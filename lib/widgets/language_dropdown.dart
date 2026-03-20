import 'package:flutter/material.dart';
import 'package:IamOkay/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

/// Language dropdown for the app bar. Place in AppBar.actions.
class LanguageDropdown extends StatelessWidget {
  final LocaleProvider localeProvider;
  /// Optional icon color. If null, uses AppBar foreground or white.
  final Color? iconColor;

  const LanguageDropdown({
    super.key,
    required this.localeProvider,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = localeProvider.locale;
    final color = iconColor ??
        Theme.of(context).appBarTheme.foregroundColor ??
        Colors.white;

    return PopupMenuButton<String>(
      icon: Icon(Icons.language, color: color),
      tooltip: 'Language',
      onSelected: (String code) {
        localeProvider.setLocale(Locale(code));
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, color: Color(0xFF1F4ED8), size: 20),
              if (currentLocale.languageCode == 'en') const SizedBox(width: 8),
              Text(l10n.languageEnglish),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'fr',
          child: Row(
            children: [
              if (currentLocale.languageCode == 'fr')
                const Icon(Icons.check, color: Color(0xFF1F4ED8), size: 20),
              if (currentLocale.languageCode == 'fr') const SizedBox(width: 8),
              Text(l10n.languageFrench),
            ],
          ),
        ),
      ],
    );
  }
}
