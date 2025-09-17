import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/gallery_service.dart';
import '../services/permission_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isLoading = true;
  bool _isTakingPicture = false;
  String? _errorMessage;
  String? _lastCapturedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final error = await CameraService.initializeCamera();
      if (error != null) {
        setState(() {
          _errorMessage = error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture) return;

    setState(() => _isTakingPicture = true);

    try {
      final imagePath = await CameraService.takePicture();
      if (imagePath != null) {
        setState(() => _lastCapturedImagePath = imagePath);
        _showImageDialog(imagePath);
      } else {
        _showSnackBar('Failed to capture image', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error taking picture: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isTakingPicture = false);
    }
  }

  Future<void> _switchCamera() async {
    try {
      final error = await CameraService.switchCamera();
      if (error != null) {
        _showSnackBar(error, Colors.orange);
      } else {
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      _showSnackBar('Error switching camera: ${e.toString()}', Colors.red);
    }
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

  Future<void> _showImageDialog(String imagePath) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Image Captured'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Would you like to save this image to gallery?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Discard'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save to Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _saveToGallery(imagePath);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveToGallery(String imagePath) async {
    try {
      final success = await GalleryService.saveImageToGallery(imagePath);
      if (success) {
        _showSnackBar('Image saved to gallery successfully!', Colors.green);
      } else {
        _showSnackBar('Failed to save image to gallery', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error saving to gallery: ${e.toString()}', Colors.red);
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
            'Camera Error',
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
            onPressed: _initializeCamera,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
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

  Widget _buildCameraPreview() {
    final controller = CameraService.controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),

        // Camera controls overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Switch camera button
                if (CameraService.cameras.length > 1)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _switchCamera,
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 56),

                // Capture button
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: _isTakingPicture
                        ? Colors.red.withOpacity(0.5)
                        : Colors.transparent,
                  ),
                  child: IconButton(
                    onPressed: _isTakingPicture ? null : _takePicture,
                    icon: Icon(
                      _isTakingPicture ? Icons.hourglass_empty : Icons.camera,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                // Last captured image preview
                _lastCapturedImagePath != null
                    ? GestureDetector(
                        onTap: () => _showImageDialog(_lastCapturedImagePath!),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              File(_lastCapturedImagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(width: 56),
              ],
            ),
          ),
        ),

        // Loading overlay
        if (_isTakingPicture)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Taking Picture...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildCameraPreview(),
    );
  }

  @override
  void dispose() {
    // Don't dispose the camera service here as it might be used by other screens
    super.dispose();
  }
}
