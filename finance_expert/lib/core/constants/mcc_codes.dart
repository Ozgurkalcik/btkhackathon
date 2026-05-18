/// MCC (Merchant Category Code) → Türkçe Kategori Eşleme Tablosu
///
/// ISO 18245 standardına göre MCC kodları ve
/// Türk tüketici harcamalarına uygun kategorizasyon.
class MccCodes {
  static const Map<String, SpendingCategory> mccToCategory = {
    // ─── MARKET & GIDA ───
    '5411': SpendingCategory('Market', 'market', MccSector.food),
    '5422': SpendingCategory('Kasap / Et Ürünleri', 'market', MccSector.food),
    '5441': SpendingCategory('Şekerleme / Bakkal', 'market', MccSector.food),
    '5451': SpendingCategory('Süt Ürünleri', 'market', MccSector.food),
    '5462': SpendingCategory('Fırın / Pastane', 'market', MccSector.food),
    '5499': SpendingCategory('Gıda Mağazası', 'market', MccSector.food),

    // ─── RESTORAN & YEMEK ───
    '5812': SpendingCategory('Restoran', 'yemek', MccSector.dining),
    '5813': SpendingCategory('Bar / Kafe', 'yemek', MccSector.dining),
    '5814': SpendingCategory('Fast Food', 'yemek', MccSector.dining),

    // ─── GİYİM ───
    '5611': SpendingCategory('Erkek Giyim', 'giyim', MccSector.clothing),
    '5621': SpendingCategory('Kadın Giyim', 'giyim', MccSector.clothing),
    '5631': SpendingCategory('Kadın Aksesuar', 'giyim', MccSector.clothing),
    '5641': SpendingCategory('Çocuk Giyim', 'giyim', MccSector.clothing),
    '5651': SpendingCategory('Spor Giyim', 'giyim', MccSector.clothing),
    '5661': SpendingCategory('Ayakkabı', 'giyim', MccSector.clothing),
    '5699': SpendingCategory('Giyim Mağazası', 'giyim', MccSector.clothing),

    // ─── KOZMETİK & KİŞİSEL BAKIM ───
    '5977': SpendingCategory('Kozmetik', 'kozmetik', MccSector.cosmetics),
    '7230': SpendingCategory('Kuaför / Güzellik', 'kozmetik', MccSector.cosmetics),
    '7297': SpendingCategory('Masaj / SPA', 'kozmetik', MccSector.cosmetics),

    // ─── ULAŞIM ───
    '4111': SpendingCategory('Toplu Taşıma', 'ulaşım', MccSector.transport),
    '4121': SpendingCategory('Taksi', 'ulaşım', MccSector.transport),
    '4131': SpendingCategory('Otobüs', 'ulaşım', MccSector.transport),
    '5541': SpendingCategory('Benzin İstasyonu', 'ulaşım', MccSector.transport),
    '5542': SpendingCategory('Akaryakıt', 'ulaşım', MccSector.transport),
    '7512': SpendingCategory('Araç Kiralama', 'ulaşım', MccSector.transport),

    // ─── SAĞLIK ───
    '5912': SpendingCategory('Eczane', 'sağlık', MccSector.health),
    '8011': SpendingCategory('Doktor', 'sağlık', MccSector.health),
    '8021': SpendingCategory('Diş Hekimi', 'sağlık', MccSector.health),
    '8042': SpendingCategory('Optik', 'sağlık', MccSector.health),
    '8062': SpendingCategory('Hastane', 'sağlık', MccSector.health),
    '8099': SpendingCategory('Sağlık Hizmeti', 'sağlık', MccSector.health),

    // ─── EĞİTİM ───
    '8211': SpendingCategory('Okul / Üniversite', 'eğitim', MccSector.education),
    '8220': SpendingCategory('Kolej / Kurs', 'eğitim', MccSector.education),
    '8299': SpendingCategory('Eğitim Hizmeti', 'eğitim', MccSector.education),
    '5942': SpendingCategory('Kitapçı', 'eğitim', MccSector.education),

    // ─── EĞLENce ───
    '7832': SpendingCategory('Sinema', 'eğlence', MccSector.entertainment),
    '7922': SpendingCategory('Tiyatro / Konser', 'eğlence', MccSector.entertainment),
    '7941': SpendingCategory('Spor Etkinliği', 'eğlence', MccSector.entertainment),
    '7993': SpendingCategory('Oyun Salonu', 'eğlence', MccSector.entertainment),
    '7994': SpendingCategory('Video Oyunları', 'eğlence', MccSector.entertainment),
    '7995': SpendingCategory('Bahis / Kumar', 'eğlence', MccSector.entertainment),

    // ─── TEKNOLOJİ & ELEKTRONİK ───
    '5045': SpendingCategory('Bilgisayar', 'teknoloji', MccSector.technology),
    '5732': SpendingCategory('Elektronik Mağaza', 'teknoloji', MccSector.technology),
    '5734': SpendingCategory('Yazılım', 'teknoloji', MccSector.technology),
    '5946': SpendingCategory('Fotoğraf Mağazası', 'teknoloji', MccSector.technology),

    // ─── EV & MOBİLYA ───
    '5200': SpendingCategory('Yapı Market', 'ev', MccSector.home),
    '5211': SpendingCategory('İnşaat Malz.', 'ev', MccSector.home),
    '5712': SpendingCategory('Mobilya', 'ev', MccSector.home),
    '5722': SpendingCategory('Beyaz Eşya', 'ev', MccSector.home),

    // ─── FATURALAR ───
    '4814': SpendingCategory('Telekom', 'fatura', MccSector.bills),
    '4899': SpendingCategory('Kablo / İnternet', 'fatura', MccSector.bills),
    '4900': SpendingCategory('Elektrik / Su / Doğalgaz', 'fatura', MccSector.bills),

    // ─── E-TİCARET ───
    '5964': SpendingCategory('Katalog Alışveriş', 'e-ticaret', MccSector.ecommerce),
    '5965': SpendingCategory('Online Alışveriş', 'e-ticaret', MccSector.ecommerce),
    '5966': SpendingCategory('Telefonla Sipariş', 'e-ticaret', MccSector.ecommerce),

    // ─── SİGORTA & FİNANS ───
    '6300': SpendingCategory('Sigorta', 'finans', MccSector.finance),
    '6012': SpendingCategory('Banka Hizmeti', 'finans', MccSector.finance),
    '6211': SpendingCategory('Yatırım', 'finans', MccSector.finance),
  };

  /// MCC kodundan kategori bul, bulunamazsa 'Diğer' döndür
  static SpendingCategory fromMcc(String mccCode) {
    return mccToCategory[mccCode] ??
        const SpendingCategory('Diğer', 'diğer', MccSector.other);
  }
}

/// Harcama kategorisi veri modeli
class SpendingCategory {
  final String displayName;
  final String key;
  final MccSector sector;

  const SpendingCategory(this.displayName, this.key, this.sector);
}

/// Sektör sınıflandırması
enum MccSector {
  food,
  dining,
  clothing,
  cosmetics,
  transport,
  health,
  education,
  entertainment,
  technology,
  home,
  bills,
  ecommerce,
  finance,
  other,
}
