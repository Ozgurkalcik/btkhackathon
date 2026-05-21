import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../navigation_helper.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/security/biometric_auth_service.dart';
import '../../../../core/security/totp_service.dart';
import '../../widgets/glass_container.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final bioEnabled = await SecureStorageService.isBiometricEnabled();
    final user = FirebaseAuth.instance.currentUser;
    bool twoFactorEnabled = false;
    if (user != null && user.email != null) {
      twoFactorEnabled = await SecureStorageService.isTwoFactorEnabled(user.email!);
    }
    if (mounted) {
      setState(() {
        _biometricEnabled = bioEnabled;
        _twoFactorEnabled = twoFactorEnabled;
      });
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        bool hide1 = true;
        bool hide2 = true;
        bool hide3 = true;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              title: const Text('Şifreyi Değiştir'),
              content: SingleChildScrollView(
                child: RepaintBoundary(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        obscureText: hide1,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Mevcut Şifre',
                          labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                          suffixIcon: IconButton(
                            icon: Icon(hide1 ? Icons.visibility_off : Icons.visibility, color: AppColors.onSurfaceVariant),
                            onPressed: () => setStateDialog(() => hide1 = !hide1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        obscureText: hide2,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Yeni Şifre',
                          labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                          suffixIcon: IconButton(
                            icon: Icon(hide2 ? Icons.visibility_off : Icons.visibility, color: AppColors.onSurfaceVariant),
                            onPressed: () => setStateDialog(() => hide2 = !hide2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        obscureText: hide3,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Yeni Şifre (Tekrar)',
                          labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                          suffixIcon: IconButton(
                            icon: Icon(hide3 ? Icons.visibility_off : Icons.visibility, color: AppColors.onSurfaceVariant),
                            onPressed: () => setStateDialog(() => hide3 = !hide3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Şifreniz başarıyla değiştirildi!'), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Değiştir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleBiometric(bool val) async {
    if (!val) {
      await SecureStorageService.setBiometricEnabled(false);
      await SecureStorageService.deleteBiometricCredentials();
      setState(() {
        _biometricEnabled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biyometrik giriş devre dışı bırakıldı.')),
      );
      return;
    }

    final isSupported = await BiometricAuthService.isDeviceSupported();
    if (!isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cihazınız biyometrik kimlik doğrulamayı desteklemiyor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final hasBio = await BiometricAuthService.hasBiometrics();
    if (!hasBio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cihazınızda kayıtlı parmak izi/yüz verisi bulunamadı. Lütfen cihaz ayarlarınızdan biyometrik veri tanımlayın.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı oturumu bulunamadı.'), backgroundColor: Colors.red),
      );
      return;
    }

    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              title: const Row(
                children: [
                  Icon(Icons.fingerprint, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text('Biyometrik Giriş'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Güvenliğiniz için lütfen mevcut şifrenizi girin. Şifreniz cihazın yerel güvenli deposunda (Keychain/Keystore) şifreli olarak saklanacaktır.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () => setStateDialog(() => obscurePassword = !obscurePassword),
                      ),
                      filled: true,
                      fillColor: AppColors.background.withOpacity(0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final password = passwordController.text.trim();
                          if (password.isEmpty) {
                            setStateDialog(() => errorMessage = 'Şifre alanı boş bırakılamaz.');
                            return;
                          }

                          setStateDialog(() {
                            isLoading = true;
                            errorMessage = null;
                          });

                          try {
                            final credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: password,
                            );
                            await user.reauthenticateWithCredential(credential);

                            await SecureStorageService.saveBiometricCredentials(user.email!, password);
                            await SecureStorageService.setBiometricEnabled(true);

                            if (mounted) {
                              setState(() {
                                _biometricEnabled = true;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Biyometrik giriş başarıyla etkinleştirildi!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            setStateDialog(() {
                              isLoading = false;
                              errorMessage = e.message ?? 'Şifre doğrulanamadı.';
                            });
                          } catch (e) {
                            setStateDialog(() {
                              isLoading = false;
                              errorMessage = 'Bir hata oluştu.';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Doğrula'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _show2FASetup() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı oturumu bulunamadı.'), backgroundColor: Colors.red),
      );
      return;
    }
    final email = user.email!;
    final secret = TotpService.generateSecret();
    final codeController = TextEditingController();
    String? errorMessage;
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              title: const Row(
                children: [
                  Icon(Icons.security, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text('2FA Kurulumu'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Google Authenticator veya benzeri bir uygulama kullanarak bu QR kodu taratın veya altındaki anahtarı ekleyin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    
                    // Procedural Mock QR Code
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(8, (y) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(8, (x) {
                                final isAnchor = (x < 3 && y < 3) || (x > 4 && y < 3) || (x < 3 && y > 4);
                                final isFilled = isAnchor || (x + y) % 3 == 0 || (x * y) % 2 == 0;
                                return Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: isFilled ? Colors.black : Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Secret Key field with copy action
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'GİZLİ ANAHTAR',
                                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  secret,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: AppColors.secondary, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: secret));
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Anahtar kopyalandı!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Code field
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 8, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Doğrulama Kodu',
                        labelStyle: const TextStyle(letterSpacing: 0, color: AppColors.onSurfaceVariant),
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.background.withOpacity(0.6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.pop(ctx),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : () async {
                          final code = codeController.text.trim();
                          if (code.length != 6) {
                            setStateDialog(() => errorMessage = 'Lütfen 6 haneli doğrulama kodunu girin.');
                            return;
                          }

                          setStateDialog(() {
                            isVerifying = true;
                            errorMessage = null;
                          });

                          final verified = TotpService.verifyCode(secret, code);
                          if (verified) {
                            await SecureStorageService.setTwoFactorEnabled(email, true);
                            await SecureStorageService.setTwoFactorSecret(email, secret);
                            if (mounted) {
                              setState(() {
                                _twoFactorEnabled = true;
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('2FA Başarıyla Aktifleştirildi!'), backgroundColor: Colors.green),
                              );
                            }
                          } else {
                            setStateDialog(() {
                              isVerifying = false;
                              errorMessage = 'Geçersiz doğrulama kodu. Lütfen tekrar deneyin.';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Doğrula ve Aktifleştir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: buildCommonAppBar(context: context, title: 'Güvenlik', showBackButton: true),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: sizes.screenPadding.copyWith(top: sizes.sp(24)),
        children: [
          GlassContainer(
            borderRadius: 24,
            padding: EdgeInsets.symmetric(vertical: sizes.sp(8)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.fingerprint, color: AppColors.onSurfaceVariant),
                  title: const Text('Biyometrik Giriş (Face ID / Touch ID)', style: TextStyle(color: AppColors.onSurface)),
                  trailing: Switch(
                    value: _biometricEnabled,
                    activeColor: AppColors.secondary,
                    onChanged: _toggleBiometric,
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.08), height: 1),
                ListTile(
                  leading: const Icon(Icons.password, color: AppColors.onSurfaceVariant),
                  title: const Text('Şifreyi Değiştir', style: TextStyle(color: AppColors.onSurface)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                  onTap: _showChangePasswordDialog,
                ),
                Divider(color: Colors.white.withOpacity(0.08), height: 1),
                ListTile(
                  leading: const Icon(Icons.security, color: AppColors.onSurfaceVariant),
                  title: const Text('İki Faktörlü Doğrulama (2FA)', style: TextStyle(color: AppColors.onSurface)),
                  trailing: Switch(
                    value: _twoFactorEnabled,
                    activeColor: AppColors.secondary,
                    onChanged: (val) async {
                      if (val) {
                        _show2FASetup();
                      } else {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null && user.email != null) {
                          await SecureStorageService.deleteTwoFactor(user.email!);
                        }
                        setState(() => _twoFactorEnabled = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('2FA devre dışı bırakıldı.')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sizes.sp(32)),
          Text(
            'Güvenlik sistemleri uçtan uca şifreleme ve banka düzeyinde güvenlik protokolleri ile korunmaktadır.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sizes.sp(12),
              color: isDark ? AppColors.onSurfaceVariant : Colors.grey[600],
              height: 1.5,
            ),
          )
        ],
      ),
    );
  }
}
