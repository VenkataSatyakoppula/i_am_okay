import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import 'graphql_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // Handle notification tap
      },
    );
  }

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

  Future<void> scheduleDailyNotificationFromDate(tz.TZDateTime startDate) async {
    // Always cancel existing notifications to ensure we don't have duplicates or stale times
    await cancelAllNotifications();

    // iOS: plugin must have requested permission or scheduled notifications may not fire
    if (Platform.isIOS) {
      await requestPermissions();
    }

    // Schedule main notifications
    await _scheduleNotifications(startDate, 0, 'daily_checkin', 'Daily Check-in', 'Time to check in! Are you okay?');
    
    // Schedule follow-up reminders
    final reminderDate = startDate.add(const Duration(minutes: AppConfig.followUpReminderDelayMinutes));
    await _scheduleNotifications(reminderDate, 100, 'checkin_reminder', 'Check-in Reminder', 'You haven\'t checked in yet. Is everything okay?');

    // Schedule emergency SMS tasks on the backend from startDate (e.g. when user sets/changes daily reminder time).
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final startDateIso = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}T00:00:00Z';
      await GraphQLService.scheduleEmergencySmsTasks(
        days: 7,
        timeZone: timeZoneInfo?.identifier ?? 'UTC',
        checkInOffset: AppConfig.emergencySmsDelayMinutes,
        startDate: startDateIso,
      );
    } catch (e) {
      // Failed to schedule emergency SMS tasks
    }
  }

  /// Number of days to schedule ahead (one-off per day on both Android and iOS).
  static const int _scheduleDaysAhead = 15;

  Future<void> _scheduleNotifications(tz.TZDateTime startDate, int startId, String type, String title, String body) async {
    try {
      final notificationDetails = const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_checkin_channel_v3',
          'Daily Check-in',
          channelDescription: 'Reminds you to check in daily',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      for (int i = 0; i < _scheduleDaysAhead; i++) {
        final tz.TZDateTime notificationDate = startDate.add(Duration(days: i));
        final payload = jsonEncode({
          'type': type,
          'scheduledDate': notificationDate.toIso8601String(),
        });
        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            id: startId + i,
            title: title,
            body: body,
            scheduledDate: notificationDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: payload,
          );
        } catch (e) {
          // Schedule failed for day $i
        }
      }
    } catch (e) {
      // Error scheduling notification
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
      await flutterLocalNotificationsPlugin.cancelAll();
    }

    try {
      await GraphQLService.clearEmergencySmsTasks();
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      await GraphQLService.scheduleEmergencySmsTasks(
        days: 7,
        timeZone: timeZoneInfo?.identifier ?? 'UTC',
        checkInOffset: AppConfig.emergencySmsDelayMinutes,
        startDate: startDateIso,
      );
    } catch (e) {
      // Failed to update emergency SMS tasks
    }

    if (inPreReminderWindow) {
      // Reschedule daily_checkin and checkin_reminder from tomorrow.
      final reminderDate = tomorrowCheckIn.add(const Duration(minutes: AppConfig.followUpReminderDelayMinutes));
      await _scheduleNotifications(tomorrowCheckIn, 0, 'daily_checkin', 'Daily Check-in', 'Time to check in! Are you okay?');
      await _scheduleNotifications(reminderDate, 100, 'checkin_reminder', 'Check-in Reminder', 'You haven\'t checked in yet. Is everything okay?');
    }
    // 11:05–11:10 or after: only emergencySMS was cleared/rescheduled above; do not touch local notifications.
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    try {
      await GraphQLService.clearEmergencySmsTasks();
    } catch (e) {
      // Failed to clear (e.g. logged out)
    }
  }
}
