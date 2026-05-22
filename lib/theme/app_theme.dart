import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// Finance Expert Premium Tema Sistemi — Material 3 & Çift Mod Desteği
class AppTheme {
  // ─── PREMIUM YUMUŞATILMIŞ RENK PALETİ (LOW-GLARE / GÖZ ALMAYAN TONLAR) ───
  // Aydınlık modda saf beyaz (#FFFFFF) yerine gözü yormayan premium kırık beyaz ve vizon tonları:
  static const Color softLightBg = Color(0xFFF2F4F7);         // Göz almayan yumuşak arka plan
  static const Color softLightSurface = Color(0xFFFAFBFD);    // Hafif kırık beyaz kart yüzeyi
  static const Color softLightContainer = Color(0xFFE6E9EE);  // Yumuşak gölgeli kaplar
  static const Color softLightBorder = Color(0xFFDFE3E8);     // İnce yumuşak kenarlıklar

  // Çift Mod Uyumlu Mint Green (Eski temadaki sevilen yeşil tonları):
  static const Color originalMintDark = Color(0xFF00C896);    // Karanlık mod için efsanevi orijinal mint yeşili
  static const Color originalMintLight = Color(0xFF008B69);   // Aydınlık modda mükemmel kontrast sunan mint yeşili

  /// ─── LIGHT MODE THEME ───
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: softLightBg,
      textTheme: _buildTextTheme(Brightness.light),
      
      // Material 3 standart renk şeması (Aydınlık Karşılıklar)
      colorScheme: const ColorScheme.light(
        primary: originalMintLight,                     // Aydınlık mod için kontrastı yüksek mint yeşili
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFE0F7F1),            // Çok hafif nane yeşili tonu
        onPrimaryContainer: originalMintLight,
        secondary: Color(0xFF007C8C),                   // Neon Cyan'ın okunabilir vizon tonu
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFE0F7FA),
        onSecondaryContainer: Color(0xFF004D40),
        tertiary: Color(0xFF5338B3),                    // Neon Mor'un okunabilir koyu tonu
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFEDE7F6),
        onTertiaryContainer: Color(0xFF311B92),
        error: AppColors.softRed,                       // Stressiz ama görünür kırmızı
        onError: Colors.white,
        surface: softLightSurface,                      // Göz yormayan vizon yüzey
        onSurface: AppColors.textLightPrimary,          // Koyu lacivert metin
        surfaceContainer: softLightContainer,           // Yumuşak kart arka planı
        onSurfaceVariant: AppColors.textLightSecondary,  // Slate 500 ikincil metin
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: softLightBg.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 4,
        iconTheme: const IconThemeData(color: originalMintLight),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: originalMintLight,
        ),
      ),

      cardTheme: CardThemeData(
        color: softLightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: softLightBorder, width: 1.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: originalMintLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softLightContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: softLightBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: originalMintLight, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textLightSecondary),
        hintStyle: GoogleFonts.inter(color: AppColors.textLightSecondary.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      dividerColor: softLightBorder,
    );
  }

  /// ─── DARK MODE THEME ───
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(Brightness.dark),

      // Material 3 standart renk şeması (Karanlık Karşılıklar)
      colorScheme: const ColorScheme.dark(
        primary: originalMintDark,                      // Eski temadaki efsanevi orijinal mint yeşili
        onPrimary: AppColors.trustBlue,
        primaryContainer: AppColors.financialGreenDark,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.goldOrange,                // Bilgilendirme Turuncusu
        onSecondary: AppColors.trustBlue,
        secondaryContainer: AppColors.goldOrangeDark,
        onSecondaryContainer: Colors.white,
        tertiary: Color(0xFF7C5CFF),                    // Neon Mor
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF5338B3),
        onTertiaryContainer: Colors.white,
        error: AppColors.softRed,
        onError: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.textDarkPrimary,           // Açık gri metin
        surfaceContainer: AppColors.darkSurfaceContainer,
        onSurfaceVariant: AppColors.textDarkSecondary,  // Slate 400 ikincil metin
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 4,
        iconTheme: const IconThemeData(color: originalMintDark),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: originalMintDark,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: originalMintDark,
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: originalMintDark, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textDarkSecondary),
        hintStyle: GoogleFonts.inter(color: AppColors.textDarkSecondary.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      dividerColor: Colors.white10,
    );
  }

  /// Tipografi Yardımcısı
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
        bodySmall: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
      ),
    );
  }
}
