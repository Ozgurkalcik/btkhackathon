import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // Not: Büyük ölçekli bir uygulamada burada Firebase, Supabase
  // veya kendi Node.js/.NET backend'iniz ile çalışan bir Datasource çağrılmalıdır.

  @override
  Future<String> login(String email, String password) async {
    // API Call simülasyonu
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isEmpty || password.isEmpty) {
      throw Exception('E-posta ve şifre boş olamaz.');
    }
    
    // Geçici Mock Token
    return 'mock_jwt_token_12345';
  }

  @override
  Future<String> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Tüm alanları doldurunuz.');
    }

    return 'mock_jwt_token_67890';
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Token'ı silme işlemi (SecureStorage üzerinden) yapılabilir.
  }

  @override
  Future<bool> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Başlangıçta giriş yapılmamış varsayıyoruz.
    return false;
  }
}
