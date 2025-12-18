import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/data/local/auth_repositoy.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/domain/models/farmer_model.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/error_helper.dart';
import 'package:new_tag_and_seal_flutter_app/core/check-network/network_check.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/domain/farm_user_permissions.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/extension_officer_permissions.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/models/extension_officer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Loading state for changing password
  bool _isChangingPassword = false;
  bool get isChangingPassword => _isChangingPassword;

  /// Loading state for updating profile
  bool _isUpdatingProfile = false;
  bool get isUpdatingProfile => _isUpdatingProfile;

  /// Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Current logged in user data
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Current logged in profile data (Farmer / SystemUser / FarmUser)
  Map<String, dynamic>? _currentProfile;
  Map<String, dynamic>? get currentProfile => _currentProfile;

  /// Current logged in farmer data
  FarmerModel? _currentFarmer;
  FarmerModel? get currentFarmer => _currentFarmer;

  /// Current logged in extension officer profile (typed)
  ExtensionOfficerModel? _currentExtensionOfficer;
  ExtensionOfficerModel? get currentExtensionOfficer =>
      _currentExtensionOfficer;

  /// Check if the current user (extension officer) has access to a given log type
  /// Only technical event log types are allowed for extension officers.
  /// Updated: allow all technical logs among the 13 supported log types.
  bool hasAccessToLogType(String logType) {
    if (!isExtensionOfficer) return true; // non-extension officers unaffected

    final normalized = logType.toLowerCase();

    // Allowed technical event types subset among the 13 logs
    final allowed = <String>{
      EventLogTypes.medication.toLowerCase(),
      EventLogTypes.vaccination.toLowerCase(),
      EventLogTypes.deworming.toLowerCase(),
      EventLogTypes.insemination.toLowerCase(),
      EventLogTypes.pregnancy.toLowerCase(),
      EventLogTypes.calving.toLowerCase(),
      EventLogTypes.farrowing.toLowerCase(),
      EventLogTypes.abortedPregnancy.toLowerCase(),
      EventLogTypes.disposal.toLowerCase(),
      EventLogTypes.dryoff.toLowerCase(),
    };

    // Allow if the normalized logType exactly matches an allowed event type
    if (allowed.contains(normalized)) return true;

    // Also allow if logType contains known keywords (defensive)
    if (normalized.contains('medic') ||
        normalized.contains('vaccin') ||
        normalized.contains('deworm') ||
        normalized.contains('insemin') ||
        normalized.contains('pregnan') ||
        normalized.contains('dispos') ||
        normalized.contains('calv') ||
        normalized.contains('farrow') ||
        normalized.contains('abort') ||
        normalized.contains('dryoff')) {
      return true;
    }
    return false;
  }

  /// Extension Officer login using email + access_code + password
  ///
  /// Shows loading dialog, calls repository, handles success/error.
  Future<bool> loginExtensionOfficer({
    required BuildContext context,
    required String email,
    required String accessCode,
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

    _isLoggingIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authRepository.loginExtensionOfficer(
        email: email,
        accessCode: accessCode,
        password: password,
      );

      final user = data['user'] as Map<String, dynamic>?;
      final profile = data['profile'] as Map<String, dynamic>?;

      _currentUser = user;
      _currentProfile = profile;
      _isAuthenticated = true;
      _isLoggingIn = false;

      // Load typed EO model and cache for offline access
      _currentExtensionOfficer = await _authRepository.getCurrentExtensionOfficer();
      if (_currentExtensionOfficer != null) {
        try {
          await _authRepository.storeExtensionOfficerModel(_currentExtensionOfficer!);
        } catch (_) {}
      }

      notifyListeners();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      return true;
    } catch (e) {
      _isLoggingIn = false;
      notifyListeners();

      if (context.mounted) Navigator.pop(context);

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

    // Show loading dialog on the register screen using the provided context
    AlertDialogs.showLoading(
      context: context,
      title: l10n.registerText,
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

      // Load user data from storage (repository stores it after auto-login)
      // This is critical for role-based access control
      final storedData = await _authRepository.getStoredUserData();

      if (storedData != null) {
        _currentUser = storedData['user'] as Map<String, dynamic>?;
        _currentProfile = storedData['profile'] as Map<String, dynamic>?;
        log(
          '🔐 DEBUG: Loaded user data after registration - Role: ${_currentUser?['role']}',
        );
      } else {
        log('⚠️ WARNING: No stored user data found after registration');
      }

      // Verify authentication status from repository (auto-login should have set this)
      _isAuthenticated = await _authRepository.isAuthenticated();
      log(
        '🔐 DEBUG: Authentication status after registration: $_isAuthenticated',
      );

      if (!_isAuthenticated) {
        log(
          '⚠️ WARNING: User not authenticated after registration and auto-login!',
        );
      }

      // Update state
      _currentFarmer = farmer;
      _isRegisteringFarmer = false;
      notifyListeners();

      // DO NOT close loading dialog here - let it stay open until navigation completes
      // The dialog will be closed in register_screen after navigation to HomeScreen
      log(
        '🔐 DEBUG: Registration and auto-login completed - keeping loading dialog open until navigation',
      );
      log(
        '🔐 DEBUG: Registration flow completed, returning true - navigation will happen in register_screen',
      );
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
      final profile = loginData['profile'] as Map<String, dynamic>?;
      final accessToken = loginData['accessToken'] as String?;
      final tokenType = loginData['tokenType'] as String?;

      // Update state
      _currentUser = user;
      _currentProfile = profile;
      _isAuthenticated = true;
      _isLoggingIn = false;

      // Extract roleTitle/jobTitle from profile for farm users
      String? roleTitle;
      if (profile != null &&
          user != null &&
          user['role'] == 'farmInvitedUser') {
        roleTitle = (profile as Map<String, dynamic>?)?['roleTitle'] as String?;
      }

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
          // Store the actual password used for login (parameter `password`)
          password: password,
          profile: profile,
          roleTitle: roleTitle ?? '',
        );

        // Reset dashboard sync prompt (stored in SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('dashboard_sync_prompt_shown');
      }

      // Load farmer data if user is a farmer
      if (_currentUser?['role'] == 'farmer') {
        _currentFarmer = await _authRepository.getCurrentFarmer();
      } else if (isExtensionOfficer) {
        _currentExtensionOfficer = await _authRepository
            .getCurrentExtensionOfficer();
        // Persist typed model for quick offline access
        if (_currentExtensionOfficer != null) {
          try {
            await _authRepository.storeExtensionOfficerModel(
              _currentExtensionOfficer!,
            );
          } catch (e) {
            log('⚠️ Failed to cache extension officer model: $e');
          }
        }
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
      final profile = loginData['profile'] as Map<String, dynamic>?;
      final accessToken = loginData['accessToken'] as String?;
      final tokenType = loginData['tokenType'] as String?;

      // Update state
      _currentUser = user;
      _currentProfile = profile;
      _isAuthenticated = true;

      // Extract roleTitle/jobTitle from profile for farm users
      String? roleTitle;
      if (profile != null &&
          user != null &&
          user['role'] == 'farmInvitedUser') {
        roleTitle = (profile as Map<String, dynamic>?)?['roleTitle'] as String?;
      }

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
          roleTitle: roleTitle ?? '',
        );
      }

      // Load farmer data if user is a farmer
      if (_currentUser?['role'] == 'farmer') {
        _currentFarmer = await _authRepository.getCurrentFarmer();
      } else if (isExtensionOfficer) {
        _currentExtensionOfficer = await _authRepository
            .getCurrentExtensionOfficer();
        // cache typed model
        if (_currentExtensionOfficer != null) {
          try {
            await _authRepository.storeExtensionOfficerModel(
              _currentExtensionOfficer!,
            );
          } catch (_) {}
        }
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
        // Get stored user data including profile
        final storedData = await _authRepository.getStoredUserData();

        if (storedData != null) {
          _currentUser = storedData['user'] as Map<String, dynamic>?;
          _currentProfile = storedData['profile'] as Map<String, dynamic>?;
        } else {
          // Fallback to getCurrentUser if getStoredUserData fails
          _currentUser = await _authRepository.getCurrentUser();
        }

        // Load farmer data if user is a farmer
        if (_currentUser?['role'] == 'farmer') {
          _currentFarmer = await _authRepository.getCurrentFarmer();
        }
      }

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _currentProfile = null;
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
      _currentProfile = storedData['profile'] as Map<String, dynamic>?;
      _isAuthenticated = true;

      log('🔐 DEBUG: Loaded profile: $_currentProfile');
      log('🔐 DEBUG: RoleTitle in profile: ${_currentProfile?['roleTitle']}');

      // Load farmer data if user is a farmer
      if (_currentUser?['role'] == 'farmer') {
        _currentFarmer = await _authRepository.getCurrentFarmer();
      }

      // If extension officer, attempt to load and cache typed model
      if (isExtensionOfficer) {
        _currentExtensionOfficer = await _authRepository
            .getCurrentExtensionOfficer();
        if (_currentExtensionOfficer != null) {
          try {
            await _authRepository.storeExtensionOfficerModel(
              _currentExtensionOfficer!,
            );
          } catch (e) {
            log(
              '⚠️ Failed to cache extension officer model during auto-login: $e',
            );
          }
        }
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

  /// Check if current user is a farm invited user (farm user)
  bool get isFarmUser => userRole == 'farmInvitedUser';

  /// Check if current user is an extension officer
  bool get isExtensionOfficer =>
      userRole == 'extension_officer' || userRole == 'extensionOfficer';

  /// Resolve farm user permissions based on current profile.roleTitle
  FarmUserPermissions? get farmUserPermissions {
    if (!isFarmUser && !isExtensionOfficer) return null;
    final profile = _currentProfile;

    // For Extension Officer, return a specialized permissions object that
    // allows creating/viewing technical logs only (medication, vaccination, etc.)
    if (isExtensionOfficer) {
      // Lazily import resolver
      try {
        // Avoid circular imports by referencing resolver here
        return resolveExtensionOfficerPermissions();
      } catch (_) {
        return const FarmUserPermissions(
          scope: FarmUserAccessScope.logsOnly,
          canManageLivestock: false,
          canCreateLogs: true,
          canViewLogs: true,
        );
      }
    }

    final roleTitle = profile?['roleTitle'] as String?;
    if (roleTitle == null || roleTitle.trim().isEmpty) return null;
    return resolveFarmUserPermissions(roleTitle);
  }

  // ==========================================================================
  // Change Password
  // ==========================================================================

  /// Store extension officer access number in secure storage
  Future<void> storeExtensionOfficerAccessNumber(String accessNumber) async {
    try {
      await _authRepository.storeExtensionOfficerAccessNumber(accessNumber);
    } catch (e) {
      log('⚠️ Failed to store extension officer access number: $e');
    }
  }

  /// Change user password
  ///
  /// Checks network connectivity, shows loading dialog, calls repository, handles success/error.
  ///
  /// Example:
  /// ```dart
  /// final success = await authProvider.changePassword(
  ///   context: context,
  ///   oldPassword: 'current_password',
  ///   newPassword: 'new_secure_password',
  /// );
  /// ```
  Future<bool> changePassword({
    required BuildContext context,
    required String oldPassword,
    required String newPassword,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    // Check network connectivity first
    final networkCheck = NetworkCheck.instance;
    final isConnected = await networkCheck.isConnected;

    if (!isConnected) {
      if (context.mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.noInternetConnection,
          message: l10n.pleaseCheckYourInternetConnection,
          buttonText: l10n.ok,
        );
      }
      return false;
    }

    // Show loading dialog
    AlertDialogs.showLoading(
      context: context,
      title: l10n.changePassword,
      message: l10n.updatingPassword,
      isDismissible: false,
    );

    // Set loading state
    _isChangingPassword = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('🔐 DEBUG: Changing password');

      // Call repository to change password
      final success = await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      log('🔐 DEBUG: Password changed successfully');

      // Update state
      _isChangingPassword = false;
      notifyListeners();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      return success;
    } catch (e) {
      log('❌ Error changing password: ${e.toString()}');

      _isChangingPassword = false;
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
  // Update Profile
  // ==========================================================================

  /// Update user profile
  ///
  /// Checks network connectivity, shows loading dialog, calls repository, handles success/error.
  /// Updates local stored data on success.
  ///
  /// Example:
  /// ```dart
  /// final profileData = {
  ///   'firstName': 'John',
  ///   'surname': 'Doe',
  ///   'phone1': '+255712345678',
  ///   // ... other fields
  /// };
  ///
  /// final success = await authProvider.updateProfile(
  ///   context: context,
  ///   profileData: profileData,
  /// );
  /// ```
  Future<bool> updateProfile({
    required BuildContext context,
    required Map<String, dynamic> profileData,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    // Check network connectivity first
    final networkCheck = NetworkCheck.instance;
    final isConnected = await networkCheck.isConnected;

    if (!isConnected) {
      if (context.mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.noInternetConnection,
          message: l10n.pleaseCheckYourInternetConnection,
          buttonText: l10n.ok,
        );
      }
      return false;
    }

    // Show loading dialog
    AlertDialogs.showLoading(
      context: context,
      title: l10n.editProfile,
      message: l10n.updatingProfile,
      isDismissible: false,
    );

    // Set loading state
    _isUpdatingProfile = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('🔐 DEBUG: Updating profile');

      // Call repository to update profile
      final response = await _authRepository.updateProfile(profileData);

      log('🔐 DEBUG: Profile updated successfully');

      // Check if update was successful (status 200)
      if (response['status'] == true) {
        // Repository already updated secure storage, now refresh provider state from storage
        // This ensures everything is in sync with what's actually stored
        final storedData = await _authRepository.getStoredUserData();
        if (storedData != null) {
          _currentUser = storedData['user'] as Map<String, dynamic>?;
          _currentProfile = storedData['profile'] as Map<String, dynamic>?;

          // Update farmer data if user is a farmer
          if (_currentUser?['role'] == 'farmer') {
            _currentFarmer = await _authRepository.getCurrentFarmer();
          }

          log(
            '✅ Provider state refreshed from secure storage after profile update',
          );
        }
      }

      // Update state
      _isUpdatingProfile = false;
      notifyListeners();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      return true;
    } catch (e) {
      log('❌ Error updating profile: ${e.toString()}');

      _isUpdatingProfile = false;
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
  // Forgot Password
  // ==========================================================================

  /// Send OTP for password reset
  Future<bool> sendOtp({
    String? email,
    String? phone,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.sendOtp(
        email: email,
        phone: phone,
      );

      if (response['status'] == true) {
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to send OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Reset password with OTP
  Future<bool> resetPassword({
    String? email,
    String? phone,
    required String otp,
    required String newPassword,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.resetPassword(
        email: email,
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );

      if (response['status'] == true) {
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to reset password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
