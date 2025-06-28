package com.example.smart_local_notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class SmartNotificationManager(private val context: Context) {
    private val notificationManager = NotificationManagerCompat.from(context)
    private val systemNotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    companion object {
        const val DEFAULT_CHANNEL_ID = "smart_local_notification_default"
        const val DEFAULT_CHANNEL_NAME = "Smart Local Notifications"
        const val DEFAULT_CHANNEL_DESCRIPTION = "Notifications from Smart Local Notification plugin"
    }

    fun initialize() {
        createDefaultNotificationChannel()
    }

    private fun createDefaultNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                DEFAULT_CHANNEL_ID,
                DEFAULT_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = DEFAULT_CHANNEL_DESCRIPTION
                enableLights(true)
                lightColor = Color.BLUE
                enableVibration(true)
                setSound(null, null) // Silent by default
            }
            systemNotificationManager.createNotificationChannel(channel)
        }
    }

    fun showNotification(
        id: Int,
        title: String,
        body: String,
        settings: Map<String, Any>
    ): Boolean {
        try {
            val channelId = settings["channelId"] as? String ?: DEFAULT_CHANNEL_ID
            val channelName = settings["channelName"] as? String ?: DEFAULT_CHANNEL_NAME
            val channelDescription = settings["channelDescription"] as? String ?: DEFAULT_CHANNEL_DESCRIPTION
            val priority = settings["priority"] as? String ?: "default"
            val silent = settings["silent"] as? Boolean ?: true
            val ongoing = settings["ongoing"] as? Boolean ?: false
            val autoCancel = settings["autoCancel"] as? Boolean ?: true
            val showTimestamp = settings["showTimestamp"] as? Boolean ?: true
            val color = settings["color"] as? Int
            val icon = settings["icon"] as? String
            val largeIcon = settings["largeIcon"] as? String

            // Create custom channel if needed
            if (channelId != DEFAULT_CHANNEL_ID) {
                createCustomNotificationChannel(channelId, channelName, channelDescription, silent)
            }

            // Create notification intent
            val intent = Intent(context, NotificationReceiver::class.java).apply {
                putExtra("notificationId", id)
                putExtra("action", "tap")
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Build notification
            val notificationBuilder = NotificationCompat.Builder(context, channelId)
                .setContentTitle(title)
                .setContentText(body)
                .setContentIntent(pendingIntent)
                .setAutoCancel(autoCancel)
                .setOngoing(ongoing)
                .setShowWhen(showTimestamp)
                .setPriority(getPriorityValue(priority))

            // Set icon
            val iconResource = getIconResource(icon)
            if (iconResource != 0) {
                notificationBuilder.setSmallIcon(iconResource)
            } else {
                // Use default app icon
                notificationBuilder.setSmallIcon(android.R.drawable.ic_dialog_info)
            }

            // Set large icon
            if (largeIcon != null) {
                val largeIconResource = getIconResource(largeIcon)
                if (largeIconResource != 0) {
                    val bitmap = android.graphics.BitmapFactory.decodeResource(
                        context.resources,
                        largeIconResource
                    )
                    notificationBuilder.setLargeIcon(bitmap)
                }
            }

            // Set color
            if (color != null) {
                notificationBuilder.setColor(color)
            }

            // Set sound (silent if specified)
            if (silent) {
                notificationBuilder.setSound(null)
                notificationBuilder.setVibrate(null)
            }

            // Show notification
            notificationManager.notify(id, notificationBuilder.build())
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    private fun createCustomNotificationChannel(
        channelId: String,
        channelName: String,
        channelDescription: String,
        silent: Boolean
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = if (silent) {
                NotificationManager.IMPORTANCE_LOW
            } else {
                NotificationManager.IMPORTANCE_HIGH
            }

            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                if (silent) {
                    setSound(null, null)
                    enableVibration(false)
                } else {
                    enableVibration(true)
                }
            }
            systemNotificationManager.createNotificationChannel(channel)
        }
    }

    private fun getPriorityValue(priority: String): Int {
        return when (priority.lowercase()) {
            "min" -> NotificationCompat.PRIORITY_MIN
            "low" -> NotificationCompat.PRIORITY_LOW
            "default" -> NotificationCompat.PRIORITY_DEFAULT
            "high" -> NotificationCompat.PRIORITY_HIGH
            "max" -> NotificationCompat.PRIORITY_MAX
            else -> NotificationCompat.PRIORITY_DEFAULT
        }
    }

    private fun getIconResource(iconName: String?): Int {
        if (iconName == null) return 0
        return context.resources.getIdentifier(
            iconName,
            "drawable",
            context.packageName
        )
    }

    fun cancelNotification(id: Int) {
        notificationManager.cancel(id)
    }

    fun cancelAllNotifications() {
        notificationManager.cancelAll()
    }
}
