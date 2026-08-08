import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../provider/app_settings.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String title;

  // Firebase Storage path of the optimized Eco Mode video
  final String? ecoFilePath;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
    this.ecoFilePath,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final settings = Provider.of<AppSettings>(
      context,
      listen: false,
    );

    String videoUrl = widget.videoUrl;

    // ========================================
    // ECO MODE
    // ========================================

    if (settings.ecoMode &&
        widget.ecoFilePath != null &&
        widget.ecoFilePath!.isNotEmpty) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child(widget.ecoFilePath!);

        videoUrl = await storageRef.getDownloadURL();

        debugPrint(
          'Eco Mode: Using optimized video',
        );

        debugPrint(
          'Eco video path: ${widget.ecoFilePath}',
        );
      } catch (e) {
        debugPrint(
          'Failed to load optimized video: $e',
        );

        // Fall back to original video
        videoUrl = widget.videoUrl;
      }
    }

    // ========================================
    // CREATE VIDEO CONTROLLER
    // ========================================

    if (videoUrl.startsWith('http')) {
      _videoController =
          VideoPlayerController.networkUrl(
            Uri.parse(videoUrl),
          );
    } else {
      _videoController =
          VideoPlayerController.file(
            File(videoUrl),
          );
    }

    await _videoController.initialize();

    if (!mounted) return;

    // ========================================
    // CHEWIE
    // ========================================

    _chewieController = ChewieController(
      videoPlayerController: _videoController,

      // Normal Mode = auto play
      // Eco Mode = don't auto play
      autoPlay: !settings.ecoMode,

      looping: false,

      allowFullScreen: true,

      allowPlaybackSpeedChanging: true,
    );

    setState(() {});
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

      body: Center(
        child: _chewieController != null
            ? Chewie(
          controller: _chewieController!,
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}