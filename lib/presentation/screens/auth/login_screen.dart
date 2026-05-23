import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../navigation_helper.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/security/biometric_auth_service.dart';
import '../../widgets/google_logo.dart';
import '../../widgets/glass_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _twoFactorCodeController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  bool _isBiometricSupported = false;
  bool _isBiometricEnabled = false;
  bool _hasBiometricCredentials = false;

  bool _showTwoFactorInput = false;
  String? _twoFactorEmail;
  String? _twoFactorToken;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _twoFactorCodeController.dispose();
    super.dispose();
  }

  void _checkBiometricAvailability() async {
    final isSupported = await BiometricAuthService.isDeviceSupported();
    final hasBiometrics = await BiometricAuthService.hasBiometrics();
    final isEnabled = await BiometricAuthService.isEnabled();
    final credentials = await SecureStorageService.getBiometricCredentials();
    final hasCredentials = credentials.email != null && credentials.password != null;

    if (mounted) {
      setState(() {
        _isBiometricSupported = isSupported;
        _isBiometricEnabled = isEnabled;
        _hasBiometricCredentials = hasCredentials;
      });

      // Auto trigger if biometrics is fully enabled & we have stored credentials
      if (isSupported && hasBiometrics && isEnabled && hasCredentials) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _handleBiometricLogin();
          }
        });
      }
    }
  }

  void _handleBiometricLogin() async {
    final isSupported = await BiometricAuthService.isDeviceSupported();
    if (!isSupported) {
      _showError('Cihazınız biyometrik girişi desteklemiyor.');
      return;
    }

    final hasBio = await BiometricAuthService.hasBiometrics();
    if (!hasBio) {
      _showError('Cihazınızda kayıtlı parmak izi/yüz verisi bulunamadı. Lütfen cihaz ayarlarınızdan biyometrik veri tanımlayın.');
      return;
    }

    final authenticated = await BiometricAuthService.authenticate(
      reason: 'Biyometrik verilerinizle hızlı giriş yapın',
    );

    if (authenticated) {
      final credentials = await SecureStorageService.getBiometricCredentials();
      if (credentials.email != null && credentials.password != null) {
        if (mounted) {
          context.read<AuthCubit>().login(
            credentials.email!,
            credentials.password!,
            rememberMe: _rememberMe,
          );
        }
      } else {
        _showError('Biyometrik giriş bilgileri bulunamadı. Lütfen önce şifrenizle giriş yapın.');
      }
    } else {
      _showError('Biyometrik doğrulama başarısız oldu.');
    }
  }

  void _showBiometricGuidance() {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Biyometrik giriş aktif değil veya giriş bilgisi kaydedilmemiş. Lütfen önce şifrenizle giriş yapıp Profil > Güvenlik Ayarları altından biyometrik girişi etkinleştirin.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _loadRememberedEmail() async {
    final enabled = await SecureStorageService.isRememberMeEnabled();
    if (enabled) {
      final email = await SecureStorageService.getRememberMeEmail();
      if (email != null && mounted) {
        setState(() {
          _emailController.text = email;
          _rememberMe = true;
        });
      }
    }
  }

  void _showError(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    final sizes = AppSizes(context);
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.08)),
          ),
          title: Text(
            'Şifre Sıfırlama',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: sizes.sp(18),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Şifrenizi sıfırlamak için kayıtlı e-posta adresinizi girin. Size sıfırlama linki göndereceğiz.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: sizes.sp(13),
                  height: 1.4,
                ),
              ),
              SizedBox(height: sizes.sp(16)),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: colorScheme.onSurface, fontSize: sizes.sp(14)),
                decoration: InputDecoration(
                  labelText: 'E-posta Adresi',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surface.withValues(alpha: 0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: sizes.sp(16), vertical: sizes.sp(14)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: sizes.sp(13),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('E-posta alanı boş bırakılamaz.')),
                  );
                  return;
                }
                Navigator.pop(context);
                context.read<AuthCubit>().forgotPassword(email);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: sizes.sp(16), vertical: sizes.sp(10)),
              ),
              child: Text(
                'Gönder',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: sizes.sp(13),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showError('Lütfen e-posta adresinizi girin.');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Lütfen geçerli bir e-posta adresi girin.');
      return;
    }

    if (password.isEmpty) {
      _showError('Lütfen şifrenizi girin.');
      return;
    }

    context.read<AuthCubit>().login(email, password, rememberMe: _rememberMe);
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (state is AuthError) {
          _showError(state.message);
        } else if (state is AuthTwoFactorRequired) {
          setState(() {
            _twoFactorEmail = state.email;
            _twoFactorToken = state.token;
            _showTwoFactorInput = true;
          });
        } else if (state is AuthPasswordResetEmailSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Şifre sıfırlama e-postası başarıyla gönderildi!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: colorScheme.secondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            // Decorative background gradients
            Positioned(
              top: -sizes.sp(100),
              right: -sizes.sp(100),
              child: Container(
                width: sizes.sp(300),
                height: sizes.sp(300),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -sizes.sp(100),
              left: -sizes.sp(100),
              child: Container(
                width: sizes.sp(300),
                height: sizes.sp(300),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: sizes.screenPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: sizes.sp(84),
                          height: sizes.sp(84),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            size: sizes.sp(42),
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                      SizedBox(height: sizes.sp(20)),
                      Text(
                        'Finance Expert',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sizes.sp(30),
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: sizes.sp(8)),
                      Text(
                        'Yapay zeka destekli kişisel finans asistanı',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sizes.sp(14),
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: sizes.sp(40)), // Login Card
                      RepaintBoundary(
                        child: GlassContainer(
                          padding: EdgeInsets.all(sizes.sp(24)),
                          borderRadius: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _showTwoFactorInput
                                ? [
                                    Text(
                                      'İki Faktörlü Doğrulama',
                                      style: TextStyle(
                                        fontSize: sizes.sp(18),
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: sizes.sp(8)),
                                    Text(
                                      'Lütfen kimlik doğrulayıcı uygulamanızdaki 6 haneli doğrulama kodunu girin.',
                                      style: TextStyle(
                                        fontSize: sizes.sp(13),
                                        color: colorScheme.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: sizes.sp(24)),
                                    
                                    // 2FA code input
                                    TextField(
                                      controller: _twoFactorCodeController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: sizes.sp(18),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: sizes.sp(12),
                                      ),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        labelText: 'Doğrulama Kodu',
                                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, letterSpacing: 0),
                                        prefixIcon: Icon(Icons.security, color: colorScheme.onSurfaceVariant),
                                        counterText: '',
                                        filled: true,
                                        fillColor: colorScheme.surface.withValues(alpha: 0.6),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: sizes.sp(16), vertical: sizes.sp(14)),
                                      ),
                                    ),
                                    SizedBox(height: sizes.sp(28)),
                                    
                                    // 2FA actions
                                    BlocBuilder<AuthCubit, AuthState>(
                                      builder: (context, state) {
                                        if (state is AuthLoading) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _showTwoFactorInput = false;
                                                    _twoFactorCodeController.clear();
                                                  });
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: colorScheme.onSurface,
                                                  side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.08)),
                                                  padding: EdgeInsets.symmetric(vertical: sizes.sp(16)),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                ),
                                                child: const Text('Geri Dön'),
                                              ),
                                            ),
                                            SizedBox(width: sizes.sp(12)),
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  gradient: LinearGradient(
                                                    colors: [colorScheme.primaryContainer, colorScheme.primary],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: colorScheme.primary.withValues(alpha: 0.3),
                                                      blurRadius: 12,
                                                      offset: const Offset(0, 4),
                                                    )
                                                  ]
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    final code = _twoFactorCodeController.text.trim();
                                                    if (code.length != 6) {
                                                      _showError('Lütfen 6 haneli doğrulama kodunu girin.');
                                                      return;
                                                    }
                                                    context.read<AuthCubit>().verifyTwoFactorCode(
                                                          _twoFactorEmail!,
                                                          _twoFactorToken!,
                                                          code,
                                                        );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor: Colors.transparent,
                                                    padding: EdgeInsets.symmetric(vertical: sizes.sp(16)),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  child: Text(
                                                    'Doğrula',
                                                    style: TextStyle(
                                                      fontSize: sizes.sp(16),
                                                      fontWeight: FontWeight.bold,
                                                      color: colorScheme.onPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ]
                                : [
                                    Text(
                                      'Hesabınıza Giriş Yapın',
                                      style: TextStyle(
                                        fontSize: sizes.sp(18),
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: sizes.sp(20)),
                                    
                                    // Email input
                                    TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(color: colorScheme.onSurface, fontSize: sizes.sp(14)),
                                      decoration: InputDecoration(
                                        labelText: 'E-posta',
                                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                        prefixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant),
                                        filled: true,
                                        fillColor: colorScheme.surface.withValues(alpha: 0.6),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: sizes.sp(16), vertical: sizes.sp(14)),
                                      ),
                                    ),
                                    SizedBox(height: sizes.sp(16)),
                                    
                                    // Password input
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: TextStyle(color: colorScheme.onSurface, fontSize: sizes.sp(14)),
                                      decoration: InputDecoration(
                                        labelText: 'Şifre',
                                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                        prefixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                            color: colorScheme.onSurfaceVariant,
                                            size: sizes.sp(20),
                                          ),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                        filled: true,
                                        fillColor: colorScheme.surface.withValues(alpha: 0.6),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: sizes.sp(16), vertical: sizes.sp(14)),
                                      ),
                                    ),
                                    SizedBox(height: sizes.sp(14)),

                                    // Remember Me & Forgot Password Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: sizes.sp(20),
                                              height: sizes.sp(20),
                                              child: Checkbox(
                                                value: _rememberMe,
                                                activeColor: colorScheme.primary,
                                                checkColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                side: BorderSide(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                                onChanged: (val) {
                                                  setState(() {
                                                    _rememberMe = val ?? false;
                                                  });
                                                },
                                              ),
                                            ),
                                            SizedBox(width: sizes.sp(8)),
                                            GestureDetector(
                                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                                              child: Text(
                                                'Beni Hatırla',
                                                style: TextStyle(
                                                  color: colorScheme.onSurface,
                                                  fontSize: sizes.sp(13),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: _showForgotPasswordDialog,
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            foregroundColor: colorScheme.secondary,
                                          ),
                                          child: Text(
                                            'Şifremi Unuttum',
                                            style: TextStyle(
                                              fontSize: sizes.sp(13),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: sizes.sp(24)),
                                    
                                    // Action Button
                                    BlocBuilder<AuthCubit, AuthState>(
                                      builder: (context, state) {
                                        if (state is AuthLoading) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(16),
                                                      gradient: LinearGradient(
                                                        colors: [colorScheme.primaryContainer, colorScheme.primary],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: colorScheme.primary.withValues(alpha: 0.3),
                                                          blurRadius: 12,
                                                          offset: const Offset(0, 4),
                                                        )
                                                      ]
                                                    ),
                                                    child: ElevatedButton(
                                                      onPressed: _handleLogin,
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.transparent,
                                                        shadowColor: Colors.transparent,
                                                        padding: EdgeInsets.symmetric(vertical: sizes.sp(16)),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                      ),
                                                      child: Text(
                                                        'Giriş Yap',
                                                        style: TextStyle(
                                                          fontSize: sizes.sp(16),
                                                          fontWeight: FontWeight.bold,
                                                          color: colorScheme.onPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (_isBiometricSupported) ...[
                                                   SizedBox(width: sizes.sp(12)),
                                                   Container(
                                                     height: sizes.sp(56),
                                                     width: sizes.sp(56),
                                                     decoration: BoxDecoration(
                                                       borderRadius: BorderRadius.circular(16),
                                                       color: colorScheme.onSurface.withValues(alpha: 0.07),
                                                       border: Border.all(
                                                         color: (_isBiometricEnabled && _hasBiometricCredentials)
                                                             ? colorScheme.primary.withValues(alpha: 0.3)
                                                             : colorScheme.onSurface.withValues(alpha: 0.12),
                                                       ),
                                                     ),
                                                     child: IconButton(
                                                       icon: Icon(
                                                         Icons.fingerprint,
                                                         color: (_isBiometricEnabled && _hasBiometricCredentials)
                                                             ? colorScheme.primary
                                                             : colorScheme.onSurface.withValues(alpha: 0.3),
                                                         size: sizes.sp(28),
                                                       ),
                                                       onPressed: () {
                                                         if (_isBiometricEnabled && _hasBiometricCredentials) {
                                                           _handleBiometricLogin();
                                                         } else {
                                                           _showBiometricGuidance();
                                                         }
                                                       },
                                                     ),
                                                   ),
                                                 ],
                                              ],
                                            ),
                                            SizedBox(height: sizes.sp(20)),
                                            Row(
                                              children: [
                                                Expanded(child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.08))),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: sizes.sp(16)),
                                                  child: Text(
                                                    'veya',
                                                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: sizes.sp(12)),
                                                  ),
                                                ),
                                                Expanded(child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.08))),
                                              ],
                                            ),
                                            SizedBox(height: sizes.sp(20)),
                                            OutlinedButton(
                                              onPressed: () {
                                                context.read<AuthCubit>().signInWithGoogle(rememberMe: _rememberMe);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: colorScheme.onSurface,
                                                side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.08)),
                                                padding: EdgeInsets.symmetric(vertical: sizes.sp(14)),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                backgroundColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(right: 12),
                                                    child: GoogleLogo(size: 20),
                                                  ),
                                                  Text(
                                                    'Google ile Giriş Yap',
                                                    style: TextStyle(
                                                      fontSize: sizes.sp(14),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                          ),
                        ),
                      ),
                      
                      // Navigation to register
                      SizedBox(height: sizes.sp(24)),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.secondary,
                        ),
                        child: Text(
                          'Hesabınız yok mu? Yeni Hesap Oluşturun',
                          style: TextStyle(
                            fontSize: sizes.sp(14),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
