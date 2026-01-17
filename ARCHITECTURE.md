# Architecture Documentation

## System Overview

The Jio Phone Link system consists of two main components that communicate over a WebSocket connection:

1. **Tablet App** (Server) - Android tablet application
2. **Companion App** (Client) - Flutter mobile application

## High-Level Architecture

```
┌─────────────────────┐         WebSocket          ┌─────────────────────┐
│   Companion App     │◄────── (Port 8080) ───────►│    Tablet App       │
│   (Phone/iOS)       │         JSON Messages       │    (Tablet)         │
└─────────────────────┘                             └─────────────────────┘
         │                                                    │
         │                                                    │
         ▼                                                    ▼
┌─────────────────────┐                            ┌─────────────────────┐
│  Phone Services     │                            │  Display Services   │
│  - Notifications    │                            │  - Notifications UI │
│  - SMS              │                            │  - Messages UI      │
│  - Calls            │                            │  - Call Logs UI     │
│  - Battery          │                            │  - Device Info UI   │
│  - Network          │                            │  - QR Code Display  │
└─────────────────────┘                            └─────────────────────┘
```

## Component Architecture

### Tablet App (Android - MVVM Pattern)

```
MainActivity
    │
    ├──► PhoneLinkViewModel (State Management)
    │       │
    │       ├──► WebSocketServer (Communication)
    │       │       └──► Handles incoming messages
    │       │
    │       └──► LiveData (Data Streams)
    │               ├──► Connection Status
    │               ├──► Battery Level
    │               ├──► Notifications
    │               └──► Messages
    │
    └──► UI Components
            ├──► RecyclerView (Notifications)
            ├──► Device Info Display
            └──► QR Code Generator
```

**Key Classes:**

- `MainActivity.kt` - Main UI controller
- `PhoneLinkViewModel.kt` - State management and business logic
- `WebSocketServer.kt` - WebSocket server implementation
- `NotificationAdapter.kt` - RecyclerView adapter for notifications
- `Models.kt` - Data models (Notification, Message, CallLog, DeviceInfo)

### Companion App (Flutter - Service-Based Architecture)

```
main.dart
    │
    └──► JioCompanionApp (Root Widget)
            │
            ├──► AppInitializer (Startup Logic)
            │       └──► ConnectionService.isConnected()
            │
            ├──► Screens
            │   ├──► PairingScreen
            │   │       ├──► QR Scanner
            │   │       └──► Manual Connection
            │   │
            │   └──► HomeScreen
            │           ├──► Status Card
            │           ├──► Sync Controls
            │           └──► Device Info Display
            │
            └──► Services (Business Logic)
                ├──► ConnectionService (WebSocket)
                ├──► NotificationService
                ├──► SmsService
                └──► DeviceInfoService
```

**Key Components:**

- `main.dart` - App entry point and initialization
- `connection_service.dart` - WebSocket client and message handling
- `notification_service.dart` - Notification monitoring and forwarding
- `sms_service.dart` - SMS reading and syncing
- `device_info_service.dart` - Battery and network monitoring
- `pairing_screen.dart` - QR scanning and pairing UI
- `home_screen.dart` - Main app interface

## Communication Flow

### 1. Pairing Flow

```
Tablet                          Companion
  │                                │
  │ 1. Start WebSocket Server      │
  │    (Port 8080)                 │
  │                                │
  │ 2. Get Local IP Address        │
  │    (e.g., 192.168.1.100)       │
  │                                │
  │ 3. Generate QR Code             │
  │    Content: IP Address         │
  │                                │
  │ ◄──────────────────────────────┤ 4. Open Companion App
  │                                │
  │ ◄──────────────────────────────┤ 5. Scan QR Code
  │                                │
  │ ◄──────────────────────────────┤ 6. Extract IP Address
  │                                │
  │ ◄──────────────────────────────┤ 7. Connect to ws://IP:8080
  │                                │
  │ 8. Accept Connection           │
  │ ────────────────────────────────►
  │                                │
  │ 9. Connection Established      │
  │ ◄───────────────────────────────►
```

### 2. Data Sync Flow

```
Companion App                           Tablet App
     │                                       │
     │ 1. Monitor Phone Events               │
     │    (Notification, SMS, etc.)          │
     │                                       │
     │ 2. Serialize to JSON                  │
     │    {                                  │
     │      "type": "notification",          │
     │      "data": {...}                    │
     │    }                                  │
     │                                       │
     │ 3. Send via WebSocket                 │
     │ ──────────────────────────────────────►
     │                                       │
     │                                       │ 4. Receive Message
     │                                       │
     │                                       │ 5. Parse JSON
     │                                       │
     │                                       │ 6. Update ViewModel
     │                                       │
     │                                       │ 7. LiveData Notifies UI
     │                                       │
     │                                       │ 8. UI Updates Display
```

