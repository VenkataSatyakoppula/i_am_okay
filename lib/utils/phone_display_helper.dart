import '../config.dart';

/// Formats a phone number for display with optional country code (e.g. "+1 (898) 989-8990").
String formatPhoneDisplay(String phone, [String? phoneExt]) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  final ext = phoneExt ?? AppConfig.defaultPhoneExt;
  final prefix = ext.isNotEmpty ? '+$ext ' : '';
  if (digits.length == 10) {
    return '$prefix(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 10)}';
  }
  return prefix.isNotEmpty ? '$prefix$phone' : phone;
}

/// Formats a phone number for use in an input field (national number only, no country code).
/// Use when country is selected separately (e.g. "(716) 431-9625").
String formatPhoneNational(String phone) {
  String digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11 && digits.startsWith('1')) {
    digits = digits.substring(1);
  }
  if (digits.length == 10) {
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 10)}';
  }
  return digits.isNotEmpty ? digits : phone;
}

/// Returns E.164-style number for tel: links: +{phoneExt}{digits}.
String toE164(String phone, [String? phoneExt]) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  final ext = phoneExt ?? AppConfig.defaultPhoneExt;
  return '+$ext$digits';
}
