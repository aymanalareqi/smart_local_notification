# Smart Local Notification Setup Guide

This guide provides detailed setup instructions for integrating the Smart Local Notification plugin into your Flutter application.

## Installation

### 1. Add Dependency

Add the plugin to your `pubspec.yaml`:

```yaml
dependencies:
  smart_local_notification: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### 2. Import the Plugin

```dart
import 'package:smart_local_notification/smart_local_notification.dart';
```

## Platform Configuration

### Android Setup

#### 1. Permissions

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
    <uses-permission android:name="android.permission.VIBRATE" />
    
    <!-- Optional permissions -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
</manifest>
```

#### 2. Minimum SDK Version

Ensure your `android/app/build.gradle` has minimum SDK 21:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### 3. ProGuard Configuration (if using)

Add to `android/app/proguard-rules.pro`:

```proguard
-keep class com.example.smart_local_notification.** { *; }
-keep class androidx.work.** { *; }
-keep class androidx.media.** { *; }
```

### iOS Setup

#### 1. Background Modes

Add background modes to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>background-processing</string>
</array>
```

#### 2. Usage Descriptions

Add usage descriptions to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to audio files for custom notification sounds.</string>
<key>NSUserNotificationsUsageDescription</key>
<string>This app needs notification permissions to show custom notifications.</string>
```

#### 3. Minimum iOS Version

Ensure your `ios/Podfile` targets iOS 12.0 or higher:

```ruby
platform :ios, '12.0'
```

## Basic Integration

### 1. Initialize the Plugin

Initialize the plugin in your `main()` function:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the plugin
  await SmartLocalNotification.initialize();
  
  // Initialize background audio manager (optional)
  BackgroundAudioManager().initialize();
  
  runApp(MyApp());
}
```

### 2. Request Permissions

Request necessary permissions before showing notifications:

```dart
Future<void> setupPermissions() async {
  final granted = await SmartLocalNotification.requestPermissions();
  if (!granted) {
    // Handle permission denial
    print('Notification permissions not granted');
  }
}
```

### 3. Basic Usage

Show a simple notification with custom audio:

```dart
Future<void> showBasicNotification() async {
  final notification = SmartNotification(
    id: 1,
    title: 'Hello World',
    body: 'This is a notification with custom audio',
    notificationSettings: NotificationSettings(
      priority: NotificationPriority.high,
      silent: true, // Silent notification
    ),
    audioSettings: AudioSettings(
      audioPath: 'notification.mp3', // Asset file
      sourceType: AudioSourceType.asset,
      volume: 0.8,
    ),
  );

  final success = await SmartLocalNotification.showNotification(notification);
  if (success) {
    print('Notification shown successfully');
  }
}
```

## Advanced Configuration

### 1. Custom Notification Channels (Android)

```dart
final notification = SmartNotification(
  id: 1,
  title: 'Custom Channel',
  body: 'This notification uses a custom channel',
  notificationSettings: NotificationSettings(
    channelId: 'custom_channel',
    channelName: 'Custom Notifications',
    channelDescription: 'Notifications for custom events',
    priority: NotificationPriority.high,
    silent: true,
  ),
  audioSettings: AudioSettings(
    audioPath: 'custom_sound.mp3',
    sourceType: AudioSourceType.asset,
  ),
);
```

### 2. Background Audio Configuration

```dart
final audioSettings = AudioSettings(
  audioPath: 'background_audio.mp3',
  sourceType: AudioSourceType.asset,
  playInBackground: true,
  loop: true,
  respectSilentMode: false,
  duckOthers: true,
);

// Optimize for background playback
final optimizedSettings = BackgroundAudioManager.optimizeForBackground(audioSettings);
```

### 3. Scheduled Notifications

```dart
final scheduledTime = DateTime.now().add(Duration(hours: 1));

