import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {

  final String imageUrl;
  final String title;

  const ImageViewerPage({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),

      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (
                context,
                child,
                loadingProgress,
                ) {

              if (loadingProgress == null) {
                return child;
              }

              return const CircularProgressIndicator();
            },

            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {

              return const Text(
                'Unable to load image',
              );
            },
          ),
        ),
      ),
    );
  }
}