package com.example.smart_local_notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.util.Log

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_PACKAGE_REPLACED -> {
                // Handle device boot or app update
                // This can be used to reschedule any persistent notifications
                // or restore audio playback state if needed
                handleBootCompleted(context)
            }
        }
    }

    private fun handleBootCompleted(context: Context) {
        // Initialize any necessary components after boot
        // This could include restoring scheduled notifications
        // or setting up background services if needed

        try {
            // Reschedule all active notifications after boot
            val scheduleManager = SmartScheduleManager(context)
            scheduleManager.rescheduleAllNotifications()

            // Clean up expired notifications
            val persistenceManager = NotificationPersistenceManager(context)
            persistenceManager.cleanupExpiredNotifications()

            Log.d("BootReceiver", "Successfully restored scheduled notifications after boot")
        } catch (e: Exception) {
            Log.e("BootReceiver", "Failed to restore scheduled notifications after boot", e)
        }
    }
}
