import 'package:flutter_test/flutter_test.dart';
import 'package:smart_local_notification/smart_local_notification.dart';
import 'package:smart_local_notification/src/smart_local_notification_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmartLocalNotificationPlatform extends SmartLocalNotificationPlatform
    with MockPlatformInterfaceMixin {
  bool _permissionsGranted = false;
  bool _shouldFailPermissionRequest = false;
  bool _shouldFailPermissionCheck = false;

  // Control methods for testing
  void setPermissionsGranted(bool granted) {
    _permissionsGranted = granted;
  }

  void setShouldFailPermissionRequest(bool shouldFail) {
    _shouldFailPermissionRequest = shouldFail;
  }

  void setShouldFailPermissionCheck(bool shouldFail) {
    _shouldFailPermissionCheck = shouldFail;
  }

  @override
  Future<bool> requestPermissions() async {
    if (_shouldFailPermissionRequest) {
      return false; // Simulate platform failure
    }
    return _permissionsGranted;
  }

  @override
  Future<bool> arePermissionsGranted() async {
    if (_shouldFailPermissionCheck) {
      return false; // Simulate platform failure
    }
    return _permissionsGranted;
  }

  // Other required methods (minimal implementation for testing)
  @override
  Future<bool> initialize() async => true;

  @override
  Future<bool> showNotification(SmartNotification notification) async => true;

  @override
  Future<bool> cancelNotification(int id) async => true;

  @override
  Future<bool> cancelAllNotifications() async => true;

  @override
  Future<bool> stopAudio() async => true;

  @override
  Future<bool> isAudioPlaying() async => false;

  @override
  Future<bool> scheduleNotification(SmartNotification notification) async =>
      true;

  @override
  Future<bool> cancelScheduledNotification(int id) async => true;

  @override
  Future<bool> cancelAllScheduledNotifications() async => true;

  @override
  Future<List<ScheduledNotificationInfo>> getScheduledNotifications(
          [ScheduledNotificationQuery? query]) async =>
      [];

  @override
  Future<bool> updateScheduledNotification(
          String scheduleId, Map<String, dynamic> updates) async =>
      true;

  @override
  Future<BatchScheduleResult> batchScheduleNotifications(
          List<SmartNotification> notifications) async =>
      BatchScheduleResult(
        successful: [],
        failed: [],
        total: 0,
      );
}

void main() {
  group('SmartLocalNotification Permission Tests', () {
    late MockSmartLocalNotificationPlatform fakePlatform;

    setUp(() {
      fakePlatform = MockSmartLocalNotificationPlatform();
      SmartLocalNotificationPlatform.instance = fakePlatform;
    });

    group('requestPermissions', () {
      test('should return true when permissions are granted', () async {
        fakePlatform.setPermissionsGranted(true);

        final result = await SmartLocalNotification.requestPermissions();

        expect(result, isTrue);
      });

      test('should return false when permissions are denied', () async {
        fakePlatform.setPermissionsGranted(false);

        final result = await SmartLocalNotification.requestPermissions();

        expect(result, isFalse);
      });

      test('should handle permission request failure gracefully', () async {
        fakePlatform.setShouldFailPermissionRequest(true);

        final result = await SmartLocalNotification.requestPermissions();

        expect(result, isFalse);
      });

      test('should handle multiple permission requests correctly', () async {
        fakePlatform.setPermissionsGranted(true);

        final result1 = await SmartLocalNotification.requestPermissions();
        final result2 = await SmartLocalNotification.requestPermissions();

        expect(result1, isTrue);
        expect(result2, isTrue);
      });
    });

    group('arePermissionsGranted', () {
      test('should return true when permissions are granted', () async {
        fakePlatform.setPermissionsGranted(true);

        final result = await SmartLocalNotification.arePermissionsGranted();

        expect(result, isTrue);
      });

      test('should return false when permissions are not granted', () async {
        fakePlatform.setPermissionsGranted(false);

        final result = await SmartLocalNotification.arePermissionsGranted();

        expect(result, isFalse);
      });

      test('should handle permission check failure gracefully', () async {
        fakePlatform.setShouldFailPermissionCheck(true);

        final result = await SmartLocalNotification.arePermissionsGranted();

        expect(result, isFalse);
      });

      test('should reflect permission state changes', () async {
        // Initially no permissions
        fakePlatform.setPermissionsGranted(false);
        expect(await SmartLocalNotification.arePermissionsGranted(), isFalse);

        // Grant permissions
        fakePlatform.setPermissionsGranted(true);
        expect(await SmartLocalNotification.arePermissionsGranted(), isTrue);

        // Revoke permissions
        fakePlatform.setPermissionsGranted(false);
        expect(await SmartLocalNotification.arePermissionsGranted(), isFalse);
      });
    });

    group('permission workflow', () {
      test('should handle complete permission workflow', () async {
        // Start with no permissions
        fakePlatform.setPermissionsGranted(false);
        expect(await SmartLocalNotification.arePermissionsGranted(), isFalse);

        // Request permissions (simulate user granting)
        fakePlatform.setPermissionsGranted(true);
        final requestResult = await SmartLocalNotification.requestPermissions();
        expect(requestResult, isTrue);

        // Verify permissions are now granted
        expect(await SmartLocalNotification.arePermissionsGranted(), isTrue);
      });

      test('should handle permission denial workflow', () async {
        // Start with no permissions
        fakePlatform.setPermissionsGranted(false);
        expect(await SmartLocalNotification.arePermissionsGranted(), isFalse);

        // Request permissions (simulate user denying)
        final requestResult = await SmartLocalNotification.requestPermissions();
        expect(requestResult, isFalse);

        // Verify permissions are still not granted
        expect(await SmartLocalNotification.arePermissionsGranted(), isFalse);
      });
    });

    group('error handling', () {
      test('should handle concurrent permission requests', () async {
        fakePlatform.setPermissionsGranted(true);

        final futures = List.generate(
            5, (_) => SmartLocalNotification.requestPermissions());
        final results = await Future.wait(futures);

        expect(results, everyElement(isTrue));
      });

      test('should handle mixed success and failure scenarios', () async {
        // First request succeeds
        fakePlatform.setPermissionsGranted(true);
        fakePlatform.setShouldFailPermissionRequest(false);
        expect(await SmartLocalNotification.requestPermissions(), isTrue);

        // Second request fails
        fakePlatform.setShouldFailPermissionRequest(true);
        expect(await SmartLocalNotification.requestPermissions(), isFalse);

        // Third request succeeds again
        fakePlatform.setShouldFailPermissionRequest(false);
        expect(await SmartLocalNotification.requestPermissions(), isTrue);
      });
    });
  });
}
