import 'dart:async';
import 'models/smart_notification.dart';
import 'models/scheduled_notification_info.dart';
import 'smart_local_notification_platform_interface.dart';

/// Main class for Smart Local Notification plugin.
///
/// This class provides a high-level API for displaying silent notifications
/// with custom audio playback capabilities.
class SmartLocalNotification {
  SmartLocalNotification._();

  /// Stream controller for notification events.
  static final StreamController<SmartNotificationEvent> _eventController =
      StreamController<SmartNotificationEvent>.broadcast();

  /// Stream of notification events.
  ///
  /// Listen to this stream to receive events when notifications are tapped,
  /// dismissed, or when audio playback starts/stops.
  static Stream<SmartNotificationEvent> get onNotificationEvent =>
      _eventController.stream;

  /// Initialize the plugin.
  ///
  /// This must be called before using any other methods.
  /// Returns `true` if initialization was successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final success = await SmartLocalNotification.initialize();
  /// if (success) {
  ///   print('Plugin initialized successfully');
  /// }
  /// ```
  static Future<bool> initialize() async {
    return SmartLocalNotificationPlatform.instance.initialize();
  }

  /// Show a notification with optional custom audio.
  ///
  /// [notification] - The notification configuration including audio settings.
  ///
  /// Returns `true` if the notification was shown successfully, `false` otherwise.
  ///
  /// This method implements the core feature of silent notifications with simultaneous
  /// custom audio playback. The notification will be displayed silently (without system
  /// sound) while custom audio plays independently through the audio system.
  ///
  /// Example:
  /// ```dart
  /// final notification = SmartNotification(
  ///   id: 1,
  ///   title: 'Custom Notification',
  ///   body: 'This notification has custom audio',
  ///   notificationSettings: NotificationSettings(
  ///     silent: true, // Ensures notification is silent
  ///   ),
  ///   audioSettings: AudioSettings(
  ///     audioPath: 'assets/custom_sound.mp3',
  ///     sourceType: AudioSourceType.asset,
  ///   ),
  /// );
  ///
  /// final success = await SmartLocalNotification.showNotification(notification);
  /// ```
  static Future<bool> showNotification(SmartNotification notification) async {
    // Validate audio settings if present
    if (notification.hasAudio) {
      final audioSettings = notification.audioSettings!;
      final validationResult = await audioSettings.validate();

      if (!validationResult.isValid) {
        _emitEvent(SmartNotificationEvent(
          type: SmartNotificationEventType.error,
          notificationId: notification.id,
          error: 'Audio validation failed: ${validationResult.error}',
        ));
        return false;
      }
    }

    // Ensure notification is configured for silent operation if audio is present
    SmartNotification processedNotification = notification;
    if (notification.hasAudio && !notification.notificationSettings.silent) {
      // Force silent notification when custom audio is present
      processedNotification = notification.copyWith(
        notificationSettings:
            notification.notificationSettings.copyWith(silent: true),
      );
    }

    try {
      final success = await SmartLocalNotificationPlatform.instance
          .showNotification(processedNotification);

      if (success && processedNotification.hasAudio) {
        _emitEvent(SmartNotificationEvent(
          type: SmartNotificationEventType.audioStarted,
          notificationId: processedNotification.id,
        ));
      }

      return success;
    } catch (e) {
      _emitEvent(SmartNotificationEvent(
        type: SmartNotificationEventType.error,
        notificationId: notification.id,
        error: 'Failed to show notification: $e',
      ));
      return false;
    }
  }

  /// Cancel a specific notification by its ID.
  ///
  /// [id] - The unique identifier of the notification to cancel.
  ///
  /// Returns `true` if the notification was cancelled successfully, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// await SmartLocalNotification.cancelNotification(1);
  /// ```
  static Future<bool> cancelNotification(int id) async {
    return SmartLocalNotificationPlatform.instance.cancelNotification(id);
  }

  /// Cancel all active notifications.
  ///
  /// Returns `true` if all notifications were cancelled successfully, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// await SmartLocalNotification.cancelAllNotifications();
  /// ```
  static Future<bool> cancelAllNotifications() async {
    return SmartLocalNotificationPlatform.instance.cancelAllNotifications();
  }

