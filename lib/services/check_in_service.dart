import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import '../config.dart';
import 'graphql_service.dart';
import 'notification_service.dart';

/// Performs a check-in (API + clearing/rescheduling notifications).
/// Used by the home screen button and by the alarm "Dismiss" action.
class CheckInService {
  static const _storage = FlutterSecureStorage();

  /// Performs check-in: creates check-in via API and completes daily check-in (clears reminders).
  /// [checkInTime] is used for completeDailyCheckIn; if null, only createCheckIn is done.
  /// Returns true on success, false on failure.
  static Future<bool> performCheckIn(TimeOfDay? checkInTime) async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) return false;

      Map<String, double>? locationData;
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            final position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
              ),
            );
            locationData = {
              'lat': position.latitude,
              'lng': position.longitude,
            };
          }
        }
      } catch (_) {
        // Continue without location
      }

      final Map<String, dynamic> checkInPayload = {
        'userId': userId,
        'status': 'OK',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'metadata': {
          'source': 'app',
          'deviceInfo': 'mobile',
        },
      };
      if (locationData != null) {
        checkInPayload['location'] = locationData;
      }

      await GraphQLService.createCheckIn(checkInPayload);

      if (checkInTime != null) {
        await NotificationService().completeDailyCheckIn(checkInTime);
      }

      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await _storage.write(key: 'last_check_in_date', value: dateStr);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Today's date as yyyy-MM-dd (local). Used to compare with last_check_in_date.
  static String todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Parses [scheduledDateIso] (e.g. from notification payload) to [TimeOfDay].
  /// Returns null if parsing fails.
  static TimeOfDay? parseCheckInTimeFromScheduledDate(String? scheduledDateIso) {
    if (scheduledDateIso == null || scheduledDateIso.isEmpty) return null;
    try {
      final dt = DateTime.parse(scheduledDateIso);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return null;
    }
  }

  /// For follow-up reminder payload: scheduledDate is the reminder time (e.g. 11:05).
  /// Returns the user's check-in time (e.g. 11:00) by subtracting followUpReminderDelayMinutes.
  static TimeOfDay? parseCheckInTimeFromReminderScheduledDate(String? scheduledDateIso) {
    if (scheduledDateIso == null || scheduledDateIso.isEmpty) return null;
    try {
      final dt = DateTime.parse(scheduledDateIso)
          .subtract(Duration(minutes: AppConfig.followUpReminderDelayMinutes));
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return null;
    }
  }

  /// Fetches the logged-in user's reminder check-in time from the API.
  /// Use as fallback when notification payload is missing (e.g. action button tap).
  static Future<TimeOfDay?> getCheckInTimeFromUser() async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) return null;
      final user = await GraphQLService.getUser(userId);
      final timeStr = user?.reminderSettings?.checkInTime;
      if (timeStr == null || timeStr.isEmpty) return null;
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (_) {
      return null;
    }
  }
}
