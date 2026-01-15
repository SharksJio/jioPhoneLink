# Build and Deployment Guide

This guide covers building and deploying both the Tablet and Companion apps.

## Prerequisites

### For Tablet App
- JDK 11 or higher
- Android SDK (API 26+)
- Android Studio (optional but recommended)
- Gradle 8.2+

### For Companion App
- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Android SDK (for Android builds)
- Xcode 14+ (for iOS builds, macOS only)

## Building the Tablet App

### Development Build

```bash
cd tablet-app

# Using Gradle wrapper (recommended)
./gradlew assembleDebug

# Output: app/build/outputs/apk/debug/app-debug.apk
```

### Release Build

1. **Create a keystore** (first time only):
```bash
keytool -genkey -v -keystore jio-release-key.keystore -alias jio-key-alias -keyalg RSA -keysize 2048 -validity 10000
```

2. **Create key.properties** in `tablet-app/` directory:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=jio-key-alias
storeFile=/path/to/jio-release-key.keystore
```

3. **Update app/build.gradle** to add signing config:
```gradle
android {
    signingConfigs {
        release {
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

4. **Build release APK**:
```bash
./gradlew assembleRelease

# Output: app/build/outputs/apk/release/app-release.apk
```

### Running on Device

```bash
# List connected devices
adb devices

# Install APK
adb install app/build/outputs/apk/debug/app-debug.apk

# View logs
adb logcat | grep JioPhoneLink
```

## Building the Companion App

### Development Build

```bash
cd companion-app

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Or specify device
flutter run -d <device-id>
```

### Android Release Build

```bash
# Build APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Release Build

```bash
# Build for iOS
flutter build ios --release

# Or build IPA
flutter build ipa --release

# Output: build/ios/ipa/companion-app.ipa
```

### Signing the Android App

1. **Create upload keystore**:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Reference keystore in build**:

Create `android/key.properties`:
```properties
storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

3. **Update android/app/build.gradle**:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Signing the iOS App

1. **Open in Xcode**:
```bash
open ios/Runner.xcworkspace
```

2. **Configure signing**:
   - Select the Runner project
   - Go to Signing & Capabilities
   - Select your Team
   - Xcode will automatically manage provisioning profiles

3. **Build archive**:
   - Product → Archive
   - Distribute App → App Store Connect / Ad Hoc / Enterprise

## Deployment

### Google Play Store (Companion App)

1. **Create Google Play Console account**
2. **Create new application**
3. **Upload app bundle**:
   - Go to Release → Production
   - Create new release
   - Upload `app-release.aab`
   - Complete store listing
   - Submit for review

### Apple App Store (Companion App)

1. **Create App Store Connect account**
2. **Create new app**
3. **Upload build**:
   - Use Xcode or Transporter app
   - Upload IPA file
4. **Complete app information**
5. **Submit for review**

### Direct Distribution

#### Tablet App (Android)
```bash
# Generate APK
./gradlew assembleRelease

# Share the APK file
# Users need to enable "Install from Unknown Sources"
```

#### Companion App (Android)
```bash
# Generate APK
flutter build apk --release --split-per-abi

# Output:
# - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# - build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# - build/app/outputs/flutter-apk/app-x86_64-release.apk
```

## Environment-specific Builds

### Development Environment
```bash
# Tablet App
./gradlew assembleDebug

# Companion App
flutter run --debug
```

### Staging Environment
```bash
# Use build flavors for different environments
flutter run --flavor staging --debug
./gradlew assembleStagingDebug
```

### Production Environment
```bash
# Tablet App
./gradlew assembleRelease

# Companion App
flutter build apk --release
flutter build ios --release
```

## Continuous Integration

### GitHub Actions Example

Create `.github/workflows/build.yml`:

```yaml
name: Build Apps

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up JDK 11
        uses: actions/setup-java@v3
        with:
          java-version: '11'
          distribution: 'temurin'
      
      - name: Build Tablet App
        run: |
          cd tablet-app
          ./gradlew assembleDebug
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Build Companion App
        run: |
          cd companion-app
          flutter pub get
          flutter build apk --debug

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Build Companion App iOS
        run: |
          cd companion-app
          flutter pub get
          flutter build ios --no-codesign
```

## Testing Builds

### Manual Testing Checklist

- [ ] App launches successfully
- [ ] QR code pairing works
- [ ] Notifications sync correctly
- [ ] SMS sync works
- [ ] Battery info displays
- [ ] Network info displays
- [ ] File transfer works
- [ ] Connection survives network changes
- [ ] App handles permissions correctly
- [ ] UI is responsive on different screen sizes

### Automated Testing

```bash
# Tablet App
cd tablet-app
./gradlew test

# Companion App
cd companion-app
flutter test
```

## Troubleshooting

### Common Build Issues

**Gradle build fails:**
- Clean build: `./gradlew clean`
- Check JDK version: `java -version`
- Update Gradle wrapper: `./gradlew wrapper --gradle-version 8.2`

**Flutter build fails:**
- Clean: `flutter clean`
- Get packages: `flutter pub get`
- Check Flutter: `flutter doctor`

**Signing errors:**
- Verify keystore path
- Check password correctness
- Ensure keystore file has proper permissions

### Build Performance

- Enable Gradle daemon: Add `org.gradle.daemon=true` to `gradle.properties`
- Increase heap size: `org.gradle.jvmargs=-Xmx4096m`
- Enable parallel builds: `org.gradle.parallel=true`
- Use build cache: `org.gradle.caching=true`

## Version Management

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/):
- MAJOR.MINOR.PATCH (e.g., 1.2.3)
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

### Updating Version

**Tablet App** - Update in `app/build.gradle`:
```gradle
android {
    defaultConfig {
        versionCode 2
        versionName "1.1.0"
    }
}
```

**Companion App** - Update in `pubspec.yaml`:
```yaml
version: 1.1.0+2
# Format: version_name+version_code
```

## Release Checklist

- [ ] Update version numbers
- [ ] Update CHANGELOG.md
- [ ] Run all tests
- [ ] Test on multiple devices
- [ ] Update documentation
- [ ] Create release notes
- [ ] Build signed releases
- [ ] Tag release in Git
- [ ] Upload to distribution channels

## Support

For build issues, check:
- GitHub Issues
- Android documentation
- Flutter documentation
- Stack Overflow
