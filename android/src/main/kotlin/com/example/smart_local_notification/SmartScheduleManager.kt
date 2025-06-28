package com.example.smart_local_notification

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import java.util.*

class SmartScheduleManager(private val context: Context) {
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    private val persistenceManager = NotificationPersistenceManager(context)

    companion object {
        private const val TAG = "SmartScheduleManager"
        private const val REQUEST_CODE_BASE = 10000
    }

    fun scheduleNotification(
        notificationData: Map<String, Any>,
        scheduleData: Map<String, Any>?
    ): Boolean {
        return try {
            val notificationId = notificationData["id"] as? Int ?: return false
            val scheduleId = generateScheduleId(notificationId)
            
            // Parse schedule information
            val scheduledTime = parseScheduledTime(notificationData, scheduleData)
            if (scheduledTime == null || scheduledTime <= System.currentTimeMillis()) {
                Log.w(TAG, "Invalid or past scheduled time for notification $notificationId")
                return false
            }

            // Store notification data for persistence
            persistenceManager.saveScheduledNotification(scheduleId, notificationData, scheduleData)

            // Create alarm intent
            val alarmIntent = createAlarmIntent(scheduleId, notificationData, scheduleData)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                scheduleId,
                alarmIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Schedule the alarm
            scheduleAlarm(scheduledTime, pendingIntent)
            
            Log.d(TAG, "Scheduled notification $notificationId for ${Date(scheduledTime)}")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule notification", e)
            false
        }
    }

