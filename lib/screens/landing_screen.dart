import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:IamOkay/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/language_dropdown.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoLogin();
    });
  }

  Future<void> _checkAutoLogin() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    final biometricEnabled = await storage.read(key: 'biometric_enabled');
    final mobile = await storage.read(key: 'mobile_number');

    if (token == null || token.isEmpty || !mounted) return;

    // Small delay to let the UI render and animation start
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Valid token present and biometric not enabled → go to Home
    if (biometricEnabled != 'true') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      return;
    }

    // Biometric enabled → go to LoginScreen to trigger biometric auth
    if (mobile != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            initialMobileNumber: mobile,
            autoBiometric: true,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/landing_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay to ensure text readability
          Container(
            color: Colors.white.withValues(alpha: 0.3),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language dropdown - top right
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                      child: Consumer<LocaleProvider>(
                        builder: (context, localeProvider, _) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: const Color(0xFF1F4ED8),
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: const Color(0xFF333333),
                            ),
                          ),
                          child: LanguageDropdown(
                            localeProvider: localeProvider,
                            iconColor: const Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Logo
                  Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Image.asset(
                          'assets/icons/Logo.png',
                          height: 100, // Adjust height as needed to match previous icon size
                        ),
                      ),
                    ),
                  ),

              const SizedBox(height: 16),
              Center(
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return Text(
                      l10n?.welcomeMessage ?? 'Welcome to your personal safety companion.',
                      textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0, // Body text: 18-20
                    fontWeight: FontWeight.w400, // Regular (400)
                    color: Color(0xFF333333), // Secondary Text
                  ),
                    );
                  },
                ),
              ),
              const Spacer(),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return CustomButton(
                    text: l10n?.getStarted ?? 'Get Started',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                  );
                },
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return CustomButton(
                    text: l10n?.iAlreadyHaveAccount ?? 'I already have an account',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                backgroundColor: Colors.white, // White background
                textColor: const Color(0xFF1F4ED8), // Deep Blue text
                  );
                },
              ),
              const SizedBox(height: 32),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n?.poweredBy ?? 'Powered by'} ',
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                    'assets/icons/InfodatLogoTop.svg',
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                      Image.asset(
                        'assets/icons/Selltis_Logolockup.png',
                        height: 20,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ],
    ),
    );
  }
}
