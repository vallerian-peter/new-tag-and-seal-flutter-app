import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_date_picker.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/livestock_date_entered_farm_picker.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/weight_input_with_bluetooth.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/color_helper.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/livestock_helper.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/livestock_stage_identification_rules.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/presentation/bill_creation_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/birth_event_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/models/bulk_livestock_row_draft.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/provider/livestock_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/widgets/bulk_livestock_difference_selector.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/widgets/bulk_livestock_identification.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/widgets/bulk_livestock_review_widgets.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// Registers many livestock with shared metadata and optional per-animal values.
/// Identification numbers: `YYYYMMDD-01`, `YYYYMMDD-02`, … from date of birth.
class BulkLivestockRegistrationScreen extends StatefulWidget {
  const BulkLivestockRegistrationScreen({
    super.key,
    this.preSelectedFarmUuid,
    this.preSelectedBirthEventUuid,
    this.preSelectedMotherUuid,
    this.pendingBirthEventToPersist,
  });

  final String? preSelectedFarmUuid;

  /// When provided the matching birth event will be pre-selected in the form
  /// and its litter size / dead count will be applied automatically.
  final String? preSelectedBirthEventUuid;

  /// When provided this livestock UUID will be pre-selected as the mother.
  final String? preSelectedMotherUuid;

  /// When set, the birth log is **not** in the database yet. It is created on
  /// the same final Save as the offspring batch (after preview). Implies farm
  /// is fixed to [BirthEventModel.farmUuid] and the birth-event dropdown is hidden.
  final BirthEventModel? pendingBirthEventToPersist;

  @override
  State<BulkLivestockRegistrationScreen> createState() =>
      _BulkLivestockRegistrationScreenState();
}

