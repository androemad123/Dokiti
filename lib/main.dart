
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart' as provider;
import 'core/models/collection_model.dart';
import 'core/repositories/collection_repository.dart';
import 'core/routing/app_router.dart';
import 'package:alhy_momken_task/dokiti.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theming/theme_provider.dart';
import 'features/home/ui/data/book_mark_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ScreenUtil.ensureScreenSize();
  await Hive.initFlutter();
  Hive.registerAdapter(PdfCollectionAdapter());
  final bookmarkRepository = BookmarkRepository();

  final collectionRepository = CollectionRepository();
  await collectionRepository.init();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool showHome = prefs.getBool("showHome") ?? false;

  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
          provider.Provider<CollectionRepository>(create: (_) => collectionRepository),
          provider.Provider<BookmarkRepository>.value(value: bookmarkRepository),
        ],
        child: Dokiti(appRouter: AppRouter(showHome: showHome)),
      ),
    ),
  );
}