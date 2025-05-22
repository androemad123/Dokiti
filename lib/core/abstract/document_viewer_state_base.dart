import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  late PdfViewerController _pdfViewerController;
  late final TextEditingController _searchController;
  PdfTextSearchResult? _searchResult;
  String _customTitle = "PDF Viewer";
  bool _isSearching = false;
  bool _isDisposed = false;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _searchController = TextEditingController();
    _initializeTitle();
  }

  void _initializeTitle() {
    if (widget.title == null || widget.title == "PDF Viewer") {
      final prettyTitle = _prettifyFileName(widget.getDefaultTitle());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted) {
          setState(() => _customTitle = prettyTitle);
        }
      });
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
    _isSearchActive = false;

    _searchResult?.removeListener(_searchListener);
    try {
      _searchResult?.clear();
      _pdfViewerController.clearSelection();
    } catch (_) {}
    _searchResult = null;

    _pdfViewerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchText(String text) async {
    if (text.isEmpty || _isDisposed || !mounted) return;
    _cancelCurrentSearch();
    _isSearchActive = true;

    try {
      setState(() => _isSearching = true);
      final newResult = await _pdfViewerController.searchText(
        text,
        searchOption: TextSearchOption.caseSensitive,
      );

      if (_shouldAbortSearch()) {
        setState(() => _isSearching = false);
        return;
      }

      newResult.addListener(_searchListener);
      setState(() => _searchResult = newResult);

      if (newResult.hasResult) {
        newResult.nextInstance();
      }
    } catch (e) {
      debugPrint('Search failed: $e');
    } finally {
      _isSearchActive = false;
      if (!_isDisposed && mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _cancelCurrentSearch() {
    try {
      _searchResult?.removeListener(_searchListener);
      _searchResult?.clear();
      _pdfViewerController.clearSelection();
    } catch (e) {
      debugPrint('Error canceling search: $e');
    }
  }

  bool _shouldAbortSearch() {
    return _isDisposed || !mounted || !_isSearchActive;
  }

  void _searchListener() {
    if (!_isDisposed && mounted) {
      setState(() {});
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
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: widget.getPdfBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No document data'));
          }

          return Stack(
            children: [
              SfPdfViewer.memory(
                snapshot.data!,
                controller: _pdfViewerController,
                key: ValueKey(_customTitle),
              ),
              _buildSearchResultIndicator(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResultIndicator() {
    if (!_isSearching && (_searchResult == null || !_searchResult!.hasResult)) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 20,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchResult!.hasResult) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _searchResult!.previousInstance,
              ),
              Text("${_searchResult!.currentInstanceIndex + 1}"
                  "/${_searchResult!.totalInstanceCount}"),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _searchResult!.nextInstance,
              ),
            ] else ...[
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
              const SizedBox(width: 8),
              const Text("Searching..."),
            ],
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _cancelCurrentSearch();
                if (!_isDisposed && mounted) {
                  setState(() => _isSearching = false);
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
              _cancelCurrentSearch();
              Navigator.pop(context);
              if (!_isDisposed && mounted) {
                setState(() => _isSearching = false);
              }
            },
          ),
        ],
      ),
    );
  }
}
