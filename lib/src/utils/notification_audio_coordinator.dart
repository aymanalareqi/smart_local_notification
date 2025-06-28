import '../models/smart_notification.dart';
import '../models/notification_settings.dart';
import '../models/audio_settings.dart';
import '../enums/notification_priority.dart';

/// Utility class for coordinating silent notifications with custom audio playback.
/// 
/// This class ensures that notifications are properly configured for silent operation
/// when custom audio is present, and provides methods for optimizing the notification
/// and audio settings for the best user experience.
class NotificationAudioCoordinator {
  
  /// Optimizes a notification for silent operation with custom audio.
  /// 
  /// This method ensures that:
  /// - Notifications with audio are configured to be silent
  /// - Audio settings are validated and optimized
  /// - Notification priority is adjusted for better visibility
  /// 
  /// [notification] - The original notification to optimize
  /// 
  /// Returns an optimized [SmartNotification] instance.
  static SmartNotification optimizeForSilentAudio(SmartNotification notification) {
    if (!notification.hasAudio) {
      // No audio, return notification as-is
      return notification;
    }

    // Optimize notification settings for silent operation
    final optimizedNotificationSettings = _optimizeNotificationSettings(
      notification.notificationSettings,
      notification.audioSettings!,
    );

    // Optimize audio settings
    final optimizedAudioSettings = _optimizeAudioSettings(
      notification.audioSettings!,
    );

    return notification.copyWith(
      notificationSettings: optimizedNotificationSettings,
      audioSettings: optimizedAudioSettings,
    );
  }

  /// Optimizes notification settings for silent operation with custom audio.
  static NotificationSettings _optimizeNotificationSettings(
    NotificationSettings settings,
    AudioSettings audioSettings,
  ) {
    return settings.copyWith(
      // Force silent notification when custom audio is present
      silent: true,
      
      // Increase priority to ensure notification is visible
      priority: _getOptimalPriority(settings.priority, audioSettings),
      
      // Ensure notification shows on lock screen for better visibility
      showOnLockScreen: true,
      
      // Make notification ongoing if audio is looping
      ongoing: audioSettings.loop ? true : settings.ongoing,
      
      // Auto-cancel should be false for looping audio to prevent accidental dismissal
      autoCancel: audioSettings.loop ? false : settings.autoCancel,
    );
  }

  /// Optimizes audio settings for better performance and user experience.
  static AudioSettings _optimizeAudioSettings(AudioSettings settings) {
    return settings.copyWith(
      // Ensure background playback is enabled for notifications
      playInBackground: true,
      
      // Duck other audio by default for notification sounds
      duckOthers: settings.duckOthers,
      
      // Don't interrupt other audio unless explicitly requested
      interruptOthers: settings.interruptOthers,
      
      // Respect silent mode setting (user preference)
      respectSilentMode: settings.respectSilentMode,
    );
  }

  /// Determines the optimal notification priority based on audio settings.
  static NotificationPriority _getOptimalPriority(
    NotificationPriority currentPriority,
    AudioSettings audioSettings,
  ) {
    // If audio is looping, use high priority to ensure visibility
    if (audioSettings.loop) {
      return NotificationPriority.high;
    }

    // If current priority is too low, bump it up for better visibility
    if (currentPriority == NotificationPriority.min || 
        currentPriority == NotificationPriority.low) {
      return NotificationPriority.defaultPriority;
    }

    // Otherwise, keep the current priority
    return currentPriority;
  }

