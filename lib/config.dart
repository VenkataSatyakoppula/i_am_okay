class AppConfig {
  // TODO: Update this URL with current tunnel URL
  static const String apiUrl = 'http://10.0.2.2:5200/graphql';

  // Notification Settings
  static const int followUpReminderDelayMinutes = 10;
  static const int emergencySmsDelayMinutes = 25;

  /// Default country code for phone/SMS (e.g. "1" US). Backend treats missing as "1".
  static const String defaultPhoneExt = '1';
}
