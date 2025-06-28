import 'package:flutter_test/flutter_test.dart';
import 'package:smart_local_notification/smart_local_notification.dart';
import 'package:smart_local_notification/src/smart_local_notification_platform_interface.dart';
import 'package:smart_local_notification/src/smart_local_notification_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmartLocalNotificationPlatform
    with MockPlatformInterfaceMixin
    implements SmartLocalNotificationPlatform {
  @override
  Future<bool> initialize() async {
    return true;
  }

  @override
  Future<bool> showNotification(SmartNotification notification) async {
    return true;
  }

  @override
  Future<bool> cancelNotification(int id) async {
    return true;
  }

  @override
  Future<bool> cancelAllNotifications() async {
    return true;
  }

  @override
  Future<bool> stopAudio() async {
    return true;
  }

  @override
  Future<bool> isAudioPlaying() async {
    return false;
  }

  @override
  Future<bool> requestPermissions() async {
    return true;
  }

  @override
  Future<bool> arePermissionsGranted() async {
    return true;
  }

  @override
  Future<bool> scheduleNotification(SmartNotification notification) async {
    return true;
  }

  @override
  Future<bool> cancelScheduledNotification(int id) async {
    return true;
  }

  @override
  Future<bool> cancelAllScheduledNotifications() async {
    return true;
  }

  @override
  Future<List<ScheduledNotificationInfo>> getScheduledNotifications(
      [ScheduledNotificationQuery? query]) async {
    return [];
  }

  @override
  Future<bool> updateScheduledNotification(
      String scheduleId, Map<String, dynamic> updates) async {
    return true;
  }

  @override
  Future<BatchScheduleResult> batchScheduleNotifications(
      List<SmartNotification> notifications) async {
    // Convert SmartNotifications to ScheduledNotificationInfo for mock
    final successful = notifications
        .map((notification) => ScheduledNotificationInfo(
              scheduleId: notification.id.toString(),
              notification: notification,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ))
        .toList();

    return BatchScheduleResult(
      successful: successful,
      failed: [],
      total: notifications.length,
    );
  }
}

void main() {
  final SmartLocalNotificationPlatform initialPlatform =
      SmartLocalNotificationPlatform.instance;

  test('$MethodChannelSmartLocalNotification is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelSmartLocalNotification>());
  });

  test('initialize', () async {
    MockSmartLocalNotificationPlatform fakePlatform =
        MockSmartLocalNotificationPlatform();
    SmartLocalNotificationPlatform.instance = fakePlatform;

    expect(await SmartLocalNotification.initialize(), true);
  });

  test('showNotification', () async {
    MockSmartLocalNotificationPlatform fakePlatform =
        MockSmartLocalNotificationPlatform();
    SmartLocalNotificationPlatform.instance = fakePlatform;

    final notification = SmartNotification(
      id: 1,
      title: 'Test',
      body: 'Test notification',
    );

    expect(await SmartLocalNotification.showNotification(notification), true);
  });

  test('cancelNotification', () async {
    MockSmartLocalNotificationPlatform fakePlatform =
        MockSmartLocalNotificationPlatform();
    SmartLocalNotificationPlatform.instance = fakePlatform;

    expect(await SmartLocalNotification.cancelNotification(1), true);
  });

  test('cancelAllNotifications', () async {
    MockSmartLocalNotificationPlatform fakePlatform =
        MockSmartLocalNotificationPlatform();
    SmartLocalNotificationPlatform.instance = fakePlatform;

    expect(await SmartLocalNotification.cancelAllNotifications(), true);
  });

  test('stopAudio', () async {
    MockSmartLocalNotificationPlatform fakePlatform =
        MockSmartLocalNotificationPlatform();
    SmartLocalNotificationPlatform.instance = fakePlatform;

    expect(await SmartLocalNotification.stopAudio(), true);
  });

  test('isAudioPlaying', () async {
    MockSmartLocalNotificationPlatform fakePlatform =
        MockSmartLocalNotificationPlatform();
    SmartLocalNotificationPlatform.instance = fakePlatform;

    expect(await SmartLocalNotification.isAudioPlaying(), false);
  });

  test('requestPermissions', () async {
    MockSmartLocalNotificationPlatform fakePlatform =
        MockSmartLocalNotificationPlatform();
    SmartLocalNotificationPlatform.instance = fakePlatform;

    expect(await SmartLocalNotification.requestPermissions(), true);
  });

  test('arePermissionsGranted', () async {
    MockSmartLocalNotificationPlatform fakePlatform =
        MockSmartLocalNotificationPlatform();
    SmartLocalNotificationPlatform.instance = fakePlatform;

    expect(await SmartLocalNotification.arePermissionsGranted(), true);
  });
}
