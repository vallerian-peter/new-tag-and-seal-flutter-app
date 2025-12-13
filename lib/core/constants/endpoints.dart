// API Endpoints Configuration
// This file contains all API endpoint constants for the Tag and Seal application.
// Base URL should be configured based on environment (development, staging, production).

import 'dart:io';

class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  /// Base URL for the API
  /// - Android Emulator: Use 10.0.2.2 to access host machine's localhost
  /// - iOS Simulator/Physical devices: Use 127.0.0.1 or your machine's IP address
  /// - Production: Replace with your actual server URL
  static final String baseUrl = _getBaseUrl();
  
  static String _getBaseUrl() {
    // if (Platform.isAndroid) {
    //   // Android emulator uses 10.0.2.2 to access host machine's localhost
    //   return 'http://10.0.2.2:8000/api';
    // } else if (Platform.isIOS || Platform.isMacOS) {
    //   // iOS simulator and macOS can use 127.0.0.1
    //   return 'http://127.0.0.1:8000/api';
    // } else {
    //   // Fallback for other platforms
    //   return 'http://localhost:8000/api';
    // }
    
    return 'http://45.77.1.62:8000/api';
  }
  
  /// Farmer module base path
  static String get farmerBase => '$baseUrl/v1/farmers';
  
  /// Extension Officer Farm Invite endpoints
  static String get extensionOfficerInviteSearch => '$farmerBase/extension-officer-invites/search';
  static String get extensionOfficerInviteCreate => '$farmerBase/extension-officer-invites';
  
  // ============================================================================
  // PUBLIC ENDPOINTS (No Authentication Required)
// ============================================================================
  
  // ----------------------------------------------------------------------------
  // Authentication Endpoints (Public)
  // ----------------------------------------------------------------------------
  
  /// Auth module base path
  static String get authBase => '$baseUrl/auth';
  
  /// Register a new user account (POST request)
  static String get register => '$authBase/register';
  
  /// Login with username/email and password (POST request)
  static String get login => '$authBase/login';

  // ----------------------------------------------------------------------------
  // Sync Endpoints (Public)
  // ----------------------------------------------------------------------------
  
  /// Initial registration sync - Get reference data for registration (GET request, no auth)
  static String get initialRegisterSync => '$baseUrl/v1/sync/initial-register';

  // ============================================================================
  // PROTECTED ENDPOINTS (Authentication Required)
  // ============================================================================
  
  // ----------------------------------------------------------------------------
  // Authentication Endpoints (Protected)
  // ----------------------------------------------------------------------------
  
  /// Logout from current device (POST request, requires auth)
  static String get logout => '$authBase/logout';
  
  /// Logout from all devices (POST request, requires auth)
  static String get logoutAll => '$authBase/logout-all';
  
  /// Get user profile (GET request, requires auth)
  static String get profile => '$authBase/profile';
  
  /// Update user profile (PUT request, requires auth)
  static String get updateProfile => '$authBase/profile';
  
  /// Change user password (POST request, requires auth)
  static String get changePassword => '$authBase/change-password';

  // ----------------------------------------------------------------------------
  // User Endpoints
  // ----------------------------------------------------------------------------
  
  /// Get current user info (GET request, requires auth)
  static String get currentUser => '$baseUrl/v1/user';

  // ============================================================================
  // SYNC ENDPOINTS (Shared - All Authenticated Roles)
  // ============================================================================

  // ----------------------------------------------------------------------------
  // Sync Endpoints (Protected)
  // ----------------------------------------------------------------------------
  
  /// Splash sync - Get all data on app startup based on user role (GET request, requires auth)
  /// Usage: ${ApiEndpoints.splashSyncAll}/{userId}
  /// Accessible by: Farmers, Extension Officers, Vets, Farm Invited Users, System Users
  static String get splashSyncAll => '$baseUrl/v1/sync/splash-sync-all';
  
  /// Full Sync Post Data - Send unsynced data to server (POST request, requires auth)
  /// Usage: ${ApiEndpoints.fullSyncPostData}/{userId}
  /// Accessible by: Farmers, Extension Officers, Vets, Farm Invited Users, System Users
  static String get fullSyncPostData => '$baseUrl/v1/sync/full-post-sync';

  // ============================================================================
  // LEGACY ENDPOINTS (Deprecated - For Backward Compatibility)
  // ============================================================================
  
  /// @deprecated Use [login] instead
  static String get farmerLogin => '$authBase/login';
  
  /// @deprecated Use [register] instead
  static String get farmerRegister => '$authBase/register';
  
  /// @deprecated Use [logout] instead
  static String get farmerLogout => '$authBase/logout';
}
