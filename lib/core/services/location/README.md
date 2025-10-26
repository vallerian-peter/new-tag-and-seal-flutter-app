# Location Service

A comprehensive GPS location service for the Tag & Seal Flutter app with automatic permission handling and error management.

## 📁 Structure

```
lib/core/services/location/
└── location_service.dart    # Main location service
```

## 🎯 Features

- ✅ Get current GPS coordinates (latitude & longitude)
- ✅ Automatic permission request handling
- ✅ Check if location services are enabled
- ✅ Open device location settings
- ✅ Open app-specific settings
- ✅ Calculate distance between coordinates
- ✅ Comprehensive error handling
- ✅ Logging for debugging

## 📦 Dependencies

```yaml
dependencies:
  geolocator: ^13.0.2
  permission_handler: ^11.3.1
```

## 🔧 Setup

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Location Permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <application>
        ...
    </application>
</manifest>
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to automatically fill farm coordinates using GPS.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to your location to automatically fill farm coordinates using GPS.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location to automatically fill farm coordinates using GPS.</string>
```

## 💻 Usage

### Basic Usage

```dart
import 'package:new_tag_and_seal_flutter_app/core/services/location/location_service.dart';

// Get current location
try {
  final position = await LocationService.getCurrentLocation();
  print('Latitude: ${position.latitude}');
  print('Longitude: ${position.longitude}');
  print('Accuracy: ${position.accuracy}m');
} catch (e) {
  print('Error: $e');
}
```

### Simplified Usage

```dart
// Returns a map or null
final coords = await LocationService.getCurrentLocationSimple();
if (coords != null) {
  print('Lat: ${coords['latitude']}, Lng: ${coords['longitude']}');
}
```

### With UI Component

```dart
import 'package:new_tag_and_seal_flutter_app/core/components/gps_location_button.dart';

// In your widget:
GpsLocationButton(
  onLocationFetched: (latitude, longitude) {
    setState(() {
      latitudeController.text = latitude.toStringAsFixed(6);
      longitudeController.text = longitude.toStringAsFixed(6);
    });
  },
)
```

## 🔄 Permission Flow

1. **Check if GPS is enabled** → If not, throw error
2. **Check current permission** → Get status
3. **Request permission if denied** → Show system dialog
4. **Handle permanently denied** → Suggest opening settings
5. **Fetch GPS coordinates** → Return Position object

## 🎯 Methods

### `isLocationServiceEnabled()`
Check if GPS is turned on.

```dart
final enabled = await LocationService.isLocationServiceEnabled();
if (!enabled) {
  // Show message to enable GPS
}
```

### `checkPermission()`
Get current permission status.

```dart
final permission = await LocationService.checkPermission();
// Returns: denied, deniedForever, whileInUse, always
```

### `requestPermission()`
Request location permission from user.

```dart
final permission = await LocationService.requestPermission();
if (permission == LocationPermission.denied) {
  // Handle denial
}
```

### `getCurrentLocation()`
Get current GPS position with automatic permission handling.

```dart
try {
  final position = await LocationService.getCurrentLocation();
  final lat = position.latitude;
  final lng = position.longitude;
  final accuracy = position.accuracy;
} catch (e) {
  // Handle errors:
  // - "Location services are disabled..."
  // - "Location permission denied..."
  // - "Location permission permanently denied..."
}
```

### `openLocationSettings()`
Open device location settings.

```dart
await LocationService.openLocationSettings();
```

### `openAppSettings()`
Open app-specific settings.

```dart
await LocationService.openAppSettings();
```

### `calculateDistance()`
Calculate distance between two points.

```dart
final distance = LocationService.calculateDistance(
  startLat: -6.7924,
  startLng: 39.2083,
  endLat: -6.8000,
  endLng: 39.2500,
);
print('Distance: ${distance}m'); // in meters
```

## 🚨 Error Messages

The service throws clear error messages:

- `"Location services are disabled. Please enable GPS in settings."`
- `"Location permission denied. Please grant permission in app settings."`
- `"Location permission permanently denied. Please enable in device settings."`

## 🎨 UI Component

### GpsLocationButton

A pre-built button component that handles the entire flow:

**Features:**
- ✅ Shows loading state while fetching
- ✅ Displays success/error messages
- ✅ Offers "Settings" action on errors
- ✅ Fully localized (English & Swahili)
- ✅ Auto-fills form fields via callback

**Usage in Form:**
```dart
GpsLocationButton(
  onLocationFetched: (latitude, longitude) {
    // Auto-fill form fields
    latController.text = latitude.toStringAsFixed(6);
    lngController.text = longitude.toStringAsFixed(6);
  },
)
```

## 📍 Example: Farm Form Integration

```dart
// Step 2: GPS Coordinates
_buildSectionTitle(l10n.gpsCoordinates),
const SizedBox(height: 20),

// GPS auto-fill button
GpsLocationButton(
  onLocationFetched: (lat, lng) {
    setState(() {
      _latitudesController.text = lat.toStringAsFixed(6);
      _longitudesController.text = lng.toStringAsFixed(6);
    });
  },
),

const SizedBox(height: 16),

// Manual input fields
CustomTextField(controller: _latitudesController, ...),
CustomTextField(controller: _longitudesController, ...),
```

## ✅ Best Practices

1. **Always handle errors** - GPS may fail for many reasons
2. **Provide fallback** - Allow manual coordinate input
3. **Show loading states** - GPS can take several seconds
4. **Guide users** - Clear messages when permissions needed
5. **Test on real devices** - GPS doesn't work on simulators

## 🐛 Debugging

Check console logs for detailed information:

```
📍 Location Service Enabled: true
📍 Location Permission: LocationPermission.whileInUse
🔄 Fetching GPS coordinates...
✅ Location retrieved: -6.7924, 39.2083
```

## 📱 Testing

**On Real Device:**
- ✅ GPS fetching works
- ✅ Permission dialogs show
- ✅ Coordinates are accurate

**On Simulator/Emulator:**
- ⚠️ GPS may not work
- ⚠️ Use test coordinates
- ⚠️ Permission flows may differ


