import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:IamOkay/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../widgets/custom_button.dart';
import 'landing_screen.dart';

/// Shown on first app launch to let the user select their preferred language.
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.language,
                size: 80,
                color: Color(0xFF1F4ED8),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.selectLanguage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.selectLanguageDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: l10n.languageEnglish,
                onPressed: () => _selectAndContinue(context, localeProvider, const Locale('en')),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: l10n.languageFrench,
                onPressed: () => _selectAndContinue(context, localeProvider, const Locale('fr')),
                backgroundColor: Colors.white,
                textColor: const Color(0xFF1F4ED8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAndContinue(BuildContext context, LocaleProvider localeProvider, Locale locale) {
    localeProvider.setLocale(locale);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
    );
  }
}
