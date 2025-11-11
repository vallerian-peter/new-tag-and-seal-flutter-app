import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
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

class LogAdditionalDataProvider extends ChangeNotifier {
  final LogAdditionalDataRepositoryInterface _repository;

  LogAdditionalDataProvider({
    required LogAdditionalDataRepositoryInterface repository,
  }) : _repository = repository;

  bool _isLoading = false;
  String? _error;

  List<FeedingType> _feedingTypes = const [];
  List<AdministrationRoute> _administrationRoutes = const [];
  List<MedicineType> _medicineTypes = const [];
  List<Medicine> _medicines = const [];
  List<DisposalType> _disposalTypes = const [];
  List<Disease> _diseases = const [];
  List<HeatType> _heatTypes = const [];
  List<SemenStrawType> _semenStrawTypes = const [];
  List<InseminationService> _inseminationServices = const [];
  List<MilkingMethod> _milkingMethods = const [];
  List<CalvingType> _calvingTypes = const [];
  List<CalvingProblem> _calvingProblems = const [];
  List<ReproductiveProblem> _reproductiveProblems = const [];
  List<TestResult> _testResults = const [];
  bool _hasLoaded = false;
  bool _hasAttemptedRemoteLoad = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FeedingType> get feedingTypes => _feedingTypes;
  List<AdministrationRoute> get administrationRoutes => _administrationRoutes;
  List<MedicineType> get medicineTypes => _medicineTypes;
  List<Medicine> get medicines => _medicines;
  List<DisposalType> get disposalTypes => _disposalTypes;
  List<Disease> get diseases => _diseases;
  List<HeatType> get heatTypes => _heatTypes;
  List<SemenStrawType> get semenStrawTypes => _semenStrawTypes;
  List<InseminationService> get inseminationServices => _inseminationServices;
  List<MilkingMethod> get milkingMethods => _milkingMethods;
  List<CalvingType> get calvingTypes => _calvingTypes;
  List<CalvingProblem> get calvingProblems => _calvingProblems;
  List<ReproductiveProblem> get reproductiveProblems => _reproductiveProblems;
  List<TestResult> get testResults => _testResults;

  void _scheduleNotify() {
    if (!hasListeners) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle ||
        SchedulerBinding.instance.schedulerPhase ==
            SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) {
          notifyListeners();
        }
      });
    }
  }

  bool _hasAnyData() {
    return _feedingTypes.isNotEmpty ||
        _administrationRoutes.isNotEmpty ||
        _medicineTypes.isNotEmpty ||
        _medicines.isNotEmpty ||
        _disposalTypes.isNotEmpty ||
        _diseases.isNotEmpty ||
        _heatTypes.isNotEmpty ||
        _semenStrawTypes.isNotEmpty ||
        _inseminationServices.isNotEmpty ||
        _milkingMethods.isNotEmpty ||
        _calvingTypes.isNotEmpty ||
        _calvingProblems.isNotEmpty ||
        _reproductiveProblems.isNotEmpty ||
        _testResults.isNotEmpty;
  }

  Future<void> ensureLoaded() async {
    if (!_hasLoaded || _isLoading) {
      await loadFromLocal();
    }

    if (_isLoading || _hasAnyData()) {
      return;
    }

    if (!_hasAttemptedRemoteLoad) {
      _hasAttemptedRemoteLoad = true;
      await refreshFromRemote();
      if (_error != null || !_hasAnyData()) {
        _hasAttemptedRemoteLoad = false;
      }
    }
  }

  Future<void> loadFromLocal() async {
    if (_isLoading) return;
    try {
      _isLoading = true;
      _error = null;
      _scheduleNotify();

      _feedingTypes = await _repository.getFeedingTypes();
      _administrationRoutes = await _repository.getAdministrationRoutes();
      _medicineTypes = await _repository.getMedicineTypes();
      _medicines = await _repository.getMedicines();
      _disposalTypes = await _repository.getDisposalTypes();
      _diseases = await _repository.getDiseases();
      _heatTypes = await _repository.getHeatTypes();
      _semenStrawTypes = await _repository.getSemenStrawTypes();
      _inseminationServices = await _repository.getInseminationServices();
      _milkingMethods = await _repository.getMilkingMethods();
      _calvingTypes = await _repository.getCalvingTypes();
      _calvingProblems = await _repository.getCalvingProblems();
      _reproductiveProblems = await _repository.getReproductiveProblems();
      _testResults = await _repository.getTestResults();
      _hasLoaded = true;

      _isLoading = false;
      _scheduleNotify();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _scheduleNotify();
    }
  }

  Future<void> refreshFromRemote() async {
    try {
      _isLoading = true;
      _error = null;
      _scheduleNotify();

      final remoteData = await _repository.fetchRemoteLogAdditionalData();
      await _repository.storeLogAdditionalData(remoteData);
      _hasLoaded = false;
      _hasAttemptedRemoteLoad = false;
      await loadFromLocal();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _hasAttemptedRemoteLoad = false;
      _scheduleNotify();
    }
  }

  Future<void> clear() async {
    await _repository.clearLogAdditionalData();
    _feedingTypes = const [];
    _administrationRoutes = const [];
    _medicineTypes = const [];
    _medicines = const [];
    _disposalTypes = const [];
    _diseases = const [];
    _heatTypes = const [];
    _semenStrawTypes = const [];
    _inseminationServices = const [];
    _milkingMethods = const [];
    _calvingTypes = const [];
    _calvingProblems = const [];
    _reproductiveProblems = const [];
    _testResults = const [];
    _hasLoaded = false;
    _hasAttemptedRemoteLoad = false;
    _scheduleNotify();
  }
}
