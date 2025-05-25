import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/models/pdf_bookmark.dart';
import '../data/book_mark_repository.dart';
import '../data/local_pdf_viewer.dart';

class BookmarksScreen extends StatelessWidget {
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookmarks', style: theme.textTheme.headlineMedium),
      ),
      body: FutureBuilder<List<CustomPdfBookmark>>(
        future: _bookmarkRepository.getAllBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              color: theme.colorScheme.secondary,
            ));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No bookmarks yet',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final bookmarks = snapshot.data!;
          // Group bookmarks by PDF file
          final Map<String, List<CustomPdfBookmark>> bookmarksByPdf = {};
          for (var bookmark in bookmarks) {
            bookmarksByPdf.putIfAbsent(bookmark.filePath, () => []).add(bookmark);
          }

          return ListView.builder(
            itemCount: bookmarksByPdf.length,
            itemBuilder: (context, index) {
              final pdfPath = bookmarksByPdf.keys.elementAt(index);
              final pdfBookmarks = bookmarksByPdf[pdfPath]!;
              final pdfName = pdfPath.split('/').last;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: isDark
                    ? theme.cardColor
                    : theme.colorScheme.surface,
                child: ExpansionTile(
                  title: Text(
                    pdfName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? theme.colorScheme.onSecondary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  children: pdfBookmarks.map((bookmark) => _buildBookmarkItem(
                    context,
                    bookmark,
                    theme,
                    isDark,
                  )).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookmarkItem(
      BuildContext context,
      CustomPdfBookmark bookmark,
      ThemeData theme,
      bool isDark,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24),
      title: Text(
        bookmark.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark
              ? theme.colorScheme.onSecondary
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Page ${bookmark.pageNumber}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? theme.colorScheme.onSecondary.withOpacity(0.7)
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          if (bookmark.previewText != null)
            Text(
              bookmark.previewText!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? theme.colorScheme.onSecondary.withOpacity(0.5)
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark
            ? theme.colorScheme.onSecondary
            : theme.colorScheme.onSurface,
      ),
      onTap: () => _openBookmark(context, bookmark),
    );
  }

  Future<void> _openBookmark(BuildContext context, CustomPdfBookmark bookmark) async {
    final file = File(bookmark.filePath);
    final fileExists = await file.exists();

    if (!fileExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The PDF file could not be found'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilePdfViewer(
          file: file,
          initialPage: bookmark.pageNumber,
        ),
      ),
    );
  }
}