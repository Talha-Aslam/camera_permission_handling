import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_service.dart';

class GalleryService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImageFromGallery() async {
    try {
      // Check storage/photos permission first
      bool hasPermission = await _checkGalleryPermission();
      if (!hasPermission) {
        hasPermission = await _requestGalleryPermission();
        if (!hasPermission) {
          return null; // Permission denied
        }
      }

      // Pick image using image_picker
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return image.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  static Future<List<String>?> pickMultipleImagesFromGallery() async {
    try {
      // Check storage/photos permission first
      bool hasPermission = await _checkGalleryPermission();
      if (!hasPermission) {
        hasPermission = await _requestGalleryPermission();
        if (!hasPermission) {
          return null; // Permission denied
        }
      }

      // Pick multiple images using image_picker
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        return images.map((image) => image.path).toList();
      }
      return null;
    } catch (e) {
      debugPrint('Error picking multiple images from gallery: $e');
      return null;
    }
  }

  static Future<List<AssetEntity>?> getRecentPhotos({int count = 20}) async {
    try {
      // Check photo manager permission
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();

      if (permission != PermissionState.authorized) {
        debugPrint('Photo manager permission denied');
        return null;
      }

      // Get recent photos
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isNotEmpty) {
        final List<AssetEntity> assets = await albums.first.getAssetListRange(
          start: 0,
          end: count,
        );
        return assets;
      }
      return [];
    } catch (e) {
      debugPrint('Error getting recent photos: $e');
      return null;
    }
  }

  static Future<Uint8List?> getAssetThumbnail(AssetEntity asset) async {
    try {
      return await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    } catch (e) {
      debugPrint('Error getting asset thumbnail: $e');
      return null;
    }
  }

  static Future<File?> getAssetFile(AssetEntity asset) async {
    try {
      return await asset.file;
    } catch (e) {
      debugPrint('Error getting asset file: $e');
      return null;
    }
  }

  static Future<bool> saveImageToGallery(String imagePath) async {
    try {
      // Check storage/photos permission first
      bool hasPermission = await _checkGalleryPermission();
      if (!hasPermission) {
        hasPermission = await _requestGalleryPermission();
        if (!hasPermission) {
          return false; // Permission denied
        }
      }

      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return false;
      }

      // Save to gallery using PhotoManager
      final AssetEntity result = await PhotoManager.editor.saveImageWithPath(
        imagePath,
        title: 'Camera_${DateTime.now().millisecondsSinceEpoch}',
      );

      // ignore: unnecessary_null_comparison
      return result != null;
    } catch (e) {
      debugPrint('Error saving image to gallery: $e');
      return false;
    }
  }

  static Future<bool> _checkGalleryPermission() async {
    try {
      // For Android 13+ (API 33+), check for READ_MEDIA_IMAGES
      if (Platform.isAndroid) {
        // Check both storage and photos permission
        final bool storagePermission =
            await PermissionService.checkStoragePermission();
        final bool photosPermission =
            await PermissionService.checkPhotosPermission();
        return storagePermission || photosPermission;
      } else if (Platform.isIOS) {
        return await PermissionService.checkPhotosPermission();
      }
      return false;
    } catch (e) {
      debugPrint('Error checking gallery permission: $e');
      return false;
    }
  }

  static Future<bool> _requestGalleryPermission() async {
    try {
      if (Platform.isAndroid) {
        // Try to request both permissions
        final bool storagePermission =
            await PermissionService.requestStoragePermission();
        final bool photosPermission =
            await PermissionService.requestPhotosPermission();
        return storagePermission || photosPermission;
      } else if (Platform.isIOS) {
        return await PermissionService.requestPhotosPermission();
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting gallery permission: $e');
      return false;
    }
  }

  static Future<String> getGalleryPermissionStatus() async {
    try {
      if (Platform.isAndroid) {
        final storageStatus =
            await PermissionService.getStoragePermissionStatus();
        final photosStatus =
            await PermissionService.getPhotosPermissionStatus();

        if (storageStatus == PermissionStatus.granted ||
            photosStatus == PermissionStatus.granted) {
          return 'Granted';
        } else if (storageStatus == PermissionStatus.permanentlyDenied ||
            photosStatus == PermissionStatus.permanentlyDenied) {
          return 'Permanently Denied';
        } else {
          return 'Denied';
        }
      } else if (Platform.isIOS) {
        final photosStatus =
            await PermissionService.getPhotosPermissionStatus();
        return PermissionService.getPermissionStatusText(photosStatus);
      }
      return 'Unknown';
    } catch (e) {
      debugPrint('Error getting gallery permission status: $e');
      return 'Error';
    }
  }
}