  /// Stop any currently playing audio.
  ///
  /// Returns `true` if audio was stopped successfully, `false` otherwise.
  ///
  /// This method stops the custom audio playback while leaving the notification
  /// visible. This is useful for implementing custom stop buttons or handling
  /// user interactions that should stop audio without dismissing the notification.
  ///
  /// Example:
  /// ```dart
  /// await SmartLocalNotification.stopAudio();
  /// ```
  static Future<bool> stopAudio() async {
    try {
      final success = await SmartLocalNotificationPlatform.instance.stopAudio();

      if (success) {
        _emitEvent(SmartNotificationEvent(
          type: SmartNotificationEventType.audioStopped,
        ));
      }

      return success;
    } catch (e) {
      _emitEvent(SmartNotificationEvent(
        type: SmartNotificationEventType.error,
        error: 'Failed to stop audio: $e',
      ));
      return false;
    }
  }

  /// Check if audio is currently playing.
  ///
  /// Returns `true` if audio is playing, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final isPlaying = await SmartLocalNotification.isAudioPlaying();
  /// if (isPlaying) {
  ///   print('Audio is currently playing');
  /// }
  /// ```
  static Future<bool> isAudioPlaying() async {
    return SmartLocalNotificationPlatform.instance.isAudioPlaying();
  }

  /// Request notification permissions from the user.
  ///
  /// Returns `true` if permissions were granted, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final granted = await SmartLocalNotification.requestPermissions();
  /// if (granted) {
  ///   print('Notification permissions granted');
  /// }
  /// ```
  static Future<bool> requestPermissions() async {
    return SmartLocalNotificationPlatform.instance.requestPermissions();
  }

  /// Check if notification permissions are currently granted.
  ///
  /// Returns `true` if permissions are granted, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final granted = await SmartLocalNotification.arePermissionsGranted();
  /// if (!granted) {
  ///   await SmartLocalNotification.requestPermissions();
  /// }
  /// ```
  static Future<bool> arePermissionsGranted() async {
    return SmartLocalNotificationPlatform.instance.arePermissionsGranted();
  }

  /// Schedule a notification for future delivery.
  ///
  /// [notification] - The notification to schedule with enhanced scheduling configuration.
  ///
  /// Returns `true` if the notification was scheduled successfully, `false` otherwise.
  ///
  /// This method supports both simple scheduled times and complex recurring patterns
  /// with timezone handling, end dates, and maximum occurrence limits.
  ///
  /// Example:
  /// ```dart
  /// final notification = SmartNotification(
  ///   id: 1,
  ///   title: 'Daily Reminder',
  ///   body: 'Don\'t forget your daily task',
  ///   schedule: NotificationSchedule.daily(
  ///     scheduledTime: DateTime(2024, 1, 1, 9, 0), // 9 AM
  ///     endDate: DateTime(2024, 12, 31),
  ///   ),
  ///   audioSettings: AudioSettings(
  ///     audioPath: 'athan.mp3',
  ///     sourceType: AudioSourceType.asset,
  ///   ),
  /// );
  ///
  /// final success = await SmartLocalNotification.scheduleNotification(notification);
  /// ```
  static Future<bool> scheduleNotification(
      SmartNotification notification) async {
    // Validate that the notification has scheduling information
    if (notification.schedule == null && notification.scheduledTime == null) {
      _emitEvent(SmartNotificationEvent(
        type: SmartNotificationEventType.error,
        notificationId: notification.id,
        error:
            'Notification must have schedule or scheduledTime for scheduling',
      ));
      return false;
    }

    // Validate schedule if present
    if (notification.schedule != null) {
      final schedule = notification.schedule!;
      if (!schedule.isValid) {
        _emitEvent(SmartNotificationEvent(
          type: SmartNotificationEventType.error,
          notificationId: notification.id,
          error: 'Invalid schedule configuration',
        ));
        return false;
      }

      final nextOccurrence = schedule.getNextOccurrence();
      if (nextOccurrence == null) {
        _emitEvent(SmartNotificationEvent(
          type: SmartNotificationEventType.error,
          notificationId: notification.id,
          error: 'No future occurrences for this schedule',
        ));
        return false;
      }
    }

    try {
      final success = await SmartLocalNotificationPlatform.instance
          .scheduleNotification(notification);

      if (success) {
        _emitEvent(SmartNotificationEvent(
          type: SmartNotificationEventType.notificationScheduled,
          notificationId: notification.id,
        ));
      }

      return success;
    } catch (e) {
      _emitEvent(SmartNotificationEvent(
        type: SmartNotificationEventType.error,
        notificationId: notification.id,
        error: 'Failed to schedule notification: $e',
      ));
      return false;
    }
  }

