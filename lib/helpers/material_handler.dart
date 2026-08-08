import 'package:flutter/material.dart';

import '../screens/pdf_viewer_page.dart';
import '../screens/video_player_page.dart';
import '../screens/image_viewer_page.dart';

class MaterialHandler {

  static void openMaterial(
      BuildContext context,
      String fileType,
      String path,
      String title,
      ) {

    if (fileType.contains('pdf')) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerPage(
            pdfUrl: path,
            title: title,
          ),
        ),
      );

    } else if (fileType.contains('video') ||
        fileType.contains('mp4')) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerPage(
            videoUrl: path,
            title: title,
          ),
        ),
      );

    } else if (fileType.contains('jpg') ||
        fileType.contains('jpeg') ||
        fileType.contains('png') ||
        fileType.contains('image')) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageViewerPage(
            imageUrl: path,
            title: title,
          ),
        ),
      );
    }
  }
}