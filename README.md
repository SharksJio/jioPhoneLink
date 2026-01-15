# Jio Phone Link

A comprehensive phone linking system similar to Microsoft Phone Link, enabling seamless integration between Android/iOS phones and tablets.

## Overview

This repository contains two applications:

1. **Tablet App** - Android application for tablets that displays phone information
2. **Companion App** - Flutter application for Android/iOS phones that shares data with the tablet

## Features

### Tablet App (Android)
- 📱 **Notifications Display** - View phone notifications in real-time
- 💬 **SMS Messages** - Read and manage text messages
- 📞 **Call Logs** - Access phone call history
- 🔋 **Battery Status** - Monitor phone battery level
- 📶 **Network Signal** - View network signal strength
- 🔕 **DND Control** - Manage Do Not Disturb settings
- 📁 **File Sharing** - Transfer files between devices
- 🔐 **QR Code Pairing** - Simple and secure device pairing

### Companion App (Flutter - Android/iOS)
- 🔗 **WebSocket Connection** - Real-time data sync with tablet
- 📲 **Notification Forwarding** - Send notifications to tablet
- 💬 **SMS Sync** - Share SMS messages with tablet
- 📞 **Call Log Sync** - Share call history with tablet
- 🔋 **Device Info Sharing** - Share battery and network status
- 📱 **QR Code Scanner** - Easy pairing with tablet
- 📁 **File Transfer** - Share files with tablet

## Architecture

### Communication Protocol
- **WebSocket Server** running on tablet (port 8080)
- **WebSocket Client** in companion app connects to tablet
- **JSON-based messaging** for data exchange
- **Real-time bidirectional communication**

### Technology Stack

**Tablet App:**
- Language: Kotlin
- Build System: Gradle
- Architecture: MVVM (Model-View-ViewModel)
- Libraries:
  - Java-WebSocket (WebSocket server)
  - ZXing (QR code generation)
  - AndroidX (Jetpack components)
  - Material Design 3

**Companion App:**
- Framework: Flutter 3.0+
- Language: Dart
- Libraries:
  - web_socket_channel (WebSocket client)
  - mobile_scanner (QR code scanning)
  - permission_handler (Runtime permissions)
  - battery_plus (Battery info)
  - telephony (SMS access)
  - flutter_local_notifications (Notifications)

## Getting Started

### Prerequisites

**For Tablet App:**
- Android Studio Arctic Fox or later
- Android SDK (API 26+)
- Kotlin 1.9+
- Gradle 8.2+

**For Companion App:**
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)

### Installation

#### Tablet App

1. Navigate to the tablet app directory:
```bash
cd tablet-app
```

2. Open the project in Android Studio

3. Sync Gradle dependencies

4. Build and run on your tablet:
```bash
./gradlew assembleDebug
```

#### Companion App

1. Navigate to the companion app directory:
```bash
cd companion-app
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Android
flutter run

# For iOS
flutter run --device=<ios-device-id>
```

## Usage

### Pairing Devices

1. **Start the Tablet App**
   - Open the app on your tablet
   - A QR code will be displayed on the screen
   - Note the IP address shown

2. **Connect from Phone**
   - Open the companion app on your phone
   - Tap "Scan QR Code"
   - Scan the QR code displayed on the tablet
   - Grant necessary permissions when prompted

3. **Start Syncing**
   - Once connected, data will automatically sync
   - Use the sync buttons to manually trigger updates

### Required Permissions

**Companion App (Phone):**
- Notification access
- SMS read/write
- Call log read
- Phone state
- Camera (for QR scanning)
- Storage access
- Network access

**Tablet App:**
- Internet access
- Network state
- Camera (optional)
- Storage access

## Project Structure

```
jioPhoneLink/
├── companion-app/          # Flutter companion app
│   ├── lib/
│   │   ├── main.dart      # App entry point
│   │   ├── screens/       # UI screens
│   │   ├── services/      # Business logic
│   │   ├── models/        # Data models
│   │   └── widgets/       # Reusable widgets
│   ├── android/           # Android specific config
│   └── pubspec.yaml       # Flutter dependencies
│
├── tablet-app/            # Android tablet app
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── java/com/jio/phonelink/
│   │   │   │   ├── MainActivity.kt
│   │   │   │   ├── viewmodel/      # ViewModels
│   │   │   │   ├── server/         # WebSocket server
│   │   │   │   ├── model/          # Data models
│   │   │   │   └── adapter/        # RecyclerView adapters
│   │   │   ├── res/                # Resources (layouts, strings, etc.)
│   │   │   └── AndroidManifest.xml
│   │   └── build.gradle
│   ├── build.gradle
│   └── settings.gradle
│
├── .gitignore
├── LICENSE
└── README.md
```

## Communication Protocol

### Message Format

All messages exchanged between devices use JSON format:

```json
{
  "type": "notification|sms_sync|device_info|call_log",
  "data": {
    // Type-specific data
  }
}
```

### Message Types

**1. Notification**
```json
{
  "type": "notification",
  "data": {
    "title": "App Name",
    "body": "Notification content",
    "packageName": "com.example.app",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**2. Device Info**
```json
{
  "type": "device_info",
  "data": {
    "battery": {
      "level": 85,
      "state": "charging"
    },
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**3. SMS Sync**
```json
{
  "type": "sms_sync",
  "data": {
    "messages": [
      {
        "address": "+1234567890",
        "body": "Message content",
        "date": "2024-01-15T10:30:00Z"
      }
    ],
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

## Development

### Building for Production

**Tablet App:**
```bash
cd tablet-app
./gradlew assembleRelease
```

**Companion App:**
```bash
cd companion-app
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Testing

**Tablet App:**
```bash
./gradlew test
```

**Companion App:**
```bash
flutter test
```

## Troubleshooting

### Connection Issues
- Ensure both devices are on the same WiFi network
- Check firewall settings on the tablet
- Verify the correct IP address is being used
- Try regenerating the QR code

### Permission Issues
- Go to app settings and manually grant required permissions
- On Android 13+, notification permission must be granted explicitly

### Build Issues
- Clean and rebuild: `./gradlew clean` or `flutter clean`
- Update dependencies: `flutter pub upgrade`
- Ensure correct SDK versions are installed

## Security Considerations

- WebSocket connection is currently unencrypted (use within trusted networks)
- Consider implementing SSL/TLS for production use
- Store sensitive data securely using platform-specific secure storage
- Validate and sanitize all incoming messages

## Future Enhancements

- [ ] End-to-end encryption for messages
- [ ] Support for multiple phone connections
- [ ] Cloud backup of messages and settings
- [ ] Cross-platform desktop support (Windows, macOS, Linux)
- [ ] Voice/video call support
- [ ] Remote phone screen mirroring
- [ ] Bluetooth connectivity as fallback

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See the [LICENSE](LICENSE) file for details.

## Support

For issues and questions, please create an issue in the GitHub repository.

---

**Note:** This application requires appropriate permissions and should only be used on devices you own or have explicit permission to access.
