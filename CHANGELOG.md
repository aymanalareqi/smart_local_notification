# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-06-28

### Added
- Initial release of Smart Local Notification plugin
- Silent notification support with custom audio playback
- Cross-platform implementation for Android and iOS
- Support for asset-bundled and external filesystem audio files
- Background audio playback capabilities
- Configurable notification settings and audio options
- Permission handling for both platforms
- Comprehensive example application
- Full documentation and setup guides

### Features
- Native Android implementation using NotificationManager and MediaPlayer
- Native iOS implementation using UNUserNotificationCenter and AVAudioPlayer
- Flutter plugin architecture with method channels
- Audio fade in/out support
- Notification priority levels
- Custom notification channels (Android)
- Background audio session management
- Foreground service for reliable background operation (Android)

### Platform Support
- Android: API level 21+ (Android 5.0+)
- iOS: iOS 12.0+
- Flutter: 3.0.0+