## Data Models

### Notification
```kotlin
data class Notification(
    val title: String,
    val body: String,
    val packageName: String?,
    val timestamp: String
)
```

### Message (SMS)
```kotlin
data class Message(
    val address: String,      // Phone number
    val body: String,         // Message content
    val date: String          // Timestamp
)
```

### Device Info
```kotlin
data class DeviceInfo(
    val batteryLevel: Int,
    val batteryState: String,
    val networkSignal: String
)
```

### Call Log
```kotlin
data class CallLog(
    val number: String,
    val type: String,         // incoming/outgoing/missed
    val date: String,
    val duration: Long        // in seconds
)
```

## Message Protocol

### Message Structure
```json
{
  "type": "message_type",
  "data": {
    // Type-specific payload
  }
}
```

### Message Types

1. **notification** - Phone notification received
2. **sms_sync** - SMS messages sync
3. **call_log** - Call log sync
4. **device_info** - Battery and network info
5. **dnd_status** - Do Not Disturb status
6. **file_transfer** - File sharing data

## Threading Model

### Tablet App (Android)
- **Main Thread**: UI updates via LiveData observers
- **IO Thread**: WebSocket server operations
- **Background Thread**: Message processing and parsing

### Companion App (Flutter)
- **Main Isolate**: UI rendering
- **Platform Thread**: Native platform calls (permissions, sensors)
- **Background Isolate**: WebSocket communication (via Stream)

## State Management

### Tablet App
Uses Android Architecture Components:
- **ViewModel**: Survives configuration changes
- **LiveData**: Observable data holder
- **Repository Pattern**: Data layer abstraction (if needed)

### Companion App
Uses Flutter's built-in state management:
- **StatefulWidget**: Local UI state
- **Services**: Singleton pattern for shared state
- **Streams**: Reactive data flow for real-time updates

## Security Considerations

### Current Implementation
- **No encryption**: WebSocket connection is plain text
- **No authentication**: Any device can connect if it knows the IP
- **Local network only**: Designed for same-network use

### Recommended Enhancements
1. **SSL/TLS**: Use wss:// instead of ws://
2. **Authentication**: Add token-based auth during pairing
3. **Encryption**: Encrypt message payloads
4. **Certificate Pinning**: For Flutter app
5. **Timeout**: Automatic disconnection after inactivity

## Performance Considerations

### Network Optimization
- **Batching**: Group multiple notifications/messages
- **Compression**: Use gzip for large payloads
- **Throttling**: Limit update frequency (e.g., battery updates every 30s)

### Memory Management
- **List Limits**: Cap notification history (e.g., last 100)
- **Image Optimization**: Compress images in file transfers
- **Resource Cleanup**: Properly dispose connections and streams

## Scalability

### Current Limitations
- Single phone connection
- No cloud backup
- Local network only

### Future Architecture
```
                    ┌──────────────┐
                    │  Cloud Server│
                    │   (Optional) │
                    └──────┬───────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
    ┌────▼────┐      ┌─────▼────┐     ┌─────▼────┐
    │ Phone 1 │      │ Phone 2  │     │ Phone N  │
    └────┬────┘      └─────┬────┘     └─────┬────┘
         │                 │                 │
         └─────────────────┼─────────────────┘
                           │
                    ┌──────▼───────┐
                    │    Tablet    │
                    └──────────────┘
```

## Error Handling

### Connection Errors
- Retry logic with exponential backoff
- Automatic reconnection on network change
- User notification for persistent failures

### Data Errors
- JSON parsing error handling
- Invalid message type handling
- Missing data field validation

### Permission Errors
- Graceful degradation if permissions denied
- Clear user prompts for required permissions
- Alternative features if optional permissions denied

## Testing Strategy

### Unit Tests
- Service layer logic
- Message parsing/serialization
- Data model validation

### Integration Tests
- WebSocket connection flow
- Message exchange scenarios
- State management

### UI Tests
- Screen navigation
- User interactions
- Permission flows

## Deployment

### Development
- Debug builds with logging
- Local network testing
- USB debugging

### Production
- Release builds with ProGuard/R8
- App signing
- Play Store/App Store deployment
- Version management

## Monitoring & Logging

### Tablet App
- Logcat for debugging
- Crashlytics (optional)
- Network traffic monitoring

### Companion App
- Flutter DevTools
- Platform-specific crash reporting
- WebSocket connection logs
