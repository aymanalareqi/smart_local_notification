import 'notification_settings.dart';
import 'audio_settings.dart';
import 'notification_schedule.dart';

/// Represents a smart notification with custom audio playback capabilities.
class SmartNotification {
  /// Unique identifier for the notification.
  final int id;

  /// The title of the notification.
  final String title;

  /// The body text of the notification.
  final String body;

  /// Configuration settings for the notification display.
  final NotificationSettings notificationSettings;

  /// Configuration settings for custom audio playback.
  /// If null, no audio will be played.
  final AudioSettings? audioSettings;

  /// Optional payload data to include with the notification.
  /// This data can be retrieved when the notification is tapped.
  final Map<String, dynamic>? payload;

  /// The scheduled time for the notification.
  /// If null, the notification will be shown immediately.
  /// @deprecated Use [schedule] instead for enhanced scheduling features.
  final DateTime? scheduledTime;

  /// Enhanced scheduling configuration for the notification.
  /// Supports one-time and recurring notifications with timezone handling.
  final NotificationSchedule? schedule;

  /// Creates a new [SmartNotification] instance.
  const SmartNotification({
    required this.id,
    required this.title,
    required this.body,
    this.notificationSettings = const NotificationSettings(),
    this.audioSettings,
    this.payload,
    this.scheduledTime,
    this.schedule,
  });

  /// Creates a copy of this [SmartNotification] with the given fields replaced.
  SmartNotification copyWith({
    int? id,
    String? title,
    String? body,
    NotificationSettings? notificationSettings,
    AudioSettings? audioSettings,
    Map<String, dynamic>? payload,
    DateTime? scheduledTime,
    NotificationSchedule? schedule,
  }) {
    return SmartNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      audioSettings: audioSettings ?? this.audioSettings,
      payload: payload ?? this.payload,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      schedule: schedule ?? this.schedule,
    );
  }

  /// Converts this [SmartNotification] to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'notificationSettings': notificationSettings.toMap(),
      'audioSettings': audioSettings?.toMap(),
      'payload': payload,
      'scheduledTime': scheduledTime?.millisecondsSinceEpoch,
      'schedule': schedule?.toMap(),
    };
  }

  /// Creates a [SmartNotification] from a map.
  factory SmartNotification.fromMap(Map<String, dynamic> map) {
    return SmartNotification(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      notificationSettings: map['notificationSettings'] != null
          ? NotificationSettings.fromMap(map['notificationSettings'])
          : const NotificationSettings(),
      audioSettings: map['audioSettings'] != null
          ? AudioSettings.fromMap(map['audioSettings'])
          : null,
      payload: map['payload'] != null
          ? Map<String, dynamic>.from(map['payload'])
          : null,
      scheduledTime: map['scheduledTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduledTime'])
          : null,
      schedule: map['schedule'] != null
          ? NotificationSchedule.fromMap(map['schedule'])
          : null,
    );
  }

  /// Whether this notification has audio settings configured.
  bool get hasAudio => audioSettings != null;

  /// Whether this notification is scheduled for a future time.
  bool get isScheduled {
    if (schedule != null) {
      return schedule!.getNextOccurrence() != null;
    }
    return scheduledTime != null && scheduledTime!.isAfter(DateTime.now());
  }

  /// Whether this notification should be shown immediately.
  bool get isImmediate {
    if (schedule != null) {
      final next = schedule!.getNextOccurrence();
      return next == null ||
          next.isBefore(DateTime.now().add(const Duration(seconds: 1)));
    }
    return scheduledTime == null || scheduledTime!.isBefore(DateTime.now());
  }

  /// Whether this notification has a recurring schedule.
  bool get isRecurring => schedule?.isRecurring ?? false;

  /// Gets the next occurrence time for this notification.
  DateTime? get nextOccurrence {
    if (schedule != null) {
      return schedule!.getNextOccurrence();
    }
    if (scheduledTime != null && scheduledTime!.isAfter(DateTime.now())) {
      return scheduledTime;
    }
    return null;
  }

  /// Gets the effective scheduled time (either from schedule or scheduledTime).
  DateTime? get effectiveScheduledTime {
    return nextOccurrence ?? scheduledTime;
  }

  @override
  String toString() {
    return 'SmartNotification('
        'id: $id, '
        'title: $title, '
        'body: $body, '
        'notificationSettings: $notificationSettings, '
        'audioSettings: $audioSettings, '
        'payload: $payload, '
        'scheduledTime: $scheduledTime, '
        'schedule: $schedule'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartNotification &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.notificationSettings == notificationSettings &&
        other.audioSettings == audioSettings &&
        other.payload == payload &&
        other.scheduledTime == scheduledTime &&
        other.schedule == schedule;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      body,
      notificationSettings,
      audioSettings,
      payload,
      scheduledTime,
      schedule,
    );
  }
}
