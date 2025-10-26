import 'package:geolocator/geolocator.dart';
import 'dart:developer';

/// Location Service for handling GPS operations
/// 
/// Provides methods to:
/// - Check and request location permissions
/// - Check if location services are enabled
/// - Get current device location (latitude & longitude)
class LocationService {
  
  /// Check if location services are enabled on the device
  /// 
  /// Returns true if GPS is turned on, false otherwise
  static Future<bool> isLocationServiceEnabled() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      log('📍 Location Service Enabled: $serviceEnabled');
      return serviceEnabled;
    } catch (e) {
      log('❌ Error checking location service: $e');
      return false;
    }
  }
  
  /// Check current location permission status
  /// 
  /// Returns the current LocationPermission status:
  /// - denied: Permission not granted
  /// - deniedForever: User permanently denied permission
  /// - whileInUse: Permission granted while app is in use
  /// - always: Permission granted always
  static Future<LocationPermission> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      log('📍 Location Permission: $permission');
      return permission;
    } catch (e) {
      log('❌ Error checking permission: $e');
      return LocationPermission.denied;
    }
  }
  
  /// Request location permission from the user
  /// 
  /// Shows the system permission dialog.
  /// Returns the permission status after user's choice.
  static Future<LocationPermission> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      log('📍 Location Permission Requested: $permission');
      return permission;
    } catch (e) {
      log('❌ Error requesting permission: $e');
      return LocationPermission.denied;
    }
  }
  
  /// Get current device location with permission and service checks
  /// 
  /// **Flow:**
  /// 1. Check if location service is enabled
  /// 2. Check current permission status
  /// 3. Request permission if denied
  /// 4. Get current position
  /// 
  /// **Returns:** Position object with latitude, longitude, accuracy, etc.
  /// **Throws:** Exception if location cannot be retrieved
  static Future<Position> getCurrentLocation() async {
    try {
      log('🔄 Getting current location...');
      
      // 1. Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('❌ Location services are disabled');
        throw Exception('Location services are disabled. Please enable GPS in settings.');
      }
      
      // 2. Check permission
      LocationPermission permission = await checkPermission();
      
      // 3. Request permission if denied
      if (permission == LocationPermission.denied) {
        log('⚠️ Permission denied - requesting...');
        permission = await requestPermission();
        
        if (permission == LocationPermission.denied) {
          log('❌ Permission denied by user');
          throw Exception('Location permission denied. Please grant permission in app settings.');
        }
      }
      
      // 4. Check if permission is permanently denied
      if (permission == LocationPermission.deniedForever) {
        log('❌ Permission denied forever');
        throw Exception('Location permission permanently denied. Please enable in device settings.');
      }
      
      // 5. Get current position
      log('🔄 Fetching GPS coordinates...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      
      log('✅ Location retrieved: ${position.latitude}, ${position.longitude}');
      return position;
      
    } catch (e) {
      log('❌ Error getting location: $e');
      rethrow;
    }
  }
  
  /// Get current location with simplified error handling
  /// 
  /// Returns a map with latitude and longitude, or null if failed.
  /// Use this for simple cases where you don't need detailed error handling.
  static Future<Map<String, double>?> getCurrentLocationSimple() async {
    try {
      final position = await getCurrentLocation();
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      log('❌ Failed to get location: $e');
      return null;
    }
  }
  
  /// Open device location settings
  /// 
  /// Opens the system settings page where user can enable location services
  /// or grant location permissions.
  static Future<bool> openLocationSettings() async {
    try {
      final opened = await Geolocator.openLocationSettings();
      log('📍 Location settings opened: $opened');
      return opened;
    } catch (e) {
      log('❌ Error opening location settings: $e');
      return false;
    }
  }
  
  /// Open app-specific settings
  /// 
  /// Opens the app's settings page in device settings where user can
  /// manually grant permissions.
  static Future<bool> openAppSettings() async {
    try {
      final opened = await Geolocator.openAppSettings();
      log('📍 App settings opened: $opened');
      return opened;
    } catch (e) {
      log('❌ Error opening app settings: $e');
      return false;
    }
  }
  
  /// Calculate distance between two coordinates
  /// 
  /// Returns distance in meters between two geographic points.
  /// 
  /// Example:
  /// ```dart
  /// final distance = LocationService.calculateDistance(
  ///   startLat: -6.7924,
  ///   startLng: 39.2083,
  ///   endLat: -6.8000,
  ///   endLng: 39.2500,
  /// );
  /// print('Distance: ${distance}m');
  /// ```
  static double calculateDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}