  /// Validates that a notification is properly configured for silent audio operation.
  /// 
  /// [notification] - The notification to validate
  /// 
  /// Returns a [ValidationResult] with validation details.
  static ValidationResult validateSilentAudioConfiguration(SmartNotification notification) {
    final issues = <String>[];
    final warnings = <String>[];

    if (!notification.hasAudio) {
      return ValidationResult(
        isValid: true,
        issues: issues,
        warnings: warnings,
      );
    }

    final audioSettings = notification.audioSettings!;
    final notificationSettings = notification.notificationSettings;

    // Check if notification is properly configured for silent operation
    if (!notificationSettings.silent) {
      warnings.add('Notification should be silent when custom audio is present. '
          'Consider setting silent: true in NotificationSettings.');
    }

    // Check audio settings
    if (!audioSettings.playInBackground) {
      warnings.add('Audio playback in background is disabled. '
          'Audio may stop when app is backgrounded.');
    }

    // Check for potential conflicts
    if (audioSettings.respectSilentMode && audioSettings.loop) {
      warnings.add('Looping audio with respectSilentMode enabled may not play '
          'when device is in silent mode.');
    }

    // Check priority for looping audio
    if (audioSettings.loop && 
        (notificationSettings.priority == NotificationPriority.min || 
         notificationSettings.priority == NotificationPriority.low)) {
      warnings.add('Low priority notifications with looping audio may not be '
          'visible to users. Consider using higher priority.');
    }

    // Check auto-cancel for looping audio
    if (audioSettings.loop && notificationSettings.autoCancel) {
      warnings.add('Auto-cancel enabled for looping audio may cause '
          'notification to disappear while audio is still playing.');
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      warnings: warnings,
    );
  }

  /// Creates a notification optimized for alarm-like behavior.
  /// 
  /// This creates a notification with settings optimized for important alerts
  /// that need to be noticed by the user, similar to alarm apps.
  static SmartNotification createAlarmStyleNotification({
    required int id,
    required String title,
    required String body,
    required AudioSettings audioSettings,
    Map<String, dynamic>? payload,
    DateTime? scheduledTime,
  }) {
    final notificationSettings = NotificationSettings(
      priority: NotificationPriority.max,
      silent: true, // Silent notification with custom audio
      ongoing: audioSettings.loop, // Ongoing if looping
      autoCancel: false, // Don't auto-cancel for alarms
      showOnLockScreen: true,
      showTimestamp: true,
    );

    final optimizedAudioSettings = audioSettings.copyWith(
      playInBackground: true,
      duckOthers: true,
      interruptOthers: false, // Don't interrupt other audio unless needed
      respectSilentMode: false, // Alarms should play even in silent mode
    );

    return SmartNotification(
      id: id,
      title: title,
      body: body,
      notificationSettings: notificationSettings,
      audioSettings: optimizedAudioSettings,
      payload: payload,
      scheduledTime: scheduledTime,
    );
  }

  /// Creates a notification optimized for gentle reminder behavior.
  /// 
  /// This creates a notification with settings optimized for non-intrusive
  /// reminders that respect user preferences.
  static SmartNotification createReminderStyleNotification({
    required int id,
    required String title,
    required String body,
    required AudioSettings audioSettings,
    Map<String, dynamic>? payload,
    DateTime? scheduledTime,
  }) {
    final notificationSettings = NotificationSettings(
      priority: NotificationPriority.defaultPriority,
      silent: true, // Silent notification with custom audio
      ongoing: false,
      autoCancel: true,
      showOnLockScreen: true,
      showTimestamp: true,
    );

    final optimizedAudioSettings = audioSettings.copyWith(
      playInBackground: true,
      duckOthers: true,
      interruptOthers: false,
      respectSilentMode: true, // Respect silent mode for reminders
      loop: false, // Don't loop reminders
    );

    return SmartNotification(
      id: id,
      title: title,
      body: body,
      notificationSettings: notificationSettings,
      audioSettings: optimizedAudioSettings,
      payload: payload,
      scheduledTime: scheduledTime,
    );
  }
}

/// Result of notification configuration validation.
class ValidationResult {
  /// Whether the configuration is valid.
  final bool isValid;

  /// List of critical issues that prevent proper operation.
  final List<String> issues;

  /// List of warnings about potential problems.
  final List<String> warnings;

  /// Creates a new [ValidationResult].
  const ValidationResult({
    required this.isValid,
    required this.issues,
    required this.warnings,
  });

  /// Whether there are any warnings.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Whether there are any issues.
  bool get hasIssues => issues.isNotEmpty;

  @override
  String toString() {
    return 'ValidationResult('
        'isValid: $isValid, '
        'issues: $issues, '
        'warnings: $warnings'
        ')';
  }
}
