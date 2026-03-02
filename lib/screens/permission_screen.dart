import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_button.dart';
import '../services/notification_service.dart';
import 'biometric_setup_screen.dart';
import 'home_screen.dart';

class PermissionScreen extends StatefulWidget {
  /// When true, screen is opened from Settings: show back button and pop on Continue.
  final bool fromSettings;

  const PermissionScreen({super.key, this.fromSettings = false});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  bool _notificationGranted = false;
  bool _locationGranted = false;
  bool _exactAlarmGranted = false;

  bool get _allRequiredPermissionsGranted {
    return _notificationGranted && (!Platform.isAndroid || _exactAlarmGranted);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _checkPermissions();
      if (!mounted) return;
      // Do not auto-request on load: let the user see the screen and tap "Grant Permissions".
      // Auto-requesting on iOS can immediately open Settings, which is disorienting.
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.locationWhenInUse.status;
    final exactAlarmStatus = Platform.isAndroid 
        ? await Permission.scheduleExactAlarm.status 
        : PermissionStatus.granted;

    // On iOS, permission_handler often reports notification status incorrectly after
    // the user grants; use the local notifications plugin so the UI reflects reality.
    final bool notificationGranted = Platform.isIOS
        ? await NotificationService().areNotificationsEnabled()
        : (await Permission.notification.status).isGranted;

    if (mounted) {
      setState(() {
        _notificationGranted = notificationGranted;
        _locationGranted = locationStatus.isGranted;
        _exactAlarmGranted = exactAlarmStatus.isGranted;
      });

      if (_allRequiredPermissionsGranted && !widget.fromSettings) {
        _navigateToNext();
      }
    }
  }

  Future<void> _requestPermissions() async {
    // Request Notifications
    if (!_notificationGranted) {
      final status = await Permission.notification.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
    // iOS: plugin must also request so scheduled notifications can fire
    if (Platform.isIOS) {
      await NotificationService().requestPermissions();
    }

    // Request Location
    if (!_locationGranted) {
      final status = await Permission.locationWhenInUse.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }

    // Request Exact Alarm (Android only)
    if (Platform.isAndroid && !_exactAlarmGranted) {
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }

    await _checkPermissions();
  }

  Future<void> _navigateToNext() async {
    const storage = FlutterSecureStorage();
    final biometricEnabled = await storage.read(key: 'biometric_enabled');

    if (!mounted) return;

    if (biometricEnabled != null && biometricEnabled == 'true') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BiometricSetupScreen()),
      );
    }
  }

  void _onContinueOrBack() {
    if (widget.fromSettings) {
      Navigator.of(context).pop();
    } else {
      _navigateToNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: widget.fromSettings
          ? AppBar(
              backgroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF000000)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Center(
                child: SvgPicture.asset(
                  'assets/icons/landing_logo.svg',
                  height: 80,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1F4ED8),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Permissions Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'To ensure your safety and provide the best experience, we need access to the following permissions:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 40),
              
              // Notification Permission Item
              _buildPermissionItem(
                icon: Icons.notifications_active_outlined,
                title: 'Notifications',
                description: 'To remind you to check in daily and ensure you are okay.',
                isGranted: _notificationGranted,
              ),
              
              const SizedBox(height: 24),
              
              // Location Permission Item
              _buildPermissionItem(
                icon: Icons.location_on_outlined,
                title: 'Location (Optional)',
                description: 'To include your current location in emergency alerts sent to your contacts.',
                isGranted: _locationGranted,
              ),

              if (Platform.isAndroid) ...[
                const SizedBox(height: 24),
                // Exact Alarm Permission Item
                _buildPermissionItem(
                  icon: Icons.alarm,
                  title: 'Alarms',
                  description: 'To schedule precise reminders and safety checks.',
                  isGranted: _exactAlarmGranted,
                ),
              ],

              const Spacer(),

              if (!_allRequiredPermissionsGranted)
                CustomButton(
                  text: 'Grant Permissions',
                  onPressed: _requestPermissions,
                ),
              
              const SizedBox(height: 16),
              
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  // Always allow continue: on iOS notification status can be wrong
                  // even when permission was granted; don't block the user
                  if (!_allRequiredPermissionsGranted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'You can enable permissions later in Settings if needed.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  _onContinueOrBack();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isGranted ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isGranted ? Colors.green : const Color(0xFF666666),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                  if (isGranted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
