import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/endpoints.dart';

/// Extension Officer Service
/// 
/// Handles all HTTP requests for extension officer operations.
class ExtensionOfficerService {
  // Private constructor to prevent instantiation
  ExtensionOfficerService._();

  /// Secure storage instance for storing sensitive data
  static const _secureStorage = FlutterSecureStorage();
  
  /// Secure storage key for authentication token
  static const String _tokenKey = 'auth_token';

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
    if (token == null || token.isEmpty) {
      log('⚠️ Auth token is null or empty');
      throw Exception('Authentication token not found. Please login again.');
    }
    
    log('✅ Auth token retrieved: ${token.substring(0, 20)}...');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Search for extension officer by email
  /// 
  /// Returns extension officer data if found, null otherwise.
  static Future<Map<String, dynamic>?> searchByEmail(String email) async {
    try {
      final headers = await _buildHeaders();
      
      log('🔍 Searching extension officer with email: $email');
      log('🔍 Request URL: ${ApiEndpoints.extensionOfficerInviteSearch}?email=$email');
      
      final response = await http.get(
        Uri.parse('${ApiEndpoints.extensionOfficerInviteSearch}?email=$email'),
        headers: headers,
      );

      log('🔍 Extension officer search response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('Unauthenticated. Please login again.');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return responseData['data'] as Map<String, dynamic>?;
      } else if (response.statusCode == 404) {
        return null; // Officer not found
      } else {
        final message = responseData['message'] ?? 'Failed to search extension officer';
        throw Exception(message);
      }
    } on http.ClientException catch (e) {
      log('❌ Network error: $e');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      log('❌ Unexpected error: $e');
      throw Exception('Failed to search extension officer: $e');
    }
  }

  /// Create extension officer farm invite
  /// 
  /// Returns invite data including access code.
  /// [accessCode] should be generated on the frontend before calling this method.
  static Future<Map<String, dynamic>> createInvite(String extensionOfficerEmail, String accessCode) async {
    try {
      log('🔑 Using access code: $accessCode');
      
      final headers = await _buildHeaders();
      
      log('📧 Creating extension officer invite for email: $extensionOfficerEmail');
      log('📧 Request URL: ${ApiEndpoints.extensionOfficerInviteCreate}');
      
      final response = await http.post(
        Uri.parse(ApiEndpoints.extensionOfficerInviteCreate),
        headers: headers,
        body: jsonEncode({
          'extensionOfficerEmail': extensionOfficerEmail,
          'access_code': accessCode,
        }),
      );

      log('📧 Extension officer invite response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('Unauthenticated. Please login again.');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && responseData['status'] == true) {
        return responseData['data'] as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Extension officer not found with this email');
      } else if (response.statusCode == 409) {
        // Invite already exists
        throw Exception(responseData['message'] ?? 'Extension officer has already been invited');
      } else {
        final message = responseData['message'] ?? 'Failed to create invite';
        throw Exception(message);
      }
    } on http.ClientException catch (e) {
      log('❌ Network error: $e');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      log('❌ Unexpected error: $e');
      throw Exception('Failed to create extension officer invite: $e');
    }
  }
}

