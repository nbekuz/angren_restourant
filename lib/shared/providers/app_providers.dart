import 'package:eda_restaurant/core/constants/app_constants.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final settingsBoxProvider = Provider<Box<dynamic>>((ref) => _settingsBox());
final sessionBoxProvider = Provider<Box<dynamic>>((ref) => _sessionBox());

final prefsProvider = Provider<AppPrefs>((ref) {
  return AppPrefs(
    ref.watch(settingsBoxProvider),
    ref.watch(sessionBoxProvider),
  );
});

final localeProvider = StateProvider<Locale>((ref) {
  final code = ref.watch(prefsProvider).localeCode;
  return Locale(code ?? 'en');
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final value = ref.watch(prefsProvider).themeMode;
  return switch (value) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };
});

final authTokenProvider = StateProvider<String?>((ref) {
  return ref.watch(prefsProvider).authToken;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final token = ref.watch(authTokenProvider);
  return token != null && token.isNotEmpty;
});

final onboardingCompleteProvider = StateProvider<bool>((ref) {
  return ref.watch(prefsProvider).onboardingComplete;
});

final languageSelectedProvider = StateProvider<bool>((ref) {
  return ref.watch(prefsProvider).languageSelected;
});

final restaurantStatusProvider = StateProvider<RestaurantStatus>((ref) {
  final value = ref.watch(prefsProvider).restaurantStatus;
  return RestaurantStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => RestaurantStatus.open,
  );
});

final connectivityOnlineProvider = StateProvider<bool>((ref) => true);

Future<void> persistLocale(WidgetRef ref, Locale locale) async {
  ref.read(localeProvider.notifier).state = locale;
  ref.read(languageSelectedProvider.notifier).state = true;
  await ref.read(prefsProvider).setLocale(locale.languageCode);
  await ref.read(prefsProvider).setLanguageSelected(true);
}

Future<void> persistThemeMode(WidgetRef ref, ThemeMode mode) async {
  ref.read(themeModeProvider.notifier).state = mode;
  await ref.read(prefsProvider).setThemeMode(mode.name);
}

Future<void> persistRestaurantStatus(
  WidgetRef ref,
  RestaurantStatus status,
) async {
  ref.read(restaurantStatusProvider.notifier).state = status;
  await ref.read(prefsProvider).setRestaurantStatus(status.name);
}

Future<void> persistAuth(
  WidgetRef ref, {
  required String token,
  required String phone,
  required bool rememberMe,
}) async {
  ref.read(authTokenProvider.notifier).state = token;
  await ref.read(prefsProvider).setAuthToken(token);
  await ref.read(prefsProvider).setUserPhone(phone);
  await ref.read(prefsProvider).setRememberMe(rememberMe);
}

Future<void> clearAuth(WidgetRef ref) async {
  ref.read(authTokenProvider.notifier).state = null;
  await ref.read(prefsProvider).clearAuth();
}

class AppPrefs {
  const AppPrefs(this._settings, this._session);

  final Box<dynamic> _settings;
  final Box<dynamic> _session;

  String? get localeCode => _settings.get(StorageKeys.locale) as String?;
  String? get themeMode => _settings.get(StorageKeys.themeMode) as String?;
  String? get authToken => _session.get(StorageKeys.accessToken) as String?;
  String? get userPhone => _session.get(StorageKeys.userPhone) as String?;
  bool get rememberMe =>
      _settings.get(StorageKeys.rememberMe, defaultValue: true) as bool;
  bool get onboardingComplete =>
      _settings.get(StorageKeys.onboardingComplete, defaultValue: false)
          as bool;
  bool get languageSelected =>
      _settings.get(StorageKeys.languageSelected, defaultValue: false) as bool;
  String? get restaurantStatus =>
      _settings.get(StorageKeys.restaurantStatus) as String?;

  Future<void> setLocale(String value) =>
      _settings.put(StorageKeys.locale, value);
  Future<void> setThemeMode(String value) =>
      _settings.put(StorageKeys.themeMode, value);
  Future<void> setRememberMe(bool value) =>
      _settings.put(StorageKeys.rememberMe, value);
  Future<void> setOnboardingComplete(bool value) =>
      _settings.put(StorageKeys.onboardingComplete, value);
  Future<void> setLanguageSelected(bool value) =>
      _settings.put(StorageKeys.languageSelected, value);
  Future<void> setRestaurantStatus(String value) =>
      _settings.put(StorageKeys.restaurantStatus, value);
  Future<void> setUserPhone(String value) =>
      _session.put(StorageKeys.userPhone, value);
  Future<void> setAuthToken(String value) =>
      _session.put(StorageKeys.accessToken, value);

  Future<void> clearAuth() async {
    await _session.delete(StorageKeys.accessToken);
  }
}

Box<dynamic> _settingsBox() {
  return Hive.box<dynamic>(AppConstants.hiveBoxSettings);
}

Box<dynamic> _sessionBox() {
  return Hive.box<dynamic>(AppConstants.hiveBoxSession);
}
