/// Ham Banka İşlem Metni Temizleme Motoru
///
/// Banka API'lerinden gelen ham açıklama metinlerini
/// (ör: "ZRT*MCDONALDSANKARA", "HPS*MNG_TRNS_9921")
/// yapılandırılmış verilere dönüştürür.
///
/// Pipeline:
///   Ham Metin → Banka Kodu Çıkarma → Tüccar Adı Temizleme
///             → Şehir Tespiti → Normalize Edilmiş Çıktı
class TransactionTextCleaner {
  /// Ham banka metnini temizle ve yapılandırılmış veriye dönüştür
  static CleanedTransaction clean(String rawText) {
    final text = rawText.trim().toUpperCase();

    // 1. Banka kodunu tespit et
    final bankCode = _extractBankCode(text);

    // 2. Banka kodunu kaldır ve kalan metni al
    String remaining = _removeBankPrefix(text);

    // 3. Şehri tespit et ve kaldır
    final city = _extractCity(remaining);
    if (city != null) {
      remaining = remaining.replaceAll(city.toUpperCase(), '').trim();
    }

    // 4. Tüccar adını temizle
    final merchantName = _cleanMerchantName(remaining);

    // 5. Bilinen tüccar eşlemesi
    final knownMerchant = _matchKnownMerchant(merchantName);

    return CleanedTransaction(
      rawText: rawText,
      bankCode: bankCode,
      merchantRaw: remaining,
      merchantCleaned: knownMerchant ?? merchantName,
      city: city,
      isResolved: knownMerchant != null,
    );
  }

