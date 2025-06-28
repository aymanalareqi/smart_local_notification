# Smart Local Notification API Reference

This document provides a comprehensive reference for all classes, methods, and properties available in the Smart Local Notification plugin.

## Core Classes

### SmartLocalNotification

The main class for interacting with the plugin.

#### Static Methods

##### `initialize()`
```dart
static Future<bool> initialize()
```
Initializes the plugin. Must be called before using any other methods.

**Returns:** `Future<bool>` - `true` if initialization was successful

**Example:**
```dart
await SmartLocalNotification.initialize();
```

##### `showNotification(SmartNotification notification)`
```dart
static Future<bool> showNotification(SmartNotification notification)
```
Shows a notification with optional custom audio.

**Parameters:**
- `notification`: The notification configuration

**Returns:** `Future<bool>` - `true` if notification was shown successfully

**Example:**
```dart
final notification = SmartNotification(
  id: 1,
  title: 'Hello',
  body: 'World',
);
await SmartLocalNotification.showNotification(notification);
```

##### `cancelNotification(int id)`
```dart
static Future<bool> cancelNotification(int id)
```
Cancels a specific notification by ID.

**Parameters:**
- `id`: The notification ID to cancel

**Returns:** `Future<bool>` - `true` if cancellation was successful

##### `cancelAllNotifications()`
```dart
static Future<bool> cancelAllNotifications()
```
Cancels all active notifications.

**Returns:** `Future<bool>` - `true` if all notifications were cancelled

##### `stopAudio()`
```dart
static Future<bool> stopAudio()
```
Stops any currently playing audio.

**Returns:** `Future<bool>` - `true` if audio was stopped successfully

##### `isAudioPlaying()`
```dart
static Future<bool> isAudioPlaying()
```
Checks if audio is currently playing.

**Returns:** `Future<bool>` - `true` if audio is playing

##### `requestPermissions()`
```dart
static Future<bool> requestPermissions()
```
Requests notification permissions from the user.

**Returns:** `Future<bool>` - `true` if permissions were granted

##### `arePermissionsGranted()`
```dart
static Future<bool> arePermissionsGranted()
```
Checks if notification permissions are currently granted.

**Returns:** `Future<bool>` - `true` if permissions are granted

#### Static Properties

##### `onNotificationEvent`
```dart
static Stream<SmartNotificationEvent> get onNotificationEvent
```
Stream of notification events. Listen to this for notification interactions and audio events.

**Example:**
```dart
SmartLocalNotification.onNotificationEvent.listen((event) {
  switch (event.type) {
    case SmartNotificationEventType.audioStarted:
      print('Audio started');
      break;
    case SmartNotificationEventType.notificationTapped:
      print('Notification tapped');
      break;
  }
});
```

## Model Classes

### SmartNotification

Represents a notification with custom audio capabilities.

