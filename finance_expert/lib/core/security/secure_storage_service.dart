import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Güvenli Anahtar Deposu Servisi
///
/// API anahtarları, token'lar ve hassas bilgilerin Android Keystore /
/// iOS Keychain üzerinde şifreli saklanmasını sağlar.
/// ASLA bellekte veya düz dosyada saklanmaz.
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // ─── Anahtar Sabitleri ───
  static const _keyGeminiApiKey = 'gemini_api_key';
  static const _keyBankApiPrefix = 'bank_api_';
  static const _keyBankClientId = 'bank_client_id_';
  static const _keyBankClientSecret = 'bank_client_secret_';
  static const _keyHiveEncryptionKey = 'hive_encryption_key';
  static const _keyUserPin = 'user_pin_hash';
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keyThemeMode = 'theme_mode';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyAiInsightsEnabled = 'ai_insights_enabled';

  // ═══════════════════════════════════════════════
  //  GEMİNİ API KEY
  // ═══════════════════════════════════════════════

  /// Gemini API anahtarını güvenli depoya kaydet
  static Future<void> setGeminiApiKey(String apiKey) async {
    await _storage.write(key: _keyGeminiApiKey, value: apiKey);
  }

  /// Gemini API anahtarını oku
  static Future<String?> getGeminiApiKey() async {
    return _storage.read(key: _keyGeminiApiKey);
  }

  /// Gemini API anahtarı kayıtlı mı?
  static Future<bool> hasGeminiApiKey() async {
    final key = await _storage.read(key: _keyGeminiApiKey);
    return key != null && key.isNotEmpty;
  }

  // ═══════════════════════════════════════════════
  //  BANKA API KEY'LERİ
  // ═══════════════════════════════════════════════

  /// Banka API anahtarını kaydet
  static Future<void> setBankApiKey(String bankId, String apiKey) async {
    await _storage.write(key: '$_keyBankApiPrefix$bankId', value: apiKey);
  }

  /// Banka API anahtarını oku
  static Future<String?> getBankApiKey(String bankId) async {
    return _storage.read(key: '$_keyBankApiPrefix$bankId');
  }

  /// Banka client credentials kaydet
  static Future<void> setBankCredentials(
    String bankId, {
    required String clientId,
    required String clientSecret,
  }) async {
    await _storage.write(key: '$_keyBankClientId$bankId', value: clientId);
    await _storage.write(key: '$_keyBankClientSecret$bankId', value: clientSecret);
  }

  /// Banka client credentials oku
  static Future<({String? clientId, String? clientSecret})> getBankCredentials(String bankId) async {
    final clientId = await _storage.read(key: '$_keyBankClientId$bankId');
    final clientSecret = await _storage.read(key: '$_keyBankClientSecret$bankId');
    return (clientId: clientId, clientSecret: clientSecret);
  }

  // ═══════════════════════════════════════════════
  //  HİVE ŞİFRELEME ANAHTARI
  // ═══════════════════════════════════════════════

  /// Hive veritabanı şifreleme anahtarını kaydet
  static Future<void> setHiveEncryptionKey(String key) async {
    await _storage.write(key: _keyHiveEncryptionKey, value: key);
  }

  /// Hive veritabanı şifreleme anahtarını oku
  static Future<String?> getHiveEncryptionKey() async {
    return _storage.read(key: _keyHiveEncryptionKey);
  }

  // ═══════════════════════════════════════════════
  //  BİYOMETRİK AYARLAR
  // ═══════════════════════════════════════════════

  /// Biyometrik doğrulama durumunu kaydet
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
  }

  /// Biyometrik doğrulama aktif mi?
  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    return val == 'true';
  }

  // ═══════════════════════════════════════════════
  //  UYGULAMA TERCİHLERİ
  // ═══════════════════════════════════════════════

  /// Tema seçimini kaydet (karanlık mod aktif mi?)
  static Future<void> setThemeMode(bool isDark) async {
    await _storage.write(key: _keyThemeMode, value: isDark.toString());
  }

  /// Tema seçimi karanlık mı? Varsayılan: true
  static Future<bool> isDarkMode() async {
    final val = await _storage.read(key: _keyThemeMode);
    if (val == null) return true; // varsayılan
    return val == 'true';
  }

  /// Bildirimleri kaydet
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _storage.write(key: _keyNotificationsEnabled, value: enabled.toString());
  }

  /// Bildirimler açık mı? Varsayılan: false
  static Future<bool> areNotificationsEnabled() async {
    final val = await _storage.read(key: _keyNotificationsEnabled);
    if (val == null) return false; // varsayılan
    return val == 'true';
  }

  /// AI önerilerini kaydet
  static Future<void> setAiInsightsEnabled(bool enabled) async {
    await _storage.write(key: _keyAiInsightsEnabled, value: enabled.toString());
  }

  /// AI önerileri açık mı? Varsayılan: true
  static Future<bool> areAiInsightsEnabled() async {
    final val = await _storage.read(key: _keyAiInsightsEnabled);
    if (val == null) return true; // varsayılan
    return val == 'true';
  }

  // ═══════════════════════════════════════════════
  //  GENEL
  // ═══════════════════════════════════════════════

  /// Tüm güvenli depoyu sil (kullanıcı çıkışı)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Belirli bir anahtarı sil
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
