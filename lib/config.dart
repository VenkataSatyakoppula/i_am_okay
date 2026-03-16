class AppConfig {
  // TODO: Update this URL with current tunnel URL
  static const String apiUrl = 'https://jhclxnt3-5200.usw3.devtunnels.ms/graphql';

  // Notification Settings
  static const int followUpReminderDelayMinutes = 1;
  static const int emergencySmsDelayMinutes = 2;

  /// Default country code for phone/SMS (e.g. "1" US). Backend treats missing as "1".
  static const String defaultPhoneExt = '1';
}
