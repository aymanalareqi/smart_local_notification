import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject {
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
    }
    
    func initialize() {
        notificationCenter.delegate = self
    }
    
    func showNotification(args: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let id = args["id"] as? Int,
              let title = args["title"] as? String,
              let body = args["body"] as? String else {
            completion(false)
            return
        }
        
        let notificationSettings = args["notificationSettings"] as? [String: Any] ?? [:]
        let scheduledTime = args["scheduledTime"] as? Int64
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        // Configure notification settings
        configureNotificationContent(content: content, settings: notificationSettings)
        
        // Create trigger
        let trigger: UNNotificationTrigger?
        if let scheduledTime = scheduledTime {
            let date = Date(timeIntervalSince1970: TimeInterval(scheduledTime) / 1000.0)
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        } else {
            // Immediate notification
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        }
        
        // Create request
        let request = UNNotificationRequest(
            identifier: String(id),
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }
    }
    
    private func configureNotificationContent(content: UNMutableNotificationContent, settings: [String: Any]) {
        let silent = settings["silent"] as? Bool ?? true
        let priority = settings["priority"] as? String ?? "default"
        let showTimestamp = settings["showTimestamp"] as? Bool ?? true
        let icon = settings["icon"] as? String
        let color = settings["color"] as? Int
        
        // Configure sound
        if silent {
            content.sound = nil
        } else {
            content.sound = .default
        }
        
        // Configure priority (iOS uses interruption level)
        if #available(iOS 15.0, *) {
            switch priority {
            case "min", "low":
                content.interruptionLevel = .passive
            case "default":
                content.interruptionLevel = .active
            case "high", "max":
                content.interruptionLevel = .timeSensitive
            default:
                content.interruptionLevel = .active
            }
        }
        
        // Configure badge (optional)
        content.badge = NSNumber(value: 1)
        
        // Configure category for actions (if needed)
        content.categoryIdentifier = "SMART_NOTIFICATION_CATEGORY"
        
        // Add custom data
        var userInfo: [String: Any] = [:]
        userInfo["notificationId"] = content.title
        userInfo["silent"] = silent
        userInfo["priority"] = priority
        
        if let payload = settings["payload"] as? [String: Any] {
            userInfo["payload"] = payload
        }
        
        content.userInfo = userInfo
    }
    
    func cancelNotification(id: Int) {
        let identifier = String(id)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("NotificationManager: Permission request error: \(error)")
                    completion(false)
                } else {
                    completion(granted)
                }
            }
        }
    }
    
    func arePermissionsGranted(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                let granted = settings.authorizationStatus == .authorized || 
                             settings.authorizationStatus == .provisional
                completion(granted)
            }
        }
    }
    
    private func setupNotificationCategories() {
        // Define actions
        let stopAction = UNNotificationAction(
            identifier: "STOP_AUDIO_ACTION",
            title: "Stop Audio",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: []
        )
        
        // Define category
        let category = UNNotificationCategory(
            identifier: "SMART_NOTIFICATION_CATEGORY",
            actions: [stopAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Register category
        notificationCenter.setNotificationCategories([category])
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let notificationId = userInfo["notificationId"] as? String ?? ""
        
        switch response.actionIdentifier {
        case "STOP_AUDIO_ACTION":
            // Handle stop audio action
            handleStopAudioAction(notificationId: notificationId)
            
        case "DISMISS_ACTION":
            // Handle dismiss action
            handleDismissAction(notificationId: notificationId)
            
        case UNNotificationDefaultActionIdentifier:
            // Handle notification tap
            handleNotificationTap(notificationId: notificationId, userInfo: userInfo)
            
        default:
            break
        }
        
        completionHandler()
    }
    
    private func handleStopAudioAction(notificationId: String) {
        // This would typically communicate back to the Flutter app
        // For now, we'll just print the action
        print("NotificationManager: Stop audio action for notification: \(notificationId)")
    }
    
    private func handleDismissAction(notificationId: String) {
        print("NotificationManager: Dismiss action for notification: \(notificationId)")
    }
    
    private func handleNotificationTap(notificationId: String, userInfo: [AnyHashable: Any]) {
        print("NotificationManager: Notification tapped: \(notificationId)")
        
        // If app is not active, bring it to foreground
        if UIApplication.shared.applicationState != .active {
            // The app will be brought to foreground automatically
        }
    }
}
