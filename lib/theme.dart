import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0F4C81);
  static const Color primaryDark = Color(0xFF093056);
  static const Color accent = Color(0xFFE94E1B);
  static const Color coldWater = Color(0xFF2E9CCA);
  static const Color hotWater = Color(0xFFE63946);
  static const Color gas = Color(0xFFF4B400);
  static const Color waste = Color(0xFF6C757D);
  static const Color pipeMetal = Color(0xFFB8BEC7);
  static const Color copper = Color(0xFFB87333);
  static const Color brass = Color(0xFFB5A642);
  static const Color cardBg = Color(0xFFF5F8FC);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF1B2A36);
  static const Color muted = Color(0xFF5E6B78);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.cardBg,
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(fontSize: 15, color: AppColors.text, height: 1.45),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.text, height: 1.45),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.muted),
    ),
  );
}

// ─── Dark theme ────────────────────────────────────────────────────────

class DarkColors {
  static const Color background = Color(0xFF0F1419);
  static const Color surface = Color(0xFF1A1F26);
  static const Color card = Color(0xFF1F2630);
  static const Color border = Color(0xFF2A3341);
  static const Color text = Color(0xFFE6EAF0);
  static const Color muted = Color(0xFF8C95A1);
}

ThemeData buildDarkAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: DarkColors.surface,
  );
  return ThemeData(
    colorScheme: scheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: DarkColors.background,
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: DarkColors.surface,
      foregroundColor: DarkColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: DarkColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: DarkColors.text),
    ),
    cardTheme: CardThemeData(
      color: DarkColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: DarkColors.border, width: 0.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DarkColors.text,
        side: const BorderSide(color: DarkColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: DarkColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: DarkColors.border),
      ),
    ),
    dividerColor: DarkColors.border,
    dialogTheme: const DialogThemeData(
      backgroundColor: DarkColors.surface,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DarkColors.surface,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: DarkColors.surface,
      labelStyle: const TextStyle(color: DarkColors.text),
      side: const BorderSide(color: DarkColors.border),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: DarkColors.text,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: DarkColors.text,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: DarkColors.text,
      ),
      bodyLarge: TextStyle(fontSize: 15, color: DarkColors.text, height: 1.45),
      bodyMedium: TextStyle(fontSize: 14, color: DarkColors.text, height: 1.45),
      bodySmall: TextStyle(fontSize: 12, color: DarkColors.muted),
    ),
  );
}
