import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF3498DB);
  // static const Color primary = Color(0xFF3498DB);
  static const Color secondary = Color(0xFF2ECC71);
  static const Color accent = Color(0xFF667EEA);
  static const Color gradEnd = Color(0xFF764BA2);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textMuted = Color(0xFF7F8C8D);
  static const Color danger = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color success = Color(0xFF27AE60);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accent, gradEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration get card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static ThemeData theme({bool arabic = false}) {
    final textTheme =
        arabic ? GoogleFonts.tajawalTextTheme() : GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        background: bgLight,
      ),
      scaffoldBackgroundColor: bgLight,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge
            ?.copyWith(fontWeight: FontWeight.w800, color: textDark),
        headlineMedium: textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.w700, color: textDark),
        titleLarge: textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w600, color: textDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: arabic ? 'Tajawal' : 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: textMuted),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        ),
      ),
    );
  }
}
