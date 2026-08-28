abstract final class AppConstants {
  static const String appName = 'Angren Deliver Partner';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/v1',
  );
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://localhost:3000',
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
