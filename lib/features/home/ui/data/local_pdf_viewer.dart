import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/abstract/document_viewer_state_base.dart';

class FilePdfViewer extends BasePdfViewer {
  final File file;
  final int? initialPage;

  const FilePdfViewer({
    Key? key,
    required this.file,
    this.initialPage,
    String? title,
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
  Future<Uint8List> getPdfBytes() async {
    return widget.file.readAsBytes();
  }

  void onPdfLoaded() {
    if (widget.initialPage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        jumpToPage(widget.initialPage! - 1);
      });
    }
  }
}