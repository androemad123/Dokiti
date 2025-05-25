import 'dart:io';

class CustomPdfBookmark {
  final String filePath; // Store the complete file path
  final String name;
  final int pageNumber;
  final DateTime createdAt;
  final String? notes;
  final String? previewText;

  CustomPdfBookmark({
    required this.filePath,
    required this.name,
    required this.pageNumber,
    DateTime? createdAt,
    this.notes,
    this.previewText,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to File object when needed
  File get file => File(filePath);

  Map<String, dynamic> toMap() {
    return {
      'filePath': filePath,
      'name': name,
      'pageNumber': pageNumber,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'previewText': previewText,
    };
  }

  factory CustomPdfBookmark.fromMap(Map<String, dynamic> map) {
    return CustomPdfBookmark(
      filePath: map['filePath'] ?? map['pdfIdentifier'], // Backward compatibility
      name: map['name'],
      pageNumber: map['pageNumber'],
      createdAt: DateTime.parse(map['createdAt']),
      notes: map['notes'],
      previewText: map['previewText'],
    );
  }
}