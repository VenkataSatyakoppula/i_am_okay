import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../config.dart';
import '../l10n/app_localizations.dart';
import 'check_in_service.dart';
import 'graphql_service.dart';

const String _localeKey = 'app_locale';

/// Called by the plugin when user taps a notification action while app is in background.
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  if (response.actionId == 'dismiss') {
    NotificationService.runCheckInFromDismiss(response.payload);
  }
  // open_app: app will be brought to foreground; onDidReceiveNotificationResponse
  // will fire and onOpenAppFromNotification will navigate to HomeScreen.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Called when user taps Dismiss on the alarm notification (optional, for showing snackbar).
  static void Function(bool success)? onCheckInFromDismiss;

  /// Called when user taps Open App on the alarm notification. App should navigate to HomeScreen.
  static void Function()? onOpenAppFromNotification;

  /// Returns true if [payload] is for daily_checkin or checkin_reminder alarm.
  static bool isAlarmPayload(String? payload) {
    if (payload == null || payload.isEmpty) return false;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>?;
      final type = map?['type'] as String?;
      return type == 'daily_checkin' || type == 'checkin_reminder';
    } catch (_) {
      return false;
    }
  }

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone().then((tz) => tz.identifier);
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Timezone init failed
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // Set to false so iOS does not show the permission prompt at app launch
    // (e.g. on landing screen). Request later on the Permissions screen.
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId == _kDismissActionId) {
      stopIosAlarmLoop();
      _dismissAlarmNotification(response.id);
      runCheckInFromDismiss(response.payload).then((success) {
        onCheckInFromDismiss?.call(success);
      });
    } else {
      if (isAlarmPayload(response.payload)) {
        startIosAlarmLoop();
      }
      if (response.actionId == _kOpenAppActionId) {
        onOpenAppFromNotification?.call();
      }
    }
  }

  /// Dismisses the alarm notification. On Android, use tag so the correct notification is removed.
  Future<void> _dismissAlarmNotification(int? notificationId) async {
    if (notificationId == null) return;
    await _cancelAlarmNotification(notificationId);
  }

  /// Public so main.dart can dismiss when app was launched from Dismiss action (e.g. terminated).
  static Future<void> dismissAlarmNotification(int? notificationId) async {
    if (notificationId == null) return;
    await _instance._cancelAlarmNotification(notificationId);
  }

  Future<void> _cancelAlarmNotification(int notificationId) async {
    try {
      if (Platform.isAndroid) {
        await flutterLocalNotificationsPlugin.cancel(
          id: notificationId,
          tag: _kAlarmNotificationTag,
        );
      } else {
        await flutterLocalNotificationsPlugin.cancel(id: notificationId);
      }
    } catch (_) {
      try {
        await flutterLocalNotificationsPlugin.cancel(id: notificationId);
      } catch (_) {}
    }
  }

  /// Runs the same flow as HomeScreen._handleCheckIn: createCheckIn + completeDailyCheckIn.
  /// Call when user taps Dismiss on alarm. [payload] may be null (e.g. action intent doesn't carry it).
  static Future<bool> runCheckInFromDismiss(String? payload) async {
    try {
      TimeOfDay? checkInTime;
      if (payload != null && payload.isNotEmpty) {
        final map = jsonDecode(payload) as Map<String, dynamic>?;
        final type = map?['type'] as String?;
        final scheduledDate = map?['scheduledDate'] as String?;
        if (type == 'daily_checkin') {
          checkInTime = CheckInService.parseCheckInTimeFromScheduledDate(scheduledDate);
        } else if (type == 'checkin_reminder') {
          checkInTime = CheckInService.parseCheckInTimeFromReminderScheduledDate(scheduledDate);
        }
      }
      if (checkInTime == null) {
        checkInTime = await CheckInService.getCheckInTimeFromUser();
      }
      return await CheckInService.performCheckIn(checkInTime);
    } catch (_) {
      return false;
    }
  }

  static const String _kDismissActionId = 'dismiss';
  static const String _kOpenAppActionId = 'open_app';
  /// Tag for alarm notifications so we can cancel them reliably on Android.
  static const String _kAlarmNotificationTag = 'daily_checkin_alarm';
  static const MethodChannel _platformChannel =
      MethodChannel('com.infodat.iamokay/full_screen_intent');
  static const MethodChannel _iosAlarmAudioChannel =
      MethodChannel('com.infodat.iamokay/ios_alarm_audio');

  /// iOS: loops [preview.caf] for 60s (notification API cannot loop past ~30s).
  static Future<void> startIosAlarmLoop() async {
    if (!Platform.isIOS) return;
    try {
      await _iosAlarmAudioChannel.invokeMethod<void>('startLoopingAlarm');
    } catch (_) {}
  }

  static Future<void> stopIosAlarmLoop() async {
    if (!Platform.isIOS) return;
    try {
      await _iosAlarmAudioChannel.invokeMethod<void>('stopLoopingAlarm');
    } catch (_) {}
  }
  static String? _cachedAlarmUri;
  static bool _alarmUriTried = false;

  Future<bool> requestPermissions() async {
    bool? iosGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool? androidGranted = await androidImplementation?.requestNotificationsPermission();
    if (androidImplementation != null) {
        final canSchedule = await androidImplementation.canScheduleExactNotifications();
      if (canSchedule == false) {
        await androidImplementation.requestExactAlarmsPermission();
      }
    }
    
    final granted = (iosGranted ?? false) || (androidGranted ?? false);
    return granted;
  }

  /// Returns whether notifications are enabled. On iOS uses the local notifications
  /// plugin so the status matches what we actually requested; permission_handler
  /// can report the wrong state on iOS after the user grants.
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isIOS) {
      final options = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return options?.isEnabled ?? false;
    }
    return false;
  }

  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    // Always cancel existing notifications to ensure we don't have duplicates or stale times
    await cancelAllNotifications();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleDailyNotificationFromDate(scheduledDate);
  }

  Future<AppLocalizations> _getLocalizations() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    final locale = (code == 'fr') ? const Locale('fr') : const Locale('en');
    return lookupAppLocalizations(locale);
  }

  Future<void> scheduleDailyNotificationFromDate(tz.TZDateTime startDate) async {
    // Always cancel existing notifications to ensure we don't have duplicates or stale times
    await cancelAllNotifications();

    // iOS: plugin must have requested permission or scheduled notifications may not fire
    if (Platform.isIOS) {
      await requestPermissions();
    }

    final l10n = await _getLocalizations();
    // Schedule main notifications
    await _scheduleNotifications(startDate, 0, 'daily_checkin', l10n.notificationDailyCheckInTitle, l10n.notificationDailyCheckInBody);
    
    // Schedule follow-up reminders
    final reminderDate = startDate.add(const Duration(minutes: AppConfig.followUpReminderDelayMinutes));
    await _scheduleNotifications(reminderDate, 100, 'checkin_reminder', l10n.notificationCheckInReminderTitle, l10n.notificationCheckInReminderBody);

    // Schedule emergency SMS tasks on the backend from startDate (e.g. when user sets/changes daily reminder time).
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final startDateIso = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}T00:00:00Z';
      await GraphQLService.scheduleEmergencySmsTasks(
        days: 7,
        timeZone: timeZoneInfo.identifier ?? 'UTC',
        checkInOffset: AppConfig.emergencySmsDelayMinutes,
        startDate: startDateIso,
      );
    } catch (e) {
      // Failed to schedule emergency SMS tasks
    }
  }

  /// Number of days to schedule ahead (one-off per day on both Android and iOS).
  static const int _scheduleDaysAhead = 15;

  /// After this duration the alarm notification is auto-cancelled (stops ringing).
  static const int _alarmRingDurationMinutes = 1;

  /// Vibration pattern for ~1 min: 800ms on, 400ms off, repeated (same duration as alarm ring).
  static Int64List _alarmVibrationPattern() {
    const int vibrateMs = 800;
    const int pauseMs = 400;
    const int totalSeconds = _alarmRingDurationMinutes * 60;
    const int cycleMs = vibrateMs + pauseMs;
    final int repeatCount = (totalSeconds * 1000) ~/ cycleMs;
    final List<int> pattern = [0];
    for (int i = 0; i < repeatCount; i++) {
      pattern.add(vibrateMs);
      pattern.add(pauseMs);
    }
    return Int64List.fromList(pattern);
  }

  /// Alarm-style notification for daily check-in: full-screen intent, ringing alarm sound, strong vibration, Dismiss action.
  static NotificationDetails _alarmNotificationDetails(String? alarmUri, AppLocalizations l10n) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_checkin_alarm_channel_v3',
        l10n.notificationAlarmChannelName,
        channelDescription: l10n.notificationAlarmChannelDesc,
        tag: _kAlarmNotificationTag,
        importance: Importance.max,
        priority: Priority.max,
        channelBypassDnd: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        playSound: true,
        sound: alarmUri != null && alarmUri.isNotEmpty
            ? UriAndroidNotificationSound(alarmUri)
            : null,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
        // Strong alarm pattern: vibrate 800ms, pause 400ms, repeated for ~1 min (matches alarm ring duration)
        vibrationPattern: _alarmVibrationPattern(),
      ),
      // iOS: bundled preview.caf for background delivery (max ~30s); foreground uses AlarmLoopController 60s loop.
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        sound: 'preview.caf',
      ),
    );
  }

  static NotificationDetails _reminderNotificationDetails(AppLocalizations l10n) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_checkin_channel_v3',
        l10n.notificationChannelName,
        channelDescription: l10n.notificationChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> _scheduleNotifications(tz.TZDateTime startDate, int startId, String type, String title, String body) async {
    try {
      final l10n = await _getLocalizations();
      // Fetch system alarm URI once (Android) for ringing alarm sound
      if ((type == 'daily_checkin' || type == 'checkin_reminder') &&
          Platform.isAndroid &&
          !_alarmUriTried) {
        _alarmUriTried = true;
        try {
          _cachedAlarmUri =
              await _platformChannel.invokeMethod<String>('getAlarmUri');
        } catch (_) {
          _cachedAlarmUri = null;
        }
      }
      final notificationDetails = (type == 'daily_checkin' || type == 'checkin_reminder')
          ? _alarmNotificationDetails(_cachedAlarmUri, l10n)
          : _reminderNotificationDetails(l10n);

      for (int i = 0; i < _scheduleDaysAhead; i++) {
        final tz.TZDateTime notificationDate = startDate.add(Duration(days: i));
        final payload = jsonEncode({
          'type': type,
          'scheduledDate': notificationDate.toIso8601String(),
        });
        final notificationId = startId + i;
        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            id: notificationId,
            title: title,
            body: body,
            scheduledDate: notificationDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            payload: payload,
          );
          if (Platform.isAndroid &&
              (type == 'daily_checkin' || type == 'checkin_reminder')) {
            final cancelAtMillis = notificationDate.millisecondsSinceEpoch +
                _alarmRingDurationMinutes * 60 * 1000;
            try {
              await _platformChannel.invokeMethod<bool>('scheduleAlarmCancel', {
                'notificationId': notificationId,
                'tag': _kAlarmNotificationTag,
                'cancelAtMillis': cancelAtMillis,
              });
            } catch (_) {
              // Ignore if scheduling cancel fails
            }
          }
        } catch (e) {
          debugPrint('Schedule failed for $type on day $i: $e');
        }
      }
    } catch (e) {
      debugPrint('Error scheduling $type notifications: $e');
    }
  }

  Future<void> completeDailyCheckIn(TimeOfDay checkInTime) async {
    // Time windows (e.g. checkIn 11:00, reminder 11:05, emergencySms 11:10):
    // - Before checkInTime: do not clear anything.
    // - Between checkInTime and reminder (11:00–11:05): clear checkin_reminder + emergencySMS, schedule from tomorrow.
    // - Between reminder and emergencySms (11:05–11:10) or after: clear only emergencySMS, schedule from tomorrow.
    final now = tz.TZDateTime.now(tz.local);
    final todayCheckInTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      checkInTime.hour,
      checkInTime.minute,
    );
    if (now.isBefore(todayCheckInTime)) {
      return;
    }

    final reminderTime = todayCheckInTime.add(const Duration(minutes: AppConfig.followUpReminderDelayMinutes));

    // Tomorrow's date in ISO 8601 format for backend startDate (e.g. 2025-03-01T00:00:00Z).
    final tomorrowCheckIn = todayCheckInTime.add(const Duration(days: 1));
    final startDateIso = '${tomorrowCheckIn.year}-${tomorrowCheckIn.month.toString().padLeft(2, '0')}-${tomorrowCheckIn.day.toString().padLeft(2, '0')}T00:00:00Z';

    final bool inPreReminderWindow = now.isBefore(reminderTime);

    if (inPreReminderWindow) {
      // 11:00–11:05: cancel local notifications FIRST so the pending follow-up reminder is removed immediately (before it can fire).
      await stopIosAlarmLoop();
      await flutterLocalNotificationsPlugin.cancelAll();
    }

    try {
      await GraphQLService.clearEmergencySmsTasks();
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      await GraphQLService.scheduleEmergencySmsTasks(
        days: 7,
        timeZone: timeZoneInfo.identifier ?? 'UTC',
        checkInOffset: AppConfig.emergencySmsDelayMinutes,
        startDate: startDateIso,
      );
    } catch (e) {
      // Failed to update emergency SMS tasks
    }

    if (inPreReminderWindow) {
      final l10n = await _getLocalizations();
      // Reschedule daily_checkin and checkin_reminder from tomorrow.
      final reminderDate = tomorrowCheckIn.add(const Duration(minutes: AppConfig.followUpReminderDelayMinutes));
      await _scheduleNotifications(tomorrowCheckIn, 0, 'daily_checkin', l10n.notificationDailyCheckInTitle, l10n.notificationDailyCheckInBody);
      await _scheduleNotifications(reminderDate, 100, 'checkin_reminder', l10n.notificationCheckInReminderTitle, l10n.notificationCheckInReminderBody);
    }
    // 11:05–11:10 or after: only emergencySMS was cleared/rescheduled above; do not touch local notifications.
  }

  Future<void> cancelAllNotifications() async {
    await stopIosAlarmLoop();
    await flutterLocalNotificationsPlugin.cancelAll();
    try {
      await GraphQLService.clearEmergencySmsTasks();
    } catch (e) {
      // Failed to clear (e.g. logged out)
    }
  }
}
