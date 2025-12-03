import 'package:flutter/foundation.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart' hide FeedingType, Disease, DisposalType, MilkingMethod, HeatType, InseminationService, SemenStrawType, TestResult, CalvingType, CalvingProblem, BirthType, BirthProblem, ReproductiveProblem;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/administration_route.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/feeding_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine_type.dart';
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
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/repo/log_additional_data_repo.dart';

class LogAdditionalDataProvider extends ChangeNotifier {
  final LogAdditionalDataRepositoryInterface _repository;

  LogAdditionalDataProvider({
    required LogAdditionalDataRepositoryInterface repository,
  }) : _repository = repository;

  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  Future<void>? _initializationFuture;

  List<FeedingType> _feedingTypes = const [];
  List<AdministrationRoute> _administrationRoutes = const [];
  List<MedicineType> _medicineTypes = const [];
  List<Medicine> _medicines = const [];
  List<Disease> _diseases = const [];
  List<DisposalType> _disposalTypes = const [];
  List<MilkingMethod> _milkingMethods = const [];
  List<HeatType> _heatTypes = const [];
  List<InseminationService> _inseminationServices = const [];
  List<SemenStrawType> _semenStrawTypes = const [];
  List<TestResult> _testResults = const [];
  List<CalvingType> _calvingTypes = const [];
  List<CalvingProblem> _calvingProblems = const [];
  List<BirthType> _birthTypes = const [];
  List<BirthProblem> _birthProblems = const [];
  List<ReproductiveProblem> _reproductiveProblems = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FeedingType> get feedingTypes => _feedingTypes;
  List<AdministrationRoute> get administrationRoutes => _administrationRoutes;
  List<MedicineType> get medicineTypes => _medicineTypes;
  List<Medicine> get medicines => _medicines;
  List<Disease> get diseases => _diseases;
  List<DisposalType> get disposalTypes => _disposalTypes;
  List<MilkingMethod> get milkingMethods => _milkingMethods;
  List<HeatType> get heatTypes => _heatTypes;
  List<InseminationService> get inseminationServices => _inseminationServices;
  List<SemenStrawType> get semenStrawTypes => _semenStrawTypes;
  List<TestResult> get testResults => _testResults;
  List<CalvingType> get calvingTypes => _calvingTypes;
  List<CalvingProblem> get calvingProblems => _calvingProblems;
  List<BirthType> get birthTypes => _birthTypes;
  List<BirthProblem> get birthProblems => _birthProblems;
  List<ReproductiveProblem> get reproductiveProblems => _reproductiveProblems;

  Future<void> loadFromLocal() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _feedingTypes = await _repository.getFeedingTypes();
      _administrationRoutes = await _repository.getAdministrationRoutes();
      _medicineTypes = await _repository.getMedicineTypes();
      _medicines = await _repository.getMedicines();
      _diseases = await _repository.getDiseases();
      _disposalTypes = await _repository.getDisposalTypes();
      _milkingMethods = await _repository.getMilkingMethods();
      _heatTypes = await _repository.getHeatTypes();
      _inseminationServices = await _repository.getInseminationServices();
      _semenStrawTypes = await _repository.getSemenStrawTypes();
      _testResults = await _repository.getTestResults();
      _calvingTypes = await _repository.getCalvingTypes();
      _calvingProblems = await _repository.getCalvingProblems();
      _birthTypes = await _repository.getBirthTypes();
      _birthProblems = await _repository.getBirthProblems();
      _reproductiveProblems = await _repository.getReproductiveProblems();

      _isLoading = false;
      _initialized = true;
      _initializationFuture = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _initializationFuture = null;
      notifyListeners();
    }
  }

  Future<void> ensureLoaded() {
    if (_initialized) {
      return Future.value();
    }
    // Defer loading to avoid setState during build phase
    _initializationFuture ??= Future.microtask(() => loadFromLocal());
    return _initializationFuture!;
  }

  Future<void> refreshFromRemote(AppDatabase database) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Repository handles sync internally (calls Sync service)
      // This follows the proper flow: Provider → Repository → Sync Service
      await _repository.syncFromRemote(database);
      
      // Reload from local database after sync
      await loadFromLocal();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clear() async {
    await _repository.clearLogAdditionalData();
    _feedingTypes = const [];
    _administrationRoutes = const [];
    _medicineTypes = const [];
    _medicines = const [];
    _diseases = const [];
    _disposalTypes = const [];
    _milkingMethods = const [];
    _heatTypes = const [];
    _inseminationServices = const [];
    _semenStrawTypes = const [];
    _testResults = const [];
    _calvingTypes = const [];
    _calvingProblems = const [];
    _birthTypes = const [];
    _birthProblems = const [];
    _reproductiveProblems = const [];
    _initialized = false;
    _initializationFuture = null;
    notifyListeners();
  }
}


