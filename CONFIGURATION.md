# Example Configuration

This directory contains example configuration files for the Jio Phone Link applications.

## Configuration Files

### Tablet App

**Key Configuration Options:**

1. **WebSocket Server Port** (Default: 8080)
   - Location: `PhoneLinkViewModel.kt`
   - Can be changed to any available port

2. **Network Interface**
   - Automatically detects local IP address
   - Uses first available non-loopback IPv4 address

3. **QR Code Settings**
   - Size: 512x512 pixels
   - Format: QR_CODE
   - Content: IP address of tablet

### Companion App

**Key Configuration Options:**

1. **WebSocket Connection**
   - Protocol: ws://
   - Port: 8080 (must match tablet)
   - Timeout: 10 seconds

2. **Update Intervals**
   - Battery Info: 30 seconds
   - Network Info: 30 seconds
   - SMS Sync: On-demand

3. **File Transfer**
   - Max File Size: 10MB
   - Encoding: Base64

## Environment Variables

### For Development

Create a `.env` file (not committed to repository):

```
# Tablet App
WEBSOCKET_PORT=8080
DEBUG_MODE=true

# Companion App
DEFAULT_TABLET_IP=192.168.1.100
ENABLE_LOGGING=true
```

## Build Variants

### Android (Tablet App)

Create different build flavors in `app/build.gradle`:

```gradle
android {
    flavorDimensions "version"
    productFlavors {
        dev {
            dimension "version"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        prod {
            dimension "version"
        }
    }
}
```

### Flutter (Companion App)

Create different flavors:

```bash
# Run with dev flavor
flutter run --flavor dev --dart-define=ENV=dev

# Run with prod flavor
flutter run --flavor prod --dart-define=ENV=prod
```

## Runtime Configuration

### Tablet App

The app can be configured at runtime through:
- Settings screen (future feature)
- System settings integration
- Configuration file in app data directory

### Companion App

The app can be configured at runtime through:
- In-app settings
- Shared preferences
- Platform-specific settings

## Network Configuration

### Firewall Rules

Ensure the following ports are open:
- TCP 8080 (WebSocket server on tablet)

### WiFi Requirements

Both devices must be on the same local network:
- Same WiFi SSID
- Same subnet (e.g., 192.168.1.x)
- No AP isolation enabled

## Security Configuration

### Development

For development builds:
- Logging enabled
- Debug information included
- Verbose error messages

### Production

For production builds:
- Logging disabled
- ProGuard/R8 enabled
- Minimal error information

## Feature Flags

Future versions may include feature flags for:
- Experimental features
- Beta testing
- A/B testing
- Gradual rollout

Example implementation:

```kotlin
// Tablet App
object FeatureFlags {
    const val ENABLE_ENCRYPTION = false
    const val ENABLE_MULTI_DEVICE = false
    const val ENABLE_CLOUD_SYNC = false
}
```

```dart
// Companion App
class FeatureFlags {
  static const bool enableEncryption = false;
  static const bool enableMultiDevice = false;
  static const bool enableCloudSync = false;
}
```

## Troubleshooting Configuration Issues

### Connection Problems

1. Verify both devices are on same network
2. Check firewall settings
3. Confirm port 8080 is not in use
4. Try manual IP entry

### Performance Issues

1. Reduce update frequency
2. Limit notification history
3. Compress file transfers
4. Enable battery optimization

### Permission Issues

1. Check Android/iOS settings
2. Reinstall app if needed
3. Verify manifest permissions
4. Request permissions at runtime

## Advanced Configuration

### Custom WebSocket Port

To change the WebSocket port:

1. In `PhoneLinkViewModel.kt`:
```kotlin
val port = 9090 // Change from 8080
```

2. Update companion app connection logic accordingly

### Custom Update Intervals

In `DeviceInfoService.dart`:
```dart
_updateTimer = Timer.periodic(
  const Duration(seconds: 60), // Change from 30
  (_) => _sendDeviceInfo(),
);
```

## Configuration Management

For managing configurations across environments:

1. Use build configurations
2. Implement configuration service
3. Load from remote config
4. Allow user customization

## Monitoring Configuration

Consider adding:
- Analytics for feature usage
- Error tracking
- Performance monitoring
- User feedback collection
