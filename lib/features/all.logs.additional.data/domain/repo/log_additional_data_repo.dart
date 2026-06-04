import 'package:new_tag_and_seal_flutter_app/database/app_database.dart'
    hide
        FeedingType,
        Disease,
        DisposalType,
        MilkingMethod,
        HeatType,
        InseminationService,
        SemenStrawType,
        TestResult,
        CalvingType,
        CalvingProblem,
        BirthType,
        BirthProblem,
        ReproductiveProblem,
        TeethClippingMethod,
        TailDockingMethod,
        LivestockMarkingType;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/feeding_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/administration_route.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/disease.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/disposal_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/milking_method.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/heat_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/insemination_service.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/semen_straw_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/test_result.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/calving_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/calving_problem.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/birth_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/birth_problem.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/reproductive_problem.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/teeth_clipping_method.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/tail_docking_method.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/livestock_marking_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/prepuce_reference_option.dart';

abstract class LogAdditionalDataRepositoryInterface {
  Future<Map<String, dynamic>> fetchRemoteLogAdditionalData();
  Future<void> storeLogAdditionalData(Map<String, dynamic> data);
  Future<void> syncFromRemote(AppDatabase database);

  Future<List<FeedingType>> getFeedingTypes();
  Future<List<AdministrationRoute>> getAdministrationRoutes();
  Future<List<MedicineType>> getMedicineTypes();
  Future<List<Medicine>> getMedicines();
  Future<List<Disease>> getDiseases();
  Future<List<DisposalType>> getDisposalTypes();
  Future<List<MilkingMethod>> getMilkingMethods();
  Future<List<TeethClippingMethod>> getTeethClippingMethods();
  Future<List<TailDockingMethod>> getTailDockingMethods();
  Future<List<LivestockMarkingType>> getLivestockMarkingTypes();
  Future<List<PrepuceReferenceOption>> getPrepuceReferenceOptions();
  Future<List<HeatType>> getHeatTypes();
  Future<List<InseminationService>> getInseminationServices();
  Future<List<SemenStrawType>> getSemenStrawTypes();
  Future<List<TestResult>> getTestResults();
  Future<List<CalvingType>> getCalvingTypes();
  Future<List<CalvingProblem>> getCalvingProblems();
  Future<List<BirthType>> getBirthTypes();
  Future<List<BirthProblem>> getBirthProblems();
  Future<List<ReproductiveProblem>> getReproductiveProblems();

  Future<void> clearLogAdditionalData();
}
