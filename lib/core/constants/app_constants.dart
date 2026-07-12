abstract final class AppConstants {
  static const String appName = 'Angren Deliver Partner';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://demo-api.eda.restaurant/v1',
  );
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://demo-socket.eda.restaurant',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const int otpLength = 4;
  static const int otpResendSeconds = 60;
  static const int orderAcceptSeconds = 45;

  static const String hiveBoxSettings = 'eda_restaurant_settings';
  static const String hiveBoxCache = 'eda_restaurant_cache';
  static const String hiveBoxSession = 'eda_restaurant_session';
}

abstract final class StorageKeys {
  static const String locale = 'locale';
  static const String themeMode = 'theme_mode';
  static const String accessToken = 'access_token';
  static const String userPhone = 'user_phone';
  static const String rememberMe = 'remember_me';
  static const String onboardingComplete = 'onboarding_complete';
  static const String languageSelected = 'language_selected';
  static const String restaurantStatus = 'restaurant_status';
  static const String pushToken = 'push_token';
  static const String pushEnabled = 'push_enabled';
  static const String documentsStatus = 'documents_status';
  static const String lastSyncAt = 'last_sync_at';
}
