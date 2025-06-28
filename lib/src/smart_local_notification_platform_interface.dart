import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'models/smart_notification.dart';
import 'models/scheduled_notification_info.dart';
import 'smart_local_notification_method_channel.dart';

/// The interface that implementations of smart_local_notification must implement.
///
/// Platform implementations should extend this class rather than implement it as `SmartLocalNotification`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [SmartLocalNotificationPlatform] methods.
abstract class SmartLocalNotificationPlatform extends PlatformInterface {
  /// Constructs a SmartLocalNotificationPlatform.
  SmartLocalNotificationPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmartLocalNotificationPlatform _instance =
      MethodChannelSmartLocalNotification();

  /// The default instance of [SmartLocalNotificationPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmartLocalNotification].
  static SmartLocalNotificationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SmartLocalNotificationPlatform] when
  /// they register themselves.
  static set instance(SmartLocalNotificationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize the plugin.
  Future<bool> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Show a notification with custom audio.
  Future<bool> showNotification(SmartNotification notification) {
    throw UnimplementedError('showNotification() has not been implemented.');
  }

  /// Cancel a notification by ID.
  Future<bool> cancelNotification(int id) {
    throw UnimplementedError('cancelNotification() has not been implemented.');
  }

  /// Cancel all notifications.
  Future<bool> cancelAllNotifications() {
    throw UnimplementedError(
        'cancelAllNotifications() has not been implemented.');
  }

  /// Stop audio playback.
  Future<bool> stopAudio() {
    throw UnimplementedError('stopAudio() has not been implemented.');
  }

  /// Check if audio is currently playing.
  Future<bool> isAudioPlaying() {
    throw UnimplementedError('isAudioPlaying() has not been implemented.');
  }

  /// Request notification permissions.
  Future<bool> requestPermissions() {
    throw UnimplementedError('requestPermissions() has not been implemented.');
  }

  /// Check if notification permissions are granted.
  Future<bool> arePermissionsGranted() {
    throw UnimplementedError(
        'arePermissionsGranted() has not been implemented.');
  }

  /// Schedules a notification for future delivery.
  Future<bool> scheduleNotification(SmartNotification notification) {
    throw UnimplementedError(
        'scheduleNotification() has not been implemented.');
  }

  /// Cancels a scheduled notification by ID.
  Future<bool> cancelScheduledNotification(int id) {
    throw UnimplementedError(
        'cancelScheduledNotification() has not been implemented.');
  }

  /// Cancels all scheduled notifications.
  Future<bool> cancelAllScheduledNotifications() {
    throw UnimplementedError(
        'cancelAllScheduledNotifications() has not been implemented.');
  }

  /// Gets scheduled notifications based on query parameters.
  Future<List<ScheduledNotificationInfo>> getScheduledNotifications(
      [ScheduledNotificationQuery? query]) {
    throw UnimplementedError(
        'getScheduledNotifications() has not been implemented.');
  }

  /// Updates a scheduled notification.
  Future<bool> updateScheduledNotification(
      String scheduleId, Map<String, dynamic> updates) {
    throw UnimplementedError(
        'updateScheduledNotification() has not been implemented.');
  }

  /// Schedules multiple notifications in a batch operation.
  Future<BatchScheduleResult> batchScheduleNotifications(
      List<SmartNotification> notifications) {
    throw UnimplementedError(
        'batchScheduleNotifications() has not been implemented.');
  }
}
