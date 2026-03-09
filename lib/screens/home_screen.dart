import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/user_model.dart';
import '../services/check_in_service.dart';
import '../services/graphql_service.dart';
import '../services/notification_service.dart';
import '../widgets/loading_overlay.dart';
import 'emergency_contact_screen.dart';
import 'daily_reminder_screen.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/bottom_nav_item.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _userRole;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    const storage = FlutterSecureStorage();
    _userRole = await storage.read(key: 'user_role');
    _userId = await storage.read(key: 'user_id');
    setState(() {});
  }

  List<Widget> get _screens {
    if (_userRole == 'contact') {
      return [
        HistoryScreen(contactId: _userId),
        const SettingsScreen(),
      ];
    }
    return [
      const HomeContent(),
      const HistoryScreen(),
      const EmergencyContactScreen(isOnboarding: false),
      const SettingsScreen(),
    ];
  }

  String get _currentTitle {
    if (_userRole == 'contact') {
      switch (_currentIndex) {
        case 0:
          return 'History';
        case 1:
          return 'Settings';
        default:
          return 'History';
      }
    }
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'History';
      case 2:
        return 'Emergency Contacts';
      case 3:
        return 'Settings';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {

    final List<BottomNavItem> navItems = _userRole == 'contact'
        ? [
            BottomNavItem(icon: Icons.history, label: 'History'),
            BottomNavItem(icon: Icons.settings, label: 'Settings'),
          ]
        : [
            BottomNavItem(icon: Icons.home, label: 'Home'),
            BottomNavItem(icon: Icons.history, label: 'History'),
            BottomNavItem(icon: Icons.contact_phone, label: 'Contacts'),
            BottomNavItem(icon: Icons.settings, label: 'Settings'),
          ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F4ED8),
        title: Text(
          _currentTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavbar(
        items: navItems,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _storage = const FlutterSecureStorage();
  String? _userName;
  String? _userAlias;
  String? _reminderTime;
  TimeOfDay? _checkInTimeOfDay;
  bool _isPaused = false;
  DateTime? _pausedUntil;
  /// Prevents showing placeholder header until cache has been read.
  bool _hasInitialLoad = false;
  /// Last check-in date (yyyy-MM-dd). Used for optimistic UI after check-in.
  String? _lastCheckInDate;
  /// True when the server has a check-in record for today. Success state requires this.
  bool _hasCheckInTodayFromServer = false;
  Timer? _countdownTimer;
  /// True until initial user + check-in data has been fetched (avoids showing wrong button state).
  bool _isLoadingInitialData = true;

  void _applyUserToState(User user) {
    final firstName = user.name?.firstName ?? '';
    final lastName = user.name?.lastName ?? '';
    _userName = '$firstName $lastName'.trim();
    _userAlias = user.name?.alias;

    if (_userName!.isEmpty) {
      _userName = _userAlias;
      _userAlias = null;
    } else if (_userAlias == _userName) {
      _userAlias = null;
    }

    if (user.reminderSettings != null) {
      _isPaused = user.reminderSettings!.isPaused ?? false;
      _pausedUntil = user.reminderSettings!.pausedUntil;

      if (user.reminderSettings!.checkInTime != null) {
        final timeParts = user.reminderSettings!.checkInTime!.split(':');
        if (timeParts.length == 2) {
          final time = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          _checkInTimeOfDay = time;
          _reminderTime = time.format(context);
        }
      }
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final lastCheckIn = await _storage.read(key: 'last_check_in_date');
      // Show cached user immediately so no placeholder flash when navigating to Home
      final cachedUser = await GraphQLService.getCachedUser();
      if (mounted) {
        setState(() {
          _hasInitialLoad = true;
          _lastCheckInDate = lastCheckIn;
          if (cachedUser != null) {
            _applyUserToState(cachedUser);
          }
        });
      }

      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        if (mounted) setState(() => _isLoadingInitialData = false);
        return;
      }

      final user = await GraphQLService.getUser(userId);
      if (mounted && user != null) {
        setState(() {
          _applyUserToState(user);
        });
      }

      // Check if there is a check-in log for today at or after the user's set reminder time (success state)
      try {
        final checkIns = await GraphQLService.getCheckInsByContactId(userId);
        final now = DateTime.now();
        final todayStr = CheckInService.todayDateString();
        DateTime? todayAtReminder;
        if (user?.reminderSettings?.checkInTime != null) {
          final parts = user!.reminderSettings!.checkInTime!.split(':');
          if (parts.length == 2) {
            todayAtReminder = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
          }
        }
        final hasValidCheckInToday = checkIns.any((c) {
          final dt = c.timestamp ?? c.createdAt;
          if (dt == null) return false;
          final local = dt.toLocal();
          final dateStr =
              '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
          if (dateStr != todayStr) return false;
          // Only count as "checked in for today" if check-in time is at or after user's set reminder time
          if (todayAtReminder != null && local.isBefore(todayAtReminder)) {
            return false;
          }
          return true;
        });
        if (mounted) {
          setState(() {
            _hasCheckInTodayFromServer = hasValidCheckInToday;
          });
        }
      } catch (_) {
        // Keep _hasCheckInTodayFromServer as-is on error
      }

      if (user != null) {
        // Only schedule if reminder time is set and not already scheduled (avoids lag on iOS)
        if (user.reminderSettings != null && user.reminderSettings!.checkInTime != null) {
          final timeParts = user.reminderSettings!.checkInTime!.split(':');
          if (timeParts.length == 2) {
            final time = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
            final isPaused = user.reminderSettings!.isPaused ?? false;
            final pausedUntil = user.reminderSettings!.pausedUntil;

            if (isPaused && (pausedUntil == null || !DateTime.now().isAfter(pausedUntil))) {
              // Still within pause period: ensure notifications are scheduled from pausedUntil (covers first-time load or no schedule yet).
              if (pausedUntil != null && _checkInTimeOfDay != null) {
                final localPausedUntil = pausedUntil.toLocal();
                var scheduledDate = tz.TZDateTime(
                  tz.local,
                  localPausedUntil.year,
                  localPausedUntil.month,
                  localPausedUntil.day,
                  time.hour,
                  time.minute,
                );
                if (localPausedUntil.hour > time.hour ||
                    (localPausedUntil.hour == time.hour && localPausedUntil.minute > time.minute)) {
                  scheduledDate = scheduledDate.add(const Duration(days: 1));
                }
                await NotificationService().scheduleDailyNotificationFromDate(scheduledDate);
              }
            } else {
              final storedTime = await _storage.read(key: 'last_scheduled_reminder_time');
              final currentTimeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              if (storedTime != currentTimeStr) {
                await NotificationService().scheduleDailyNotification(time);
                await _storage.write(key: 'last_scheduled_reminder_time', value: currentTimeStr);
              }
            }
          }
        }
      }
    } catch (e) {
      // Error fetching user data
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  String _getRelativeTime(DateTime? until) {
    if (until == null) return '';
    final now = DateTime.now();
    final localUntil = until.toLocal();
    final diff = localUntil.difference(now);
    
    if (diff.isNegative) return 'soon';
    
    if (diff.inDays > 1) {
      return '${diff.inDays} days';
    } else if (diff.inDays == 1) {
      return '1 day';
    } else if (diff.inHours > 1) {
      return '${diff.inHours} hours';
    } else if (diff.inHours == 1) {
      return '1 hour';
    } else if (diff.inMinutes > 1) {
      return '${diff.inMinutes} minutes';
    } else {
      return 'less than a minute';
    }
  }

  void _showResumeConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resume Reminder?'),
        content: const Text('Would you like to start receiving daily reminders again?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF333333),
            ),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateReminderStatus(false, null);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1F4ED8),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Yes, Resume'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckIn() async {
    LoadingOverlay.show(context);
    TimeOfDay? checkInTime = _checkInTimeOfDay;
    if (checkInTime == null && _reminderTime != null) {
      try {
        final parts = _reminderTime!.split(':');
        if (parts.length == 2) {
          checkInTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (_) {}
    }
    final success = await CheckInService.performCheckIn(checkInTime);
    if (mounted) {
      LoadingOverlay.hide(context);
      if (success) {
        setState(() {
          _lastCheckInDate = CheckInService.todayDateString();
          _hasCheckInTodayFromServer = true;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Check-in successful! You are okay!'
                : 'Failed to check in. Please try again.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _fetchUserData();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Show success state only when: user has set time, there is a check-in log for today, and now >= today's reminder time.
  bool get _checkedInToday {
    if (_checkInTimeOfDay == null || !_hasCheckInTodayFromServer) {
      return false;
    }
    final now = DateTime.now();
    final todayCheckInTime = DateTime(
      now.year,
      now.month,
      now.day,
      _checkInTimeOfDay!.hour,
      _checkInTimeOfDay!.minute,
    );
    return now.isAfter(todayCheckInTime) || now.isAtSameMomentAs(todayCheckInTime);
  }

  /// True when current time is before today's reminder time (button should be disabled).
  bool get _isBeforeReminderTimeToday {
    if (_checkInTimeOfDay == null) return false;
    final now = DateTime.now();
    final todayAtReminder = DateTime(
      now.year,
      now.month,
      now.day,
      _checkInTimeOfDay!.hour,
      _checkInTimeOfDay!.minute,
    );
    return now.isBefore(todayAtReminder);
  }

  DateTime? _getNextCheckInDateTime() {
    if (_checkInTimeOfDay == null) return null;
    final now = DateTime.now();
    final todayAtReminder = DateTime(
      now.year,
      now.month,
      now.day,
      _checkInTimeOfDay!.hour,
      _checkInTimeOfDay!.minute,
    );
    if (now.isBefore(todayAtReminder) || now.isAtSameMomentAs(todayAtReminder)) {
      return todayAtReminder;
    }
    return todayAtReminder.add(const Duration(days: 1));
  }

  String _getNextCheckInCountdown() {
    final next = _getNextCheckInDateTime();
    if (next == null) return '';
    final diff = next.difference(DateTime.now());
    if (diff.isNegative) return 'Next reminder tomorrow at $_reminderTime';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    if (hours > 0) {
      return 'Next reminder in ${hours}h ${minutes}m ${seconds}s';
    }
    if (minutes > 0) {
      return 'Next reminder in ${minutes}m ${seconds}s';
    }
    return 'Next reminder in ${seconds}s';
  }

  Future<void> _updateReminderStatus(bool isPaused, DateTime? pausedUntil) async {
    LoadingOverlay.show(context);
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) throw Exception("User ID not found");

      await GraphQLService.updateUser(userId, {
        'reminderSettings': {
          'isPaused': isPaused,
          'pausedUntil': pausedUntil?.toUtc().toIso8601String(),
        }
      });

      if (mounted) {
        LoadingOverlay.hide(context);
        setState(() {
          _isPaused = isPaused;
          _pausedUntil = pausedUntil;
        });

        // Handle notification rescheduling
        if (isPaused) {
          await _storage.delete(key: 'last_scheduled_reminder_time');
          if (pausedUntil != null && _checkInTimeOfDay != null) {
            final localPausedUntil = pausedUntil.toLocal();
            var scheduledDate = tz.TZDateTime(
              tz.local,
              localPausedUntil.year,
              localPausedUntil.month,
              localPausedUntil.day,
              _checkInTimeOfDay!.hour,
              _checkInTimeOfDay!.minute,
            );

            // if pausedUntil hour and minute (converted to local timezone) is more than the check-in time then schedule it to next day.
            if (localPausedUntil.hour > _checkInTimeOfDay!.hour ||
                (localPausedUntil.hour == _checkInTimeOfDay!.hour &&
                    localPausedUntil.minute > _checkInTimeOfDay!.minute)) {
              scheduledDate = scheduledDate.add(const Duration(days: 1));
            }
            NotificationService().scheduleDailyNotificationFromDate(scheduledDate);
          } else {
            // If we can't reschedule, at least cancel everything.
            NotificationService().cancelAllNotifications();
          }
        } else {
          // Resuming
          if (_checkInTimeOfDay != null) {
            await NotificationService().scheduleDailyNotification(_checkInTimeOfDay!);
            final timeStr = '${_checkInTimeOfDay!.hour.toString().padLeft(2, '0')}:${_checkInTimeOfDay!.minute.toString().padLeft(2, '0')}';
            await _storage.write(key: 'last_scheduled_reminder_time', value: timeStr);
          }
        }

        String message;
        if (isPaused) {
          final dateStr = pausedUntil?.toString().split(' ')[0] ?? '';
          message = 'Reminder paused until $dateStr';
        } else {
          message = 'Reminder resumed';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPauseReminderOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pause Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(context, '24 hours', duration: const Duration(hours: 24)),
            _buildOption(context, '2 days', duration: const Duration(days: 2)),
            _buildOption(context, '1 week', duration: const Duration(days: 7)),
            _buildOption(context, 'Custom', isCustom: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF333333),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String text,
      {bool isCustom = false, Duration? duration}) {
    return ListTile(
      title: Text(text),
      onTap: () async {
        Navigator.pop(context); // Close dialog first
        
        DateTime? untilDate;
        
        if (isCustom) {
          // Show date picker or time picker
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) {
            untilDate = picked;
          }
        } else if (duration != null) {
          untilDate = DateTime.now().add(duration);
        }

        if (untilDate != null) {
          _updateReminderStatus(true, untilDate);
        }
      },
    );
  }

  Widget _buildPauseResumeButton() {
    if (_isPaused) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_arrow, color: Color(0xFF666666)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showResumeConfirmDialog,
            child: const Text(
              'Resume Reminder',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F4ED8), // Link color
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    }
    return TextButton.icon(
      onPressed: _showPauseReminderOptions,
      icon: const Icon(Icons.pause, color: Color(0xFF666666)),
      label: const Text(
        'Pause Reminder',
        style: TextStyle(color: Color(0xFF666666), fontSize: 16),
      ),
    );
  }

  Widget _buildMainActionButton() {
    // Paused: show paused state
    if (_isPaused) {
      return GestureDetector(
        onTap: _showResumeConfirmDialog,
        child: _buildButtonContainer(
          color: Colors.grey[400] ?? Colors.grey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pause, color: Colors.white, size: 48),
            const SizedBox(height: 8),
            const Text(
              'Paused',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Resumes in ${_getRelativeTime(_pausedUntil)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
    }

    // No reminder time set: button disabled, prompt to set reminder
    if (_checkInTimeOfDay == null) {
      return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DailyReminderScreen()),
          );
          if (mounted) _fetchUserData();
        },
        child: _buildButtonContainer(
          color: Colors.white,
          borderColor: Colors.grey.shade300,
          showRipples: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off_outlined,
                  size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'I am Okay',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Set a daily reminder to check in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Checked in today: static success button + countdown below
    if (_checkedInToday) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You have checked in for Today!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3D6BFE),
                  Color(0xFF1F4ED8),
                  Color(0xFF1539A0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F4ED8).withAlpha(80),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF1539A0).withAlpha(40),
                  blurRadius: 12,
                  spreadRadius: -2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 36,
                    color: Color(0xFF1F4ED8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getNextCheckInCountdown(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
        ],
      );
    }

    // Time set, not checked in today, but current time is before reminder time: disabled button + countdown
    if (_isBeforeReminderTimeToday) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButtonContainer(
            color: Colors.white,
            borderColor: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/landing_logo.svg',
                  height: 70,
                  colorFilter: ColorFilter.mode(
                    Colors.grey.shade400,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'I am Okay',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getNextCheckInCountdown(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
        ],
      );
    }

    // Time set, not checked in today, now >= reminder time: normal tappable pulsing button
    return GestureDetector(
      onTap: _handleCheckIn,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double offset = index / 3.0;
                final double value = (_controller.value + offset) % 1.0;
                return Transform.scale(
                  scale: 1.0 + (value * 0.5),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1F4ED8)
                          .withAlpha((255 * 0.3 * (1 - value)).toInt()),
                    ),
                  ),
                );
              },
            );
          }),
          _buildButtonContainer(
            color: Colors.white,
            borderColor: const Color(0xFF1F4ED8).withAlpha((255 * 0.5).toInt()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/landing_logo.svg',
                  height: 70,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1F4ED8),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'I am Okay',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F4ED8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContainer({
    required Widget child,
    required Color color,
    Color? borderColor,
    bool showRipples = true,
    VoidCallback? onTap,
  }) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.0)
            : null,
        boxShadow: [
          BoxShadow(
            color: (color == Colors.grey[400]
                    ? Colors.grey
                    : color == const Color(0xFF2E7D32)
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF1F4ED8))
                .withAlpha((255 * 0.2).toInt()),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildHeader() {
    if (!_hasInitialLoad) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: SizedBox(height: 100),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_userName != null && _userName!.isNotEmpty)
            Text(
              'Hi, $_userName${_userAlias != null && _userAlias!.isNotEmpty ? ' ($_userAlias)' : ''}',
              style: const TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          const SizedBox(height: 4),
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 24),
          if (_reminderTime != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_active, color: Color(0xFF1F4ED8), size: 20),
                  const SizedBox(width: 12),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF333333),
                        ),
                        children: [
                          const TextSpan(text: "Daily check-in at "),
                          TextSpan(
                            text: _reminderTime,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DailyReminderScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F4ED8)
                    .withAlpha((255 * 0.1).toInt()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                        color: const Color(0xFF1F4ED8)
                            .withAlpha((255 * 0.3).toInt())),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_alert, color: Color(0xFF1F4ED8), size: 20),
                    const SizedBox(width: 12),
                    const Flexible(
                      child: Text(
                        'Set a Daily Reminder',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F4ED8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: _isLoadingInitialData
                    ? const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          color: Color(0xFF1F4ED8),
                          strokeWidth: 3,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMainActionButton(),
                          if (_checkInTimeOfDay != null) ...[
                            const SizedBox(height: 60),
                            _buildPauseResumeButton(),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
