import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/security/secure_storage_service.dart';
import '../../core/security/encrypted_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> login(String email, String password, {bool rememberMe = false}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('E-posta ve şifre boş olamaz.');
    }
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Giriş başarısız. Kullanıcı bulunamadı.');
      }

      // Save/update profile in Hive securely
      await _saveLocalProfile(
        uid: user.uid,
        name: user.displayName ?? 'Kullanıcı',
        email: user.email ?? email,
        phoneNumber: user.phoneNumber ?? '',
      );

      // Handle remember me logic
      await SecureStorageService.setRememberMe(rememberMe, email: email);

      final idToken = await user.getIdToken();
      return idToken ?? 'firebase_mock_token';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw Exception('E-posta veya şifre hatalı.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Hatalı şifre.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta adresi.');
      } else if (e.code == 'user-disabled') {
        throw Exception('Bu kullanıcı hesabı askıya alınmış.');
      }
      throw Exception(e.message ?? 'Giriş yapılamadı.');
    } catch (e) {
      throw Exception('Bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<String> register(String name, String email, String password, String phoneNumber) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      throw Exception('Tüm alanları doldurunuz.');
    }
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Kayıt başarısız oldu.');
      }
      
      // Update the user display name in Firebase Auth
      await user.updateDisplayName(name);
      
      // Save profile in Hive securely
      await _saveLocalProfile(
        uid: user.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );

      final idToken = await user.getIdToken();
      return idToken ?? 'firebase_mock_token';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Şifre en az 6 karakter olmalıdır.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Bu e-posta adresi zaten başka bir hesap tarafından kullanılıyor.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta adresi.');
      }
      throw Exception(e.message ?? 'Kayıt işlemi başarısız.');
    } catch (e) {
      throw Exception('Bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<String> signInWithGoogle({bool rememberMe = false}) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google ile giriş iptal edildi.');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Google girişi başarısız. Kullanıcı bilgisi alınamadı.');
      }
      
      // Save/update profile in Hive securely
      await _saveLocalProfile(
        uid: user.uid,
        name: user.displayName ?? 'Google Kullanıcısı',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber ?? '',
      );

      // Handle remember me logic
      await SecureStorageService.setRememberMe(rememberMe, email: user.email);

      final idToken = await user.getIdToken();
      return idToken ?? 'firebase_mock_token';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('Bu e-posta adresi zaten farklı bir giriş yöntemiyle ilişkilendirilmiş.');
      }
      throw Exception(e.message ?? 'Google ile giriş yapılamadı.');
    } catch (e) {
      if (e.toString().contains('sign_in_failed')) {
        throw Exception('Google Giriş Başarısız. Firebase konsolunuzda Android SHA-1 parmak izinin ekli olduğundan ve Google Sign-In sağlayıcısının aktif olduğundan emin olun.');
      }
      throw Exception('Giriş yapılırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      throw Exception('E-posta adresi boş olamaz.');
    }
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Bu e-posta adresiyle kayıtlı bir kullanıcı bulunamadı.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta adresi.');
      }
      throw Exception(e.message ?? 'Şifre sıfırlama maili gönderilemedi.');
    } catch (e) {
      throw Exception('Bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }

  @override
  Future<bool> checkAuthStatus() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return false;
    }

    // Check if remember me is still valid
    final rememberMeEnabled = await SecureStorageService.isRememberMeEnabled();
    if (rememberMeEnabled) {
      final isValid = await SecureStorageService.isRememberMeValid();
      if (!isValid) {
        // Expiry has passed, log out the user from Firebase
        await logout();
        return false;
      }
      return true;
    }

    // If remember me is NOT enabled, we do NOT persist session after app restart!
    await logout();
    return false;
  }

  Future<void> _saveLocalProfile({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final String profileKey = 'user_profile_$uid';
      final existingData = await EncryptedStorage.get<String>(EncryptedStorage.boxUserProfile, profileKey);
      
      Map<String, dynamic> profileMap = {};
      if (existingData != null) {
        try {
          profileMap = Map<String, dynamic>.from(jsonDecode(existingData));
        } catch (_) {}
      }

      profileMap['uid'] = uid;
      profileMap['name'] = name;
      profileMap['email'] = email;
      if (phoneNumber.isNotEmpty || !profileMap.containsKey('phoneNumber')) {
        profileMap['phoneNumber'] = phoneNumber;
      }

      await EncryptedStorage.put<String>(
        EncryptedStorage.boxUserProfile,
        profileKey,
        jsonEncode(profileMap),
      );
    } catch (e) {
      // Silent error or log in development
    }
  }
}
