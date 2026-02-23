import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
            const Text(
              'Effective Date: 02/20/2026',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'IamOkay is a personal safety check-in application provided and operated by Infodat (“we,” “our,” or “us”). This Privacy Policy explains how we collect, use, and share information in connection with the IamOkay mobile application. By using IamOkay, you consent to the practices described below.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Information We Collect',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• User Information: Name, phone number, email (if provided)\n'
              '• Emergency Contacts: Name and phone number of contacts designated by users\n'
              '• Location Data: Optional, if the user shares location during check-ins\n'
              '• App Usage Data: App usage, login times, check-in status',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'How We Use Your Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• To send emergency alerts to designated contacts if a user fails to check in on time\n'
              '• To provide app functionality and improve user experience\n'
              '• To communicate important messages regarding the app or services',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'SMS Messaging',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Emergency contacts may receive automated SMS messages when a user fails to check in as scheduled:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Message frequency varies depending on emergency alerts\n'
              '• Message & data rates may apply\n'
              '• Recipients can reply STOP at any time to opt out or HELP for assistance',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Consent & Double Opt-In',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Users adding emergency contacts must confirm the contact’s consent within the app via a required checkbox\n'
              '• Emergency contacts receive a confirmation SMS requiring them to reply YES before receiving any automated alerts',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Information Sharing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• We do not sell personal data\n'
              '• We may use third-party providers (e.g., SMS services, cloud storage) to operate the app',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Data Retention',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'We retain personal data only as long as necessary to provide the service or comply with legal obligations.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(text: 'For questions about this Privacy Policy or your data, contact us at: '),
                  TextSpan(
                    text: 'info@infodatinc.com',
                    style: const TextStyle(
                      color: Colors.blue,
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