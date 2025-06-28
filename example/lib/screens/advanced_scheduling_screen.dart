import 'package:flutter/material.dart';
import 'package:smart_local_notification/smart_local_notification.dart';
import '../utils/notification_helper.dart';

class AdvancedSchedulingScreen extends StatefulWidget {
  const AdvancedSchedulingScreen({super.key});

  @override
  State<AdvancedSchedulingScreen> createState() =>
      _AdvancedSchedulingScreenState();
}

class _AdvancedSchedulingScreenState extends State<AdvancedSchedulingScreen> {
  DateTime _selectedTime = DateTime.now().add(const Duration(minutes: 1));
  ScheduleType _scheduleType = ScheduleType.oneTime;
  List<WeekDay> _selectedWeekDays = [];
  DateTime? _endDate;
  int? _maxOccurrences;
  int _customInterval = 1;
  String _customIntervalUnit = 'hours';

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = 'Advanced Scheduled Notification';
    _bodyController.text =
        'This notification uses advanced scheduling features';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
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
    SmartNotification notification;

    try {
      switch (_scheduleType) {
        case ScheduleType.oneTime:
          notification = NotificationHelper.createScheduledNotification(
            title:
                _titleController.text.isNotEmpty ? _titleController.text : null,
            body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
            scheduledTime: _selectedTime,
          );
          break;
        case ScheduleType.daily:
          notification = NotificationHelper.createDailyNotification(
            title:
                _titleController.text.isNotEmpty ? _titleController.text : null,
            body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
            time: _selectedTime,
            endDate: _endDate,
            maxOccurrences: _maxOccurrences,
          );
          break;
        case ScheduleType.weekly:
          notification = NotificationHelper.createWeeklyNotification(
            title:
                _titleController.text.isNotEmpty ? _titleController.text : null,
            body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
            time: _selectedTime,
            weekDays: _selectedWeekDays.isNotEmpty ? _selectedWeekDays : null,
            endDate: _endDate,
            maxOccurrences: _maxOccurrences,
          );
          break;
        case ScheduleType.custom:
          notification = NotificationHelper.createCustomIntervalNotification(
            title:
                _titleController.text.isNotEmpty ? _titleController.text : null,
            body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
            startTime: _selectedTime,
            interval: _customInterval,
            intervalUnit: _customIntervalUnit,
            endDate: _endDate,
            maxOccurrences: _maxOccurrences,
          );
          break;
        default:
          _showErrorSnackBar('Unsupported schedule type');
          return;
      }

      final success =
          await SmartLocalNotification.scheduleNotification(notification);
      if (mounted) {
        if (success) {
          _showSuccessSnackBar('Notification scheduled successfully');
          Navigator.pop(context);
        } else {
          _showErrorSnackBar('Failed to schedule notification');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedTime),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedTime = DateTime(
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Scheduling'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification content
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
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Schedule type selection
            const Text(
              'Schedule Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<ScheduleType>(
              value: _scheduleType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ScheduleType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.description),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _scheduleType = value!;
                  // Reset type-specific settings
                  _selectedWeekDays.clear();
                  _endDate = null;
                  _maxOccurrences = null;
                });
              },
            ),

            const SizedBox(height: 16),

            // Time selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _scheduleType == ScheduleType.oneTime
                          ? 'Scheduled Time:'
                          : 'Start Time:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(_formatDateTime(_selectedTime)),
                        ),
                        ElevatedButton(
                          onPressed: _selectDateTime,
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Type-specific options
            if (_scheduleType == ScheduleType.weekly) ...[
              const SizedBox(height: 16),
              const Text(
                'Days of Week',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: WeekDay.values.map((day) {
                  return FilterChip(
                    label: Text(day.shortName),
                    selected: _selectedWeekDays.contains(day),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedWeekDays.add(day);
                        } else {
                          _selectedWeekDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            if (_scheduleType == ScheduleType.custom) ...[
              const SizedBox(height: 16),
              const Text(
                'Repeat Interval',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: _customInterval.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Every',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _customInterval = int.tryParse(value) ?? 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _customIntervalUnit,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'minutes', child: Text('Minutes')),
                        DropdownMenuItem(value: 'hours', child: Text('Hours')),
                        DropdownMenuItem(value: 'days', child: Text('Days')),
                        DropdownMenuItem(value: 'weeks', child: Text('Weeks')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _customIntervalUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),

            // Schedule button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _scheduleNotification,
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
