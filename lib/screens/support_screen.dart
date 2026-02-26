import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Support',
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
            _SectionHeading(title: 'Contact Us'),
            const SizedBox(height: 12),
            const Text(
              'Email: support@iamokay.app\n'
              'We typically respond within 24–48 hours.',
              style: TextStyle(fontSize: 16.0, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'Frequently Asked Questions'),
            const SizedBox(height: 12),
            _FAQItem(
              question: 'How do I add an emergency contact?',
              answer: 'Go to the Contacts tab, tap Add Contact, and enter their name, relation, and phone number. You can add up to 3 emergency contacts.',
            ),
            _FAQItem(
              question: 'What happens if I miss a check-in?',
              answer: 'If you don’t check in by your reminder time, your emergency contacts may receive an alert so they can reach out to you.',
            ),
            _FAQItem(
              question: 'Can I pause my reminders?',
              answer: 'Yes. On the Home screen, use "Pause Reminder" to temporarily stop check-in reminders for 24 hours, 2 days, 1 week, or a custom date.',
            ),
            _FAQItem(
              question: 'Is my location shared?',
              answer: 'Location is only included in emergency alerts if you have granted location permission and it is enabled in your settings.',
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'Resources'),
            const SizedBox(height: 12),
            const Text(
              '• Privacy Policy (see Settings)\n'
              '• App version and updates via your device’s store',
              style: TextStyle(fontSize: 16.0, height: 1.6, color: Color(0xFF333333)),
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
