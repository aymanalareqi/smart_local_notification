import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'models/smart_notification.dart';
import 'smart_local_notification_platform_interface.dart';

/// An implementation of [SmartLocalNotificationPlatform] that uses method channels.
class MethodChannelSmartLocalNotification extends SmartLocalNotificationPlatform {
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
      debugPrint('SmartLocalNotification: Failed to show notification: ${e.message}');
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
      debugPrint('SmartLocalNotification: Failed to cancel notification: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> cancelAllNotifications() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('cancelAllNotifications');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('SmartLocalNotification: Failed to cancel all notifications: ${e.message}');
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
      debugPrint('SmartLocalNotification: Failed to check audio status: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('requestPermissions');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('SmartLocalNotification: Failed to request permissions: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> arePermissionsGranted() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('arePermissionsGranted');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('SmartLocalNotification: Failed to check permissions: ${e.message}');
      return false;
    }
  }
}