  /// Banka kodu ön-ekini tespit et
  static String? _extractBankCode(String text) {
    for (final entry in _bankPrefixes.entries) {
      for (final prefix in entry.value) {
        if (text.startsWith(prefix)) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// Banka ön-ekini kaldır
  static String _removeBankPrefix(String text) {
    for (final prefixes in _bankPrefixes.values) {
      for (final prefix in prefixes) {
        if (text.startsWith(prefix)) {
          return text.substring(prefix.length).trim();
        }
      }
    }
    // Genel separatör temizliği
    return text.replaceAll(RegExp(r'^[A-Z]{2,4}[\*\-\/]'), '').trim();
  }

  /// Şehir ismini tespit et
  static String? _extractCity(String text) {
    for (final city in _turkishCities) {
      if (text.toUpperCase().contains(city.toUpperCase())) {
        return city;
      }
    }
    return null;
  }

  /// Tüccar adını temizle
  static String _cleanMerchantName(String text) {
    String cleaned = text
        .replaceAll(RegExp(r'[_\-\*\/\\]'), ' ') // Özel karakterleri boşluğa çevir
        .replaceAll(RegExp(r'\d{4,}'), '')         // 4+ haneli sayıları kaldır
        .replaceAll(RegExp(r'\s+'), ' ')           // Çoklu boşlukları teke indir
        .trim();

    // İlk harfleri büyük yap
    if (cleaned.isNotEmpty) {
      cleaned = cleaned.split(' ').map((word) {
        if (word.isEmpty) return '';
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    return cleaned;
  }

  /// Bilinen tüccar veritabanından eşleştir
  static String? _matchKnownMerchant(String cleanedName) {
    final normalized = cleanedName.toUpperCase().replaceAll(' ', '');
    for (final entry in _knownMerchants.entries) {
      for (final pattern in entry.value) {
        if (normalized.contains(pattern.toUpperCase())) {
          return entry.key;
        }
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════
  //  VERİ TABLOLARI
  // ═══════════════════════════════════════════════

  /// Banka ön-ek kodları
  static const Map<String, List<String>> _bankPrefixes = {
    'Ziraat': ['ZRT*', 'ZRT-', 'ZIRAAT*', 'ZB*'],
    'VakıfBank': ['VKF*', 'VAKIF*', 'VB*'],
    'Garanti': ['GRN*', 'GARANTI*', 'GBBVA*'],
    'İş Bankası': ['ISB*', 'ISBANK*', 'IB*'],
    'Akbank': ['AKB*', 'AKBANK*'],
    'Yapı Kredi': ['YKB*', 'YAPIKREDI*', 'YK*'],
    'Halkbank': ['HLK*', 'HALKB*'],
    'DenizBank': ['DNZ*', 'DENIZ*'],
    'QNB': ['QNB*', 'FINANS*'],
    'Hepsiburada': ['HPS*'],
    'Trendyol': ['TRY*', 'TRENDYOL*'],
  };

  /// Bilinen tüccar eşlemeleri (pattern → görünen ad)
  static const Map<String, List<String>> _knownMerchants = {
    "McDonald's": ['MCDONALDS', 'MCDONALD', 'MCD'],
    'Burger King': ['BURGERKING', 'BK'],
    'Starbucks': ['STARBUCKS', 'STRBCKS', 'SBUX'],
    'Migros': ['MIGROS', 'MGS'],
    'BİM': ['BIM', 'BIMAS'],
    'A101': ['A101'],
    'ŞOK': ['SOK', 'SOKMARKET'],
    'CarrefourSA': ['CARREFOUR', 'CARREFOURSA'],
    'LC Waikiki': ['LCWAIKIKI', 'LCW'],
    'Koton': ['KOTON'],
    'Zara': ['ZARA'],
    'H&M': ['HM', 'H&M', 'HANDM'],
    'Watsons': ['WATSONS'],
    'Gratis': ['GRATIS'],
    'Hepsiburada': ['HEPSIBURADA', 'HPSBURADA'],
    'Trendyol': ['TRENDYOL', 'TRNDYL'],
    'Amazon': ['AMAZON', 'AMZN'],
    'Netflix': ['NETFLIX', 'NFLX'],
    'Spotify': ['SPOTIFY'],
    'YouTube': ['YOUTUBE', 'GOOGLEYOUTUBE'],
    'Apple': ['APPLE', 'ITUNES'],
    'Google': ['GOOGLE', 'GOOGLEPLAY'],
    'Shell': ['SHELL'],
    'BP': ['BP', 'BPPETROL'],
    'Opet': ['OPET'],
    'Petrol Ofisi': ['PETROLOFISI', 'PO'],
    'THY': ['TURKISHAIRLINES', 'THY', 'THYAO'],
    'Pegasus': ['PEGASUS', 'PGSUS'],
    'Uber': ['UBER'],
    'BiTaksi': ['BITAKSI'],
    'Getir': ['GETIR'],
    'Yemeksepeti': ['YEMEKSEPETI', 'YEMEK SEPETI'],
    'Trendyol Yemek': ['TRENDYOLYEMEK'],
    'Dominos': ['DOMINOS', 'DOMINOSPIZZA'],
    'Pizza Hut': ['PIZZAHUT'],
    'KFC': ['KFC'],
    'Popeyes': ['POPEYES'],
    'D&R': ['DR', 'D&R', 'DRVEKITAP'],
    'MediaMarkt': ['MEDIAMARKT'],
    'Teknosa': ['TEKNOSA'],
    'Turkcell': ['TURKCELL'],
    'Vodafone': ['VODAFONE'],
    'Türk Telekom': ['TURKTELEKOM', 'TTNET'],
  };

  /// Türk illeri listesi
  static const List<String> _turkishCities = [
    'ISTANBUL', 'ANKARA', 'IZMIR', 'BURSA', 'ANTALYA', 'ADANA',
    'KONYA', 'GAZIANTEP', 'MERSIN', 'DIYARBAKIR', 'KAYSERI',
    'ESKISEHIR', 'SAMSUN', 'DENIZLI', 'SANLIURFA', 'MALATYA',
    'TRABZON', 'ERZURUM', 'KAHRAMANMARAS', 'VAN', 'ELAZIG',
    'MANISA', 'BALIKESIR', 'AYDIN', 'TEKIRDAG', 'MUGLA',
    'SAKARYA', 'KOCAELI', 'HATAY', 'MARDIN', 'ORDU',
    'AFYON', 'SIVAS', 'TOKAT', 'USAK', 'EDIRNE',
    'BOLU', 'ISPARTA', 'GIRESUN', 'RIZE', 'AKSARAY',
    'YALOVA', 'DUZCE', 'KARABUK', 'KIRIKKALE', 'OSMANIYE',
    'BESIKTAS', 'KADIKOY', 'BAKIRKOY', 'SISLI', 'USKUDAR',
    'BEYOGLU', 'FATIH', 'MALTEPE', 'KARTAL', 'PENDIK',
    'UMRANIYE', 'ESENYURT', 'AVCILAR', 'BAGCILAR', 'BAYRAMPASA',
    'CANKAYA', 'KECIOREN', 'MAMAK', 'ETIMESGUT', 'SINCAN',
    'BORNOVA', 'KARSIYAKA', 'BUCA', 'KONAK',
  ];
}

/// Temizlenmiş işlem verisi
class CleanedTransaction {
  final String rawText;
  final String? bankCode;
  final String merchantRaw;
  final String merchantCleaned;
  final String? city;
  final bool isResolved;

  const CleanedTransaction({
    required this.rawText,
    this.bankCode,
    required this.merchantRaw,
    required this.merchantCleaned,
    this.city,
    required this.isResolved,
  });

  @override
  String toString() =>
      'CleanedTransaction(bank: $bankCode, merchant: $merchantCleaned, city: $city, resolved: $isResolved)';
}
