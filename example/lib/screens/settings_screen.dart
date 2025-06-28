import 'package:flutter/material.dart';
import 'package:smart_local_notification/smart_local_notification.dart';
import '../utils/notification_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _permissionsGranted = false;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final permissions = await NotificationHelper.arePermissionsGranted();
    final audioPlaying = await SmartLocalNotification.isAudioPlaying();
    
    setState(() {
      _permissionsGranted = permissions;
      _isAudioPlaying = audioPlaying;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final granted = await NotificationHelper.requestPermissions();
    setState(() {
      _permissionsGranted = granted;
    });
    
    _showSnackBar(
      granted ? 'Permissions granted' : 'Some permissions were denied',
      isError: !granted,
    );
  }

  Future<void> _stopAudio() async {
    final success = await SmartLocalNotification.stopAudio();
    if (success) {
      setState(() {
        _isAudioPlaying = false;
      });
      _showSnackBar('Audio stopped');
    } else {
      _showSnackBar('Failed to stop audio', isError: true);
    }
  }

  Future<void> _clearAllNotifications() async {
    await NotificationHelper.stopAllAndClear();
    setState(() {
      _isAudioPlaying = false;
    });
    _showSnackBar('All notifications cleared');
  }

  Future<void> _testBasicNotification() async {
    final notification = SmartNotification(
      id: NotificationHelper.getNextId(),
      title: 'Test Notification',
      body: 'This is a test notification without audio',
      notificationSettings: const NotificationSettings(
        priority: NotificationPriority.defaultPriority,
        silent: false, // Allow system sound for this test
      ),
    );

    final success = await SmartLocalNotification.showNotification(notification);
    _showSnackBar(
      success ? 'Test notification sent' : 'Failed to send notification',
      isError: !success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Section
          const Text(
            'Status',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _StatusRow(
                    label: 'Permissions',
                    value: _permissionsGranted ? 'Granted' : 'Not Granted',
                    isGood: _permissionsGranted,
                    action: !_permissionsGranted
                        ? TextButton(
                            onPressed: _requestPermissions,
                            child: const Text('Grant'),
                          )
                        : null,
                  ),
                  const Divider(),
                  _StatusRow(
                    label: 'Audio Playing',
                    value: _isAudioPlaying ? 'Yes' : 'No',
                    isGood: null, // Neutral
                    action: _isAudioPlaying
                        ? TextButton(
                            onPressed: _stopAudio,
                            child: const Text('Stop'),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Actions Section
          const Text(
            'Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _ActionCard(
            title: 'Test Basic Notification',
            description: 'Send a simple notification without custom audio',
            icon: Icons.notifications,
            onTap: _testBasicNotification,
          ),
          
          _ActionCard(
            title: 'Request Permissions',
            description: 'Request all necessary permissions for the app',
            icon: Icons.security,
            onTap: _requestPermissions,
          ),
          
          _ActionCard(
            title: 'Stop Audio',
            description: 'Stop any currently playing audio',
            icon: Icons.stop,
            onTap: _stopAudio,
            enabled: _isAudioPlaying,
          ),
          
          _ActionCard(
            title: 'Clear All Notifications',
            description: 'Remove all notifications and stop audio',
            icon: Icons.clear_all,
            onTap: _clearAllNotifications,
            color: Colors.red,
          ),
          
          const SizedBox(height: 32),
          
          // Information Section
          const Text(
            'Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Smart Local Notification',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This plugin provides silent notifications with custom audio playback. '
                    'It supports both asset-bundled and external filesystem audio files, '
                    'with background audio capabilities.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Features:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('• Silent notifications with custom audio'),
                  const Text('• Background audio playback'),
                  const Text('• Asset and file system audio support'),
                  const Text('• Cross-platform (Android & iOS)'),
                  const Text('• Audio fade in/out effects'),
                  const Text('• Notification scheduling'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool? isGood;
  final Widget? action;

  const _StatusRow({
    required this.label,
    required this.value,
    this.isGood,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    Color? valueColor;
    if (isGood == true) {
      valueColor = Colors.green;
    } else if (isGood == false) {
      valueColor = Colors.red;
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 8),
          action!,
        ],
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final Color? color;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: enabled 
                      ? cardColor.withOpacity(0.1) 
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: enabled ? cardColor : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: enabled ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: enabled ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
