/// Defines the type of audio source for custom sound playback.
enum AudioSourceType {
  /// Audio file is bundled in the app's assets folder.
  asset,
  
  /// Audio file is located in the device's file system.
  file,
  
  /// Audio file is accessible via a URL (for future implementation).
  url,
}

/// Extension methods for [AudioSourceType].
extension AudioSourceTypeExtension on AudioSourceType {
  /// Returns the string representation of the audio source type.
  String get value {
    switch (this) {
      case AudioSourceType.asset:
        return 'asset';
      case AudioSourceType.file:
        return 'file';
      case AudioSourceType.url:
        return 'url';
    }
  }

  /// Creates an [AudioSourceType] from a string value.
  static AudioSourceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'asset':
        return AudioSourceType.asset;
      case 'file':
        return AudioSourceType.file;
      case 'url':
        return AudioSourceType.url;
      default:
        throw ArgumentError('Invalid AudioSourceType: $value');
    }
  }
}
