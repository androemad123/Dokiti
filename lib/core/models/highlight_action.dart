import 'package:flutter/cupertino.dart';

class HighlightAction {
  final TextSelection selection;
  final Color color;
  final int pageNumber;
  final DateTime timestamp;

  HighlightAction({
    required this.selection,
    required this.color,
    required this.pageNumber,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}