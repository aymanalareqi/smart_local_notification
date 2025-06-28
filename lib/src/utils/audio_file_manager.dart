import 'dart:io';
import 'package:flutter/services.dart';
import '../enums/audio_source_type.dart';

/// Utility class for managing audio file paths and validation.
class AudioFileManager {
  /// Validates if an audio file exists and is accessible.
  /// 
  /// [audioPath] - The path to the audio file
  /// [sourceType] - The type of audio source (asset, file, url)
  /// 
  /// Returns `true` if the file exists and is accessible, `false` otherwise.
  static Future<bool> validateAudioFile(String audioPath, AudioSourceType sourceType) async {
    try {
      switch (sourceType) {
        case AudioSourceType.asset:
          return await _validateAssetFile(audioPath);
        case AudioSourceType.file:
          return await _validateFileSystemFile(audioPath);
        case AudioSourceType.url:
          return _validateUrl(audioPath);
      }
    } catch (e) {
      return false;
    }
  }

  /// Validates an asset file.
  static Future<bool> _validateAssetFile(String assetPath) async {
    try {
      // Remove 'assets/' prefix if present for consistency
      final normalizedPath = assetPath.startsWith('assets/') 
          ? assetPath.substring(7) 
          : assetPath;
      
      // Try to load the asset to verify it exists
      await rootBundle.load('assets/$normalizedPath');
      return true;
    } catch (e) {
      // If loading fails, the asset doesn't exist
      return false;
    }
  }

  /// Validates a file system file.
  static Future<bool> _validateFileSystemFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Validates a URL.
  static bool _validateUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Normalizes an audio file path based on the source type.
  /// 
  /// [audioPath] - The original audio path
  /// [sourceType] - The type of audio source
  /// 
  /// Returns the normalized path that can be used by platform implementations.
  static String normalizeAudioPath(String audioPath, AudioSourceType sourceType) {
    switch (sourceType) {
      case AudioSourceType.asset:
        // Ensure assets have the correct prefix for platform implementations
        if (audioPath.startsWith('assets/')) {
          return audioPath;
        } else {
          return 'assets/$audioPath';
        }
      case AudioSourceType.file:
      case AudioSourceType.url:
        // File and URL paths should be used as-is
        return audioPath;
    }
  }

  /// Gets the file extension from an audio path.
  /// 
  /// [audioPath] - The audio file path
  /// 
  /// Returns the file extension (without the dot) or null if no extension is found.
  static String? getFileExtension(String audioPath) {
    final lastDotIndex = audioPath.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == audioPath.length - 1) {
      return null;
    }
    return audioPath.substring(lastDotIndex + 1).toLowerCase();
  }

  /// Checks if the file extension is supported for audio playback.
  /// 
  /// [extension] - The file extension to check
  /// 
  /// Returns `true` if the extension is supported, `false` otherwise.
  static bool isSupportedAudioFormat(String? extension) {
    if (extension == null) return false;
    
    const supportedFormats = {
      // Common audio formats supported by both Android and iOS
      'mp3',
      'wav',
      'aac',
      'm4a',
      'ogg', // Android only, but we'll include it
      'flac', // Android only, but we'll include it
      'mp4', // For audio in MP4 container
    };
    
    return supportedFormats.contains(extension.toLowerCase());
  }

  /// Gets the MIME type for an audio file based on its extension.
  /// 
  /// [extension] - The file extension
  /// 
  /// Returns the MIME type or null if the extension is not recognized.
  static String? getMimeType(String? extension) {
    if (extension == null) return null;
    
    const mimeTypes = {
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'aac': 'audio/aac',
      'm4a': 'audio/mp4',
      'ogg': 'audio/ogg',
      'flac': 'audio/flac',
      'mp4': 'audio/mp4',
    };
    
    return mimeTypes[extension.toLowerCase()];
  }

  /// Estimates the file size of an audio file (for file system files only).
  /// 
  /// [filePath] - The path to the file
  /// 
  /// Returns the file size in bytes or null if the file doesn't exist or can't be accessed.
  static Future<int?> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Formats file size in a human-readable format.
  /// 
  /// [bytes] - The file size in bytes
  /// 
  /// Returns a formatted string (e.g., "1.5 MB", "256 KB").
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Validates audio settings and provides detailed error information.
  /// 
  /// [audioPath] - The audio file path
  /// [sourceType] - The type of audio source
  /// 
  /// Returns a [AudioValidationResult] with validation details.
  static Future<AudioValidationResult> validateAudioSettings(
    String audioPath, 
    AudioSourceType sourceType
  ) async {
    // Check if path is empty
    if (audioPath.isEmpty) {
      return AudioValidationResult(
        isValid: false,
        error: 'Audio path cannot be empty',
      );
    }

    // Check file extension
    final extension = getFileExtension(audioPath);
    if (!isSupportedAudioFormat(extension)) {
      return AudioValidationResult(
        isValid: false,
        error: 'Unsupported audio format: ${extension ?? 'unknown'}',
        supportedFormats: ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'],
      );
    }

    // Validate file existence
    final exists = await validateAudioFile(audioPath, sourceType);
    if (!exists) {
      return AudioValidationResult(
        isValid: false,
        error: 'Audio file not found or inaccessible: $audioPath',
      );
    }

    // Get additional file information for file system files
    int? fileSize;
    if (sourceType == AudioSourceType.file) {
      fileSize = await getFileSize(audioPath);
    }

    return AudioValidationResult(
      isValid: true,
      normalizedPath: normalizeAudioPath(audioPath, sourceType),
      fileExtension: extension,
      mimeType: getMimeType(extension),
      fileSize: fileSize,
    );
  }
}

/// Result of audio file validation.
class AudioValidationResult {
  /// Whether the audio file is valid.
  final bool isValid;

  /// Error message if validation failed.
  final String? error;

  /// The normalized audio path.
  final String? normalizedPath;

  /// The file extension.
  final String? fileExtension;

  /// The MIME type of the audio file.
  final String? mimeType;

  /// The file size in bytes (for file system files).
  final int? fileSize;

  /// List of supported audio formats.
  final List<String>? supportedFormats;

  /// Creates a new [AudioValidationResult].
  const AudioValidationResult({
    required this.isValid,
    this.error,
    this.normalizedPath,
    this.fileExtension,
    this.mimeType,
    this.fileSize,
    this.supportedFormats,
  });

  /// Returns a human-readable file size string.
  String? get formattedFileSize {
    if (fileSize == null) return null;
    return AudioFileManager.formatFileSize(fileSize!);
  }

  @override
  String toString() {
    return 'AudioValidationResult('
        'isValid: $isValid, '
        'error: $error, '
        'normalizedPath: $normalizedPath, '
        'fileExtension: $fileExtension, '
        'mimeType: $mimeType, '
        'fileSize: $fileSize'
        ')';
  }
}
