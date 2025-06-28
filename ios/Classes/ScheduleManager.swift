import Foundation
import UserNotifications

class ScheduleManager: NSObject {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let persistenceManager = NotificationPersistenceManager()
    
    override init() {
        super.init()
    }
    
    func scheduleNotification(notificationData: [String: Any], scheduleData: [String: Any]?) -> Bool {
        guard let notificationId = notificationData["id"] as? Int else {
            print("ScheduleManager: Missing notification ID")
            return false
        }
        
        let scheduleId = generateScheduleId(notificationId: notificationId)
        
        // Parse schedule information
        guard let scheduledTime = parseScheduledTime(notificationData: notificationData, scheduleData: scheduleData) else {
            print("ScheduleManager: Invalid or past scheduled time for notification \(notificationId)")
            return false
        }
        
        // Store notification data for persistence
        persistenceManager.saveScheduledNotification(
            scheduleId: scheduleId,
            notificationData: notificationData,
            scheduleData: scheduleData
        )
        
        // Create notification content
        let content = createNotificationContent(notificationData: notificationData)
        
        // Create trigger based on schedule type
        guard let trigger = createNotificationTrigger(
            scheduledTime: scheduledTime,
            scheduleData: scheduleData
        ) else {
            print("ScheduleManager: Failed to create notification trigger")
            return false
        }
        
        // Create request
        let request = UNNotificationRequest(
            identifier: String(scheduleId),
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        var success = false
        let semaphore = DispatchSemaphore(value: 0)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("ScheduleManager: Failed to schedule notification: \(error)")
                success = false
            } else {
                print("ScheduleManager: Scheduled notification \(notificationId) for \(scheduledTime)")
                success = true
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return success
    }
    
    func cancelScheduledNotification(notificationId: Int) -> Bool {
        let scheduleId = generateScheduleId(notificationId: notificationId)
        let identifier = String(scheduleId)
        
        // Cancel the notification
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        
        // Remove from persistence
        persistenceManager.removeScheduledNotification(scheduleId: scheduleId)
        
        print("ScheduleManager: Cancelled scheduled notification \(notificationId)")
        return true
    }
    
    func cancelAllScheduledNotifications() -> Bool {
        // Get all scheduled notifications
        let scheduledNotifications = persistenceManager.getAllScheduledNotifications()
        
        // Cancel all pending notifications
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        
        // Clear all from persistence
        persistenceManager.clearAllScheduledNotifications()
        
        print("ScheduleManager: Cancelled all scheduled notifications")
        return true
    }
    
    func rescheduleAllNotifications() {
        let scheduledNotifications = persistenceManager.getAllScheduledNotifications()
        
        for (scheduleId, data) in scheduledNotifications {
            guard let notificationData = data["notification"] as? [String: Any] else { continue }
            let scheduleData = data["schedule"] as? [String: Any]
            
            // Calculate next occurrence
            if let nextOccurrence = calculateNextOccurrence(
                notificationData: notificationData,
                scheduleData: scheduleData
            ) {
                if nextOccurrence > Date() {
                    let content = createNotificationContent(notificationData: notificationData)
                    
                    if let trigger = createNotificationTrigger(
                        scheduledTime: nextOccurrence,
                        scheduleData: scheduleData
                    ) {
                        let request = UNNotificationRequest(
                            identifier: String(scheduleId),
                            content: content,
                            trigger: trigger
                        )
                        
                        notificationCenter.add(request) { error in
                            if let error = error {
                                print("ScheduleManager: Failed to reschedule notification: \(error)")
                            } else {
                                print("ScheduleManager: Rescheduled notification for \(nextOccurrence)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func parseScheduledTime(notificationData: [String: Any], scheduleData: [String: Any]?) -> Date? {
        // First check for enhanced schedule
        if let scheduleData = scheduleData {
            return calculateNextOccurrence(notificationData: notificationData, scheduleData: scheduleData)
        }
        
        // Fall back to simple scheduledTime
        if let scheduledTimeMs = notificationData["scheduledTime"] as? Int64 {
            return Date(timeIntervalSince1970: TimeInterval(scheduledTimeMs) / 1000.0)
        }
        
        return nil
    }
    
    private func calculateNextOccurrence(notificationData: [String: Any], scheduleData: [String: Any]?) -> Date? {
        guard let scheduleData = scheduleData else {
            if let scheduledTimeMs = notificationData["scheduledTime"] as? Int64 {
                return Date(timeIntervalSince1970: TimeInterval(scheduledTimeMs) / 1000.0)
            }
            return nil
        }
        
        let scheduleType = scheduleData["scheduleType"] as? String ?? "oneTime"
        guard let scheduledTimeMs = scheduleData["scheduledTime"] as? Int64 else { return nil }
        let timeZone = scheduleData["timeZone"] as? String
        let isActive = scheduleData["isActive"] as? Bool ?? true
        
        if !isActive { return nil }
        
        let scheduledTime = Date(timeIntervalSince1970: TimeInterval(scheduledTimeMs) / 1000.0)
        let now = Date()
        
        var calendar = Calendar.current
        if let timeZone = timeZone, let tz = TimeZone(identifier: timeZone) {
            calendar.timeZone = tz
        }
        
        switch scheduleType {
        case "oneTime":
            return scheduledTime > now ? scheduledTime : nil
        case "daily":
            return calculateNextDailyOccurrence(scheduledTime: scheduledTime, calendar: calendar, now: now)
        case "weekly":
            return calculateNextWeeklyOccurrence(
                scheduledTime: scheduledTime,
                calendar: calendar,
                now: now,
                scheduleData: scheduleData
            )
        case "monthly":
            return calculateNextMonthlyOccurrence(scheduledTime: scheduledTime, calendar: calendar, now: now)
        case "yearly":
            return calculateNextYearlyOccurrence(scheduledTime: scheduledTime, calendar: calendar, now: now)
        case "custom":
            return calculateNextCustomOccurrence(
                scheduledTime: scheduledTime,
                calendar: calendar,
                now: now,
                scheduleData: scheduleData
            )
        default:
            return nil
        }
    }
    
    private func calculateNextDailyOccurrence(scheduledTime: Date, calendar: Calendar, now: Date) -> Date {
        let components = calendar.dateComponents([.hour, .minute, .second], from: scheduledTime)
        var nextOccurrence = calendar.nextDate(
            after: now,
            matching: components,
            matchingPolicy: .nextTime
        ) ?? now
        
        // If the calculated time is not after now, add a day
        if nextOccurrence <= now {
            nextOccurrence = calendar.date(byAdding: .day, value: 1, to: nextOccurrence) ?? nextOccurrence
        }
        
        return nextOccurrence
    }
    
    private func calculateNextWeeklyOccurrence(
        scheduledTime: Date,
        calendar: Calendar,
        now: Date,
        scheduleData: [String: Any]
    ) -> Date? {
        let weekDays = scheduleData["weekDays"] as? [String] ?? []
        let targetWeekDays = weekDays.isEmpty ? [calendar.component(.weekday, from: scheduledTime)] : weekDays.compactMap { weekDayToCalendar($0) }
        
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: scheduledTime)
        
        // Find the next occurrence within the next 7 days
        for i in 0..<7 {
            if let candidateDate = calendar.date(byAdding: .day, value: i, to: now) {
                let weekday = calendar.component(.weekday, from: candidateDate)
                
                if targetWeekDays.contains(weekday) {
                    var components = calendar.dateComponents([.year, .month, .day], from: candidateDate)
                    components.hour = timeComponents.hour
                    components.minute = timeComponents.minute
                    components.second = timeComponents.second
                    
                    if let nextOccurrence = calendar.date(from: components), nextOccurrence > now {
                        return nextOccurrence
                    }
                }
            }
        }
        
        return nil
    }
    
    private func calculateNextMonthlyOccurrence(scheduledTime: Date, calendar: Calendar, now: Date) -> Date {
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: scheduledTime)
        var nextOccurrence = calendar.nextDate(
            after: now,
            matching: components,
            matchingPolicy: .nextTime
        ) ?? now
        
        // If the calculated time is not after now, add a month
        if nextOccurrence <= now {
            nextOccurrence = calendar.date(byAdding: .month, value: 1, to: nextOccurrence) ?? nextOccurrence
        }
        
        return nextOccurrence
    }
    
    private func calculateNextYearlyOccurrence(scheduledTime: Date, calendar: Calendar, now: Date) -> Date {
        let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: scheduledTime)
        var nextOccurrence = calendar.nextDate(
            after: now,
            matching: components,
            matchingPolicy: .nextTime
        ) ?? now
        
        // If the calculated time is not after now, add a year
        if nextOccurrence <= now {
            nextOccurrence = calendar.date(byAdding: .year, value: 1, to: nextOccurrence) ?? nextOccurrence
        }
        
        return nextOccurrence
    }
    
    private func calculateNextCustomOccurrence(
        scheduledTime: Date,
        calendar: Calendar,
        now: Date,
        scheduleData: [String: Any]
    ) -> Date? {
        guard let interval = scheduleData["interval"] as? Int,
              let intervalUnit = scheduleData["intervalUnit"] as? String else {
            return nil
        }
        
        var nextOccurrence = scheduledTime
        
        // Calculate next occurrence based on interval
        while nextOccurrence <= now {
            switch intervalUnit.lowercased() {
            case "minutes":
                nextOccurrence = calendar.date(byAdding: .minute, value: interval, to: nextOccurrence) ?? nextOccurrence
            case "hours":
                nextOccurrence = calendar.date(byAdding: .hour, value: interval, to: nextOccurrence) ?? nextOccurrence
            case "days":
                nextOccurrence = calendar.date(byAdding: .day, value: interval, to: nextOccurrence) ?? nextOccurrence
            case "weeks":
                nextOccurrence = calendar.date(byAdding: .weekOfYear, value: interval, to: nextOccurrence) ?? nextOccurrence
            case "months":
                nextOccurrence = calendar.date(byAdding: .month, value: interval, to: nextOccurrence) ?? nextOccurrence
            default:
                return nil
            }
        }
        
        return nextOccurrence
    }
    
    private func weekDayToCalendar(_ weekDay: String) -> Int? {
        switch weekDay.lowercased() {
        case "sunday": return 1
        case "monday": return 2
        case "tuesday": return 3
        case "wednesday": return 4
        case "thursday": return 5
        case "friday": return 6
        case "saturday": return 7
        default: return nil
        }
    }
    
    private func createNotificationContent(notificationData: [String: Any]) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = notificationData["title"] as? String ?? "Scheduled Notification"
        content.body = notificationData["body"] as? String ?? "This is a scheduled notification"
        
        // Configure notification settings
        if let notificationSettings = notificationData["notificationSettings"] as? [String: Any] {
            let silent = notificationSettings["silent"] as? Bool ?? true
            if silent {
                content.sound = nil
            } else {
                content.sound = .default
            }
            
            content.badge = NSNumber(value: 1)
        }
        
        // Add custom data
        var userInfo: [String: Any] = [:]
        userInfo["notificationId"] = notificationData["id"]
        userInfo["isScheduled"] = true
        
        if let payload = notificationData["payload"] as? [String: Any] {
            userInfo["payload"] = payload
        }
        
        content.userInfo = userInfo
        return content
    }
    
    private func createNotificationTrigger(scheduledTime: Date, scheduleData: [String: Any]?) -> UNNotificationTrigger? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: scheduledTime)
        
        // For recurring notifications, we only schedule the next occurrence
        // The app will handle rescheduling when the notification fires
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
    
    private func generateScheduleId(notificationId: Int) -> Int {
        return 10000 + notificationId
    }
}
