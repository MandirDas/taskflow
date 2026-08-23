import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MotionPreference { system, reduced }

/// Duration options for the session inactivity timeout.
enum SessionTimeoutDuration {
  oneMinute(Duration(minutes: 1), '1 minute'),
  fiveMinutes(Duration(minutes: 5), '5 minutes'),
  fifteenMinutes(Duration(minutes: 15), '15 minutes'),
  thirtyMinutes(Duration(minutes: 30), '30 minutes'),
  never(Duration.zero, 'Never');

  const SessionTimeoutDuration(this.duration, this.label);
  final Duration duration;
  final String label;
}

class AppSettingsState extends Equatable {
  final ThemeMode themeMode;
  final MotionPreference motionPreference;
  final bool biometricEnabled;
  final SessionTimeoutDuration sessionTimeout;
  final Locale? locale;

  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.motionPreference = MotionPreference.system,
    this.biometricEnabled = false,
    this.sessionTimeout = SessionTimeoutDuration.never,
    this.locale,
  });

  bool get reduceMotion => motionPreference == MotionPreference.reduced;
  bool get hasSessionTimeout => sessionTimeout != SessionTimeoutDuration.never;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    MotionPreference? motionPreference,
    bool? biometricEnabled,
    SessionTimeoutDuration? sessionTimeout,
    Locale? Function()? locale,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      motionPreference: motionPreference ?? this.motionPreference,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      locale: locale != null ? locale() : this.locale,
    );
  }

  @override
  List<Object?> get props =>
      [themeMode, motionPreference, biometricEnabled, sessionTimeout, locale];
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  static const _themeKey = 'taskflow_theme_mode';
  static const _motionKey = 'taskflow_motion_preference';
  static const _biometricKey = 'taskflow_biometric_enabled';
  static const _sessionTimeoutKey = 'taskflow_session_timeout';
  static const _localeKey = 'taskflow_locale';

  final SharedPreferences preferences;

  AppSettingsCubit({required this.preferences}) : super(_load(preferences));

  static AppSettingsState _load(SharedPreferences preferences) {
    final themeName = preferences.getString(_themeKey);
    final motionName = preferences.getString(_motionKey);
    final biometric = preferences.getBool(_biometricKey) ?? false;
    final timeoutName = preferences.getString(_sessionTimeoutKey);
    final localeCode = preferences.getString(_localeKey);
    return AppSettingsState(
      themeMode: ThemeMode.values.firstWhere(
        (value) => value.name == themeName,
        orElse: () => ThemeMode.system,
      ),
      motionPreference: MotionPreference.values.firstWhere(
        (value) => value.name == motionName,
        orElse: () => MotionPreference.system,
      ),
      biometricEnabled: biometric,
      sessionTimeout: SessionTimeoutDuration.values.firstWhere(
        (value) => value.name == timeoutName,
        orElse: () => SessionTimeoutDuration.never,
      ),
      locale: localeCode != null ? Locale(localeCode) : null,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await preferences.setString(_themeKey, mode.name);
  }

  Future<void> setMotionPreference(MotionPreference preference) async {
    emit(state.copyWith(motionPreference: preference));
    await preferences.setString(_motionKey, preference.name);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    emit(state.copyWith(biometricEnabled: enabled));
    await preferences.setBool(_biometricKey, enabled);
  }

  Future<void> setSessionTimeout(SessionTimeoutDuration timeout) async {
    emit(state.copyWith(sessionTimeout: timeout));
    await preferences.setString(_sessionTimeoutKey, timeout.name);
  }

  /// Set the app locale. Pass null to follow system locale.
  Future<void> setLocale(Locale? locale) async {
    emit(state.copyWith(locale: () => locale));
    if (locale == null) {
      await preferences.remove(_localeKey);
    } else {
      await preferences.setString(_localeKey, locale.languageCode);
    }
  }
}
