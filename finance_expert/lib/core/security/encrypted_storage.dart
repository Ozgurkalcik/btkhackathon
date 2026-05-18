import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'secure_storage_service.dart';

/// Şifreli Yerel Veritabanı (Encrypted Hive Storage)
///
/// Tüm finansal verileri AES-256 ile şifrelenmiş Hive kutularında saklar.
/// Şifreleme anahtarı Android Keystore / iOS Keychain'de tutulur.
class EncryptedStorage {
  static bool _initialized = false;

  /// Hive'ı şifreli modda başlat
  ///
  /// Uygulama başlangıcında bir kez çağrılmalıdır.
  /// Şifreleme anahtarı yoksa yeni bir tane oluşturur ve
  /// SecureStorage'a kaydeder.
  static Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _initialized = true;
  }

  /// AES-256 şifreleme anahtarı oluştur veya var olanı oku
  static Future<Uint8List> _getEncryptionKey() async {
    String? storedKey = await SecureStorageService.getHiveEncryptionKey();

    if (storedKey == null || storedKey.isEmpty) {
      // Yeni anahtar oluştur (32 byte = AES-256)
      final secureKey = Hive.generateSecureKey();
      storedKey = base64Encode(secureKey);
      await SecureStorageService.setHiveEncryptionKey(storedKey);
    }

    return base64Decode(storedKey);
  }

  /// Şifreli bir Hive kutusu aç
  ///
  /// [boxName] kutu adı — her veri türü için farklı kutu kullanılır
  static Future<Box<T>> openEncryptedBox<T>(String boxName) async {
    if (!_initialized) await initialize();

    final encryptionKey = await _getEncryptionKey();

    return Hive.openBox<T>(
      boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  /// Şifreli kutu aç ve veri kaydet
  static Future<void> put<T>(String boxName, String key, T value) async {
    final box = await openEncryptedBox<T>(boxName);
    await box.put(key, value);
  }

  /// Şifreli kutudan veri oku
  static Future<T?> get<T>(String boxName, String key) async {
    final box = await openEncryptedBox<T>(boxName);
    return box.get(key);
  }

  /// Şifreli kutudan tüm verileri oku
  static Future<List<T>> getAll<T>(String boxName) async {
    final box = await openEncryptedBox<T>(boxName);
    return box.values.toList();
  }

  /// Şifreli kutudan veri sil
  static Future<void> delete(String boxName, String key) async {
    final box = await openEncryptedBox(boxName);
    await box.delete(key);
  }

  /// Kutu adları (sabitleri)
  static const String boxTransactions = 'encrypted_transactions';
  static const String boxAccounts = 'encrypted_accounts';
  static const String boxBudgets = 'encrypted_budgets';
  static const String boxChatHistory = 'encrypted_chat_history';
  static const String boxUserProfile = 'encrypted_user_profile';

  /// Veri bütünlüğü kontrolü — SHA-256 hash
  static String computeIntegrityHash(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }
}
