import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart' as db;
import 'package:new_tag_and_seal_flutter_app/database/daos/log_reference_dao.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/data/remote/all.additional.data_api.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/administration_route.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/feeding_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine_type.dart';
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
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/repo/log_additional_data_repo.dart';

class LogAdditionalDataRepository
    implements LogAdditionalDataRepositoryInterface {
  final db.AppDatabase _database;
  late final LogReferenceDao _dao;

  LogAdditionalDataRepository(this._database) {
    _dao = _database.logReferenceDao;
  }

  @override
  Future<Map<String, dynamic>> fetchRemoteLogAdditionalData() async {
    final data = await AllAdditionalDataService.fetchAllAdditionalData();
    return {
      'feedingTypes': data['feedingTypes'] ?? [],
      'administrationRoutes': data['administrationRoutes'] ?? [],
      'medicineTypes': data['medicineTypes'] ?? [],
      'medicines': data['medicines'] ?? [],
      'disposalTypes': data['disposalTypes'] ?? [],
      'diseases': data['diseases'] ?? [],
      'heatTypes': data['heatTypes'] ?? [],
      'semenStrawTypes': data['semenStrawTypes'] ?? [],
      'inseminationServices': data['inseminationServices'] ?? [],
      'milkingMethods': data['milkingMethods'] ?? [],
      'calvingTypes': data['calvingTypes'] ?? [],
      'calvingProblems': data['calvingProblems'] ?? [],
      'reproductiveProblems': data['reproductiveProblems'] ?? [],
      'testResults': data['testResults'] ?? [],
    };
  }

  @override
  Future<void> storeLogAdditionalData(Map<String, dynamic> data) async {
    try {
      final feedingTypes =
          (data['feedingTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(FeedingType.fromJson)
              .map(
                (model) => db.FeedingTypesCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.FeedingTypesCompanion>[];

      final administrationRoutes =
          (data['administrationRoutes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(AdministrationRoute.fromJson)
              .map(
                (model) => db.AdministrationRoutesCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.AdministrationRoutesCompanion>[];

      final medicineTypes =
          (data['medicineTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(MedicineType.fromJson)
              .map(
                (model) => db.MedicineTypesCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.MedicineTypesCompanion>[];

      final medicines =
          (data['medicines'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(Medicine.fromJson)
              .map(
                (model) => db.MedicinesCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                  medicineTypeId: Value(model.medicineTypeId),
                ),
              )
              .toList() ??
          const <db.MedicinesCompanion>[];

      final disposalTypes =
          (data['disposalTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(DisposalType.fromJson)
              .map(
                (model) => db.DisposalTypesCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.DisposalTypesCompanion>[];

      final diseases =
          (data['diseases'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(Disease.fromJson)
              .map(
                (model) => db.DiseasesCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                  status: Value(model.status),
                ),
              )
              .toList() ??
          const <db.DiseasesCompanion>[];

      final heatTypes =
          (data['heatTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(HeatType.fromJson)
              .map(
                (model) => db.HeatTypesCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.HeatTypesCompanion>[];

      final semenStrawTypes =
          (data['semenStrawTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(SemenStrawType.fromJson)
              .map(
                (model) => db.SemenStrawTypesCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                  category: Value(model.category),
                ),
              )
              .toList() ??
          const <db.SemenStrawTypesCompanion>[];

      final inseminationServices =
          (data['inseminationServices'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(InseminationService.fromJson)
              .map(
                (model) => db.InseminationServicesCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.InseminationServicesCompanion>[];

      final milkingMethods =
          (data['milkingMethods'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(MilkingMethod.fromJson)
              .map(
                (model) => db.MilkingMethodsCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.MilkingMethodsCompanion>[];

      final calvingTypes =
          (data['calvingTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(CalvingType.fromJson)
              .map(
                (model) => db.CalvingTypesCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.CalvingTypesCompanion>[];

      final calvingProblems =
          (data['calvingProblems'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(CalvingProblem.fromJson)
              .map(
                (model) => db.CalvingProblemsCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.CalvingProblemsCompanion>[];

      final reproductiveProblems =
          (data['reproductiveProblems'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(ReproductiveProblem.fromJson)
              .map(
                (model) => db.ReproductiveProblemsCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.ReproductiveProblemsCompanion>[];

      final testResults =
          (data['testResults'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(TestResult.fromJson)
              .map(
                (model) => db.TestResultsCompanion(
                  id: Value(model.id),
                  name: Value(model.name),
                ),
              )
              .toList() ??
          const <db.TestResultsCompanion>[];

      await _dao.upsertFeedingTypes(feedingTypes);
      await _dao.upsertAdministrationRoutes(administrationRoutes);
      await _dao.upsertMedicineTypes(medicineTypes);
      await _dao.upsertMedicines(medicines);
      await _dao.upsertDisposalTypes(disposalTypes);
      await _dao.upsertDiseases(diseases);
      await _dao.upsertHeatTypes(heatTypes);
      await _dao.upsertSemenStrawTypes(semenStrawTypes);
      await _dao.upsertInseminationServices(inseminationServices);
      await _dao.upsertMilkingMethods(milkingMethods);
      await _dao.upsertCalvingTypes(calvingTypes);
      await _dao.upsertCalvingProblems(calvingProblems);
      await _dao.upsertReproductiveProblems(reproductiveProblems);
      await _dao.upsertTestResults(testResults);
    } catch (e) {
      log('❌ Error storing log additional data: $e');
      rethrow;
    }
  }

  @override
  Future<List<FeedingType>> getFeedingTypes() async {
    final entities = await _dao.getAllFeedingTypes();
    return entities
        .map((entity) => FeedingType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<AdministrationRoute>> getAdministrationRoutes() async {
    final entities = await _dao.getAllAdministrationRoutes();
    return entities
        .map((entity) => AdministrationRoute(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<MedicineType>> getMedicineTypes() async {
    final entities = await _dao.getAllMedicineTypes();
    return entities
        .map((entity) => MedicineType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<Medicine>> getMedicines() async {
    final entities = await _dao.getAllMedicines();
    return entities
        .map(
          (entity) => Medicine(
            id: entity.id,
            name: entity.name,
            medicineTypeId: entity.medicineTypeId,
          ),
        )
        .toList();
  }

  @override
  Future<List<DisposalType>> getDisposalTypes() async {
    final entities = await _dao.getAllDisposalTypes();
    return entities
        .map((entity) => DisposalType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<Disease>> getDiseases() async {
    final entities = await _dao.getAllDiseases();
    return entities
        .map(
          (entity) =>
              Disease(id: entity.id, name: entity.name, status: entity.status),
        )
        .toList();
  }

  @override
  Future<List<HeatType>> getHeatTypes() async {
    final entities = await _dao.getAllHeatTypes();
    return entities
        .map((entity) => HeatType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<SemenStrawType>> getSemenStrawTypes() async {
    final entities = await _dao.getAllSemenStrawTypes();
    return entities
        .map(
          (entity) => SemenStrawType(
            id: entity.id,
            name: entity.name,
            category: entity.category,
          ),
        )
        .toList();
  }

  @override
  Future<List<InseminationService>> getInseminationServices() async {
    final entities = await _dao.getAllInseminationServices();
    return entities
        .map((entity) => InseminationService(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<MilkingMethod>> getMilkingMethods() async {
    final entities = await _dao.getAllMilkingMethods();
    return entities
        .map((entity) => MilkingMethod(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<CalvingType>> getCalvingTypes() async {
    final entities = await _dao.getAllCalvingTypes();
    return entities
        .map((entity) => CalvingType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<CalvingProblem>> getCalvingProblems() async {
    final entities = await _dao.getAllCalvingProblems();
    return entities
        .map((entity) => CalvingProblem(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<ReproductiveProblem>> getReproductiveProblems() async {
    final entities = await _dao.getAllReproductiveProblems();
    return entities
        .map((entity) => ReproductiveProblem(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<TestResult>> getTestResults() async {
    final entities = await _dao.getAllTestResults();
    return entities
        .map((entity) => TestResult(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<void> clearLogAdditionalData() => _dao.clearAll();
}
