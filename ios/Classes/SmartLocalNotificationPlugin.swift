import Flutter
import UIKit
import UserNotifications
import AVFoundation

public class SmartLocalNotificationPlugin: NSObject, FlutterPlugin {
    private var audioManager: AudioManager?
    private var notificationManager: NotificationManager?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "smart_local_notification", binaryMessenger: registrar.messenger())
        let instance = SmartLocalNotificationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    override init() {
        super.init()
        self.audioManager = AudioManager()
        self.notificationManager = NotificationManager()
        setupNotificationCategories()
    }

    private func setupNotificationCategories() {
        notificationManager?.initialize()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(result: result)
        case "showNotification":
            showNotification(call: call, result: result)
        case "cancelNotification":
            cancelNotification(call: call, result: result)
        case "cancelAllNotifications":
            cancelAllNotifications(result: result)
        case "stopAudio":
            stopAudio(result: result)
        case "isAudioPlaying":
            isAudioPlaying(result: result)
        case "requestPermissions":
            requestPermissions(result: result)
        case "arePermissionsGranted":
            arePermissionsGranted(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(result: @escaping FlutterResult) {
        // Initialize audio session and notification center
        audioManager?.initialize()
        notificationManager?.initialize()
        result(true)
    }
    
    private func showNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        // Parse notification data and show notification with audio
        notificationManager?.showNotification(args: args) { [weak self] success in
            if success, let audioSettings = args["audioSettings"] as? [String: Any] {
                self?.audioManager?.playAudio(settings: audioSettings)
            }
            result(success)
        }
    }
    
    private func cancelNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        notificationManager?.cancelNotification(id: id)
        result(true)
    }
    
    private func cancelAllNotifications(result: @escaping FlutterResult) {
        notificationManager?.cancelAllNotifications()
        result(true)
    }
    
    private func stopAudio(result: @escaping FlutterResult) {
        audioManager?.stopAudio()
        result(true)
    }
    
    private func isAudioPlaying(result: @escaping FlutterResult) {
        let isPlaying = audioManager?.isPlaying ?? false
        result(isPlaying)
    }
    
    private func requestPermissions(result: @escaping FlutterResult) {
        notificationManager?.requestPermissions { granted in
            result(granted)
        }
    }
    
    private func arePermissionsGranted(result: @escaping FlutterResult) {
        notificationManager?.arePermissionsGranted { granted in
            result(granted)
        }
    }
}
