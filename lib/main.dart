import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'package:alhy_momken_task/dokiti.dart';

import 'core/theming/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure screen size is initialized
  await ScreenUtil.ensureScreenSize();

  // Load SharedPreferences and get showHome flag
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool showHome = prefs.getBool("showHome") ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // Provide ThemeProvider
      ],
      child: Dokiti(appRouter: AppRouter(showHome: showHome)),
    ),
  );
}
