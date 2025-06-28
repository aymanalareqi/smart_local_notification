import 'package:flutter/material.dart';
import 'package:smart_local_notification/smart_local_notification.dart';
import '../utils/notification_helper.dart';
import '../widgets/notification_card.dart';
import '../widgets/audio_status_widget.dart';
import 'audio_file_picker_screen.dart';
import 'scheduled_notifications_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAudioPlaying = false;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _setupAudioStatusListener();
  }

  Future<void> _checkPermissions() async {
    final granted = await NotificationHelper.arePermissionsGranted();
    setState(() {
      _permissionsGranted = granted;
    });
  }

  void _setupAudioStatusListener() {
    SmartLocalNotification.onNotificationEvent.listen((event) {
      if (mounted) {
        switch (event.type) {
          case SmartNotificationEventType.audioStarted:
            setState(() {
              _isAudioPlaying = true;
            });
            break;
          case SmartNotificationEventType.audioStopped:
          case SmartNotificationEventType.audioCompleted:
            setState(() {
              _isAudioPlaying = false;
            });
            break;
          case SmartNotificationEventType.error:
            _showErrorSnackBar(event.error ?? 'Unknown error occurred');
            break;
          default:
            break;
        }
      }
    });

    // Check initial audio status
    _updateAudioStatus();
  }

  Future<void> _updateAudioStatus() async {
    final isPlaying = await SmartLocalNotification.isAudioPlaying();
    if (mounted) {
      setState(() {
        _isAudioPlaying = isPlaying;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final granted = await NotificationHelper.requestPermissions();
    setState(() {
      _permissionsGranted = granted;
    });
    
    if (granted) {
      _showSuccessSnackBar('Permissions granted successfully');
    } else {
      _showErrorSnackBar('Some permissions were not granted');
    }
  }

  Future<void> _showNotification(SmartNotification notification) async {
    final success = await SmartLocalNotification.showNotification(notification);
    if (success) {
      _showSuccessSnackBar('Notification shown successfully');
    } else {
      _showErrorSnackBar('Failed to show notification');
    }
  }

  Future<void> _stopAudio() async {
    final success = await SmartLocalNotification.stopAudio();
    if (success) {
      _showSuccessSnackBar('Audio stopped');
    } else {
      _showErrorSnackBar('Failed to stop audio');
    }
  }

  Future<void> _clearAll() async {
    await NotificationHelper.stopAllAndClear();
    _showSuccessSnackBar('All notifications cleared and audio stopped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Smart Local Notification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Audio Status Widget
          AudioStatusWidget(
            isPlaying: _isAudioPlaying,
            onStop: _stopAudio,
            onClearAll: _clearAll,
          ),
          
          // Permissions Status
          if (!_permissionsGranted)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Permissions Required',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Some permissions are not granted. Please grant permissions to use all features.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _requestPermissions,
                    child: const Text('Grant Permissions'),
                  ),
                ],
              ),
            ),
          
          // Notification Examples
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Notification Examples',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                NotificationCard(
                  title: 'Asset Audio Notification',
                  description: 'Play notification with audio from app assets',
                  icon: Icons.music_note,
                  onTap: () => _showNotification(
                    NotificationHelper.createAssetAudioNotification(),
                  ),
                ),
                
                NotificationCard(
                  title: 'Looping Asset Audio',
                  description: 'Play looping audio from assets (like an alarm)',
                  icon: Icons.loop,
                  onTap: () => _showNotification(
                    NotificationHelper.createAssetAudioNotification(
                      title: 'Looping Audio',
                      body: 'This audio will loop until stopped',
                      loop: true,
                    ),
                  ),
                ),
                
                NotificationCard(
                  title: 'Alarm Style Notification',
                  description: 'High priority notification with alarm-like behavior',
                  icon: Icons.alarm,
                  onTap: () => _showNotification(
                    NotificationHelper.createAlarmNotification(),
                  ),
                ),
                
                NotificationCard(
                  title: 'Reminder Style Notification',
                  description: 'Gentle reminder with fade in/out audio',
                  icon: Icons.notifications_active,
                  onTap: () => _showNotification(
                    NotificationHelper.createReminderNotification(),
                  ),
                ),
                
                NotificationCard(
                  title: 'Custom Audio File',
                  description: 'Pick and play audio from device storage',
                  icon: Icons.folder_open,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AudioFilePickerScreen(),
                      ),
                    );
                  },
                ),
                
                NotificationCard(
                  title: 'Scheduled Notifications',
                  description: 'Schedule notifications for future times',
                  icon: Icons.schedule,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScheduledNotificationsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
