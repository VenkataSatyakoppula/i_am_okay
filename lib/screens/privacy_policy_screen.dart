import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/icons/Logo.png',
                    height: 100,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'IamOkay Privacy Policy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Powered by',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/InfodatLogoTop.svg',
                        height: 40,
                      ),
                      const SizedBox(width: 20),
                      Image.asset(
                        'assets/icons/Selltis_Logolockup.png',
                        height: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _SectionHeading(title: 'Effective Date: 02/20/2026'),
            const SizedBox(height: 12),
            const Text(
              'IamOkay is a personal safety check-in application provided and operated by Infodat ("we," "our," or "us"). This Privacy Policy explains how we collect, use, and share information in connection with the IamOkay mobile application. By using IamOkay, you consent to the practices described below.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'Information We Collect'),
            const SizedBox(height: 10),
            const Text(
              '• User Information: Name, phone number, email (if provided)\n'
              '• Emergency Contacts: Name and phone number of contacts designated by users\n'
              '• Location Data: Optional, if the user shares location during check-ins\n'
              '• App Usage Data: App usage, login times, check-in status',
              style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'How We Use Your Information'),
            const SizedBox(height: 10),
            const Text(
              '• To send emergency alerts to designated contacts if a user fails to check in on time\n'
              '• To provide app functionality and improve user experience\n'
              '• To communicate important messages regarding the app or services',
              style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'SMS Messaging'),
            const SizedBox(height: 10),
            const Text(
              'Emergency contacts may receive automated SMS messages when a user fails to check in as scheduled:',
              style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Message frequency varies depending on emergency alerts\n'
              '• Message & data rates may apply\n'
              '• Recipients can reply STOP at any time to opt out or HELP for assistance',
              style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'Consent & Double Opt-In'),
            const SizedBox(height: 10),
            const Text(
              '• Users adding emergency contacts must confirm the contact\'s consent within the app via a required checkbox\n'
              '• Emergency contacts receive a confirmation SMS requiring them to reply YES before receiving any automated alerts',
              style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'Information Sharing'),
            const SizedBox(height: 10),
            const Text(
              '• We do not sell personal data\n'
              '• We may use third-party providers (e.g., SMS services, cloud storage) to operate the app',
              style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'Data Retention'),
            const SizedBox(height: 10),
            const Text(
              'We retain personal data only as long as necessary to provide the service or comply with legal obligations.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: 'Contact Us'),
            const SizedBox(height: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF333333)),
                children: [
                  TextSpan(text: 'For questions about this Privacy Policy or your data, contact us at: '),
                  TextSpan(
                    text: 'info@infodatinc.com',
                    style: TextStyle(
                      color: Color(0xFF1F4ED8),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                '© 2026 Infodat. All rights reserved.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
