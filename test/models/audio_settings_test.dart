import 'package:flutter_test/flutter_test.dart';
import 'package:smart_local_notification/smart_local_notification.dart';

void main() {
  group('AudioSettings', () {
    test('should create audio settings with required fields', () {
      final settings = AudioSettings(
        audioPath: 'test.mp3',
        sourceType: AudioSourceType.asset,
      );

      expect(settings.audioPath, 'test.mp3');
      expect(settings.sourceType, AudioSourceType.asset);
      expect(settings.loop, false);
      expect(settings.volume, 1.0);
      expect(settings.playInBackground, true);
    });

    test('should create audio settings with all fields', () {
      final settings = AudioSettings(
        audioPath: 'custom.wav',
        sourceType: AudioSourceType.file,
        loop: true,
        volume: 0.5,
        fadeInDuration: Duration(seconds: 2),
        fadeOutDuration: Duration(seconds: 3),
        respectSilentMode: true,
        duckOthers: false,
        interruptOthers: true,
        audioSessionCategory: 'playback',
        playInBackground: false,
      );

      expect(settings.audioPath, 'custom.wav');
      expect(settings.sourceType, AudioSourceType.file);
      expect(settings.loop, true);
      expect(settings.volume, 0.5);
      expect(settings.fadeInDuration, Duration(seconds: 2));
      expect(settings.fadeOutDuration, Duration(seconds: 3));
      expect(settings.respectSilentMode, true);
      expect(settings.duckOthers, false);
      expect(settings.interruptOthers, true);
      expect(settings.audioSessionCategory, 'playback');
      expect(settings.playInBackground, false);
    });

    test('should validate volume range', () {
      expect(
        () => AudioSettings(
          audioPath: 'test.mp3',
          sourceType: AudioSourceType.asset,
          volume: 1.5,
        ),
        throwsAssertionError,
      );

      expect(
        () => AudioSettings(
          audioPath: 'test.mp3',
          sourceType: AudioSourceType.asset,
          volume: -0.1,
        ),
        throwsAssertionError,
      );
    });

    test('should convert to and from map', () {
      final settings = AudioSettings(
        audioPath: 'test.mp3',
        sourceType: AudioSourceType.asset,
        loop: true,
        volume: 0.8,
        fadeInDuration: Duration(milliseconds: 1500),
        fadeOutDuration: Duration(milliseconds: 2000),
      );

      final map = settings.toMap();
      final recreated = AudioSettings.fromMap(map);

      expect(recreated.audioPath, settings.audioPath);
      expect(recreated.sourceType, settings.sourceType);
      expect(recreated.loop, settings.loop);
      expect(recreated.volume, settings.volume);
      expect(recreated.fadeInDuration, settings.fadeInDuration);
      expect(recreated.fadeOutDuration, settings.fadeOutDuration);
    });

    test('should create copy with modified fields', () {
      final original = AudioSettings(
        audioPath: 'original.mp3',
        sourceType: AudioSourceType.asset,
        volume: 0.5,
      );

      final copy = original.copyWith(
        audioPath: 'modified.mp3',
        volume: 0.8,
        loop: true,
      );

      expect(copy.audioPath, 'modified.mp3');
      expect(copy.sourceType, original.sourceType);
      expect(copy.volume, 0.8);
      expect(copy.loop, true);
      expect(original.loop, false);
    });

    test('should get file extension', () {
      final mp3Settings = AudioSettings(
        audioPath: 'test.mp3',
        sourceType: AudioSourceType.asset,
      );

      final wavSettings = AudioSettings(
        audioPath: 'audio/test.wav',
        sourceType: AudioSourceType.file,
      );

      final noExtSettings = AudioSettings(
        audioPath: 'noextension',
        sourceType: AudioSourceType.asset,
      );

      expect(mp3Settings.fileExtension, 'mp3');
      expect(wavSettings.fileExtension, 'wav');
      expect(noExtSettings.fileExtension, null);
    });

    test('should check supported formats', () {
      final mp3Settings = AudioSettings(
        audioPath: 'test.mp3',
        sourceType: AudioSourceType.asset,
      );

      final txtSettings = AudioSettings(
        audioPath: 'test.txt',
        sourceType: AudioSourceType.asset,
      );

      expect(mp3Settings.isSupportedFormat, true);
      expect(txtSettings.isSupportedFormat, false);
    });

    test('should get normalized path', () {
      final assetSettings = AudioSettings(
        audioPath: 'test.mp3',
        sourceType: AudioSourceType.asset,
      );

      final fileSettings = AudioSettings(
        audioPath: '/path/to/file.mp3',
        sourceType: AudioSourceType.file,
      );

      expect(assetSettings.normalizedPath, 'assets/test.mp3');
      expect(fileSettings.normalizedPath, '/path/to/file.mp3');
    });

    test('should handle equality correctly', () {
      final settings1 = AudioSettings(
        audioPath: 'test.mp3',
        sourceType: AudioSourceType.asset,
        volume: 0.8,
      );

      final settings2 = AudioSettings(
        audioPath: 'test.mp3',
        sourceType: AudioSourceType.asset,
        volume: 0.8,
      );

      final settings3 = AudioSettings(
        audioPath: 'test.mp3',
        sourceType: AudioSourceType.asset,
        volume: 0.5,
      );

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });
  });
}
