import 'package:flutter/material.dart';

/// Finance Expert — Renk Psikolojisi Tabanlı Renk Sistemi
///
/// • Güven Mavisi (#0A2540): Finansal güven ve istikrar
/// • Finansal Yeşil (#00D632): Pozitif gelişim ve kazanç
/// • Soft Kırmızı (#FF6B6B): Dikkat çekici ama stressiz uyarı
/// • Altın Turuncu (#FFB95F): Bilgilendirme ve öneri
abstract class AppColors {
  // ─── Ana Renkler (Primary Palette) ───
  static const Color trustBlue = Color(0xFF0A2540);
  static const Color financialGreen = Color(0xFF00D632);
  static const Color financialGreenLight = Color(0xFF4EDEA3);
  static const Color financialGreenDark = Color(0xFF10B981);

  // ─── İkincil Renkler (Secondary) ───
  static const Color goldOrange = Color(0xFFFFB95F);
  static const Color goldOrangeDark = Color(0xFFE29100);

  // ─── Uyarı Renkleri (Alert — Stressiz ama dikkat çekici) ───
  static const Color softRed = Color(0xFFFF6B6B);
  static const Color softRedLight = Color(0xFFFFB2B9);
  static const Color softRedDark = Color(0xFF891933);
  static const Color warningOrange = Color(0xFFFF9F43);

  // ─── Nötr Renkler (Neutral) ───
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // ─── Dark Mode Yüzey Renkleri ───
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF101827);
  static const Color darkSurfaceContainer = Color(0xFF1A2332);
  static const Color darkSurfaceHigh = Color(0xFF243044);
  static const Color darkSurfaceHighest = Color(0xFF2E3B52);

  // ─── Light Mode Yüzey Renkleri ───
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF1F5F9);

  // ─── Metin Renkleri ───
  static const Color textDarkPrimary = Color(0xFFE8EDF5);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
  static const Color textLightPrimary = Color(0xFF0A2540);
  static const Color textLightSecondary = Color(0xFF64748B);

  // ─── Kategori Renkleri (Harcama Kategorileri) ───
  static const Color categoryFood = Color(0xFFFF6B6B);
  static const Color categoryTransport = Color(0xFF4ECDC4);
  static const Color categoryShopping = Color(0xFFFFBE0B);
  static const Color categoryBills = Color(0xFF8B5CF6);
  static const Color categoryHealth = Color(0xFF06D6A0);
  static const Color categoryEntertainment = Color(0xFFFF9F43);
  static const Color categoryEducation = Color(0xFF3B82F6);
  static const Color categoryOther = Color(0xFF94A3B8);
}
