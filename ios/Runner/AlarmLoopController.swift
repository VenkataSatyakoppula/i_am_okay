import AVFoundation
import Foundation

/// Loops the bundled alarm sound (preview.caf) for 60 seconds — iOS notification sounds cannot loop beyond ~30s.
final class AlarmLoopController {
  static let shared = AlarmLoopController()

  private var player: AVAudioPlayer?
  private var stopTimer: Timer?
  private let loopDurationSeconds: TimeInterval = 60

  private init() {}

  /// Returns true if payload JSON has type daily_checkin or checkin_reminder.
  static func isAlarmPayload(_ userInfo: [AnyHashable: Any]) -> Bool {
    guard let payload = userInfo["payload"] as? String,
          let data = payload.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let type = json["type"] as? String else {
      return false
    }
    return type == "daily_checkin" || type == "checkin_reminder"
  }

  func start() {
    stop()

    guard let url = Bundle.main.url(forResource: "preview", withExtension: "caf") else {
      return
    }

    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .default, options: [.duckOthers])
      try session.setActive(true, options: [])

      let p = try AVAudioPlayer(contentsOf: url)
      p.numberOfLoops = -1
      p.prepareToPlay()
      p.play()
      player = p

      stopTimer = Timer.scheduledTimer(withTimeInterval: loopDurationSeconds, repeats: false) { [weak self] _ in
        self?.stop()
      }
    } catch {
      stop()
    }
  }

  func stop() {
    stopTimer?.invalidate()
    stopTimer = nil
    player?.stop()
    player = nil
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }
}
