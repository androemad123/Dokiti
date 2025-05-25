// collections_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/collection_model.dart';
import '../../../../core/repositories/collection_repository.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'collection_details_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final _searchController = TextEditingController();
  late final CollectionRepository _collectionRepository;
  List<PdfCollection> _collections = [];
  List<PdfCollection> _filteredCollections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _collectionRepository = context.read<CollectionRepository>();
    _loadCollections();
    _searchController.addListener(_filterCollections);
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    _collections = await _collectionRepository.getAllCollections();
    _filteredCollections = _collections;
    setState(() => _isLoading = false);
  }

  void _filterCollections() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCollections = _collections.where((collection) {
        return collection.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _createNewCollection() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _CreateCollectionDialog(),
    );

    if (name != null && name.isNotEmpty) {
      final newCollection = PdfCollection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdAt: DateTime.now(),
      );

      await _collectionRepository.addCollection(newCollection);
      await _loadCollections();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collections"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewCollection,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              controller: _searchController,
              hintText: "Search your collections",
              isSecuredField: false,
              prefixIcon: Icons.search_outlined,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCollections.isEmpty
                  ? const Center(child: Text("No collections found"))
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _filteredCollections.length,
                itemBuilder: (context, index) {
                  final collection = _filteredCollections[index];
                  return _CollectionCard(
                    collection: collection,
                    onTap: () => _openCollection(collection),
                    onDelete: () => _deleteCollection(collection.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCollection(PdfCollection collection) {
    Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => CollectionDetailsScreen(collection: collection),
    ));
  }

  Future<void> _deleteCollection(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Collection"),
        content: const Text("Are you sure you want to delete this collection?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _collectionRepository.deleteCollection(id);
      await _loadCollections();
    }
  }
}

class _CreateCollectionDialog extends StatelessWidget {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Collection"),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: "Collection Name",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _nameController.text.trim()),
          child: const Text("Create"),
        ),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final PdfCollection collection;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CollectionCard({
    required this.collection,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      collection.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (details) => _showPopupMenu(context, details),
                    child: const Icon(Icons.more_vert, size: 20),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${collection.pdfPaths.length} items",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                "Created: ${DateFormat('MMM d, y').format(collection.createdAt)}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context, TapDownDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromLTRB(
      details.globalPosition.dx,
      details.globalPosition.dy,
      overlay.size.width - details.globalPosition.dx,
      overlay.size.height - details.globalPosition.dy,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        onDelete();
      }
    });
  }
}