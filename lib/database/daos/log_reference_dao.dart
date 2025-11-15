import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../features/all.logs.additional.data/data/local/tables/feeding_type_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/administration_route_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/medicine_type_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/medicine_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/disease_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/disposal_type_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/milking_method_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/heat_type_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/insemination_service_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/semen_straw_type_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/test_result_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/calving_type_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/calving_problem_table.dart';
import '../../features/all.logs.additional.data/data/local/tables/reproductive_problem_table.dart';

part 'log_reference_dao.g.dart';

@DriftAccessor(tables: [
  FeedingTypes,
  AdministrationRoutes,
  MedicineTypes,
  Medicines,
  Diseases,
  DisposalTypes,
  MilkingMethods,
  HeatTypes,
  InseminationServices,
  SemenStrawTypes,
  TestResults,
  CalvingTypes,
  CalvingProblems,
  ReproductiveProblems,
])
class LogReferenceDao extends DatabaseAccessor<AppDatabase>
    with _$LogReferenceDaoMixin {
  LogReferenceDao(AppDatabase db) : super(db);

  Future<void> upsertFeedingTypes(List<FeedingTypesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(feedingTypes, entries);
    });
  }

  Future<void> upsertAdministrationRoutes(
      List<AdministrationRoutesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(administrationRoutes, entries);
    });
  }

  Future<void> upsertMedicineTypes(
      List<MedicineTypesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(medicineTypes, entries);
    });
  }

  Future<void> upsertMedicines(List<MedicinesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(medicines, entries);
    });
  }

  Future<void> upsertDiseases(List<DiseasesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(diseases, entries);
    });
  }

  Future<void> upsertDisposalTypes(List<DisposalTypesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(disposalTypes, entries);
    });
  }

  Future<void> upsertMilkingMethods(List<MilkingMethodsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(milkingMethods, entries);
    });
  }

  Future<void> upsertHeatTypes(List<HeatTypesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(heatTypes, entries);
    });
  }

  Future<void> upsertInseminationServices(
      List<InseminationServicesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(inseminationServices, entries);
    });
  }

  Future<void> upsertSemenStrawTypes(List<SemenStrawTypesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(semenStrawTypes, entries);
    });
  }

  Future<void> upsertTestResults(List<TestResultsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(testResults, entries);
    });
  }

  Future<void> upsertCalvingTypes(List<CalvingTypesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(calvingTypes, entries);
    });
  }

  Future<void> upsertCalvingProblems(List<CalvingProblemsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(calvingProblems, entries);
    });
  }

  Future<void> upsertReproductiveProblems(
      List<ReproductiveProblemsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(reproductiveProblems, entries);
    });
  }

  Future<List<FeedingType>> getAllFeedingTypes() =>
      select(feedingTypes).get();

  Future<List<AdministrationRouteData>> getAllAdministrationRoutes() =>
      select(administrationRoutes).get();

  Future<List<MedicineTypeData>> getAllMedicineTypes() =>
      select(medicineTypes).get();

  Future<List<MedicineData>> getAllMedicines() => select(medicines).get();

  Future<List<Disease>> getAllDiseases() => select(diseases).get();

  Future<List<DisposalType>> getAllDisposalTypes() => select(disposalTypes).get();

  Future<List<MilkingMethod>> getAllMilkingMethods() =>
      select(milkingMethods).get();

  Future<List<HeatType>> getAllHeatTypes() => select(heatTypes).get();

  Future<List<InseminationService>> getAllInseminationServices() =>
      select(inseminationServices).get();

  Future<List<SemenStrawType>> getAllSemenStrawTypes() =>
      select(semenStrawTypes).get();

  Future<List<TestResult>> getAllTestResults() => select(testResults).get();

  Future<List<CalvingType>> getAllCalvingTypes() => select(calvingTypes).get();

  Future<List<CalvingProblem>> getAllCalvingProblems() =>
      select(calvingProblems).get();

  Future<List<ReproductiveProblem>> getAllReproductiveProblems() =>
      select(reproductiveProblems).get();

  Future<void> clearAll() async {
    await batch((batch) {
      batch.deleteWhere(feedingTypes, (_) => const Constant(true));
      batch.deleteWhere(administrationRoutes, (_) => const Constant(true));
      batch.deleteWhere(medicineTypes, (_) => const Constant(true));
      batch.deleteWhere(medicines, (_) => const Constant(true));
      batch.deleteWhere(diseases, (_) => const Constant(true));
      batch.deleteWhere(disposalTypes, (_) => const Constant(true));
      batch.deleteWhere(milkingMethods, (_) => const Constant(true));
      batch.deleteWhere(heatTypes, (_) => const Constant(true));
      batch.deleteWhere(inseminationServices, (_) => const Constant(true));
      batch.deleteWhere(semenStrawTypes, (_) => const Constant(true));
      batch.deleteWhere(testResults, (_) => const Constant(true));
      batch.deleteWhere(calvingTypes, (_) => const Constant(true));
      batch.deleteWhere(calvingProblems, (_) => const Constant(true));
      batch.deleteWhere(reproductiveProblems, (_) => const Constant(true));
    });
  }
}


