import 'dart:async';
import '../models/audio_settings.dart';
import '../smart_local_notification.dart';

/// Utility class for managing background audio playback.
/// 
/// This class provides methods for ensuring audio continues playing when the app
/// is backgrounded or closed, with proper lifecycle management and platform-specific
/// optimizations.
class BackgroundAudioManager {
  static final BackgroundAudioManager _instance = BackgroundAudioManager._internal();
  factory BackgroundAudioManager() => _instance;
  BackgroundAudioManager._internal();

  Timer? _keepAliveTimer;
  bool _isBackgroundAudioActive = false;
  AudioSettings? _currentAudioSettings;
  StreamSubscription<SmartNotificationEvent>? _eventSubscription;

  /// Initialize the background audio manager.
  /// 
  /// This should be called during app initialization to set up proper
  /// background audio handling.
  void initialize() {
    _setupEventListeners();
  }

  /// Sets up event listeners for audio lifecycle management.
  void _setupEventListeners() {
    _eventSubscription?.cancel();
    _eventSubscription = SmartLocalNotification.onNotificationEvent.listen((event) {
      switch (event.type) {
        case SmartNotificationEventType.audioStarted:
          _onAudioStarted();
          break;
        case SmartNotificationEventType.audioStopped:
        case SmartNotificationEventType.audioCompleted:
          _onAudioStopped();
          break;
        default:
          break;
      }
    });
  }

  /// Called when audio playback starts.
  void _onAudioStarted() {
    _isBackgroundAudioActive = true;
    _startKeepAliveTimer();
  }

  /// Called when audio playback stops.
  void _onAudioStopped() {
    _isBackgroundAudioActive = false;
    _stopKeepAliveTimer();
    _currentAudioSettings = null;
  }

