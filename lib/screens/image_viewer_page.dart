import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  State<ImageViewerPage> createState() =>
      _ImageViewerPageState();
}

class _ImageViewerPageState
    extends State<ImageViewerPage> {

  String _fileSize = 'Checking...';

  @override
  void initState() {
    super.initState();

    _getFileSize();
  }

  // ========================================
  // Get image file size
  // ========================================

  Future<void> _getFileSize() async {

    try {

      // ======================================
      // Network image
      // ======================================

      if (widget.imageUrl.startsWith('http')) {

        final response = await http.head(
          Uri.parse(widget.imageUrl),
        );

        final contentLength =
        response.headers['content-length'];

        if (contentLength != null) {

          final bytes = int.parse(contentLength);

          if (!mounted) return;

          setState(() {
            _fileSize = _formatFileSize(bytes);
          });

        } else {

          if (!mounted) return;

          setState(() {
            _fileSize = 'Unknown';
          });
        }
      }

      // ======================================
      // Local image
      // ======================================

      else {

        final file = File(widget.imageUrl);

        if (await file.exists()) {

          final bytes = await file.length();

          if (!mounted) return;

          setState(() {
            _fileSize = _formatFileSize(bytes);
          });

        } else {

          if (!mounted) return;

          setState(() {
            _fileSize = 'File not found';
          });
        }
      }

    } catch (e) {

      debugPrint(
        'Unable to get image file size: $e',
      );

      if (!mounted) return;

      setState(() {
        _fileSize = 'Unknown';
      });
    }
  }

  // ========================================
  // Format file size
  // ========================================

  String _formatFileSize(int bytes) {

    if (bytes < 1024) {
      return '$bytes B';
    }

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

          // ==================================
          // Image
          // ==================================

          Expanded(
            child: Center(
              child: InteractiveViewer(
                child: widget.imageUrl.startsWith('http')
                    ? Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                )
                    : Image.file(
                  File(widget.imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ==================================
          // File information
          // ==================================

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
                  'File size: $_fileSize',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}