class _BulkLivestockRegistrationScreenState
    extends State<BulkLivestockRegistrationScreen> {
  static const int _maxLivestock = 40;
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey();
  int _currentStep = 0;

  final _livestockCountController = TextEditingController(text: '8');
  final _namePrefixController = TextEditingController();
  final _weightController = TextEditingController();
  final _deadDisposalReasonsController = TextEditingController();
  final _quickSexFemaleController = TextEditingController();
  final _quickSexMaleController = TextEditingController();
  final _quickSexFemaleDeadController = TextEditingController();
  final _quickSexMaleDeadController = TextEditingController();

  String? _selectedFarmUuid;
  int? _selectedLivestockTypeId;
  int? _selectedSpeciesId;
  int? _selectedBreedId;
  int? _selectedStageId;
  int? _selectedLivestockObtainedMethodId;
  String? _selectedMotherUuid;
  String? _selectedFatherUuid;
  String? _selectedBirthEventUuid;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedDateFirstEnteredToFarm;
  String _selectedStatus = 'active';
  String? _selectedPrimaryColor;
  String? _selectedSecondaryColor;
  bool _hasIndividualDifferences = false;
  bool _diffSex = false;
  bool _diffWeight = false;
  bool _diffNamePrefix = false;
  bool _diffIdentification = false;
  bool _diffDateOfBirth = false;
  bool _diffBirthEvent = false;
  bool _diffMother = false;
  bool _diffFather = false;
  bool _diffObtainedMethod = false;
  bool _diffDateEnteredFarm = false;
  bool _diffColors = false;
  bool _diffStatus = false;

  List<Farm> _farms = [];
  List<LivestockType> _livestockTypes = [];
  List<Specie> _species = [];
  List<Specie> _filteredSpecies = [];
  List<Breed> _breeds = [];
  List<Breed> _filteredBreeds = [];
  List<LivestockObtainedMethod> _livestockObtainedMethods = [];
  List<Livestock> _eligibleMothers = [];
  List<Livestock> _eligibleFathers = [];
  List<BirthEvent> _birthEvents = [];
  List<DisposalType> _disposalTypes = [];
  int? _deadDisposalTypeId;
  List<Stage> _stages = [];
  List<Stage> _filteredStages = [];
  List<Livestock> _allLivestock = [];

  List<BulkLivestockRowDraft> _livestockRows = [];

  bool _isLoadingData = true;
  bool _hasLoadedData = false;
  bool _l10nPrefixApplied = false;
  bool _deadDisposalReasonL10nApplied = false;
  bool _isSubmitting = false;
  bool? _isIdentifiedOverride;
  LivestockStageIdentificationRules _stageIdentificationRules =
      LivestockStageIdentificationRules.fallback;

  Stage? _getSelectedStage() {
    if (_selectedStageId == null) return null;
    for (final s in _stages) {
      if (s.id == _selectedStageId) return s;
    }
    return null;
  }

  bool get _isEarlyStageSelected {
    final stage = _getSelectedStage();
    if (stage == null) return false;
    var typeName = '';
    for (final type in _livestockTypes) {
      if (type.id == _selectedLivestockTypeId) {
        typeName = type.name;
        break;
      }
    }
    return _stageIdentificationRules.isYoungStage(
      livestockType: typeName,
      stage: stage.name,
    );
  }

  bool get _isIdentified => _isIdentifiedOverride ?? !_isEarlyStageSelected;

  bool _isRowIdentified(BulkLivestockRowDraft row) =>
      row.isIdentifiedOverride ?? _isIdentified;

  bool get _hasSelectedIndividualFields =>
      _hasIndividualDifferences &&
      (_diffSex ||
          _diffWeight ||
          _diffNamePrefix ||
          _diffIdentification ||
          _diffDateOfBirth ||
          _diffBirthEvent ||
          _diffMother ||
          _diffFather ||
          _diffObtainedMethod ||
          _diffDateEnteredFarm ||
          _diffColors ||
          _diffStatus);

  bool get _hasSelectedIndividualDetailFields =>
      _hasIndividualDifferences &&
      (_diffSex ||
          _diffDateOfBirth ||
          _diffBirthEvent ||
          _diffMother ||
          _diffFather ||
          _diffObtainedMethod ||
          _diffDateEnteredFarm ||
          _diffColors ||
          _diffStatus);

  bool get _needsIndividualCards =>
      _hasSelectedIndividualFields || _livestockRows.any(_isRowIdentified);

  bool _isBornOnFarmSelected() {
    return _isBornOnFarmMethod(_selectedLivestockObtainedMethodId);
  }

  bool _isBornOnFarmMethod(int? methodId) {
    if (methodId == null) return false;
    try {
      final m = _livestockObtainedMethods.firstWhere((e) => e.id == methodId);
      return m.name.toLowerCase().contains('born');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    final pending = widget.pendingBirthEventToPersist;
    _selectedFarmUuid = widget.preSelectedFarmUuid ?? pending?.farmUuid;
    _selectedMotherUuid =
        widget.preSelectedMotherUuid ?? pending?.livestockUuid;
  }

  @override
  void dispose() {
    _livestockCountController.dispose();
    _namePrefixController.dispose();
    _weightController.dispose();
    _deadDisposalReasonsController.dispose();
    _quickSexFemaleController.dispose();
    _quickSexMaleController.dispose();
    _quickSexFemaleDeadController.dispose();
    _quickSexMaleDeadController.dispose();
    _disposeRowControllers();
    super.dispose();
  }

  void _disposeRowControllers() {
    for (final row in _livestockRows) {
      row.namePrefixController.dispose();
      row.nicknameController.dispose();
      row.officialIdController.dispose();
      row.dummyTagIdController.dispose();
      row.barcodeTagIdController.dispose();
      row.rfidTagIdController.dispose();
      row.weightController.dispose();
      row.disposalReasonController.dispose();
      row.disposalRemarksController.dispose();
    }
    _livestockRows = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_l10nPrefixApplied) {
      _l10nPrefixApplied = true;
      final l10n = AppLocalizations.of(context)!;
      _namePrefixController.text = l10n.smallLivestockDefaultNamePrefix;
    }
    if (!_deadDisposalReasonL10nApplied) {
      _deadDisposalReasonL10nApplied = true;
      final l10n = AppLocalizations.of(context)!;
      _deadDisposalReasonsController.text =
          l10n.pigletDeadAtBirthDisposalReasonDefault;
    }
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      _loadReferenceData();
    }
  }

  Future<void> _loadReferenceData() async {
    setState(() => _isLoadingData = true);
    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      final pending = widget.pendingBirthEventToPersist;
      Livestock? dam;
      if (pending != null) {
        dam = await db.livestockDao.getLivestockByUuid(pending.livestockUuid);
      }

      final farms = await db.farmDao.getAllActiveFarms();
      final types = await db.livestockTypeDao.getAllLivestockTypes();
      final species = await db.specieDao.getAllSpecies();
      final breeds = await db.breedDao.getAllBreeds();
      final methods = await db.livestockObtainedMethodDao
          .getAllLivestockObtainedMethods();
      final stages = await db.stageDao.getAllStages();
      final stageIdentificationRules =
          await LivestockStageIdentificationRules.load();
      final birthEvents = await db.eventDao.getBirthEvents();
      final all = await db.livestockDao.getAllActiveLivestock();
      final disposalTypes = await db.logReferenceDao.getAllDisposalTypes();

      if (!mounted) return;
      setState(() {
        _farms = farms;
        _livestockTypes = types;
        _species = species;
        _breeds = breeds;
        _livestockObtainedMethods = methods;
        _stages = stages;
        _stageIdentificationRules = stageIdentificationRules;
        _birthEvents = birthEvents;
        _disposalTypes = disposalTypes;
        _allLivestock = all;
        _filteredSpecies = species;
        _filteredBreeds = breeds;
        _filteredStages = stages;
        _isLoadingData = false;
        _selectDefaultDeadDisposalType();

        if (pending != null) {
          _selectedBirthEventUuid = pending.uuid;
          _applyDraftBirthEventCountsAndDates(pending);
          if (dam != null) {
            final d = dam;
            _selectedLivestockTypeId = d.livestockTypeId;
            _filteredSpecies = species
                .where((s) => s.livestockTypeId == d.livestockTypeId)
                .toList();
            if (_filteredSpecies.isEmpty) _filteredSpecies = species;
            _filteredBreeds = breeds
                .where((b) => b.livestockTypeId == d.livestockTypeId)
                .toList();
            _filteredStages = stages
                .where((st) => st.livestockTypeId == d.livestockTypeId)
                .toList();
            if (_filteredSpecies.any((s) => s.id == d.speciesId)) {
              _selectedSpeciesId = d.speciesId;
            }
            if (_filteredBreeds.any((b) => b.id == d.breedId)) {
              _selectedBreedId = d.breedId;
            }
            Stage? earlyStage;
            var typeName = '';
            for (final type in types) {
              if (type.id == d.livestockTypeId) {
                typeName = type.name;
                break;
              }
            }
            for (final s in _filteredStages) {
              if (stageIdentificationRules.isYoungStage(
                livestockType: typeName,
                stage: s.name,
              )) {
                earlyStage = s;
                break;
              }
            }
            _selectedStageId =
                earlyStage?.id ??
                (_filteredStages.isNotEmpty ? _filteredStages.first.id : null);
          }
          for (final m in _livestockObtainedMethods) {
            if (m.name.toLowerCase().contains('born')) {
              _selectedLivestockObtainedMethodId = m.id;
              break;
            }
          }
          if (_isBornOnFarmSelected() && _selectedDateOfBirth != null) {
            _selectedDateFirstEnteredToFarm = _selectedDateOfBirth;
          }
        } else if (widget.preSelectedBirthEventUuid != null) {
          _applyBirthEventSelection(widget.preSelectedBirthEventUuid);
        }
      });
      _updateEligibleParents();
    } catch (e, st) {
      log('Bulk livestock load failed: $e\n$st');
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  void _filterBreedsAndSpeciesByType() {
    if (_selectedLivestockTypeId == null) {
      setState(() {
        _filteredSpecies = _species;
        _filteredBreeds = _breeds;
        _selectedSpeciesId = null;
        _selectedBreedId = null;
        _filteredStages = _stages;
        _selectedStageId = null;
      });
      return;
    }

    setState(() {
      _filteredSpecies = _species
          .where((s) => s.livestockTypeId == _selectedLivestockTypeId)
          .toList();
      if (_filteredSpecies.isEmpty) _filteredSpecies = _species;

      if (_selectedSpeciesId != null &&
          !_filteredSpecies.any((s) => s.id == _selectedSpeciesId)) {
        _selectedSpeciesId = null;
        _selectedBreedId = null;
      }

      _filteredBreeds = _breeds
          .where((b) => b.livestockTypeId == _selectedLivestockTypeId)
          .toList();

      if (_selectedBreedId != null &&
          !_filteredBreeds.any((b) => b.id == _selectedBreedId)) {
        _selectedBreedId = null;
      }

      _filteredStages = _stages
          .where((st) => st.livestockTypeId == _selectedLivestockTypeId)
          .toList();
      if (_selectedStageId != null &&
          !_filteredStages.any((s) => s.id == _selectedStageId)) {
        _selectedStageId = null;
      }
    });
  }

  void _updateEligibleParents() {
    if (_allLivestock.isEmpty) {
      setState(() {
        _eligibleMothers = [];
        _eligibleFathers = [];
      });
      return;
    }
    Iterable<Livestock> base = _allLivestock;
    final typeId = _selectedLivestockTypeId;
    if (typeId != null) {
      base = base.where((l) => l.livestockTypeId == typeId);
    }
    base = base.where(LivestockHelper.isActive);
    setState(() {
      _eligibleMothers = base
          .where((l) => l.gender.toLowerCase() == 'female')
          .toList();
      _eligibleFathers = base
          .where((l) => l.gender.toLowerCase() == 'male')
          .toList();

      if (_selectedMotherUuid != null &&
          !_eligibleMothers.any((l) => l.uuid == _selectedMotherUuid)) {
        _selectedMotherUuid = null;
      }
      if (_selectedFatherUuid != null &&
          !_eligibleFathers.any((l) => l.uuid == _selectedFatherUuid)) {
        _selectedFatherUuid = null;
      }
    });
  }

  void _selectDefaultDeadDisposalType() {
    if (_disposalTypes.isEmpty) {
      _deadDisposalTypeId = null;
      return;
    }
    DisposalType? pick;
    for (final t in _disposalTypes) {
      final n = t.name.toLowerCase();
      if (n.contains('dead') ||
          n.contains('died') ||
          n.contains('mortality') ||
          n.contains('stillborn')) {
        pick = t;
        break;
      }
    }
    _deadDisposalTypeId = (pick ?? _disposalTypes.first).id;
  }

  BirthEvent? _birthEventByUuid(String? uuid) {
    if (uuid == null) return null;
    for (final e in _birthEvents) {
      if (e.uuid == uuid) return e;
    }
    return null;
  }

  String? _fatherUuidForBirthEvent(String? birthEventUuid) {
    if (birthEventUuid == null) return null;
    for (final livestock in _allLivestock) {
      if (livestock.birthEventUuid == birthEventUuid &&
          livestock.fatherUuid != null &&
          livestock.fatherUuid!.isNotEmpty) {
        return livestock.fatherUuid;
      }
    }
    return null;
  }

  void _prefillSharedParentsFromBirthEvent(BirthEvent event) {
    _selectedMotherUuid = event.livestockUuid;
    final fatherUuid = _fatherUuidForBirthEvent(event.uuid);
    if (fatherUuid != null) _selectedFatherUuid = fatherUuid;
  }

  void _prefillDifferentParentsFromSharedBirthEvent() {
    if (_diffBirthEvent) return;
    final event = _birthEventByUuid(_selectedBirthEventUuid);
    if (event == null) return;
    final fatherUuid = _fatherUuidForBirthEvent(event.uuid);
    for (final row in _livestockRows) {
      if (_diffMother) row.motherUuidOverride = event.livestockUuid;
      if (_diffFather && fatherUuid != null) {
        row.fatherUuidOverride = fatherUuid;
      }
    }
  }

  void _applyRowBirthEventSelection(
    BulkLivestockRowDraft row,
    String? birthEventUuid,
  ) {
    row.birthEventUuidOverride = birthEventUuid;
    final event = _birthEventByUuid(birthEventUuid);
    if (event == null) return;
    row.motherUuidOverride = event.livestockUuid;
    final fatherUuid = _fatherUuidForBirthEvent(event.uuid);
    if (fatherUuid != null) row.fatherUuidOverride = fatherUuid;
  }

  void _applyBirthEventSelection(String? uuid) {
    _selectedBirthEventUuid = uuid;
    final e = _birthEventByUuid(uuid);
    if (e == null) return;
    _prefillSharedParentsFromBirthEvent(e);
    _prefillDifferentParentsFromSharedBirthEvent();
    if (e.totalBorn != null && e.totalBorn! > 0) {
      final c = e.totalBorn!.clamp(1, _maxLivestock);
      _livestockCountController.text = '$c';
    }
    try {
      final ds = e.startDate.split('T').first;
      final d = DateTime.parse(ds);
      _selectedDateOfBirth = DateTime(d.year, d.month, d.day);
      if (_isBornOnFarmSelected()) {
        _selectedDateFirstEnteredToFarm = _selectedDateOfBirth;
      }
    } catch (_) {}
    _syncPreviewRowsForCurrentInputs();
  }

  /// Prefill litter size and date of birth from an unsaved [BirthEventModel]
  /// (deferred / piglet-bulk-combined flow).
  void _applyDraftBirthEventCountsAndDates(BirthEventModel m) {
    if (m.totalBorn != null && m.totalBorn! > 0) {
      final c = m.totalBorn!.clamp(1, _maxLivestock);
      _livestockCountController.text = '$c';
    }
    try {
      final ds = m.startDate.split('T').first;
      final d = DateTime.parse(ds);
      _selectedDateOfBirth = DateTime(d.year, d.month, d.day);
    } catch (_) {}
  }

  String _formatBirthEventMenuLabel(BirthEvent e, AppLocalizations l10n) {
    final date = e.startDate.split('T').first;
    final head = '${e.eventType.toUpperCase()} — $date';
    if (e.totalBorn != null) {
      final dead = e.deadCount ?? 0;
      if (dead > 0) {
        return '$head · ${l10n.pigletBulkLitterTotalDead(e.totalBorn!, dead)}';
      }
      return '$head · ${l10n.pigletBulkLitterTotal(e.totalBorn!)}';
    }
    return head;
  }

  /// Returns the number of dead-at-birth slots from the linked birth event's
  /// deadCount, clamped to [count]. No longer requires litter size to match
  /// totalBorn so that dead rows are always populated when a birth event with
  /// deadCount > 0 is selected.
  int _deadAtBirthSlotsForCount(int count) {
    final pending = widget.pendingBirthEventToPersist;
    if (pending != null) {
      return (pending.deadCount ?? 0).clamp(0, count);
    }
    final e = _birthEventByUuid(_selectedBirthEventUuid);
    if (e == null) return 0;
    return (e.deadCount ?? 0).clamp(0, count);
  }

  /// Assigns sex by status groups:
  /// - alive rows use femaleAlive / maleAlive
  /// - dead rows use femaleDead / maleDead
  /// Order is preserved within each group.
  Future<void> _applyQuickSexDistribution(AppLocalizations l10n) async {
    FocusScope.of(context).unfocus();
    final aliveIndices = <int>[];
    final deadIndices = <int>[];
    for (var i = 0; i < _livestockRows.length; i++) {
      if (_isRowInactive(_livestockRows[i])) {
        deadIndices.add(i);
      } else {
        aliveIndices.add(i);
      }
    }
    final aliveExpected = aliveIndices.length;
    final deadExpected = deadIndices.length;
    if (_livestockRows.isEmpty) return;

    int parseCount(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

    final femaleAlive = parseCount(_quickSexFemaleController);
    final maleAlive = parseCount(_quickSexMaleController);
    final femaleDead = parseCount(_quickSexFemaleDeadController);
    final maleDead = parseCount(_quickSexMaleDeadController);
    if (femaleAlive < 0 || maleAlive < 0 || femaleDead < 0 || maleDead < 0) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.enterValidNumber,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }
    final aliveAssigned = femaleAlive + maleAlive;
    final deadAssigned = femaleDead + maleDead;
    if (aliveAssigned != aliveExpected || deadAssigned != deadExpected) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.pigletBulkSexCountMismatch(
          _livestockRows.length,
          aliveAssigned + deadAssigned,
        ),
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }

    setState(() {
      var aliveCursor = 0;
      for (var i = 0; i < femaleAlive; i++) {
        _livestockRows[aliveIndices[aliveCursor++]].gender = 'female';
      }
      for (var i = 0; i < maleAlive; i++) {
        _livestockRows[aliveIndices[aliveCursor++]].gender = 'male';
      }
      var deadCursor = 0;
      for (var i = 0; i < femaleDead; i++) {
        _livestockRows[deadIndices[deadCursor++]].gender = 'female';
      }
      for (var i = 0; i < maleDead; i++) {
        _livestockRows[deadIndices[deadCursor++]].gender = 'male';
      }
    });
  }

  int? _parseLivestockCount() {
    final t = _livestockCountController.text.trim();
    final n = int.tryParse(t);
    if (n == null || n < 1 || n > _maxLivestock) return null;
    return n;
  }

  String _newLivestockUuid() => const Uuid().v4();

  bool get _hasBirthEventLink =>
      widget.pendingBirthEventToPersist != null ||
      (_selectedBirthEventUuid != null && _selectedBirthEventUuid!.isNotEmpty);

  String? _effectiveBirthEventUuid(BulkLivestockRowDraft row) =>
      widget.pendingBirthEventToPersist != null
      ? _selectedBirthEventUuid
      : row.birthEventUuidOverride ?? _selectedBirthEventUuid;

  String? _effectiveMotherUuid(BulkLivestockRowDraft row) {
    final event = _birthEventByUuid(_effectiveBirthEventUuid(row));
    if (event != null) return event.livestockUuid;
    if (widget.pendingBirthEventToPersist != null) return _selectedMotherUuid;
    return row.motherUuidOverride ?? _selectedMotherUuid;
  }

  String? _effectiveFatherUuid(BulkLivestockRowDraft row) {
    final fatherUuid = _fatherUuidForBirthEvent(_effectiveBirthEventUuid(row));
    return row.fatherUuidOverride ?? fatherUuid ?? _selectedFatherUuid;
  }

  DateTime? _effectiveDateOfBirth(BulkLivestockRowDraft row) =>
      row.dateOfBirthOverride ?? _selectedDateOfBirth;

  int? _effectiveObtainedMethodId(BulkLivestockRowDraft row) =>
      row.obtainedMethodIdOverride ?? _selectedLivestockObtainedMethodId;

  DateTime? _effectiveDateEnteredFarm(BulkLivestockRowDraft row) =>
      _isBornOnFarmMethod(_effectiveObtainedMethodId(row))
      ? _effectiveDateOfBirth(row)
      : row.dateEnteredFarmOverride ?? _selectedDateFirstEnteredToFarm;

  String? _effectivePrimaryColor(BulkLivestockRowDraft row) =>
      row.primaryColorOverride ?? _selectedPrimaryColor;

  String? _effectiveSecondaryColor(BulkLivestockRowDraft row) =>
      row.secondaryColorOverride ?? _selectedSecondaryColor;

  String _effectiveStatus(BulkLivestockRowDraft row) =>
      row.isDeadAtBirth ? 'notActive' : (row.statusOverride ?? _selectedStatus);

  bool _isRowInactive(BulkLivestockRowDraft row) =>
      _effectiveStatus(row) == 'notActive';

  String _submittedIdentificationNumber(BulkLivestockRowDraft row) {
    if (!_isRowIdentified(row)) return row.identificationNumber;
    return row.officialIdController.text.trim();
  }

  String? _identifiedTagValue(
    BulkLivestockRowDraft row,
    TextEditingController controller,
  ) {
    if (!_isRowIdentified(row)) return null;
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String _labelForLivestock(String? uuid) {
    if (uuid == null || uuid.isEmpty) return '';
    for (final livestock in _allLivestock) {
      if (livestock.uuid == uuid) {
        return LivestockHelper.getDisplayLabel(
          livestock,
          fallbackPrefix: 'Livestock',
        );
      }
    }
    return '';
  }

  String _displayNameForRow({
    required BulkLivestockRowDraft row,
    required int index,
    required String prefix,
  }) {
    final nick = row.nicknameController.text.trim();
    final rowPrefix = row.namePrefixController.text.trim();
    final effectivePrefix = rowPrefix.isNotEmpty ? rowPrefix : prefix;
    return nick.isNotEmpty ? nick : '$effectivePrefix ${index + 1}';
  }

  void _clearIndividualOverrides({
    bool sex = false,
    bool weight = false,
    bool namePrefix = false,
    bool identification = false,
    bool dateOfBirth = false,
    bool birthEvent = false,
    bool mother = false,
    bool father = false,
    bool obtainedMethod = false,
    bool dateEnteredFarm = false,
    bool colors = false,
    bool status = false,
    bool all = false,
  }) {
    for (final row in _livestockRows) {
      if (all || sex) row.gender = null;
      if (all || weight) row.weightController.clear();
      if (all || namePrefix) row.namePrefixController.clear();
      if (all || identification) row.isIdentifiedOverride = null;
      if (all || dateOfBirth) row.dateOfBirthOverride = null;
      if (all || birthEvent) row.birthEventUuidOverride = null;
      if (all || mother) row.motherUuidOverride = null;
      if (all || father) row.fatherUuidOverride = null;
      if (all || obtainedMethod) row.obtainedMethodIdOverride = null;
      if (all || dateEnteredFarm) row.dateEnteredFarmOverride = null;
      if (all || colors) {
        row.primaryColorOverride = null;
        row.secondaryColorOverride = null;
      }
      if (all || status) {
        row.statusOverride = null;
        row.disposalTypeId = null;
        row.disposalDate = null;
        row.disposalReasonController.clear();
        row.disposalRemarksController.clear();
      }
      if (all) row.individualDetailsExpanded = false;
    }
  }

  void _setHasIndividualDifferences(bool value) {
    setState(() {
      _hasIndividualDifferences = value;
      if (!value) {
        _diffSex = false;
        _diffWeight = false;
        _diffNamePrefix = false;
        _diffIdentification = false;
        _diffDateOfBirth = false;
        _diffBirthEvent = false;
        _diffMother = false;
        _diffFather = false;
        _diffObtainedMethod = false;
        _diffDateEnteredFarm = false;
        _diffColors = false;
        _diffStatus = false;
        _clearIndividualOverrides(all: true);
      } else {
        _syncPreviewRowsForCurrentInputs();
      }
    });
  }

  void _setIndividualField({
    required bool value,
    bool sex = false,
    bool weight = false,
    bool namePrefix = false,
    bool identification = false,
    bool dateOfBirth = false,
    bool birthEvent = false,
    bool mother = false,
    bool father = false,
    bool obtainedMethod = false,
    bool dateEnteredFarm = false,
    bool colors = false,
    bool status = false,
  }) {
    setState(() {
      if (sex) _diffSex = value;
      if (weight) _diffWeight = value;
      if (namePrefix) _diffNamePrefix = value;
      if (identification) _diffIdentification = value;
      if (dateOfBirth) _diffDateOfBirth = value;
      if (birthEvent) _diffBirthEvent = value;
      if (mother) _diffMother = value;
      if (father) _diffFather = value;
      if (obtainedMethod) _diffObtainedMethod = value;
      if (dateEnteredFarm) _diffDateEnteredFarm = value;
      if (colors) _diffColors = value;
      if (status) _diffStatus = value;
      if (!value) {
        _clearIndividualOverrides(
          sex: sex,
          weight: weight,
          namePrefix: namePrefix,
          identification: identification,
          dateOfBirth: dateOfBirth,
          birthEvent: birthEvent,
          mother: mother || birthEvent,
          father: father || birthEvent,
          obtainedMethod: obtainedMethod,
          dateEnteredFarm: dateEnteredFarm,
          colors: colors,
          status: status,
        );
        if (dateOfBirth) _refreshRowIdentificationNumbers();
        if (birthEvent) _prefillDifferentParentsFromSharedBirthEvent();
      } else {
        for (final row in _livestockRows) {
          row.individualDetailsExpanded = true;
        }
        _syncPreviewRowsForCurrentInputs();
      }
    });
  }

  void _syncPreviewRowsForCurrentInputs() {
    final count = _parseLivestockCount();
    if (count == null) return;
    _buildPreviewRows(count);
  }

  void _buildPreviewRows(int count) {
    _quickSexFemaleController.clear();
    _quickSexMaleController.clear();
    _quickSexFemaleDeadController.clear();
    _quickSexMaleDeadController.clear();
    final deadSlots = _deadAtBirthSlotsForCount(count);
    final nextRows = <BulkLivestockRowDraft>[];
    for (var i = 0; i < count; i++) {
      final row = i < _livestockRows.length
          ? _livestockRows[i]
          : BulkLivestockRowDraft(
              identificationNumber: '',
              uuid: _newLivestockUuid(),
              namePrefixController: TextEditingController(),
              nicknameController: TextEditingController(),
              officialIdController: TextEditingController(),
              dummyTagIdController: TextEditingController(),
              barcodeTagIdController: TextEditingController(),
              rfidTagIdController: TextEditingController(),
              weightController: TextEditingController(),
              disposalReasonController: TextEditingController(),
              disposalRemarksController: TextEditingController(),
              isDeadAtBirth: false,
            );
      final dob = _effectiveDateOfBirth(row);
      row.identificationNumber = dob == null
          ? '${i + 1}'
          : buildBulkLivestockIdentificationSerial(dob, i + 1, count);
      row.isDeadAtBirth = i >= count - deadSlots;
      if (_hasSelectedIndividualFields) row.individualDetailsExpanded = true;
      nextRows.add(row);
    }
    for (var i = count; i < _livestockRows.length; i++) {
      _livestockRows[i].namePrefixController.dispose();
      _livestockRows[i].nicknameController.dispose();
      _livestockRows[i].officialIdController.dispose();
      _livestockRows[i].dummyTagIdController.dispose();
      _livestockRows[i].barcodeTagIdController.dispose();
      _livestockRows[i].rfidTagIdController.dispose();
      _livestockRows[i].weightController.dispose();
      _livestockRows[i].disposalReasonController.dispose();
      _livestockRows[i].disposalRemarksController.dispose();
    }
    _livestockRows = nextRows;
    _prefillDifferentParentsFromSharedBirthEvent();
  }

  void _refreshRowIdentificationNumbers() {
    final total = _livestockRows.length;
    for (var i = 0; i < total; i++) {
      final row = _livestockRows[i];
      final dob = _effectiveDateOfBirth(row);
      row.identificationNumber = dob == null
          ? '${i + 1}'
          : buildBulkLivestockIdentificationSerial(dob, i + 1, total);
    }
  }

  void _setRowDateOfBirthOverride(
    BulkLivestockRowDraft row,
    DateTime? dateOfBirth,
  ) {
    row.dateOfBirthOverride = dateOfBirth;
    if (_isBornOnFarmMethod(_effectiveObtainedMethodId(row))) {
      row.dateEnteredFarmOverride = _effectiveDateOfBirth(row);
    }
    _refreshRowIdentificationNumbers();
  }

  Future<void> _onStepContinue() async {
    final l10n = AppLocalizations.of(context)!;

    if (_currentStep == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      final count = _parseLivestockCount();
      setState(() {
        if (count != null) _buildPreviewRows(count);
        _currentStep = 1;
      });
      return;
    }

    if (_currentStep == 1) {
      if (_hasIndividualDifferences && !_hasSelectedIndividualFields) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pigletBulkSelectAtLeastOneDifferentField,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
      if (!(_formKey.currentState?.validate() ?? false)) return;
      final count = _parseLivestockCount();
      if (count == null) return;
      setState(() {
        _buildPreviewRows(count);
        _currentStep = 2;
      });
      return;
    }

    // Preview — sex is required for every row.
    for (final row in _livestockRows) {
      if (row.gender == null || row.gender!.isEmpty) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pigletBulkSelectSexEach,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
    }

    final deadPreview = _livestockRows.where(_isRowInactive).length;
    final alivePreview = _livestockRows.length - deadPreview;
    if (alivePreview < 0 ||
        (alivePreview + deadPreview) != _livestockRows.length) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.pigletBulkFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }
    if (widget.pendingBirthEventToPersist != null &&
        (_selectedMotherUuid == null || _selectedMotherUuid!.isEmpty)) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.pigletBulkMotherRequiredForBirthFlow,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }
    if (deadPreview > 0 &&
        (_deadDisposalTypeId == null || _disposalTypes.isEmpty)) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.pigletBulkSelectDisposalTypeForDead,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }
    for (var i = 0; i < _livestockRows.length; i++) {
      final row = _livestockRows[i];
      final dateOfBirth = _effectiveDateOfBirth(row);
      final dateEnteredFarm = _effectiveDateEnteredFarm(row);
      if (dateOfBirth != null &&
          dateEnteredFarm != null &&
          dateEnteredFarm.isBefore(dateOfBirth)) {
        row.individualDetailsExpanded = true;
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pigletBulkDateEnteredBeforeBirth(i + 1),
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        if (mounted) setState(() {});
        return;
      }
      if (!_isRowInactive(row)) continue;
      final disposalTypeId = row.disposalTypeId ?? _deadDisposalTypeId;
      if (disposalTypeId == null || _disposalTypes.isEmpty) {
        row.individualDetailsExpanded = true;
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pigletBulkInactiveDisposalRequired(i + 1),
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        if (mounted) setState(() {});
        return;
      }
      final reason = row.disposalReasonController.text.trim();
      if (reason.isEmpty &&
          _deadDisposalReasonsController.text.trim().isEmpty) {
        row.individualDetailsExpanded = true;
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pigletBulkInactiveReasonRequired(i + 1),
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        if (mounted) setState(() {});
        return;
      }
    }

    if (!mounted) return;
    final provider = context.read<LivestockProvider>();
    final ids = _livestockRows.map(_submittedIdentificationNumber).toList();
    if (ids.toSet().length != ids.length) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.pigletBulkDuplicateIdentificationValues,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }
    final taken = await provider.findExistingIdentificationNumbers(ids);
    if (taken.isNotEmpty && mounted) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message:
            '${l10n.pigletBulkIdConflict}\n\n${l10n.pigletBulkConflictingIds(taken.join(', '))}',
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }

    final rfidValues = _livestockRows
        .map((row) => _identifiedTagValue(row, row.rfidTagIdController))
        .whereType<String>()
        .toList();
    final barcodeValues = _livestockRows
        .map((row) => _identifiedTagValue(row, row.barcodeTagIdController))
        .whereType<String>()
        .toList();
    final hasDuplicateRfid = rfidValues.toSet().length != rfidValues.length;
    final hasDuplicateBarcode =
        barcodeValues.toSet().length != barcodeValues.length;
    final rfidUnique = await Future.wait(
      rfidValues.map(provider.isRfidTagIdUnique),
    );
    final barcodeUnique = await Future.wait(
      barcodeValues.map(provider.isBarcodeTagIdUnique),
    );
    if (!mounted) return;
    if (hasDuplicateRfid || rfidUnique.any((isUnique) => !isUnique)) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.rfidTagIdExists,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }
    if (hasDuplicateBarcode || barcodeUnique.any((isUnique) => !isUnique)) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.barcodeTagIdExists,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }

    if (!mounted) return;
    await AlertDialogs.showConfirmation(
      context: context,
      title: l10n.register,
      message: l10n.pigletBulkConfirmRegister(_livestockRows.length),
      confirmText: l10n.pigletBulkRegisterAll,
      cancelText: l10n.cancel,
      onConfirm: () async {
        Navigator.of(context).pop(true);
        await _submitBatch(l10n);
      },
    );
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitBatch(AppLocalizations l10n) async {
    if (_selectedFarmUuid == null ||
        _selectedDateOfBirth == null ||
        _selectedDateFirstEnteredToFarm == null ||
        _selectedLivestockTypeId == null ||
        _selectedSpeciesId == null ||
        _selectedBreedId == null) {
      return;
    }

    final speciesId = _selectedSpeciesId ?? _selectedLivestockTypeId!;
    final prefix = _namePrefixController.text.trim().isEmpty
        ? l10n.smallLivestockDefaultNamePrefix
        : _namePrefixController.text.trim();
    final rawWeightText = _weightController.text.trim();
    final parsedWeight = rawWeightText.isEmpty
        ? null
        : double.tryParse(rawWeightText);
    if (parsedWeight != null && parsedWeight <= 0) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.enterValidWeight,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }
    final commonWeight = parsedWeight;
    const weightDeadFloor = 0.01;

    final livestockProvider = context.read<LivestockProvider>();
    final eventsProvider = context.read<EventsProvider>();
    setState(() => _isSubmitting = true);
    var loadingDialogOpen = false;

    try {
      AlertDialogs.showLoading(
        context: context,
        title: l10n.save,
        message: l10n.pigletBulkSavingMessage,
        isDismissible: false,
      );
      loadingDialogOpen = true;

      var effectiveBirthUuid = _selectedBirthEventUuid;
      final pending = widget.pendingBirthEventToPersist;
      if (pending != null) {
        final totalRows = _livestockRows.length;
        final deadN = _livestockRows.where(_isRowInactive).length;
        final nowIso = DateTime.now().toIso8601String();
        final dobIso = _selectedDateOfBirth!.toIso8601String();
        final reconciled = pending.copyWith(
          totalBorn: totalRows,
          deadCount: deadN,
          aliveCount: totalRows - deadN,
          startDate: dobIso,
          eventDate:
              (pending.eventDate != null &&
                  pending.eventDate!.trim().isNotEmpty)
              ? pending.eventDate
              : dobIso,
          updatedAt: nowIso,
        );
        await eventsProvider.addBirthEvent(reconciled);
        effectiveBirthUuid = reconciled.uuid;
      }

      final items = <Map<String, dynamic>>[];
      for (var i = 0; i < _livestockRows.length; i++) {
        final row = _livestockRows[i];
        final dateOfBirth = _effectiveDateOfBirth(row);
        if (dateOfBirth == null) {
          if (!mounted) return;
          Navigator.of(context).pop();
          setState(() => _isSubmitting = false);
          await AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message: l10n.pleaseSelectDateOfBirth,
            buttonText: l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
          );
          return;
        }
        row.uuid ??= _newLivestockUuid();
        final nick = row.nicknameController.text.trim();
        final rowPrefix = row.namePrefixController.text.trim();
        final effectivePrefix = rowPrefix.isNotEmpty ? rowPrefix : prefix;
        final name = nick.isNotEmpty ? nick : '$effectivePrefix ${i + 1}';

        final gender = row.gender!;

        final status = _effectiveStatus(row);
        final rowWeightRaw = row.weightController.text.trim();
        final rowWeightParsed = rowWeightRaw.isEmpty
            ? null
            : double.tryParse(rowWeightRaw);
        if (rowWeightParsed != null && rowWeightParsed <= 0) {
          if (!mounted) return;
          Navigator.of(context).pop();
          setState(() => _isSubmitting = false);
          await AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message: l10n.enterValidWeight,
            buttonText: l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
          );
          return;
        }
        final effectiveWeight = rowWeightParsed ?? commonWeight ?? 0.0;
        final w = _isRowInactive(row)
            ? (effectiveWeight < weightDeadFloor
                  ? weightDeadFloor
                  : effectiveWeight)
            : effectiveWeight;
        final dateEnteredFarm = _effectiveDateEnteredFarm(row);
        if (dateEnteredFarm == null) {
          if (!mounted) return;
          Navigator.of(context).pop();
          setState(() => _isSubmitting = false);
          await AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message: l10n.pleaseSelectDateEnteredFarm,
            buttonText: l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
          );
          return;
        }
        final rowBirthEventUuid = widget.pendingBirthEventToPersist != null
            ? effectiveBirthUuid
            : _effectiveBirthEventUuid(row);

        items.add({
          'farmUuid': _selectedFarmUuid,
          'uuid': row.uuid,
          'identificationNumber': _submittedIdentificationNumber(row),
          'dummyTagId': _identifiedTagValue(row, row.dummyTagIdController),
          'barcodeTagId': _identifiedTagValue(row, row.barcodeTagIdController),
          'rfidTagId': _identifiedTagValue(row, row.rfidTagIdController),
          'livestockTypeId': _selectedLivestockTypeId,
          'name': name,
          'dateOfBirth': dateOfBirth.toIso8601String().split('T').first,
          'motherUuid': _effectiveMotherUuid(row),
          'fatherUuid': _effectiveFatherUuid(row),
          'birthEventUuid': rowBirthEventUuid,
          'gender': gender,
          'breedId': _selectedBreedId,
          'speciesId': speciesId,
          'status': status,
          'livestockObtainedMethodId': _effectiveObtainedMethodId(row) ?? 1,
          'dateFirstEnteredToFarm': dateEnteredFarm,
          'weightAsOnRegistration': w,
          'primaryColor': _effectivePrimaryColor(row),
          'secondaryColor': _effectiveSecondaryColor(row),
          'stageId': _selectedStageId,
          'isIdentified': _isRowIdentified(row),
        });
      }

      final created = await livestockProvider.createLivestockBatch(items);

      if (!mounted) return;
      final createdCount = created?.length ?? 0;
      if (created == null || createdCount != items.length) {
        if (loadingDialogOpen) {
          Navigator.of(context).pop();
          loadingDialogOpen = false;
        }
        setState(() => _isSubmitting = false);
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pigletBulkBatchSizeMismatch(items.length, createdCount),
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }

      var disposalFailures = 0;
      final inactiveIndices = <int>[];
      for (var i = 0; i < _livestockRows.length; i++) {
        if (_isRowInactive(_livestockRows[i])) inactiveIndices.add(i);
      }

      // Batch-size mismatch is handled above, so every row maps to a created
      // livestock entry and disposal tracing remains complete.
      if (inactiveIndices.isNotEmpty) {
        final now = DateTime.now().toIso8601String();

        for (final i in inactiveIndices) {
          final row = _livestockRows[i];
          try {
            final livestockUuid = created[i].uuid;
            final uuid =
                'disposal-${DateTime.now().microsecondsSinceEpoch}-$i-${livestockUuid.hashCode}';
            final disposalDate = _isRowInactive(row)
                ? _effectiveDateOfBirth(row)!
                : (row.disposalDate ?? DateTime.now());
            final rowReason = row.disposalReasonController.text.trim();
            final commonReason = _deadDisposalReasonsController.text.trim();
            final reasons = rowReason.isNotEmpty
                ? rowReason
                : commonReason.isNotEmpty
                ? commonReason
                : l10n.pigletDeadAtBirthDisposalReasonDefault;
            final remarks = row.disposalRemarksController.text.trim();
            await eventsProvider.addDisposal(
              DisposalModel(
                uuid: uuid,
                farmUuid: _selectedFarmUuid!,
                livestockUuid: livestockUuid,
                disposalTypeId: row.disposalTypeId ?? _deadDisposalTypeId,
                reasons: reasons,
                remarks: remarks.isEmpty ? null : remarks,
                status: 'completed',
                eventDate: disposalDate.toIso8601String(),
                synced: false,
                syncAction: 'create',
                createdAt: now,
                updatedAt: now,
              ),
            );
          } catch (e, st) {
            disposalFailures++;
            log('Piglet disposal error: $e\n$st');
          }
        }
      }

      if (!mounted) return;
      if (loadingDialogOpen) {
        Navigator.of(context).pop();
        loadingDialogOpen = false;
      }

      setState(() => _isSubmitting = false);

      if (created.isNotEmpty) {
        if (!mounted) return;
        await BillCreationHelper.maybeCreateBillForLivestockBatch(
          context: context,
          farmUuid: _selectedFarmUuid!,
          livestockCount: created.length,
          referenceLivestockUuid: created.first.uuid,
        );

        if (!mounted) return;

        final inactiveN = inactiveIndices.length;
        final hasPartialFailure = disposalFailures > 0 && inactiveN > 0;
        if (hasPartialFailure) {
          await AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message:
                '${l10n.pigletBulkSuccess(created.length)}\n\n${l10n.pigletBulkDisposalPartialFailure}',
            buttonText: l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
          );
        } else {
          var successMsg = pending != null
              ? '${l10n.birthEventSaved}\n\n${l10n.pigletBulkSuccess(created.length)}'
              : l10n.pigletBulkSuccess(created.length);
          if (inactiveN > 0) {
            successMsg =
                '$successMsg\n\n${l10n.pigletBulkSuccessDisposals(inactiveN)}';
          }

          await AlertDialogs.showSuccess(
            context: context,
            title: l10n.success,
            message: successMsg,
            buttonText: l10n.ok,
          );
        }

        if (mounted) Navigator.of(context).pop(true);
      } else if (mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pigletBulkFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
    } catch (e, st) {
      log('Bulk livestock submit error: $e\n$st');
      if (mounted) {
        try {
          if (loadingDialogOpen) {
            Navigator.of(context).pop();
            loadingDialogOpen = false;
          }
        } catch (_) {}
        setState(() => _isSubmitting = false);
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pigletBulkFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
    }
  }

  Widget _infoCard(AppLocalizations l10n, ThemeData theme, String message) =>
      BulkLivestockInfoCard(message: message);

  Widget _sectionTitle(String title, String subtitle) =>
      BulkLivestockSectionTitle(title: title, subtitle: subtitle);

  Widget _buildFinalReviewGuardCard(
    AppLocalizations l10n,
    ThemeData theme,
    int alive,
    int dead,
  ) => BulkLivestockReviewGuardCard(
    total: _livestockRows.length,
    alive: alive,
    dead: dead,
    hasDisposalType: _deadDisposalTypeId != null,
  );

  Widget _buildIndividualDifferenceSelector(AppLocalizations l10n) {
    final birthEventCanDiffer = widget.pendingBirthEventToPersist == null;

    return BulkLivestockDifferenceSelector(
      enabled: _hasIndividualDifferences,
      hasSelection: _hasSelectedIndividualFields,
      onEnabledChanged: _setHasIndividualDifferences,
      options: [
        BulkLivestockDifferenceOption(
          label: l10n.gender,
          icon: Icons.wc_outlined,
          selected: _diffSex,
          onChanged: (value) => _setIndividualField(value: value, sex: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.weightKg,
          icon: Icons.monitor_weight_outlined,
          selected: _diffWeight,
          onChanged: (value) => _setIndividualField(value: value, weight: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.pigletBulkNamePrefix,
          icon: Icons.badge_outlined,
          selected: _diffNamePrefix,
          onChanged: (value) =>
              _setIndividualField(value: value, namePrefix: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.identificationStatus,
          icon: Icons.verified_outlined,
          selected: _diffIdentification,
          onChanged: (value) =>
              _setIndividualField(value: value, identification: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.dateOfBirth,
          icon: Icons.cake_outlined,
          selected: _diffDateOfBirth,
          onChanged: (value) =>
              _setIndividualField(value: value, dateOfBirth: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.birthEventOptional,
          icon: Icons.child_friendly_outlined,
          selected: _diffBirthEvent,
          enabled: birthEventCanDiffer,
          onChanged: (value) =>
              _setIndividualField(value: value, birthEvent: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.motherOptional,
          icon: Icons.female_outlined,
          selected: _diffMother,
          enabled: birthEventCanDiffer,
          disabledReason: l10n.pigletBulkMotherLockedByBirthEvent,
          onChanged: (value) => _setIndividualField(value: value, mother: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.fatherOptional,
          icon: Icons.male_outlined,
          selected: _diffFather,
          onChanged: (value) => _setIndividualField(value: value, father: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.obtainedMethod,
          icon: Icons.source_outlined,
          selected: _diffObtainedMethod,
          onChanged: (value) =>
              _setIndividualField(value: value, obtainedMethod: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.dateEnteredFarmRequired,
          icon: Icons.login_outlined,
          selected: _diffDateEnteredFarm,
          onChanged: (value) =>
              _setIndividualField(value: value, dateEnteredFarm: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.colorInformation,
          icon: Icons.palette_outlined,
          selected: _diffColors,
          onChanged: (value) => _setIndividualField(value: value, colors: true),
        ),
        BulkLivestockDifferenceOption(
          label: l10n.status,
          icon: Icons.flag_outlined,
          selected: _diffStatus,
          onChanged: (value) => _setIndividualField(value: value, status: true),
        ),
      ],
    );
  }

  Widget _buildCommonPerAnimalSetup(AppLocalizations l10n, ThemeData theme) {
    final count = _parseLivestockCount();
    if (count == null) {
      return _infoCard(l10n, theme, l10n.pigletBulkInvalidCount(_maxLivestock));
    }
    if (_livestockRows.length != count) {
      return _infoCard(l10n, theme, l10n.pigletBulkDifferentDataHelp);
    }
    final prefix = _namePrefixController.text.trim().isEmpty
        ? l10n.smallLivestockDefaultNamePrefix
        : _namePrefixController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          l10n.pigletBulkIndividualDetails,
          l10n.pigletBulkIndividualFieldsPreviewHelp,
        ),
        const SizedBox(height: 12),
        ...List.generate(_livestockRows.length, (index) {
          final row = _livestockRows[index];
          final animalLabel = _displayNameForRow(
            row: row,
            index: index,
            prefix: prefix,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Constants.primaryColor.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Constants.primaryColor,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          animalLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.pigletBulkSystemReference}: ${row.identificationNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
                    ),
                  ),
                  if (_diffIdentification) ...[
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _isRowIdentified(row),
                      activeThumbColor: Constants.primaryColor,
                      title: Text(l10n.pigletBulkIdentificationSwitchTitle),
                      subtitle: Text(
                        _isRowIdentified(row)
                            ? l10n.identified
                            : l10n.notIdentified,
                      ),
                      onChanged: (value) =>
                          setState(() => row.isIdentifiedOverride = value),
                    ),
                  ],
                  if (_isRowIdentified(row)) ...[
                    const SizedBox(height: 12),
                    BulkLivestockAnimalIdentificationFields(
                      officialIdController: row.officialIdController,
                      dummyTagIdController: row.dummyTagIdController,
                      barcodeTagIdController: row.barcodeTagIdController,
                      rfidTagIdController: row.rfidTagIdController,
                    ),
                  ],
                  if (_diffNamePrefix) ...[
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: row.namePrefixController,
                      label: l10n.pigletBulkNamePrefix,
                      hintText: l10n.pigletBulkSameAsBatch,
                      prefixIcon: Icons.badge_outlined,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  if (_diffWeight) ...[
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: row.weightController,
                      label: l10n.pigletBulkWeightPerRowLabel,
                      hintText: l10n.pigletBulkWeightPerRowHint,
                      prefixIcon: Icons.monitor_weight_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                    ),
                  ],
                  if (_hasSelectedIndividualDetailFields ||
                      _isRowInactive(row)) ...[
                    const SizedBox(height: 12),
                    _buildRowIndividualDetails(l10n, theme, row, index),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCommonStep(
    AppLocalizations l10n,
    ThemeData theme, {
    required bool showSetup,
    required bool showBatch,
  }) {
    const showSharedWeight = true;
    const showSharedObtainedMethod = true;
    const showSharedDateEnteredFarm = true;
    const showSharedColors = true;
    final showSharedStatus = !_diffStatus;
    final showSharedParentage = _isBornOnFarmSelected() || _hasBirthEventLink;
    const showSharedAcquisition = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSetup) ...[
          _sectionTitle(l10n.farmLocation, l10n.selectWhereLocated),
          const SizedBox(height: 12),
          CustomDropdown<String>(
            label: l10n.farm,
            hint: l10n.select,
            icon: Icons.agriculture_outlined,
            value: _selectedFarmUuid,
            enabled: widget.pendingBirthEventToPersist == null,
            dropdownItems: _farms
                .map((f) => DropdownItem(value: f.uuid, label: f.name))
                .toList(),
            onChanged: (v) {
              setState(() {
                _selectedFarmUuid = v;
                if (_selectedBirthEventUuid != null) {
                  final ok = _birthEvents.any(
                    (e) => e.uuid == _selectedBirthEventUuid && e.farmUuid == v,
                  );
                  if (!ok) _selectedBirthEventUuid = null;
                }
              });
            },
            validator: (v) =>
                (v == null || v.isEmpty) ? l10n.pleaseSelectFarm : null,
          ),
          if (widget.pendingBirthEventToPersist != null) ...[
            const SizedBox(height: 12),
            _infoCard(l10n, theme, l10n.pigletBulkDeferredBirthHint),
          ],
          const SizedBox(height: 24),
          _sectionTitle(
            l10n.livestockClassification,
            l10n.selectTypeSpeciesBreed,
          ),
          const SizedBox(height: 12),
          CustomDropdown<int>(
            label: l10n.livestockType,
            hint: l10n.select,
            icon: Icons.category_outlined,
            value: _selectedLivestockTypeId,
            dropdownItems: _livestockTypes
                .map((t) => DropdownItem(value: t.id, label: t.name))
                .toList(),
            onChanged: (v) {
              setState(() {
                _selectedLivestockTypeId = v;
                _isIdentifiedOverride = null;
              });
              _filterBreedsAndSpeciesByType();
              _updateEligibleParents();
            },
            validator: (v) => v == null ? l10n.livestockTypeRequired : null,
          ),
          const SizedBox(height: 16),
          CustomDropdown<int>(
            key: ValueKey(
              'pb_species_${_selectedLivestockTypeId}_${_filteredSpecies.length}',
            ),
            label: l10n.species,
            hint: _selectedLivestockTypeId == null
                ? l10n.pleaseSelectLivestockType
                : l10n.select,
            icon: Icons.pets_outlined,
            value: _selectedSpeciesId,
            enabled: _selectedLivestockTypeId != null,
            dropdownItems: _filteredSpecies
                .map((s) => DropdownItem(value: s.id, label: s.name))
                .toList(),
            onChanged: (v) => setState(() {
              _selectedSpeciesId = v;
              _selectedBreedId = null;
            }),
            validator: (v) {
              if (_selectedLivestockTypeId == null) return null;
              return v == null ? l10n.speciesRequired : null;
            },
          ),
          const SizedBox(height: 16),
          CustomDropdown<int>(
            key: ValueKey(
              'pb_breed_${_selectedLivestockTypeId}_${_selectedSpeciesId}_${_filteredBreeds.length}',
            ),
            label: l10n.breed,
            hint: _selectedLivestockTypeId == null
                ? l10n.pleaseSelectLivestockType
                : (_selectedSpeciesId == null
                      ? l10n.pleaseSelectSpecies
                      : l10n.select),
            icon: Icons.menu_book_outlined,
            value: _selectedBreedId,
            enabled:
                _selectedLivestockTypeId != null && _selectedSpeciesId != null,
            dropdownItems: _filteredBreeds
                .map((b) => DropdownItem(value: b.id, label: b.name))
                .toList(),
            onChanged: (v) => setState(() => _selectedBreedId = v),
            validator: (v) {
              if (_selectedLivestockTypeId == null ||
                  _selectedSpeciesId == null) {
                return null;
              }
              return v == null ? l10n.breedRequired : null;
            },
          ),
          const SizedBox(height: 16),
          CustomDropdown<int>(
            label: l10n.stage,
            hint: _selectedLivestockTypeId == null
                ? l10n.pleaseSelectLivestockType
                : l10n.select,
            icon: Icons.stacked_line_chart_outlined,
            value: _selectedStageId,
            enabled: _selectedLivestockTypeId != null,
            dropdownItems: _filteredStages
                .map((s) => DropdownItem(value: s.id, label: s.name))
                .toList(),
            onChanged: (v) => setState(() {
              _selectedStageId = v;
              _isIdentifiedOverride = null;
              for (final row in _livestockRows) {
                row.isIdentifiedOverride = null;
              }
            }),
            isRequired: false,
          ),
        ],
        if (showBatch) ...[
          _sectionTitle(
            l10n.pigletBulkNumberOfPiglets,
            l10n.pigletBulkNamePrefixHint,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _livestockCountController,
            label: '${l10n.pigletBulkNumberOfPiglets} *',
            hintText: l10n.pigletBulkCountRangeHint(_maxLivestock),
            prefixIcon: Icons.groups_2_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              if (!_needsIndividualCards) return;
              setState(_syncPreviewRowsForCurrentInputs);
            },
            validator: (value) {
              if (_parseLivestockCount() == null) {
                return l10n.pigletBulkInvalidCount(_maxLivestock);
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pigletBulkNumberOfPigletsHelp,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildIndividualDifferenceSelector(l10n),
          if (widget.pendingBirthEventToPersist == null) ...[
            const SizedBox(height: 24),
            _buildSharedBirthEventSection(l10n, theme),
          ],
          const SizedBox(height: 24),
          _buildIdentificationSwitch(),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _namePrefixController,
            label: '${l10n.pigletBulkNamePrefix} *',
            hintText: l10n.pigletBulkNamePrefixHint,
            prefixIcon: Icons.badge_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.nameRequired;
              }
              return null;
            },
          ),
          if (showSharedWeight) ...[
            const SizedBox(height: 24),
            WeightInputWithBluetooth(
              controller: _weightController,
              label: l10n.weightKg,
              hintText: l10n.enterWeightOrBluetooth,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final w = double.tryParse(value.trim());
                if (w == null || w <= 0) {
                  return l10n.enterValidWeight;
                }
                return null;
              },
              onWeightChanged: (_) {},
            ),
            const SizedBox(height: 16),
          ],
          CustomDatePicker(
            label: l10n.dateOfBirth,
            hint: l10n.selectDateOfBirth,
            selectedDate: _selectedDateOfBirth,
            onDateSelected: (date) {
              setState(() {
                _selectedDateOfBirth = date;
                if (_isBornOnFarmSelected()) {
                  _selectedDateFirstEnteredToFarm = date;
                }
                if (_hasSelectedIndividualFields) {
                  _refreshRowIdentificationNumbers();
                }
              });
            },
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            dateValidator: (date) =>
                date == null ? l10n.pleaseSelectDateOfBirth : null,
          ),
          if (showSharedColors) ...[
            const SizedBox(height: 24),
            _sectionTitle(l10n.colorInformation, l10n.colorInformationSubtitle),
            const SizedBox(height: 12),
            CustomDropdown<String>(
              label: l10n.primaryColor,
              hint: l10n.selectPrimaryColor,
              icon: Icons.palette_outlined,
              value: _selectedPrimaryColor,
              dropdownItems: ColorHelper.getColorDropdownItems(l10n),
              onChanged: (v) => setState(() {
                _selectedPrimaryColor = v;
                if (_selectedPrimaryColor == _selectedSecondaryColor) {
                  _selectedSecondaryColor = null;
                }
              }),
              isRequired: false,
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              key: ValueKey('pb_sec_$_selectedPrimaryColor'),
              label: l10n.secondaryColor,
              hint: l10n.selectSecondaryColor,
              icon: Icons.color_lens_outlined,
              value: _selectedSecondaryColor,
              dropdownItems: ColorHelper.getColorDropdownItems(
                l10n,
                excludeColor: _selectedPrimaryColor,
              ),
              onChanged: (v) => setState(() => _selectedSecondaryColor = v),
              isRequired: false,
            ),
          ],
          if (showSharedAcquisition) ...[
            const SizedBox(height: 24),
            _sectionTitle(l10n.acquisitionDetails, l10n.howAndWhenObtained),
            if (showSharedObtainedMethod) ...[
              const SizedBox(height: 12),
              CustomDropdown<int>(
                label: l10n.obtainedMethod,
                hint: l10n.select,
                icon: Icons.source_outlined,
                value: _selectedLivestockObtainedMethodId,
                dropdownItems: _livestockObtainedMethods
                    .map((m) => DropdownItem(value: m.id, label: m.name))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedLivestockObtainedMethodId = v;
                    if (v != null) {
                      final m = _livestockObtainedMethods.firstWhere(
                        (e) => e.id == v,
                        orElse: () => _livestockObtainedMethods.first,
                      );
                      if (m.name.toLowerCase().contains('born') &&
                          _selectedDateOfBirth != null) {
                        _selectedDateFirstEnteredToFarm = _selectedDateOfBirth;
                      } else {
                        _selectedMotherUuid = null;
                        _selectedFatherUuid = null;
                      }
                    } else {
                      _selectedMotherUuid = null;
                      _selectedFatherUuid = null;
                    }
                  });
                },
              ),
            ],
            if (showSharedDateEnteredFarm) ...[
              const SizedBox(height: 16),
              LivestockDateEnteredFarmPicker(
                label: l10n.dateEnteredFarmRequired,
                hint: _isBornOnFarmSelected()
                    ? l10n.selectDateOfBirth
                    : l10n.pleaseSelectDateEnteredFarm,
                selectedDate: _selectedDateFirstEnteredToFarm,
                onDateSelected: (d) =>
                    setState(() => _selectedDateFirstEnteredToFarm = d),
                enabled: !_isBornOnFarmSelected(),
                isBornOnFarm: _isBornOnFarmSelected(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                dateValidator: (d) =>
                    d == null ? l10n.pleaseSelectDateEnteredFarm : null,
              ),
            ],
          ],
          if (showSharedParentage) ...[
            const SizedBox(height: 24),
            _sectionTitle(
              l10n.parentageInformation,
              l10n.optionalSelectParents,
            ),
            const SizedBox(height: 12),
            CustomDropdown<String>(
              label: l10n.motherOptional,
              hint: l10n.select,
              icon: Icons.female_outlined,
              value: _selectedMotherUuid,
              enabled: !_hasBirthEventLink,
              dropdownItems: _eligibleMothers.map((livestock) {
                final farmName = _farms.isNotEmpty
                    ? _farms
                          .firstWhere(
                            (f) => f.uuid == livestock.farmUuid,
                            orElse: () => _farms.first,
                          )
                          .name
                    : l10n.unknownFarm;
                final label =
                    LivestockHelper.getDisplayName(livestock).isNotEmpty
                    ? LivestockHelper.getDisplayName(livestock)
                    : '${l10n.livestock} #${livestock.id}';
                final ageLabel = LivestockHelper.getAgeLabelFromDateOfBirth(
                  livestock.dateOfBirth,
                );
                return DropdownItem(
                  value: livestock.uuid,
                  label: '$label • ${l10n.age}: $ageLabel • $farmName',
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedMotherUuid = v),
              isRequired: false,
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: l10n.fatherOptional,
              hint: l10n.select,
              icon: Icons.male_outlined,
              value: _selectedFatherUuid,
              dropdownItems: _eligibleFathers.map((livestock) {
                final farmName = _farms.isNotEmpty
                    ? _farms
                          .firstWhere(
                            (f) => f.uuid == livestock.farmUuid,
                            orElse: () => _farms.first,
                          )
                          .name
                    : l10n.unknownFarm;
                final label =
                    LivestockHelper.getDisplayName(livestock).isNotEmpty
                    ? LivestockHelper.getDisplayName(livestock)
                    : '${l10n.livestock} #${livestock.id}';
                final ageLabel = LivestockHelper.getAgeLabelFromDateOfBirth(
                  livestock.dateOfBirth,
                );
                return DropdownItem(
                  value: livestock.uuid,
                  label: '$label • ${l10n.age}: $ageLabel • $farmName',
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedFatherUuid = v),
              isRequired: false,
            ),
          ],
          if (showSharedStatus) ...[
            const SizedBox(height: 24),
            CustomDropdown<String>(
              label: l10n.status,
              hint: l10n.select,
              icon: Icons.flag_outlined,
              value: _selectedStatus,
              dropdownItems: [
                DropdownItem(value: 'active', label: l10n.active),
                DropdownItem(value: 'notActive', label: l10n.notActive),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedStatus = v);
              },
            ),
          ],
          const SizedBox(height: 24),
          _infoCard(l10n, theme, l10n.pigletBulkPreviewInfo),
        ],
      ],
    );
  }

  Widget _buildSharedBirthEventSection(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          l10n.birthEventOptional,
          l10n.pigletBulkBirthEventLitterHint,
        ),
        const SizedBox(height: 12),
        CustomDropdown<String>(
          label: l10n.birthEventOptional,
          hint: l10n.select,
          icon: Icons.child_friendly_outlined,
          value: _selectedBirthEventUuid,
          dropdownItems: _birthEvents
              .where(
                (event) =>
                    _selectedFarmUuid == null ||
                    event.farmUuid == _selectedFarmUuid,
              )
              .map(
                (event) => DropdownItem<String>(
                  value: event.uuid,
                  label: _formatBirthEventMenuLabel(event, l10n),
                ),
              )
              .toList(),
          onChanged: (value) =>
              setState(() => _applyBirthEventSelection(value)),
          isRequired: false,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.birthEventOptionalHelper,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.addLivestockAllTypesReminder,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIdentificationSwitch() {
    final selectedStage = _getSelectedStage();
    return BulkLivestockIdentificationCard(
      isIdentified: _isIdentified,
      stageName: selectedStage?.name,
      onChanged: (value) => setState(() {
        _isIdentifiedOverride = value;
        if (!_diffIdentification) {
          for (final row in _livestockRows) {
            row.isIdentifiedOverride = null;
          }
        }
        if (value) _syncPreviewRowsForCurrentInputs();
      }),
    );
  }

  Widget _buildDifferencesStep(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommonStep(l10n, theme, showSetup: false, showBatch: true),
        if (_needsIndividualCards) ...[
          const SizedBox(height: 24),
          _buildCommonPerAnimalSetup(l10n, theme),
        ] else ...[
          const SizedBox(height: 16),
          _infoCard(l10n, theme, l10n.pigletBulkDifferentDataHelp),
        ],
      ],
    );
  }

  Widget _buildPreviewStep(AppLocalizations l10n, ThemeData theme) {
    final deadN = _livestockRows.where(_isRowInactive).length;
    final aliveN = _livestockRows.length - deadN;
    final showSharedSex = !_diffSex;
    final showSharedDisposal = !_diffStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Shared-data summary so the user can verify everything before submit ──
        _buildSharedDataSummaryCard(l10n),
        const SizedBox(height: 16),

        _infoCard(l10n, theme, l10n.pigletBulkPreviewInfo),
        const SizedBox(height: 12),
        _buildFinalReviewGuardCard(l10n, theme, aliveN, deadN),
        if (deadN > 0 && showSharedDisposal) ...[
          const SizedBox(height: 12),
          _infoCard(
            l10n,
            theme,
            l10n.pigletBulkPreviewAliveDeadSummary(aliveN, deadN),
          ),
          const SizedBox(height: 20),
          _sectionTitle(
            l10n.pigletBulkDisposalSectionTitle,
            l10n.pigletBulkDisposalSectionSubtitle,
          ),
          const SizedBox(height: 12),
          CustomDropdown<int>(
            label: l10n.pigletBulkDisposalTypeLabel,
            hint: l10n.select,
            icon: Icons.delete_forever_outlined,
            value: _deadDisposalTypeId,
            dropdownItems: _disposalTypes
                .map((t) => DropdownItem<int>(value: t.id, label: t.name))
                .toList(),
            onChanged: (v) => setState(() => _deadDisposalTypeId = v),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _deadDisposalReasonsController,
            label: l10n.pigletBulkDeadDisposalReasonHint,
            hintText: l10n.pigletDeadAtBirthDisposalReasonDefault,
            prefixIcon: Icons.notes_outlined,
            maxLines: 2,
          ),
        ],
        if (_livestockRows.isNotEmpty && showSharedSex) ...[
          SizedBox(height: deadN > 0 ? 20 : 8),
          _sectionTitle(
            l10n.pigletBulkQuickSexTitle,
            l10n.pigletBulkQuickSexSubtitle(_livestockRows.length),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _quickSexFemaleController,
                  label: '${l10n.female} · ${l10n.alive}',
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: _quickSexMaleController,
                  label: '${l10n.male} · ${l10n.alive}',
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _quickSexFemaleDeadController,
                  label: '${l10n.female} · ${l10n.dead}',
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: _quickSexMaleDeadController,
                  label: '${l10n.male} · ${l10n.dead}',
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _applyQuickSexDistribution(l10n),
              icon: const Icon(Icons.auto_fix_high_outlined),
              label: Text(l10n.pigletBulkApplySexSplit),
            ),
          ),
          const SizedBox(height: 8),
          _infoCard(l10n, theme, l10n.pigletBulkQuickSexOrderNote),
        ],
        if (_hasSelectedIndividualFields) ...[
          const SizedBox(height: 16),
          _infoCard(l10n, theme, l10n.pigletBulkIndividualFieldsPreviewHelp),
        ],
        const SizedBox(height: 20),
        Text(
          '${_livestockRows.length} · ${l10n.pigletBulkStepPreviewTitle}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: Constants.textSize + 1,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_livestockRows.length, (index) {
          final row = _livestockRows[index];
          final isDark = theme.brightness == Brightness.dark;
          final isInactive = _isRowInactive(row);
          final cardColor = isInactive
              ? (isDark ? Colors.grey[900]! : Colors.red.shade50)
              : (isDark ? Colors.grey[850]! : Colors.white);
          final borderColor = isInactive
              ? theme.colorScheme.error.withValues(alpha: 0.45)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!);
          final avatarColor = isInactive
              ? theme.colorScheme.error.withValues(alpha: 0.2)
              : Constants.primaryColor.withValues(alpha: 0.15);
          final avatarFg = isInactive
              ? theme.colorScheme.error
              : Constants.primaryColor;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: isInactive ? 1.6 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row: index, ID number, dead/alive toggle ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: avatarColor,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: avatarFg,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isRowIdentified(row)
                                      ? l10n.identificationNumber
                                      : l10n.pigletBulkSystemReference,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                                SelectableText(
                                  _submittedIdentificationNumber(row),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ── Dead / Alive toggle button ──
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                row.isDeadAtBirth = !row.isDeadAtBirth;
                                row.gender = null;
                              });
                            },
                            child: Chip(
                              avatar: Icon(
                                isInactive
                                    ? Icons.heart_broken_outlined
                                    : Icons.favorite_outlined,
                                size: 14,
                                color: isInactive
                                    ? theme.colorScheme.onError
                                    : Colors.green.shade700,
                              ),
                              label: Text(
                                isInactive ? l10n.notActive : l10n.active,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isInactive
                                      ? theme.colorScheme.onError
                                      : Colors.green.shade700,
                                ),
                              ),
                              backgroundColor: isInactive
                                  ? theme.colorScheme.error
                                  : Colors.green.shade50,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              side: BorderSide.none,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Status row (non-similar: alive vs dead-at-birth) ──
                      if (!_diffStatus) ...[
                        _buildPreviewInfoRow(
                          theme,
                          icon: Icons.flag_outlined,
                          label: l10n.status,
                          value: _effectiveStatus(row) == 'active'
                              ? l10n.active
                              : l10n.notActive,
                          valueColor: _isRowInactive(row)
                              ? theme.colorScheme.error
                              : Colors.green.shade700,
                        ),
                        const SizedBox(height: 10),
                      ],

                      // ── Nickname (non-similar: individual name override) ──
                      CustomTextField(
                        controller: row.nicknameController,
                        label: l10n.pigletBulkNicknameOptional,
                        hintText: l10n.enterLivestockName,
                        prefixIcon: Icons.edit_outlined,
                      ),
                      const SizedBox(height: 12),
                      if (_diffWeight) ...[
                        CustomTextField(
                          controller: row.weightController,
                          label: l10n.pigletBulkWeightPerRowLabel,
                          hintText: l10n.pigletBulkWeightPerRowHint,
                          prefixIcon: Icons.monitor_weight_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_hasSelectedIndividualFields ||
                          _isRowInactive(row)) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => setState(
                              () => row.individualDetailsExpanded =
                                  !row.individualDetailsExpanded,
                            ),
                            icon: Icon(
                              row.individualDetailsExpanded
                                  ? Icons.expand_less
                                  : Icons.tune_outlined,
                            ),
                            label: Text(l10n.pigletBulkIndividualDetails),
                          ),
                        ),
                      ],
                      if ((_hasSelectedIndividualFields ||
                              _isRowInactive(row)) &&
                          row.individualDetailsExpanded) ...[
                        const SizedBox(height: 12),
                        _buildRowIndividualDetails(l10n, theme, row, index),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _resetRowIndividualDetails(BulkLivestockRowDraft row) {
    row.statusOverride = null;
    row.birthEventUuidOverride = null;
    row.motherUuidOverride = null;
    row.fatherUuidOverride = null;
    row.dateOfBirthOverride = null;
    row.obtainedMethodIdOverride = null;
    row.dateEnteredFarmOverride = null;
    row.primaryColorOverride = null;
    row.secondaryColorOverride = null;
    row.disposalTypeId = null;
    row.disposalDate = null;
    row.disposalReasonController.clear();
    row.disposalRemarksController.clear();
    _refreshRowIdentificationNumbers();
  }

  Widget _buildRowIndividualDetails(
    AppLocalizations l10n,
    ThemeData theme,
    BulkLivestockRowDraft row,
    int index,
  ) {
    final isInactive = _isRowInactive(row);
    final effectiveBirthEvent = _birthEventByUuid(
      _effectiveBirthEventUuid(row),
    );
    final dateOfBirthOverride = row.dateOfBirthOverride;
    final dateEnteredOverride = row.dateEnteredFarmOverride;
    final disposalDate =
        row.disposalDate ?? (isInactive ? _effectiveDateOfBirth(row) : null);

    DropdownItem<String> parentItem(Livestock livestock) {
      var farmName = l10n.unknownFarm;
      for (final f in _farms) {
        if (f.uuid == livestock.farmUuid) {
          farmName = f.name;
          break;
        }
      }
      final label = LivestockHelper.getDisplayLabel(
        livestock,
        fallbackPrefix: l10n.livestock,
      );
      return DropdownItem(value: livestock.uuid, label: '$label ($farmName)');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune_outlined,
                color: Constants.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.pigletBulkOverrideBatchDefaults,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _resetRowIndividualDetails(row)),
                child: Text(l10n.pigletBulkUseBatchDefaults),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.pigletBulkIndividualDetailsHelp,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 14),
          if (_diffStatus) ...[
            CustomDropdown<String>(
              label: l10n.status,
              hint: isInactive ? l10n.notActive : l10n.pigletBulkSameAsBatch,
              icon: Icons.flag_outlined,
              value: isInactive ? 'notActive' : row.statusOverride,
              enabled: !row.isDeadAtBirth,
              dropdownItems: [
                DropdownItem(value: 'active', label: l10n.active),
                DropdownItem(value: 'notActive', label: l10n.notActive),
              ],
              onChanged: (v) => setState(() {
                row.statusOverride = v;
                if (v == 'notActive') row.individualDetailsExpanded = true;
              }),
              isRequired: false,
            ),
            const SizedBox(height: 12),
          ],
          if (_diffSex) ...[
            CustomDropdown<String>(
              label: l10n.gender,
              hint: l10n.selectGender,
              icon: Icons.wc_outlined,
              value: row.gender,
              dropdownItems: [
                DropdownItem(value: 'male', label: l10n.male),
                DropdownItem(value: 'female', label: l10n.female),
              ],
              onChanged: (v) => setState(() => row.gender = v),
              isRequired: true,
            ),
            const SizedBox(height: 12),
          ],
          if (_diffBirthEvent) ...[
            CustomDropdown<String>(
              label: l10n.birthEventOptional,
              hint: l10n.pigletBulkSameAsBatch,
              icon: Icons.child_friendly_outlined,
              value: row.birthEventUuidOverride,
              dropdownItems: _birthEvents
                  .where(
                    (event) =>
                        _selectedFarmUuid == null ||
                        event.farmUuid == _selectedFarmUuid,
                  )
                  .map(
                    (event) => DropdownItem<String>(
                      value: event.uuid,
                      label: _formatBirthEventMenuLabel(event, l10n),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _applyRowBirthEventSelection(row, value)),
              isRequired: false,
            ),
            const SizedBox(height: 12),
          ],
          if (_diffMother || _diffBirthEvent) ...[
            CustomDropdown<String>(
              label: l10n.motherOptional,
              hint: effectiveBirthEvent != null
                  ? (_labelForLivestock(
                          effectiveBirthEvent.livestockUuid,
                        ).isEmpty
                        ? l10n.pigletBulkSameAsBatch
                        : _labelForLivestock(effectiveBirthEvent.livestockUuid))
                  : l10n.pigletBulkSameAsBatch,
              icon: Icons.female_outlined,
              value:
                  effectiveBirthEvent?.livestockUuid ?? row.motherUuidOverride,
              enabled: effectiveBirthEvent == null,
              dropdownItems: _eligibleMothers.map(parentItem).toList(),
              onChanged: (v) => setState(() => row.motherUuidOverride = v),
              isRequired: false,
            ),
            const SizedBox(height: 12),
          ],
          if (_diffFather || _diffBirthEvent) ...[
            CustomDropdown<String>(
              label: l10n.fatherOptional,
              hint: l10n.pigletBulkSameAsBatch,
              icon: Icons.male_outlined,
              value: row.fatherUuidOverride,
              dropdownItems: _eligibleFathers.map(parentItem).toList(),
              onChanged: (v) => setState(() => row.fatherUuidOverride = v),
              isRequired: false,
            ),
            const SizedBox(height: 12),
          ],
          if (_diffDateOfBirth) ...[
            CustomDatePicker(
              label: l10n.dateOfBirth,
              hint: l10n.pigletBulkSameAsBatch,
              selectedDate: dateOfBirthOverride,
              onDateSelected: (date) {
                setState(() => _setRowDateOfBirthOverride(row, date));
              },
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              isRequired: false,
            ),
            if (dateOfBirthOverride != null) ...[
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () {
                  setState(() => _setRowDateOfBirthOverride(row, null));
                },
                icon: const Icon(Icons.undo_outlined, size: 16),
                label: Text(l10n.pigletBulkUseBatchDefaults),
              ),
            ],
            const SizedBox(height: 12),
          ],
          if (_diffObtainedMethod) ...[
            CustomDropdown<int>(
              label: l10n.obtainedMethod,
              hint: l10n.pigletBulkSameAsBatch,
              icon: Icons.source_outlined,
              value: row.obtainedMethodIdOverride,
              dropdownItems: _livestockObtainedMethods
                  .map((m) => DropdownItem(value: m.id, label: m.name))
                  .toList(),
              onChanged: (v) => setState(() {
                row.obtainedMethodIdOverride = v;
                if (v == null) return;
                final method = _livestockObtainedMethods.firstWhere(
                  (m) => m.id == v,
                  orElse: () => _livestockObtainedMethods.first,
                );
                if (method.name.toLowerCase().contains('born') &&
                    _selectedDateOfBirth != null) {
                  row.dateEnteredFarmOverride = _effectiveDateOfBirth(row);
                }
              }),
              isRequired: false,
            ),
            const SizedBox(height: 12),
          ],
          if (_diffDateEnteredFarm || dateEnteredOverride != null) ...[
            CustomDatePicker(
              label: l10n.dateEnteredFarmRequired,
              hint: l10n.pigletBulkSameAsBatch,
              selectedDate: dateEnteredOverride,
              onDateSelected: (date) =>
                  setState(() => row.dateEnteredFarmOverride = date),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              isRequired: false,
            ),
            if (dateEnteredOverride != null) ...[
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () =>
                    setState(() => row.dateEnteredFarmOverride = null),
                icon: const Icon(Icons.undo_outlined, size: 16),
                label: Text(l10n.pigletBulkUseBatchDefaults),
              ),
            ],
            const SizedBox(height: 12),
          ],
          if (_diffColors) ...[
            CustomDropdown<String>(
              label: l10n.primaryColor,
              hint: l10n.pigletBulkSameAsBatch,
              icon: Icons.palette_outlined,
              value: row.primaryColorOverride,
              dropdownItems: ColorHelper.getColorDropdownItems(l10n),
              onChanged: (v) => setState(() {
                row.primaryColorOverride = v;
                if (row.primaryColorOverride == row.secondaryColorOverride) {
                  row.secondaryColorOverride = null;
                }
              }),
              isRequired: false,
            ),
            const SizedBox(height: 12),
            CustomDropdown<String>(
              label: l10n.secondaryColor,
              hint: l10n.pigletBulkSameAsBatch,
              icon: Icons.color_lens_outlined,
              value: row.secondaryColorOverride,
              dropdownItems: ColorHelper.getColorDropdownItems(
                l10n,
                excludeColor: _effectivePrimaryColor(row),
              ),
              onChanged: (v) => setState(() => row.secondaryColorOverride = v),
              isRequired: false,
            ),
            const SizedBox(height: 12),
          ],
          if (isInactive) ...[
            const SizedBox(height: 16),
            _infoCard(l10n, theme, l10n.pigletBulkInactiveDisposalHelp),
            const SizedBox(height: 12),
            CustomDropdown<int>(
              label: l10n.disposalTypeId,
              hint: l10n.selectDisposalType,
              icon: Icons.delete_forever_outlined,
              value: row.disposalTypeId ?? _deadDisposalTypeId,
              dropdownItems: _disposalTypes
                  .map((t) => DropdownItem(value: t.id, label: t.name))
                  .toList(),
              onChanged: (v) => setState(() => row.disposalTypeId = v),
            ),
            const SizedBox(height: 12),
            CustomDatePicker(
              label: l10n.pigletBulkDisposalDate,
              hint: isInactive
                  ? l10n.selectDateOfBirth
                  : l10n.pigletBulkDisposalDateHint,
              selectedDate: disposalDate,
              onDateSelected: (date) => setState(() => row.disposalDate = date),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              isRequired: !isInactive,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: row.disposalReasonController,
              label: isInactive
                  ? l10n.pigletBulkDeadDisposalReasonHint
                  : '${l10n.disposalReasons} *',
              hintText: isInactive
                  ? l10n.pigletDeadAtBirthDisposalReasonDefault
                  : l10n.enterDisposalReasons,
              prefixIcon: Icons.notes_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: row.disposalRemarksController,
              label: l10n.remarks,
              hintText: l10n.enterRemarksOptional,
              prefixIcon: Icons.comment_outlined,
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) => BulkLivestockPreviewInfoRow(
    icon: icon,
    label: label,
    value: value,
    valueColor: valueColor,
  );

  /// Compact summary card displayed at the top of the preview step so users
  /// can verify ALL shared metadata before submitting the batch.
  Widget _buildSharedDataSummaryCard(AppLocalizations l10n) {
    String nameFor<T>({
      required List<T> items,
      required bool Function(T) match,
      required String Function(T) name,
      String fallback = '—',
    }) {
      try {
        return name(items.firstWhere(match));
      } catch (_) {
        return fallback;
      }
    }

    final farmName = nameFor(
      items: _farms,
      match: (f) => f.uuid == _selectedFarmUuid,
      name: (f) => f.name,
    );
    final typeName = nameFor(
      items: _livestockTypes,
      match: (t) => t.id == _selectedLivestockTypeId,
      name: (t) => t.name,
    );
    final speciesName = nameFor(
      items: _filteredSpecies,
      match: (s) => s.id == _selectedSpeciesId,
      name: (s) => s.name,
    );
    final breedName = nameFor(
      items: _filteredBreeds,
      match: (b) => b.id == _selectedBreedId,
      name: (b) => b.name,
    );
    final stageName = nameFor(
      items: _filteredStages,
      match: (s) => s.id == _selectedStageId,
      name: (s) => s.name,
    );
    final motherName = nameFor(
      items: _eligibleMothers,
      match: (m) => m.uuid == _selectedMotherUuid,
      name: (m) => m.name.isNotEmpty ? m.name : '${l10n.livestock} #${m.id}',
    );
    final fatherName = nameFor(
      items: _eligibleFathers,
      match: (f) => f.uuid == _selectedFatherUuid,
      name: (f) => f.name.isNotEmpty ? f.name : '${l10n.livestock} #${f.id}',
    );
    final methodName = nameFor(
      items: _livestockObtainedMethods,
      match: (m) => m.id == _selectedLivestockObtainedMethodId,
      name: (m) => m.name,
    );
    final String birthEventLabel;
    final pendingDraft = widget.pendingBirthEventToPersist;
    if (pendingDraft != null) {
      final date = pendingDraft.startDate.split('T').first;
      final head = '${pendingDraft.eventType.toUpperCase()} — $date';
      if (_livestockRows.isEmpty) {
        birthEventLabel = head;
      } else {
        final t = _livestockRows.length;
        final d = _livestockRows.where(_isRowInactive).length;
        birthEventLabel = d > 0
            ? '$head · ${l10n.pigletBulkLitterTotalDead(t, d)}'
            : '$head · ${l10n.pigletBulkLitterTotal(t)}';
      }
    } else if (_selectedBirthEventUuid != null) {
      final be = _birthEventByUuid(_selectedBirthEventUuid);
      birthEventLabel = be != null ? _formatBirthEventMenuLabel(be, l10n) : '—';
    } else {
      birthEventLabel = '—';
    }

    final dobStr = _selectedDateOfBirth != null
        ? DateFormat.yMMMd().format(_selectedDateOfBirth!)
        : '—';
    final enteredStr = _selectedDateFirstEnteredToFarm != null
        ? DateFormat.yMMMd().format(_selectedDateFirstEnteredToFarm!)
        : '—';
    final weight = _weightController.text.trim().isEmpty
        ? '—'
        : '${_weightController.text.trim()} kg';

    final rows = <BulkLivestockSummaryEntry>[
      BulkLivestockSummaryEntry(
        Icons.agriculture_outlined,
        l10n.farm,
        farmName,
      ),
      BulkLivestockSummaryEntry(
        Icons.category_outlined,
        l10n.livestockType,
        typeName,
      ),
      BulkLivestockSummaryEntry(Icons.pets_outlined, l10n.species, speciesName),
      BulkLivestockSummaryEntry(
        Icons.menu_book_outlined,
        l10n.breed,
        breedName,
      ),
      if (_selectedStageId != null)
        BulkLivestockSummaryEntry(
          Icons.stacked_line_chart_outlined,
          l10n.stage,
          stageName,
        ),
      BulkLivestockSummaryEntry(Icons.cake_outlined, l10n.dateOfBirth, dobStr),
      BulkLivestockSummaryEntry(
        Icons.login_outlined,
        l10n.dateEnteredFarmRequired,
        enteredStr,
      ),
      if (!_diffWeight)
        BulkLivestockSummaryEntry(
          Icons.monitor_weight_outlined,
          l10n.weightKg,
          weight,
        ),
      BulkLivestockSummaryEntry(
        Icons.source_outlined,
        l10n.obtainedMethod,
        methodName,
      ),
      if (_selectedBirthEventUuid != null || pendingDraft != null)
        BulkLivestockSummaryEntry(
          Icons.child_friendly_outlined,
          l10n.birthEventOptional,
          birthEventLabel,
        ),
      if (_selectedMotherUuid != null)
        BulkLivestockSummaryEntry(
          Icons.female_outlined,
          l10n.motherOptional,
          motherName,
        ),
      if (_selectedFatherUuid != null)
        BulkLivestockSummaryEntry(
          Icons.male_outlined,
          l10n.fatherOptional,
          fatherName,
        ),
      if (_selectedPrimaryColor != null)
        BulkLivestockSummaryEntry(
          Icons.palette_outlined,
          l10n.primaryColor,
          _selectedPrimaryColor!,
        ),
      if (_selectedSecondaryColor != null)
        BulkLivestockSummaryEntry(
          Icons.color_lens_outlined,
          l10n.secondaryColor,
          _selectedSecondaryColor!,
        ),
    ];

    return BulkLivestockSharedSummaryCard(
      title: l10n.pigletBulkStepPreviewTitle,
      entries: rows,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.scaffoldBackgroundColor
          : Constants.veryLightGreyColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: theme.brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
        leading: CustomBackButton(
          isEnabledBgColor: false,
          iconColor: theme.colorScheme.tertiary,
          iconSize: 24,
        ),
        title: Text(
          widget.pendingBirthEventToPersist != null
              ? l10n.pigletBulkCompleteBirthFlowTitle
              : l10n.smallLivestockBulkTitle,
          style: TextStyle(
            fontSize: Constants.largeTextSize,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingData
          ? const Center(child: LoadingIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: CustomStepper(
                  key: _stepperKey,
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  isLoading: _isSubmitting,
                  continueButtonText: l10n.continueButton,
                  finalStepButtonText: l10n.pigletBulkRegisterAll,
                  backButtonText: l10n.back,
                  steps: [
                    StepperStep(
                      title: l10n.pigletBulkStepCommonTitle,
                      subtitle: l10n.pigletBulkStepCommonSubtitle,
                      icon: Icons.groups_2_outlined,
                      content: _buildCommonStep(
                        l10n,
                        theme,
                        showSetup: true,
                        showBatch: false,
                      ),
                    ),
                    StepperStep(
                      title: l10n.pigletBulkStepDifferencesTitle,
                      subtitle: l10n.pigletBulkStepDifferencesSubtitle,
                      icon: Icons.tune_outlined,
                      content: _buildDifferencesStep(l10n, theme),
                    ),
                    StepperStep(
                      title: l10n.pigletBulkStepPreviewTitle,
                      subtitle: l10n.pigletBulkStepPreviewSubtitle,
                      icon: Icons.fact_check_outlined,
                      content: _buildPreviewStep(l10n, theme),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
