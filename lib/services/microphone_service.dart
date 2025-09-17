// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'permission_service.dart';

class MicrophoneService {
  static FlutterSoundRecorder? _recorder;
  static bool _isRecording = false;
  static String? _recordingPath;

  static Future<String?> initializeRecorder() async {
    try {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      return null; // Success
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
      return 'Failed to initialize recorder: ${e.toString()}';
    }
  }

  static Future<String?> startRecording() async {
    try {
      // Initialize recorder if not already initialized
      if (_recorder == null) {
        final error = await initializeRecorder();
        if (error != null) {
          return error;
        }
      }

      // Check microphone permission first
      bool hasPermission = await PermissionService.checkMicrophonePermission();
      if (!hasPermission) {
        hasPermission = await PermissionService.requestMicrophonePermission();
        if (!hasPermission) {
          return 'Microphone permission is required to record audio';
        }
      }

      // Check if already recording
      if (_isRecording) {
        return 'Already recording';
      }

      // Get the temporary directory to save the recording
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      _recordingPath = path.join(tempDir.path, fileName);

      // Start recording
      await _recorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacADTS,
      );
      _isRecording = true;

      return null; // Success
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return 'Failed to start recording: ${e.toString()}';
    }
  }

  static Future<String?> stopRecording() async {
    try {
      if (!_isRecording || _recorder == null) {
        return 'Not currently recording';
      }

      // Stop recording
      await _recorder!.stopRecorder();
      _isRecording = false;

      return _recordingPath; // Return the recording path
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  static Future<String?> pauseRecording() async {
    try {
      if (!_isRecording || _recorder == null) {
        return 'Not currently recording';
      }

      await _recorder!.pauseRecorder();
      return null; // Success
    } catch (e) {
      debugPrint('Error pausing recording: $e');
      return 'Failed to pause recording: ${e.toString()}';
    }
  }

  static Future<String?> resumeRecording() async {
    try {
      if (_recorder == null) {
        return 'Recorder not initialized';
      }

      await _recorder!.resumeRecorder();
      return null; // Success
    } catch (e) {
      debugPrint('Error resuming recording: $e');
      return 'Failed to resume recording: ${e.toString()}';
    }
  }

  static Future<bool> isRecordingActive() async {
    try {
      if (_recorder == null) return false;
      return _recorder!.isRecording;
    } catch (e) {
      debugPrint('Error checking recording status: $e');
      return false;
    }
  }

  static Future<bool> isPausedRecording() async {
    try {
      if (_recorder == null) return false;
      return _recorder!.isPaused;
    } catch (e) {
      debugPrint('Error checking pause status: $e');
      return false;
    }
  }

  static bool get isRecording => _isRecording;
  static String? get currentRecordingPath => _recordingPath;

  static Future<void> dispose() async {
    try {
      if (_recorder != null) {
        if (_isRecording) {
          await _recorder!.stopRecorder();
          _isRecording = false;
        }
        await _recorder!.closeRecorder();
        _recorder = null;
      }
    } catch (e) {
      debugPrint('Error disposing audio recorder: $e');
    }
  }

  static Future<Duration?> getRecordingDuration() async {
    try {
      // This is a simple implementation
      // You might want to use a more sophisticated method to get accurate duration
      if (_recordingPath != null && File(_recordingPath!).existsSync()) {
        // For now, we'll return a placeholder duration
        // In a real app, you might use a media info library to get the actual duration
        return const Duration(seconds: 0);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting recording duration: $e');
      return null;
    }
  }

  static Future<int?> getRecordingFileSize() async {
    try {
      if (_recordingPath != null && File(_recordingPath!).existsSync()) {
        final file = File(_recordingPath!);
        final size = await file.length();
        return size;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting recording file size: $e');
      return null;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
