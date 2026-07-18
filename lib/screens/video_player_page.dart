import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';

import '../provider/app_settings.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
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

    if (widget.videoUrl.startsWith('http')) {

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

    } else {

      _videoController = VideoPlayerController.file(
        File(widget.videoUrl),
      );
    }

    _videoController.initialize().then((_) {
      final ecoMode = Provider.of<AppSettings>(
        context,
        listen: false,
      ).ecoMode;

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: !ecoMode,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
      );

      setState(() {});
    });
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