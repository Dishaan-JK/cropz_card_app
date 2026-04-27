class PocketbaseConfig {
  static const String baseUrl = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: 'http://127.0.0.1:8090',
  );

  static const String usersCollection = 'users';
  static const String cardsCollection = 'cards';

  static String get requestOtpPath =>
      '/api/collections/$usersCollection/request-otp';
  static String get authWithOtpPath =>
      '/api/collections/$usersCollection/auth-with-otp';
  static String get cardsRecordsPath =>
      '/api/collections/$cardsCollection/records';

  static bool get isConfigured => baseUrl.trim().isNotEmpty;
}
