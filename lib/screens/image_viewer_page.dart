import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageViewerPage extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String mode;

  // Used only for automated research testing
  final bool testMode;

  const ImageViewerPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.mode,
    this.testMode = false,
  });

  @override
  State<ImageViewerPage> createState() =>
      _ImageViewerPageState();
}

class _ImageViewerPageState
    extends State<ImageViewerPage> {

  String _fileSize = 'Checking...';

  Uint8List? _imageBytes;

  Timer? _testTimer;

  bool _testStarted = false;
  bool _testFinished = false;

  @override
  void initState() {
    super.initState();

    _loadImage();
  }

  // ========================================
  // LOAD IMAGE
  // ========================================

  Future<void> _loadImage() async {

    try {

      debugPrint('================================');
      debugPrint('IMAGE RESOURCE TEST');
      debugPrint('================================');

      debugPrint('Mode: ${widget.mode}');
      debugPrint('Image URL: ${widget.imageUrl}');

      // ======================================
      // NETWORK IMAGE
      // ======================================

      if (widget.imageUrl.startsWith('http')) {

        debugPrint('IMAGE SOURCE: NETWORK');
        debugPrint('Downloading image with HTTP GET...');

        final response = await http.get(
          Uri.parse(widget.imageUrl),
        );

        debugPrint(
          'HTTP STATUS: ${response.statusCode}',
        );

        if (response.statusCode != 200) {

          throw Exception(
            'Image download failed: '
                '${response.statusCode}',
          );
        }

        final bytes = response.bodyBytes;

        debugPrint(
          'IMAGE NETWORK BYTES: ${bytes.length}',
        );

        debugPrint(
          'IMAGE NETWORK SIZE: '
              '${_formatFileSize(bytes.length)}',
        );

        if (!mounted) return;

        setState(() {

          _imageBytes = bytes;

          _fileSize =
              _formatFileSize(bytes.length);

        });

        // ====================================
        // Start automated test AFTER download
        // ====================================

        if (widget.testMode) {

          _startAutomaticTest();
        }
      }

      // ======================================
      // LOCAL IMAGE
      // ======================================

      else {

        debugPrint('IMAGE SOURCE: LOCAL FILE');

        final file =
        File(widget.imageUrl);

        if (!await file.exists()) {

          throw Exception(
            'Local image file not found.',
          );
        }

        final bytes =
        await file.readAsBytes();

        debugPrint(
          'LOCAL IMAGE BYTES: ${bytes.length}',
        );

        debugPrint(
          'LOCAL IMAGE SIZE: '
              '${_formatFileSize(bytes.length)}',
        );

        if (!mounted) return;

        setState(() {

          _imageBytes = bytes;

          _fileSize =
              _formatFileSize(bytes.length);

        });

        if (widget.testMode) {

          _startAutomaticTest();
        }
      }

    } catch (e) {

      debugPrint(
        'IMAGE DOWNLOAD ERROR: $e',
      );

      if (!mounted) return;

      setState(() {

        _fileSize =
        'Download failed';

      });
    }
  }

  // ========================================
  // START AUTOMATIC TEST
  // ========================================

  void _startAutomaticTest() {

    if (_testStarted ||
        _testFinished ||
        !widget.testMode ||
        !mounted) {
      return;
    }

    _testStarted = true;

    debugPrint('================================');
    debugPrint('IMAGE TEST STARTED');
    debugPrint('Mode: ${widget.mode}');
    debugPrint('Image loaded successfully.');
    debugPrint('Waiting 3 seconds...');
    debugPrint('================================');

    _testTimer = Timer(
      const Duration(seconds: 3),
      _finishTest,
    );
  }

  // ========================================
  // FINISH AUTOMATIC TEST
  // ========================================

  void _finishTest() {

    if (_testFinished ||
        !mounted) {
      return;
    }

    _testFinished = true;

    debugPrint('================================');
    debugPrint('IMAGE TEST COMPLETED');
    debugPrint('Mode: ${widget.mode}');
    debugPrint(
      'Downloaded size: $_fileSize',
    );
    debugPrint('================================');

    Navigator.pop(context);
  }

  // ========================================
  // FORMAT FILE SIZE
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

  // ========================================
  // DISPOSE
  // ========================================

  @override
  void dispose() {

    _testTimer?.cancel();

    _testFinished = true;

    super.dispose();
  }

  // ========================================
  // BUILD
  // ========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Column(
        children: [

          // ==================================
          // IMAGE
          // ==================================

          Expanded(
            child: Center(

              child: _imageBytes != null

                  ? InteractiveViewer(
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.contain,
                ),
              )

                  : const CircularProgressIndicator(),
            ),
          ),

          // ==================================
          // FILE INFORMATION
          // ==================================

          Padding(
            padding:
            const EdgeInsets.all(16),

            child: Column(
              children: [

                Text(
                  '${widget.mode} Mode',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  'Downloaded size: $_fileSize',
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