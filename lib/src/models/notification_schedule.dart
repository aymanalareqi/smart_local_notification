import '../enums/schedule_type.dart';

/// Represents a notification schedule with support for one-time and recurring notifications.
class NotificationSchedule {
  /// The type of schedule (one-time, daily, weekly, etc.).
  final ScheduleType scheduleType;

  /// The initial date and time for the notification.
  /// For recurring notifications, this is the first occurrence.
  final DateTime scheduledTime;

  /// The timezone identifier for the scheduled time.
  /// If null, uses the device's current timezone.
  final String? timeZone;

  /// For weekly recurring notifications, specifies which days of the week.
  /// If null for weekly schedules, defaults to the day of the week from scheduledTime.
  final List<WeekDay>? weekDays;

  /// For custom recurring notifications, specifies the interval in the given unit.
  /// For example, interval: 2 with intervalUnit: 'hours' means every 2 hours.
  final int? interval;

  /// The unit for custom intervals ('minutes', 'hours', 'days', 'weeks', 'months').
  final String? intervalUnit;

  /// The end date for recurring notifications.
  /// If null, the notification will repeat indefinitely.
  final DateTime? endDate;

  /// Maximum number of occurrences for recurring notifications.
  /// If null, the notification will repeat indefinitely (or until endDate).
  final int? maxOccurrences;

  /// Whether to automatically adjust for daylight saving time changes.
  final bool adjustForDST;

  /// Whether the schedule is currently active.
  final bool isActive;

  /// Creates a new [NotificationSchedule].
  const NotificationSchedule({
    required this.scheduleType,
    required this.scheduledTime,
    this.timeZone,
    this.weekDays,
    this.interval,
    this.intervalUnit,
    this.endDate,
    this.maxOccurrences,
    this.adjustForDST = true,
    this.isActive = true,
  });

  /// Creates a one-time notification schedule.
  factory NotificationSchedule.oneTime({
    required DateTime scheduledTime,
    String? timeZone,
    bool adjustForDST = true,
  }) {
    return NotificationSchedule(
      scheduleType: ScheduleType.oneTime,
      scheduledTime: scheduledTime,
      timeZone: timeZone,
      adjustForDST: adjustForDST,
    );
  }

  /// Creates a daily recurring notification schedule.
  factory NotificationSchedule.daily({
    required DateTime scheduledTime,
    String? timeZone,
    DateTime? endDate,
    int? maxOccurrences,
    bool adjustForDST = true,
  }) {
    return NotificationSchedule(
      scheduleType: ScheduleType.daily,
      scheduledTime: scheduledTime,
      timeZone: timeZone,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
      adjustForDST: adjustForDST,
    );
  }

  /// Creates a weekly recurring notification schedule.
  factory NotificationSchedule.weekly({
    required DateTime scheduledTime,
    List<WeekDay>? weekDays,
    String? timeZone,
    DateTime? endDate,
    int? maxOccurrences,
    bool adjustForDST = true,
  }) {
    return NotificationSchedule(
      scheduleType: ScheduleType.weekly,
      scheduledTime: scheduledTime,
      weekDays: weekDays,
      timeZone: timeZone,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
      adjustForDST: adjustForDST,
    );
  }

  /// Creates a monthly recurring notification schedule.
  factory NotificationSchedule.monthly({
    required DateTime scheduledTime,
    String? timeZone,
    DateTime? endDate,
    int? maxOccurrences,
    bool adjustForDST = true,
  }) {
    return NotificationSchedule(
      scheduleType: ScheduleType.monthly,
      scheduledTime: scheduledTime,
      timeZone: timeZone,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
      adjustForDST: adjustForDST,
    );
  }

  /// Creates a yearly recurring notification schedule.
  factory NotificationSchedule.yearly({
    required DateTime scheduledTime,
    String? timeZone,
    DateTime? endDate,
    int? maxOccurrences,
    bool adjustForDST = true,
  }) {
    return NotificationSchedule(
      scheduleType: ScheduleType.yearly,
      scheduledTime: scheduledTime,
      timeZone: timeZone,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
      adjustForDST: adjustForDST,
    );
  }

