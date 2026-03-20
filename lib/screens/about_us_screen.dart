import 'package:flutter/material.dart';
import 'package:IamOkay/l10n/app_localizations.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.aboutUs,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1F4ED8),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeading(title: AppLocalizations.of(context)!.ourMission),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.aboutUsMission,
              style: TextStyle(fontSize: 16.0, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: AppLocalizations.of(context)!.howItWorks),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.aboutUsHowItWorks,
              style: TextStyle(fontSize: 16.0, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: AppLocalizations.of(context)!.features),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.aboutUsFeatures,
              style: TextStyle(fontSize: 16.0, height: 1.6, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: AppLocalizations.of(context)!.version),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.appVersion,
              style: TextStyle(fontSize: 16.0, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F4ED8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
