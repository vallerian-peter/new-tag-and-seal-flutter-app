import 'package:new_tag_and_seal_flutter_app/features/vaccines/domain/models/vaccine_model.dart';

abstract class VaccineRepositoryInterface {
  Future<void> syncVaccines(List<Map<String, dynamic>> vaccines);

  Future<List<VaccineModel>> getVaccines({String? farmUuid});

  Future<List<Map<String, dynamic>>> getUnsyncedVaccinesForApi();

  Future<void> markVaccinesAsSynced(List<String> uuids);

  Future<VaccineModel> createVaccine(VaccineModel model);

  Future<VaccineModel> updateVaccine(VaccineModel model);

  Future<VaccineModel?> getVaccineByUuid(String uuid);
}

