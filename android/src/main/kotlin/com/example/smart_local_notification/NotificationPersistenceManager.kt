package com.example.smart_local_notification

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class NotificationPersistenceManager(context: Context) {
    private val sharedPreferences: SharedPreferences = context.getSharedPreferences(
        PREFS_NAME, Context.MODE_PRIVATE
    )
    private val gson = Gson()

    companion object {
        private const val PREFS_NAME = "smart_local_notification_schedules"
        private const val KEY_SCHEDULED_NOTIFICATIONS = "scheduled_notifications"
        private const val TAG = "NotificationPersistence"
    }

    fun saveScheduledNotification(
        scheduleId: Int,
        notificationData: Map<String, Any>,
        scheduleData: Map<String, Any>?
    ) {
        try {
            val allSchedules = getAllScheduledNotifications().toMutableMap()
            
            val scheduleInfo = mapOf(
                "scheduleId" to scheduleId,
                "notification" to notificationData,
                "schedule" to scheduleData,
                "createdAt" to System.currentTimeMillis(),
                "updatedAt" to System.currentTimeMillis(),
                "triggerCount" to 0,
                "isActive" to true
            )
            
            allSchedules[scheduleId] = scheduleInfo
            saveAllScheduledNotifications(allSchedules)
            
            Log.d(TAG, "Saved scheduled notification with ID: $scheduleId")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to save scheduled notification $scheduleId", e)
        }
    }

    fun removeScheduledNotification(scheduleId: Int) {
        try {
            val allSchedules = getAllScheduledNotifications().toMutableMap()
            allSchedules.remove(scheduleId)
            saveAllScheduledNotifications(allSchedules)
            
            Log.d(TAG, "Removed scheduled notification with ID: $scheduleId")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to remove scheduled notification $scheduleId", e)
        }
    }

    fun getScheduledNotification(scheduleId: Int): Map<String, Any>? {
        return try {
            getAllScheduledNotifications()[scheduleId]
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get scheduled notification $scheduleId", e)
            null
        }
    }

    fun getAllScheduledNotifications(): Map<Int, Map<String, Any>> {
        return try {
            val json = sharedPreferences.getString(KEY_SCHEDULED_NOTIFICATIONS, "{}")
            if (json.isNullOrEmpty() || json == "{}") {
                emptyMap()
            } else {
                val type = object : TypeToken<Map<String, Map<String, Any>>>() {}.type
                val stringKeyMap: Map<String, Map<String, Any>> = gson.fromJson(json, type) ?: emptyMap()
                
                // Convert string keys to int keys
                stringKeyMap.mapKeys { it.key.toIntOrNull() ?: 0 }
                    .filterKeys { it != 0 }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get all scheduled notifications", e)
            emptyMap()
        }
    }

    fun updateScheduledNotification(
        scheduleId: Int,
        updates: Map<String, Any>
    ) {
        try {
            val allSchedules = getAllScheduledNotifications().toMutableMap()
            val existing = allSchedules[scheduleId]?.toMutableMap() ?: return
            
            existing.putAll(updates)
            existing["updatedAt"] = System.currentTimeMillis()
            
            allSchedules[scheduleId] = existing
            saveAllScheduledNotifications(allSchedules)
            
            Log.d(TAG, "Updated scheduled notification with ID: $scheduleId")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to update scheduled notification $scheduleId", e)
        }
    }

    fun incrementTriggerCount(scheduleId: Int) {
        try {
            val allSchedules = getAllScheduledNotifications().toMutableMap()
            val existing = allSchedules[scheduleId]?.toMutableMap() ?: return
            
            val currentCount = existing["triggerCount"] as? Int ?: 0
            existing["triggerCount"] = currentCount + 1
            existing["updatedAt"] = System.currentTimeMillis()
            
            allSchedules[scheduleId] = existing
            saveAllScheduledNotifications(allSchedules)
            
            Log.d(TAG, "Incremented trigger count for notification $scheduleId to ${currentCount + 1}")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to increment trigger count for notification $scheduleId", e)
        }
    }

    fun markAsInactive(scheduleId: Int) {
        updateScheduledNotification(scheduleId, mapOf("isActive" to false))
    }

    fun clearAllScheduledNotifications() {
        try {
            sharedPreferences.edit()
                .remove(KEY_SCHEDULED_NOTIFICATIONS)
                .apply()
            
            Log.d(TAG, "Cleared all scheduled notifications")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to clear all scheduled notifications", e)
        }
    }

    fun getActiveScheduledNotifications(): Map<Int, Map<String, Any>> {
        return getAllScheduledNotifications().filter { (_, data) ->
            data["isActive"] as? Boolean ?: true
        }
    }

    fun getExpiredScheduledNotifications(): Map<Int, Map<String, Any>> {
        val now = System.currentTimeMillis()
        return getAllScheduledNotifications().filter { (_, data) ->
            val scheduleData = data["schedule"] as? Map<String, Any>
            val endDate = scheduleData?.get("endDate") as? Long
            val maxOccurrences = scheduleData?.get("maxOccurrences") as? Int
            val triggerCount = data["triggerCount"] as? Int ?: 0
            val isActive = data["isActive"] as? Boolean ?: true
            
            !isActive || 
            (endDate != null && now > endDate) ||
            (maxOccurrences != null && triggerCount >= maxOccurrences)
        }
    }

    fun cleanupExpiredNotifications() {
        try {
            val expired = getExpiredScheduledNotifications()
            val allSchedules = getAllScheduledNotifications().toMutableMap()
            
            for (scheduleId in expired.keys) {
                allSchedules.remove(scheduleId)
            }
            
            saveAllScheduledNotifications(allSchedules)
            
            Log.d(TAG, "Cleaned up ${expired.size} expired notifications")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to cleanup expired notifications", e)
        }
    }

    fun getScheduledNotificationsByQuery(
        isActive: Boolean? = null,
        isRecurring: Boolean? = null,
        scheduledAfter: Long? = null,
        scheduledBefore: Long? = null,
        limit: Int? = null,
        offset: Int? = null
    ): List<Map<String, Any>> {
        return try {
            var results = getAllScheduledNotifications().values.toList()
            
            // Apply filters
            if (isActive != null) {
                results = results.filter { (it["isActive"] as? Boolean ?: true) == isActive }
            }
            
            if (isRecurring != null) {
                results = results.filter { data ->
                    val scheduleData = data["schedule"] as? Map<String, Any>
                    val scheduleType = scheduleData?.get("scheduleType") as? String
                    val recurring = scheduleType != null && scheduleType != "oneTime"
                    recurring == isRecurring
                }
            }
            
            if (scheduledAfter != null) {
                results = results.filter { data ->
                    val scheduleData = data["schedule"] as? Map<String, Any>
                    val scheduledTime = scheduleData?.get("scheduledTime") as? Long
                    scheduledTime != null && scheduledTime > scheduledAfter
                }
            }
            
            if (scheduledBefore != null) {
                results = results.filter { data ->
                    val scheduleData = data["schedule"] as? Map<String, Any>
                    val scheduledTime = scheduleData?.get("scheduledTime") as? Long
                    scheduledTime != null && scheduledTime < scheduledBefore
                }
            }
            
            // Apply pagination
            if (offset != null && offset > 0) {
                results = results.drop(offset)
            }
            
            if (limit != null && limit > 0) {
                results = results.take(limit)
            }
            
            results
        } catch (e: Exception) {
            Log.e(TAG, "Failed to query scheduled notifications", e)
            emptyList()
        }
    }

    private fun saveAllScheduledNotifications(schedules: Map<Int, Map<String, Any>>) {
        try {
            // Convert int keys to string keys for JSON serialization
            val stringKeyMap = schedules.mapKeys { it.key.toString() }
            val json = gson.toJson(stringKeyMap)
            
            sharedPreferences.edit()
                .putString(KEY_SCHEDULED_NOTIFICATIONS, json)
                .apply()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to save scheduled notifications", e)
        }
    }

    fun getStatistics(): Map<String, Any> {
        return try {
            val all = getAllScheduledNotifications()
            val active = getActiveScheduledNotifications()
            val expired = getExpiredScheduledNotifications()
            
            val recurring = all.values.count { data ->
                val scheduleData = data["schedule"] as? Map<String, Any>
                val scheduleType = scheduleData?.get("scheduleType") as? String
                scheduleType != null && scheduleType != "oneTime"
            }
            
            mapOf(
                "total" to all.size,
                "active" to active.size,
                "expired" to expired.size,
                "recurring" to recurring,
                "oneTime" to (all.size - recurring)
            )
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get statistics", e)
            emptyMap()
        }
    }
}
