import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/security/secure_storage_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isDark = await SecureStorageService.isDarkMode();
    final notifs = await SecureStorageService.areNotificationsEnabled();
    final ai = await SecureStorageService.areAiInsightsEnabled();

    emit(state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      notificationsEnabled: notifs,
      aiInsightsEnabled: ai,
    ));
  }

  Future<void> toggleTheme(bool isDark) async {
    await SecureStorageService.setThemeMode(isDark);
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> toggleNotifications(bool enabled) async {
    await SecureStorageService.setNotificationsEnabled(enabled);
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> toggleAiInsights(bool enabled) async {
    await SecureStorageService.setAiInsightsEnabled(enabled);
    emit(state.copyWith(aiInsightsEnabled: enabled));
  }
}
