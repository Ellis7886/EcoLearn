import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;

class VideoPlayerPage extends StatefulWidget {

  final String videoUrl;
  final String title;
  final String mode;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.mode,
  });

  @override
  State<VideoPlayerPage> createState() =>
      _VideoPlayerPageState();
}

class _VideoPlayerPageState
    extends State<VideoPlayerPage> {

  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  String _fileSize = 'Checking...';

  @override
  void initState() {
    super.initState();

    _initializeVideo();
    _getFileSize();
  }

  Future<void> _initializeVideo() async {

    debugPrint('============================');
    debugPrint('VIDEO PLAYER');
    debugPrint('Mode: ${widget.mode}');
    debugPrint('Video URL: ${widget.videoUrl}');
    debugPrint('============================');

    // Network video
    if (widget.videoUrl.startsWith('http')) {

      _videoController =
          VideoPlayerController.networkUrl(
            Uri.parse(widget.videoUrl),
          );
    }

    // Local video
    else {

      _videoController =
          VideoPlayerController.file(
            File(widget.videoUrl),
          );
    }

    await _videoController.initialize();

    if (!mounted) return;

    debugPrint(
      'Video initialized successfully.',
    );

    // ========================================
    // Normal / Eco Mode
    // ========================================

    final bool isNormalMode =
        widget.mode.toLowerCase() == 'normal';

    _chewieController = ChewieController(

      videoPlayerController:
      _videoController,

      // Normal = autoplay
      // Eco = no autoplay
      autoPlay: isNormalMode,

      looping: false,

      allowFullScreen: true,

      allowPlaybackSpeedChanging: true,
    );

    setState(() {});
  }

  Future<void> _getFileSize() async {

    try {

      // Network file
      if (widget.videoUrl.startsWith('http')) {

        final response = await http.head(
          Uri.parse(widget.videoUrl),
        );

        final contentLength =
        response.headers['content-length'];

        if (contentLength != null) {

          final bytes =
          int.parse(contentLength);

          if (!mounted) return;

          setState(() {
            _fileSize =
                _formatFileSize(bytes);
          });

        } else {

          if (!mounted) return;

          setState(() {
            _fileSize = 'Unknown';
          });
        }
      }

      // Local file
      else {

        final file =
        File(widget.videoUrl);

        if (await file.exists()) {

          final bytes =
          await file.length();

          if (!mounted) return;

          setState(() {
            _fileSize =
                _formatFileSize(bytes);
          });

        } else {

          if (!mounted) return;

          setState(() {
            _fileSize =
            'File not found';
          });
        }
      }

    } catch (e) {

      debugPrint(
        'Unable to get video file size: $e',
      );

      if (!mounted) return;

      setState(() {
        _fileSize = 'Unknown';
      });
    }
  }

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
  void dispose() {

    _chewieController?.dispose();

    _videoController.dispose();

    super.dispose();
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
              child: _chewieController != null

                  ? Chewie(
                controller:
                _chewieController!,
              )

                  : const CircularProgressIndicator(),
            ),
          ),

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

                const SizedBox(height: 5),

                const Text(
                  'Video File Size',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _fileSize,
                  style: const TextStyle(
                    fontSize: 18,
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