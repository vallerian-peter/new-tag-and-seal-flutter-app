import 'package:new_tag_and_seal_flutter_app/features/farmUser/domain/models/farm_user_model.dart';

abstract class FarmUserRepositoryInterface {
  Future<void> syncFarmUsers(List<Map<String, dynamic>> items);

  Future<List<FarmUserModel>> getFarmUsers({String? farmUuid});

  Future<List<Map<String, dynamic>>> getUnsyncedFarmUsersForApi();

  Future<void> markFarmUsersAsSynced(List<String> uuids);

  Future<FarmUserModel> createFarmUser(FarmUserModel model);

  Future<FarmUserModel> updateFarmUser(FarmUserModel model);

  Future<bool> markFarmUserAsDeleted(String uuid);
}


