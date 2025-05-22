import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/abstract/document_viewer_state_base.dart';

class UrlPdfViewer extends BasePdfViewer {
  final String fileUrl;

  const UrlPdfViewer({
    Key? key,
    required this.fileUrl,
    String? title,
    Map<int, String> initialComments = const {},
  }) : super(key: key, title: title,);

  @override
  State<StatefulWidget> createState() => _UrlPdfViewerState();

  @override
  Future<Uint8List> getPdfBytes() async {
    try {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode != 200) throw Exception('Failed to load PDF');
      return response.bodyBytes;
    } catch (e) {
      throw Exception('Could not download PDF: $e');
    }
  }

  @override
  String getDefaultTitle() {
    try {
      final uri = Uri.parse(fileUrl);
      return uri.pathSegments.lastWhere((e) => e.isNotEmpty, orElse: () => 'Document');
    } catch (_) {
      return 'PDF Document';
    }
  }
}

class _UrlPdfViewerState extends BasePdfViewerState<UrlPdfViewer> {
  // Add any UrlPdfViewer-specific state management here if needed
}