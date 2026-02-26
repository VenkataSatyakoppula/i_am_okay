import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
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
            _SectionHeading(title: 'Our Mission'),
            const SizedBox(height: 8),
            const Text(
              'IamOkay is dedicated to keeping you connected with the people who care about you. We help users stay safe by enabling simple daily check-ins and automated emergency alerts to designated contacts when needed.',
              style: TextStyle(fontSize: 16.0, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'How It Works'),
            const SizedBox(height: 8),
            const Text(
              'Set a daily reminder time that works for you. Check in when prompted to let your emergency contacts know you\'re okay. If you miss a check-in, your contacts can be notified so they can reach out and ensure your wellbeing.',
              style: TextStyle(fontSize: 16.0, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'Features'),
            const SizedBox(height: 8),
            const Text(
              '• Daily check-in reminders\n'
              '• Up to 3 emergency contacts\n'
              '• Optional location sharing for alerts\n'
              '• Pause reminders when needed\n'
              '• Simple, privacy-focused design',
              style: TextStyle(fontSize: 16.0, height: 1.6, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'Version'),
            const SizedBox(height: 8),
            const Text(
              'IamOkay v1.0.0',
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
