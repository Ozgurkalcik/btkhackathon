import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../navigation_helper.dart';
import '../../widgets/google_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  void _handleRegister() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showError('Lütfen adınızı ve soyadınızı girin.');
      return;
    }

    if (phone.isEmpty) {
      _showError('Lütfen telefon numaranızı girin.');
      return;
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(phone.replaceAll(' ', ''))) {
      _showError('Lütfen geçerli bir telefon numarası girin.');
      return;
    }

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
      _showError('Lütfen bir şifre belirleyin.');
      return;
    }

    if (password.length < 6) {
      _showError('Şifre en az 6 karakterden oluşmalıdır.');
      return;
    }

    // Check password complexity (at least one letter and one number for senior-level security)
    if (!RegExp(r'[a-zA-Z]').hasMatch(password) || !RegExp(r'[0-9]').hasMatch(password)) {
      _showError('Şifre en az bir harf ve en az bir rakam içermelidir.');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showError('Lütfen şifrenizi tekrar girin.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Şifreler eşleşmiyor.');
      return;
    }

    context.read<AuthCubit>().register(name, email, password, phone);
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else if (state is AuthError) {
          _showError(state.message);
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
            // Floating Back Button moved to the bottom of Stack z-order to receive touch events
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: sizes.screenPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: sizes.sp(50)),
                      // Header Section
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: sizes.sp(72),
                          height: sizes.sp(72),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            size: sizes.sp(36),
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                      SizedBox(height: sizes.sp(16)),
                      Text(
                        'Hesap Oluştur',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sizes.sp(28),
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: sizes.sp(6)),
                      Text(
                        'Aramıza katılın ve finansal yönetiminizi kolaylaştırın',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sizes.sp(13),
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: sizes.sp(32)),

                      // Register Card
                      RepaintBoundary(
                        child: Container(
                          padding: EdgeInsets.all(sizes.sp(24)),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Yeni Kayıt',
                              style: TextStyle(
                                  fontSize: sizes.sp(18),
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: sizes.sp(20)),

                              // Name input
                              TextField(
                                controller: _nameController,
                                style: TextStyle(color: colorScheme.onSurface, fontSize: sizes.sp(14)),
                                decoration: InputDecoration(
                                  labelText: 'Ad Soyad',
                                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                  prefixIcon: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
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

                              // Phone input
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: TextStyle(color: colorScheme.onSurface, fontSize: sizes.sp(14)),
                                decoration: InputDecoration(
                                  labelText: 'Telefon Numarası',
                                  hintText: '5XXXXXXXXX',
                                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                  prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.onSurfaceVariant),
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
                              SizedBox(height: sizes.sp(16)),

                              // Confirm Password input
                              TextField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: TextStyle(color: colorScheme.onSurface, fontSize: sizes.sp(14)),
                                decoration: InputDecoration(
                                  labelText: 'Şifre Tekrar',
                                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                  prefixIcon: Icon(Icons.lock_clock_outlined, color: colorScheme.onSurfaceVariant),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: colorScheme.onSurfaceVariant,
                                      size: sizes.sp(20),
                                    ),
                                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
                                      Container(
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
                                            ]),
                                        child: ElevatedButton(
                                          onPressed: _handleRegister,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: EdgeInsets.symmetric(vertical: sizes.sp(16)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          ),
                                          child: Text(
                                            'Kayıt Ol',
                                            style: TextStyle(
                                              fontSize: sizes.sp(16),
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
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
                                          context.read<AuthCubit>().signInWithGoogle();
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
                                              'Google ile Kaydol',
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

                      // Navigation to login
                      SizedBox(height: sizes.sp(24)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.secondary,
                        ),
                        child: Text(
                          'Zaten hesabınız var mı? Giriş Yapın',
                          style: TextStyle(
                            fontSize: sizes.sp(14),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      SizedBox(height: sizes.sp(40)),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Back Button placed on top of SingleChildScrollView in Stack z-order
            Positioned(
              top: sizes.sp(16),
              left: sizes.sp(16),
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                    border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.06)),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface, size: sizes.sp(20)),
                    onPressed: () => Navigator.pop(context),
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
