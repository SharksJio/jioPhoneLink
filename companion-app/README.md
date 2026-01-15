# Jio Phone Link - Companion App

This is the companion app that runs on Android/iOS phones and shares data with the tablet app.

## Features

- **Notifications Sync**: Send phone notifications to tablet
- **SMS Sync**: Share SMS messages with tablet
- **Call Logs**: Share call history with tablet
- **Device Info**: Share battery status, network signal strength
- **DND Control**: Sync Do Not Disturb settings
- **File Sharing**: Transfer files between phone and tablet

## Setup

1. Install Flutter SDK (3.0.0 or higher)
2. Run `flutter pub get` to install dependencies
3. Connect your Android/iOS device
4. Run `flutter run` to build and install the app

## Required Permissions

The app requires the following permissions:
- Notification access
- SMS read/send
- Call logs read
- Battery status
- Network state
- Storage access

## Pairing with Tablet

1. Open the app on your phone
2. Open the tablet app
3. Scan the QR code displayed on the tablet
4. Grant necessary permissions
5. Start syncing data

## Build

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```
