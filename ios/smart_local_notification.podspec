Pod::Spec.new do |s|
  s.name             = 'smart_local_notification'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin for native Android and iOS notifications with custom sound playback.'
  s.description      = <<-DESC
A Flutter plugin that provides the ability to display silent notifications while playing
custom audio files simultaneously, supporting both asset-bundled and external filesystem audio files.
                       DESC
  s.homepage         = 'https://github.com/your-org/smart_local_notification'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Organization' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Add frameworks for audio and notifications
  s.frameworks = 'AVFoundation', 'UserNotifications', 'AudioToolbox'
end
