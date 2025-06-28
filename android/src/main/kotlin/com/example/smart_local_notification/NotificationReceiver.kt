package com.example.smart_local_notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class NotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra("notificationId", -1)
        val action = intent.getStringExtra("action")

        when (action) {
            "tap" -> {
                // Handle notification tap
                handleNotificationTap(context, notificationId)
            }
            "dismiss" -> {
                // Handle notification dismiss
                handleNotificationDismiss(context, notificationId)
            }
            "stop_audio" -> {
                // Handle stop audio action
                handleStopAudio(context)
            }
        }
    }

    private fun handleNotificationTap(context: Context, notificationId: Int) {
        // Launch the main app activity
        val packageManager = context.packageManager
        val launchIntent = packageManager.getLaunchIntentForPackage(context.packageName)
        launchIntent?.let { intent ->
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.putExtra("notificationId", notificationId)
            intent.putExtra("action", "tap")
            context.startActivity(intent)
        }
    }

    private fun handleNotificationDismiss(context: Context, notificationId: Int) {
        // Optionally stop audio when notification is dismissed
        // This can be configurable based on notification settings
    }

    private fun handleStopAudio(context: Context) {
        // Stop the audio playback service
        val serviceIntent = Intent(context, AudioPlaybackService::class.java)
        context.stopService(serviceIntent)
    }
}