  /// Cancel a scheduled notification by ID.
  ///
  /// [id] - The ID of the notification to cancel.
  ///
  /// Returns `true` if the notification was cancelled successfully, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// await SmartLocalNotification.cancelScheduledNotification(1);
  /// ```
  static Future<bool> cancelScheduledNotification(int id) async {
    try {
      final success = await SmartLocalNotificationPlatform.instance
          .cancelScheduledNotification(id);

      if (success) {
        _emitEvent(SmartNotificationEvent(
          type: SmartNotificationEventType.notificationCancelled,
          notificationId: id,
        ));
      }

      return success;
    } catch (e) {
      _emitEvent(SmartNotificationEvent(
        type: SmartNotificationEventType.error,
        notificationId: id,
        error: 'Failed to cancel scheduled notification: $e',
      ));
      return false;
    }
  }

  /// Cancel all scheduled notifications.
  ///
  /// Returns `true` if all notifications were cancelled successfully, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// await SmartLocalNotification.cancelAllScheduledNotifications();
  /// ```
  static Future<bool> cancelAllScheduledNotifications() async {
    try {
      final success = await SmartLocalNotificationPlatform.instance
          .cancelAllScheduledNotifications();

      if (success) {
        _emitEvent(SmartNotificationEvent(
          type: SmartNotificationEventType.allNotificationsCancelled,
        ));
      }

      return success;
    } catch (e) {
      _emitEvent(SmartNotificationEvent(
        type: SmartNotificationEventType.error,
        error: 'Failed to cancel all scheduled notifications: $e',
      ));
      return false;
    }
  }

  /// Get scheduled notifications based on query parameters.
  ///
  /// [query] - Optional query parameters to filter results.
  ///
  /// Returns a list of [ScheduledNotificationInfo] objects.
  ///
  /// Example:
  /// ```dart
  /// // Get all active scheduled notifications
  /// final activeNotifications = await SmartLocalNotification.getScheduledNotifications(
  ///   ScheduledNotificationQuery(isActive: true)
  /// );
  /// ```
  static Future<List<ScheduledNotificationInfo>> getScheduledNotifications(
      [ScheduledNotificationQuery? query]) async {
    try {
      return await SmartLocalNotificationPlatform.instance
          .getScheduledNotifications(query);
    } catch (e) {
      _emitEvent(SmartNotificationEvent(
        type: SmartNotificationEventType.error,
        error: 'Failed to get scheduled notifications: $e',
      ));
      return [];
    }
  }

  /// Emit a notification event.
  ///
  /// This method is used internally by the platform implementations
  /// to notify listeners of notification events.
  static void _emitEvent(SmartNotificationEvent event) {
    _eventController.add(event);
  }

  /// Dispose of resources.
  ///
  /// Call this method when you no longer need the plugin to clean up resources.
  static void dispose() {
    _eventController.close();
  }
}

/// Represents different types of notification events.
enum SmartNotificationEventType {
  /// Notification was tapped by the user.
  notificationTapped,

  /// Notification was dismissed by the user.
  notificationDismissed,

  /// Audio playback started.
  audioStarted,

  /// Audio playback stopped.
  audioStopped,

  /// Audio playback completed.
  audioCompleted,

  /// Notification was scheduled successfully.
  notificationScheduled,

  /// Notification was cancelled.
  notificationCancelled,

  /// All notifications were cancelled.
  allNotificationsCancelled,

  /// An error occurred.
  error,
}

/// Represents a notification event.
class SmartNotificationEvent {
  /// The type of event.
  final SmartNotificationEventType type;

  /// The notification ID associated with the event.
  final int? notificationId;

  /// Optional payload data associated with the event.
  final Map<String, dynamic>? payload;

  /// Error message if the event type is error.
  final String? error;

  /// Creates a new [SmartNotificationEvent].
  const SmartNotificationEvent({
    required this.type,
    this.notificationId,
    this.payload,
    this.error,
  });

  @override
  String toString() {
    return 'SmartNotificationEvent('
        'type: $type, '
        'notificationId: $notificationId, '
        'payload: $payload, '
        'error: $error'
        ')';
  }
}
