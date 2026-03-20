import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:IamOkay/l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/language_selection_screen.dart';
import 'services/check_in_service.dart';
import 'services/notification_service.dart';
import 'providers/locale_provider.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.onCheckInFromDismiss = (bool success) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          rootScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(
                success ? l10n.checkInSuccessful : l10n.checkInFailedFromNotification,
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    });
  };
  NotificationService.onOpenAppFromNotification = () {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    });
  };
  await NotificationService().init();

  // Handle app opened from alarm (full-screen intent or notification tap)
  final launchDetails = await NotificationService().flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails();
  final launchedByNotification = launchDetails?.didNotificationLaunchApp ?? false;
  final initialResponse = launchDetails?.notificationResponse;

  if (launchedByNotification) {
    if (initialResponse != null && initialResponse.actionId == 'dismiss') {
      await NotificationService.dismissAlarmNotification(initialResponse.id);
      final success = await NotificationService.runCheckInFromDismiss(
        initialResponse.payload,
      );
      NotificationService.onCheckInFromDismiss?.call(success);
    }
    final shouldOpenHome = initialResponse == null ||
        initialResponse.actionId == 'open_app' ||
        NotificationService.isAlarmPayload(initialResponse.payload);
    if (shouldOpenHome) {
      // Open HomeScreen when alarm rings (full-screen intent) or notification tap
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      });
    }
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'IAmOkay',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // White
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F4ED8), // Deep Blue
          primary: const Color(0xFF1F4ED8),
          surface: const Color(0xFFFFFFFF),
        ),
        fontFamily: 'Roboto', // Default flutter font, but explicit is good. Or just rely on default.
        textTheme: const TextTheme(
          // Main heading: 28–34
          displayLarge: TextStyle(
            fontSize: 34.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
          displayMedium: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
          // Section title: 22–26
          titleLarge: TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
          titleMedium: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
          // Body text: 18–20
          bodyLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
            color: Color(0xFF000000),
          ),
          bodyMedium: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
            color: Color(0xFF333333), // Secondary text color for body medium often makes sense
          ),
          // Button text: 18–22
          labelLarge: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFFFFFF),
          ),
        ),
        useMaterial3: true,
      ),
      home: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          if (!localeProvider.isLoaded) {
            return const Scaffold(
              backgroundColor: Color(0xFFFFFFFF),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF1F4ED8)),
              ),
            );
          }
          if (localeProvider.hasSelectedLanguage) {
            return const LandingScreen();
          }
          return const LanguageSelectionScreen();
        },
      ),
    );
  }
}
