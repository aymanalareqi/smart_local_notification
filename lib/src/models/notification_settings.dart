import '../enums/notification_priority.dart';

/// Configuration settings for notifications.
class NotificationSettings {
  /// The priority level of the notification.
  final NotificationPriority priority;

  /// Whether the notification should be silent (no default system sound).
  final bool silent;

  /// The notification channel ID (Android only).
  /// If null, a default channel will be used.
  final String? channelId;

  /// The notification channel name (Android only).
  /// If null, a default channel name will be used.
  final String? channelName;

  /// The notification channel description (Android only).
  final String? channelDescription;

  /// Custom notification icon resource name (Android only).
  /// Should be the name of a drawable resource in the app.
  final String? icon;

  /// Whether the notification should show a timestamp.
  final bool showTimestamp;

  /// Whether the notification should be ongoing (cannot be dismissed).
  final bool ongoing;

  /// Whether the notification should auto-cancel when tapped.
  final bool autoCancel;

  /// Custom color for the notification (Android only).
  /// Represented as an integer color value.
  final int? color;

  /// Whether to show the notification on the lock screen.
  final bool showOnLockScreen;

  /// Large icon for the notification (Android only).
  /// Should be the name of a drawable resource in the app.
  final String? largeIcon;

  /// Creates a new [NotificationSettings] instance.
  const NotificationSettings({
    this.priority = NotificationPriority.defaultPriority,
    this.silent = true,
    this.channelId,
    this.channelName,
    this.channelDescription,
    this.icon,
    this.showTimestamp = true,
    this.ongoing = false,
    this.autoCancel = true,
    this.color,
    this.showOnLockScreen = true,
    this.largeIcon,
  });

  /// Creates a copy of this [NotificationSettings] with the given fields replaced.
  NotificationSettings copyWith({
    NotificationPriority? priority,
    bool? silent,
    String? channelId,
    String? channelName,
    String? channelDescription,
    String? icon,
    bool? showTimestamp,
    bool? ongoing,
    bool? autoCancel,
    int? color,
    bool? showOnLockScreen,
    String? largeIcon,
  }) {
    return NotificationSettings(
      priority: priority ?? this.priority,
      silent: silent ?? this.silent,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      channelDescription: channelDescription ?? this.channelDescription,
      icon: icon ?? this.icon,
      showTimestamp: showTimestamp ?? this.showTimestamp,
      ongoing: ongoing ?? this.ongoing,
      autoCancel: autoCancel ?? this.autoCancel,
      color: color ?? this.color,
      showOnLockScreen: showOnLockScreen ?? this.showOnLockScreen,
      largeIcon: largeIcon ?? this.largeIcon,
    );
  }

  /// Converts this [NotificationSettings] to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'priority': priority.value,
      'silent': silent,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'icon': icon,
      'showTimestamp': showTimestamp,
      'ongoing': ongoing,
      'autoCancel': autoCancel,
      'color': color,
      'showOnLockScreen': showOnLockScreen,
      'largeIcon': largeIcon,
    };
  }

  /// Creates a [NotificationSettings] from a map.
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      priority: NotificationPriorityExtension.fromString(map['priority'] ?? 'default'),
      silent: map['silent'] ?? true,
      channelId: map['channelId'],
      channelName: map['channelName'],
      channelDescription: map['channelDescription'],
      icon: map['icon'],
      showTimestamp: map['showTimestamp'] ?? true,
      ongoing: map['ongoing'] ?? false,
      autoCancel: map['autoCancel'] ?? true,
      color: map['color'],
      showOnLockScreen: map['showOnLockScreen'] ?? true,
      largeIcon: map['largeIcon'],
    );
  }

  @override
  String toString() {
    return 'NotificationSettings('
        'priority: $priority, '
        'silent: $silent, '
        'channelId: $channelId, '
        'channelName: $channelName, '
        'channelDescription: $channelDescription, '
        'icon: $icon, '
        'showTimestamp: $showTimestamp, '
        'ongoing: $ongoing, '
        'autoCancel: $autoCancel, '
        'color: $color, '
        'showOnLockScreen: $showOnLockScreen, '
        'largeIcon: $largeIcon'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.priority == priority &&
        other.silent == silent &&
        other.channelId == channelId &&
        other.channelName == channelName &&
        other.channelDescription == channelDescription &&
        other.icon == icon &&
        other.showTimestamp == showTimestamp &&
        other.ongoing == ongoing &&
        other.autoCancel == autoCancel &&
        other.color == color &&
        other.showOnLockScreen == showOnLockScreen &&
        other.largeIcon == largeIcon;
  }

  @override
  int get hashCode {
    return Object.hash(
      priority,
      silent,
      channelId,
      channelName,
      channelDescription,
      icon,
      showTimestamp,
      ongoing,
      autoCancel,
      color,
      showOnLockScreen,
      largeIcon,
    );
  }
}
