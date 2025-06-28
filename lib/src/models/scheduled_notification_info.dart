import 'package:smart_local_notification/smart_local_notification.dart';

import 'smart_notification.dart';
import 'notification_schedule.dart';

/// Information about a scheduled notification stored in the system.
class ScheduledNotificationInfo {
  /// The unique identifier for the scheduled notification.
  final String scheduleId;

  /// The notification configuration.
  final SmartNotification notification;

  /// When this notification was originally scheduled.
  final DateTime createdAt;

  /// When this notification was last updated.
  final DateTime updatedAt;

  /// The next scheduled occurrence time.
  final DateTime? nextOccurrence;

  /// Number of times this notification has been triggered.
  final int triggerCount;

  /// Whether this scheduled notification is currently active.
  final bool isActive;

  /// Platform-specific scheduling identifier (for cancellation).
  final String? platformScheduleId;

  /// Creates a new [ScheduledNotificationInfo].
  const ScheduledNotificationInfo({
    required this.scheduleId,
    required this.notification,
    required this.createdAt,
    required this.updatedAt,
    this.nextOccurrence,
    this.triggerCount = 0,
    this.isActive = true,
    this.platformScheduleId,
  });

  /// Creates a copy of this info with the given fields replaced.
  ScheduledNotificationInfo copyWith({
    String? scheduleId,
    SmartNotification? notification,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextOccurrence,
    int? triggerCount,
    bool? isActive,
    String? platformScheduleId,
  }) {
    return ScheduledNotificationInfo(
      scheduleId: scheduleId ?? this.scheduleId,
      notification: notification ?? this.notification,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      triggerCount: triggerCount ?? this.triggerCount,
      isActive: isActive ?? this.isActive,
      platformScheduleId: platformScheduleId ?? this.platformScheduleId,
    );
  }

  /// Converts this info to a map for storage.
  Map<String, dynamic> toMap() {
    return {
      'scheduleId': scheduleId,
      'notification': notification.toMap(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'nextOccurrence': nextOccurrence?.millisecondsSinceEpoch,
      'triggerCount': triggerCount,
      'isActive': isActive,
      'platformScheduleId': platformScheduleId,
    };
  }

  /// Creates a [ScheduledNotificationInfo] from a map.
  factory ScheduledNotificationInfo.fromMap(Map<String, dynamic> map) {
    return ScheduledNotificationInfo(
      scheduleId: map['scheduleId'] ?? '',
      notification: SmartNotification.fromMap(map['notification'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      nextOccurrence: map['nextOccurrence'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['nextOccurrence'])
          : null,
      triggerCount: map['triggerCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      platformScheduleId: map['platformScheduleId'],
    );
  }

  /// Whether this scheduled notification is expired.
  bool get isExpired {
    if (!isActive) return true;
    if (nextOccurrence == null) return true;
    if (notification.schedule?.endDate != null &&
        DateTime.now().isAfter(notification.schedule!.endDate!)) {
      return true;
    }
    if (notification.schedule?.maxOccurrences != null &&
        triggerCount >= notification.schedule!.maxOccurrences!) {
      return true;
    }
    return false;
  }

  /// Whether this is a recurring notification.
  bool get isRecurring => notification.isRecurring;

  /// Gets the schedule configuration.
  NotificationSchedule? get schedule => notification.schedule;

  @override
  String toString() {
    return 'ScheduledNotificationInfo('
        'scheduleId: $scheduleId, '
        'notification: ${notification.id}, '
        'nextOccurrence: $nextOccurrence, '
        'triggerCount: $triggerCount, '
        'isActive: $isActive'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduledNotificationInfo &&
        other.scheduleId == scheduleId &&
        other.notification == notification &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.nextOccurrence == nextOccurrence &&
        other.triggerCount == triggerCount &&
        other.isActive == isActive &&
        other.platformScheduleId == platformScheduleId;
  }

  @override
  int get hashCode {
    return Object.hash(
      scheduleId,
      notification,
      createdAt,
      updatedAt,
      nextOccurrence,
      triggerCount,
      isActive,
      platformScheduleId,
    );
  }
}

/// Result of a batch scheduling operation.
class BatchScheduleResult {
  /// Successfully scheduled notifications.
  final List<ScheduledNotificationInfo> successful;

  /// Failed scheduling attempts with error messages.
  final List<BatchScheduleError> failed;

  /// Total number of notifications processed.
  final int total;

  /// Creates a new [BatchScheduleResult].
  const BatchScheduleResult({
    required this.successful,
    required this.failed,
    required this.total,
  });

  /// Whether all notifications were scheduled successfully.
  bool get isCompleteSuccess => failed.isEmpty && successful.length == total;

  /// Whether some notifications were scheduled successfully.
  bool get isPartialSuccess => successful.isNotEmpty && failed.isNotEmpty;

  /// Whether no notifications were scheduled successfully.
  bool get isCompleteFailure => successful.isEmpty && failed.isNotEmpty;

  /// Number of successfully scheduled notifications.
  int get successCount => successful.length;

  /// Number of failed scheduling attempts.
  int get failureCount => failed.length;

  @override
  String toString() {
    return 'BatchScheduleResult('
        'total: $total, '
        'successful: $successCount, '
        'failed: $failureCount'
        ')';
  }
}

/// Represents a failed scheduling attempt in a batch operation.
class BatchScheduleError {
  /// The notification that failed to schedule.
  final SmartNotification notification;

  /// The error message.
  final String error;

  /// The error code (if available).
  final String? errorCode;

  /// Creates a new [BatchScheduleError].
  const BatchScheduleError({
    required this.notification,
    required this.error,
    this.errorCode,
  });

  @override
  String toString() {
    return 'BatchScheduleError('
        'notificationId: ${notification.id}, '
        'error: $error, '
        'errorCode: $errorCode'
        ')';
  }
}

/// Query parameters for retrieving scheduled notifications.
class ScheduledNotificationQuery {
  /// Filter by active status.
  final bool? isActive;

  /// Filter by recurring status.
  final bool? isRecurring;

  /// Filter by schedule type.
  final ScheduleType? scheduleType;

  /// Filter by notifications scheduled after this time.
  final DateTime? scheduledAfter;

  /// Filter by notifications scheduled before this time.
  final DateTime? scheduledBefore;

  /// Maximum number of results to return.
  final int? limit;

  /// Number of results to skip (for pagination).
  final int? offset;

  /// Sort field ('createdAt', 'nextOccurrence', 'triggerCount').
  final String? sortBy;

  /// Sort order ('asc' or 'desc').
  final String? sortOrder;

  /// Creates a new [ScheduledNotificationQuery].
  const ScheduledNotificationQuery({
    this.isActive,
    this.isRecurring,
    this.scheduleType,
    this.scheduledAfter,
    this.scheduledBefore,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  /// Converts this query to a map for platform communication.
  Map<String, dynamic> toMap() {
    return {
      'isActive': isActive,
      'isRecurring': isRecurring,
      'scheduleType': scheduleType?.value,
      'scheduledAfter': scheduledAfter?.millisecondsSinceEpoch,
      'scheduledBefore': scheduledBefore?.millisecondsSinceEpoch,
      'limit': limit,
      'offset': offset,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
  }

  @override
  String toString() {
    return 'ScheduledNotificationQuery('
        'isActive: $isActive, '
        'isRecurring: $isRecurring, '
        'scheduleType: $scheduleType, '
        'limit: $limit, '
        'offset: $offset'
        ')';
  }
}
