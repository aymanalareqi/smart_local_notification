package com.example.smart_local_notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class ScheduledNotificationReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "ScheduledNotificationReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Received scheduled notification broadcast")
        
        try {
            val scheduleId = intent.getIntExtra("scheduleId", -1)
            val notificationData = intent.getSerializableExtra("notificationData") as? HashMap<String, Any>
            val scheduleData = intent.getSerializableExtra("scheduleData") as? HashMap<String, Any>
            
            if (scheduleId == -1 || notificationData == null) {
                Log.e(TAG, "Invalid notification data received")
                return
            }
            
            Log.d(TAG, "Processing scheduled notification with ID: $scheduleId")
            
            // Initialize managers
            val notificationManager = SmartNotificationManager(context)
            val audioManager = SmartAudioManager(context)
            val scheduleManager = SmartScheduleManager(context)
            val persistenceManager = NotificationPersistenceManager(context)
            
            // Show the notification
            val notificationId = notificationData["id"] as? Int ?: scheduleId
            val title = notificationData["title"] as? String ?: "Scheduled Notification"
            val body = notificationData["body"] as? String ?: "This is a scheduled notification"
            val notificationSettings = notificationData["notificationSettings"] as? Map<String, Any> ?: emptyMap()
            val audioSettings = notificationData["audioSettings"] as? Map<String, Any>
            
            val success = notificationManager.showNotification(
                notificationId,
                title,
                body,
                notificationSettings
            )
            
            if (success) {
                Log.d(TAG, "Successfully showed scheduled notification $notificationId")
                
                // Play audio if configured
                if (audioSettings != null) {
                    audioManager.playAudio(audioSettings)
                }
                
                // Update persistence
                persistenceManager.incrementTriggerCount(scheduleId)
                
                // Handle recurring notifications
                handleRecurringNotification(context, scheduleId, notificationData, scheduleData)
            } else {
                Log.e(TAG, "Failed to show scheduled notification $notificationId")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error processing scheduled notification", e)
        }
    }
    
    private fun handleRecurringNotification(
        context: Context,
        scheduleId: Int,
        notificationData: HashMap<String, Any>,
        scheduleData: HashMap<String, Any>?
    ) {
        if (scheduleData == null) return
        
        val scheduleType = scheduleData["scheduleType"] as? String
        if (scheduleType == null || scheduleType == "oneTime") {
            // One-time notification, remove from persistence
            val persistenceManager = NotificationPersistenceManager(context)
            persistenceManager.markAsInactive(scheduleId)
            return
        }
        
        try {
            val scheduleManager = SmartScheduleManager(context)
            val persistenceManager = NotificationPersistenceManager(context)
            
            // Check if we've reached the maximum occurrences
            val maxOccurrences = scheduleData["maxOccurrences"] as? Int
            if (maxOccurrences != null) {
                val currentData = persistenceManager.getScheduledNotification(scheduleId)
                val triggerCount = currentData?.get("triggerCount") as? Int ?: 0
                
                if (triggerCount >= maxOccurrences) {
                    Log.d(TAG, "Reached maximum occurrences for notification $scheduleId")
                    persistenceManager.markAsInactive(scheduleId)
                    return
                }
            }
            
            // Check if we've passed the end date
            val endDate = scheduleData["endDate"] as? Long
            if (endDate != null && System.currentTimeMillis() > endDate) {
                Log.d(TAG, "Passed end date for notification $scheduleId")
                persistenceManager.markAsInactive(scheduleId)
                return
            }
            
            // Schedule the next occurrence
            val success = scheduleManager.scheduleNotification(notificationData, scheduleData)
            if (success) {
                Log.d(TAG, "Scheduled next occurrence for recurring notification $scheduleId")
            } else {
                Log.e(TAG, "Failed to schedule next occurrence for notification $scheduleId")
                persistenceManager.markAsInactive(scheduleId)
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error handling recurring notification $scheduleId", e)
        }
    }
}
