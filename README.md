# Camera Permission Handling App

A Flutter application that demonstrates proper handling of camera, microphone, and gallery permissions with comprehensive error handling and user-friendly permission management.

## 📱 Features

- **Camera Access**: Take photos with front and back camera switching
- **Microphone Recording**: Record audio with pause/resume functionality
- **Gallery Access**: Pick single or multiple images from device gallery
- **Permission Settings**: Direct access to app permission settings
- **Real-time Permission Status**: Automatic updates when permissions are granted/denied
- **Comprehensive Error Handling**: Graceful handling of permission denials without app crashes

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.5.3)
- Android SDK (API level 24 or higher)
- iOS 11.0 or higher (for iOS builds)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Talha-Aslam/camera_permission_handling.git
   cd camera_permission_handling
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## 🔧 Dependencies

The app uses the following key packages:

- **[permission_handler](https://pub.dev/packages/permission_handler)** (^11.3.1) - Handle device permissions
- **[photo_manager](https://pub.dev/packages/photo_manager)** (^3.2.1) - Access device gallery
- **[camera](https://pub.dev/packages/camera)** (^0.10.5+9) - Camera functionality
- **[image_picker](https://pub.dev/packages/image_picker)** (^1.0.8) - Pick images from gallery
- **[flutter_sound](https://pub.dev/packages/flutter_sound)** (^9.10.6) - Audio recording
- **[path_provider](https://pub.dev/packages/path_provider)** (^2.1.3) - File system paths

## 📂 Project Structure

```
lib/
├── main.dart                     # App entry point
├── services/                     # Business logic services
│   ├── permission_service.dart   # Permission handling
│   ├── camera_service.dart       # Camera functionality
│   ├── gallery_service.dart      # Gallery operations
│   └── microphone_service.dart   # Audio recording
└── screens/                      # UI screens
    ├── home_screen.dart          # Main screen with buttons
    ├── camera_screen.dart        # Camera interface
    ├── gallery_screen.dart       # Gallery picker
    └── microphone_screen.dart    # Recording interface
```

## 🛠️ Configuration

### Android Setup

The app requires the following permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Camera permissions -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Microphone permissions -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Storage permissions -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Android 13+ media permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />

<!-- Hardware features -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
<uses-feature android:name="android.hardware.microphone" android:required="false" />
```

**Build Configuration:**
- `compileSdk`: 35
- `minSdk`: 24
- `targetSdk`: 35

### iOS Setup

Add the following keys to `ios/Runner/Info.plist`:

```xml
<!-- Camera permission -->
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos.</string>

<!-- Microphone permission -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone to record audio.</string>

<!-- Photo library permissions -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select and save images.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs access to photo library to save images.</string>
```

## 🎯 Key Features Explained

### 1. Smart Permission Handling
- **Automatic Requests**: Permissions are requested when features are accessed
- **Status Tracking**: Real-time permission status updates
- **Settings Integration**: Direct links to app settings for permanently denied permissions
- **Lifecycle Awareness**: Automatic permission checks when returning from settings

### 2. Camera Functionality
- **Multi-camera Support**: Switch between front and back cameras
- **Photo Capture**: High-quality image capture with proper file management
- **Error Recovery**: Graceful handling of camera initialization failures

### 3. Audio Recording
- **Professional Recording**: AAC format with configurable quality
- **Recording Controls**: Start, stop, pause, and resume functionality
- **Real-time Feedback**: Recording duration display and file size information

### 4. Gallery Integration
- **Single/Multiple Selection**: Choose one or multiple images
- **Recent Photos**: Quick access to recently taken photos
- **Cross-platform**: Works on both Android and iOS with proper permissions

## 🔒 Permission Flow

The app handles permissions in the following order:

1. **Check Current Status**: Verify if permission is already granted
2. **Request Permission**: Ask user for permission if not granted
3. **Handle Response**: 
   - ✅ **Granted**: Proceed with functionality
   - ❌ **Denied**: Show retry options
   - 🔒 **Permanently Denied**: Redirect to settings
4. **Auto-refresh**: Update UI when returning from settings

## 🧪 Testing

### Test Scenarios

1. **First Launch**: All permissions should be requested when features are accessed
2. **Permission Denial**: App should not crash and show appropriate error messages
3. **Settings Return**: Permission status should update when returning from system settings
4. **Background/Foreground**: App state should be maintained during permission flows

### Running Tests

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 🚨 Error Handling

The app implements comprehensive error handling:

- **Permission Denied**: Clear error messages with retry options
- **Hardware Unavailable**: Graceful degradation when camera/mic unavailable
- **File System Errors**: Proper error messages for storage issues
- **Network Issues**: Handled for any online operations
- **App Lifecycle**: Maintains state during permission flows

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Talha Aslam**
- GitHub: [@Talha-Aslam](https://github.com/Talha-Aslam)

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Package maintainers for the essential plugins
- Community for inspiration and best practices

## 📚 Additional Resources

- [Flutter Permission Handling Guide](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Android Permission System](https://developer.android.com/guide/topics/permissions/overview)
- [iOS Permission Guidelines](https://developer.apple.com/design/human-interface-guidelines/requesting-permission)

---

**Note**: This app demonstrates best practices for permission handling in Flutter. It's designed to be educational and can serve as a template for production apps requiring similar functionality.
