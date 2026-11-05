import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../services/performance_logger.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final String mode;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.mode = 'Normal',
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {

  PerfSession? _session;

  bool get _isNetwork => widget.pdfUrl.startsWith('http');

  @override
  void initState() {
    super.initState();
    PerformanceLogger.start().then((s) => _session = s);
  }

  void _logLoaded(int pages) {
    final session = _session;
    if (session == null) return;
    _session = null;

    PerformanceLogger.finish(
      session,
      mode: widget.mode,
      operation: 'Open PDF',
      dataSource: _isNetwork ? 'Network' : 'Local file',
      recordCount: pages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      // FIXED: web URLs must use SfPdfViewer.network.
      // SfPdfViewer.file(File(url)) could never open them.
      body: _isNetwork
          ? SfPdfViewer.network(
        widget.pdfUrl,
        onDocumentLoaded: (details) =>
            _logLoaded(details.document.pages.count),
      )
          : SfPdfViewer.file(
        File(widget.pdfUrl),
        onDocumentLoaded: (details) =>
            _logLoaded(details.document.pages.count),
      ),
    );
  }
}
