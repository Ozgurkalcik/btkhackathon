import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'gemini_service.dart';

/// Zenginleştirilmiş Finansal Analiz Pipeline Servisi
/// Bu servis 5 aşamalı (Ingestion, LLM Parsing, OSINT RPA, Time Deduction, Dashboard Prep) veri işlem hattını yönetir.
class EnrichedPipelineService {
  final GeminiService _geminiService = GeminiService();
  final _RpaOsintBot _osintBot = _RpaOsintBot();

  /// Ana Pipeline Metodu: Ham veriyi alır ve zenginleştirilmiş Transaction nesnesi döndürür.
  /// [previousTransactions] kullanıcının zaman/mekan çıkarımı için daha önce yaptığı işlemleri içerir.
  Future<Transaction> processRawTransaction(
    String rawDescription,
    double amount,
    DateTime date,
    TransactionType type,
    List<Transaction> previousTransactions,
  ) async {
    // Aşama 1: Veri Kabul ve Temizleme (Normalization)
    final cleanedText = _normalizeText(rawDescription);

    // Aşama 2: Gemini API ile Akıllı Ayrıştırma (LLM Parsing)
    final parsedData = await _geminiService.parseTransactionToJSON(cleanedText);
    final companyName = parsedData['Sirket_Adi'] as String? ?? 'Bilinmeyen Şirket';
    final city = parsedData['Sehir'] as String? ?? 'Bilinmeyen Şehir';

    // Aşama 3: OSINT & Resmi Kayıt RPA Botu (Mock)
    final osintResult = await _osintBot.scrapeCompanyData(companyName);

    // Aşama 4: Konumsal ve Zamansal Çıkarım (Time-Clustering & Deduction)
    // Önceki alışverişleri listele
    final recentMerchants = previousTransactions
        .where((t) => t.date.isAfter(date.subtract(const Duration(hours: 3))))
        .map((t) => t.resolvedMerchant ?? '')
        .where((m) => m.isNotEmpty)
        .toList();

    final locationContext = await _geminiService.deduceLocationContext(recentMerchants, companyName);
    
    // Exact location ve district öncelikle OSINT'ten değilse LLM bağlamından alınsın
    String exactLocation = osintResult['address'] as String;
    String district = "";
    if (locationContext['exactLocation'] != 'Bilinmiyor') {
      exactLocation = locationContext['exactLocation'] as String;
      district = locationContext['district'] as String;
    }

    // Aşama 5: Sınıflandırma ve Dashboard Veri Hazırlığı
    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: osintResult['fullName'] as String? ?? companyName,
      category: parsedData['Olası_Sektor'] as String? ?? 'Diğer',
      amount: amount,
      date: date,
      bankSource: 'Otomatik Pipeline',
      rawDescription: rawDescription,
      resolvedMerchant: companyName,
      type: type,
      icon: _getIconForCategory(parsedData['Olası_Sektor'] as String?),
      enrichedCity: city,
      enrichedDistrict: district.isNotEmpty ? district : null,
      naceCode: osintResult['naceCode'] as String?,
      exactLocation: exactLocation,
      fullCompanyName: osintResult['fullName'] as String?,
    );
  }

  /// POS numaralarını (örn. K107, V836) ve gereksiz boşlukları regex ile temizler.
  String _normalizeText(String raw) {
    // [A-Z][0-9]{3} kalıplarını bulur (K107, V836 gibi pos kodları)
    final posRegex = RegExp(r'\b[A-Z][0-9]{3}\b');
    // Fazla boşlukları temizler
    final spaceRegex = RegExp(r'\s{2,}');
    
    var cleaned = raw.replaceAll(posRegex, '');
    cleaned = cleaned.replaceAll(spaceRegex, ' ').trim();
    return cleaned;
  }

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'Gıda/Market':
        return Icons.shopping_basket;
      case 'Kozmetik':
        return Icons.face_retouching_natural;
      case 'Giyim':
        return Icons.checkroom;
      case 'Yemek':
        return Icons.restaurant;
      default:
        return Icons.receipt_long;
    }
  }
}

/// Aşama 3: MERSİS/Ticaret Sicil Kazıma simülatörü (IP ban yememek için Mock)
class _RpaOsintBot {
  Future<Map<String, dynamic>> scrapeCompanyData(String companyName) async {
    // Gerçekçi bir ağ gecikmesi
    await Future.delayed(const Duration(milliseconds: 1800));

    // Sabit mock veritabanı
    if (companyName.contains("NIKBEY")) {
      return {
        "fullName": "NİKBEY GIDA HAYVANCILIK TİCARET SANAYİ LİMİTED ŞİRKETİ",
        "naceCode": "47.11.01 (Bakkal ve Marketler)",
        "address": "İnönü Cad. Malatya Park AVM No:178",
      };
    } else if (companyName.contains("GRATIS")) {
      return {
        "fullName": "GRATİS İÇ VE DIŞ TİCARET ANONİM ŞİRKETİ",
        "naceCode": "47.75.01 (Kozmetik ve Kişisel Bakım)",
        "address": "İnönü Cad. Malatya Park AVM",
      };
    }

    return {
      "fullName": "$companyName A.Ş.",
      "naceCode": "Bilinmiyor",
      "address": "Bilinmiyor",
    };
  }
}
