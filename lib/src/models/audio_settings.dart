import '../enums/audio_source_type.dart';
import '../utils/audio_file_manager.dart';

/// Configuration settings for custom audio playback.
class AudioSettings {
  /// The path to the audio file.
  /// For assets: 'assets/audio/sound.mp3'
  /// For files: '/storage/emulated/0/audio/sound.mp3'
  /// For URLs: 'https://example.com/audio/sound.mp3'
  final String audioPath;

  /// The type of audio source (asset, file, or URL).
  final AudioSourceType sourceType;

  /// Whether to loop the audio playback.
  final bool loop;

  /// The volume level for audio playback (0.0 to 1.0).
  final double volume;

  /// Duration for fading in the audio at the start.
  final Duration? fadeInDuration;

  /// Duration for fading out the audio at the end.
  final Duration? fadeOutDuration;

  /// Whether to respect the device's silent mode.
  /// If true, audio won't play when device is in silent mode.
  final bool respectSilentMode;

  /// Whether to duck other audio when this audio plays.
  /// If true, other audio will be lowered in volume.
  final bool duckOthers;

  /// Whether to interrupt other audio when this audio plays.
  /// If true, other audio will be paused.
  final bool interruptOthers;

  /// The audio session category (iOS only).
  /// Common values: 'playback', 'ambient', 'soloAmbient'
  final String? audioSessionCategory;

  /// Whether to play audio even when the app is in background.
  final bool playInBackground;

  /// Creates a new [AudioSettings] instance.
  const AudioSettings({
    required this.audioPath,
    required this.sourceType,
    this.loop = false,
    this.volume = 1.0,
    this.fadeInDuration,
    this.fadeOutDuration,
    this.respectSilentMode = false,
    this.duckOthers = true,
    this.interruptOthers = false,
    this.audioSessionCategory,
    this.playInBackground = true,
  }) : assert(volume >= 0.0 && volume <= 1.0,
            'Volume must be between 0.0 and 1.0');

  /// Creates a copy of this [AudioSettings] with the given fields replaced.
  AudioSettings copyWith({
    String? audioPath,
    AudioSourceType? sourceType,
    bool? loop,
    double? volume,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
    bool? respectSilentMode,
    bool? duckOthers,
    bool? interruptOthers,
    String? audioSessionCategory,
    bool? playInBackground,
  }) {
    return AudioSettings(
      audioPath: audioPath ?? this.audioPath,
      sourceType: sourceType ?? this.sourceType,
      loop: loop ?? this.loop,
      volume: volume ?? this.volume,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
      respectSilentMode: respectSilentMode ?? this.respectSilentMode,
      duckOthers: duckOthers ?? this.duckOthers,
      interruptOthers: interruptOthers ?? this.interruptOthers,
      audioSessionCategory: audioSessionCategory ?? this.audioSessionCategory,
      playInBackground: playInBackground ?? this.playInBackground,
    );
  }

  /// Converts this [AudioSettings] to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'audioPath': audioPath,
      'sourceType': sourceType.value,
      'loop': loop,
      'volume': volume,
      'fadeInDuration': fadeInDuration?.inMilliseconds,
      'fadeOutDuration': fadeOutDuration?.inMilliseconds,
      'respectSilentMode': respectSilentMode,
      'duckOthers': duckOthers,
      'interruptOthers': interruptOthers,
      'audioSessionCategory': audioSessionCategory,
      'playInBackground': playInBackground,
    };
  }

  /// Creates an [AudioSettings] from a map.
  factory AudioSettings.fromMap(Map<String, dynamic> map) {
    return AudioSettings(
      audioPath: map['audioPath'] ?? '',
      sourceType:
          AudioSourceTypeExtension.fromString(map['sourceType'] ?? 'asset'),
      loop: map['loop'] ?? false,
      volume: (map['volume'] ?? 1.0).toDouble(),
      fadeInDuration: map['fadeInDuration'] != null
          ? Duration(milliseconds: map['fadeInDuration'])
          : null,
      fadeOutDuration: map['fadeOutDuration'] != null
          ? Duration(milliseconds: map['fadeOutDuration'])
          : null,
      respectSilentMode: map['respectSilentMode'] ?? false,
      duckOthers: map['duckOthers'] ?? true,
      interruptOthers: map['interruptOthers'] ?? false,
      audioSessionCategory: map['audioSessionCategory'],
      playInBackground: map['playInBackground'] ?? true,
    );
  }

  @override
  String toString() {
    return 'AudioSettings('
        'audioPath: $audioPath, '
        'sourceType: $sourceType, '
        'loop: $loop, '
        'volume: $volume, '
        'fadeInDuration: $fadeInDuration, '
        'fadeOutDuration: $fadeOutDuration, '
        'respectSilentMode: $respectSilentMode, '
        'duckOthers: $duckOthers, '
        'interruptOthers: $interruptOthers, '
        'audioSessionCategory: $audioSessionCategory, '
        'playInBackground: $playInBackground'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioSettings &&
        other.audioPath == audioPath &&
        other.sourceType == sourceType &&
        other.loop == loop &&
        other.volume == volume &&
        other.fadeInDuration == fadeInDuration &&
        other.fadeOutDuration == fadeOutDuration &&
        other.respectSilentMode == respectSilentMode &&
        other.duckOthers == duckOthers &&
        other.interruptOthers == interruptOthers &&
        other.audioSessionCategory == audioSessionCategory &&
        other.playInBackground == playInBackground;
  }

  @override
  int get hashCode {
    return Object.hash(
      audioPath,
      sourceType,
      loop,
      volume,
      fadeInDuration,
      fadeOutDuration,
      respectSilentMode,
      duckOthers,
      interruptOthers,
      audioSessionCategory,
      playInBackground,
    );
  }

  /// Validates the audio settings and returns detailed validation information.
  ///
  /// Returns a [AudioValidationResult] with validation details.
  Future<AudioValidationResult> validate() async {
    return AudioFileManager.validateAudioSettings(audioPath, sourceType);
  }

  /// Gets the normalized audio path for platform implementations.
  String get normalizedPath {
    return AudioFileManager.normalizeAudioPath(audioPath, sourceType);
  }

  /// Gets the file extension of the audio file.
  String? get fileExtension {
    return AudioFileManager.getFileExtension(audioPath);
  }

  /// Checks if the audio format is supported.
  bool get isSupportedFormat {
    return AudioFileManager.isSupportedAudioFormat(fileExtension);
  }
}
