import 'package:hive/hive.dart';
import '../models/collection_model.dart';

class CollectionRepository {
  static const _boxName = 'collections';
  late Box<PdfCollection> _box;

  // Initialize the box once when the app starts
  Future<void> init() async {
    _box = await Hive.openBox<PdfCollection>(_boxName);
  }

  List<PdfCollection> getAllCollections() {
    return _box.values.toList();
  }

  PdfCollection? getCollection(String id) {
    return _box.get(id);
  }

  Future<void> addCollection(PdfCollection collection) async {
    await _box.put(collection.id, collection);
  }

  Future<void> updateCollection(PdfCollection collection) async {
    await _box.put(collection.id, collection);
  }

  Future<void> deleteCollection(String id) async {
    await _box.delete(id);
  }

  Future<void> addPdfToCollection(String collectionId, String pdfPath) async {
    final collection = _box.get(collectionId);
    if (collection != null) {
      // Check if PDF already exists to avoid duplicates
      if (!collection.pdfPaths.contains(pdfPath)) {
        final updated = collection.copyWith(
          pdfPaths: [...collection.pdfPaths, pdfPath],
        );
        await _box.put(collectionId, updated);
      }
    }
  }

  Future<void> removePdfFromCollection(String collectionId, String pdfPath) async {
    final collection = _box.get(collectionId);
    if (collection != null) {
      final updated = collection.copyWith(
        pdfPaths: collection.pdfPaths.where((path) => path != pdfPath).toList(),
      );
      await _box.put(collectionId, updated);
    }
  }

  Future<void> close() async {
    await _box.close();
  }
}