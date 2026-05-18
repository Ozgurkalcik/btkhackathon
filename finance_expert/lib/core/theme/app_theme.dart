import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Finance Expert Tema Sistemi — Dark & Light Mode
class AppTheme {
  /// ─── DARK THEME ───
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(Brightness.dark),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.financialGreen,
        onPrimary: AppColors.trustBlue,
        primaryContainer: AppColors.financialGreenDark,
        secondary: AppColors.goldOrange,
        onSecondary: AppColors.trustBlue,
        secondaryContainer: AppColors.goldOrangeDark,
        error: AppColors.softRed,
        onError: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.textDarkPrimary,
        surfaceContainerHighest: AppColors.darkSurfaceHighest,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 4,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.financialGreen,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.financialGreen,
          foregroundColor: AppColors.trustBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.financialGreen, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textDarkSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.trustBlue
              : AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.financialGreen
              : AppColors.darkSurfaceHigh;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurfaceContainer,
        selectedItemColor: AppColors.financialGreen,
        unselectedItemColor: AppColors.textDarkSecondary,
      ),
      dividerColor: Colors.white10,
    );
  }

  /// ─── LIGHT THEME ───
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _buildTextTheme(Brightness.light),
      colorScheme: const ColorScheme.light(
        primary: AppColors.trustBlue,
        onPrimary: Colors.white,
        primaryContainer: AppColors.financialGreenLight,
        secondary: AppColors.goldOrange,
        onSecondary: AppColors.trustBlue,
        error: AppColors.softRed,
        onError: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.textLightPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 4,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.trustBlue,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.trustBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.trustBlue, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textLightSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerColor: Colors.black12,
    );
  }

  /// Tipografi
  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: color),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
        bodyLarge: TextStyle(fontSize: 16, color: color),
        bodyMedium: TextStyle(fontSize: 14, color: color),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
        bodySmall: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7)),
      ),
    );
  }
}
