abstract class AuthRepository {
  /// Kullanıcı girişi yapar. Başarılı ise token döner.
  Future<String> login(String email, String password, {bool rememberMe = false});

  /// Yeni kullanıcı kaydı oluşturur.
  Future<String> register(String name, String email, String password, String phoneNumber);

  /// Google ile giriş yapar. Başarılı ise token döner.
  Future<String> signInWithGoogle({bool rememberMe = false});

  /// Şifre sıfırlama e-postası gönderir.
  Future<void> sendPasswordResetEmail(String email);

  /// Çıkış yapar.
  Future<void> logout();

  /// Mevcut oturum durumunu kontrol eder.
  Future<bool> checkAuthStatus();
}
