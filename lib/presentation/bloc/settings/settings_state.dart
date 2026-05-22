import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool aiInsightsEnabled;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.notificationsEnabled = false,
    this.aiInsightsEnabled = true,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? aiInsightsEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      aiInsightsEnabled: aiInsightsEnabled ?? this.aiInsightsEnabled,
    );
  }

  @override
  List<Object?> get props => [themeMode, notificationsEnabled, aiInsightsEnabled];
}
