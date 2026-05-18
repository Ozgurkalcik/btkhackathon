abstract class AuthRepository {
  /// Kullanıcı girişi yapar. Başarılı ise token döner.
  Future<String> login(String email, String password);

  /// Yeni kullanıcı kaydı oluşturur.
  Future<String> register(String name, String email, String password);

  /// Çıkış yapar.
  Future<void> logout();

  /// Mevcut oturum durumunu kontrol eder.
  Future<bool> checkAuthStatus();
}
