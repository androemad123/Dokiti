import 'package:flutter/material.dart';
import '../models/book_mark_model.dart';

class BookmarkCard extends StatelessWidget {
  final BookmarkModel bookmark;

  const BookmarkCard({Key? key, required this.bookmark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.onSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.transparent, width: 1.5,), // ✅ Added border color
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8), // ✅ Reduced space
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(1), // ✅ Square with rounded corners
            child: Image.network(
              bookmark.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) => Image.asset("assets/images/imagenotfound.png")
            )
        ),
        title: Text(
          bookmark.title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Icon(bookmark.icon, size: 16, color: Colors.blue),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  bookmark.source,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 5),
              Text(bookmark.time, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }
}
