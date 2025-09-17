import 'dart:io';
import 'package:flutter/material.dart';
import '../services/microphone_service.dart';
import '../services/permission_service.dart';

class MicrophoneScreen extends StatefulWidget {
  const MicrophoneScreen({super.key});

  @override
  State<MicrophoneScreen> createState() => _MicrophoneScreenState();
}

class _MicrophoneScreenState extends State<MicrophoneScreen>
    with WidgetsBindingObserver {
  bool _isRecording = false;
  bool _isPaused = false;
  String? _errorMessage;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkMicrophonePermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop recording if it's active
    if (_isRecording) {
      MicrophoneService.stopRecording();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app becomes active (user returns from settings), check permission again
    if (state == AppLifecycleState.resumed) {
      _checkMicrophonePermission();
    }
  }

  Future<void> _checkMicrophonePermission() async {
    try {
      bool hasPermission = await PermissionService.checkMicrophonePermission();
      if (!hasPermission) {
        // Request permission if not already granted
        hasPermission = await PermissionService.requestMicrophonePermission();

        if (!hasPermission) {
          setState(() {
            _errorMessage = 'Microphone permission is required to record audio';
          });
        } else {
          // Permission was granted, clear error message
          setState(() {
            _errorMessage = null;
          });
        }
      } else {
        // Permission is already granted, clear error message
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking microphone permission: ${e.toString()}';
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      final error = await MicrophoneService.startRecording();
      if (error != null) {
        _showSnackBar(error, Colors.red);
        setState(() => _errorMessage = error);
      } else {
        setState(() {
          _isRecording = true;
          _isPaused = false;
          _errorMessage = null;
          _recordingStartTime = DateTime.now();
        });
        _startTimer();
        _showSnackBar('Recording started', Colors.green);
      }
    } catch (e) {
      final errorMsg = 'Error starting recording: ${e.toString()}';
      setState(() => _errorMessage = errorMsg);
      _showSnackBar(errorMsg, Colors.red);
    }
  }

  Future<void> _stopRecording() async {
    try {
      final recordingPath = await MicrophoneService.stopRecording();
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _currentRecordingPath = recordingPath;
        _recordingDuration = Duration.zero;
      });
      _stopTimer();

      if (recordingPath != null) {
        _showSnackBar('Recording saved', Colors.green);
        _showRecordingDialog(recordingPath);
      } else {
        _showSnackBar('Failed to save recording', Colors.red);
      }
    } catch (e) {
      final errorMsg = 'Error stopping recording: ${e.toString()}';
      setState(() => _errorMessage = errorMsg);
      _showSnackBar(errorMsg, Colors.red);
    }
  }

  Future<void> _pauseRecording() async {
    try {
      final error = await MicrophoneService.pauseRecording();
      if (error != null) {
        _showSnackBar(error, Colors.orange);
      } else {
        setState(() => _isPaused = true);
        _stopTimer();
        _showSnackBar('Recording paused', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Error pausing recording: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _resumeRecording() async {
    try {
      final error = await MicrophoneService.resumeRecording();
      if (error != null) {
        _showSnackBar(error, Colors.orange);
      } else {
        setState(() => _isPaused = false);
        _startTimer();
        _showSnackBar('Recording resumed', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error resuming recording: ${e.toString()}', Colors.red);
    }
  }

  void _startTimer() {
    if (_recordingStartTime != null) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_isRecording && !_isPaused && mounted) {
          setState(() {
            _recordingDuration =
                DateTime.now().difference(_recordingStartTime!);
          });
          _startTimer(); // Continue the timer
        }
      });
    }
  }

  void _stopTimer() {
    // Timer will stop naturally when _isRecording becomes false
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showRecordingDialog(String recordingPath) async {
    final file = File(recordingPath);
    final fileSize = await file.length();

    return showDialog<void>(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recording Completed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.audio_file,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text('File: ${recordingPath.split('/').last}'),
              Text('Size: ${MicrophoneService.formatFileSize(fileSize)}'),
              Text(
                  'Duration: ${MicrophoneService.formatDuration(_recordingDuration)}'),
              const SizedBox(height: 16),
              const Text('Recording saved successfully!'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestMicrophonePermission() async {
    try {
      final hasPermission =
          await PermissionService.requestMicrophonePermission();
      if (hasPermission) {
        setState(() {
          _errorMessage = null;
        });
        _showSnackBar('Microphone permission granted!', Colors.green);
      } else {
        setState(() {
          _errorMessage = 'Microphone permission is required to record audio';
        });
        _showSnackBar('Microphone permission denied', Colors.red);
      }
    } catch (e) {
      final errorMsg =
          'Error requesting microphone permission: ${e.toString()}';
      setState(() {
        _errorMessage = errorMsg;
      });
      _showSnackBar(errorMsg, Colors.red);
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Microphone Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _requestMicrophonePermission,
            icon: const Icon(Icons.mic),
            label: const Text('Request Permission'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _checkMicrophonePermission,
            icon: const Icon(Icons.refresh),
            label: const Text('Check Again'),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () async {
              await PermissionService.openPermissionSettings();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingInterface() {
    return Column(
      children: [
        // Status information
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                _isRecording
                    ? (_isPaused
                        ? Icons.pause_circle
                        : Icons.radio_button_checked)
                    : Icons.mic_none,
                size: 64,
                color: _isRecording
                    ? (_isPaused ? Colors.orange : Colors.red)
                    : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording
                    ? (_isPaused ? 'Recording Paused' : 'Recording...')
                    : 'Ready to Record',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_isRecording) ...[
                const SizedBox(height: 8),
                Text(
                  MicrophoneService.formatDuration(_recordingDuration),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ],
          ),
        ),

        const Spacer(),

        // Recording controls
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (!_isRecording) ...[
                // Start recording button
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ElevatedButton(
                    onPressed: _startRecording,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 8,
                    ),
                    child: const Icon(Icons.mic, size: 48),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tap to Start Recording',
                  style: TextStyle(fontSize: 18),
                ),
              ] else ...[
                // Recording controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Pause/Resume button
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: ElevatedButton(
                        onPressed:
                            _isPaused ? _resumeRecording : _pauseRecording,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: Icon(
                          _isPaused ? Icons.play_arrow : Icons.pause,
                          size: 32,
                        ),
                      ),
                    ),

                    // Stop recording button
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: ElevatedButton(
                        onPressed: _stopRecording,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 8,
                        ),
                        child: const Icon(Icons.stop, size: 40),
                      ),
                    ),

                    // Placeholder for symmetry
                    const SizedBox(width: 80, height: 80),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _isPaused ? 'Tap play to resume' : 'Tap stop to finish',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ],
          ),
        ),

        const Spacer(),

        // Current recording info
        if (_currentRecordingPath != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Recording Saved',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _currentRecordingPath!.split('/').last,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microphone'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _errorMessage != null && !_isRecording
          ? _buildErrorWidget()
          : _buildRecordingInterface(),
    );
  }
}
