import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'analytics.dart' as analytics;
import 'budget.dart' as budget;
import 'dashbroad.dart' as dashboard;
import 'health.dart' as health;
import 'profile.dart' as profile;
import 'scan.dart' as scan;
import 'services/data_repository.dart';

import 'presentation/bloc/settings/settings_cubit.dart';
import 'presentation/bloc/settings/settings_state.dart';
import 'presentation/bloc/auth/auth_cubit.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'data/repositories/auth_repository_impl.dart';

import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/profile/personal_info_screen.dart';
import 'presentation/screens/profile/payment_methods_screen.dart';
import 'presentation/screens/profile/security_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataRepository().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => AuthCubit(authRepository: AuthRepositoryImpl())..checkAuth()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Finance Expert',
            debugShowCheckedModeBanner: false,
            themeMode: state.themeMode,
            theme: ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color(0xFFF0F2F5),
              textTheme: ThemeData.light().textTheme.apply(
                    fontFamily: 'Inter',
                    bodyColor: const Color(0xFF101415),
                    displayColor: const Color(0xFF101415),
                  ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF101415),
              textTheme: ThemeData.dark().textTheme.apply(
                    fontFamily: 'Inter',
                    bodyColor: const Color(0xFFE0E3E5),
                    displayColor: const Color(0xFFE0E3E5),
                  ),
            ),
            initialRoute: '/auth_check',
            routes: {
              '/auth_check': (context) => const AuthCheckScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/': (context) => const dashboard.DashboardScreen(),
              '/analytics': (context) => const analytics.AnalyticsScreen(),
              '/budget': (context) => const budget.BudgetScreen(),
              '/health': (context) => const health.HealthDashboardScreen(),
              '/profile': (context) => const profile.ProfileScreen(),
              '/scan': (context) => const scan.ResolutionScreen(),
              '/profile/personal_info': (context) => const PersonalInfoScreen(),
              '/profile/payment_methods': (context) => const PaymentMethodsScreen(),
              '/profile/security_settings': (context) => const SecuritySettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      builder: (context, state) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
