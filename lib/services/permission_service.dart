import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }

  static Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }

  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<bool> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting photos permission: $e');
      return false;
    }
  }

  static Future<bool> checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error checking camera permission: $e');
      return false;
    }
  }

  static Future<bool> checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error checking microphone permission: $e');
      return false;
    }
  }

  static Future<bool> checkStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error checking storage permission: $e');
      return false;
    }
  }

  static Future<bool> checkPhotosPermission() async {
    try {
      final status = await Permission.photos.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error checking photos permission: $e');
      return false;
    }
  }

  static Future<void> openPermissionSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  static Future<PermissionStatus> getCameraPermissionStatus() async {
    try {
      return await Permission.camera.status;
    } catch (e) {
      debugPrint('Error getting camera permission status: $e');
      return PermissionStatus.denied;
    }
  }

  static Future<PermissionStatus> getMicrophonePermissionStatus() async {
    try {
      return await Permission.microphone.status;
    } catch (e) {
      debugPrint('Error getting microphone permission status: $e');
      return PermissionStatus.denied;
    }
  }

  static Future<PermissionStatus> getStoragePermissionStatus() async {
    try {
      return await Permission.storage.status;
    } catch (e) {
      debugPrint('Error getting storage permission status: $e');
      return PermissionStatus.denied;
    }
  }

  static Future<PermissionStatus> getPhotosPermissionStatus() async {
    try {
      return await Permission.photos.status;
    } catch (e) {
      debugPrint('Error getting photos permission status: $e');
      return PermissionStatus.denied;
    }
  }

  static String getPermissionStatusText(PermissionStatus status) {
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
      default:
        return 'Unknown';
    }
  }

  static Future<bool> handlePermissionDenied(
      PermissionStatus status, String permissionName) async {
    if (status == PermissionStatus.permanentlyDenied) {
      // Permission is permanently denied, we need to open app settings
      debugPrint(
          '$permissionName permission is permanently denied. Please enable it in app settings.');
      return false;
    } else if (status == PermissionStatus.denied) {
      // Permission is denied, but we can request again
      debugPrint('$permissionName permission is denied.');
      return false;
    }
    return true;
  }
}
