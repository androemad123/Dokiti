import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF5661FE),
  // Main theme color
  scaffoldBackgroundColor: Color(0xFFFFFFFF),
  // Background color
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFD2D6FE),
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  colorScheme: ColorScheme.light(
    primary: Color(0xFF5661FE),
    secondary: Color(0xFF151836),
    surface: Color(0xFFBCC1FE),
    onPrimary: Colors.grey[200]!,
    onSecondary: Colors.black,
    onSurface: Colors.white,
  ),

  cardColor: Color(0xFFF3E5F5),
  canvasColor: Color(0xFFE3F2FD),
  highlightColor: Color(0xFFFFEBEE),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF7C85FE),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    headlineMedium:
        TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF5460FE),
  // Main theme color
  scaffoldBackgroundColor: Color(0xFF151836),
  // Background color
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF313588),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF151836),
    secondary: Color(0xFF5460FE),
    surface: Color(0xFF1C88E1),
    primaryContainer: Colors.black12,
    onPrimary: Colors.grey[200]!,
    onSecondary: Colors.white,
    onSurface: Color(0xFF151836),
  ),
  cardColor: Color(0xFFD05CE3).withOpacity(0.3),
  canvasColor: Color(0xFF64B5F6).withOpacity(0.3),
  highlightColor: Color(0xFFFF6B6B).withOpacity(0.3),
    elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF707AFE),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    headlineMedium:
        TextStyle(color: Color(0xFFA4AAFE), fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Color(0xFFA4AAFE)),
  ),
);
