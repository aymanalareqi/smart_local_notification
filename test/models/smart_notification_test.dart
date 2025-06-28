import 'package:flutter_test/flutter_test.dart';
import 'package:smart_local_notification/smart_local_notification.dart';

void main() {
  group('SmartNotification', () {
    test('should create notification with required fields', () {
      final notification = SmartNotification(
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      expect(notification.id, 1);
      expect(notification.title, 'Test Title');
      expect(notification.body, 'Test Body');
      expect(notification.hasAudio, false);
      expect(notification.isImmediate, true);
      expect(notification.isScheduled, false);
    });

    test('should create notification with audio settings', () {
      final audioSettings = AudioSettings(
        audioPath: 'test.mp3',
        sourceType: AudioSourceType.asset,
      );

      final notification = SmartNotification(
        id: 2,
        title: 'Audio Test',
        body: 'Test with audio',
        audioSettings: audioSettings,
      );

      expect(notification.hasAudio, true);
      expect(notification.audioSettings, audioSettings);
    });

    test('should create scheduled notification', () {
      final scheduledTime = DateTime.now().add(Duration(hours: 1));
      final notification = SmartNotification(
        id: 3,
        title: 'Scheduled',
        body: 'Scheduled notification',
        scheduledTime: scheduledTime,
      );

      expect(notification.isScheduled, true);
      expect(notification.isImmediate, false);
      expect(notification.scheduledTime, scheduledTime);
    });

    test('should convert to and from map', () {
      final audioSettings = AudioSettings(
        audioPath: 'test.mp3',
        sourceType: AudioSourceType.asset,
        volume: 0.8,
        loop: true,
      );

      final notification = SmartNotification(
        id: 4,
        title: 'Map Test',
        body: 'Test map conversion',
        audioSettings: audioSettings,
        payload: {'key': 'value'},
      );

      final map = notification.toMap();
      final recreated = SmartNotification.fromMap(map);

      expect(recreated.id, notification.id);
      expect(recreated.title, notification.title);
      expect(recreated.body, notification.body);
      expect(recreated.hasAudio, notification.hasAudio);
      expect(recreated.payload, notification.payload);
    });

    test('should create copy with modified fields', () {
      final original = SmartNotification(
        id: 5,
        title: 'Original',
        body: 'Original body',
      );

      final copy = original.copyWith(
        title: 'Modified',
        audioSettings: AudioSettings(
          audioPath: 'new.mp3',
          sourceType: AudioSourceType.asset,
        ),
      );

      expect(copy.id, original.id);
      expect(copy.title, 'Modified');
      expect(copy.body, original.body);
      expect(copy.hasAudio, true);
      expect(original.hasAudio, false);
    });

    test('should handle equality correctly', () {
      final notification1 = SmartNotification(
        id: 6,
        title: 'Test',
        body: 'Test body',
      );

      final notification2 = SmartNotification(
        id: 6,
        title: 'Test',
        body: 'Test body',
      );

      final notification3 = SmartNotification(
        id: 7,
        title: 'Test',
        body: 'Test body',
      );

      expect(notification1, equals(notification2));
      expect(notification1, isNot(equals(notification3)));
    });
  });
}
