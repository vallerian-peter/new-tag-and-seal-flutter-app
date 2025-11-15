import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/database/daos/log_reference_dao.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/data/remote/all.additional.data_api.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/administration_route.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/feeding_type.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine_type.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/disease.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/disposal_type.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/milking_method.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/heat_type.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/insemination_service.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/semen_straw_type.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/test_result.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/calving_type.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/calving_problem.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/reproductive_problem.dart'
    as logModels;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/repo/log_additional_data_repo.dart';

class LogAdditionalDataRepository implements LogAdditionalDataRepositoryInterface {
  final AppDatabase _database;
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
      'diseases': data['diseases'] ?? [],
      'disposalTypes': data['disposalTypes'] ?? [],
      'milkingMethods': data['milkingMethods'] ?? [],
      'heatTypes': data['heatTypes'] ?? [],
      'inseminationServices': data['inseminationServices'] ?? [],
      'semenStrawTypes': data['semenStrawTypes'] ?? [],
      'testResults': data['testResults'] ?? [],
      'calvingTypes': data['calvingTypes'] ?? [],
      'calvingProblems': data['calvingProblems'] ?? [],
      'reproductiveProblems': data['reproductiveProblems'] ?? [],
    };
  }

  @override
  Future<void> storeLogAdditionalData(Map<String, dynamic> data) async {
    try {
      final feedingTypes = (data['feedingTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.FeedingType.fromJson)
              .map((model) => FeedingTypesCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <FeedingTypesCompanion>[];

      final administrationRoutes = (data['administrationRoutes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.AdministrationRoute.fromJson)
              .map((model) => AdministrationRoutesCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <AdministrationRoutesCompanion>[];

      final medicineTypes = (data['medicineTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.MedicineType.fromJson)
              .map((model) => MedicineTypesCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <MedicineTypesCompanion>[];

      final medicines = (data['medicines'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.Medicine.fromJson)
              .map((model) => MedicinesCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                    medicineTypeId: Value(model.medicineTypeId),
                  ))
              .toList() ??
          const <MedicinesCompanion>[];

      final diseases = (data['diseases'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.Disease.fromJson)
              .map((model) => DiseasesCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                    status: model.status != null
                        ? Value(model.status!)
                        : const Value.absent(),
                  ))
              .toList() ??
          const <DiseasesCompanion>[];

      final disposalTypes = (data['disposalTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.DisposalType.fromJson)
              .map((model) => DisposalTypesCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <DisposalTypesCompanion>[];

      final milkingMethods = (data['milkingMethods'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.MilkingMethod.fromJson)
              .map((model) => MilkingMethodsCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <MilkingMethodsCompanion>[];

      final heatTypes = (data['heatTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.HeatType.fromJson)
              .map((model) => HeatTypesCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <HeatTypesCompanion>[];

      final inseminationServices = (data['inseminationServices'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.InseminationService.fromJson)
              .map((model) => InseminationServicesCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <InseminationServicesCompanion>[];

      final semenStrawTypes = (data['semenStrawTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.SemenStrawType.fromJson)
              .map((model) => SemenStrawTypesCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <SemenStrawTypesCompanion>[];

      final testResults = (data['testResults'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.TestResult.fromJson)
              .map((model) => TestResultsCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <TestResultsCompanion>[];

      final calvingTypes = (data['calvingTypes'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.CalvingType.fromJson)
              .map((model) => CalvingTypesCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <CalvingTypesCompanion>[];

      final calvingProblems = (data['calvingProblems'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.CalvingProblem.fromJson)
              .map((model) => CalvingProblemsCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <CalvingProblemsCompanion>[];

      final reproductiveProblems = (data['reproductiveProblems'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(logModels.ReproductiveProblem.fromJson)
              .map((model) => ReproductiveProblemsCompanion(
                    id: Value(model.id),
                    name: Value(model.name),
                  ))
              .toList() ??
          const <ReproductiveProblemsCompanion>[];

      await _dao.upsertFeedingTypes(feedingTypes);
      await _dao.upsertAdministrationRoutes(administrationRoutes);
      await _dao.upsertMedicineTypes(medicineTypes);
      await _dao.upsertMedicines(medicines);
      await _dao.upsertDiseases(diseases);
      await _dao.upsertDisposalTypes(disposalTypes);
      await _dao.upsertMilkingMethods(milkingMethods);
      await _dao.upsertHeatTypes(heatTypes);
      await _dao.upsertInseminationServices(inseminationServices);
      await _dao.upsertSemenStrawTypes(semenStrawTypes);
      await _dao.upsertTestResults(testResults);
      await _dao.upsertCalvingTypes(calvingTypes);
      await _dao.upsertCalvingProblems(calvingProblems);
      await _dao.upsertReproductiveProblems(reproductiveProblems);
    } catch (e) {
      log('❌ Error storing log additional data: $e');
      rethrow;
    }
  }

  @override
  Future<List<logModels.FeedingType>> getFeedingTypes() async {
    final entities = await _dao.getAllFeedingTypes();
    return entities
        .map((entity) => logModels.FeedingType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<logModels.AdministrationRoute>> getAdministrationRoutes() async {
    final entities = await _dao.getAllAdministrationRoutes();
    return entities
        .map((entity) => logModels.AdministrationRoute(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<logModels.MedicineType>> getMedicineTypes() async {
    final entities = await _dao.getAllMedicineTypes();
    return entities
        .map((entity) => logModels.MedicineType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<logModels.Medicine>> getMedicines() async {
    final entities = await _dao.getAllMedicines();
    return entities
        .map((entity) => logModels.Medicine(
              id: entity.id,
              name: entity.name,
              medicineTypeId: entity.medicineTypeId,
            ))
        .toList();
  }

  @override
  Future<List<logModels.Disease>> getDiseases() async {
    final entities = await _dao.getAllDiseases();
    return entities
        .map((entity) => logModels.Disease(
              id: entity.id,
              name: entity.name,
              status: entity.status,
            ))
        .toList();
  }

  @override
  Future<List<logModels.DisposalType>> getDisposalTypes() async {
    final entities = await _dao.getAllDisposalTypes();
    return entities
        .map((entity) => logModels.DisposalType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<logModels.MilkingMethod>> getMilkingMethods() async {
    final entities = await _dao.getAllMilkingMethods();
    return entities
        .map((entity) => logModels.MilkingMethod(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<logModels.HeatType>> getHeatTypes() async {
    final entities = await _dao.getAllHeatTypes();
    return entities
        .map((entity) => logModels.HeatType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<logModels.InseminationService>> getInseminationServices() async {
    final entities = await _dao.getAllInseminationServices();
    return entities
        .map((entity) =>
            logModels.InseminationService(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<logModels.SemenStrawType>> getSemenStrawTypes() async {
    final entities = await _dao.getAllSemenStrawTypes();
    return entities
        .map((entity) => logModels.SemenStrawType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<logModels.TestResult>> getTestResults() async {
    final entities = await _dao.getAllTestResults();
    return entities
        .map((entity) => logModels.TestResult(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<logModels.CalvingType>> getCalvingTypes() async {
    final entities = await _dao.getAllCalvingTypes();
    return entities
        .map((entity) => logModels.CalvingType(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<List<logModels.CalvingProblem>> getCalvingProblems() async {
    final entities = await _dao.getAllCalvingProblems();
    return entities
        .map(
          (entity) => logModels.CalvingProblem(id: entity.id, name: entity.name),
        )
        .toList();
  }

  @override
  Future<List<logModels.ReproductiveProblem>> getReproductiveProblems() async {
    final entities = await _dao.getAllReproductiveProblems();
    return entities
        .map((entity) =>
            logModels.ReproductiveProblem(id: entity.id, name: entity.name))
        .toList();
  }

  @override
  Future<void> clearLogAdditionalData() => _dao.clearAll();
}


