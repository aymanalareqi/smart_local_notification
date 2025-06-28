import 'package:flutter/material.dart';

class AudioStatusWidget extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onStop;
  final VoidCallback onClearAll;

  const AudioStatusWidget({
    super.key,
    required this.isPlaying,
    required this.onStop,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPlaying ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaying ? Colors.green : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isPlaying ? Icons.volume_up : Icons.volume_off,
                color: isPlaying ? Colors.green : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPlaying ? 'Audio Playing' : 'No Audio Playing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPlaying ? Colors.green.shade700 : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      isPlaying 
                          ? 'Custom audio is currently playing in the background'
                          : 'No background audio is currently active',
                      style: TextStyle(
                        fontSize: 14,
                        color: isPlaying ? Colors.green.shade600 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isPlaying) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStop,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Audio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onClearAll,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onClearAll,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All Notifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
