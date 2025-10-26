import 'package:new_tag_and_seal_flutter_app/features/auth/domain/models/farmer_model.dart';


abstract class AuthRepositoryInterface {
  
  Future<FarmerModel> registerFarmer(Map<String, dynamic> farmerData);

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  });

  Future<bool> logout();

  Future<bool> isAuthenticated();

  Future<Map<String, dynamic>?> getCurrentUser();

  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> saveCredentials({
    required String username,
    required String password,
  });

  Future<Map<String, String>?> getSavedCredentials();

  Future<void> clearAuthData();
}

