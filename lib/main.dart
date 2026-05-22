import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'presentation/screens/transactions_screen.dart';
import 'presentation/screens/assistant_screen.dart';
import 'dashbroad.dart' as dashboard;
import 'budget.dart' as budget;
import 'health.dart' as health;
import 'profile.dart' as profile;
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

import 'presentation/screens/analytics_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: '/auth_check',
            routes: {
              '/auth_check': (context) => const AuthCheckScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/': (context) => const dashboard.DashboardScreen(),
              '/transactions': (context) => const TransactionsScreen(),
              '/assistant': (context) => const AssistantScreen(),
              '/health': (context) => const health.HealthDashboardScreen(),
              '/budget': (context) => const budget.BudgetScreen(),
              '/analytics': (context) => const AnalyticsScreen(),
              '/profile': (context) => const profile.ProfileScreen(),
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