  /// Creates a custom recurring notification schedule.
  factory NotificationSchedule.custom({
    required DateTime scheduledTime,
    required int interval,
    required String intervalUnit,
    String? timeZone,
    DateTime? endDate,
    int? maxOccurrences,
    bool adjustForDST = true,
  }) {
    return NotificationSchedule(
      scheduleType: ScheduleType.custom,
      scheduledTime: scheduledTime,
      interval: interval,
      intervalUnit: intervalUnit,
      timeZone: timeZone,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
      adjustForDST: adjustForDST,
    );
  }

  /// Creates a copy of this schedule with the given fields replaced.
  NotificationSchedule copyWith({
    ScheduleType? scheduleType,
    DateTime? scheduledTime,
    String? timeZone,
    List<WeekDay>? weekDays,
    int? interval,
    String? intervalUnit,
    DateTime? endDate,
    int? maxOccurrences,
    bool? adjustForDST,
    bool? isActive,
  }) {
    return NotificationSchedule(
      scheduleType: scheduleType ?? this.scheduleType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      timeZone: timeZone ?? this.timeZone,
      weekDays: weekDays ?? this.weekDays,
      interval: interval ?? this.interval,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      endDate: endDate ?? this.endDate,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
      adjustForDST: adjustForDST ?? this.adjustForDST,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Converts this schedule to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'scheduleType': scheduleType.value,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'timeZone': timeZone,
      'weekDays': weekDays?.map((day) => day.value).toList(),
      'interval': interval,
      'intervalUnit': intervalUnit,
      'endDate': endDate?.millisecondsSinceEpoch,
      'maxOccurrences': maxOccurrences,
      'adjustForDST': adjustForDST,
      'isActive': isActive,
    };
  }

  /// Creates a [NotificationSchedule] from a map.
  factory NotificationSchedule.fromMap(Map<String, dynamic> map) {
    return NotificationSchedule(
      scheduleType: ScheduleTypeExtension.fromString(map['scheduleType'] ?? 'oneTime'),
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(map['scheduledTime'] ?? 0),
      timeZone: map['timeZone'],
      weekDays: map['weekDays'] != null
          ? (map['weekDays'] as List<dynamic>)
              .map((day) => WeekDayExtension.fromString(day.toString()))
              .toList()
          : null,
      interval: map['interval'],
      intervalUnit: map['intervalUnit'],
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      maxOccurrences: map['maxOccurrences'],
      adjustForDST: map['adjustForDST'] ?? true,
      isActive: map['isActive'] ?? true,
    );
  }

  /// Whether this schedule is recurring.
  bool get isRecurring => scheduleType.isRecurring;

  /// Whether this schedule is a one-time notification.
  bool get isOneTime => scheduleType == ScheduleType.oneTime;

  /// Whether this schedule has an end condition (endDate or maxOccurrences).
  bool get hasEndCondition => endDate != null || maxOccurrences != null;

  /// Whether this schedule is currently valid (not expired).
  bool get isValid {
    if (!isActive) return false;
    if (endDate != null && DateTime.now().isAfter(endDate!)) return false;
    return true;
  }

  /// Gets the next occurrence of this schedule after the given date.
  /// Returns null if there are no more occurrences.
  DateTime? getNextOccurrence([DateTime? after]) {
    final now = after ?? DateTime.now();
    
    if (!isValid) return null;
    
    switch (scheduleType) {
      case ScheduleType.oneTime:
        return scheduledTime.isAfter(now) ? scheduledTime : null;
        
      case ScheduleType.daily:
        return _getNextDailyOccurrence(now);
        
      case ScheduleType.weekly:
        return _getNextWeeklyOccurrence(now);
        
      case ScheduleType.monthly:
        return _getNextMonthlyOccurrence(now);
        
      case ScheduleType.yearly:
        return _getNextYearlyOccurrence(now);
        
      case ScheduleType.custom:
        return _getNextCustomOccurrence(now);
    }
  }

