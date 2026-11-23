import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/performance_logger.dart';

/// Shows a learning image.
///
/// Normal Mode: original image downloaded from the network.
/// Eco Mode: optimised image opened from the phone and decoded
/// at screen width (less memory and CPU).
class ImageViewerPage extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String mode;

  const ImageViewerPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.mode,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  String _fileSize = 'Checking...';
  Uint8List? _imageBytes;

  bool get _isNetwork => widget.imageUrl.startsWith('http');

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /// Loads the image bytes (network or local file) and logs
  /// execution time, network bytes and memory for "Open Image".
  Future<void> _loadImage() async {
    final session = await PerformanceLogger.start();

    try {
      final Uint8List bytes;

      if (_isNetwork) {
        final response = await http.get(Uri.parse(widget.imageUrl));

        if (response.statusCode != 200) {
          throw Exception('Image download failed: ${response.statusCode}');
        }

        bytes = response.bodyBytes;
      } else {
        final file = File(widget.imageUrl);

        if (!await file.exists()) {
          throw Exception('Local image file not found.');
        }

        bytes = await file.readAsBytes();
      }

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _fileSize = _formatFileSize(bytes.length);
      });

      await PerformanceLogger.finish(
        session,
        mode: widget.mode,
        operation: 'Open Image',
        dataSource: _isNetwork ? 'Network' : 'Local file',
        recordCount: bytes.length,
      );
    } catch (e) {
      debugPrint('Image error: $e');

      if (!mounted) return;

      setState(() {
        _fileSize = 'Download failed';
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _imageBytes != null
                  ? InteractiveViewer(
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.contain,
                        // Eco Mode decodes the image at screen width
                        // instead of full resolution.
                        cacheWidth: widget.mode == 'Eco'
                            ? (MediaQuery.sizeOf(context).width *
                                    MediaQuery.devicePixelRatioOf(context))
                                .round()
                            : null,
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${widget.mode} Mode',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Downloaded size: $_fileSize',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
