import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/models/pdf_bookmark.dart';

class BookmarkRepository {
  static const String _bookmarksKey = 'pdf_bookmarks';
  static String get bookmarksKey => _bookmarksKey;

  Future<List<CustomPdfBookmark>> getBookmarksForPdf(String pdfIdentifier) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
    print(bookmarksJson);

    return bookmarksJson
        .map((json) => CustomPdfBookmark.fromMap(jsonDecode(json)))
        .where((bookmark) => bookmark.filePath == pdfIdentifier)
        .toList();
  }



  Future<List<CustomPdfBookmark>> getAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];

      if (bookmarksJson.isEmpty) {
        print('No bookmarks found in storage');
        return [];
      }

      final bookmarks = <CustomPdfBookmark>[];
      for (final json in bookmarksJson) {
        try {
          final decoded = jsonDecode(json);
          final bookmark = CustomPdfBookmark.fromMap(decoded);
          bookmarks.add(bookmark);
        } catch (e) {
          print('Error parsing bookmark JSON: $e\nJSON: $json');
        }
      }

      return bookmarks;
    } catch (e) {
      print('Error getting bookmarks: $e');
      rethrow;
    }
  }


  Future<void> addBookmark(CustomPdfBookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(bookmarksKey) ?? [];
    bookmarksJson.add(jsonEncode(bookmark.toMap()));
    await prefs.setStringList(bookmarksKey, bookmarksJson);
  }

  Future<void> removeBookmark(CustomPdfBookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(bookmarksKey) ?? [];
    bookmarksJson.removeWhere((json) {
      final existing = CustomPdfBookmark.fromMap(jsonDecode(json));
      return existing.filePath == bookmark.filePath &&
          existing.pageNumber == bookmark.pageNumber;
    });
    await prefs.setStringList(bookmarksKey, bookmarksJson);
  }
}