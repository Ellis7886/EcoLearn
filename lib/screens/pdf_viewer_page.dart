import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {

  final String pdfUrl;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SfPdfViewer.network(
        pdfUrl,
      ),
    );
  }
}