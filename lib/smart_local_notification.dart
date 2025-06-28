/// A Flutter plugin for native Android and iOS notifications with custom sound playback.
///
/// This plugin provides the ability to display silent notifications while playing
/// custom audio files simultaneously, supporting both asset-bundled and external
/// filesystem audio files.
library smart_local_notification;

export 'src/smart_local_notification.dart';
export 'src/models/notification_settings.dart';
export 'src/models/audio_settings.dart';
export 'src/models/smart_notification.dart';
export 'src/enums/audio_source_type.dart';
export 'src/enums/notification_priority.dart';
export 'src/utils/audio_file_manager.dart';
export 'src/utils/notification_audio_coordinator.dart';
export 'src/utils/background_audio_manager.dart';
