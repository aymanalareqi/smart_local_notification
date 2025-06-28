import 'package:flutter/material.dart';
import 'package:smart_local_notification/smart_local_notification.dart';

class ScheduledNotificationsManagementScreen extends StatefulWidget {
  const ScheduledNotificationsManagementScreen({super.key});

  @override
  State<ScheduledNotificationsManagementScreen> createState() => _ScheduledNotificationsManagementScreenState();
}

class _ScheduledNotificationsManagementScreenState extends State<ScheduledNotificationsManagementScreen> {
  List<ScheduledNotificationInfo> _scheduledNotifications = [];
  bool _isLoading = true;
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    _loadScheduledNotifications();
  }

  Future<void> _loadScheduledNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query = _showActiveOnly 
          ? ScheduledNotificationQuery(isActive: true)
          : null;
      
      final notifications = await SmartLocalNotification.getScheduledNotifications(query);
      
      setState(() {
        _scheduledNotifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load scheduled notifications: $e');
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

  Future<void> _cancelNotification(ScheduledNotificationInfo notification) async {
    try {
      final success = await SmartLocalNotification.cancelScheduledNotification(
        notification.notification.id
      );
      
      if (success) {
        _showSuccessSnackBar('Notification cancelled');
        _loadScheduledNotifications();
      } else {
        _showErrorSnackBar('Failed to cancel notification');
      }
    } catch (e) {
      _showErrorSnackBar('Error cancelling notification: $e');
    }
  }

  Future<void> _cancelAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel All Notifications'),
        content: const Text('Are you sure you want to cancel all scheduled notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await SmartLocalNotification.cancelAllScheduledNotifications();
        
        if (success) {
          _showSuccessSnackBar('All notifications cancelled');
          _loadScheduledNotifications();
        } else {
          _showErrorSnackBar('Failed to cancel all notifications');
        }
      } catch (e) {
        _showErrorSnackBar('Error cancelling notifications: $e');
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getScheduleTypeDescription(NotificationSchedule? schedule) {
    if (schedule == null) return 'One-time';
    
    switch (schedule.scheduleType) {
      case ScheduleType.oneTime:
        return 'One-time';
      case ScheduleType.daily:
        return 'Daily';
      case ScheduleType.weekly:
        return 'Weekly';
      case ScheduleType.monthly:
        return 'Monthly';
      case ScheduleType.yearly:
        return 'Yearly';
      case ScheduleType.custom:
        return 'Custom (${schedule.interval} ${schedule.intervalUnit})';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Notifications'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScheduledNotifications,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'toggle_filter':
                  setState(() {
                    _showActiveOnly = !_showActiveOnly;
                  });
                  _loadScheduledNotifications();
                  break;
                case 'cancel_all':
                  _cancelAllNotifications();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_filter',
                child: Text(_showActiveOnly ? 'Show All' : 'Show Active Only'),
              ),
              const PopupMenuItem(
                value: 'cancel_all',
                child: Text('Cancel All'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scheduledNotifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showActiveOnly 
                            ? 'No active scheduled notifications'
                            : 'No scheduled notifications',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _scheduledNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = _scheduledNotifications[index];
                    final schedule = notification.notification.schedule;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.notification.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(_getScheduleTypeDescription(schedule)),
                                  backgroundColor: schedule?.scheduleType == ScheduleType.oneTime
                                      ? Colors.blue[100]
                                      : Colors.green[100],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              notification.notification.body,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Next: ${_formatDateTime(notification.nextOccurrence)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            
                            if (notification.triggerCount > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Triggered: ${notification.triggerCount} times',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            
                            const SizedBox(height: 12),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _cancelNotification(notification),
                                  icon: const Icon(Icons.cancel, size: 16),
                                  label: const Text('Cancel'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
