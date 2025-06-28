import 'package:flutter/material.dart';
import 'package:smart_local_notification/smart_local_notification.dart';
import '../utils/notification_helper.dart';

class ScheduledNotificationsScreen extends StatefulWidget {
  const ScheduledNotificationsScreen({super.key});

  @override
  State<ScheduledNotificationsScreen> createState() => _ScheduledNotificationsScreenState();
}

class _ScheduledNotificationsScreenState extends State<ScheduledNotificationsScreen> {
  DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = 'Scheduled Notification';
    _bodyController.text = 'This notification was scheduled for a specific time';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
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

  Future<void> _scheduleNotification() async {
    if (_selectedDateTime.isBefore(DateTime.now())) {
      _showErrorSnackBar('Please select a future date and time');
      return;
    }

    final notification = NotificationHelper.createScheduledNotification(
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
      body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
      scheduledTime: _selectedDateTime,
    );

    final success = await SmartLocalNotification.showNotification(notification);
    if (success) {
      _showSuccessSnackBar('Notification scheduled successfully');
      Navigator.pop(context);
    } else {
      _showErrorSnackBar('Failed to schedule notification');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isInPast = _selectedDateTime.isBefore(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Notifications'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule a Notification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Date and time selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scheduled Time:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatDateTime(_selectedDateTime),
                            style: TextStyle(
                              fontSize: 16,
                              color: isInPast ? Colors.red : Colors.black,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _selectDateTime,
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    if (isInPast) ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Selected time is in the past',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Notification content
            const Text(
              'Notification Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Notification Body',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Quick schedule options
            const Text(
              'Quick Schedule Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickScheduleChip(
                  label: '1 minute',
                  onTap: () {
                    setState(() {
                      _selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
                    });
                  },
                ),
                _QuickScheduleChip(
                  label: '5 minutes',
                  onTap: () {
                    setState(() {
                      _selectedDateTime = DateTime.now().add(const Duration(minutes: 5));
                    });
                  },
                ),
                _QuickScheduleChip(
                  label: '10 minutes',
                  onTap: () {
                    setState(() {
                      _selectedDateTime = DateTime.now().add(const Duration(minutes: 10));
                    });
                  },
                ),
                _QuickScheduleChip(
                  label: '1 hour',
                  onTap: () {
                    setState(() {
                      _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
                    });
                  },
                ),
              ],
            ),
            
            const Spacer(),
            
            // Schedule button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: !isInPast ? _scheduleNotification : null,
                icon: const Icon(Icons.schedule),
                label: const Text('Schedule Notification'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickScheduleChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickScheduleChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}