final notification = SmartNotification(
  id: 2,
  title: 'Scheduled Notification',
  body: 'This notification was scheduled',
  scheduledTime: scheduledTime,
  notificationSettings: NotificationSettings(
    priority: NotificationPriority.defaultPriority,
    silent: true,
  ),
  audioSettings: AudioSettings(
    audioPath: 'scheduled_sound.mp3',
    sourceType: AudioSourceType.asset,
  ),
);
```

## Asset Management

### 1. Adding Audio Assets

Add audio files to your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/audio/
```

Create the directory structure:
```
assets/
  audio/
    notification.mp3
    alarm.mp3
    reminder.mp3
```

### 2. Supported Audio Formats

- **MP3**: Widely supported, good compression
- **WAV**: Uncompressed, larger files
- **AAC**: Good compression, iOS preferred
- **M4A**: Apple format, iOS optimized
- **OGG**: Android only
- **FLAC**: Android only, lossless

### 3. Audio File Guidelines

- **Size**: Keep under 1MB for better performance
- **Length**: 2-10 seconds for notifications
- **Quality**: 44.1kHz, 16-bit minimum
- **Naming**: Use descriptive, lowercase names

## Troubleshooting

### Common Issues

#### 1. Notifications Not Showing
- Check notification permissions
- Verify device notification settings
- Test with basic notification first
- Check Do Not Disturb mode

#### 2. Audio Not Playing
- Verify audio file exists and format is supported
- Check device volume and silent mode
- Ensure audio permissions are granted
- Test with different audio files

#### 3. Background Audio Stops
- Check battery optimization settings
- Verify background app refresh is enabled
- Ensure foreground service is working (Android)
- Check audio session configuration (iOS)

#### 4. Permission Issues
- Request permissions before using features
- Handle permission denial gracefully
- Check platform-specific permission requirements
- Test on different Android versions

### Platform-Specific Issues

#### Android
- **Battery Optimization**: Users may need to disable battery optimization
- **Notification Channels**: Required for Android 8.0+
- **Foreground Service**: Needed for reliable background audio
- **Exact Alarms**: May require special permission on Android 12+

#### iOS
- **Background Audio**: Limited by system policies
- **App Store Review**: Background audio may require justification
- **Silent Mode**: Respect user preferences
- **Audio Session**: Proper configuration is crucial

### Debug Tips

1. **Enable Logging**: Check console for error messages
2. **Test Incrementally**: Start with basic features
3. **Use Example App**: Reference implementation
4. **Check Permissions**: Verify all required permissions
5. **Test on Real Devices**: Emulators may behave differently

## Best Practices

### 1. User Experience
- Always request permissions with clear explanation
- Provide option to disable audio
- Respect device silent mode when appropriate
- Use appropriate notification priorities

### 2. Performance
- Optimize audio file sizes
- Clean up resources properly
- Monitor battery usage
- Use background audio judiciously

### 3. Accessibility
- Provide alternative notification methods
- Support screen readers
- Use clear, descriptive text
- Consider users with hearing impairments

### 4. Testing
- Test on multiple devices and OS versions
- Verify background behavior
- Check battery optimization scenarios
- Test permission flows

## Migration Guide

### From Other Notification Plugins

If migrating from other notification plugins:

1. **Remove old dependencies** from `pubspec.yaml`
2. **Update imports** to use Smart Local Notification
3. **Migrate notification models** to `SmartNotification`
4. **Update permission handling** to use plugin methods
5. **Test thoroughly** on target platforms

### Version Updates

When updating the plugin:

1. **Check changelog** for breaking changes
2. **Update platform configurations** if needed
3. **Test existing functionality**
4. **Update documentation** references

## Support

For additional help:

- Check the [example app](../example/) for reference implementation
- Review the [API documentation](api_reference.md)
- Submit issues on the GitHub repository
- Check platform-specific documentation for native features

## Next Steps

After completing the setup:

1. **Explore the Example App**: Run the example to see all features in action
2. **Read the API Reference**: Understand all available options and methods
3. **Implement Basic Features**: Start with simple notifications and add complexity
4. **Test Thoroughly**: Verify behavior on your target platforms and devices
5. **Optimize for Production**: Configure for best performance and user experience
