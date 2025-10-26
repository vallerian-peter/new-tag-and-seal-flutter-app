import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// NetworkCheck
/// 
/// A singleton service for checking network connectivity status.
/// Provides both real-time monitoring and one-time checks.
/// 
/// Features:
/// - Singleton pattern for global access
/// - Stream-based connectivity monitoring
/// - Actual internet connectivity verification (not just WiFi/Mobile data)
/// - Platform-independent implementation
/// - Error handling and fallback mechanisms
/// 
/// Usage:
/// ```dart
/// // Get instance
/// final networkCheck = NetworkCheck.instance;
/// 
/// // Check if connected
/// bool isConnected = await networkCheck.isConnected;
/// 
/// // Listen to connectivity changes
/// networkCheck.onConnectivityChanged.listen((isConnected) {
///   if (isConnected) {
///     print('Internet connection available');
///   } else {
///     print('No internet connection');
///   }
/// });
/// ```
class NetworkCheck {
  // Private constructor for singleton
  NetworkCheck._();
  
  /// Singleton instance
  static final NetworkCheck _instance = NetworkCheck._();
  
  /// Get singleton instance
  static NetworkCheck get instance => _instance;
  
  // ============================================================================
  // Dependencies
  // ============================================================================
  
  /// Connectivity plugin instance
  final Connectivity _connectivity = Connectivity();
  
  /// Stream controller for connectivity changes
  final StreamController<bool> _connectivityController = 
      StreamController<bool>.broadcast();
  
  /// Last known connectivity status
  bool _isConnected = false;
  
  /// Subscription to connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  // ============================================================================
  // Configuration
  // ============================================================================
  
  /// Timeout duration for internet check
  static const Duration _checkTimeout = Duration(seconds: 10);
  
  /// Host to check for internet connectivity
  /// Using Google's DNS as it's reliable and fast
  static const String _checkHost = '8.8.8.8';
  
  /// Port to check
  static const int _checkPort = 53;
  
  // ============================================================================
  // Public API
  // ============================================================================
  
  /// Check if device has internet connection
  /// 
  /// Returns true if connected, false otherwise.
  /// This performs an actual internet check, not just WiFi/Mobile data status.
  Future<bool> get isConnected async {
    try {
      // First check connectivity status
      final connectivityResult = await _connectivity.checkConnectivity();
      
      // If no connectivity (none), return false immediately
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _isConnected = false;
        return false;
      }
      
      // If we have connectivity (WiFi/Mobile), verify actual internet access
      final hasInternet = await _checkInternetConnection();
      _isConnected = hasInternet;
      
      return hasInternet;
    } catch (e) {
      debugPrint('NetworkCheck: Error checking connection - $e');
      _isConnected = false;
      return false;
    }
  }
  
  /// Get current connectivity status synchronously
  /// 
  /// Returns the last known connectivity status.
  /// For real-time status, use [isConnected] or [onConnectivityChanged].
  bool get currentStatus => _isConnected;
  
  /// Stream of connectivity changes
  /// 
  /// Emits true when internet connection is available,
  /// false when internet connection is lost.
  /// 
  /// Example:
  /// ```dart
  /// NetworkCheck.instance.onConnectivityChanged.listen((isConnected) {
  ///   if (isConnected) {
  ///     // Handle connected state
  ///   } else {
  ///     // Handle disconnected state
  ///   }
  /// });
  /// ```
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;
  
  // ============================================================================
  // Lifecycle Management
  // ============================================================================
  
  /// Initialize network monitoring
  /// 
  /// Call this once at app startup to begin monitoring connectivity changes.
  /// This will emit events on [onConnectivityChanged] stream.
  Future<void> initialize() async {
    // Get initial connectivity status
    _isConnected = await isConnected;
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        await _handleConnectivityChange(results);
      },
      onError: (error) {
        debugPrint('NetworkCheck: Connectivity stream error - $error');
        _connectivityController.add(false);
      },
    );
    
    debugPrint('NetworkCheck: Initialized with status: $_isConnected');
  }
  
  /// Dispose resources
  /// 
  /// Call this when the app is closing or when you no longer need
  /// network monitoring to free up resources.
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _connectivityController.close();
    debugPrint('NetworkCheck: Disposed');
  }
  
  // ============================================================================
  // Private Methods
  // ============================================================================
  
  /// Handle connectivity change events
  Future<void> _handleConnectivityChange(List<ConnectivityResult> results) async {
    try {
      // Check if we have any connectivity
      final hasConnectivity = !results.contains(ConnectivityResult.none);
      
      if (!hasConnectivity) {
        // No connectivity at all
        _isConnected = false;
        _connectivityController.add(false);
        return;
      }
      
      // We have connectivity (WiFi/Mobile), verify actual internet access
      final hasInternet = await _checkInternetConnection();
      
      // Only emit if status changed
      if (_isConnected != hasInternet) {
        _isConnected = hasInternet;
        _connectivityController.add(hasInternet);
        debugPrint('NetworkCheck: Connectivity changed to: $hasInternet');
      }
    } catch (e) {
      debugPrint('NetworkCheck: Error handling connectivity change - $e');
      _connectivityController.add(false);
    }
  }
  
  /// Check actual internet connection by attempting to reach a host
  /// 
  /// This verifies that the device can actually access the internet,
  /// not just that WiFi/Mobile data is enabled.
  Future<bool> _checkInternetConnection() async {
    try {
      // Try to lookup the host
      final result = await InternetAddress.lookup(_checkHost)
          .timeout(_checkTimeout);
      
      // Check if we got a valid response
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      
      return false;
    } on SocketException catch (_) {
      // Socket exception means no internet
      return false;
    } on TimeoutException catch (_) {
      // Timeout means slow or no internet
      return false;
    } catch (e) {
      // Any other error, assume no internet
      debugPrint('NetworkCheck: Internet check error - $e');
      return false;
    }
  }
  
  // ============================================================================
  // Utility Methods
  // ============================================================================
  
  /// Get detailed connectivity information
  /// 
  /// Returns a map with connectivity details including:
  /// - hasInternet: bool
  /// - connectivityType: String (wifi, mobile, ethernet, none)
  Future<Map<String, dynamic>> getConnectivityDetails() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final hasInternet = await isConnected;
      
      // Get primary connectivity type
      String connectivityType = 'none';
      if (connectivityResults.contains(ConnectivityResult.wifi)) {
        connectivityType = 'wifi';
      } else if (connectivityResults.contains(ConnectivityResult.mobile)) {
        connectivityType = 'mobile';
      } else if (connectivityResults.contains(ConnectivityResult.ethernet)) {
        connectivityType = 'ethernet';
      }
      
      return {
        'hasInternet': hasInternet,
        'connectivityType': connectivityType,
        'connectivityResults': connectivityResults.map((r) => r.name).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('NetworkCheck: Error getting connectivity details - $e');
      return {
        'hasInternet': false,
        'connectivityType': 'none',
        'connectivityResults': [],
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Check if connected via WiFi
  Future<bool> get isWiFi async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }
  
  /// Check if connected via Mobile data
  Future<bool> get isMobile async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }
  
  /// Check if connected via Ethernet
  Future<bool> get isEthernet async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.ethernet);
  }
}

