import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  PdfTextSearchResult? _searchResult;
  String _customTitle = "PDF Viewer";
  bool _isSearching = false;
  bool _isDisposed = false;
  bool _hasSearchResult = false;
  bool _isSearchable = true;
  String? _searchError;
  bool _isLoading = true;
  Uint8List? _pdfData;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _searchController = TextEditingController();
    _loadPdfAndInitialize();
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
    super.dispose();
  }

  bool _isSafeToUpdate() => !_isDisposed && mounted;

  Future<void> _checkIfSearchable(PdfDocument document) async {
    try {
      final text = await PdfTextExtractor(document).extractText(startPageIndex: 0, endPageIndex: 0);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_customTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _pdfData != null ? () => _showSearchDialog(context) : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfData == null
          ? const SizedBox.shrink()
          : Stack(
        children: [
          SfPdfViewer.memory(
            _pdfData!,
            controller: _pdfViewerController,
            key: ValueKey(_customTitle),
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              _checkIfSearchable(details.document);
            },
          ),
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
  }
}
