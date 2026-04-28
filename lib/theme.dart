import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF00F0FF); // Neon Cyan
  static const Color secondary = Color(0xFF7000FF); // Electric Purple
  static const Color background = Color(0xFF0A0A0A); // Deep Black
  static const Color surface = Color(0xFF1A1A1A); // Dark Grey
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color error = Color(0xFFFF0055);
  static const Color success = Color(0xFF00FF88);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onPrimary: Colors.black,
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      titleLarge: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10, width: 1),
      ),
      elevation: 0,
    ),
  );
}
