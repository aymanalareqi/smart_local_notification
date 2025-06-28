import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'models/smart_notification.dart';
import 'models/scheduled_notification_info.dart';
import 'smart_local_notification_platform_interface.dart';

/// An implementation of [SmartLocalNotificationPlatform] that uses method channels.
class MethodChannelSmartLocalNotification
    extends SmartLocalNotificationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('smart_local_notification');

  @override
  Future<bool> initialize() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('initialize');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('SmartLocalNotification: Failed to initialize: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> showNotification(SmartNotification notification) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'showNotification',
        notification.toMap(),
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to show notification: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> cancelNotification(int id) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'cancelNotification',
        {'id': id},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to cancel notification: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> cancelAllNotifications() async {
    try {
      final result =
          await methodChannel.invokeMethod<bool>('cancelAllNotifications');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to cancel all notifications: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> stopAudio() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('stopAudio');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('SmartLocalNotification: Failed to stop audio: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> isAudioPlaying() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isAudioPlaying');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to check audio status: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final result =
          await methodChannel.invokeMethod<bool>('requestPermissions');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to request permissions: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> arePermissionsGranted() async {
    try {
      final result =
          await methodChannel.invokeMethod<bool>('arePermissionsGranted');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to check permissions: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> scheduleNotification(SmartNotification notification) async {
    try {
      final result =
          await methodChannel.invokeMethod<bool>('scheduleNotification', {
        'notification': notification.toMap(),
        'schedule': notification.schedule?.toMap(),
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to schedule notification: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> cancelScheduledNotification(int id) async {
    try {
      final result = await methodChannel
          .invokeMethod<bool>('cancelScheduledNotification', {
        'id': id,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to cancel scheduled notification: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> cancelAllScheduledNotifications() async {
    try {
      final result = await methodChannel
          .invokeMethod<bool>('cancelAllScheduledNotifications');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to cancel all scheduled notifications: ${e.message}');
      return false;
    }
  }

  @override
  Future<List<ScheduledNotificationInfo>> getScheduledNotifications(
      [ScheduledNotificationQuery? query]) async {
    try {
      final result = await methodChannel.invokeMethod<List<dynamic>>(
          'getScheduledNotifications', query?.toMap());
      return (result ?? [])
          .map((item) => ScheduledNotificationInfo.fromMap(
              Map<String, dynamic>.from(item)))
          .toList();
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to get scheduled notifications: ${e.message}');
      return [];
    }
  }

  @override
  Future<bool> updateScheduledNotification(
      String scheduleId, Map<String, dynamic> updates) async {
    try {
      final result = await methodChannel
          .invokeMethod<bool>('updateScheduledNotification', {
        'scheduleId': int.tryParse(scheduleId) ?? 0,
        'updates': updates,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'SmartLocalNotification: Failed to update scheduled notification: ${e.message}');
      return false;
    }
  }

  @override
  Future<BatchScheduleResult> batchScheduleNotifications(
      List<SmartNotification> notifications) async {
    final successful = <ScheduledNotificationInfo>[];
    final failed = <BatchScheduleError>[];

    for (final notification in notifications) {
      try {
        final success = await scheduleNotification(notification);
        if (success) {
          // Create a scheduled notification info for successful scheduling
          final scheduleInfo = ScheduledNotificationInfo(
            scheduleId: 'batch_${notification.id}',
            notification: notification,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            nextOccurrence: notification.nextOccurrence,
          );
          successful.add(scheduleInfo);
        } else {
          failed.add(BatchScheduleError(
            notification: notification,
            error: 'Failed to schedule notification',
          ));
        }
      } catch (e) {
        failed.add(BatchScheduleError(
          notification: notification,
          error: e.toString(),
        ));
      }
    }

    return BatchScheduleResult(
      successful: successful,
      failed: failed,
      total: notifications.length,
    );
  }
}
