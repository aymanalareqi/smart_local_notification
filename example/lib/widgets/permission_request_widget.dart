import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/notification_helper.dart';
import '../screens/permissions_screen.dart';

class PermissionRequestWidget extends StatefulWidget {
  final VoidCallback? onPermissionsChanged;
  final bool showDetailedView;
  final bool compact;

  const PermissionRequestWidget({
    super.key,
    this.onPermissionsChanged,
    this.showDetailedView = false,
    this.compact = false,
  });

  @override
  State<PermissionRequestWidget> createState() => _PermissionRequestWidgetState();
}

class _PermissionRequestWidgetState extends State<PermissionRequestWidget> {
  bool _permissionsGranted = false;
  bool _isLoading = false;
  Map<String, PermissionStatus> _detailedStatus = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final granted = await NotificationHelper.arePermissionsGranted();
      
      if (widget.showDetailedView) {
        final detailed = await NotificationHelper.getDetailedPermissionStatus();
        setState(() {
          _detailedStatus = detailed;
        });
      }
      
      setState(() {
        _permissionsGranted = granted;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final granted = await NotificationHelper.requestPermissions();
      
      setState(() {
        _permissionsGranted = granted;
        _isLoading = false;
      });

      if (widget.onPermissionsChanged != null) {
        widget.onPermissionsChanged!();
      }

      if (granted) {
        _showSnackBar('All permissions granted successfully', Colors.green);
      } else {
        _showSnackBar('Some permissions were not granted', Colors.orange);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Failed to request permissions: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    }
  }

  void _openPermissionsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PermissionsScreen(),
      ),
    ).then((_) {
      _checkPermissions();
      if (widget.onPermissionsChanged != null) {
        widget.onPermissionsChanged!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionsGranted && !widget.showDetailedView) {
      return const SizedBox.shrink();
    }

    if (widget.compact) {
      return _buildCompactView();
    }

    return _buildFullView();
  }

  Widget _buildCompactView() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          _permissionsGranted ? Icons.check_circle : Icons.warning,
          color: _permissionsGranted ? Colors.green : Colors.orange,
        ),
        title: Text(
          _permissionsGranted ? 'Permissions Granted' : 'Permissions Required',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _permissionsGranted 
              ? 'All required permissions are granted'
              : 'Tap to manage permissions',
        ),
        trailing: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _isLoading ? null : _openPermissionsScreen,
      ),
    );
  }

  Widget _buildFullView() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _permissionsGranted 
            ? Colors.green.shade50 
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _permissionsGranted ? Colors.green : Colors.orange,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _permissionsGranted ? Icons.check_circle : Icons.warning,
            color: _permissionsGranted ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            _permissionsGranted ? 'All Permissions Granted' : 'Permissions Required',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _permissionsGranted ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _permissionsGranted
                ? 'All required permissions have been granted. You can use all app features.'
                : 'Some permissions are not granted. Please grant permissions to use all features.',
            textAlign: TextAlign.center,
          ),
          if (widget.showDetailedView && _detailedStatus.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._detailedStatus.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    entry.value.isGranted ? Icons.check : Icons.close,
                    size: 16,
                    color: entry.value.isGranted ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    entry.value.isGranted ? 'Granted' : 'Denied',
                    style: TextStyle(
                      fontSize: 12,
                      color: entry.value.isGranted ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 12),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_permissionsGranted)
                  ElevatedButton.icon(
                    onPressed: _requestPermissions,
                    icon: const Icon(Icons.security, size: 18),
                    label: const Text('Quick Grant'),
                  ),
                OutlinedButton.icon(
                  onPressed: _openPermissionsScreen,
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Manage'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
