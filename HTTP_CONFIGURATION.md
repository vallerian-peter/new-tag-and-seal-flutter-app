# HTTP Configuration for Local Development

## Overview
This document explains how the app is configured to use HTTP (non-HTTPS) connections for local development with the Laravel backend.

## Platform-Specific Configuration

### Android
- **Emulator URL**: `http://10.0.2.2:8000/api`
  - Android emulator uses `10.0.2.2` as a special alias to access the host machine's `127.0.0.1`
  - This allows the emulator to connect to your Laravel backend running on localhost

- **Configuration**: `android/app/src/main/AndroidManifest.xml`
  ```xml
  <application
      android:usesCleartextTraffic="true"
      ...>
  ```
  - `android:usesCleartextTraffic="true"` allows HTTP connections (required for Android 9+)

### iOS
- **Simulator URL**: `http://127.0.0.1:8000/api`
  - iOS simulator can directly access the host machine's localhost

- **Configuration**: `ios/Runner/Info.plist`
  ```xml
  <key>NSAppTransportSecurity</key>
  <dict>
      <key>NSAllowsArbitraryLoads</key>
      <true/>
      <key>NSAllowsLocalNetworking</key>
      <true/>
  </dict>
  ```
  - `NSAllowsArbitraryLoads` allows all HTTP connections
  - `NSAllowsLocalNetworking` specifically allows local network HTTP connections

### macOS
- **URL**: `http://127.0.0.1:8000/api`
- **Configuration**: `macos/Runner/Info.plist` (same as iOS)

## Code Implementation

The base URL is dynamically determined based on the platform in `lib/core/global-sync/endpoints.dart`:

```dart
static final String baseUrl = _getBaseUrl();

static String _getBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000/api';
  } else if (Platform.isIOS || Platform.isMacOS) {
    return 'http://127.0.0.1:8000/api';
  } else {
    return 'http://localhost:8000/api';
  }
}
```

## Testing Physical Devices

For testing on **physical devices** (not emulators/simulators):

1. Find your computer's local IP address:
   - **macOS/Linux**: Run `ifconfig` or `ip addr`
   - **Windows**: Run `ipconfig`
   - Look for something like `192.168.x.x`

2. Update the URL in `endpoints.dart` to use your machine's IP:
   ```dart
   return 'http://192.168.1.100:8000/api'; // Replace with your IP
   ```

3. Ensure:
   - Your phone and computer are on the same WiFi network
   - Your Laravel backend is accessible on the network (use `php artisan serve --host=0.0.0.0`)
   - Your firewall allows connections on port 8000

## Production Deployment

**⚠️ IMPORTANT**: Before releasing to production:

1. Change the base URL to your production HTTPS server:
   ```dart
   return 'https://your-domain.com/api';
   ```

2. Remove or restrict the cleartext traffic permissions:
   - Android: Remove `android:usesCleartextTraffic="true"`
   - iOS/macOS: Remove the `NSAppTransportSecurity` configuration or restrict it

3. Use environment-based configuration:
   ```dart
   static String _getBaseUrl() {
     const isProduction = bool.fromEnvironment('dart.vm.product');
     if (isProduction) {
       return 'https://your-domain.com/api';
     }
     // Development URLs...
   }
   ```

## Troubleshooting

### Android Emulator Connection Issues
- Verify your Laravel server is running: `php artisan serve`
- Try accessing `http://10.0.2.2:8000/api` in the emulator's browser
- Check if `android:usesCleartextTraffic="true"` is in your manifest

### iOS Simulator Connection Issues
- Verify `NSAppTransportSecurity` settings in `Info.plist`
- Try accessing `http://127.0.0.1:8000/api` in Safari on the simulator
- Restart the simulator after changing `Info.plist`

### Physical Device Connection Issues
- Ensure both devices are on the same network
- Use your computer's IP address instead of localhost
- Check firewall settings
- Test the URL in the device's browser first

## Security Note

HTTP connections are only suitable for local development. Always use HTTPS in production to ensure:
- Data encryption in transit
- Protection against man-in-the-middle attacks
- Compliance with app store security requirements

