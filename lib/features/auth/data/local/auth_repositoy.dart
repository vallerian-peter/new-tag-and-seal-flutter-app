import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/data/remote/auth_service.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/domain/models/farmer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/domain/repo/auth_repository_interface.dart';

/// Auth Repository Implementation
/// 
/// This class implements the AuthRepositoryInterface and handles:
/// - Communication with remote API (via AuthService)
/// - Local data storage (SharedPreferences and SecureStorage)
/// - Business logic for authentication operations
/// 
/// This is the bridge between the UI layer (Provider) and the API layer (Service).
class AuthRepository implements AuthRepositoryInterface {
  // ==========================================================================
  // Storage Instances
  // ==========================================================================
  
  /// Secure storage for sensitive data (tokens, passwords)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  /// Regular storage for non-sensitive data (user info, preferences)
  SharedPreferences? _prefs;

  // ==========================================================================
  // Storage Keys
  // ==========================================================================
  
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'saved_username';
  static const String _passwordKey = 'saved_password';
  static const String _userKey = 'user_data';
  static const String _farmerKey = 'farmer_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // ==========================================================================
  // Constructor
  // ==========================================================================
  
  /// Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ==========================================================================
  // Registration
  // ==========================================================================

  @override
  Future<FarmerModel> registerFarmer(Map<String, dynamic> farmerData) async {
    try {
      // 1. Extract credentials for login after registration
      final username = farmerData['username'] as String;
      final password = farmerData['password'] ?? farmerData['email'] as String;
      
      // 2. Add role to registration data
      farmerData['role'] = 'farmer';

      // 3. Call remote API to register farmer
      final registerResponse = await AuthService.registerFarmer(farmerData);

      // 4. Check if registration was successful
      if (registerResponse.isEmpty || registerResponse['status'] != true) {
        final errorMessage = registerResponse['message'] ?? 'Registration failed';
        log('🔐 DEBUG: Error registering farmer: $errorMessage');
        throw Exception(errorMessage);
      }

      // 5. Registration successful, now login to get full data
      final loginResponse = await AuthService.login(
        username: username,
        password: password,
      );

      // 6. Check if login was successful
      if (loginResponse.isEmpty || loginResponse['status'] != true) {
        final errorMessage = loginResponse['message'] ?? 'Auto-login after registration failed';
        log('🔐 DEBUG: Error logging in after registration: $errorMessage');
        throw Exception(errorMessage);
      }

      // 7. Extract data from login response
      final data = loginResponse['data'] as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;
      final profile = data['profile'];
      final accessToken = data['accessToken'] as String;
      final tokenType = data['tokenType'] as String;

      // 8. Create FarmerModel from profile
      final farmer = FarmerModel.fromJson(data['profile'] as Map<String, dynamic>);

      // 9. Store all data in secure storage (using camelCase keys)
      await storeUserData(
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
        accessToken: accessToken,
        tokenType: tokenType,
        password: password,
        profile: profile,
      );

      // 10. Set logged in status
      await _setLoggedInStatus(true);

      // 11. Return the registered farmer
      return farmer;
    } catch (e) {
      throw Exception('Repository: Failed to register farmer - $e');
    }
  }

  // ==========================================================================
  // Login
  // ==========================================================================

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // 1. Call remote API to login
      final response = await AuthService.login(
        username: username,
        password: password,
      );

      log('🔐 DEBUG: Login response: $response');

      // 2. Extract data from response
      final data = response['data'] as Map<String, dynamic>;
      final token = data['accessToken'] as String;
      final userData = data['user'] as Map<String, dynamic>;

      // 3. Save authentication data locally (including credentials for auto-login)
      await saveToken(token);
      await saveCredentials(username: username, password: password);
      await _saveUserData(userData);
      await _setLoggedInStatus(true);

      // 4. If user is a farmer, save farmer data
      if (userData['role'] == 'farmer' && data.containsKey('farmer')) {
        await _saveFarmerData(data['farmer'] as Map<String, dynamic>);
      }

