import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smart_local_notification/smart_local_notification.dart';
import '../utils/notification_helper.dart';

class AudioFilePickerScreen extends StatefulWidget {
  const AudioFilePickerScreen({super.key});

  @override
  State<AudioFilePickerScreen> createState() => _AudioFilePickerScreenState();
}

class _AudioFilePickerScreenState extends State<AudioFilePickerScreen> {
  String? _selectedFilePath;
  AudioValidationResult? _validationResult;
  bool _isValidating = false;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _loopAudio = false;
  double _volume = 0.8;

  @override
  void initState() {
    super.initState();
    _titleController.text = 'Custom Audio File';
    _bodyController.text = 'Playing audio from selected file';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        setState(() {
          _selectedFilePath = filePath;
          _validationResult = null;
          _isValidating = true;
        });

        // Validate the selected file
        final validation = await AudioFileManager.validateAudioSettings(
          filePath,
          AudioSourceType.file,
        );

        setState(() {
          _validationResult = validation;
          _isValidating = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick audio file: $e');
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

  Future<void> _playNotification() async {
    if (_selectedFilePath == null || _validationResult?.isValid != true) {
      _showErrorSnackBar('Please select a valid audio file first');
      return;
    }

    final notification = NotificationHelper.createFileAudioNotification(
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
      body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
      filePath: _selectedFilePath!,
      loop: _loopAudio,
    );

    // Update volume
    final updatedNotification = notification.copyWith(
      audioSettings: notification.audioSettings?.copyWith(volume: _volume),
    );

    final success = await SmartLocalNotification.showNotification(updatedNotification);
    if (success) {
      _showSuccessSnackBar('Notification with custom audio file shown successfully');
      Navigator.pop(context);
    } else {
      _showErrorSnackBar('Failed to show notification');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Audio File'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Audio File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // File picker button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickAudioFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Pick Audio File'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Selected file info
            if (_selectedFilePath != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected File:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFilePath!.split('/').last,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Path: $_selectedFilePath',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      if (_isValidating) ...[
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Validating file...'),
                          ],
                        ),
                      ],
                      
                      if (_validationResult != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              _validationResult!.isValid ? Icons.check_circle : Icons.error,
                              color: _validationResult!.isValid ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _validationResult!.isValid ? 'Valid audio file' : 'Invalid audio file',
                              style: TextStyle(
                                color: _validationResult!.isValid ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        if (!_validationResult!.isValid && _validationResult!.error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${_validationResult!.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        
                        if (_validationResult!.isValid) ...[
                          const SizedBox(height: 8),
                          if (_validationResult!.fileExtension != null)
                            Text('Format: ${_validationResult!.fileExtension}'),
                          if (_validationResult!.formattedFileSize != null)
                            Text('Size: ${_validationResult!.formattedFileSize}'),
                          if (_validationResult!.mimeType != null)
                            Text('MIME Type: ${_validationResult!.mimeType}'),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Notification settings
            const Text(
              'Notification Settings',
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
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            // Audio settings
            SwitchListTile(
              title: const Text('Loop Audio'),
              subtitle: const Text('Audio will repeat until stopped'),
              value: _loopAudio,
              onChanged: (value) {
                setState(() {
                  _loopAudio = value;
                });
              },
            ),
            
            const SizedBox(height: 8),
            
            Text('Volume: ${(_volume * 100).round()}%'),
            Slider(
              value: _volume,
              onChanged: (value) {
                setState(() {
                  _volume = value;
                });
              },
              min: 0.0,
              max: 1.0,
              divisions: 10,
            ),
            
            const Spacer(),
            
            // Play button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _validationResult?.isValid == true ? _playNotification : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Show Notification'),
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
