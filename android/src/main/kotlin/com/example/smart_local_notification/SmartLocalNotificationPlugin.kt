package com.example.smart_local_notification

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** SmartLocalNotificationPlugin */
class SmartLocalNotificationPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var notificationManager: SmartNotificationManager? = null
  private var audioManager: SmartAudioManager? = null
  private var permissionManager: SmartPermissionManager? = null
  private var scheduleManager: SmartScheduleManager? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "smart_local_notification")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    
    // Initialize managers
    notificationManager = SmartNotificationManager(context)
    audioManager = SmartAudioManager(context)
    permissionManager = SmartPermissionManager(context)
    scheduleManager = SmartScheduleManager(context)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initialize" -> initialize(result)
      "showNotification" -> showNotification(call, result)
      "cancelNotification" -> cancelNotification(call, result)
      "cancelAllNotifications" -> cancelAllNotifications(result)
      "stopAudio" -> stopAudio(result)
      "isAudioPlaying" -> isAudioPlaying(result)
      "requestPermissions" -> requestPermissions(result)
      "arePermissionsGranted" -> arePermissionsGranted(result)
      "scheduleNotification" -> scheduleNotification(call, result)
      "cancelScheduledNotification" -> cancelScheduledNotification(call, result)
      "cancelAllScheduledNotifications" -> cancelAllScheduledNotifications(result)
      "getScheduledNotifications" -> getScheduledNotifications(call, result)
      "updateScheduledNotification" -> updateScheduledNotification(call, result)
      else -> result.notImplemented()
    }
  }

  private fun initialize(result: Result) {
    try {
      notificationManager?.initialize()
      audioManager?.initialize()
      result.success(true)
    } catch (e: Exception) {
      result.success(false)
    }
  }

  private fun showNotification(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<String, Any> ?: run {
        result.error("INVALID_ARGUMENTS", "Invalid arguments provided", null)
        return
      }

      val id = args["id"] as? Int ?: run {
        result.error("MISSING_ID", "Notification ID is required", null)
        return
      }

      val title = args["title"] as? String ?: ""
      val body = args["body"] as? String ?: ""
      val notificationSettings = args["notificationSettings"] as? Map<String, Any> ?: emptyMap()
      val audioSettings = args["audioSettings"] as? Map<String, Any>
      val scheduleData = args["schedule"] as? Map<String, Any>

      // Check if this is a scheduled notification
      if (scheduleData != null || args["scheduledTime"] != null) {
        val scheduled = scheduleManager?.scheduleNotification(args, scheduleData) ?: false
        result.success(scheduled)
        return
      }

      // Show immediate notification
      val notificationShown = notificationManager?.showNotification(
        id, title, body, notificationSettings
      ) ?: false

      // Play audio if settings provided
      if (audioSettings != null && notificationShown) {
        audioManager?.playAudio(audioSettings)
      }

      result.success(notificationShown)
    } catch (e: Exception) {
      result.error("SHOW_NOTIFICATION_ERROR", e.message, null)
    }
  }

  private fun cancelNotification(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<String, Any> ?: run {
        result.error("INVALID_ARGUMENTS", "Invalid arguments provided", null)
        return
      }

      val id = args["id"] as? Int ?: run {
        result.error("MISSING_ID", "Notification ID is required", null)
        return
      }

      notificationManager?.cancelNotification(id)
      result.success(true)
    } catch (e: Exception) {
      result.error("CANCEL_NOTIFICATION_ERROR", e.message, null)
    }
  }

  private fun cancelAllNotifications(result: Result) {
    try {
      notificationManager?.cancelAllNotifications()
      result.success(true)
    } catch (e: Exception) {
      result.error("CANCEL_ALL_NOTIFICATIONS_ERROR", e.message, null)
    }
  }

  private fun stopAudio(result: Result) {
    try {
      audioManager?.stopAudio()
      result.success(true)
    } catch (e: Exception) {
      result.error("STOP_AUDIO_ERROR", e.message, null)
    }
  }

  private fun isAudioPlaying(result: Result) {
    try {
      val isPlaying = audioManager?.isPlaying() ?: false
      result.success(isPlaying)
    } catch (e: Exception) {
      result.success(false)
    }
  }

  private fun requestPermissions(result: Result) {
    try {
      permissionManager?.requestPermissions(result)
    } catch (e: Exception) {
      result.success(false)
    }
  }

  private fun arePermissionsGranted(result: Result) {
    try {
      val granted = permissionManager?.arePermissionsGranted() ?: false
      result.success(granted)
    } catch (e: Exception) {
      result.success(false)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    audioManager?.cleanup()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    permissionManager?.setActivity(binding.activity)
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // No action needed
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    permissionManager?.setActivity(binding.activity)
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivity() {
    permissionManager?.setActivity(null)
  }

  override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<out String>,
    grantResults: IntArray
  ): Boolean {
    permissionManager?.handlePermissionResult(requestCode, permissions, grantResults)
    return true
  }

  private fun scheduleNotification(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<String, Any> ?: run {
        result.error("INVALID_ARGUMENTS", "Invalid arguments provided", null)
        return
      }

      val notificationData = args["notification"] as? Map<String, Any> ?: run {
        result.error("MISSING_NOTIFICATION", "Notification data is required", null)
        return
      }

      val scheduleData = args["schedule"] as? Map<String, Any>
      val scheduled = scheduleManager?.scheduleNotification(notificationData, scheduleData) ?: false
      result.success(scheduled)
    } catch (e: Exception) {
      result.error("SCHEDULE_NOTIFICATION_ERROR", e.message, null)
    }
  }

  private fun cancelScheduledNotification(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<String, Any> ?: run {
        result.error("INVALID_ARGUMENTS", "Invalid arguments provided", null)
        return
      }

      val id = args["id"] as? Int ?: run {
        result.error("MISSING_ID", "Notification ID is required", null)
        return
      }

      val cancelled = scheduleManager?.cancelScheduledNotification(id) ?: false
      result.success(cancelled)
    } catch (e: Exception) {
      result.error("CANCEL_SCHEDULED_NOTIFICATION_ERROR", e.message, null)
    }
  }

  private fun cancelAllScheduledNotifications(result: Result) {
    try {
      val cancelled = scheduleManager?.cancelAllScheduledNotifications() ?: false
      result.success(cancelled)
    } catch (e: Exception) {
      result.error("CANCEL_ALL_SCHEDULED_NOTIFICATIONS_ERROR", e.message, null)
    }
  }

  private fun getScheduledNotifications(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<String, Any> ?: emptyMap()
      val persistenceManager = NotificationPersistenceManager(context)

      val isActive = args["isActive"] as? Boolean
      val isRecurring = args["isRecurring"] as? Boolean
      val scheduledAfter = args["scheduledAfter"] as? Long
      val scheduledBefore = args["scheduledBefore"] as? Long
      val limit = args["limit"] as? Int
      val offset = args["offset"] as? Int

      val notifications = persistenceManager.getScheduledNotificationsByQuery(
        isActive, isRecurring, scheduledAfter, scheduledBefore, limit, offset
      )

      result.success(notifications)
    } catch (e: Exception) {
      result.error("GET_SCHEDULED_NOTIFICATIONS_ERROR", e.message, null)
    }
  }

  private fun updateScheduledNotification(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<String, Any> ?: run {
        result.error("INVALID_ARGUMENTS", "Invalid arguments provided", null)
        return
      }

      val scheduleId = args["scheduleId"] as? Int ?: run {
        result.error("MISSING_SCHEDULE_ID", "Schedule ID is required", null)
        return
      }

      val updates = args["updates"] as? Map<String, Any> ?: run {
        result.error("MISSING_UPDATES", "Updates data is required", null)
        return
      }

      val persistenceManager = NotificationPersistenceManager(context)
      persistenceManager.updateScheduledNotification(scheduleId, updates)
      result.success(true)
    } catch (e: Exception) {
      result.error("UPDATE_SCHEDULED_NOTIFICATION_ERROR", e.message, null)
    }
  }
}
