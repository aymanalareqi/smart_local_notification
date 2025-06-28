/// Defines the priority level for notifications.
/// 
/// This affects how the notification is displayed and its behavior
/// on different platforms.
enum NotificationPriority {
  /// Minimum priority - may not be shown in some cases.
  min,
  
  /// Low priority - shown in notification shade but not as heads-up.
  low,
  
  /// Default priority - standard notification behavior.
  defaultPriority,
  
  /// High priority - may show as heads-up notification.
  high,
  
  /// Maximum priority - always shows as heads-up notification.
  max,
}

/// Extension methods for [NotificationPriority].
extension NotificationPriorityExtension on NotificationPriority {
  /// Returns the string representation of the notification priority.
  String get value {
    switch (this) {
      case NotificationPriority.min:
        return 'min';
      case NotificationPriority.low:
        return 'low';
      case NotificationPriority.defaultPriority:
        return 'default';
      case NotificationPriority.high:
        return 'high';
      case NotificationPriority.max:
        return 'max';
    }
  }

  /// Returns the Android priority value.
  int get androidValue {
    switch (this) {
      case NotificationPriority.min:
        return -2; // NotificationCompat.PRIORITY_MIN
      case NotificationPriority.low:
        return -1; // NotificationCompat.PRIORITY_LOW
      case NotificationPriority.defaultPriority:
        return 0; // NotificationCompat.PRIORITY_DEFAULT
      case NotificationPriority.high:
        return 1; // NotificationCompat.PRIORITY_HIGH
      case NotificationPriority.max:
        return 2; // NotificationCompat.PRIORITY_MAX
    }
  }

  /// Creates a [NotificationPriority] from a string value.
  static NotificationPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'min':
        return NotificationPriority.min;
      case 'low':
        return NotificationPriority.low;
      case 'default':
        return NotificationPriority.defaultPriority;
      case 'high':
        return NotificationPriority.high;
      case 'max':
        return NotificationPriority.max;
      default:
        throw ArgumentError('Invalid NotificationPriority: $value');
    }
  }
}
