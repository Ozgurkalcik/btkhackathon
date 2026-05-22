import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/security/totp_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await _authRepository.checkAuthStatus();
      if (isAuthenticated) {
        emit(const AuthAuthenticated('existing_token'));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    emit(AuthLoading());
    try {
      // Önce 2FA durumunu kontrol et
      final is2faEnabled = await SecureStorageService.isTwoFactorEnabled(email);
      
      // Firebase kimlik doğrulamayı gerçekleştir
      final token = await _authRepository.login(email, password, rememberMe: rememberMe);
      
      if (is2faEnabled) {
        emit(AuthTwoFactorRequired(email, token));
      } else {
        emit(AuthAuthenticated(token));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(AuthUnauthenticated()); // Return to unauthenticated to allow retry
    }
  }

  Future<void> register(String name, String email, String password, String phoneNumber) async {
    emit(AuthLoading());
    try {
      final token = await _authRepository.register(name, email, password, phoneNumber);
      emit(AuthAuthenticated(token));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signInWithGoogle({bool rememberMe = false}) async {
    emit(AuthLoading());
    try {
      final token = await _authRepository.signInWithGoogle(rememberMe: rememberMe);
      
      final email = FirebaseAuth.instance.currentUser?.email;
      final is2faEnabled = email != null && await SecureStorageService.isTwoFactorEnabled(email);
      
      if (is2faEnabled) {
        emit(AuthTwoFactorRequired(email, token));
      } else {
        emit(AuthAuthenticated(token));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> verifyTwoFactorCode(String email, String token, String code) async {
    emit(AuthLoading());
    try {
      final secret = await SecureStorageService.getTwoFactorSecret(email);
      if (secret == null) {
        emit(AuthError('2FA yapılandırması bulunamadı.'));
        emit(AuthTwoFactorRequired(email, token));
        return;
      }
      
      final isValid = TotpService.verifyCode(secret, code);
      if (isValid) {
        emit(AuthAuthenticated(token));
      } else {
        emit(AuthError('Geçersiz doğrulama kodu. Lütfen tekrar deneyin.'));
        emit(AuthTwoFactorRequired(email, token));
      }
    } catch (e) {
      emit(AuthError('Doğrulama hatası: ${e.toString()}'));
      emit(AuthTwoFactorRequired(email, token));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email);
      emit(AuthPasswordResetEmailSent());
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
