import Flutter
import UIKit
import UserNotifications
import AVFoundation

public class SmartLocalNotificationPlugin: NSObject, FlutterPlugin {
    private var audioManager: AudioManager?
    private var notificationManager: NotificationManager?
    private var scheduleManager: ScheduleManager?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "smart_local_notification", binaryMessenger: registrar.messenger())
        let instance = SmartLocalNotificationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    override init() {
        super.init()
        self.audioManager = AudioManager()
        self.notificationManager = NotificationManager()
        self.scheduleManager = ScheduleManager()
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
        case "scheduleNotification":
            scheduleNotification(call: call, result: result)
        case "cancelScheduledNotification":
            cancelScheduledNotification(call: call, result: result)
        case "cancelAllScheduledNotifications":
            cancelAllScheduledNotifications(result: result)
        case "getScheduledNotifications":
            getScheduledNotifications(call: call, result: result)
        case "updateScheduledNotification":
            updateScheduledNotification(call: call, result: result)
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

        // Check if this is a scheduled notification
        if let scheduleData = args["schedule"] as? [String: Any] {
            let scheduled = scheduleManager?.scheduleNotification(
                notificationData: args,
                scheduleData: scheduleData
            ) ?? false
            result(scheduled)
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

    private func scheduleNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let notificationData = args["notification"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let scheduleData = args["schedule"] as? [String: Any]
        let scheduled = scheduleManager?.scheduleNotification(
            notificationData: notificationData,
            scheduleData: scheduleData
        ) ?? false
        result(scheduled)
    }

    private func cancelScheduledNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let cancelled = scheduleManager?.cancelScheduledNotification(notificationId: id) ?? false
        result(cancelled)
    }

    private func cancelAllScheduledNotifications(result: @escaping FlutterResult) {
        let cancelled = scheduleManager?.cancelAllScheduledNotifications() ?? false
        result(cancelled)
    }

    private func getScheduledNotifications(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        let persistenceManager = NotificationPersistenceManager()

        let isActive = args["isActive"] as? Bool
        let isRecurring = args["isRecurring"] as? Bool
        let scheduledAfter = args["scheduledAfter"] as? Double
        let scheduledBefore = args["scheduledBefore"] as? Double
        let limit = args["limit"] as? Int
        let offset = args["offset"] as? Int

        let notifications = persistenceManager.getScheduledNotificationsByQuery(
            isActive: isActive,
            isRecurring: isRecurring,
            scheduledAfter: scheduledAfter,
            scheduledBefore: scheduledBefore,
            limit: limit,
            offset: offset
        )

        result(notifications)
    }

    private func updateScheduledNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let scheduleId = args["scheduleId"] as? Int,
              let updates = args["updates"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let persistenceManager = NotificationPersistenceManager()
        persistenceManager.updateScheduledNotification(scheduleId: scheduleId, updates: updates)
        result(true)
    }
}
