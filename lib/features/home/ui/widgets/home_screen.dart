import 'dart:io';
import 'package:alhy_momken_task/core/widgets/app_text_field.dart';
import 'package:alhy_momken_task/features/home/ui/widgets/category_item.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/collection_model.dart';
import '../../../../core/models/pdf_bookmark.dart';
import '../../../../core/repositories/collection_repository.dart';
import '../../../../core/widgets/recent_bookmark_item.dart';
import '../../../../core/widgets/recent_folder_item.dart';
import '../data/book_mark_repository.dart';
import '../data/document_viewer.dart';
import '../data/local_pdf_viewer.dart';
import 'document_alert_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<CustomPdfBookmark>> _recentBookmarksFuture;
  bool _isLoading = true;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _recentBookmarksFuture = _loadRecentBookmarks();
    print(_recentBookmarksFuture);
    _loadBookmarks();
  }

  Future<List<CustomPdfBookmark>> _loadRecentBookmarks() async {
    final repository = Provider.of<BookmarkRepository>(context, listen: false);
    final allBookmarks = await repository.getAllBookmarks();
    // Sort by date (assuming you have a date field in CustomPdfBookmark)
    allBookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allBookmarks.take(3).toList(); // Get 3 most recent
  }
  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = Provider.of<BookmarkRepository>(context, listen: false);
      final allBookmarks = await repository.getAllBookmarks();

      // Sort by date (newest first)
      allBookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _recentBookmarksFuture = Future.value(allBookmarks.take(3).toList());
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load bookmarks: ${e.toString()}';
        _isLoading = false;
      });
      print('Error loading bookmarks: $e');
    }
  }
  void _showUrlInputDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => DocumentInputDialog(),
    );

    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UrlPdfViewer(
            fileUrl: result['url']!,
          ),
        ),
      );
    }
  }

  void _pickAndViewPDF(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FilePdfViewer(file: file),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _searchController = TextEditingController();
    final collectionRepository = Provider.of<CollectionRepository>(context);
    final List<PdfCollection> recentCollections = collectionRepository.getAllCollections().take(3).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          "Hello",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _searchController,
                hintText: "search your bookmark",
                isSecuredField: false,
                prefixIcon: Icons.search_outlined,
              ),
              SizedBox(height: 20.h),

              // Recent Folders Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Folders",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to all collections screen
                    },
                    child: Text("See All >"),
                  )
                ],
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 120.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentCollections.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: RecentFolderItem(
                        collection: recentCollections[index],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),

              // Quick Access Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Quick Access",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CategoryItem(
                    icon: Icons.link,
                    label: "Links",
                    backgroundColor: Theme.of(context).cardColor,
                    iconColor: Color(0xFF9C27B0),
                    onTap: () => _showUrlInputDialog(context),
                  ),
                  SizedBox(width: 16),
                  CategoryItem(
                    icon: Icons.image,
                    label: "Images",
                    backgroundColor: Theme.of(context).canvasColor,
                    iconColor: Color(0xFF2196F3),
                    onTap: () {},
                  ),
                  SizedBox(width: 16),
                  CategoryItem(
                    icon: Icons.insert_drive_file,
                    label: "Documents",
                    backgroundColor: Theme.of(context).highlightColor,
                    iconColor: Color(0xFFE57373),
                    onTap: () => _pickAndViewPDF(context),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Recent Bookmarks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Bookmarks",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to all bookmarks screen
                    },
                    child: Text("See All >"),
                  )
                ],
              ),
              SizedBox(height: 12.h),
              FutureBuilder<List<CustomPdfBookmark>>(
                future: _recentBookmarksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error loading bookmarks');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No recent bookmarks');
                  } else {
                    return Column(
                      children: snapshot.data!.map((bookmark) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RecentBookmarkItem(
                            title: bookmark.name,
                            collection: bookmark.filePath.split('/').last,
                            date: _formatDate(bookmark.createdAt),
                            preview: bookmark.previewText ?? bookmark.notes ?? '',
                            onTap: () {
                              // Navigate to the PDF at the bookmarked page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FilePdfViewer(
                                    file: File(bookmark.filePath),
                                    initialPage: bookmark.pageNumber - 1,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}