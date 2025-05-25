import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../features/home/ui/data/book_mark_repository.dart';
import '../../features/home/ui/data/local_pdf_viewer.dart';
import '../models/pdf_bookmark.dart';

abstract class BasePdfViewer extends StatefulWidget {
  final String? title;
  const BasePdfViewer({
    Key? key,
    this.title,
  }) : super(key: key);

  @protected
  Future<Uint8List> getPdfBytes();

  @protected
  String getDefaultTitle();
}

abstract class BasePdfViewerState<T extends BasePdfViewer> extends State<T> {
  late final PdfViewerController _pdfViewerController;
  late final TextEditingController _searchController;
  late final TextEditingController _bookmarkNameController;
  late final TextEditingController _bookmarkNotesController;
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();

  PdfTextSearchResult? _searchResult;
  List<CustomPdfBookmark> _bookmarks = [];
  String _customTitle = "PDF Viewer";
  bool _isSearching = false;
  bool _isDisposed = false;
  bool _hasSearchResult = false;
  bool _isSearchable = true;
  bool _showBookmarksPanel = false;
  bool _isAddingBookmark = false;
  bool _isLoading = true;
  String? _searchError;
  Uint8List? _pdfData;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _searchController = TextEditingController();
    _bookmarkNameController = TextEditingController();
    _bookmarkNotesController = TextEditingController();
    _loadPdfAndInitialize();
    _loadBookmarks();
  }

  Future<void> _loadPdfAndInitialize() async {
    try {
      final data = await widget.getPdfBytes();
      if (_isDisposed) return;

      setState(() {
        _pdfData = data;
        _isLoading = false;
      });

      _initializeTitle();

    } catch (e) {
      if (_isDisposed) return;
      setState(() {
        _isLoading = false;
        _searchError = 'Failed to load PDF: ${e.toString()}';
      });
    }
  }

  Future<void> _loadBookmarks() async {
    String identifier;
    if (widget is FilePdfViewer) {
      identifier = (widget as FilePdfViewer).file.path; // Match storage key
    } else {
      identifier = widget.getDefaultTitle(); // Fallback for other types
    }

    _bookmarks = await _bookmarkRepository.getBookmarksForPdf(identifier);
    if (_isSafeToUpdate()) {
      setState(() {});
    }
  }

  void _initializeTitle() {
    if (widget.title == null || widget.title == "PDF Viewer") {
      final prettyTitle = _prettifyFileName(widget.getDefaultTitle());
      if (_isSafeToUpdate()) {
        setState(() => _customTitle = prettyTitle);
      }
    } else {
      _customTitle = widget.title!;
    }
  }

  String _prettifyFileName(String rawName) {
    return rawName
        .replaceAll(".pdf", "")
        .replaceFirst(RegExp(r"^\d+_"), "")
        .replaceAll("_", " ")
        .trim();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelSearch();
    _pdfViewerController.dispose();
    _searchController.dispose();
    _bookmarkNameController.dispose();
    _bookmarkNotesController.dispose();
    super.dispose();
  }

  bool _isSafeToUpdate() => !_isDisposed && mounted;

  Future<void> _checkIfSearchable(sf.PdfDocument document) async {
    try {
      final text = await sf.PdfTextExtractor(document).extractText(startPageIndex: 0, endPageIndex: 0);
      if (_isSafeToUpdate()) {
        setState(() {
          _isSearchable = text.trim().isNotEmpty;
          if (!_isSearchable) {
            _searchError = 'Document may not contain searchable text';
          }
        });
      }
    } catch (e) {
      if (_isSafeToUpdate()) {
        setState(() {
          _isSearchable = false;
          _searchError = 'Unable to check document text content';
        });
      }
    }
  }

  Future<void> _searchText(String text) async {
    if (text.isEmpty || !_isSafeToUpdate()) return;

    if (!_isSearchable) {
      if (_isSafeToUpdate()) {
        setState(() {
          _searchError = 'Cannot search - document not searchable';
          _hasSearchResult = false;
          _isSearching = false;
        });
      }
      return;
    }

    _cancelSearch();

    if (_isSafeToUpdate()) {
      setState(() {
        _isSearching = true;
        _hasSearchResult = false;
        _searchError = null;
      });
    }

    try {
      final newResult = await _pdfViewerController.searchText(
        text,
        searchOption: TextSearchOption.caseSensitive,
      );

      if (!_isSafeToUpdate()) {
        newResult.clear();
        return;
      }

      newResult.addListener(_searchListener);

      if (_isSafeToUpdate()) {
        setState(() {
          _searchResult = newResult;
          _hasSearchResult = newResult.hasResult;
          _isSearching = false;
        });
      }

      if (newResult.hasResult) {
        newResult.nextInstance();
      }
    } catch (e) {
      debugPrint('Search failed: $e');
      if (_isSafeToUpdate()) {
        setState(() {
          _isSearching = false;
          _hasSearchResult = false;
          _searchError = 'Search failed: ${e.toString()}';
        });
      }
    }
  }

  void _cancelSearch() {
    try {
      _searchResult?.removeListener(_searchListener);
      _searchResult?.clear();
      _pdfViewerController.clearSelection();
      _searchResult = null;
    } catch (e) {
      debugPrint('Error canceling search: $e');
    }
  }

  void _searchListener() {
    if (_isSafeToUpdate()) {
      setState(() {
        _hasSearchResult = _searchResult?.hasResult ?? false;
      });
    }
  }

  Future<void> _addCurrentPageBookmark() async {
    final currentPage = _pdfViewerController.pageNumber;

    setState(() => _isAddingBookmark = true);

    try {
      String? previewText;
      try {
        final document = sf.PdfDocument(inputBytes: await widget.getPdfBytes());
        final text = await sf.PdfTextExtractor(document)
            .extractText(startPageIndex: currentPage - 1, endPageIndex: currentPage - 1);
        previewText = text.length > 100 ? '${text.substring(0, 100)}...' : text;
      } catch (e) {
        debugPrint('Could not extract preview text: $e');
      }

      // Get the actual file path from the widget (for FilePdfViewer)
      String filePath;
      if (widget is FilePdfViewer) {
        filePath = (widget as FilePdfViewer).file.path;
      } else {
        // Handle other cases (like network PDFs) if needed
        throw Exception('Only file-based bookmarks are supported');
      }

      final bookmark = CustomPdfBookmark(
        filePath: filePath, // Store the actual file path
        name: _bookmarkNameController.text.trim().isEmpty
            ? 'Page ${currentPage + 1}'
            : _bookmarkNameController.text.trim(),
        pageNumber: currentPage + 1,
        notes: _bookmarkNotesController.text.trim().isEmpty ? null : _bookmarkNotesController.text.trim(),
        previewText: previewText,
      );

      await _bookmarkRepository.addBookmark(bookmark);
      await _loadBookmarks();
    } finally {
      if (_isSafeToUpdate()) {
        setState(() {
          _isAddingBookmark = false;
          _bookmarkNameController.clear();
          _bookmarkNotesController.clear();
        });
      }
    }
  }
  Future<void> _removeBookmark(CustomPdfBookmark bookmark) async {
    await _bookmarkRepository.removeBookmark(bookmark);
    await _loadBookmarks();
  }

  void _navigateToBookmark(CustomPdfBookmark bookmark) {
    _pdfViewerController.jumpToPage(bookmark.pageNumber - 1);
    setState(() => _showBookmarksPanel = false);
  }

  void _showAddBookmarkDialog() {
    final currentPage = _pdfViewerController.pageNumber ?? 0;
    _bookmarkNameController.text = 'Page ${currentPage + 1}';
    _bookmarkNotesController.clear();
    setState(() => _isAddingBookmark = true);
  }
  void jumpToPage(int pageNumber) {
    _pdfViewerController.jumpToPage(pageNumber);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_customTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _pdfData != null
                ? () => setState(() => _showBookmarksPanel = !_showBookmarksPanel)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _pdfData != null ? () => _showSearchDialog(context) : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pdfData == null
              ? const SizedBox.shrink()
              : SfPdfViewer.memory(
            _pdfData!,
            controller: _pdfViewerController,
            key: ValueKey(_customTitle),
            onDocumentLoaded: (details) {
              _checkIfSearchable(details.document);
            },
          ),

          if (_showBookmarksPanel) _buildBookmarksPanel(),

          if (_isAddingBookmark) _buildAddBookmarkDialog(),

          if (_searchError != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _searchError!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          if (_isSearching || (_searchResult != null)) _buildSearchResultIndicator(),
        ],
      ),
      floatingActionButton: _pdfData != null && !_showBookmarksPanel
          ? FloatingActionButton(
        child: const Icon(Icons.bookmark_add),
        onPressed: () => _showAddBookmarkDialog(),
      )
          : null,
    );
  }

  Widget _buildAddBookmarkDialog() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Bookmark',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _bookmarkNameController,
                decoration: const InputDecoration(
                  labelText: 'Bookmark Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _bookmarkNotesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isAddingBookmark = false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addCurrentPageBookmark,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksPanel() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bookmarks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showBookmarksPanel = false),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _bookmarks.isEmpty
                  ? const Center(
                child: Text('No bookmarks yet'),
              )
                  : ListView.builder(
                itemCount: _bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = _bookmarks[index];
                  return ListTile(
                    title: Text(bookmark.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Page ${bookmark.pageNumber}'),
                        if (bookmark.previewText != null)
                          Text(
                            bookmark.previewText!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (bookmark.notes != null)
                          Text(
                            bookmark.notes!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeBookmark(bookmark),
                    ),
                    onTap: () => _navigateToBookmark(bookmark),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultIndicator() {
    return Positioned(
      bottom: 80,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: _isSearching
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
            const SizedBox(width: 8),
            const Text("Searching..."),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _cancelSearch();
                if (_isSafeToUpdate()) {
                  setState(() => _isSearching = false);
                }
              },
            ),
          ],
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchResult != null && _searchResult!.hasResult) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  _searchResult?.previousInstance();
                  if (_isSafeToUpdate()) {
                    setState(() {});
                  }
                },
              ),
              Text("${_searchResult!.currentInstanceIndex}/${_searchResult!.totalInstanceCount}"),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.black),
                onPressed: () {
                  _searchResult?.nextInstance();
                  if (_isSafeToUpdate()) {
                    setState(() {});
                  }
                },
              ),
            ],
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                _cancelSearch();
                if (_isSafeToUpdate()) {
                  setState(() {
                    _isSearching = false;
                    _hasSearchResult = false;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  // In BasePdfViewerState
  Future<void> loadPdfData(Uint8List data) async {
    if (_isDisposed) return;

    setState(() {
      _pdfData = data;
      _isLoading = false;
    });

    _initializeTitle();
  }
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Search"),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search text",
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                final text = _searchController.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context);
                  _searchText(text);
                }
              },
            ),
          ),
          onSubmitted: (text) {
            if (text.trim().isNotEmpty) {
              Navigator.pop(context);
              _searchText(text.trim());
            }
          },
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              _cancelSearch();
              Navigator.pop(context);
              if (_isSafeToUpdate()) {
                setState(() => _isSearching = false);
              }
            },
          ),
        ],
      ),
    );
  }}