#### Constructor
```dart
SmartNotification({
  required int id,
  required String title,
  required String body,
  NotificationSettings notificationSettings = const NotificationSettings(),
  AudioSettings? audioSettings,
  Map<String, dynamic>? payload,
  DateTime? scheduledTime,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `int` | Unique notification identifier |
| `title` | `String` | Notification title |
| `body` | `String` | Notification body text |
| `notificationSettings` | `NotificationSettings` | Notification display configuration |
| `audioSettings` | `AudioSettings?` | Custom audio configuration |
| `payload` | `Map<String, dynamic>?` | Optional data payload |
| `scheduledTime` | `DateTime?` | When to show the notification |

#### Methods

##### `copyWith(...)`
Creates a copy with modified properties.

##### `toMap()`
Converts to a map for platform communication.

##### `fromMap(Map<String, dynamic> map)`
Creates instance from a map.

#### Getters

##### `hasAudio`
```dart
bool get hasAudio
```
Returns `true` if audio settings are configured.

##### `isScheduled`
```dart
bool get isScheduled
```
Returns `true` if notification is scheduled for future.

##### `isImmediate`
```dart
bool get isImmediate
```
Returns `true` if notification should show immediately.

### NotificationSettings

Configuration for notification display behavior.

#### Constructor
```dart
NotificationSettings({
  NotificationPriority priority = NotificationPriority.defaultPriority,
  bool silent = true,
  String? channelId,
  String? channelName,
  String? channelDescription,
  String? icon,
  bool showTimestamp = true,
  bool ongoing = false,
  bool autoCancel = true,
  int? color,
  bool showOnLockScreen = true,
  String? largeIcon,
})
```

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `priority` | `NotificationPriority` | `defaultPriority` | Notification priority level |
| `silent` | `bool` | `true` | Whether notification is silent |
| `channelId` | `String?` | `null` | Android notification channel ID |
| `channelName` | `String?` | `null` | Android notification channel name |
| `channelDescription` | `String?` | `null` | Android notification channel description |
| `icon` | `String?` | `null` | Custom notification icon |
| `showTimestamp` | `bool` | `true` | Whether to show timestamp |
| `ongoing` | `bool` | `false` | Whether notification is ongoing |
| `autoCancel` | `bool` | `true` | Whether to auto-cancel on tap |
| `color` | `int?` | `null` | Notification color (Android) |
| `showOnLockScreen` | `bool` | `true` | Whether to show on lock screen |
| `largeIcon` | `String?` | `null` | Large icon resource name |

### AudioSettings

Configuration for custom audio playback.

#### Constructor
```dart
AudioSettings({
  required String audioPath,
  required AudioSourceType sourceType,
  bool loop = false,
  double volume = 1.0,
  Duration? fadeInDuration,
  Duration? fadeOutDuration,
  bool respectSilentMode = false,
  bool duckOthers = true,
  bool interruptOthers = false,
  String? audioSessionCategory,
  bool playInBackground = true,
})
```

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `audioPath` | `String` | - | Path to audio file |
| `sourceType` | `AudioSourceType` | - | Type of audio source |
| `loop` | `bool` | `false` | Whether to loop audio |
| `volume` | `double` | `1.0` | Audio volume (0.0-1.0) |
| `fadeInDuration` | `Duration?` | `null` | Fade in duration |
| `fadeOutDuration` | `Duration?` | `null` | Fade out duration |
| `respectSilentMode` | `bool` | `false` | Whether to respect silent mode |
| `duckOthers` | `bool` | `true` | Whether to duck other audio |
| `interruptOthers` | `bool` | `false` | Whether to interrupt other audio |
| `audioSessionCategory` | `String?` | `null` | iOS audio session category |
| `playInBackground` | `bool` | `true` | Whether to play in background |

#### Methods

##### `validate()`
```dart
Future<AudioValidationResult> validate()
```
Validates the audio settings and returns detailed validation information.

##### `normalizedPath`
```dart
String get normalizedPath
```
Gets the normalized audio path for platform implementations.

##### `fileExtension`
```dart
String? get fileExtension
```
Gets the file extension of the audio file.

##### `isSupportedFormat`
```dart
bool get isSupportedFormat
```
Checks if the audio format is supported.

## Enums

### AudioSourceType

Defines the type of audio source.

```dart
enum AudioSourceType {
  asset,  // Audio from app assets
  file,   // Audio from file system
  url,    // Audio from URL
}
```

### NotificationPriority

Defines notification priority levels.

```dart
enum NotificationPriority {
  min,              // Minimum priority
  low,              // Low priority
  defaultPriority,  // Default priority
  high,             // High priority
  max,              // Maximum priority
}
```

### SmartNotificationEventType

Types of notification events.

```dart
enum SmartNotificationEventType {
  notificationTapped,    // Notification was tapped
  notificationDismissed, // Notification was dismissed
  audioStarted,          // Audio playback started
  audioStopped,          // Audio playback stopped
  audioCompleted,        // Audio playback completed
  error,                 // An error occurred
}
```

## Utility Classes

### AudioFileManager

Utility for managing audio files and validation.

#### Static Methods

##### `validateAudioFile(String audioPath, AudioSourceType sourceType)`
```dart
static Future<bool> validateAudioFile(String audioPath, AudioSourceType sourceType)
```
Validates if an audio file exists and is accessible.

##### `normalizeAudioPath(String audioPath, AudioSourceType sourceType)`
```dart
static String normalizeAudioPath(String audioPath, AudioSourceType sourceType)
```
Normalizes an audio file path based on source type.

##### `isSupportedAudioFormat(String? extension)`
```dart
static bool isSupportedAudioFormat(String? extension)
```
Checks if file extension is supported for audio playback.

##### `validateAudioSettings(String audioPath, AudioSourceType sourceType)`
```dart
static Future<AudioValidationResult> validateAudioSettings(String audioPath, AudioSourceType sourceType)
```
Validates audio settings and provides detailed error information.

### NotificationAudioCoordinator

Utility for coordinating silent notifications with custom audio.

#### Static Methods

##### `optimizeForSilentAudio(SmartNotification notification)`
```dart
static SmartNotification optimizeForSilentAudio(SmartNotification notification)
```
Optimizes a notification for silent operation with custom audio.

##### `validateSilentAudioConfiguration(SmartNotification notification)`
```dart
static ValidationResult validateSilentAudioConfiguration(SmartNotification notification)
```
Validates notification configuration for silent audio operation.

##### `createAlarmStyleNotification(...)`
```dart
static SmartNotification createAlarmStyleNotification({
  required int id,
  required String title,
  required String body,
  required AudioSettings audioSettings,
  Map<String, dynamic>? payload,
  DateTime? scheduledTime,
})
```
Creates a notification optimized for alarm-like behavior.

##### `createReminderStyleNotification(...)`
```dart
static SmartNotification createReminderStyleNotification({
  required int id,
  required String title,
  required String body,
  required AudioSettings audioSettings,
  Map<String, dynamic>? payload,
  DateTime? scheduledTime,
})
```
Creates a notification optimized for gentle reminder behavior.

### BackgroundAudioManager

Utility for managing background audio playback.

#### Instance Methods

##### `initialize()`
```dart
void initialize()
```
Initializes the background audio manager.

##### `prepareForBackground()`
```dart
Future<void> prepareForBackground()
```
Prepares the app for entering background mode with active audio.

##### `handleForegroundReturn()`
```dart
Future<void> handleForegroundReturn()
```
Handles app returning to foreground with active audio.

#### Static Methods

##### `optimizeForBackground(AudioSettings audioSettings)`
```dart
static AudioSettings optimizeForBackground(AudioSettings audioSettings)
```
Configures audio settings for optimal background playback.

##### `getBackgroundAudioRecommendations(AudioSettings audioSettings)`
```dart
static List<String> getBackgroundAudioRecommendations(AudioSettings audioSettings)
```
Gets recommendations for background audio configuration.

##### `estimateBatteryImpact(AudioSettings audioSettings, Duration estimatedDuration)`
```dart
static BatteryImpactEstimate estimateBatteryImpact(AudioSettings audioSettings, Duration estimatedDuration)
```
Estimates battery impact of background audio playback.

## Event Classes

### SmartNotificationEvent

Represents a notification event.

#### Constructor
```dart
SmartNotificationEvent({
  required SmartNotificationEventType type,
  int? notificationId,
  Map<String, dynamic>? payload,
  String? error,
})
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `type` | `SmartNotificationEventType` | The type of event |
| `notificationId` | `int?` | Associated notification ID |
| `payload` | `Map<String, dynamic>?` | Optional event data |
| `error` | `String?` | Error message if applicable |

