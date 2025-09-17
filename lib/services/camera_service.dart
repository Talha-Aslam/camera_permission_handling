import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'permission_service.dart';

class CameraService {
  static CameraController? _controller;
  static List<CameraDescription> _cameras = [];
  static bool _isInitialized = false;

  static Future<String?> initializeCamera() async {
    try {
      // Check camera permission first
      bool hasPermission = await PermissionService.checkCameraPermission();
      if (!hasPermission) {
        hasPermission = await PermissionService.requestCameraPermission();
        if (!hasPermission) {
          return 'Camera permission is required to use the camera';
        }
      }

      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        return 'No cameras available on this device';
      }

      // Initialize camera controller with the first camera (usually back camera)
      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;

      return null; // Success
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      return 'Failed to initialize camera: ${e.toString()}';
    }
  }

  static Future<String?> takePicture() async {
    try {
      if (!_isInitialized || _controller == null) {
        final error = await initializeCamera();
        if (error != null) {
          return error;
        }
      }

      if (!_controller!.value.isInitialized) {
        return 'Camera is not initialized';
      }

      // Get the temporary directory to save the image
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(tempDir.path, fileName);

      // Take the picture
      final XFile picture = await _controller!.takePicture();

      // Copy the file to our desired location
      await picture.saveTo(filePath);

      return filePath; // Return the file path
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  static CameraController? get controller => _controller;
  static bool get isInitialized => _isInitialized;
  static List<CameraDescription> get cameras => _cameras;

  static Future<String?> switchCamera() async {
    try {
      if (_cameras.length < 2) {
        return 'No other camera available';
      }

      if (_controller != null) {
        await _controller!.dispose();
      }

      // Switch to the other camera
      final currentCameraIndex = _cameras.indexOf(_controller!.description);
      final newCameraIndex = (currentCameraIndex + 1) % _cameras.length;

      _controller = CameraController(
        _cameras[newCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      return null; // Success
    } catch (e) {
      debugPrint('Error switching camera: $e');
      return 'Failed to switch camera: ${e.toString()}';
    }
  }

  static Future<void> dispose() async {
    try {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
        _isInitialized = false;
      }
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
  }

  static Future<bool> checkCameraAvailability() async {
    try {
      final cameras = await availableCameras();
      return cameras.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking camera availability: $e');
      return false;
    }
  }
}