  /// Starts a keep-alive timer to maintain background audio session.
  /// 
  /// This timer helps prevent the system from terminating audio playback
  /// when the app is backgrounded.
  void _startKeepAliveTimer() {
    _stopKeepAliveTimer();
    
    // Send periodic keep-alive signals to maintain audio session
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isBackgroundAudioActive) {
        _sendKeepAliveSignal();
      } else {
        timer.cancel();
      }
    });
  }

  /// Stops the keep-alive timer.
  void _stopKeepAliveTimer() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  /// Sends a keep-alive signal to maintain background audio session.
  void _sendKeepAliveSignal() {
    // This could be implemented to send a signal to the native platforms
    // to ensure the audio session remains active
    // For now, we'll just check if audio is still playing
    SmartLocalNotification.isAudioPlaying().then((isPlaying) {
      if (!isPlaying && _isBackgroundAudioActive) {
        _onAudioStopped();
      }
    });
  }

  /// Configures the app for optimal background audio playback.
  /// 
  /// [audioSettings] - The audio settings to optimize for background playback
  /// 
  /// Returns optimized [AudioSettings] for background operation.
  static AudioSettings optimizeForBackground(AudioSettings audioSettings) {
    return audioSettings.copyWith(
      // Ensure background playback is enabled
      playInBackground: true,
      
      // Use appropriate audio session category for background playback
      audioSessionCategory: audioSettings.audioSessionCategory ?? 'playback',
      
      // Duck other audio to be respectful of other apps
      duckOthers: true,
      
      // Don't interrupt other audio unless explicitly requested
      interruptOthers: audioSettings.interruptOthers,
      
      // Respect silent mode based on user preference
      respectSilentMode: audioSettings.respectSilentMode,
    );
  }

  /// Checks if background audio is currently active.
  bool get isBackgroundAudioActive => _isBackgroundAudioActive;

  /// Gets the current audio settings if audio is playing.
  AudioSettings? get currentAudioSettings => _currentAudioSettings;

  /// Prepares the app for entering background mode with active audio.
  /// 
  /// This method should be called when the app is about to enter background
  /// mode and audio is playing.
  Future<void> prepareForBackground() async {
    if (_isBackgroundAudioActive) {
      // Ensure audio session is properly configured for background
      await _configureBackgroundAudioSession();
      
      // Start more frequent keep-alive signals
      _startAggressiveKeepAlive();
    }
  }

  /// Handles app returning to foreground with active audio.
  /// 
  /// This method should be called when the app returns to foreground
  /// and audio might be playing.
  Future<void> handleForegroundReturn() async {
    if (_isBackgroundAudioActive) {
      // Verify audio is still playing
      final isPlaying = await SmartLocalNotification.isAudioPlaying();
      if (!isPlaying) {
        _onAudioStopped();
      } else {
        // Resume normal keep-alive frequency
        _startKeepAliveTimer();
      }
    }
  }

  /// Configures the audio session for background operation.
  Future<void> _configureBackgroundAudioSession() async {
    // This would typically call platform-specific methods
    // to configure the audio session for background operation
    // Implementation would be handled by the native platforms
  }

  /// Starts aggressive keep-alive for background operation.
  void _startAggressiveKeepAlive() {
    _stopKeepAliveTimer();
    
    // More frequent keep-alive signals when in background
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isBackgroundAudioActive) {
        _sendKeepAliveSignal();
      } else {
        timer.cancel();
      }
    });
  }

  /// Handles app termination with active audio.
  /// 
  /// This method attempts to ensure audio continues playing even if
  /// the app is terminated, where supported by the platform.
  Future<void> handleAppTermination() async {
    if (_isBackgroundAudioActive) {
      // On platforms that support it, try to maintain audio playback
      // even after app termination
      await _setupPersistentAudioSession();
    }
  }

  /// Sets up persistent audio session for post-termination playback.
  Future<void> _setupPersistentAudioSession() async {
    // This would be implemented by platform-specific code
    // Android: Use foreground service
    // iOS: Use background audio capability
  }

  /// Gets recommendations for background audio configuration.
  /// 
  /// [audioSettings] - The audio settings to analyze
  /// 
  /// Returns a list of recommendations for optimal background operation.
  static List<String> getBackgroundAudioRecommendations(AudioSettings audioSettings) {
    final recommendations = <String>[];

    if (!audioSettings.playInBackground) {
      recommendations.add('Enable playInBackground for audio to continue when app is backgrounded');
    }

    if (audioSettings.respectSilentMode && audioSettings.loop) {
      recommendations.add('Consider disabling respectSilentMode for looping background audio');
    }

    if (audioSettings.interruptOthers) {
      recommendations.add('Consider disabling interruptOthers to be respectful of other apps');
    }

    if (!audioSettings.duckOthers) {
      recommendations.add('Consider enabling duckOthers to lower other audio during playback');
    }

    if (audioSettings.audioSessionCategory == null) {
      recommendations.add('Set audioSessionCategory to "playback" for optimal background audio');
    }

    return recommendations;
  }

  /// Estimates battery impact of background audio playback.
  /// 
  /// [audioSettings] - The audio settings to analyze
  /// [estimatedDuration] - Estimated playback duration
  /// 
  /// Returns a [BatteryImpactEstimate] with impact analysis.
  static BatteryImpactEstimate estimateBatteryImpact(
    AudioSettings audioSettings,
    Duration estimatedDuration,
  ) {
    var impact = BatteryImpactLevel.low;
    final factors = <String>[];

    // Looping audio has higher impact
    if (audioSettings.loop) {
      impact = BatteryImpactLevel.high;
      factors.add('Looping audio increases battery usage');
    }

    // Long duration increases impact
    if (estimatedDuration.inMinutes > 30) {
      impact = BatteryImpactLevel.values[
        (impact.index + 1).clamp(0, BatteryImpactLevel.values.length - 1)
      ];
      factors.add('Long playback duration increases battery usage');
    }

    // Background playback increases impact
    if (audioSettings.playInBackground) {
      impact = BatteryImpactLevel.values[
        (impact.index + 1).clamp(0, BatteryImpactLevel.values.length - 1)
      ];
      factors.add('Background playback increases battery usage');
    }

    return BatteryImpactEstimate(
      level: impact,
      factors: factors,
      estimatedDuration: estimatedDuration,
    );
  }

  /// Disposes of the background audio manager.
  void dispose() {
    _stopKeepAliveTimer();
    _eventSubscription?.cancel();
    _isBackgroundAudioActive = false;
    _currentAudioSettings = null;
  }
}

/// Represents the level of battery impact.
enum BatteryImpactLevel {
  low,
  medium,
  high,
  veryHigh,
}

/// Represents an estimate of battery impact for background audio.
class BatteryImpactEstimate {
  /// The estimated impact level.
  final BatteryImpactLevel level;

  /// Factors contributing to the impact.
  final List<String> factors;

  /// The estimated duration of playback.
  final Duration estimatedDuration;

  /// Creates a new [BatteryImpactEstimate].
  const BatteryImpactEstimate({
    required this.level,
    required this.factors,
    required this.estimatedDuration,
  });

  /// Gets a human-readable description of the impact level.
  String get description {
    switch (level) {
      case BatteryImpactLevel.low:
        return 'Low battery impact - minimal effect on battery life';
      case BatteryImpactLevel.medium:
        return 'Medium battery impact - moderate effect on battery life';
      case BatteryImpactLevel.high:
        return 'High battery impact - significant effect on battery life';
      case BatteryImpactLevel.veryHigh:
        return 'Very high battery impact - substantial effect on battery life';
    }
  }

  @override
  String toString() {
    return 'BatteryImpactEstimate('
        'level: $level, '
        'factors: $factors, '
        'estimatedDuration: $estimatedDuration'
        ')';
  }
}
