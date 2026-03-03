const String sendEmergencySmsMutation = """
  mutation SendEmergencySms(\$location: String) {
    sendEmergencySms(location: \$location)
  }
""";

/// Schedule server-side emergency SMS tasks. Backend uses user's CheckInTime.
/// days: 7 (default), timeZone: e.g. America/New_York, checkInOffset: minutes after CheckInTime,
/// startDate: optional DateTime (ISO 8601 string e.g. 2025-03-01T00:00:00Z) to start schedule from.
const String scheduleEmergencySmsTasksMutation = """
  mutation ScheduleEmergencySmsTasks(\$days: Int, \$timeZone: String, \$checkInOffset: Int, \$startDate: DateTime) {
    scheduleEmergencySmsTasks(days: \$days, timeZone: \$timeZone, checkInOffset: \$checkInOffset, startDate: \$startDate)
  }
""";

/// Clear all scheduled emergency SMS tasks for the current user. Call on logout.
const String clearEmergencySmsTasksMutation = """
  mutation ClearEmergencySmsTasks {
    clearEmergencySmsTasks
  }
""";
