import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/custom_button.dart';
import '../services/graphql_service.dart';
import '../services/notification_service.dart';
import '../models/user_model.dart';
import 'landing_screen.dart';
import 'about_us_screen.dart';
import 'daily_reminder_screen.dart';
import 'edit_profile_screen.dart';
import 'support_screen.dart';
import 'privacy_policy_screen.dart';
import 'permission_screen.dart';

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
          _errorMessage = _user == null ? "User not found locally. Please login again." : null;
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
      debugPrint("Failed to fetch full profile: $e");
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
              if (_errorMessage!.contains("login again"))
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4ED8),
                  ),
                  child: const Text('Go to Login'),
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
            const Text("Failed to load profile. You may be offline."),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Log Out',
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
        _buildSectionTitle("User Information"),
        _buildInfoCard(),
        const SizedBox(height: 20),
        _buildSectionTitle("Settings"),
        _buildSettingsCard(),
        const SizedBox(height: 20),
        _buildSectionTitle("Actions"),
        _buildActionsCard(),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final fullName =
        "${_user?.name?.firstName ?? ''} ${_user?.name?.lastName ?? ''}".trim();
    final displayName = fullName.isNotEmpty ? fullName : "User";
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
            alias!,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          _formatPhoneNumber(_user?.mobileNumber ?? ''),
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
              title: "Email",
              subtitle: _user!.email!,
            ),
          if (addressStr.isNotEmpty)
            _buildProfileOption(
              icon: Icons.location_on_outlined,
              title: "Address",
              subtitle: addressStr,
            ),
          _buildProfileOption(
            icon: Icons.edit,
            title: "Edit Profile",
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
            title: "Daily Reminder",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const DailyReminderScreen(isOnboarding: false))),
          ),
          _buildProfileOption(
            icon: Icons.notifications_active_outlined,
            title: "Permissions",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PermissionScreen(fromSettings: true),
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
            title: "About Us",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen())),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildProfileOption(
            icon: Icons.support_agent,
            title: "Support",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SupportScreen())),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildProfileOption(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen())),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildProfileOption(
            icon: Icons.logout,
            title: "Log Out",
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

  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    // Check if it starts with 1 (US country code) and has 11 digits, remove the 1
    if (digits.length == 11 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }

    // If we have 10 digits, format it
    if (digits.length == 10) {
      return '+1 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    // Fallback to original or return empty if input was empty
    return phone;
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
