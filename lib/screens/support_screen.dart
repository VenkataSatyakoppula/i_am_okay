import 'package:flutter/material.dart';
import 'package:IamOkay/l10n/app_localizations.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.support,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
            _SectionHeading(title: AppLocalizations.of(context)!.contactUs),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.supportContactText,
              style: const TextStyle(fontSize: 16.0, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: AppLocalizations.of(context)!.faq),
            const SizedBox(height: 12),
            _FAQItem(
              question: AppLocalizations.of(context)!.faqAddContactQuestion,
              answer: AppLocalizations.of(context)!.faqAddContactAnswer,
            ),
            _FAQItem(
              question: AppLocalizations.of(context)!.faqMissCheckInQuestion,
              answer: AppLocalizations.of(context)!.faqMissCheckInAnswer,
            ),
            _FAQItem(
              question: AppLocalizations.of(context)!.faqPauseRemindersQuestion,
              answer: AppLocalizations.of(context)!.faqPauseRemindersAnswer,
            ),
            _FAQItem(
              question: AppLocalizations.of(context)!.faqLocationQuestion,
              answer: AppLocalizations.of(context)!.faqLocationAnswer,
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: AppLocalizations.of(context)!.resources),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.supportResources,
              style: const TextStyle(fontSize: 16.0, height: 1.6, color: Color(0xFF333333)),
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

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F4ED8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 15.0,
              height: 1.5,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
