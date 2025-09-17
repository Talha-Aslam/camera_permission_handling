// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../services/camera_service.dart';
import '../services/gallery_service.dart';
import '../services/microphone_service.dart';
import 'camera_screen.dart';
import 'gallery_screen.dart';
import 'microphone_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _cameraPermissionStatus = 'Unknown';
  String _microphonePermissionStatus = 'Unknown';
  String _galleryPermissionStatus = 'Unknown';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    setState(() => _isLoading = true);

    try {
      final cameraStatus = await PermissionService.getCameraPermissionStatus();
      final microphoneStatus =
          await PermissionService.getMicrophonePermissionStatus();
      final galleryStatus = await GalleryService.getGalleryPermissionStatus();

      setState(() {
        _cameraPermissionStatus =
            PermissionService.getPermissionStatusText(cameraStatus);
        _microphonePermissionStatus =
            PermissionService.getPermissionStatusText(microphoneStatus);
        _galleryPermissionStatus = galleryStatus;
      });
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return Colors.green;
      case 'denied':
        return Colors.orange;
      case 'permanently denied':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPermissionCard({
    required String title,
    required String status,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(
          icon,
          size: 32,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Status: $status',
          style: TextStyle(
            color: _getStatusColor(status),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showErrorDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
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

  Future<void> _navigateToCameraScreen() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      ).then((_) {
        // Refresh permissions when returning
        _checkAllPermissions();
      });
    } catch (e) {
      await _showErrorDialog('Error', 'Failed to open camera: ${e.toString()}');
    }
  }

  Future<void> _navigateToGalleryScreen() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GalleryScreen()),
      ).then((_) {
        // Refresh permissions when returning
        _checkAllPermissions();
      });
    } catch (e) {
      await _showErrorDialog(
          'Error', 'Failed to open gallery: ${e.toString()}');
    }
  }

  Future<void> _navigateToMicrophoneScreen() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MicrophoneScreen()),
      ).then((_) {
        // Refresh permissions when returning
        _checkAllPermissions();
      });
    } catch (e) {
      await _showErrorDialog(
          'Error', 'Failed to open microphone: ${e.toString()}');
    }
  }

  Future<void> _openPermissionSettings() async {
    try {
      await PermissionService.openPermissionSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening permission settings...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Refresh permissions after user potentially changes them
      Future.delayed(const Duration(seconds: 3), () {
        _checkAllPermissions();
      });
    } catch (e) {
      await _showErrorDialog(
          'Error', 'Failed to open permission settings: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Permission Demo'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _checkAllPermissions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Permission Status Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap on any feature below to use it. The app will handle permissions gracefully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildPermissionCard(
                        title: 'Camera',
                        status: _cameraPermissionStatus,
                        icon: Icons.camera_alt,
                        onTap: _navigateToCameraScreen,
                      ),
                      _buildPermissionCard(
                        title: 'Microphone',
                        status: _microphonePermissionStatus,
                        icon: Icons.mic,
                        onTap: _navigateToMicrophoneScreen,
                      ),
                      _buildPermissionCard(
                        title: 'Gallery',
                        status: _galleryPermissionStatus,
                        icon: Icons.photo_library,
                        onTap: _navigateToGalleryScreen,
                      ),
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: Icon(
                            Icons.settings,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: const Text(
                            'Permission Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'Open app settings to manage permissions',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: _openPermissionSettings,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'This app demonstrates proper permission handling\nwith graceful error handling.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    // Dispose services when screen is disposed
    CameraService.dispose();
    MicrophoneService.dispose();
    super.dispose();
  }
}
