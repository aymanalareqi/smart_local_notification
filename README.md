# Smart Local Notification

A Flutter plugin for native Android and iOS notifications with custom sound playback. This plugin provides the ability to display silent notifications while playing custom audio files simultaneously, supporting both asset-bundled and external filesystem audio files.

## Features

- 🔕 **Silent Notifications**: Display notifications without default system sounds
- 🎵 **Custom Audio Playback**: Play custom audio files independently from notifications
- 📱 **Cross-Platform**: Native implementation for both Android and iOS
- 🎯 **Background Audio**: Continue audio playback when app is backgrounded or closed
- 📁 **Flexible Audio Sources**: Support for asset files and external filesystem files
- ⚙️ **Configurable**: Extensive customization options for notifications and audio
- ⏰ **Advanced Scheduling**: Schedule one-time and recurring notifications
- 🔁 **Recurring Patterns**: Daily, weekly, monthly, yearly, and custom intervals
- 🌍 **Timezone Support**: Proper timezone handling for scheduled notifications
- 📊 **Schedule Management**: Query, update, and cancel scheduled notifications
- 🔄 **Boot Recovery**: Automatically restore scheduled notifications after device restart

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  smart_local_notification: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### Android Setup

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.VIBRATE" />
```

### iOS Setup

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>background-processing</string>
</array>
```

## Usage

### Basic Example

```dart
import 'package:smart_local_notification/smart_local_notification.dart';

// Initialize the plugin
await SmartLocalNotification.initialize();

// Create notification settings
final notification = SmartNotification(
  id: 1,
  title: 'Custom Notification',
  body: 'This is a silent notification with custom audio',
  notificationSettings: NotificationSettings(
    priority: NotificationPriority.high,
    silent: true,
  ),
  audioSettings: AudioSettings(
    audioPath: 'assets/custom_sound.mp3',
    sourceType: AudioSourceType.asset,
    loop: true,
    volume: 0.8,
  ),
);

// Show the notification
await SmartLocalNotification.showNotification(notification);
```

### Advanced Configuration

```dart
final notification = SmartNotification(
  id: 2,
  title: 'Advanced Notification',
  body: 'Notification with external audio file',
  notificationSettings: NotificationSettings(
    priority: NotificationPriority.max,
    silent: true,
    channelId: 'custom_channel',
    channelName: 'Custom Notifications',
    icon: 'notification_icon',
  ),
  audioSettings: AudioSettings(
    audioPath: '/storage/emulated/0/custom_audio.mp3',
    sourceType: AudioSourceType.file,
    loop: false,
    volume: 1.0,
    fadeInDuration: Duration(seconds: 2),
    fadeOutDuration: Duration(seconds: 3),
  ),
);

await SmartLocalNotification.showNotification(notification);
```

## Advanced Scheduling

The plugin supports advanced scheduling features including recurring notifications, timezone handling, and schedule management.

### One-time Scheduled Notification

```dart
final notification = SmartNotification(
  id: 1,
  title: 'Scheduled Reminder',
  body: 'This notification was scheduled',
  schedule: NotificationSchedule.oneTime(
    scheduledTime: DateTime.now().add(Duration(hours: 2)),
  ),
  audioSettings: AudioSettings(
    audioPath: 'reminder.mp3',
    sourceType: AudioSourceType.asset,
  ),
);

await SmartLocalNotification.scheduleNotification(notification);
```

### Daily Recurring Notification

```dart
final notification = SmartNotification(
  id: 2,
  title: 'Daily Reminder',
  body: 'Don\'t forget your daily task',
  schedule: NotificationSchedule.daily(
    scheduledTime: DateTime(2024, 1, 1, 9, 0), // 9 AM daily
    endDate: DateTime(2024, 12, 31), // Stop at end of year
    maxOccurrences: 365, // Or limit by count
  ),
  audioSettings: AudioSettings(
    audioPath: 'daily_reminder.mp3',
    sourceType: AudioSourceType.asset,
  ),
);

await SmartLocalNotification.scheduleNotification(notification);
```

### Weekly Recurring Notification

