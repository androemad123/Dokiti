import 'package:flutter/material.dart';

import '../../../../core/models/book_mark_model.dart';
import '../../../../core/widgets/app_book_mark.dart';
import '../../../../core/widgets/app_text_field.dart';

class BookMarks extends StatelessWidget {
  const BookMarks({super.key});

  @override
  Widget build(BuildContext context) {
    final _searchController = TextEditingController();
    final List<BookmarkModel> todayBookmarks = [
      BookmarkModel(
        title: "Top UI/UX Design Works for Inspiration",
        source: "UI & UX Design Inspiration",
        category: "Inspiration",
        time: "12:21",
        imageUrl: "https://via.placeholder.com/150",
        icon: Icons.brush,
      ),
      BookmarkModel(
        title: "3 tips for research newbies",
        source: "Medium",
        category: "Unsorted",
        time: "11:10",
        imageUrl: "https://via.placeholder.com/150",
        icon: Icons.folder,
      ),
      BookmarkModel(
        title: "High quality wallpapers",
        source: "Reddit",
        category: "Unsorted",
        time: "07:32",
        imageUrl: "https://via.placeholder.com/150",
        icon: Icons.image,
      ),
    ];

    final List<BookmarkModel> yesterdayBookmarks = [
      BookmarkModel(
        title: "30 Times Cats Cracked Us Up",
        source: "Boredpanda",
        category: "Catboosters",
        time: "Yesterday",
        imageUrl: "https://via.placeholder.com/150",
        icon: Icons.pets,
      ),
      BookmarkModel(
        title: "Color Theory for Designers",
        source: "Smashing Magazine",
        category: "Brain Foods",
        time: "Yesterday",
        imageUrl: "https://via.placeholder.com/150",
        icon: Icons.palette,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Bookmarks"),backgroundColor: Colors.transparent,),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              controller: _searchController,
              hintText: "search your bookmark",
              isSecuredField: false,
              prefixIcon: Icons.search_outlined,
            ),
            _buildSection("Today", todayBookmarks),
            const SizedBox(height: 20),
            _buildSection("Yesterday", yesterdayBookmarks),
          ],
        ),
      ),
    );
  }
  Widget _buildSection(String title, List<BookmarkModel> bookmarks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Column(
          children: bookmarks.map((bookmark) => BookmarkCard(bookmark: bookmark)).toList(),
        ),
      ],
    );
  }
}
