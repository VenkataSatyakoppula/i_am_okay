import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:IamOkay/l10n/app_localizations.dart';
import '../widgets/custom_button.dart';
import '../services/graphql_service.dart';
import '../services/notification_service.dart';
import '../models/user_model.dart';
import '../utils/api_error_handler.dart';
import '../utils/phone_display_helper.dart';
import 'landing_screen.dart';
import 'about_us_screen.dart';
import 'daily_reminder_screen.dart';
import 'edit_profile_screen.dart';
import 'support_screen.dart';
import 'privacy_policy_screen.dart';
import 'permission_screen.dart';
import 'biometric_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    // Show cached user immediately so no spinner when navigating to Settings
    final cachedUser = await GraphQLService.getCachedUser();
    if (mounted && cachedUser != null) {
      setState(() {
        _user = cachedUser;
        _isLoading = false;
      });
    }

    final userId = await _storage.read(key: 'user_id');
    final mobileNumber = await _storage.read(key: 'mobile_number');

    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _user == null ? AppLocalizations.of(context)!.userNotFoundPleaseLogin : null;
        });
      }
      return;
    }

    // If no cache, show minimal user so we don't block the UI
    if (mounted && _user == null) {
      setState(() {
        _user = User(id: userId, mobileNumber: mobileNumber ?? '');
        _isLoading = false;
      });
    }

    // Fetch full profile from network and update
    try {
      final user = await GraphQLService.getUser(userId);
      if (mounted && user != null) {
        setState(() {
          _user = user;
        });
      }
    } catch (e) {
      if (mounted) await ApiErrorHandler.handle(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1F4ED8),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4ED8),
                  ),
                  child: Text(AppLocalizations.of(context)!.goToLogin),
                ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.failedToLoadProfile),
            const SizedBox(height: 24),
            CustomButton(
              text: AppLocalizations.of(context)!.logOut,
              onPressed: _logout,
              backgroundColor: Colors.red,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 20),
        _buildSectionTitle(AppLocalizations.of(context)!.userInformation),
        _buildInfoCard(),
        const SizedBox(height: 20),
        _buildSectionTitle(AppLocalizations.of(context)!.settings),
        _buildSettingsCard(),
        const SizedBox(height: 20),
        _buildSectionTitle(AppLocalizations.of(context)!.actions),
        _buildActionsCard(),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final fullName =
        "${_user?.name?.firstName ?? ''} ${_user?.name?.lastName ?? ''}".trim();
    final displayName = fullName.isNotEmpty ? fullName : AppLocalizations.of(context)!.user;
    final alias = _user?.name?.alias?.trim();
    final hasAlias = alias != null && alias.isNotEmpty;

    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF1F4ED8).withAlpha((255 * 0.1).toInt()),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Color(0xFF1F4ED8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        if (hasAlias) ...[
          const SizedBox(height: 4),
          Text(
            alias,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          formatPhoneDisplay(_user?.mobileNumber ?? '', _user?.phoneExt),
          style: const TextStyle(
            fontSize: 18.0,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final addr = _user?.address;
    final addressParts = addr != null ? [
      addr.address1,
      addr.address2,
      addr.city,
      addr.state,
      addr.zipCode
    ] : [];
    
    final addressStr = addressParts
        .where((s) => s != null && s.isNotEmpty)
        .join(", ");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          if (_user?.email != null && _user!.email!.isNotEmpty)
            _buildProfileOption(
              icon: Icons.email_outlined,
              title: AppLocalizations.of(context)!.email,
              subtitle: _user!.email!,
            ),
          if (addressStr.isNotEmpty)
            _buildProfileOption(
              icon: Icons.location_on_outlined,
              title: AppLocalizations.of(context)!.address,
              subtitle: addressStr,
            ),
          _buildProfileOption(
            icon: Icons.edit,
            title: AppLocalizations.of(context)!.editProfile,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(user: _user!),
                ),
              );
              if (result == true) {
                _fetchUser();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildProfileOption(
            icon: Icons.timer_outlined,
            title: AppLocalizations.of(context)!.dailyReminder,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const DailyReminderScreen(isOnboarding: false))),
          ),
          _buildProfileOption(
            icon: Icons.notifications_active_outlined,
            title: AppLocalizations.of(context)!.permissions,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PermissionScreen(fromSettings: true),
              ),
            ),
          ),
          _buildProfileOption(
            icon: Icons.fingerprint,
            title: AppLocalizations.of(context)!.biometric,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BiometricSetupScreen(fromSettings: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildProfileOption(
            icon: Icons.info_outline,
            title: AppLocalizations.of(context)!.aboutUs,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen())),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildProfileOption(
            icon: Icons.support_agent,
            title: AppLocalizations.of(context)!.support,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SupportScreen())),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildProfileOption(
            icon: Icons.privacy_tip_outlined,
            title: AppLocalizations.of(context)!.privacyPolicy,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen())),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildProfileOption(
            icon: Icons.logout,
            title: AppLocalizations.of(context)!.logOut,
            onTap: _logout,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor ?? const Color(0xFF1F4ED8)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Color(0xFF666666))) : null,
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
    );
  }

  Future<void> _logout() async {
    // Cancel all notifications on logout
    await NotificationService().cancelAllNotifications();
    // Clear in-memory/disk user cache and all secure storage (auth_token, user_id,
    // last_scheduled_reminder_time, etc.) so the next user gets a clean state
    await GraphQLService.clearUserCache();
    await _storage.deleteAll();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
        (route) => false,
      );
    }
  }
}
