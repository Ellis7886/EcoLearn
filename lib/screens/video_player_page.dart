import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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

  late VideoPlayerController _controller;

  @override
  @override
  void initState() {
    super.initState();

    debugPrint('VIDEO URL: ${widget.videoUrl}');

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    _controller.initialize().then((_) {
      debugPrint('VIDEO INITIALIZED SUCCESSFULLY');

      setState(() {});
    }).catchError((error) {
      debugPrint('VIDEO ERROR: $error');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Center(
        child: _controller.value.isInitialized
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),

            const SizedBox(height: 20),

            IconButton(
              iconSize: 50,
              icon: Icon(
                _controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),

              onPressed: () {

                setState(() {

                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  }
                  else {
                    _controller.play();
                  }
                });
              },
            ),
          ],
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}