    fun cancelScheduledNotification(notificationId: Int): Boolean {
        return try {
            val scheduleId = generateScheduleId(notificationId)
            
            // Cancel the alarm
            val alarmIntent = createAlarmIntent(scheduleId, emptyMap(), null)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                scheduleId,
                alarmIntent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
            }

            // Remove from persistence
            persistenceManager.removeScheduledNotification(scheduleId)
            
            Log.d(TAG, "Cancelled scheduled notification $notificationId")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to cancel scheduled notification $notificationId", e)
            false
        }
    }

    fun cancelAllScheduledNotifications(): Boolean {
        return try {
            val scheduledNotifications = persistenceManager.getAllScheduledNotifications()
            
            for (scheduleId in scheduledNotifications.keys) {
                val alarmIntent = createAlarmIntent(scheduleId, emptyMap(), null)
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    scheduleId,
                    alarmIntent,
                    PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
                )
                
                if (pendingIntent != null) {
                    alarmManager.cancel(pendingIntent)
                    pendingIntent.cancel()
                }
            }

            // Clear all from persistence
            persistenceManager.clearAllScheduledNotifications()
            
            Log.d(TAG, "Cancelled all scheduled notifications")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to cancel all scheduled notifications", e)
            false
        }
    }

    fun rescheduleAllNotifications() {
        try {
            val scheduledNotifications = persistenceManager.getAllScheduledNotifications()
            
            for ((scheduleId, data) in scheduledNotifications) {
                val notificationData = data["notification"] as? Map<String, Any> ?: continue
                val scheduleData = data["schedule"] as? Map<String, Any>
                
                // Calculate next occurrence
                val nextOccurrence = calculateNextOccurrence(notificationData, scheduleData)
                if (nextOccurrence != null && nextOccurrence > System.currentTimeMillis()) {
                    val alarmIntent = createAlarmIntent(scheduleId, notificationData, scheduleData)
                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        scheduleId,
                        alarmIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    
                    scheduleAlarm(nextOccurrence, pendingIntent)
                    Log.d(TAG, "Rescheduled notification for ${Date(nextOccurrence)}")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to reschedule notifications", e)
        }
    }

    private fun parseScheduledTime(
        notificationData: Map<String, Any>,
        scheduleData: Map<String, Any>?
    ): Long? {
        // First check for enhanced schedule
        if (scheduleData != null) {
            return calculateNextOccurrence(notificationData, scheduleData)
        }
        
        // Fall back to simple scheduledTime
        return notificationData["scheduledTime"] as? Long
    }

    private fun calculateNextOccurrence(
        notificationData: Map<String, Any>,
        scheduleData: Map<String, Any>?
    ): Long? {
        if (scheduleData == null) {
            return notificationData["scheduledTime"] as? Long
        }

        val scheduleType = scheduleData["scheduleType"] as? String ?: "oneTime"
        val scheduledTime = scheduleData["scheduledTime"] as? Long ?: return null
        val timeZone = scheduleData["timeZone"] as? String
        val isActive = scheduleData["isActive"] as? Boolean ?: true
        
        if (!isActive) return null

        val calendar = Calendar.getInstance()
        if (timeZone != null) {
            calendar.timeZone = TimeZone.getTimeZone(timeZone)
        }
        
        val now = System.currentTimeMillis()
        calendar.timeInMillis = scheduledTime

        return when (scheduleType) {
            "oneTime" -> {
                if (scheduledTime > now) scheduledTime else null
            }
            "daily" -> {
                calculateNextDailyOccurrence(calendar, now)
            }
            "weekly" -> {
                calculateNextWeeklyOccurrence(calendar, now, scheduleData)
            }
            "monthly" -> {
                calculateNextMonthlyOccurrence(calendar, now)
            }
            "yearly" -> {
                calculateNextYearlyOccurrence(calendar, now)
            }
            "custom" -> {
                calculateNextCustomOccurrence(calendar, now, scheduleData)
            }
            else -> null
        }
    }

    private fun calculateNextDailyOccurrence(calendar: Calendar, now: Long): Long {
        val targetTime = Calendar.getInstance()
        targetTime.timeZone = calendar.timeZone
        targetTime.timeInMillis = now
        
        // Set to the same time today
        targetTime.set(Calendar.HOUR_OF_DAY, calendar.get(Calendar.HOUR_OF_DAY))
        targetTime.set(Calendar.MINUTE, calendar.get(Calendar.MINUTE))
        targetTime.set(Calendar.SECOND, calendar.get(Calendar.SECOND))
        targetTime.set(Calendar.MILLISECOND, calendar.get(Calendar.MILLISECOND))
        
        // If the time has passed today, schedule for tomorrow
        if (targetTime.timeInMillis <= now) {
            targetTime.add(Calendar.DAY_OF_MONTH, 1)
        }
        
        return targetTime.timeInMillis
    }

    private fun calculateNextWeeklyOccurrence(
        calendar: Calendar,
        now: Long,
        scheduleData: Map<String, Any>
    ): Long {
        val weekDays = scheduleData["weekDays"] as? List<String>
        val targetWeekDays = weekDays?.map { weekDayToCalendar(it) } ?: listOf(calendar.get(Calendar.DAY_OF_WEEK))
        
        val targetTime = Calendar.getInstance()
        targetTime.timeZone = calendar.timeZone
        targetTime.timeInMillis = now
        
        // Set to the target time
        targetTime.set(Calendar.HOUR_OF_DAY, calendar.get(Calendar.HOUR_OF_DAY))
        targetTime.set(Calendar.MINUTE, calendar.get(Calendar.MINUTE))
        targetTime.set(Calendar.SECOND, calendar.get(Calendar.SECOND))
        targetTime.set(Calendar.MILLISECOND, calendar.get(Calendar.MILLISECOND))
        
        // Find the next occurrence
        for (i in 0..6) {
            if (targetWeekDays.contains(targetTime.get(Calendar.DAY_OF_WEEK)) && targetTime.timeInMillis > now) {
                return targetTime.timeInMillis
            }
            targetTime.add(Calendar.DAY_OF_MONTH, 1)
        }
        
        return targetTime.timeInMillis
    }

    private fun calculateNextMonthlyOccurrence(calendar: Calendar, now: Long): Long {
        val targetTime = Calendar.getInstance()
        targetTime.timeZone = calendar.timeZone
        targetTime.timeInMillis = now
        
        // Set to the target day and time this month
        targetTime.set(Calendar.DAY_OF_MONTH, calendar.get(Calendar.DAY_OF_MONTH))
        targetTime.set(Calendar.HOUR_OF_DAY, calendar.get(Calendar.HOUR_OF_DAY))
        targetTime.set(Calendar.MINUTE, calendar.get(Calendar.MINUTE))
        targetTime.set(Calendar.SECOND, calendar.get(Calendar.SECOND))
        targetTime.set(Calendar.MILLISECOND, calendar.get(Calendar.MILLISECOND))
        
        // If the time has passed this month, schedule for next month
        if (targetTime.timeInMillis <= now) {
            targetTime.add(Calendar.MONTH, 1)
        }
        
        return targetTime.timeInMillis
    }

    private fun calculateNextYearlyOccurrence(calendar: Calendar, now: Long): Long {
        val targetTime = Calendar.getInstance()
        targetTime.timeZone = calendar.timeZone
        targetTime.timeInMillis = now
        
        // Set to the target date and time this year
        targetTime.set(Calendar.MONTH, calendar.get(Calendar.MONTH))
        targetTime.set(Calendar.DAY_OF_MONTH, calendar.get(Calendar.DAY_OF_MONTH))
        targetTime.set(Calendar.HOUR_OF_DAY, calendar.get(Calendar.HOUR_OF_DAY))
        targetTime.set(Calendar.MINUTE, calendar.get(Calendar.MINUTE))
        targetTime.set(Calendar.SECOND, calendar.get(Calendar.SECOND))
        targetTime.set(Calendar.MILLISECOND, calendar.get(Calendar.MILLISECOND))
        
        // If the time has passed this year, schedule for next year
        if (targetTime.timeInMillis <= now) {
            targetTime.add(Calendar.YEAR, 1)
        }
        
        return targetTime.timeInMillis
    }

    private fun calculateNextCustomOccurrence(
        calendar: Calendar,
        now: Long,
        scheduleData: Map<String, Any>
    ): Long {
        val interval = scheduleData["interval"] as? Int ?: return calendar.timeInMillis
        val intervalUnit = scheduleData["intervalUnit"] as? String ?: "minutes"
        
        val targetTime = Calendar.getInstance()
        targetTime.timeZone = calendar.timeZone
        targetTime.timeInMillis = calendar.timeInMillis
        
        // Calculate next occurrence based on interval
        while (targetTime.timeInMillis <= now) {
            when (intervalUnit.lowercase()) {
                "minutes" -> targetTime.add(Calendar.MINUTE, interval)
                "hours" -> targetTime.add(Calendar.HOUR_OF_DAY, interval)
                "days" -> targetTime.add(Calendar.DAY_OF_MONTH, interval)
                "weeks" -> targetTime.add(Calendar.WEEK_OF_YEAR, interval)
                "months" -> targetTime.add(Calendar.MONTH, interval)
                else -> return calendar.timeInMillis
            }
        }
        
        return targetTime.timeInMillis
    }

    private fun weekDayToCalendar(weekDay: String): Int {
        return when (weekDay.lowercase()) {
            "sunday" -> Calendar.SUNDAY
            "monday" -> Calendar.MONDAY
            "tuesday" -> Calendar.TUESDAY
            "wednesday" -> Calendar.WEDNESDAY
            "thursday" -> Calendar.THURSDAY
            "friday" -> Calendar.FRIDAY
            "saturday" -> Calendar.SATURDAY
            else -> Calendar.SUNDAY
        }
    }

    private fun scheduleAlarm(triggerTime: Long, pendingIntent: PendingIntent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerTime,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                triggerTime,
                pendingIntent
            )
        }
    }

    private fun createAlarmIntent(
        scheduleId: Int,
        notificationData: Map<String, Any>,
        scheduleData: Map<String, Any>?
    ): Intent {
        return Intent(context, ScheduledNotificationReceiver::class.java).apply {
            putExtra("scheduleId", scheduleId)
            putExtra("notificationData", HashMap(notificationData))
            if (scheduleData != null) {
                putExtra("scheduleData", HashMap(scheduleData))
            }
        }
    }

    private fun generateScheduleId(notificationId: Int): Int {
        return REQUEST_CODE_BASE + notificationId
    }
}
