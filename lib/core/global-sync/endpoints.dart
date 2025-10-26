// API Endpoints Configuration
// This file contains all API endpoint constants for the Tag and Seal application.
// Base URL should be configured based on environment (development, staging, production).

class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  /// Base URL for the API
  static const String baseUrl = 'http://localhost:8000/api';
  /// Farmer module base path
  static const String farmerBase = '$baseUrl/v1/farmers';
  
  // ============================================================================
  // PUBLIC ENDPOINTS (No Authentication Required)
  // ============================================================================
  
  // ----------------------------------------------------------------------------
  // Authentication Endpoints (Public)
  // ----------------------------------------------------------------------------
  
  /// Auth module base path
  static const String authBase = '$baseUrl/auth';
  
  /// Register a new user account (POST request)
  static const String register = '$authBase/register';
  
  /// Login with username/email and password (POST request)
  static const String login = '$authBase/login';

  // ----------------------------------------------------------------------------
  // Sync Endpoints (Public)
  // ----------------------------------------------------------------------------
  
  /// Initial registration sync - Get reference data for registration (GET request, no auth)
  static const String initialRegisterSync = '$baseUrl/v1/sync/initial-register';

  // ============================================================================
  // PROTECTED ENDPOINTS (Authentication Required)
  // ============================================================================
  
  // ----------------------------------------------------------------------------
  // Authentication Endpoints (Protected)
  // ----------------------------------------------------------------------------
  
  /// Logout from current device (POST request, requires auth)
  static const String logout = '$authBase/logout';
  
  /// Logout from all devices (POST request, requires auth)
  static const String logoutAll = '$authBase/logout-all';
  
  /// Get user profile (GET request, requires auth)
  static const String profile = '$authBase/profile';
  
  /// Change user password (POST request, requires auth)
  static const String changePassword = '$authBase/change-password';

  // ----------------------------------------------------------------------------
  // User Endpoints
  // ----------------------------------------------------------------------------
  
  /// Get current user info (GET request, requires auth)
  static const String currentUser = '$baseUrl/v1/user';

  // ============================================================================
  // FARMER ENDPOINTS (Requires Farmer or System User Role)
  // ============================================================================

  // ----------------------------------------------------------------------------
  // Farmer Sync Endpoints
  // ----------------------------------------------------------------------------
  
  /// Splash sync - Get all data on app startup (GET request, requires auth)
  /// Usage: ${ApiEndpoints.splashSyncAll}/{userId}
  static const String splashSyncAll = '$farmerBase/sync/splash-sync-all';
  
  /// Full Sync Post Data - Send unsynced data to server (POST request, requires auth)
  /// Usage: ${ApiEndpoints.fullSyncPostData}/{userId}
  static const String fullSyncPostData = '$farmerBase/sync/full-post-sync';

  // ============================================================================
  // LEGACY ENDPOINTS (Deprecated - For Backward Compatibility)
  // ============================================================================
  
  /// @deprecated Use [login] instead
  static const String farmerLogin = '$authBase/login';
  
  /// @deprecated Use [register] instead
  static const String farmerRegister = '$authBase/register';
  
  /// @deprecated Use [logout] instead
  static const String farmerLogout = '$authBase/logout';
}