      // 5. Return complete login data
      return data;
    } catch (e) {
      throw Exception('Repository: Failed to login - $e');
    }
  }

  // ==========================================================================
  // Logout
  // ==========================================================================

  @override
  Future<bool> logout() async {
    try {
      // 1. Call remote API to logout (invalidate token on server)
      await AuthService.logout();

      // 2. Clear all local authentication data
      await clearAuthData();

      // 3. Return success
      return true;
    } catch (e) {
      // Even if API fails, clear local data
      await clearAuthData();
      return true;
    }
  }

  // ==========================================================================
  // Authentication Status
  // ==========================================================================

  @override
  Future<bool> isAuthenticated() async {
    try {
      await _initPrefs();
      
      // Check if user is logged in in SharedPreferences
      final isLoggedIn = _prefs!.getBool(_isLoggedInKey) ?? false;
      
      // Check if essential user data exists in secure storage
      final userId = await _secureStorage.read(key: 'userId');
      final username = await _secureStorage.read(key: 'username');
      final accessToken = await _secureStorage.read(key: 'accessToken');
      
      // User is authenticated if:
      // 1. SharedPreferences says they're logged in AND
      // 2. Essential user data exists in secure storage
      return isLoggedIn && 
             userId != null && userId.isNotEmpty &&
             username != null && username.isNotEmpty &&
             accessToken != null && accessToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ==========================================================================
  // Get Current User
  // ==========================================================================

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      await _initPrefs();
      
      // Get user data from storage
      final userJson = _prefs!.getString(_userKey);
      
      if (userJson != null && userJson.isNotEmpty) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get current farmer data
  /// 
  /// Returns farmer information from local storage.
  /// Returns null if no farmer is logged in or user is not a farmer.
  Future<FarmerModel?> getCurrentFarmer() async {
    try {
      await _initPrefs();
      
      // Get farmer data from storage
      final farmerJson = _prefs!.getString(_farmerKey);
      
      if (farmerJson != null && farmerJson.isNotEmpty) {
        final farmerData = jsonDecode(farmerJson) as Map<String, dynamic>;
        return FarmerModel.fromJson(farmerData);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all stored user data from secure storage
  /// 
  /// Returns a map containing all stored user information including tokens.
  /// Returns null if no user data is stored.
  Future<Map<String, dynamic>?> getStoredUserData() async {
    try {
      // Get all stored user data from secure storage
      final userId = await _secureStorage.read(key: 'userId');
      final username = await _secureStorage.read(key: 'username');
      final email = await _secureStorage.read(key: 'email');
      final role = await _secureStorage.read(key: 'role');
      final roleId = await _secureStorage.read(key: 'roleId');
      final firstname = await _secureStorage.read(key: 'firstname');
      final surname = await _secureStorage.read(key: 'surname');
      final phone1 = await _secureStorage.read(key: 'phone1');
      final physicalAddress = await _secureStorage.read(key: 'physicalAddress');
      final dateOfBirth = await _secureStorage.read(key: 'dateOfBirth');
      final gender = await _secureStorage.read(key: 'gender');
      final accessToken = await _secureStorage.read(key: 'accessToken');
      final tokenType = await _secureStorage.read(key: 'tokenType');
      final profileJson = await _secureStorage.read(key: 'profile');

      // Check if essential data exists
      if (userId == null || username == null || accessToken == null) {
        return null;
      }

      // Parse profile if it exists
      Map<String, dynamic>? profile;
      if (profileJson != null && profileJson.isNotEmpty) {
        try {
          profile = jsonDecode(profileJson) as Map<String, dynamic>;
        } catch (e) {
          // Profile parsing failed, continue without it
        }
      }

      // Return structured user data
      return {
        'user': {
          'id': int.tryParse(userId),
          'username': username,
          'email': email,
          'role': role,
          'roleId': int.tryParse(roleId ?? '1'),
          'firstname': firstname,
          'surname': surname,
          'phone1': phone1,
          'physicalAddress': physicalAddress,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
        },
        'profile': profile,
        'accessToken': accessToken,
        'tokenType': tokenType,
      };
    } catch (e) {
      return null;
    }
  }

  // ==========================================================================
  // Token Management
  // ==========================================================================

  @override
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  // ==========================================================================
  // Credentials Management (Auto-Login)
  // ==========================================================================

  @override
  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    try {
      // Save credentials securely for auto-login
      await _secureStorage.write(key: _usernameKey, value: username);
      await _secureStorage.write(key: _passwordKey, value: password);
    } catch (e) {
      throw Exception('Failed to save credentials: $e');
    }
  }

  @override
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final username = await _secureStorage.read(key: _usernameKey);
      final password = await _secureStorage.read(key: _passwordKey);

      if (username != null && password != null) {
        return {
          'username': username,
          'password': password,
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // ==========================================================================
  // Store User Data (camelCase keys)
  // ==========================================================================

  /// Store all user data from login response
  /// 
  /// Stores user data, profile, and tokens in secure storage with camelCase keys.
  /// Called after successful login to persist user session.
  Future<void> storeUserData({
    required String userId,
    required String username,
    required String email,
    required String role,
    required String roleId,
    required String firstname,
    required String surname,
    required String phone1,
    required String physicalAddress,
    required String dateOfBirth,
    required String gender,
    required String accessToken,
    required String tokenType,
    required String password,
    dynamic profile,
  }) async {
    try {
      await _initPrefs();
      
      // Store user information (camelCase keys - no underscores)
      await _secureStorage.write(key: 'userId', value: userId);
      await _secureStorage.write(key: 'username', value: username);
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'role', value: role);
      await _secureStorage.write(key: 'roleId', value: roleId);
      await _secureStorage.write(key: 'firstname', value: firstname);
      await _secureStorage.write(key: 'surname', value: surname);
      await _secureStorage.write(key: 'phone1', value: phone1);
      await _secureStorage.write(key: 'physicalAddress', value: physicalAddress);
      await _secureStorage.write(key: 'dateOfBirth', value: dateOfBirth);
      await _secureStorage.write(key: 'gender', value: gender);
      await _secureStorage.write(key: 'password', value: password);
      
      // Store tokens
      await _secureStorage.write(key: 'accessToken', value: accessToken);
      await _secureStorage.write(key: 'tokenType', value: tokenType);
      
      // Store profile data if available
      if (profile != null) {
        final profileJson = jsonEncode(profile);
        await _secureStorage.write(key: 'profile', value: profileJson);
      }
      
      // Set logged in status in SharedPreferences
      await _prefs!.setBool(_isLoggedInKey, true);
    } catch (e) {
      throw Exception('Failed to store user data: $e');
    }
  }

  // ==========================================================================
  // Clear Data
  // ==========================================================================

  @override
  Future<void> clearAuthData() async {
    try {
      await _initPrefs();
      
      // Clear secure storage (token and credentials)
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _usernameKey);
      await _secureStorage.delete(key: _passwordKey);
      await _secureStorage.delete(key: 'password');
      
      // Clear user data from secure storage (camelCase keys)
      await _secureStorage.delete(key: 'userId');
      await _secureStorage.delete(key: 'username');
      await _secureStorage.delete(key: 'email');
      await _secureStorage.delete(key: 'role');
      await _secureStorage.delete(key: 'roleId');
      await _secureStorage.delete(key: 'firstname');
      await _secureStorage.delete(key: 'surname');
      await _secureStorage.delete(key: 'phone1');
      await _secureStorage.delete(key: 'physicalAddress');
      await _secureStorage.delete(key: 'dateOfBirth');
      await _secureStorage.delete(key: 'gender');
      await _secureStorage.delete(key: 'accessToken');
      await _secureStorage.delete(key: 'tokenType');
      await _secureStorage.delete(key: 'profile');


      
      // Clear shared preferences (user data, farmer data, login status)
      await _prefs!.remove(_userKey);
      await _prefs!.remove(_farmerKey);
      await _prefs!.remove(_isLoggedInKey);
    } catch (e) {
      throw Exception('Failed to clear auth data: $e');
    }
  }

  // ==========================================================================
  // Private Helper Methods
  // ==========================================================================

  /// Save user data to local storage
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      await _initPrefs();
      final userJson = jsonEncode(userData);
      await _prefs!.setString(_userKey, userJson);
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Save farmer data to local storage
  Future<void> _saveFarmerData(Map<String, dynamic> farmerData) async {
    try {
      await _initPrefs();
      final farmerJson = jsonEncode(farmerData);
      await _prefs!.setString(_farmerKey, farmerJson);
    } catch (e) {
      throw Exception('Failed to save farmer data: $e');
    }
  }

  /// Set logged in status
  Future<void> _setLoggedInStatus(bool isLoggedIn) async {
    try {
      await _initPrefs();
      await _prefs!.setBool(_isLoggedInKey, isLoggedIn);
    } catch (e) {
      throw Exception('Failed to set logged in status: $e');
    }
  }
}

