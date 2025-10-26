import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/data/local/auth_repositoy.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/domain/models/farmer_model.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/error_helper.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

/// Auth Provider
/// 
/// Manages authentication state and provides methods for UI interaction.
/// This is the connection layer between the UI and the repository.
/// 
/// Responsibilities:
/// - Manage loading states
/// - Handle errors and show dialogs
/// - Notify UI of state changes
/// - Provide authentication methods to UI
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  // ==========================================================================
  // Constructor
  // ==========================================================================

  AuthProvider({required AuthRepository authRepository, required repository})
      : _authRepository = authRepository;

  // ==========================================================================
  // State Variables
  // ==========================================================================

  /// Loading state for registration
  bool _isRegisteringFarmer = false;
  bool get isRegisteringFarmer => _isRegisteringFarmer;

  /// Loading state for login
  bool _isLoggingIn = false;
  bool get isLoggingIn => _isLoggingIn;

  /// Loading state for logout
  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;

  /// Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Current logged in user data
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Current logged in farmer data
  FarmerModel? _currentFarmer;
  FarmerModel? get currentFarmer => _currentFarmer;

  /// Authentication status
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // ==========================================================================
  // Registration
  // ==========================================================================

  /// Register a new farmer
  /// 
  /// Shows loading dialog, calls repository, handles success/error.
  /// Automatically navigates and shows appropriate dialogs.
  /// 
  /// Example:
  /// ```dart
  /// final success = await authProvider.registerFarmer(
  ///   context: context,
  ///   farmerData: formData,
  /// );
  /// ```
  Future<bool> registerFarmer({
    required BuildContext context,
    required Map<String, dynamic> farmerData,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    // Show loading dialog
    AlertDialogs.showLoading(
      context: context,
      title: l10n.register,
      message: l10n.creatingAccount,
      isDismissible: false,
    );

    // Set loading state
    _isRegisteringFarmer = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('🔐 DEBUG: Registering farmer: $farmerData');
      
      // Call repository to register farmer
      final farmer = await _authRepository.registerFarmer(farmerData);

      log('🔐 DEBUG: Farmer registered: $farmer');
      
      // Update state
      _currentFarmer = farmer;
      _isAuthenticated = true;
      _isRegisteringFarmer = false;
      notifyListeners();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show success dialog
      if (context.mounted) {
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.registrationSuccessful,
          buttonText: l10n.continueText,
        );
      }

      return true;
    } catch (e) {
      // Update error state
      log('🔐 DEBUG: Error registering farmer: $e');
      _isRegisteringFarmer = false;
      notifyListeners();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show user-friendly error dialog
      if (context.mounted) {
        final errorMessage = ErrorHelper.formatErrorMessage(e.toString(), l10n);
        final errorTitle = ErrorHelper.getErrorTitle(e.toString(), l10n);
        
        await AlertDialogs.showError(
          context: context,
          title: errorTitle,
          message: errorMessage,
          buttonText: l10n.tryAgain,
        );
      }

      return false;
    }
  }

  // ==========================================================================
  // Login
  // ==========================================================================

  /// Login user with username and password
  /// 
  /// Shows loading dialog, calls repository, handles success/error.
  /// Stores user data, profile, and token in secure storage on success.
  /// 
  /// Example:
  /// ```dart
  /// final success = await authProvider.login(
  ///   context: context,
  ///   username: 'john_doe',
  ///   password: 'securepass123',
  /// );
  /// ```
  Future<bool> login({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    // Show loading dialog
    AlertDialogs.showLoading(
      context: context,
      title: l10n.login,
      message: l10n.loggingIn,
      isDismissible: false,
    );

    // Set loading state
    _isLoggingIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call repository to login
      final loginData = await _authRepository.login(
        username: username,
        password: password,
      );

      // Extract response data
      final user = loginData['user'] as Map<String, dynamic>?;
      final profile = loginData['profile'];
      final accessToken = loginData['accessToken'] as String?;
      final tokenType = loginData['tokenType'] as String?;

      // Update state
      _currentUser = user;
      _isAuthenticated = true;
      _isLoggingIn = false;

      // Store all data in secure storage (using camelCase keys)
      if (user != null) {
        await _authRepository.storeUserData(
          userId: user['id']?.toString() ?? '',
          username: user['username'] ?? '',
          email: user['email'] ?? '',
          role: user['role'] ?? '',
          roleId: user['roleId']?.toString() ?? '1',
          firstname: user['firstname'] ?? '',
          surname: user['surname'] ?? '',
          phone1: user['phone1'] ?? '',
          physicalAddress: user['physicalAddress'] ?? '',
          dateOfBirth: user['dateOfBirth'] ?? '',
          gender: user['gender'] ?? '',
          accessToken: accessToken ?? '',
          tokenType: tokenType ?? 'Bearer',
          password: user['password'] ?? user['email'] ?? '',
          profile: profile,
        );
      }

      // Load farmer data if user is a farmer
      if (_currentUser?['role'] == 'farmer') {
        _currentFarmer = await _authRepository.getCurrentFarmer();
      }

      notifyListeners();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      return true;
    } catch (e) {
      log('❌ Error logging in: ${e.toString()}');

      _isLoggingIn = false;
      notifyListeners();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show user-friendly error dialog
      if (context.mounted) {
        final errorMessage = ErrorHelper.formatErrorMessage(e.toString(), l10n);
        final errorTitle = ErrorHelper.getErrorTitle(e.toString(), l10n);
        
        await AlertDialogs.showError(
          context: context,
          title: errorTitle,
          message: errorMessage,
          buttonText: l10n.tryAgain,
        );
      }

      return false;
    }
  }

  // ==========================================================================
  // Silent Login (for auto-login)
  // ==========================================================================

  /// Silent login without showing dialogs
  /// 
  /// Used for auto-login flows where we don't want to show error dialogs.
  /// Returns true on success, false on failure.
  /// 
  /// Example:
  /// ```dart
  /// final success = await authProvider.silentLogin(
  ///   username: email,
  ///   password: password,
  /// );
  /// ```
  Future<bool> silentLogin({
    required String username,
    required String password,
  }) async {
    try {
      // Call repository to login
      final loginData = await _authRepository.login(
        username: username,
        password: password,
      );

      // Extract response data
      final user = loginData['user'] as Map<String, dynamic>?;
      final profile = loginData['profile'];
      final accessToken = loginData['accessToken'] as String?;
      final tokenType = loginData['tokenType'] as String?;

      // Update state
      _currentUser = user;
      _isAuthenticated = true;

      // Store all data in secure storage (using camelCase keys)
      if (user != null) {
        await _authRepository.storeUserData(
          userId: user['id']?.toString() ?? '',
          username: user['username'] ?? '',
          email: user['email'] ?? '',
          role: user['role'] ?? '',
          roleId: user['roleId']?.toString() ?? '1',
          firstname: user['firstname'] ?? '',
          surname: user['surname'] ?? '',
          phone1: user['phone1'] ?? '',
          physicalAddress: user['physicalAddress'] ?? '',
          dateOfBirth: user['dateOfBirth'] ?? '',
          gender: user['gender'] ?? '',
          accessToken: accessToken ?? '',
          tokenType: tokenType ?? 'Bearer',
          password: password, // Use the password parameter, not from user data
          profile: profile,
        );
      }

      // Load farmer data if user is a farmer
      if (_currentUser?['role'] == 'farmer') {
        _currentFarmer = await _authRepository.getCurrentFarmer();
      }

      notifyListeners();
      return true;
    } catch (e) {
      log('❌ Silent login failed: ${e.toString()}');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  // ==========================================================================
  // Logout
  // ==========================================================================

  /// Logout current user
  /// 
  /// Shows loading, clears all data, updates state.
  /// 
  /// Example:
  /// ```dart
  /// await authProvider.logout(context);
  /// ```
  Future<void> logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // Show loading dialog
    AlertDialogs.showLoading(
      context: context,
      title: l10n.logout,
      message: l10n.loggingOut,
      isDismissible: false,
    );

    // Set loading state
    _isLoggingOut = true;
    notifyListeners();

    try {
      // Call repository to logout
      await _authRepository.logout();

      // Clear state
      _currentUser = null;
      _currentFarmer = null;
      _isAuthenticated = false;
      _errorMessage = null;
      _isLoggingOut = false;
      notifyListeners();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      // Even if error, clear local state
      _currentUser = null;
      _currentFarmer = null;
      _isAuthenticated = false;
      _isLoggingOut = false;
      notifyListeners();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);
    }
  }

  // ==========================================================================
  // Check Authentication Status
  // ==========================================================================

  /// Check if user is currently authenticated
  /// 
  /// Checks both repository and updates local state.
  /// Call this on app startup.
  /// 
  /// Example:
  /// ```dart
  /// await authProvider.checkAuthStatus();
  /// if (authProvider.isAuthenticated) {
  ///   // Navigate to home
  /// } else {
  ///   // Navigate to login
  /// }
  /// ```
  Future<void> checkAuthStatus() async {
    try {
      // Check repository for authentication status
      _isAuthenticated = await _authRepository.isAuthenticated();

      // If authenticated, load user data
      if (_isAuthenticated) {
        _currentUser = await _authRepository.getCurrentUser();
        
        // Load farmer data if user is a farmer
        if (_currentUser?['role'] == 'farmer') {
          _currentFarmer = await _authRepository.getCurrentFarmer();
        }
      }

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _currentFarmer = null;
      notifyListeners();
    }
  }

  // ==========================================================================
  // Auto-Login
  // ==========================================================================

  /// Attempt automatic login using saved credentials
  /// 
  /// Retrieves stored user data from secure storage without making API calls.
  /// Returns true if auto-login was successful.
  /// Call this on app startup if user is not authenticated.
  /// 
  /// Example:
  /// ```dart
  /// final autoLoginSuccess = await authProvider.tryAutoLogin();
  /// if (autoLoginSuccess) {
  ///   // Navigate to dashboard
  /// } else {
  ///   // Show login screen
  /// }
  /// ```
  Future<bool> tryAutoLogin() async {
    try {
      // Check if user is already authenticated
      final isAuthenticated = await _authRepository.isAuthenticated();
      log('🔐 DEBUG: Is authenticated: $isAuthenticated');
      
      if (!isAuthenticated) {
        return false;
      }

      // Get stored user data from secure storage
      final storedData = await _authRepository.getStoredUserData();
      log('🔐 DEBUG: Stored data: $storedData');
      
      if (storedData == null) {
        return false;
      }

      // Update state with stored data
      _currentUser = storedData['user'] as Map<String, dynamic>?;
      _isAuthenticated = true;

      // Load farmer data if user is a farmer
      if (_currentUser?['role'] == 'farmer') {
        _currentFarmer = await _authRepository.getCurrentFarmer();
      }

      notifyListeners();
      return true;
    } catch (e) {
      // Auto-login failed, user will need to login manually
      _isAuthenticated = false;
      _currentUser = null;
      _currentFarmer = null;
      notifyListeners();
      return false;
    }
  }

  /// Check if saved credentials exist
  /// 
  /// Returns true if username and password are stored securely.
  /// Useful for showing "remember me" or auto-login status.
  Future<bool> hasSavedCredentials() async {
    try {
      final credentials = await _authRepository.getSavedCredentials();
      return credentials != null;
    } catch (e) {
      return false;
    }
  }

  // ==========================================================================
  // Clear Error
  // ==========================================================================

  /// Clear error message
  /// 
  /// Call this when user dismisses error or before new operation.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==========================================================================
  // Get User Role
  // ==========================================================================

  /// Get current user's role
  /// 
  /// Returns null if no user is logged in.
  String? get userRole => _currentUser?['role'] as String?;

  /// Check if current user is a farmer
  bool get isFarmer => userRole == 'farmer';
}

