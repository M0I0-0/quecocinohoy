import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand
  static const Color orange = Color(0xFFD4611A);
  static const Color orangeLight = Color(0xFFE8842A);
  static const Color yellow = Color(0xFFE8942A);
  static const Color yellowLight = Color(0xFFF5C46A);

  // Backgrounds
  static const Color cream = Color(0xFFFAFAF8);
  static const Color creamDark = Color(0xFFF4EEE4);
  static const Color white = Color(0xFFFFFFFF);
  static const Color beige = Color(0xFFF4EEE4);
  static const Color beigeStrong = Color(0xFFEDE5D8);

  // Semantic
  static const Color green = Color(0xFF4A9068);
  static const Color greenLight = Color(0xFFE8F5EE);
  static const Color lavender = Color(0xFF8B7EC8);
  static const Color lavenderLight = Color(0xFFEEEBF8);

  // Text
  static const Color textDark = Color(0xFF1C1A17);
  static const Color textMedium = Color(0xFF6B6459);
  static const Color textLight = Color(0xFF9E9790);

  // Border
  static const Color border = Color(0xFFE5E0D9);

  // Gradients (kept for backward compat, now subtle)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeLight],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cream, cream],
  );
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        primary: AppColors.orange,
        secondary: AppColors.yellow,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSurface: AppColors.textDark,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.inter(color: AppColors.textLight, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 36, fontWeight: FontWeight.w700,
        color: AppColors.textDark, height: 1.15,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: AppColors.textDark, height: 1.2,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: AppColors.textDark, letterSpacing: -0.1,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: AppColors.textDark, height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: AppColors.textMedium, height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: AppColors.white, letterSpacing: 0.1,
      ),
    );
  }
}
