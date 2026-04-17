class AppConfig {
  // TODO: Update this URL with current tunnel URL
  static const String apiUrl = 'https://amok.dev.selltis.com/graphql';

  // Notification Settings
  static const int followUpReminderDelayMinutes = 10;
  static const int emergencySmsDelayMinutes = 25;

  /// Fallback E.164 country calling code when the app has no number/extension (often "1").
  /// Prefer per-user [phoneExt] from the API; change this if your primary market differs.
  static const String defaultPhoneExt = '1';
}
