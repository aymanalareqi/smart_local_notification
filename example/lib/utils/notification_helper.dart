import 'package:smart_local_notification/smart_local_notification.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper class for managing notifications in the example app.
class NotificationHelper {
  static int _notificationIdCounter = 1;

  /// Initialize the notification helper.
  static Future<void> initialize() async {
    // Request permissions
    await requestPermissions();

    // Listen to notification events
    SmartLocalNotification.onNotificationEvent.listen((event) {
      print('Notification Event: ${event.type} - ID: ${event.notificationId}');
      if (event.error != null) {
        print('Error: ${event.error}');
      }
    });
  }

  /// Request necessary permissions.
  static Future<bool> requestPermissions() async {
    // Request notification permissions through the plugin
    final pluginPermissions = await SmartLocalNotification.requestPermissions();

    // Request additional permissions through permission_handler
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.audio,
      Permission.storage,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);

    return pluginPermissions && allGranted;
  }

  /// Check if all permissions are granted.
  static Future<bool> arePermissionsGranted() async {
    final pluginPermissions =
        await SmartLocalNotification.arePermissionsGranted();

    final notificationStatus = await Permission.notification.status;
    final audioStatus = await Permission.audio.status;

    return pluginPermissions &&
        notificationStatus.isGranted &&
        audioStatus.isGranted;
  }

  /// Get the next notification ID.
  static int getNextId() {
    return _notificationIdCounter++;
  }

  /// Create a simple notification with asset audio.
  static SmartNotification createAssetAudioNotification({
    String? title,
    String? body,
    String? audioPath,
    bool loop = false,
  }) {
    return SmartNotification(
      id: getNextId(),
      title: title ?? 'Asset Audio Notification',
      body: body ?? 'This notification plays audio from app assets',
      notificationSettings: const NotificationSettings(
        priority: NotificationPriority.high,
        silent: true,
      ),
      audioSettings: AudioSettings(
        audioPath: audioPath ??
            'notification.mp3', // Will be prefixed with assets/ automatically
        sourceType: AudioSourceType.asset,
        loop: loop,
        volume: 0.8,
      ),
    );
  }

  /// Create a notification with file system audio.
  static SmartNotification createFileAudioNotification({
    String? title,
    String? body,
    required String filePath,
    bool loop = false,
  }) {
    return SmartNotification(
      id: getNextId(),
      title: title ?? 'File Audio Notification',
      body: body ?? 'This notification plays audio from file system',
      notificationSettings: const NotificationSettings(
        priority: NotificationPriority.high,
        silent: true,
      ),
      audioSettings: AudioSettings(
        audioPath: filePath,
        sourceType: AudioSourceType.file,
        loop: loop,
        volume: 0.8,
      ),
    );
  }

  /// Create an alarm-style notification.
  static SmartNotification createAlarmNotification({
    String? title,
    String? body,
    String? audioPath,
  }) {
    return NotificationAudioCoordinator.createAlarmStyleNotification(
      id: getNextId(),
      title: title ?? 'Alarm Notification',
      body: body ?? 'This is an alarm-style notification with looping audio',
      audioSettings: AudioSettings(
        audioPath: audioPath ?? 'assets/audio/alarm.mp3',
        sourceType: AudioSourceType.asset,
        loop: true,
        volume: 1.0,
        respectSilentMode: false,
      ),
    );
  }

  /// Create a reminder-style notification.
  static SmartNotification createReminderNotification({
    String? title,
    String? body,
    String? audioPath,
  }) {
    return NotificationAudioCoordinator.createReminderStyleNotification(
      id: getNextId(),
      title: title ?? 'Reminder Notification',
      body: body ?? 'This is a gentle reminder with custom audio',
      audioSettings: AudioSettings(
        audioPath: audioPath ?? 'assets/audio/reminder.mp3',
        sourceType: AudioSourceType.asset,
        loop: false,
        volume: 0.6,
        respectSilentMode: true,
        fadeInDuration: const Duration(seconds: 2),
        fadeOutDuration: const Duration(seconds: 2),
      ),
    );
  }

  /// Create a scheduled notification.
  static SmartNotification createScheduledNotification({
    String? title,
    String? body,
    String? audioPath,
    required DateTime scheduledTime,
  }) {
    return SmartNotification(
      id: getNextId(),
      title: title ?? 'Scheduled Notification',
      body: body ??
          'This notification was scheduled for ${scheduledTime.toString()}',
      scheduledTime: scheduledTime,
      notificationSettings: const NotificationSettings(
        priority: NotificationPriority.defaultPriority,
        silent: true,
      ),
      audioSettings: AudioSettings(
        audioPath: audioPath ?? 'assets/audio/scheduled.mp3',
        sourceType: AudioSourceType.asset,
        loop: false,
        volume: 0.7,
      ),
    );
  }

  /// Validate audio file before creating notification.
  static Future<bool> validateAudioFile(
      String path, AudioSourceType sourceType) async {
    final result =
        await AudioFileManager.validateAudioSettings(path, sourceType);
    return result.isValid;
  }

  /// Get audio file information.
  static Future<AudioValidationResult> getAudioFileInfo(
      String path, AudioSourceType sourceType) async {
    return await AudioFileManager.validateAudioSettings(path, sourceType);
  }

  /// Stop all audio and cancel all notifications.
  static Future<void> stopAllAndClear() async {
    await SmartLocalNotification.stopAudio();
    await SmartLocalNotification.cancelAllNotifications();
  }
}
