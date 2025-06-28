# Audio Assets

This directory should contain sample audio files for testing the Smart Local Notification plugin.

## Required Audio Files

To fully test the example app, please add the following audio files to this directory:

1. **notification.mp3** - A short notification sound (2-5 seconds)
2. **alarm.mp3** - A longer alarm sound suitable for looping (5-10 seconds)
3. **reminder.mp3** - A gentle reminder sound (3-7 seconds)
4. **scheduled.mp3** - A sound for scheduled notifications (2-5 seconds)

## Audio File Requirements

- **Format**: MP3, WAV, AAC, or M4A
- **Quality**: 44.1kHz, 16-bit minimum
- **Size**: Keep files under 1MB for better performance
- **Length**: 
  - Notification sounds: 2-5 seconds
  - Alarm sounds: 5-10 seconds (will be looped)
  - Reminder sounds: 3-7 seconds

## Sample Audio Sources

You can find royalty-free audio files from:
- [Freesound.org](https://freesound.org)
- [Zapsplat](https://zapsplat.com)
- [Adobe Stock Audio](https://stock.adobe.com/audio)
- [YouTube Audio Library](https://studio.youtube.com)

## Testing Without Audio Files

If you don't have audio files available, the example app will still work but will show errors when trying to play audio. The notification functionality will still be demonstrated.

## File Naming Convention

Please use the exact filenames listed above for the best experience with the example app. The app is configured to look for these specific files.
