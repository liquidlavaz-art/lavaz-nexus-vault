# Lavaz Unified Nexus & Vault - Android APK

This is a native Android application wrapper for the Lavaz Unified Nexus & Vault HTML/CSS/JS interface, rendered in a WebView.

## Project Structure

```
lavaz-nexus-vault/
├── app/                           # Main Android app module
│   ├── src/main/
│   │   ├── java/com/lavaz/nexusvault/
│   │   │   ├── MainActivity.kt                 # Entry point activity
│   │   │   ├── LavazWebViewClient.kt          # WebView client handling
│   │   │   └── LavazWebChromeClient.kt        # Chrome client for JS alerts, etc
│   │   ├── res/
│   │   │   ├── layout/activity_main.xml       # Main layout (WebView)
│   │   │   ├── values/                        # String resources, colors, themes
│   │   │   ├── xml/                           # Backup and data extraction rules
│   │   │   └── raw/index.html                 # HTML content (embedded)
│   │   └── AndroidManifest.xml                # App manifest
│   ├── build.gradle                           # App module build config
│   └── proguard-rules.pro                     # Code obfuscation rules
├── build.gradle                               # Root build config
├── settings.gradle                            # Gradle settings
└── README.md                                  # This file
```

## Building the APK

### Prerequisites

- Android Studio (latest) or Android SDK tools
- JDK 11 or later
- Gradle 8.0+

### Steps to Build

#### Option 1: Using Android Studio

1. Clone the repository: `git clone https://github.com/liquidlavaz-art/lavaz-nexus-vault.git`
2. Open Android Studio → File → Open → Select this project
3. Wait for Gradle sync to complete
4. Connect an Android device or start an emulator
5. Run → Run 'app' (or press Shift+F10)

#### Option 2: Using Command Line

```bash
# Debug APK
./gradlew assembleDebug
# Output: app/build/outputs/apk/debug/app-debug.apk

# Release APK (requires keystore signing)
./gradlew assembleRelease
# Output: app/build/outputs/apk/release/app-release.apk
```

#### Option 3: Building APK Bundle

```bash
# Generate AAB for Play Store
./gradlew bundleRelease
# Output: app/build/outputs/bundle/release/app-release.aab
```

### Signing the Release APK

1. Generate a keystore:
```bash
keytool -genkey -v -keystore ~/my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

2. Update `app/build.gradle` with keystore info or sign after build:
```bash
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore ~/my-release-key.jks \
  app/build/outputs/apk/release/app-release-unsigned.apk \
  my-key-alias
```

3. Align the APK:
```bash
zipalign -v 4 app-release-unsigned.apk app-release.apk
```

## Features

✅ Offline-first design
✅ Neumorphic UI with Material 3 styling
✅ WebView rendering of HTML/CSS/JS interface
✅ Kotlin + AndroidX
✅ JavaScript bridge support (ready for future enhancements)
✅ Proguard obfuscation for release builds
✅ Safe cleartext traffic disabled
✅ Full screen support with notch awareness

## Configuration

- **Minimum SDK**: 24 (Android 7.0 Nougat)
- **Target SDK**: 34 (Android 14)
- **App ID**: `com.lavaz.nexusvault`
- **Version**: 1.0.0

## Testing

### Manual Testing Checklist

- [ ] App launches without crashes
- [ ] WebView renders HTML correctly
- [ ] Quick capture button works
- [ ] Navigation between tabs works
- [ ] Back button navigates properly
- [ ] JavaScript console logs are visible
- [ ] Responsive layout works on different screen sizes

### Running Tests

```bash
# Unit tests
./gradlew test

# Instrumented tests on device
./gradlew connectedAndroidTest
```

## JavaScript Bridge (Ready for Enhancement)

The WebView is configured to allow JavaScript. You can add a bridge to call native Android code:

```kotlin
// In MainActivity.kt
webView.addJavascriptInterface(NativeInterface(this), "Android")

// In HTML/JS
Android.showToast("Hello from WebView!");
```

## Troubleshooting

### APK won't build
- Clear cache: `./gradlew clean`
- Check JDK version: `java -version` (should be 11+)
- Sync Gradle: Android Studio → File → Sync Now

### WebView not loading content
- Check AndroidManifest.xml permissions
- Verify `raw/index.html` exists in resources
- Check logcat for errors

### App crashes on launch
- Review logcat: `adb logcat | grep "com.lavaz"`
- Check WebView hardware acceleration settings
- Verify all required permissions are granted

## Distribution

### Google Play Store
1. Build release AAB: `./gradlew bundleRelease`
2. Create Play Store account and app listing
3. Upload AAB under Internal Test or Beta channel
4. Fill metadata (screenshots, description, privacy policy)
5. Submit for review

### Direct APK Distribution
- Upload debug/release APK to GitHub Releases
- Users can sideload: `adb install app-release.apk`

## License

Proprietary - Lavaz Unified Nexus & Vault

## Author

@liquidlavaz-art
