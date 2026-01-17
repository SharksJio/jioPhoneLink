# Jio Phone Link - Tablet App

This is the tablet app that receives and displays data from connected phones.

## Features

- **Notifications Display**: View phone notifications on tablet
- **SMS Messages**: Read and send SMS from tablet
- **Call Logs**: View call history from phone
- **Device Info**: Display battery status, network signal strength
- **DND Control**: Control Do Not Disturb settings
- **File Sharing**: Transfer files between phone and tablet

## Requirements

- Android 8.0 (API level 26) or higher
- Tablet device recommended (phone also supported)

## Setup

1. Install Android Studio
2. Open this project in Android Studio
3. Sync Gradle dependencies
4. Build and run on your tablet

## Pairing with Phone

1. Open the tablet app
2. A QR code will be displayed
3. Open the companion app on your phone
4. Scan the QR code with the phone
5. Start receiving data

## Build

```bash
./gradlew assembleRelease
```

## Architecture

- WebSocket server for real-time communication
- Material Design UI
- MVVM architecture pattern
