import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/abstract/document_viewer_state_base.dart';

class FilePdfViewer extends BasePdfViewer {
  final File file;

  const FilePdfViewer({
    Key? key,
    required this.file,
    String? title,
    Map<int, String> initialComments = const {},
  }) : super(key: key, title: title);

  @override
  State<StatefulWidget> createState() => _FilePdfViewerState();

  @override
  Future<Uint8List> getPdfBytes() async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      throw Exception('Could not read file: $e');
    }
  }

  @override
  String getDefaultTitle() {
    return file.path.split('/').last;
  }
}

class _FilePdfViewerState extends BasePdfViewerState<FilePdfViewer> {
  // Add any FilePdfViewer-specific state management here if needed
}