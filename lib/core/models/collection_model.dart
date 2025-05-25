// collection_model.dart
import 'package:hive/hive.dart';

part 'collection_model.g.dart';

@HiveType(typeId: 0)
class PdfCollection {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final List<String> pdfPaths;

  PdfCollection({
    required this.id,
    required this.name,
    required this.createdAt,
    this.pdfPaths = const [],
  });

  PdfCollection copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? pdfPaths,
  }) {
    return PdfCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      pdfPaths: pdfPaths ?? this.pdfPaths,
    );
  }
}