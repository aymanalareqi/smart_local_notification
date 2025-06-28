# Smart Local Notification Example App

This example app demonstrates all the features of the Smart Local Notification plugin, including silent notifications with custom audio playback, background audio management, and cross-platform compatibility.

## Features Demonstrated

### 1. Basic Notifications
- Silent notifications with custom audio from assets
- Looping audio notifications (alarm-style)
- Different notification priorities and settings

### 2. Custom Audio Sources
- Asset-bundled audio files
- External file system audio files
- Audio file validation and format checking
- File picker integration for custom audio selection

### 3. Notification Styles
- **Alarm Style**: High priority, looping audio, persistent notification
- **Reminder Style**: Gentle audio with fade in/out effects
- **Scheduled**: Notifications scheduled for future times

### 4. Background Audio Management
- Audio continues playing when app is backgrounded
- Proper audio session management
- Battery impact estimation
- Keep-alive mechanisms for reliable playback

### 5. Advanced Features
- Audio file validation and format checking
- Real-time audio status monitoring
- Permission management
- Notification scheduling
- Custom notification settings

## Setup Instructions

### 1. Install Dependencies

```bash
cd example
flutter pub get
```

### 2. Add Audio Files

Add sample audio files to `example/assets/audio/`:
- `notification.mp3` - Short notification sound
- `alarm.mp3` - Alarm sound for looping
- `reminder.mp3` - Gentle reminder sound
- `scheduled.mp3` - Scheduled notification sound

See `example/assets/audio/README.md` for detailed requirements.

### 3. Platform Setup

#### Android Setup

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS Setup

Add to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>background-processing</string>
</array>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to audio files for custom notification sounds.</string>
```

### 4. Run the App

```bash
flutter run
```

## App Structure

### Screens

1. **Home Screen** (`lib/screens/home_screen.dart`)
   - Main interface with notification examples
   - Audio status monitoring
   - Permission management

2. **Audio File Picker** (`lib/screens/audio_file_picker_screen.dart`)
   - File picker for custom audio files
   - Audio file validation
   - Custom notification settings

3. **Scheduled Notifications** (`lib/screens/scheduled_notifications_screen.dart`)
   - Schedule notifications for future times
   - Quick schedule options
   - Date/time picker integration

4. **Settings** (`lib/screens/settings_screen.dart`)
   - App status and diagnostics
   - Permission management
   - Plugin information

### Utilities

1. **Notification Helper** (`lib/utils/notification_helper.dart`)
   - Pre-configured notification templates
   - Permission management
   - Audio file validation

2. **Widgets** (`lib/widgets/`)
   - Reusable UI components
   - Audio status display
   - Notification cards

## Testing Scenarios

### 1. Basic Functionality
- [ ] Show notification with asset audio
- [ ] Show notification with looping audio
- [ ] Stop audio playback
- [ ] Cancel notifications

### 2. Custom Audio Files
- [ ] Pick audio file from device storage
- [ ] Validate different audio formats
- [ ] Play notification with custom file
- [ ] Handle invalid audio files

### 3. Background Behavior
- [ ] Audio continues when app is backgrounded
- [ ] Audio continues when app is closed (Android)
- [ ] Proper audio session management
- [ ] Battery optimization handling

### 4. Scheduled Notifications
- [ ] Schedule notification for future time
- [ ] Notification appears at scheduled time
- [ ] Audio plays with scheduled notification
- [ ] Handle timezone changes

### 5. Permission Handling
- [ ] Request notification permissions
- [ ] Handle permission denial
- [ ] Check permission status
- [ ] Graceful degradation without permissions

### 6. Error Handling
- [ ] Invalid audio file paths
- [ ] Missing audio files
- [ ] Network audio files (if supported)
- [ ] Platform-specific limitations

## Troubleshooting

### Audio Not Playing
1. Check if audio files exist in `assets/audio/`
2. Verify audio file formats are supported
3. Check device volume and silent mode settings
4. Ensure permissions are granted

### Notifications Not Showing
1. Check notification permissions
2. Verify device notification settings
3. Check Do Not Disturb mode
4. Test with basic notification first

### Background Audio Issues
1. Check battery optimization settings
2. Verify background app refresh is enabled
3. Test foreground service functionality
4. Check audio session configuration

### File Picker Issues
1. Ensure storage permissions are granted
2. Check file picker plugin compatibility
3. Verify audio file accessibility
4. Test with different file locations

## Performance Considerations

### Battery Usage
- Looping audio increases battery consumption
- Background audio uses more power
- Use fade effects sparingly
- Monitor battery impact in production

### Memory Usage
- Large audio files consume more memory
- Multiple simultaneous notifications increase usage
- Clean up resources properly
- Use appropriate audio compression

### Storage
- Asset audio files increase app size
- External files don't affect app size
- Consider audio quality vs. file size
- Implement audio file caching if needed

## Platform Differences

### Android
- Foreground service for background audio
- More flexible notification customization
- Better background audio support
- Battery optimization challenges

### iOS
- Background audio limitations
- Stricter notification policies
- Better audio session management
- App Store review considerations

## Contributing

When contributing to the example app:

1. Test on both Android and iOS
2. Verify all features work as expected
3. Update documentation for new features
4. Follow Flutter best practices
5. Ensure accessibility compliance
