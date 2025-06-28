import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_local_notification/smart_local_notification.dart';
import '../utils/notification_helper.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  Map<String, PermissionStatus> _permissionStatuses = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final statuses = <String, PermissionStatus>{};
      
      // Check individual permissions
      statuses['Notifications'] = await Permission.notification.status;
      statuses['Audio'] = await Permission.audio.status;
      statuses['Storage'] = await Permission.storage.status;
      statuses['Microphone'] = await Permission.microphone.status;
      
      // Check plugin-specific permissions
      final pluginPermissions = await SmartLocalNotification.arePermissionsGranted();
      statuses['Plugin Permissions'] = pluginPermissions 
          ? PermissionStatus.granted 
          : PermissionStatus.denied;

      setState(() {
        _permissionStatuses = statuses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to check permissions: $e');
    }
  }

  Future<void> _requestPermission(String permissionName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      PermissionStatus status;
      
      switch (permissionName) {
        case 'Notifications':
          status = await Permission.notification.request();
          break;
        case 'Audio':
          status = await Permission.audio.request();
          break;
        case 'Storage':
          status = await Permission.storage.request();
          break;
        case 'Microphone':
          status = await Permission.microphone.request();
          break;
        case 'Plugin Permissions':
          final granted = await SmartLocalNotification.requestPermissions();
          status = granted ? PermissionStatus.granted : PermissionStatus.denied;
          break;
        default:
          status = PermissionStatus.denied;
      }

      setState(() {
        _permissionStatuses[permissionName] = status;
        _isLoading = false;
      });

      if (status.isGranted) {
        _showSuccessSnackBar('$permissionName permission granted');
      } else if (status.isPermanentlyDenied) {
        _showPermanentlyDeniedDialog(permissionName);
      } else {
        _showErrorSnackBar('$permissionName permission denied');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to request $permissionName permission: $e');
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final granted = await NotificationHelper.requestPermissions();
      
      if (granted) {
        _showSuccessSnackBar('All permissions granted successfully');
      } else {
        _showErrorSnackBar('Some permissions were not granted');
      }
      
      await _checkAllPermissions();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to request permissions: $e');
    }
  }

  void _showPermanentlyDeniedDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          '$permissionName permission has been permanently denied. '
          'Please enable it in the app settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
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

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
        return Colors.grey;
      case PermissionStatus.limited:
        return Colors.yellow;
      case PermissionStatus.provisional:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return Icons.check_circle;
      case PermissionStatus.denied:
        return Icons.cancel;
      case PermissionStatus.permanentlyDenied:
        return Icons.block;
      case PermissionStatus.restricted:
        return Icons.warning;
      case PermissionStatus.limited:
        return Icons.info;
      case PermissionStatus.provisional:
        return Icons.help;
    }
  }

  String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
  }

  String _getPermissionDescription(String permissionName) {
    switch (permissionName) {
      case 'Notifications':
        return 'Required to show local notifications';
      case 'Audio':
        return 'Required to play notification sounds';
      case 'Storage':
        return 'Required to access audio files from device storage';
      case 'Microphone':
        return 'May be required for audio recording features';
      case 'Plugin Permissions':
        return 'Smart Local Notification plugin permissions';
      default:
        return 'Permission required for app functionality';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAllPermissions,
            tooltip: 'Refresh permissions',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Permissions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The following permissions are required for the Smart Local Notification plugin to work properly:',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _requestAllPermissions,
                          icon: const Icon(Icons.security),
                          label: const Text('Request All Permissions'),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Permissions List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _permissionStatuses.length,
                    itemBuilder: (context, index) {
                      final entry = _permissionStatuses.entries.elementAt(index);
                      final permissionName = entry.key;
                      final status = entry.value;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            _getStatusIcon(status),
                            color: _getStatusColor(status),
                            size: 32,
                          ),
                          title: Text(
                            permissionName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getPermissionDescription(permissionName)),
                              const SizedBox(height: 4),
                              Text(
                                'Status: ${_getStatusText(status)}',
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: status.isGranted
                              ? null
                              : ElevatedButton(
                                  onPressed: () => _requestPermission(permissionName),
                                  child: const Text('Request'),
                                ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
