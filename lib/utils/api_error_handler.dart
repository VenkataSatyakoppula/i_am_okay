import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:IamOkay/l10n/app_localizations.dart';
import '../screens/landing_screen.dart';
import '../services/graphql_service.dart';
import '../services/notification_service.dart';

/// Handles API errors. When API fails and user has internet, shows a dialog
/// prompting logout and login again.
class ApiErrorHandler {
  static const _storage = FlutterSecureStorage();

  /// Call when an API error occurs. If user has internet, shows re-login dialog.
  static Future<void> handle(BuildContext context, Object error) async {
    if (!context.mounted) return;

    final hasInternet = await _checkConnectivity();
    if (!hasInternet) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.pleaseCheckConnection ?? 'Please check your internet connection and try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Has internet but API failed - prompt re-login
    await _showReLoginDialog(context);
  }

  static Future<bool> _checkConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      // connectivity_plus 6.x returns List<ConnectivityResult>; none means no connectivity
      return !(results.length == 1 && results.first == ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  static Future<void> _showReLoginDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.connectionIssue ?? 'Connection issue'),
        content: Text(
          l10n?.logoutAndSignInAgain ?? 'We\'re having trouble connecting. Please log out and log in again to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F4ED8),
            ),
            child: Text(l10n?.logoutAndSignInButton ?? 'Log out and sign in again'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _logout(context);
    }
  }

  static Future<void> _logout(BuildContext context) async {
    await NotificationService().cancelAllNotifications();
    await GraphQLService.clearUserCache();
    await _storage.deleteAll();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
        (route) => false,
      );
    }
  }
}
