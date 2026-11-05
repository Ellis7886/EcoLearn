import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/app_settings.dart';
import '../themes/app_colors.dart';
import '../helpers/material_handler.dart';
import '../services/material_cache_service.dart';
import '../services/performance_logger.dart';

/// Eco Mode material card (data from SQLite).
///
/// CHANGED: the optimised file is downloaded ONCE and then
/// opened from the phone, also without internet (learning
/// continuity). A small icon shows whether the material is
/// already available offline.
class MaterialCardSqlite extends StatefulWidget {

  final Map<String, dynamic> material;
  final bool darkTheme;

  const MaterialCardSqlite({
    super.key,
    required this.material,
    required this.darkTheme,
  });

  @override
  State<MaterialCardSqlite> createState() => _MaterialCardSqliteState();
}

class _MaterialCardSqliteState extends State<MaterialCardSqlite> {

  final MaterialCacheService _cacheService = MaterialCacheService();

  String? _localPath;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  @override
  void didUpdateWidget(covariant MaterialCardSqlite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.material['local_path'] != widget.material['local_path']) {
      _checkCache();
    }
  }

  Future<void> _checkCache() async {
    final path = await _cacheService.getCachedPath(widget.material);
    if (!mounted) return;
    setState(() {
      _localPath = path;
    });
  }

  Future<void> _open(String fileType) async {
    final settings = Provider.of<AppSettings>(
      context,
      listen: false,
    );

    // Safety net: this card is only used in Eco Mode
    if (!settings.ecoMode) {
      MaterialHandler.openMaterial(
        context,
        fileType,
        widget.material['file_url'],
        widget.material['title'],
        'Normal',
      );
      return;
    }

    if (_downloading) return;

    try {
      String path;

      if (_localPath != null) {
        path = _localPath!;
      } else {
        setState(() {
          _downloading = true;
        });

        final session = await PerformanceLogger.start();

        final result = await _cacheService.getOrDownload(widget.material);
        path = result.path;

        if (result.downloaded) {
          await PerformanceLogger.finish(
            session,
            mode: 'Eco',
            operation: 'Download Material ($fileType)',
            dataSource: 'Firebase Storage (optimised)',
            recordCount: 1,
          );
        }

        if (!mounted) return;

        setState(() {
          _localPath = path;
          _downloading = false;
        });
      }

      if (!mounted) return;

      MaterialHandler.openMaterial(
        context,
        fileType,
        path,
        widget.material['title'],
        'Eco',
      );
    } catch (e) {
      debugPrint('Material error: $e');

      if (!mounted) return;

      setState(() {
        _downloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This material is not downloaded yet. '
                'Connect to the internet once to save it for offline use.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    IconData icon = Icons.description;

    final fileType = (widget.material['type'] ?? '')
        .toString()
        .toLowerCase();

    if (fileType.contains('pdf')) {
      icon = Icons.picture_as_pdf;
    }
    else if (fileType.contains('mp4') ||
        fileType.contains('video')) {
      icon = Icons.video_library;
    }
    else if (fileType.contains('jpg') ||
        fileType.contains('jpeg') ||
        fileType.contains('png') ||
        fileType.contains('image')) {
      icon = Icons.image;
    }
    else if (fileType.contains('doc') ||
        fileType.contains('docx') ||
        fileType.contains('word')) {
      icon = Icons.article;
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      decoration: BoxDecoration(
        color: AppColors.card(widget.darkTheme,),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border(widget.darkTheme,),
        ),
        boxShadow: widget.darkTheme
            ? []
            : [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: ListTile(leading:
      Icon(
        icon,
        color: AppColors.primary,
      ),

          title: Text(
            widget.material['title'],
            style: TextStyle(
              color: AppColors.text(widget.darkTheme,),
            ),
          ),

        trailing: _downloading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Icon(
          _localPath != null
              ? Icons.offline_pin
              : Icons.cloud_download_outlined,
          color: _localPath != null
              ? AppColors.primary
              : AppColors.subText(widget.darkTheme),
          size: 20,
        ),

        onTap: () => _open(fileType),
      ),
    );
  }
}
