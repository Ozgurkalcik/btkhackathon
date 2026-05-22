/// Banka API yapılandırma bilgileri
///
/// API key'lerinizi aldığınızda ilgili bankanın [apiKey] alanını doldurun.
/// Endpoint URL'leri bankaların resmi API dokümanlarından alınmalıdır.
class BankApiConfig {
  final String id;
  final String name;
  final String shortName;
  final String baseUrl;
  final String apiKey;
  final String? clientId;
  final String? clientSecret;
  final bool isEnabled;

  const BankApiConfig({
    required this.id,
    required this.name,
    required this.shortName,
    required this.baseUrl,
    this.apiKey = '', // GÜVENLİK: API key'ler buraya YAZILMAMALI — SecureStorage üzerinden yönetilecek
    this.clientId,
    this.clientSecret,
    this.isEnabled = false,
  });

  /// API anahtarı tanımlanmış mı?
  bool get hasApiKey => apiKey.isNotEmpty;

  /// Client credentials tanımlanmış mı?
  bool get hasCredentials =>
      clientId != null &&
      clientId!.isNotEmpty &&
      clientSecret != null &&
      clientSecret!.isNotEmpty;

  /// Bu banka kullanılabilir mi?
  bool get isReady => isEnabled && (hasApiKey || hasCredentials);
}

/// Tüm desteklenen bankaların yapılandırma listesi
///
/// ╔══════════════════════════════════════════════════════════════════╗
/// ║  API KEY'LERİNİZİ BURAYA EKLEYİN                              ║
/// ║                                                                ║
/// ║  Her bankanın apiKey, clientId ve clientSecret alanlarını       ║
/// ║  ilgili bankanın geliştirici portalından aldığınız bilgilerle   ║
/// ║  doldurun. isEnabled: true yaparak bankayı aktif edin.         ║
/// ╚══════════════════════════════════════════════════════════════════╝
class BankRegistry {
  static const List<BankApiConfig> banks = [
    // ─────────── KAMU BANKALARI ───────────
    BankApiConfig(
      id: 'ziraat',
      name: 'T.C. Ziraat Bankası',
      shortName: 'Ziraat',
      baseUrl: '', // TODO: Ziraat API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'vakifbank',
      name: 'Türkiye Vakıflar Bankası',
      shortName: 'VakıfBank',
      baseUrl: '', // TODO: VakıfBank API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'halkbank',
      name: 'Türkiye Halk Bankası',
      shortName: 'Halkbank',
      baseUrl: '', // TODO: Halkbank API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),

    // ─────────── ÖZEL BANKALAR ───────────
    BankApiConfig(
      id: 'garanti',
      name: 'Garanti BBVA',
      shortName: 'Garanti',
      baseUrl: '', // TODO: Garanti API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      clientId: '',     // TODO: Client ID eklenecek
      clientSecret: '', // TODO: Client Secret eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'isbank',
      name: 'Türkiye İş Bankası',
      shortName: 'İş Bankası',
      baseUrl: '', // TODO: İş Bankası API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'akbank',
      name: 'Akbank',
      shortName: 'Akbank',
      baseUrl: '', // TODO: Akbank API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'yapikredi',
      name: 'Yapı ve Kredi Bankası',
      shortName: 'Yapı Kredi',
      baseUrl: '', // TODO: Yapı Kredi API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'denizbank',
      name: 'DenizBank',
      shortName: 'DenizBank',
      baseUrl: '', // TODO: DenizBank API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'qnb',
      name: 'QNB Finansbank',
      shortName: 'QNB',
      baseUrl: '', // TODO: QNB Finansbank API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'enpara',
      name: 'Enpara.com',
      shortName: 'Enpara',
      baseUrl: '', // TODO: Enpara API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'teb',
      name: 'Türk Ekonomi Bankası',
      shortName: 'TEB',
      baseUrl: '', // TODO: TEB API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'ing',
      name: 'ING Bank',
      shortName: 'ING',
      baseUrl: '', // TODO: ING API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),

    // ─────────── KATILIM BANKALARI ───────────
    BankApiConfig(
      id: 'kuveytturk',
      name: 'Kuveyt Türk',
      shortName: 'Kuveyt Türk',
      baseUrl: '', // TODO: Kuveyt Türk API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
    BankApiConfig(
      id: 'albaraka',
      name: 'Albaraka Türk',
      shortName: 'Albaraka',
      baseUrl: '', // TODO: Albaraka API endpoint'i eklenecek
      apiKey: '',  // TODO: API key eklenecek
      isEnabled: false,
    ),
  ];

  /// ID ile banka config bul
  static BankApiConfig? getBank(String bankId) {
    try {
      return banks.firstWhere((b) => b.id == bankId);
    } catch (_) {
      return null;
    }
  }

  /// Aktif (kullanıma hazır) bankaları getir
  static List<BankApiConfig> get activeBanks =>
      banks.where((b) => b.isReady).toList();

  /// Tüm etkin bankaları getir
  static List<BankApiConfig> get enabledBanks =>
      banks.where((b) => b.isEnabled).toList();
}
