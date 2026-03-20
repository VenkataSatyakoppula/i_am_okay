import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'app_locale';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _hasSelectedLanguage = false;
  bool _isLoaded = false;

  Locale get locale => _locale;

  /// True when the user has previously selected a language (not first launch).
  bool get hasSelectedLanguage => _hasSelectedLanguage;

  /// True when locale has been loaded from storage (avoids flash on returning users).
  bool get isLoaded => _isLoaded;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null && (code == 'en' || code == 'fr')) {
      _locale = Locale(code);
      _hasSelectedLanguage = true;
    } else {
      // Use device locale for display until user selects
      final deviceLocale = ui.PlatformDispatcher.instance.locale;
      _locale = (deviceLocale.languageCode == 'fr') ? const Locale('fr') : const Locale('en');
      _hasSelectedLanguage = false;
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale && _hasSelectedLanguage) return;
    _locale = locale;
    _hasSelectedLanguage = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }
}
