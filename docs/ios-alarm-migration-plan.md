# iOS: Migrate daily check-in scheduling to the Alarm package

This document plans replacing **`flutter_local_notifications`** scheduling **on iOS only** with a native-style alarm flow using the **[`alarm`](https://pub.dev/packages/alarm)** package (commonly referred to in conversation as a “Flutter alarm” solution). **Android continues to use `flutter_local_notifications`** as today, unless you later choose to unify both platforms on `alarm`.

---

## 1. Goals

- On **iOS**, fire a **real alarm** at the user’s daily check-in time (and follow-up reminder time), with sound and vibration behavior closer to the Clock app than a simple scheduled notification.
- Preserve existing product behavior:
  - Daily check-in alarm + short-offset follow-up reminder (see `AppConfig.followUpReminderDelayMinutes`).
  - Rolling window of future triggers (today the app schedules **15 days** ahead via `_scheduleDaysAhead`).
  - Cancel/reschedule when the user completes check-in (`completeDailyCheckIn`) or changes reminder time.
  - Payload must still encode `type` (`daily_checkin` | `checkin_reminder`) and `scheduledDate` so **check-in from dismiss** and **navigation to home** keep working.

---

## 2. Current architecture (reference)

| Area | Behavior |
|------|----------|
| `lib/services/notification_service.dart` | `zonedSchedule` for both platforms; alarm-style details on Android; iOS uses `DarwinNotificationDetails` with `preview.caf`. |
| `lib/main.dart` | `NotificationService().init()`, `getNotificationAppLaunchDetails`, handling `dismiss` / alarm payload for navigation and `runCheckInFromDismiss`. |
| iOS assets | `preview.caf` (and related) in Runner for notification sound. |

**Constraint:** Scheduled notifications on iOS are **not** full-screen alarms; reliability and UX differ from a dedicated alarm API.

---

## 3. Package choice

### 3.1 Primary: `alarm` (recommended for this plan)

- **pub.dev:** [`alarm`](https://pub.dev/packages/alarm) — *“A simple Flutter alarm manager plugin for both iOS and Android.”*
- **Why it fits:** Explicit `AlarmSettings` with `dateTime`, `assetAudioPath`, loop, vibrate, `notificationSettings` (title/body/stop button), optional `payload`.
- **iOS caveats (from package docs):** Alarms may **not** fire after device restart, if the app is force-quit, or under memory pressure; **Background App Refresh** and App Store disclosure matter. For **iOS 18+**, the package FAQ points to **`flutter_alarmkit`** for stronger system integration.

### 3.2 Alternative: `flutter_alarmkit`

- **pub.dev:** [`flutter_alarmkit`](https://pub.dev/packages/flutter_alarmkit) — **iOS 18+**, Apple **AlarmKit** (one-shot, countdown, recurrent weekdays).
- **Use when:** Minimum iOS is 18 and you want alarms that behave closer to first-party Clock alarms with tighter OS support.
- **Trade-off:** Narrower OS range; different API surface than `alarm`.

**Naming note:** There is no widely used package literally named `flutter_alarm` on pub.dev; **`alarm`** is the standard cross-platform choice. This plan is written around **`alarm`**; swap the integration layer if you standardize on **AlarmKit** instead.

---

## 4. High-level design

### 4.1 Platform split

- **`Platform.isAndroid`**  
  Keep current path: `flutter_local_notifications` + existing `AndroidNotificationDetails` (full-screen intent, alarm channel, etc.).

- **`Platform.isIOS`**  
  - `await Alarm.init()` once at startup (see `main.dart`).
  - Schedule/cancel via `Alarm.set` / `Alarm.stop` (and/or bulk cancel helper if the package provides one — verify current API in the version you pin).
  - Map each logical notification **id** (0–14 for main, 100–114 for reminder) to **the same numeric id** used by `alarm` where possible, so cancel logic stays consistent.

### 4.2 Scheduling rules (mirror current)

1. **On set/change of daily time** (`scheduleDailyNotification` / `scheduleDailyNotificationFromDate`):  
   - Clear **iOS** alarms only (stop all known ids or replace full set).  
   - Schedule **15** `daily_checkin` datetimes + **15** `checkin_reminder` datetimes (existing loop).

2. **On successful early window check-in** (`completeDailyCheckIn` when `inPreReminderWindow`):  
   - Today: `cancelAll` for iOS alarms + reschedule from **tomorrow** (same as current `cancelAll` + `_scheduleNotifications`).

3. **Global cancel** (`cancelAllNotifications`):  
   - iOS: stop every alarm id in the reserved ranges (and any one-off ids you introduce).

### 4.3 Payload and callbacks

- Encode the **same JSON** as today in `AlarmSettings.payload` (or equivalent):  
  `{'type': '...', 'scheduledDate': '...'}`.
- Wire **alarm ring / stop** to existing flows:
  - **Stop / dismiss from notification:** map to `Notification Service` check-in or open app — align with `alarm`’s `notificationSettings.stopButton` and any **ringing** stream (`Alarm.ringing.listen`).
  - **Tap to open app:** ensure `main.dart` can still **push `HomeScreen`** when the user opens the app from the alarm UI (may require bridging through `alarm`’s API; verify when implementing).

### 4.4 Audio and copy

- Add alarm sound under **`assets/`** and declare in `pubspec.yaml`; set `assetAudioPath` (e.g. `assets/sounds/preview.mp3` or a shorter clip suitable for looping).
- Reuse **localized** title/body: either pass strings from `lookupAppLocalizations` at schedule time (like current `_getLocalizations()`) or schedule with English fallback and improve later.

---

## 5. Implementation phases

### Phase A — Dependencies and iOS project setup

1. Add to `pubspec.yaml`:  
   `alarm: ^<pinned version>`  
   (keep `flutter_local_notifications` for Android and optionally for any remaining iOS use — see Phase E.)
2. Follow **`help/INSTALL-IOS.md`** in the `alarm` repo:  
   - Background modes, audio, notification usage description strings, asset bundling, any **Info.plist** / **Xcode** capabilities.
3. Confirm **minimum iOS version** supported by the chosen `alarm` version matches your `Podfile` deployment target.

### Phase B — `main.dart` bootstrap

1. `WidgetsFlutterBinding.ensureInitialized();`
2. `await Alarm.init();` **before** `runApp` (iOS only or unconditional if safe on Android — follow package guidance).
3. Keep existing notification init for **Android**; if iOS no longer uses local notifications for alarms, **skip** or narrow iOS initialization of `flutter_local_notifications` (Phase E).

### Phase C — Refactor `NotificationService`

1. Extract **shared** helpers: timezone resolution, payload encode/decode, “next 15 dates” loop, `GraphQLService.scheduleEmergencySmsTasks` / `clearEmergencySmsTasks` (unchanged).
2. Implement `_scheduleNotificationsIosWithAlarm(...)` parallel to current `_scheduleNotifications` (or branch inside with `if (Platform.isIOS)`).
3. Implement `_cancelAllIosAlarms()` iterating ids `0..(_scheduleDaysAhead-1)` and `100..(100+_scheduleDaysAhead-1)` (match current `startId` convention: `0` vs `100`).
4. In `completeDailyCheckIn` and `cancelAllNotifications`, call **both** Android cancel-all and iOS alarm stops as appropriate.

### Phase D — Parity with check-in and navigation

1. **`NotificationService.runCheckInFromDismiss`** / **`dismiss` action:**  
   Reproduce with `alarm` stop handler + payload; ensure **token/storage** are available in background isolate if applicable (mirror current `onBackgroundNotificationResponse` constraints).
2. **`main.dart` `getNotificationAppLaunchDetails`:**  
   If iOS no longer launches via notification plugin for alarms, add equivalent handling for **`alarm`** (app opened from lock screen / notification). Validate on device.

### Phase E — Reduce or remove iOS use of `flutter_local_notifications` (optional cleanup)

- If **all** iOS scheduling moves to `alarm`, remove iOS branches from `zonedSchedule` and Darwin settings **only** when no other feature still needs banners (e.g. generic app notices). If something must stay, keep minimal iOS initialization.

### Phase F — QA and release

- Test on **physical iPhone**: cold start, background, locked screen, **Low Power Mode**, **Do Not Disturb** (expect silenced banner per package table, but sound behavior documented).
- Test **time zone change** and **daylight saving** (known edge cases in alarm plugins — document follow-up).
- App Store: prepare **privacy / background audio** justification per plugin FAQ.

---

## 6. Risks and mitigations

| Risk | Mitigation |
|------|------------|
| iOS kills app before alarm | `warningNotificationOnKill` on iOS; user education; consider **AlarmKit** for iOS 18+. |
| Duplicate systems (notification + alarm) | Double-fire if both active — ensure **only one** scheduler runs per platform. |
| Id collision / orphan alarms | Fixed id ranges + `cancelAll` on every reschedule path. |
| Localized strings at schedule time | Read locale from `SharedPreferences` (`app_locale`) before building `AlarmSettings`. |
| App Store review | Declare alarm / background audio use clearly. |

---

## 7. Files likely touched

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `alarm`, assets. |
| `lib/main.dart` | `Alarm.init`, launch handling updates. |
| `lib/services/notification_service.dart` | Platform branches; iOS `Alarm.set` / `Alarm.stop`; cancel/reschedule. |
| `ios/Runner/Info.plist` | Permissions / background modes per `alarm` install doc. |
| `ios/Podfile` | Deployment target if needed. |
| Optional new `lib/services/ios_alarm_service.dart` | Isolate iOS alarm logic for readability. |

---

## 8. Definition of done

- [ ] iOS: daily check-in and follow-up times fire via **`alarm`**, not `zonedSchedule`, for the 15-day window.  
- [ ] Android: unchanged behavior with `flutter_local_notifications`.  
- [ ] Completing check-in in the early window still **cancels** same-day follow-up and **reschedules** from tomorrow on both platforms.  
- [ ] Dismiss / open-app flows still perform check-in or navigate to home with correct payload semantics.  
- [ ] Docs updated; QA sign-off on real devices.

---

*Last updated: planning only — no runtime behavior changed by this document.*