  DateTime? _getNextDailyOccurrence(DateTime after) {
    var next = DateTime(
      after.year,
      after.month,
      after.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );
    
    if (next.isBefore(after) || next.isAtSameMomentAs(after)) {
      next = next.add(const Duration(days: 1));
    }
    
    if (endDate != null && next.isAfter(endDate!)) return null;
    return next;
  }

  DateTime? _getNextWeeklyOccurrence(DateTime after) {
    final targetWeekDays = weekDays ?? [WeekDayExtension.fromDateTime(scheduledTime)];
    
    for (int i = 0; i < 7; i++) {
      final candidate = after.add(Duration(days: i));
      final candidateWeekDay = WeekDayExtension.fromDateTime(candidate);
      
      if (targetWeekDays.contains(candidateWeekDay)) {
        var next = DateTime(
          candidate.year,
          candidate.month,
          candidate.day,
          scheduledTime.hour,
          scheduledTime.minute,
          scheduledTime.second,
        );
        
        if (next.isAfter(after)) {
          if (endDate != null && next.isAfter(endDate!)) return null;
          return next;
        }
      }
    }
    
    return null;
  }

  DateTime? _getNextMonthlyOccurrence(DateTime after) {
    var next = DateTime(
      after.year,
      after.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );
    
    if (next.isBefore(after) || next.isAtSameMomentAs(after)) {
      next = DateTime(
        next.month == 12 ? next.year + 1 : next.year,
        next.month == 12 ? 1 : next.month + 1,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
        scheduledTime.second,
      );
    }
    
    if (endDate != null && next.isAfter(endDate!)) return null;
    return next;
  }

  DateTime? _getNextYearlyOccurrence(DateTime after) {
    var next = DateTime(
      after.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );
    
    if (next.isBefore(after) || next.isAtSameMomentAs(after)) {
      next = DateTime(
        next.year + 1,
        scheduledTime.month,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
        scheduledTime.second,
      );
    }
    
    if (endDate != null && next.isAfter(endDate!)) return null;
    return next;
  }

  DateTime? _getNextCustomOccurrence(DateTime after) {
    if (interval == null || intervalUnit == null) return null;
    
    Duration intervalDuration;
    switch (intervalUnit!.toLowerCase()) {
      case 'minutes':
        intervalDuration = Duration(minutes: interval!);
        break;
      case 'hours':
        intervalDuration = Duration(hours: interval!);
        break;
      case 'days':
        intervalDuration = Duration(days: interval!);
        break;
      default:
        return null; // Unsupported interval unit for simple calculation
    }
    
    var next = scheduledTime;
    while (next.isBefore(after) || next.isAtSameMomentAs(after)) {
      next = next.add(intervalDuration);
    }
    
    if (endDate != null && next.isAfter(endDate!)) return null;
    return next;
  }

  @override
  String toString() {
    return 'NotificationSchedule('
        'scheduleType: $scheduleType, '
        'scheduledTime: $scheduledTime, '
        'timeZone: $timeZone, '
        'weekDays: $weekDays, '
        'interval: $interval, '
        'intervalUnit: $intervalUnit, '
        'endDate: $endDate, '
        'maxOccurrences: $maxOccurrences, '
        'adjustForDST: $adjustForDST, '
        'isActive: $isActive'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSchedule &&
        other.scheduleType == scheduleType &&
        other.scheduledTime == scheduledTime &&
        other.timeZone == timeZone &&
        other.weekDays == weekDays &&
        other.interval == interval &&
        other.intervalUnit == intervalUnit &&
        other.endDate == endDate &&
        other.maxOccurrences == maxOccurrences &&
        other.adjustForDST == adjustForDST &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      scheduleType,
      scheduledTime,
      timeZone,
      weekDays,
      interval,
      intervalUnit,
      endDate,
      maxOccurrences,
      adjustForDST,
      isActive,
    );
  }
}
