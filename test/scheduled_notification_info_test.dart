import 'package:flutter_test/flutter_test.dart';
import 'package:smart_local_notification/src/models/scheduled_notification_info.dart';
import 'package:smart_local_notification/src/models/smart_notification.dart';
import 'package:smart_local_notification/src/models/notification_settings.dart';

void main() {
  group('ScheduledNotificationInfo', () {
    test('should handle int scheduleId from Android platform', () {
      // Simulate data coming from Android platform with int scheduleId
      final androidData = <String, dynamic>{
        'scheduleId': 123, // int value from Android
        'notification': <String, dynamic>{
          'id': 1,
          'title': 'Test Notification',
          'body': 'Test Body',
          'notificationSettings': <String, dynamic>{},
        },
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'triggerCount': 0,
        'isActive': true,
      };

      expect(() {
        final info = ScheduledNotificationInfo.fromMap(androidData);
        expect(info.scheduleId, equals('123')); // Should be converted to string
        expect(info.scheduleId, isA<String>());
      }, returnsNormally);
    });

    test('should handle string scheduleId from iOS platform', () {
      // Simulate data coming from iOS platform with string scheduleId
      final iosData = <String, dynamic>{
        'scheduleId': '456', // string value from iOS
        'notification': <String, dynamic>{
          'id': 2,
          'title': 'Test Notification 2',
          'body': 'Test Body 2',
          'notificationSettings': <String, dynamic>{},
        },
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'triggerCount': 1,
        'isActive': true,
      };

      expect(() {
        final info = ScheduledNotificationInfo.fromMap(iosData);
        expect(info.scheduleId, equals('456')); // Should remain as string
        expect(info.scheduleId, isA<String>());
      }, returnsNormally);
    });

    test('should handle null scheduleId gracefully', () {
      // Simulate data with null scheduleId
      final nullData = <String, dynamic>{
        'scheduleId': null,
        'notification': <String, dynamic>{
          'id': 3,
          'title': 'Test Notification 3',
          'body': 'Test Body 3',
          'notificationSettings': <String, dynamic>{},
        },
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'triggerCount': 2,
        'isActive': false,
      };

      expect(() {
        final info = ScheduledNotificationInfo.fromMap(nullData);
        expect(info.scheduleId, equals('')); // Should default to empty string
        expect(info.scheduleId, isA<String>());
      }, returnsNormally);
    });

    test('should handle platformScheduleId type conversion', () {
      // Test that platformScheduleId is also converted to string
      final data = <String, dynamic>{
        'scheduleId': 789,
        'notification': <String, dynamic>{
          'id': 4,
          'title': 'Test Notification 4',
          'body': 'Test Body 4',
          'notificationSettings': <String, dynamic>{},
        },
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'triggerCount': 0,
        'isActive': true,
        'platformScheduleId':
            999, // int value that should be converted to string
      };

      expect(() {
        final info = ScheduledNotificationInfo.fromMap(data);
        expect(info.scheduleId, equals('789'));
        expect(info.platformScheduleId,
            equals('999')); // Should be converted to string
        expect(info.platformScheduleId, isA<String>());
      }, returnsNormally);
    });

    test('should serialize and deserialize correctly', () {
      final originalInfo = ScheduledNotificationInfo(
        scheduleId: '123',
        notification: const SmartNotification(
          id: 1,
          title: 'Test',
          body: 'Test Body',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        triggerCount: 5,
        isActive: true,
        platformScheduleId: '456',
      );

      // Convert to map and back
      final map = originalInfo.toMap();
      final deserializedInfo = ScheduledNotificationInfo.fromMap(map);

      expect(deserializedInfo.scheduleId, equals(originalInfo.scheduleId));
      expect(deserializedInfo.notification.id,
          equals(originalInfo.notification.id));
      expect(deserializedInfo.notification.title,
          equals(originalInfo.notification.title));
      expect(deserializedInfo.triggerCount, equals(originalInfo.triggerCount));
      expect(deserializedInfo.isActive, equals(originalInfo.isActive));
      expect(deserializedInfo.platformScheduleId,
          equals(originalInfo.platformScheduleId));
    });
  });
}
