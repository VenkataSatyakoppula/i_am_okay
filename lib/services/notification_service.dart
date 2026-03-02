import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import 'background_service.dart';

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
      debugPrint('Local timezone successfully set to: $timeZoneName');
    } catch (e) {
      debugPrint('Error setting local timezone: $e');
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
        debugPrint('Notification tapped: ${notificationResponse.payload}');
        
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
      debugPrint('Can schedule exact alarms: $canSchedule');
      
      if (canSchedule == false) {
        await androidImplementation.requestExactAlarmsPermission();
      }
    }
    
    final granted = (iosGranted ?? false) || (androidGranted ?? false);
    debugPrint('Permissions granted: $granted (iOS: $iosGranted, Android: $androidGranted)');
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

    // Schedule Emergency SMS Task Sequence (starting from the first scheduled date)
    // The background service will handle the 15-day loop logic.
    await BackgroundService().scheduleEmergencySmsSequence(startDate);
  }

  /// Number of days to schedule ahead on iOS (one-off notifications; matchDateTimeComponents is unreliable on iOS).
  static const int _iosScheduleDays = 15;

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

      if (Platform.isIOS) {
        // iOS: schedule multiple one-off notifications (matchDateTimeComponents can be unreliable on iOS).
        for (int i = 0; i < _iosScheduleDays; i++) {
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
            debugPrint('iOS schedule notification $type day $i: $e');
          }
        }
        debugPrint('Scheduled $_iosScheduleDays days of $type notifications on iOS');
      } else {
        // Android: one recurring daily notification.
        final payload = jsonEncode({
          'type': type,
          'scheduledDate': startDate.toIso8601String(),
        });
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: startId,
          title: title,
          body: body,
          scheduledDate: startDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      }
    } catch (e) {
      debugPrint('ERROR scheduling notification ($type): $e');
    }
  }

  Future<void> completeDailyCheckIn(TimeOfDay checkInTime) async {
    // 1. Cancel follow-up reminders (id 100 on Android; 100..129 on iOS).
    for (int i = 0; i < _iosScheduleDays; i++) {
      await flutterLocalNotificationsPlugin.cancel(id: 100 + i);
    }
    // Cancel any pending emergency SMS task since user checked in
    await BackgroundService().cancelEmergencySms();
    
    debugPrint('Cancelled check-in reminders and emergency task');

    // 2. Reschedule reminders starting from TOMORROW
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime todayCheckIn = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      checkInTime.hour,
      checkInTime.minute,
    );
    
    // Start from tomorrow
    final tz.TZDateTime tomorrowCheckIn = todayCheckIn.add(const Duration(days: 1));
    final reminderDate = tomorrowCheckIn.add(const Duration(minutes: AppConfig.followUpReminderDelayMinutes));
    
    await _scheduleNotifications(reminderDate, 100, 'checkin_reminder', 'Check-in Reminder', 'You haven\'t checked in yet. Is everything okay?');

    // Schedule Emergency SMS Sequence for tomorrow
    // We start the sequence from tomorrow's check-in time.
    await BackgroundService().scheduleEmergencySmsSequence(tomorrowCheckIn);
  }


  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    await BackgroundService().cancelEmergencySms();
  }
}
