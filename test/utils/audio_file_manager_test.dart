import 'package:flutter_test/flutter_test.dart';
import 'package:smart_local_notification/smart_local_notification.dart';

void main() {
  group('AudioFileManager', () {
    test('should normalize asset paths correctly', () {
      expect(
        AudioFileManager.normalizeAudioPath('test.mp3', AudioSourceType.asset),
        'assets/test.mp3',
      );

      expect(
        AudioFileManager.normalizeAudioPath('assets/test.mp3', AudioSourceType.asset),
        'assets/test.mp3',
      );
    });

    test('should not modify file and URL paths', () {
      expect(
        AudioFileManager.normalizeAudioPath('/path/to/file.mp3', AudioSourceType.file),
        '/path/to/file.mp3',
      );

      expect(
        AudioFileManager.normalizeAudioPath('https://example.com/audio.mp3', AudioSourceType.url),
        'https://example.com/audio.mp3',
      );
    });

    test('should extract file extensions correctly', () {
      expect(AudioFileManager.getFileExtension('test.mp3'), 'mp3');
      expect(AudioFileManager.getFileExtension('audio/file.wav'), 'wav');
      expect(AudioFileManager.getFileExtension('path/to/audio.m4a'), 'm4a');
      expect(AudioFileManager.getFileExtension('noextension'), null);
      expect(AudioFileManager.getFileExtension('file.'), null);
      expect(AudioFileManager.getFileExtension(''), null);
    });

    test('should identify supported audio formats', () {
      expect(AudioFileManager.isSupportedAudioFormat('mp3'), true);
      expect(AudioFileManager.isSupportedAudioFormat('wav'), true);
      expect(AudioFileManager.isSupportedAudioFormat('aac'), true);
      expect(AudioFileManager.isSupportedAudioFormat('m4a'), true);
      expect(AudioFileManager.isSupportedAudioFormat('ogg'), true);
      expect(AudioFileManager.isSupportedAudioFormat('flac'), true);
      expect(AudioFileManager.isSupportedAudioFormat('mp4'), true);

      expect(AudioFileManager.isSupportedAudioFormat('txt'), false);
      expect(AudioFileManager.isSupportedAudioFormat('jpg'), false);
      expect(AudioFileManager.isSupportedAudioFormat('pdf'), false);
      expect(AudioFileManager.isSupportedAudioFormat(null), false);
      expect(AudioFileManager.isSupportedAudioFormat(''), false);
    });

    test('should return correct MIME types', () {
      expect(AudioFileManager.getMimeType('mp3'), 'audio/mpeg');
      expect(AudioFileManager.getMimeType('wav'), 'audio/wav');
      expect(AudioFileManager.getMimeType('aac'), 'audio/aac');
      expect(AudioFileManager.getMimeType('m4a'), 'audio/mp4');
      expect(AudioFileManager.getMimeType('ogg'), 'audio/ogg');
      expect(AudioFileManager.getMimeType('flac'), 'audio/flac');
      expect(AudioFileManager.getMimeType('mp4'), 'audio/mp4');

      expect(AudioFileManager.getMimeType('txt'), null);
      expect(AudioFileManager.getMimeType(null), null);
      expect(AudioFileManager.getMimeType(''), null);
    });

    test('should format file sizes correctly', () {
      expect(AudioFileManager.formatFileSize(500), '500 B');
      expect(AudioFileManager.formatFileSize(1024), '1.0 KB');
      expect(AudioFileManager.formatFileSize(1536), '1.5 KB');
      expect(AudioFileManager.formatFileSize(1024 * 1024), '1.0 MB');
      expect(AudioFileManager.formatFileSize(1024 * 1024 * 1024), '1.0 GB');
    });

    test('should validate audio settings and return appropriate results', () async {
      // Test empty path
      final emptyPathResult = await AudioFileManager.validateAudioSettings('', AudioSourceType.asset);
      expect(emptyPathResult.isValid, false);
      expect(emptyPathResult.error, contains('empty'));

      // Test unsupported format
      final unsupportedResult = await AudioFileManager.validateAudioSettings('test.txt', AudioSourceType.asset);
      expect(unsupportedResult.isValid, false);
      expect(unsupportedResult.error, contains('Unsupported'));
      expect(unsupportedResult.supportedFormats, isNotNull);
    });
  });

  group('AudioValidationResult', () {
    test('should create valid result', () {
      const result = AudioValidationResult(
        isValid: true,
        normalizedPath: 'assets/test.mp3',
        fileExtension: 'mp3',
        mimeType: 'audio/mpeg',
        fileSize: 1024,
      );

      expect(result.isValid, true);
      expect(result.normalizedPath, 'assets/test.mp3');
      expect(result.fileExtension, 'mp3');
      expect(result.mimeType, 'audio/mpeg');
      expect(result.fileSize, 1024);
      expect(result.formattedFileSize, '1.0 KB');
    });

    test('should create invalid result with error', () {
      const result = AudioValidationResult(
        isValid: false,
        error: 'File not found',
      );

      expect(result.isValid, false);
      expect(result.error, 'File not found');
      expect(result.formattedFileSize, null);
    });

    test('should handle null file size', () {
      const result = AudioValidationResult(
        isValid: true,
        fileSize: null,
      );

      expect(result.formattedFileSize, null);
    });
  });
}
