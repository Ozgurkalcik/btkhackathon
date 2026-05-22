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
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keyThemeMode = 'theme_mode';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyAiInsightsEnabled = 'ai_insights_enabled';
  static const _keyRememberMe = 'remember_me';
  static const _keyRememberMeEmail = 'remember_me_email';
  static const _keyRememberMeExpiry = 'remember_me_expiry';

  // ═══════════════════════════════════════════════
  //  BENİ HATIRLA (REMEMBER ME)
  // ═══════════════════════════════════════════════

  /// Beni hatırla durumunu ve e-postayı güvenli depoya kaydet
  static Future<void> setRememberMe(bool enabled, {String? email}) async {
    await _storage.write(key: _keyRememberMe, value: enabled.toString());
    if (enabled && email != null) {
      await _storage.write(key: _keyRememberMeEmail, value: email);
      final expiry = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
      await _storage.write(key: _keyRememberMeExpiry, value: expiry.toString());
    } else {
      await _storage.delete(key: _keyRememberMeEmail);
      await _storage.delete(key: _keyRememberMeExpiry);
    }
  }

  /// Beni hatırla aktif mi?
  static Future<bool> isRememberMeEnabled() async {
    final val = await _storage.read(key: _keyRememberMe);
    return val == 'true';
  }

  /// Kaydedilen Beni hatırla e-postasını oku
  static Future<String?> getRememberMeEmail() async {
    return _storage.read(key: _keyRememberMeEmail);
  }

  /// Beni hatırla süresi geçerli mi? (1 ay)
  static Future<bool> isRememberMeValid() async {
    final enabled = await isRememberMeEnabled();
    if (!enabled) return false;
    final expiryStr = await _storage.read(key: _keyRememberMeExpiry);
    if (expiryStr == null) return false;
    final expiry = int.tryParse(expiryStr);
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

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

  static const _keyBiometricEmail = 'biometric_email';
  static const _keyBiometricPassword = 'biometric_password';
  static const _keyTwoFactorEnabledPrefix = '2fa_enabled_';
  static const _keyTwoFactorSecretPrefix = '2fa_secret_';

  // ═══════════════════════════════════════════════
  //  BİYOMETRİK ŞİFRE SAKLAMA
  // ═══════════════════════════════════════════════

  /// Biyometrik giriş için kullanıcı bilgilerini kaydet
  static Future<void> saveBiometricCredentials(String email, String password) async {
    await _storage.write(key: _keyBiometricEmail, value: email);
    await _storage.write(key: _keyBiometricPassword, value: password);
  }

  /// Biyometrik giriş için kaydedilmiş bilgileri oku
  static Future<({String? email, String? password})> getBiometricCredentials() async {
    final email = await _storage.read(key: _keyBiometricEmail);
    final password = await _storage.read(key: _keyBiometricPassword);
    return (email: email, password: password);
  }

  /// Biyometrik kimlik bilgilerini sil
  static Future<void> deleteBiometricCredentials() async {
    await _storage.delete(key: _keyBiometricEmail);
    await _storage.delete(key: _keyBiometricPassword);
  }

  // ═══════════════════════════════════════════════
  //  İKİ FAKTÖRLÜ DOĞRULAMA (2FA)
  // ═══════════════════════════════════════════════

  /// Kullanıcı bazlı 2FA aktiflik durumunu kaydet
  static Future<void> setTwoFactorEnabled(String email, bool enabled) async {
    await _storage.write(key: '$_keyTwoFactorEnabledPrefix$email', value: enabled.toString());
  }

  /// Kullanıcı bazlı 2FA aktif mi?
  static Future<bool> isTwoFactorEnabled(String email) async {
    final val = await _storage.read(key: '$_keyTwoFactorEnabledPrefix$email');
    return val == 'true';
  }

  /// Kullanıcı bazlı 2FA gizli anahtarını (secret) kaydet
  static Future<void> setTwoFactorSecret(String email, String secret) async {
    await _storage.write(key: '$_keyTwoFactorSecretPrefix$email', value: secret);
  }

  /// Kullanıcı bazlı 2FA gizli anahtarını (secret) oku
  static Future<String?> getTwoFactorSecret(String email) async {
    return _storage.read(key: '$_keyTwoFactorSecretPrefix$email');
  }

  /// Kullanıcının 2FA ayarlarını sil
  static Future<void> deleteTwoFactor(String email) async {
    await _storage.delete(key: '$_keyTwoFactorEnabledPrefix$email');
    await _storage.delete(key: '$_keyTwoFactorSecretPrefix$email');
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
