/// Defines the type of notification schedule.
enum ScheduleType {
  /// One-time notification at a specific date and time.
  oneTime,
  
  /// Recurring notification that repeats daily.
  daily,
  
  /// Recurring notification that repeats weekly.
  weekly,
  
  /// Recurring notification that repeats monthly.
  monthly,
  
  /// Recurring notification that repeats yearly.
  yearly,
  
  /// Custom recurring pattern with specific intervals.
  custom,
}

/// Extension methods for [ScheduleType].
extension ScheduleTypeExtension on ScheduleType {
  /// Returns the string representation of the schedule type.
  String get value {
    switch (this) {
      case ScheduleType.oneTime:
        return 'oneTime';
      case ScheduleType.daily:
        return 'daily';
      case ScheduleType.weekly:
        return 'weekly';
      case ScheduleType.monthly:
        return 'monthly';
      case ScheduleType.yearly:
        return 'yearly';
      case ScheduleType.custom:
        return 'custom';
    }
  }

  /// Returns a human-readable description of the schedule type.
  String get description {
    switch (this) {
      case ScheduleType.oneTime:
        return 'One-time notification';
      case ScheduleType.daily:
        return 'Daily recurring notification';
      case ScheduleType.weekly:
        return 'Weekly recurring notification';
      case ScheduleType.monthly:
        return 'Monthly recurring notification';
      case ScheduleType.yearly:
        return 'Yearly recurring notification';
      case ScheduleType.custom:
        return 'Custom recurring notification';
    }
  }

  /// Returns whether this schedule type is recurring.
  bool get isRecurring {
    return this != ScheduleType.oneTime;
  }

  /// Creates a [ScheduleType] from a string value.
  static ScheduleType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'onetime':
        return ScheduleType.oneTime;
      case 'daily':
        return ScheduleType.daily;
      case 'weekly':
        return ScheduleType.weekly;
      case 'monthly':
        return ScheduleType.monthly;
      case 'yearly':
        return ScheduleType.yearly;
      case 'custom':
        return ScheduleType.custom;
      default:
        throw ArgumentError('Invalid ScheduleType: $value');
    }
  }
}

/// Defines the days of the week for weekly recurring notifications.
enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Extension methods for [WeekDay].
extension WeekDayExtension on WeekDay {
  /// Returns the string representation of the weekday.
  String get value {
    switch (this) {
      case WeekDay.monday:
        return 'monday';
      case WeekDay.tuesday:
        return 'tuesday';
      case WeekDay.wednesday:
        return 'wednesday';
      case WeekDay.thursday:
        return 'thursday';
      case WeekDay.friday:
        return 'friday';
      case WeekDay.saturday:
        return 'saturday';
      case WeekDay.sunday:
        return 'sunday';
    }
  }

  /// Returns the weekday number (1 = Monday, 7 = Sunday).
  int get weekdayNumber {
    switch (this) {
      case WeekDay.monday:
        return 1;
      case WeekDay.tuesday:
        return 2;
      case WeekDay.wednesday:
        return 3;
      case WeekDay.thursday:
        return 4;
      case WeekDay.friday:
        return 5;
      case WeekDay.saturday:
        return 6;
      case WeekDay.sunday:
        return 7;
    }
  }

  /// Returns the short name of the weekday.
  String get shortName {
    switch (this) {
      case WeekDay.monday:
        return 'Mon';
      case WeekDay.tuesday:
        return 'Tue';
      case WeekDay.wednesday:
        return 'Wed';
      case WeekDay.thursday:
        return 'Thu';
      case WeekDay.friday:
        return 'Fri';
      case WeekDay.saturday:
        return 'Sat';
      case WeekDay.sunday:
        return 'Sun';
    }
  }

  /// Returns the full name of the weekday.
  String get fullName {
    switch (this) {
      case WeekDay.monday:
        return 'Monday';
      case WeekDay.tuesday:
        return 'Tuesday';
      case WeekDay.wednesday:
        return 'Wednesday';
      case WeekDay.thursday:
        return 'Thursday';
      case WeekDay.friday:
        return 'Friday';
      case WeekDay.saturday:
        return 'Saturday';
      case WeekDay.sunday:
        return 'Sunday';
    }
  }

  /// Creates a [WeekDay] from a weekday number (1 = Monday, 7 = Sunday).
  static WeekDay fromWeekdayNumber(int weekday) {
    switch (weekday) {
      case 1:
        return WeekDay.monday;
      case 2:
        return WeekDay.tuesday;
      case 3:
        return WeekDay.wednesday;
      case 4:
        return WeekDay.thursday;
      case 5:
        return WeekDay.friday;
      case 6:
        return WeekDay.saturday;
      case 7:
        return WeekDay.sunday;
      default:
        throw ArgumentError('Invalid weekday number: $weekday. Must be 1-7.');
    }
  }

  /// Creates a [WeekDay] from a DateTime weekday (1 = Monday, 7 = Sunday).
  static WeekDay fromDateTime(DateTime dateTime) {
    return fromWeekdayNumber(dateTime.weekday);
  }

  /// Creates a [WeekDay] from a string value.
  static WeekDay fromString(String value) {
    switch (value.toLowerCase()) {
      case 'monday':
      case 'mon':
        return WeekDay.monday;
      case 'tuesday':
      case 'tue':
        return WeekDay.tuesday;
      case 'wednesday':
      case 'wed':
        return WeekDay.wednesday;
      case 'thursday':
      case 'thu':
        return WeekDay.thursday;
      case 'friday':
      case 'fri':
        return WeekDay.friday;
      case 'saturday':
      case 'sat':
        return WeekDay.saturday;
      case 'sunday':
      case 'sun':
        return WeekDay.sunday;
      default:
        throw ArgumentError('Invalid WeekDay: $value');
    }
  }
}
