package com.example.smart_local_notification

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodChannel

class SmartPermissionManager(private val context: Context) {
    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null

    companion object {
        const val PERMISSION_REQUEST_CODE = 1001
        private val REQUIRED_PERMISSIONS = arrayOf(
            Manifest.permission.POST_NOTIFICATIONS,
            Manifest.permission.WAKE_LOCK,
            Manifest.permission.FOREGROUND_SERVICE,
            Manifest.permission.VIBRATE
        )
    }

    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    fun requestPermissions(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            requestNotificationPermission(result)
        } else {
            // For older versions, check if notifications are enabled
            val enabled = NotificationManagerCompat.from(context).areNotificationsEnabled()
            result.success(enabled)
        }
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        val activity = this.activity
        if (activity == null) {
            result.success(false)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                // Store the result to respond later
                pendingResult = result
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    PERMISSION_REQUEST_CODE
                )
            } else {
                result.success(true)
            }
        } else {
            result.success(true)
        }
    }

    fun arePermissionsGranted(): Boolean {
        // Check notification permission
        val notificationPermissionGranted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            // For older versions, check if notifications are enabled
            NotificationManagerCompat.from(context).areNotificationsEnabled()
        }

        // Check other permissions
        val otherPermissionsGranted = REQUIRED_PERMISSIONS.all { permission ->
            if (permission == Manifest.permission.POST_NOTIFICATIONS && Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                true // Skip this check for older versions
            } else {
                ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
            }
        }

        return notificationPermissionGranted && otherPermissionsGranted
    }

    fun areNotificationsEnabled(): Boolean {
        return NotificationManagerCompat.from(context).areNotificationsEnabled()
    }

    fun checkSpecificPermission(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
    }

    fun shouldShowRequestPermissionRationale(permission: String): Boolean {
        val activity = this.activity ?: return false
        return ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
    }

    fun getRequiredPermissions(): Array<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            REQUIRED_PERMISSIONS
        } else {
            REQUIRED_PERMISSIONS.filter { it != Manifest.permission.POST_NOTIFICATIONS }.toTypedArray()
        }
    }

    fun getMissingPermissions(): List<String> {
        return getRequiredPermissions().filter { permission ->
            ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED
        }
    }

    fun handlePermissionResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        if (requestCode == PERMISSION_REQUEST_CODE && pendingResult != null) {
            val granted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            pendingResult?.success(granted)
            pendingResult = null
        }
    }
}
