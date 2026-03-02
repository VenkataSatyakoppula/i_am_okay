import 'dart:async';
import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';
import '../gql/mutations/emergency_mutations.dart';

const String emergencySmsTask = "emergencySmsTask";

const String _debugTag = '[EmergencySMS]';

/// On iOS, processing tasks report unique name (e.g. emergency_sms_0); on Android, task name.
bool _isEmergencySmsTask(String task) =>
    task == emergencySmsTask || task.startsWith('emergency_sms_');

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('$_debugTag callbackDispatcher invoked with task="$task" inputData=$inputData');
    if (!_isEmergencySmsTask(task)) {
      debugPrint('$_debugTag task not emergency SMS, skipping. task="$task"');
      return Future.value(true);
    }
    debugPrint('$_debugTag matched emergency SMS task, starting execution');
    try {
      debugPrint('$_debugTag Step 1: Getting location...');
      String locationString = "Unknown";
      final permission = await Geolocator.checkPermission();
      debugPrint('$_debugTag Location permission: $permission');
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          );
          locationString = "${position.latitude},${position.longitude}";
          debugPrint('$_debugTag Location obtained: $locationString');
        } catch (e, st) {
          debugPrint('$_debugTag Error getting location: $e');
          debugPrint('$_debugTag $st');
        }
      } else {
        debugPrint('$_debugTag Location permission not granted for background task.');
      }

      debugPrint('$_debugTag Step 2: Setting up GraphQL client...');
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      final hasToken = token != null && token.isNotEmpty;
      debugPrint('$_debugTag Auth token present: $hasToken');
      if (!hasToken) {
        debugPrint('$_debugTag Aborting: no auth token (user may be logged out).');
        return Future.value(false);
      }

      final HttpLink httpLink = HttpLink(
        AppConfig.apiUrl,
      );
      final AuthLink authLink = AuthLink(
        getToken: () async => token != null ? 'Bearer $token' : null,
      );
      final Link link = authLink.concat(httpLink);
      final client = GraphQLClient(
        link: link,
        cache: GraphQLCache(),
      );
      debugPrint('$_debugTag Step 3: Calling sendEmergencySms mutation (location=$locationString)...');
      final result = await client.mutate(
        MutationOptions(
          document: gql(sendEmergencySmsMutation),
          variables: {
            'location': locationString,
          },
        ),
      );

      if (result.hasException) {
        debugPrint('$_debugTag Mutation exception: ${result.exception}');
        return Future.value(false);
      }
      debugPrint('$_debugTag Emergency SMS sent successfully. data=${result.data}');
      return Future.value(true);
    } catch (e, st) {
      debugPrint('$_debugTag Fatal error: $e');
      debugPrint('$_debugTag StackTrace: $st');
      return Future.value(false);
    }
  });
}

/// Number of days we schedule emergency SMS for (must match iOS AppDelegate/Info.plist identifiers).
const int emergencySmsTaskCount = 15;

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  Future<void> init() async {
    debugPrint('$_debugTag init() called');
    await Workmanager().initialize(
      callbackDispatcher,
    );
    debugPrint('$_debugTag Workmanager initialized');
  }

  Future<void> scheduleEmergencySmsSequence(DateTime startDate) async {
    debugPrint('$_debugTag scheduleEmergencySmsSequence called startDate=$startDate platform=${Platform.isIOS ? "iOS" : "Android"}');
    await cancelEmergencySms();
    debugPrint('$_debugTag cancelEmergencySms() completed');

    for (int i = 0; i < emergencySmsTaskCount; i++) {
      final emergencyTime = startDate.add(Duration(days: i)).add(const Duration(minutes: AppConfig.emergencySmsDelayMinutes));
      final delay = emergencyTime.difference(DateTime.now());

      if (delay.isNegative) {
        debugPrint('$_debugTag day $i skipped (delay negative: ${delay.inMinutes} min)');
        continue;
      }
      try {
        if (Platform.isIOS) {
          debugPrint('$_debugTag Registering iOS processing task emergency_sms_$i delay=${delay.inMinutes} min (${delay.inSeconds} sec)');
          await Workmanager().registerProcessingTask(
            "emergency_sms_$i",
            emergencySmsTask,
            initialDelay: delay,
            constraints: Constraints(
              networkType: NetworkType.connected,
            ),
            inputData: {},
          );
          debugPrint('$_debugTag iOS registerProcessingTask("emergency_sms_$i") returned OK');
        } else {
          await Workmanager().registerOneOffTask(
            "emergency_sms_$i",
            emergencySmsTask,
            initialDelay: delay,
            constraints: Constraints(
              networkType: NetworkType.connected,
            ),
            inputData: {},
            existingWorkPolicy: ExistingWorkPolicy.replace,
          );
          debugPrint('$_debugTag Android registerOneOffTask day $i OK');
        }
      } catch (e, st) {
        debugPrint('$_debugTag FAILED to schedule day $i: $e');
        debugPrint('$_debugTag $st');
      }
    }
    debugPrint('$_debugTag scheduleEmergencySmsSequence finished. To inspect pending tasks on iOS: Workmanager().printScheduledTasks()');
  }

  Future<void> cancelEmergencySms() async {
    debugPrint('$_debugTag cancelEmergencySms() called');
    await Workmanager().cancelAll();
    debugPrint('$_debugTag cancelAll() completed');
  }
}
