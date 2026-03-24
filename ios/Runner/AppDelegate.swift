import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let alarmAudioChannel = "com.infodat.iamokay/ios_alarm_audio"
  private var alarmChannelRegistered = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    registerAlarmAudioChannelIfNeeded()
  }

  private func registerAlarmAudioChannelIfNeeded() {
    guard !alarmChannelRegistered else { return }
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    alarmChannelRegistered = true

    let channel = FlutterMethodChannel(
      name: AppDelegate.alarmAudioChannel,
      binaryMessenger: controller.engine.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "startLoopingAlarm":
        AlarmLoopController.shared.start()
        result(nil)
      case "stopLoopingAlarm":
        AlarmLoopController.shared.stop()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // MARK: - Foreground notification: loop alarm 1 min (no system sound — we play loop)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    if AlarmLoopController.isAlarmPayload(userInfo) {
      AlarmLoopController.shared.start()
      if #available(iOS 14.0, *) {
        completionHandler([.banner, .list, .badge])
      } else {
        completionHandler([.alert, .badge])
      }
      return
    }
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
}
