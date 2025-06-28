import Foundation

class NotificationPersistenceManager {
    private let userDefaults = UserDefaults.standard
    private let scheduledNotificationsKey = "smart_local_notification_schedules"
    
    func saveScheduledNotification(
        scheduleId: Int,
        notificationData: [String: Any],
        scheduleData: [String: Any]?
    ) {
        var allSchedules = getAllScheduledNotifications()
        
        let scheduleInfo: [String: Any] = [
            "scheduleId": scheduleId,
            "notification": notificationData,
            "schedule": scheduleData as Any,
            "createdAt": Date().timeIntervalSince1970 * 1000,
            "updatedAt": Date().timeIntervalSince1970 * 1000,
            "triggerCount": 0,
            "isActive": true
        ]
        
        allSchedules[String(scheduleId)] = scheduleInfo
        saveAllScheduledNotifications(allSchedules)
        
        print("NotificationPersistenceManager: Saved scheduled notification with ID: \(scheduleId)")
    }
    
    func removeScheduledNotification(scheduleId: Int) {
        var allSchedules = getAllScheduledNotifications()
        allSchedules.removeValue(forKey: String(scheduleId))
        saveAllScheduledNotifications(allSchedules)
        
        print("NotificationPersistenceManager: Removed scheduled notification with ID: \(scheduleId)")
    }
    
    func getScheduledNotification(scheduleId: Int) -> [String: Any]? {
        let allSchedules = getAllScheduledNotifications()
        return allSchedules[String(scheduleId)]
    }
    
    func getAllScheduledNotifications() -> [String: [String: Any]] {
        guard let data = userDefaults.data(forKey: scheduledNotificationsKey),
              let schedules = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return [:]
        }
        return schedules
    }
    
    func updateScheduledNotification(scheduleId: Int, updates: [String: Any]) {
        var allSchedules = getAllScheduledNotifications()
        guard var existing = allSchedules[String(scheduleId)] else { return }
        
        for (key, value) in updates {
            existing[key] = value
        }
        existing["updatedAt"] = Date().timeIntervalSince1970 * 1000
        
        allSchedules[String(scheduleId)] = existing
        saveAllScheduledNotifications(allSchedules)
        
        print("NotificationPersistenceManager: Updated scheduled notification with ID: \(scheduleId)")
    }
    
    func incrementTriggerCount(scheduleId: Int) {
        var allSchedules = getAllScheduledNotifications()
        guard var existing = allSchedules[String(scheduleId)] else { return }
        
        let currentCount = existing["triggerCount"] as? Int ?? 0
        existing["triggerCount"] = currentCount + 1
        existing["updatedAt"] = Date().timeIntervalSince1970 * 1000
        
        allSchedules[String(scheduleId)] = existing
        saveAllScheduledNotifications(allSchedules)
        
        print("NotificationPersistenceManager: Incremented trigger count for notification \(scheduleId) to \(currentCount + 1)")
    }
    
    func markAsInactive(scheduleId: Int) {
        updateScheduledNotification(scheduleId: scheduleId, updates: ["isActive": false])
    }
    
    func clearAllScheduledNotifications() {
        userDefaults.removeObject(forKey: scheduledNotificationsKey)
        print("NotificationPersistenceManager: Cleared all scheduled notifications")
    }
    
    func getActiveScheduledNotifications() -> [String: [String: Any]] {
        let allSchedules = getAllScheduledNotifications()
        return allSchedules.filter { (_, data) in
            return data["isActive"] as? Bool ?? true
        }
    }
    
    func getExpiredScheduledNotifications() -> [String: [String: Any]] {
        let allSchedules = getAllScheduledNotifications()
        let now = Date().timeIntervalSince1970 * 1000
        
        return allSchedules.filter { (_, data) in
            let scheduleData = data["schedule"] as? [String: Any]
            let endDate = scheduleData?["endDate"] as? Double
            let maxOccurrences = scheduleData?["maxOccurrences"] as? Int
            let triggerCount = data["triggerCount"] as? Int ?? 0
            let isActive = data["isActive"] as? Bool ?? true
            
            return !isActive ||
                   (endDate != nil && now > endDate!) ||
                   (maxOccurrences != nil && triggerCount >= maxOccurrences!)
        }
    }
    
    func cleanupExpiredNotifications() {
        let expired = getExpiredScheduledNotifications()
        var allSchedules = getAllScheduledNotifications()
        
        for scheduleId in expired.keys {
            allSchedules.removeValue(forKey: scheduleId)
        }
        
        saveAllScheduledNotifications(allSchedules)
        print("NotificationPersistenceManager: Cleaned up \(expired.count) expired notifications")
    }
    
    func getScheduledNotificationsByQuery(
        isActive: Bool? = nil,
        isRecurring: Bool? = nil,
        scheduledAfter: Double? = nil,
        scheduledBefore: Double? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> [[String: Any]] {
        var results = Array(getAllScheduledNotifications().values)
        
        // Apply filters
        if let isActive = isActive {
            results = results.filter { data in
                return (data["isActive"] as? Bool ?? true) == isActive
            }
        }
        
        if let isRecurring = isRecurring {
            results = results.filter { data in
                let scheduleData = data["schedule"] as? [String: Any]
                let scheduleType = scheduleData?["scheduleType"] as? String
                let recurring = scheduleType != nil && scheduleType != "oneTime"
                return recurring == isRecurring
            }
        }
        
        if let scheduledAfter = scheduledAfter {
            results = results.filter { data in
                let scheduleData = data["schedule"] as? [String: Any]
                let scheduledTime = scheduleData?["scheduledTime"] as? Double
                return scheduledTime != nil && scheduledTime! > scheduledAfter
            }
        }
        
        if let scheduledBefore = scheduledBefore {
            results = results.filter { data in
                let scheduleData = data["schedule"] as? [String: Any]
                let scheduledTime = scheduleData?["scheduledTime"] as? Double
                return scheduledTime != nil && scheduledTime! < scheduledBefore
            }
        }
        
        // Apply pagination
        if let offset = offset, offset > 0 {
            results = Array(results.dropFirst(offset))
        }
        
        if let limit = limit, limit > 0 {
            results = Array(results.prefix(limit))
        }
        
        return results
    }
    
    private func saveAllScheduledNotifications(_ schedules: [String: [String: Any]]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: schedules)
            userDefaults.set(data, forKey: scheduledNotificationsKey)
        } catch {
            print("NotificationPersistenceManager: Failed to save scheduled notifications: \(error)")
        }
    }
    
    func getStatistics() -> [String: Any] {
        let all = getAllScheduledNotifications()
        let active = getActiveScheduledNotifications()
        let expired = getExpiredScheduledNotifications()
        
        let recurring = all.values.filter { data in
            let scheduleData = data["schedule"] as? [String: Any]
            let scheduleType = scheduleData?["scheduleType"] as? String
            return scheduleType != nil && scheduleType != "oneTime"
        }.count
        
        return [
            "total": all.count,
            "active": active.count,
            "expired": expired.count,
            "recurring": recurring,
            "oneTime": all.count - recurring
        ]
    }
}
