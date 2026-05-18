import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'secure_storage_service.dart';

/// Biyometrik Kimlik Doğrulama Servisi
///
/// FaceID, parmak izi veya cihaz PIN'i ile kullanıcı doğrulaması sağlar.
/// Finansal verilere erişimden önce zorunlu kılınabilir.
class BiometricAuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Cihazda biyometrik donanım var mı?
  static Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Kayıtlı biyometrik veri var mı?
  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Kullanılabilir biyometrik türlerini getir
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Biyometrik doğrulama yap
  ///
  /// Başarılı → true, başarısız → false döner.
  /// [reason] kullanıcıya gösterilecek açıklama metni.
  static Future<bool> authenticate({
    String reason = 'Finansal verilerinize erişim için kimliğinizi doğrulayın',
  }) async {
    try {
      // Biyometrik kapalıysa direkt geç
      final enabled = await SecureStorageService.isBiometricEnabled();
      if (!enabled) return true;

      final isSupported = await isDeviceSupported();
      if (!isSupported) return true; // Desteklenmiyorsa bypass

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // PIN fallback'e izin ver
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Biyometrik doğrulamayı aktif/pasif yap
  static Future<void> setEnabled(bool enabled) async {
    await SecureStorageService.setBiometricEnabled(enabled);
  }

  /// Biyometrik doğrulama aktif mi?
  static Future<bool> isEnabled() async {
    return SecureStorageService.isBiometricEnabled();
  }
}