```dart
final notification = SmartNotification(
  id: 3,
  title: 'Weekly Meeting',
  body: 'Team meeting in 15 minutes',
  schedule: NotificationSchedule.weekly(
    scheduledTime: DateTime(2024, 1, 1, 14, 45), // 2:45 PM
    weekDays: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
    endDate: DateTime(2024, 6, 30),
  ),
  audioSettings: AudioSettings(
    audioPath: 'meeting_reminder.mp3',
    sourceType: AudioSourceType.asset,
  ),
);

await SmartLocalNotification.scheduleNotification(notification);
```

### Custom Interval Notification

```dart
final notification = SmartNotification(
  id: 4,
  title: 'Hydration Reminder',
  body: 'Time to drink water!',
  schedule: NotificationSchedule.custom(
    scheduledTime: DateTime.now().add(Duration(minutes: 30)),
    interval: 2, // Every 2 hours
    intervalUnit: 'hours',
    maxOccurrences: 8, // 8 times per day
  ),
  audioSettings: AudioSettings(
    audioPath: 'water_reminder.mp3',
    sourceType: AudioSourceType.asset,
  ),
);

await SmartLocalNotification.scheduleNotification(notification);
```

### Managing Scheduled Notifications

```dart
// Get all active scheduled notifications
final activeNotifications = await SmartLocalNotification.getScheduledNotifications(
  ScheduledNotificationQuery(isActive: true)
);

// Get recurring notifications
final recurringNotifications = await SmartLocalNotification.getScheduledNotifications(
  ScheduledNotificationQuery(isRecurring: true)
);

// Cancel a specific scheduled notification
await SmartLocalNotification.cancelScheduledNotification(1);

// Cancel all scheduled notifications
await SmartLocalNotification.cancelAllScheduledNotifications();

// Batch schedule multiple notifications
final notifications = [notification1, notification2, notification3];
final result = await SmartLocalNotification.batchScheduleNotifications(notifications);
print('Scheduled: ${result.successCount}, Failed: ${result.failureCount}');
```

## API Reference

### SmartLocalNotification

Main class for interacting with the plugin.

#### Methods

- `initialize()` - Initialize the plugin
- `showNotification(SmartNotification)` - Show a notification with custom audio
- `cancelNotification(int id)` - Cancel a specific notification
- `cancelAllNotifications()` - Cancel all notifications
- `stopAudio()` - Stop audio playback
- `isAudioPlaying()` - Check if audio is currently playing
- `requestPermissions()` - Request notification permissions
- `arePermissionsGranted()` - Check if permissions are granted
- `scheduleNotification(SmartNotification)` - Schedule a notification for future delivery
- `cancelScheduledNotification(int id)` - Cancel a scheduled notification
- `cancelAllScheduledNotifications()` - Cancel all scheduled notifications
- `getScheduledNotifications([ScheduledNotificationQuery])` - Get scheduled notifications
- `updateScheduledNotification(String scheduleId, Map updates)` - Update a scheduled notification
- `batchScheduleNotifications(List<SmartNotification>)` - Schedule multiple notifications

### Models

#### SmartNotification
- `id` - Unique notification identifier
- `title` - Notification title
- `body` - Notification body
- `notificationSettings` - Notification configuration
- `audioSettings` - Audio playback configuration

#### NotificationSettings
- `priority` - Notification priority level
- `silent` - Whether notification should be silent
- `channelId` - Android notification channel ID
- `channelName` - Android notification channel name
- `icon` - Custom notification icon

#### AudioSettings
- `audioPath` - Path to audio file
- `sourceType` - Type of audio source (asset/file)
- `loop` - Whether to loop audio
- `volume` - Audio volume (0.0 - 1.0)
- `fadeInDuration` - Fade in duration
- `fadeOutDuration` - Fade out duration

## Permissions

### Android
- `POST_NOTIFICATIONS` - Required for showing notifications
- `WAKE_LOCK` - Keep device awake during audio playback
- `FOREGROUND_SERVICE` - Background audio playback
- `VIBRATE` - Notification vibration

### iOS
- Notification permissions are requested automatically
- Background audio capability required for background playback

## Limitations

- iOS background audio is limited by system policies
- Android battery optimization may affect background playback
- File system audio requires appropriate read permissions

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