## Result Classes

### AudioValidationResult

Result of audio file validation.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `isValid` | `bool` | Whether the audio file is valid |
| `error` | `String?` | Error message if validation failed |
| `normalizedPath` | `String?` | The normalized audio path |
| `fileExtension` | `String?` | The file extension |
| `mimeType` | `String?` | The MIME type |
| `fileSize` | `int?` | File size in bytes |
| `formattedFileSize` | `String?` | Human-readable file size |

### ValidationResult

Result of notification configuration validation.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `isValid` | `bool` | Whether configuration is valid |
| `issues` | `List<String>` | Critical issues |
| `warnings` | `List<String>` | Potential problems |
| `hasWarnings` | `bool` | Whether there are warnings |
| `hasIssues` | `bool` | Whether there are issues |

### BatteryImpactEstimate

Estimate of battery impact for background audio.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `level` | `BatteryImpactLevel` | Impact level |
| `factors` | `List<String>` | Contributing factors |
| `estimatedDuration` | `Duration` | Estimated duration |
| `description` | `String` | Human-readable description |

## Constants

### Supported Audio Formats

The plugin supports the following audio formats:

- **MP3** (`.mp3`) - Widely supported
- **WAV** (`.wav`) - Uncompressed
- **AAC** (`.aac`) - Good compression
- **M4A** (`.m4a`) - Apple format
- **OGG** (`.ogg`) - Android only
- **FLAC** (`.flac`) - Android only
- **MP4** (`.mp4`) - Audio in MP4 container

### Default Values

- **Default notification priority**: `NotificationPriority.defaultPriority`
- **Default audio volume**: `1.0`
- **Default silent mode**: `true`
- **Default background playback**: `true`
- **Default loop**: `false`

## Error Handling

The plugin uses standard Dart error handling patterns:

- Methods return `Future<bool>` for success/failure
- Validation methods return result objects with detailed information
- Events include error information when applicable
- Platform exceptions are caught and converted to boolean results

### Common Error Scenarios

1. **Permission Denied**: User hasn't granted notification permissions
2. **Audio File Not Found**: Specified audio file doesn't exist
3. **Unsupported Format**: Audio file format not supported on platform
4. **Platform Error**: Native platform returned an error
5. **Invalid Configuration**: Notification settings are invalid

## Platform Differences

### Android-Specific Features

- Notification channels and channel management
- Foreground service for background audio
- More flexible notification customization
- Battery optimization considerations

### iOS-Specific Features

- Audio session category configuration
- Background audio limitations
- Stricter notification policies
- App Store review considerations

## Migration Notes

When migrating between versions:

1. Check the changelog for breaking changes
2. Update platform configurations if needed
3. Test notification and audio functionality
4. Verify permission handling still works
5. Update any deprecated method calls
