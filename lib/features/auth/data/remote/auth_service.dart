import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/endpoints.dart';

/// Auth Service
/// 
/// Handles all HTTP requests for authentication operations.
/// This is a stateless service that only communicates with the API.
/// No business logic or state management happens here.
class AuthService {
  // Private constructor to prevent instantiation
  AuthService._();

  /// Secure storage instance for storing sensitive data
  static const _secureStorage = FlutterSecureStorage();
  
  /// Secure storage key for authentication token
  static const String _tokenKey = 'auth_token';

  // ==========================================================================
  // Helper Methods
  // ==========================================================================

  /// Get authentication token from secure storage
  static Future<String?> _getAuthToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw Exception('Failed to retrieve auth token: $e');
    }
  }

  /// Build HTTP headers with authentication
  static Future<Map<String, String>> _buildHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==========================================================================
  // API Methods
  // ==========================================================================

  /// Register a new farmer
  /// 
  /// Sends farmer registration data to the backend.
  /// Returns the complete API response including farmer data and token.
  /// 
  /// Throws an exception if:
  /// - Network request fails
  /// - Response status is not 200/201
  /// - Response format is invalid
  /// 
  /// Example:
  /// ```dart
  /// final farmerData = {
  ///   'username': 'john_doe',
  ///   'email': 'john@example.com',
  ///   'password': 'securepass123',
  ///   'password_confirmation': 'securepass123',
  ///   'role': 'farmer',
  ///   'firstName': 'John',
  ///   'surname': 'Doe',
  ///   'phone1': '+255712345678',
  ///   'gender': 'male',
  ///   // ... other fields
  /// };
  /// 
  /// final response = await AuthService.registerFarmer(farmerData);
  /// print(response['data']['farmer']); // Farmer data
  /// print(response['data']['token']);  // Auth token
  /// ```
  static Future<Map<String, dynamic>> registerFarmer(
    Map<String, dynamic> farmerData,
  ) async {
    try {
      // Build headers
      final headers = await _buildHeaders();

      // Make POST request
      final response = await http.post(
        Uri.parse(ApiEndpoints.farmerRegister),
        headers: headers,
        body: jsonEncode(farmerData),
      );

      log('🔐 DEBUG: Register farmer response: ${response.body}');

      // Parse response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Check response status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check API status flag
        if (responseData['status'] == true) {
          return responseData;
        } else {
          // API returned error
          final message = responseData['message'] ?? 'Registration failed';
          final errors = responseData['errors'];
          
          if (errors != null && errors is Map) {
            // Format validation errors
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.cast<String>());
              } else {
                errorMessages.add(value.toString());
              }
            });
            throw Exception('Validation failed: ${errorMessages.join(', ')}');
          }
          
          throw Exception(message);
        }
      } else if (response.statusCode == 422) {
        // Validation errors
        final errors = responseData['errors'];
        if (errors != null && errors is Map) {
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            }
          });
          throw Exception('Validation failed: ${errorMessages.join(', ')}');
        }
        throw Exception('Validation failed');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized request');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later');
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to register farmer: $e');
    }
  }

  /// Login user with username and password
  /// 
  /// Sends login credentials to the backend.
  /// Returns the complete API response including user data and token.
  /// 
  /// Throws an exception if:
  /// - Network request fails
  /// - Credentials are invalid
  /// - Response format is invalid
  /// 
  /// Example:
  /// ```dart
  /// final response = await AuthService.login(
  ///   username: 'john_doe',
  ///   password: 'securepass123',
  /// );
  /// 
  /// print(response['data']['user']);  // User data
  /// print(response['data']['token']); // Auth token
  /// ```
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Build headers
      final headers = await _buildHeaders();

      // Prepare login data
      final loginData = {
        'username': username,
        'password': password,
      };

      // Make POST request
      final response = await http.post(
        Uri.parse(ApiEndpoints.farmerLogin),
        headers: headers,
        body: jsonEncode(loginData),
      );

      log('🔐 DEBUG: Login response: ${response.body}');

      // Parse response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Check response status code
      if (response.statusCode == 200) {
        // Check API status flag
        if (responseData['status'] == true) {
          return responseData;
        } else {
          final message = responseData['message'] ?? 'Login failed';
          throw Exception(message);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid username or password');
      } else if (response.statusCode == 422) {
        throw Exception('Please provide valid username and password');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later');
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to login: $e');
    }
  }

  /// Logout current user
  /// 
  /// Sends logout request to the backend to invalidate the token.
  /// Returns true if logout was successful.
  /// 
  /// Example:
  /// ```dart
  /// final success = await AuthService.logout();
  /// if (success) {
  ///   print('Logged out successfully');
  /// }
  /// ```
  static Future<bool> logout() async {
    try {
      // Build headers with auth token
      final headers = await _buildHeaders();

      // Make POST request
      final response = await http.post(
        Uri.parse(ApiEndpoints.farmerLogout),
        headers: headers,
      );

      // Check response
      if (response.statusCode == 200) {
        return true;
      } else {
        // Even if API fails, we should clear local data
        return true;
      }
    } catch (e) {
      // Even if network fails, we should clear local data
      return true;
    }
  }
}

