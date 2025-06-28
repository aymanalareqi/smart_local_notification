import Flutter
import UIKit
import UserNotifications
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Configure notification center
    UNUserNotificationCenter.current().delegate = self

    // Configure audio session for background audio
    configureAudioSession()

    // Request notification permissions
    requestNotificationPermissions()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureAudioSession() {
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
      try audioSession.setActive(true)
    } catch {
      print("Failed to configure audio session: \(error)")
    }
  }

  private func requestNotificationPermissions() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        print("Notification permission error: \(error)")
      }
    }
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate {
  // Handle notification when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show notification even when app is in foreground
    completionHandler([.alert, .sound, .badge])
  }

  // Handle notification tap
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo

    // Handle notification actions
    switch response.actionIdentifier {
    case "STOP_AUDIO_ACTION":
      // Handle stop audio action
      handleStopAudioAction()
    case "SNOOZE_ACTION":
      // Handle snooze action
      handleSnoozeAction(userInfo: userInfo)
    case UNNotificationDefaultActionIdentifier:
      // Handle default tap action
      handleNotificationTap(userInfo: userInfo)
    default:
      break
    }

    completionHandler()
  }

  private func handleStopAudioAction() {
    // Stop audio playback
    print("Stop audio action triggered")
  }

  private func handleSnoozeAction(userInfo: [AnyHashable: Any]) {
    // Handle snooze functionality
    print("Snooze action triggered")
  }

  private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
    // Handle notification tap
    print("Notification tapped")
  }
}
