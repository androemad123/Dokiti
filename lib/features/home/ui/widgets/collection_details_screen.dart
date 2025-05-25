import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/collection_model.dart';
import '../../../../core/repositories/collection_repository.dart';
import '../data/local_pdf_viewer.dart';

class CollectionDetailsScreen extends StatefulWidget {
  final PdfCollection collection;

  const CollectionDetailsScreen({super.key, required this.collection});

  @override
  State<CollectionDetailsScreen> createState() => _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState extends State<CollectionDetailsScreen> {
  late PdfCollection _collection;
  final _searchController = TextEditingController();
  List<String> _filteredPdfs = [];
  late final CollectionRepository _repository;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = context.read<CollectionRepository>();
    _loadCollection();
    _searchController.addListener(_filterPdfs);
  }

  Future<void> _loadCollection() async {
    setState(() => _isLoading = true);
    final loadedCollection = _repository.getCollection(widget.collection.id);
    if (loadedCollection != null) {
      setState(() {
        _collection = loadedCollection;
        _filteredPdfs = loadedCollection.pdfPaths;
      });
    }
    setState(() => _isLoading = false);
  }

  void _filterPdfs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPdfs = _collection.pdfPaths.where((path) {
        return path.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _addPdfToCollection() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final pdfPath = file.path;

        if (pdfPath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get PDF path')),
          );
          return;
        }

        setState(() => _isLoading = true);
        await _repository.addPdfToCollection(_collection.id, pdfPath);
        await _loadCollection();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${file.name} to collection'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removePdf(String pdfPath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove PDF"),
        content: const Text("Are you sure you want to remove this PDF from the collection?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      await _repository.removePdfFromCollection(_collection.id, pdfPath);
      await _loadCollection();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _collection.name,
          style: theme.textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isLoading ? null : _addPdfToCollection,
            color: theme.colorScheme.onPrimary,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search PDFs in collection",
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredPdfs.isEmpty
                  ? Center(
                child: Text(
                  "No PDFs in this collection",
                  style: theme.textTheme.bodyLarge,
                ),
              )
                  : ListView.builder(
                itemCount: _filteredPdfs.length,
                itemBuilder: (context, index) {
                  final pdfPath = _filteredPdfs[index];
                  final fileName = pdfPath.split('/').last;
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: theme.cardColor,
                    child: ListTile(
                      leading: Icon(
                        Icons.picture_as_pdf,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        fileName,
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        pdfPath,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () => _removePdf(pdfPath),
                      ),
                      onTap: () async {
                        final file = File(pdfPath);
                        if (await file.exists()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilePdfViewer(file: file),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('File not found: $fileName'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}