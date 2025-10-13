import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF008B8B);
  static const Color accentCoral = Color(0xFFE55A52);
  static const Color backgroundWhite = Colors.white;
  static const Color secondaryGray = Colors.grey;

  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryTeal,
      onPrimary: Colors.white,
      secondary: accentCoral,
      onSecondary: Colors.white,
      surface: backgroundWhite,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundWhite,
    useMaterial3: true,
    fontFamily: 'Roboto',
  );
}
