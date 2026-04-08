/// Backend [User.preferredLanguage]: `"en"` | `"fr"`. Anything else → treat as English for UI.
String normalizePreferredLanguageCode(String? raw) {
  final t = raw?.trim().toLowerCase();
  if (t == 'fr') return 'fr';
  return 'en';
}

/// App locale code to send on register / update (only en/fr supported for alerts).
String preferredLanguageFromUiLocale(String languageCode) {
  return languageCode == 'fr' ? 'fr' : 'en';
}
