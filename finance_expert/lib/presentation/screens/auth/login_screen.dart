import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../navigation_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: sizes.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.account_balance, size: sizes.sp(80), color: AppColors.primary),
                  SizedBox(height: sizes.sp(24)),
                  Text(
                    'Finance Expert',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: sizes.sp(28), fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  SizedBox(height: sizes.sp(8)),
                  Text(
                    'Hesabınıza giriş yapın',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: sizes.sp(16), color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.onSurfaceVariant),
                  ),
                  SizedBox(height: sizes.sp(48)),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: sizes.sp(16)),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: sizes.sp(24)),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      return ElevatedButton(
                        onPressed: () {
                          context.read<AuthCubit>().login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: sizes.sp(16)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Giriş Yap', style: TextStyle(fontSize: sizes.sp(16), fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                  SizedBox(height: sizes.sp(16)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text('Hesabınız yok mu? Kayıt olun', style: TextStyle(color: AppColors.primary, fontSize: sizes.sp(14))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
