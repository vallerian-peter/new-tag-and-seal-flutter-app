import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/feeding_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/administration_route.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/disposal_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/disease.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/heat_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/semen_straw_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/insemination_service.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/milking_method.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/calving_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/calving_problem.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/reproductive_problem.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/test_result.dart';

abstract class LogAdditionalDataRepositoryInterface {
  Future<Map<String, dynamic>> fetchRemoteLogAdditionalData();
  Future<void> storeLogAdditionalData(Map<String, dynamic> data);

  Future<List<FeedingType>> getFeedingTypes();
  Future<List<AdministrationRoute>> getAdministrationRoutes();
  Future<List<MedicineType>> getMedicineTypes();
  Future<List<Medicine>> getMedicines();
  Future<List<DisposalType>> getDisposalTypes();
  Future<List<Disease>> getDiseases();
  Future<List<HeatType>> getHeatTypes();
  Future<List<SemenStrawType>> getSemenStrawTypes();
  Future<List<InseminationService>> getInseminationServices();
  Future<List<MilkingMethod>> getMilkingMethods();
  Future<List<CalvingType>> getCalvingTypes();
  Future<List<CalvingProblem>> getCalvingProblems();
  Future<List<ReproductiveProblem>> getReproductiveProblems();
  Future<List<TestResult>> getTestResults();

  Future<void> clearLogAdditionalData();
}
