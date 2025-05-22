import 'package:flutter/material.dart';
class BookmarkModel {
  final String title;
  final String source;
  final String category;
  final String time;
  final String imageUrl;
  final IconData icon;

  BookmarkModel({
    required this.title,
    required this.source,
    required this.category,
    required this.time,
    required this.imageUrl,
    required this.icon,
  });
}