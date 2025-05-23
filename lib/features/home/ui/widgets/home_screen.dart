import 'dart:io';

import 'package:alhy_momken_task/core/theming/styles.dart';
import 'package:alhy_momken_task/core/widgets/app_text_field.dart';
import 'package:alhy_momken_task/features/home/ui/widgets/category_item.dart';
import 'package:alhy_momken_task/features/home/ui/widgets/collection_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theming/theme_provider.dart';
import '../../../../core/widgets/app_text_btn.dart';
import '../data/document_viewer.dart';
import '../data/local_pdf_viewer.dart';
import 'document_alert_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    final List<Map<String, dynamic>> collections = [
      {'title': 'Inspiration', 'items': 32, 'icon': Icons.emoji_emotions},
      {'title': 'Catboosters', 'items': 163, 'icon': Icons.pets},
      {'title': 'Brain Foods', 'items': 26, 'icon': Icons.restaurant},
      {'title': 'Brain Foods', 'items': 26, 'icon': Icons.restaurant},
      {'title': 'Brain Foods', 'items': 26, 'icon': Icons.restaurant},
    ];
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
              AppTextBtn(
                backGroundColor: Theme.of(context).colorScheme.secondary,
                buttonHeight: 56.h,
                buttonWidth: 300.w,
                buttonText: "Switch",
                textStyle: MyTextStyle.font16SemiBold(context),
                onPressed: () {
                  final themeProvider =
                      Provider.of<ThemeProvider>(context, listen: false);
                  themeProvider
                      .toggleTheme(themeProvider.themeMode != ThemeMode.dark);
                },
                borderRadius: 10,
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My collections",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text("See All >"),
                  )
                ],
              ),
              SizedBox(
                height: 12.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CategoryItem(
                    icon: Icons.link,
                    label: "Links",
                    backgroundColor: Theme.of(context).cardColor,
                    iconColor: Color(0xFF9C27B0),
                    onTap:  () => _showUrlInputDialog(context),
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
                    onTap: () =>_pickAndViewPDF(context),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              SizedBox(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      collections.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        // Space between items
                        child: CollectionCard(collection: collections[index]),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                "Recent bookmark",
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
