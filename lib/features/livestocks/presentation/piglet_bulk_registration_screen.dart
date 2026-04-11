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
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/presentation/bill_creation_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/birth_event_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/provider/livestock_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

String _pigletIdentificationSerial(DateTime dob, int index1Based, int total) {
  final prefix = DateFormat('yyyyMMdd').format(dob);
  final width = total > 99 ? 3 : 2;
  return '$prefix-${index1Based.toString().padLeft(width, '0')}';
}

class _PigletRowDraft {
  _PigletRowDraft({
    required this.identificationNumber,
    required this.nicknameController,
    required this.weightController,
    required bool isDeadAtBirth,
  }) : _isDeadAtBirth = isDeadAtBirth;

  final String identificationNumber;
  bool _isDeadAtBirth;
  bool get isDeadAtBirth => _isDeadAtBirth;
  set isDeadAtBirth(bool value) => _isDeadAtBirth = value;
  String? gender;
  final TextEditingController nicknameController;
  final TextEditingController weightController;
}

/// Register many piglets with shared metadata and per-row sex (and optional nicknames).
/// Identification numbers: `YYYYMMDD-01`, `YYYYMMDD-02`, … from date of birth.
class PigletBulkRegistrationScreen extends StatefulWidget {
  const PigletBulkRegistrationScreen({
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
  State<PigletBulkRegistrationScreen> createState() =>
      _PigletBulkRegistrationScreenState();
}

class _PigletBulkRegistrationScreenState
    extends State<PigletBulkRegistrationScreen> {
  static const int _maxPiglets = 40;
  static const Set<String> _earlyStageNames = {
    'piglet',
    'calf',
    'kid',
    'lamb',
    'chick',
    'newborn',
    'neonate',
  };

  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey();
  int _currentStep = 0;

  final _pigletCountController = TextEditingController(text: '8');
  final _namePrefixController = TextEditingController();
  final _weightController = TextEditingController();
  final _deadDisposalReasonsController = TextEditingController();
  final _quickSexFemaleController = TextEditingController();
  final _quickSexMaleController = TextEditingController();
  final _quickSexFemaleDeadController = TextEditingController();
  final _quickSexMaleDeadController = TextEditingController();
  final _quickWeightAliveController = TextEditingController();
  final _quickWeightDeadController = TextEditingController();

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

  List<_PigletRowDraft> _pigletRows = [];

  bool _isLoadingData = true;
  bool _hasLoadedData = false;
  bool _l10nPrefixApplied = false;
  bool _deadDisposalReasonL10nApplied = false;
  bool _isSubmitting = false;

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
    return _earlyStageNames.contains(stage.name.trim().toLowerCase());
  }

  bool get _isIdentified => !_isEarlyStageSelected;

  bool _isBornOnFarmSelected() {
    if (_selectedLivestockObtainedMethodId == null) return false;
    try {
      final m = _livestockObtainedMethods.firstWhere(
        (e) => e.id == _selectedLivestockObtainedMethodId,
      );
      return m.name.toLowerCase().contains('born');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    final pending = widget.pendingBirthEventToPersist;
    _selectedFarmUuid =
        widget.preSelectedFarmUuid ?? pending?.farmUuid;
    _selectedMotherUuid =
        widget.preSelectedMotherUuid ?? pending?.livestockUuid;
  }

  @override
  void dispose() {
    _pigletCountController.dispose();
    _namePrefixController.dispose();
    _weightController.dispose();
    _deadDisposalReasonsController.dispose();
    _quickSexFemaleController.dispose();
    _quickSexMaleController.dispose();
    _quickSexFemaleDeadController.dispose();
    _quickSexMaleDeadController.dispose();
    _quickWeightAliveController.dispose();
    _quickWeightDeadController.dispose();
    _disposeRowControllers();
    super.dispose();
  }

  void _disposeRowControllers() {
    for (final row in _pigletRows) {
      row.nicknameController.dispose();
      row.weightController.dispose();
    }
    _pigletRows = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_l10nPrefixApplied) {
      _l10nPrefixApplied = true;
      final l10n = AppLocalizations.of(context)!;
      _namePrefixController.text = l10n.pigletDefaultNamePrefix;
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
            for (final s in _filteredStages) {
              if (_earlyStageNames.contains(s.name.trim().toLowerCase())) {
                earlyStage = s;
                break;
              }
            }
            _selectedStageId = earlyStage?.id ??
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
      log('Piglet bulk load failed: $e\n$st');
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
    setState(() {
      _eligibleMothers =
          base.where((l) => l.gender.toLowerCase() == 'female').toList();
      _eligibleFathers =
          base.where((l) => l.gender.toLowerCase() == 'male').toList();
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

  void _applyBirthEventSelection(String? uuid) {
    _selectedBirthEventUuid = uuid;
    final e = _birthEventByUuid(uuid);
    if (e == null) return;
    if (e.totalBorn != null && e.totalBorn! > 0) {
      final c = e.totalBorn!.clamp(1, _maxPiglets);
      _pigletCountController.text = '$c';
    }
    try {
      final ds = e.startDate.split('T').first;
      final d = DateTime.parse(ds);
      _selectedDateOfBirth = DateTime(d.year, d.month, d.day);
      if (_isBornOnFarmSelected()) {
        _selectedDateFirstEnteredToFarm = _selectedDateOfBirth;
      }
    } catch (_) {}
  }

  /// Prefill litter size and date of birth from an unsaved [BirthEventModel]
  /// (deferred / piglet-bulk-combined flow).
  void _applyDraftBirthEventCountsAndDates(BirthEventModel m) {
    if (m.totalBorn != null && m.totalBorn! > 0) {
      final c = m.totalBorn!.clamp(1, _maxPiglets);
      _pigletCountController.text = '$c';
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
  /// - alive rows use femaleAlive / maleAlive (rest become unknown)
  /// - dead rows use femaleDead / maleDead (rest become unknown)
  /// Order is preserved within each group.
  Future<void> _applyQuickSexDistribution(AppLocalizations l10n) async {
    FocusScope.of(context).unfocus();
    final aliveIndices = <int>[];
    final deadIndices = <int>[];
    for (var i = 0; i < _pigletRows.length; i++) {
      if (_pigletRows[i].isDeadAtBirth) {
        deadIndices.add(i);
      } else {
        aliveIndices.add(i);
      }
    }
    final aliveExpected = aliveIndices.length;
    final deadExpected = deadIndices.length;
    if (_pigletRows.isEmpty) return;

    int parseCount(TextEditingController c) =>
        int.tryParse(c.text.trim()) ?? 0;

    final femaleAlive = parseCount(_quickSexFemaleController);
    final maleAlive = parseCount(_quickSexMaleController);
    final femaleDead = parseCount(_quickSexFemaleDeadController);
    final maleDead = parseCount(_quickSexMaleDeadController);
    if (femaleAlive < 0 ||
        maleAlive < 0 ||
        femaleDead < 0 ||
        maleDead < 0) {
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
    if (aliveAssigned > aliveExpected || deadAssigned > deadExpected) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.pigletBulkSexCountMismatch(
          _pigletRows.length,
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
        _pigletRows[aliveIndices[aliveCursor++]].gender = 'female';
      }
      for (var i = 0; i < maleAlive; i++) {
        _pigletRows[aliveIndices[aliveCursor++]].gender = 'male';
      }
      while (aliveCursor < aliveIndices.length) {
        _pigletRows[aliveIndices[aliveCursor++]].gender = 'unknown';
      }

      var deadCursor = 0;
      for (var i = 0; i < femaleDead; i++) {
        _pigletRows[deadIndices[deadCursor++]].gender = 'female';
      }
      for (var i = 0; i < maleDead; i++) {
        _pigletRows[deadIndices[deadCursor++]].gender = 'male';
      }
      while (deadCursor < deadIndices.length) {
        _pigletRows[deadIndices[deadCursor++]].gender = 'unknown';
      }
    });
  }

  int? _parsePigletCount() {
    final t = _pigletCountController.text.trim();
    final n = int.tryParse(t);
    if (n == null || n < 1 || n > _maxPiglets) return null;
    return n;
  }

  void _buildPreviewRows(int count) {
    _disposeRowControllers();
    _quickSexFemaleController.clear();
    _quickSexMaleController.clear();
    _quickSexFemaleDeadController.clear();
    _quickSexMaleDeadController.clear();
    _quickWeightAliveController.clear();
    _quickWeightDeadController.clear();
    final dob = _selectedDateOfBirth!;
    final deadSlots = _deadAtBirthSlotsForCount(count);
    _pigletRows = List.generate(
      count,
      (i) => _PigletRowDraft(
        identificationNumber: _pigletIdentificationSerial(dob, i + 1, count),
        nicknameController: TextEditingController(),
        weightController: TextEditingController(),
        isDeadAtBirth: i >= count - deadSlots,
      ),
    );
  }

  Future<void> _applyQuickWeightDistribution(AppLocalizations l10n) async {
    final aliveWeightRaw = _quickWeightAliveController.text.trim();
    final deadWeightRaw = _quickWeightDeadController.text.trim();
    final aliveWeight = aliveWeightRaw.isEmpty ? null : double.tryParse(aliveWeightRaw);
    final deadWeight = deadWeightRaw.isEmpty ? null : double.tryParse(deadWeightRaw);
    if ((aliveWeight != null && aliveWeight <= 0) ||
        (deadWeight != null && deadWeight <= 0)) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.enterValidWeight,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
      return;
    }
    setState(() {
      for (final row in _pigletRows) {
        final target = row.isDeadAtBirth ? deadWeight : aliveWeight;
        if (target == null) continue;
        row.weightController.text = target.toString();
      }
    });
  }

  Future<void> _onStepContinue() async {
    final l10n = AppLocalizations.of(context)!;

    if (_currentStep == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      final count = _parsePigletCount();
      if (count == null) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pigletBulkInvalidCount(_maxPiglets),
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
      setState(() {
        _buildPreviewRows(count);
        _currentStep = 1;
      });
      return;
    }

    // Preview — sex is required for alive piglets; dead piglets default to
    // 'unknown' automatically so they are never blocked.
    for (final row in _pigletRows) {
      if (row.isDeadAtBirth) {
        // Auto-assign 'unknown' gender to dead piglets that have no sex set
        row.gender ??= 'unknown';
        continue;
      }
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

    final deadPreview =
        _pigletRows.where((r) => r.isDeadAtBirth).length;
    final alivePreview = _pigletRows.length - deadPreview;
    if (alivePreview < 0 || (alivePreview + deadPreview) != _pigletRows.length) {
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

    if (!mounted) return;
    final provider = context.read<LivestockProvider>();
    final ids = _pigletRows.map((r) => r.identificationNumber).toList();
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

    if (!mounted) return;
    await AlertDialogs.showConfirmation(
      context: context,
      title: l10n.register,
      message: l10n.pigletBulkConfirmRegister(_pigletRows.length),
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
        ? l10n.pigletDefaultNamePrefix
        : _namePrefixController.text.trim();
    final rawWeightText = _weightController.text.trim();
    final parsedWeight =
        rawWeightText.isEmpty ? null : double.tryParse(rawWeightText);
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

    try {
      AlertDialogs.showLoading(
        context: context,
        title: l10n.save,
        message: l10n.pigletBulkSavingMessage,
        isDismissible: false,
      );

      var effectiveBirthUuid = _selectedBirthEventUuid;
      final pending = widget.pendingBirthEventToPersist;
      if (pending != null) {
        final totalRows = _pigletRows.length;
        final deadN = _pigletRows.where((r) => r.isDeadAtBirth).length;
        final nowIso = DateTime.now().toIso8601String();
        final dobIso = _selectedDateOfBirth!.toIso8601String();
        final reconciled = pending.copyWith(
          totalBorn: totalRows,
          deadCount: deadN,
          aliveCount: totalRows - deadN,
          startDate: dobIso,
          eventDate: (pending.eventDate != null &&
                  pending.eventDate!.trim().isNotEmpty)
              ? pending.eventDate
              : dobIso,
          updatedAt: nowIso,
        );
        await eventsProvider.addBirthEvent(reconciled);
        effectiveBirthUuid = reconciled.uuid;
      }

      final items = <Map<String, dynamic>>[];
      for (var i = 0; i < _pigletRows.length; i++) {
        final row = _pigletRows[i];
        final nick = row.nicknameController.text.trim();
        final name = nick.isNotEmpty ? nick : '$prefix ${i + 1}';

        final gender = row.isDeadAtBirth
            ? (row.gender?.trim().isNotEmpty == true
                  ? row.gender!
                  : 'unknown')
            : row.gender!;

        final status = row.isDeadAtBirth ? 'notActive' : _selectedStatus;
        final rowWeightRaw = row.weightController.text.trim();
        final rowWeightParsed =
            rowWeightRaw.isEmpty ? null : double.tryParse(rowWeightRaw);
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
        final w = row.isDeadAtBirth
            ? (effectiveWeight < weightDeadFloor ? weightDeadFloor : effectiveWeight)
            : effectiveWeight;

        items.add({
          'farmUuid': _selectedFarmUuid,
          'identificationNumber': row.identificationNumber,
          'dummyTagId': null,
          'barcodeTagId': null,
          'rfidTagId': null,
          'livestockTypeId': _selectedLivestockTypeId,
          'name': name,
          'dateOfBirth': _selectedDateOfBirth!.toIso8601String().split('T').first,
          'motherUuid': _selectedMotherUuid,
          'fatherUuid': _selectedFatherUuid,
          'birthEventUuid': effectiveBirthUuid,
          'gender': gender,
          'breedId': _selectedBreedId,
          'speciesId': speciesId,
          'status': status,
          'livestockObtainedMethodId': _selectedLivestockObtainedMethodId ?? 1,
          'dateFirstEnteredToFarm': _selectedDateFirstEnteredToFarm,
          'weightAsOnRegistration': w,
          'primaryColor': _selectedPrimaryColor,
          'secondaryColor': _selectedSecondaryColor,
          'stageId': _selectedStageId,
          'isIdentified': _isIdentified,
        });
      }

      final created = await livestockProvider.createLivestockBatch(items);

      if (!mounted) return;
      final createdCount = created?.length ?? 0;
      if (created == null || createdCount != items.length) {
        Navigator.of(context).pop();
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
      final deadIndices = <int>[];
      for (var i = 0; i < _pigletRows.length; i++) {
        if (_pigletRows[i].isDeadAtBirth) deadIndices.add(i);
      }

      // Batch-size mismatch is handled above, so every row maps to a created
      // livestock entry and disposal tracing remains complete.
      if (deadIndices.isNotEmpty && _deadDisposalTypeId != null) {
        final eventDateIso = _selectedDateOfBirth!.toIso8601String();
        final reasons = _deadDisposalReasonsController.text.trim().isEmpty
            ? l10n.pigletDeadAtBirthDisposalReasonDefault
            : _deadDisposalReasonsController.text.trim();
        final now = DateTime.now().toIso8601String();

        for (final i in deadIndices) {
          try {
            final livestockUuid = created[i].uuid;
            final uuid =
                'disposal-${DateTime.now().microsecondsSinceEpoch}-$i-${livestockUuid.hashCode}';
            await eventsProvider.addDisposal(
              DisposalModel(
                uuid: uuid,
                farmUuid: _selectedFarmUuid!,
                livestockUuid: livestockUuid,
                disposalTypeId: _deadDisposalTypeId,
                reasons: reasons,
                remarks: null,
                status: 'completed',
                eventDate: eventDateIso,
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
      Navigator.of(context).pop();

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

        final deadN = deadIndices.length;
        var successMsg = pending != null
            ? '${l10n.birthEventSaved}\n\n${l10n.pigletBulkSuccess(created.length)}'
            : l10n.pigletBulkSuccess(created.length);
        if (deadN > 0 && disposalFailures == 0) {
          successMsg =
              '$successMsg\n\n${l10n.pigletBulkSuccessDisposals(deadN)}';
        }

        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: successMsg,
          buttonText: l10n.ok,
        );

        if (mounted && disposalFailures > 0 && deadN > 0) {
          await AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message: l10n.pigletBulkDisposalPartialFailure,
            buttonText: l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
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
      log('Piglet bulk submit error: $e\n$st');
      if (mounted) {
        try {
          Navigator.of(context).pop();
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

  Widget _infoCard(AppLocalizations l10n, ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Constants.primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: Constants.textSize,
                height: 1.35,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: Constants.largeTextSize,
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: Constants.textSize - 1,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFinalReviewGuardCard(
    AppLocalizations l10n,
    ThemeData theme,
    int aliveN,
    int deadN,
  ) {
    final total = _pigletRows.length;
    final isConsistent = (aliveN + deadN) == total && aliveN >= 0 && deadN >= 0;
    final disposalState = deadN == 0
        ? l10n.pigletBulkStatusNotApplicable
        : (_deadDisposalTypeId != null
            ? l10n.pigletBulkStatusReady
            : l10n.pigletBulkStatusRequired);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isConsistent
            ? Constants.primaryColor.withValues(alpha: 0.06)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConsistent
              ? Constants.primaryColor.withValues(alpha: 0.22)
              : theme.colorScheme.error.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConsistent ? Icons.verified_outlined : Icons.error_outline,
                color: isConsistent
                    ? Constants.primaryColor
                    : theme.colorScheme.error,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.pigletBulkSaveCheckTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildPreviewInfoRow(
            theme,
            icon: Icons.groups_2_outlined,
            label: l10n.total,
            value: '$total',
          ),
          const SizedBox(height: 6),
          _buildPreviewInfoRow(
            theme,
            icon: Icons.favorite_outlined,
            label: l10n.aliveCount,
            value: '$aliveN',
            valueColor: Colors.green.shade700,
          ),
          const SizedBox(height: 6),
          _buildPreviewInfoRow(
            theme,
            icon: Icons.heart_broken_outlined,
            label: l10n.deadCount,
            value: '$deadN',
            valueColor: deadN > 0 ? theme.colorScheme.error : null,
          ),
          const SizedBox(height: 6),
          _buildPreviewInfoRow(
            theme,
            icon: Icons.delete_forever_outlined,
            label: l10n.pigletBulkDisposalTypeLabel,
            value: disposalState,
            valueColor: deadN > 0 && _deadDisposalTypeId == null
                ? theme.colorScheme.error
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCommonStep(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  (e) =>
                      e.uuid == _selectedBirthEventUuid &&
                      e.farmUuid == v,
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
        _sectionTitle(l10n.livestockClassification, l10n.selectTypeSpeciesBreed),
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
            setState(() => _selectedLivestockTypeId = v);
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
          onChanged: (v) => setState(() => _selectedStageId = v),
          isRequired: false,
        ),
        const SizedBox(height: 24),
        if (widget.pendingBirthEventToPersist == null) ...[
          _sectionTitle(l10n.birthEventOptional, l10n.pigletBulkBirthEventLitterHint),
          const SizedBox(height: 12),
          CustomDropdown<String>(
            label: l10n.birthEventOptional,
            hint: l10n.select,
            icon: Icons.child_friendly_outlined,
            value: _selectedBirthEventUuid,
            dropdownItems: _birthEvents
                .where(
                  (e) =>
                      _selectedFarmUuid == null ||
                      e.farmUuid == _selectedFarmUuid,
                )
                .map(
                  (e) => DropdownItem<String>(
                    value: e.uuid,
                    label: _formatBirthEventMenuLabel(e, l10n),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _applyBirthEventSelection(v)),
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
          const SizedBox(height: 24),
        ],
        _sectionTitle(l10n.pigletBulkNumberOfPiglets, l10n.pigletBulkNamePrefixHint),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _pigletCountController,
          label: '${l10n.pigletBulkNumberOfPiglets} *',
          hintText: l10n.pigletBulkCountRangeHint(_maxPiglets),
          prefixIcon: Icons.groups_2_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (_parsePigletCount() == null) {
              return l10n.pigletBulkInvalidCount(_maxPiglets);
            }
            return null;
          },
        ),
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
            });
          },
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          dateValidator: (date) =>
              date == null ? l10n.pleaseSelectDateOfBirth : null,
        ),
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
        const SizedBox(height: 24),
        _sectionTitle(l10n.parentageInformation, l10n.optionalSelectParents),
        const SizedBox(height: 12),
        CustomDropdown<String>(
          label: l10n.motherOptional,
          hint: l10n.select,
          icon: Icons.female_outlined,
          value: _selectedMotherUuid,
          enabled: widget.pendingBirthEventToPersist == null,
          dropdownItems:           _eligibleMothers.map((livestock) {
            var farmName = l10n.unknownFarm;
            for (final f in _farms) {
              if (f.uuid == livestock.farmUuid) {
                farmName = f.name;
                break;
              }
            }
            final label = livestock.name.isNotEmpty
                ? livestock.name
                : '${l10n.livestock} #${livestock.id}';
            return DropdownItem(
              value: livestock.uuid,
              label: '$label ($farmName)',
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
          dropdownItems:           _eligibleFathers.map((livestock) {
            var farmName = l10n.unknownFarm;
            for (final f in _farms) {
              if (f.uuid == livestock.farmUuid) {
                farmName = f.name;
                break;
              }
            }
            final label = livestock.name.isNotEmpty
                ? livestock.name
                : '${l10n.livestock} #${livestock.id}';
            return DropdownItem(
              value: livestock.uuid,
              label: '$label ($farmName)',
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedFatherUuid = v),
          isRequired: false,
        ),
        const SizedBox(height: 24),
        _sectionTitle(l10n.acquisitionDetails, l10n.howAndWhenObtained),
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
                );
                if (m.name.toLowerCase().contains('born') &&
                    _selectedDateOfBirth != null) {
                  _selectedDateFirstEnteredToFarm = _selectedDateOfBirth;
                }
              }
            });
          },
        ),
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
        const SizedBox(height: 24),
        _infoCard(l10n, theme, l10n.pigletBulkPreviewInfo),
      ],
    );
  }

  Widget _buildPreviewStep(AppLocalizations l10n, ThemeData theme) {
    final deadN = _pigletRows.where((r) => r.isDeadAtBirth).length;
    final aliveN = _pigletRows.length - deadN;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Shared-data summary so the user can verify everything before submit ──
        _buildSharedDataSummaryCard(l10n, theme),
        const SizedBox(height: 16),

        _infoCard(l10n, theme, l10n.pigletBulkPreviewInfo),
        const SizedBox(height: 12),
        _buildFinalReviewGuardCard(l10n, theme, aliveN, deadN),
        if (deadN > 0) ...[
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
        if (_pigletRows.isNotEmpty) ...[
          SizedBox(height: deadN > 0 ? 20 : 8),
          _sectionTitle(
            l10n.pigletBulkQuickSexTitle,
            l10n.pigletBulkQuickSexSubtitle(_pigletRows.length),
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
        const SizedBox(height: 20),
        _sectionTitle(
          l10n.pigletBulkQuickWeightTitle,
          l10n.pigletBulkQuickWeightSubtitle,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                controller: _quickWeightAliveController,
                label: l10n.pigletBulkWeightAliveHint,
                hintText: l10n.pigletBulkWeightPerRowHint,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(
                controller: _quickWeightDeadController,
                label: l10n.pigletBulkWeightDeadHint,
                hintText: l10n.pigletBulkWeightPerRowHint,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _applyQuickWeightDistribution(l10n),
            icon: const Icon(Icons.monitor_weight_outlined),
            label: Text(l10n.pigletBulkApplyWeights),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '${_pigletRows.length} · ${l10n.pigletBulkStepPreviewTitle}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: Constants.textSize + 1,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_pigletRows.length, (index) {
          final row = _pigletRows[index];
          final isDark = theme.brightness == Brightness.dark;
          final cardColor = row.isDeadAtBirth
              ? (isDark ? Colors.grey[900]! : Colors.red.shade50)
              : (isDark ? Colors.grey[850]! : Colors.white);
          final borderColor = row.isDeadAtBirth
              ? theme.colorScheme.error.withValues(alpha: 0.45)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!);
          final avatarColor = row.isDeadAtBirth
              ? theme.colorScheme.error.withValues(alpha: 0.2)
              : Constants.primaryColor.withValues(alpha: 0.15);
          final avatarFg = row.isDeadAtBirth
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
                    width: row.isDeadAtBirth ? 1.6 : 1,
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
                                  l10n.identificationNumber,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                                SelectableText(
                                  row.identificationNumber,
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
                                // When marked alive, clear unknown default if still set
                                if (!row.isDeadAtBirth &&
                                    row.gender == 'unknown') {
                                  row.gender = null;
                                }
                              });
                            },
                            child: Chip(
                              avatar: Icon(
                                row.isDeadAtBirth
                                    ? Icons.heart_broken_outlined
                                    : Icons.favorite_outlined,
                                size: 14,
                                color: row.isDeadAtBirth
                                    ? theme.colorScheme.onError
                                    : Colors.green.shade700,
                              ),
                              label: Text(
                                row.isDeadAtBirth
                                    ? l10n.pigletBulkDeadAtBirthChip
                                    : l10n.active,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: row.isDeadAtBirth
                                      ? theme.colorScheme.onError
                                      : Colors.green.shade700,
                                ),
                              ),
                              backgroundColor: row.isDeadAtBirth
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
                      _buildPreviewInfoRow(
                        theme,
                        icon: Icons.flag_outlined,
                        label: l10n.status,
                        value: row.isDeadAtBirth
                            ? l10n.notActive
                            : _selectedStatus == 'active'
                                ? l10n.active
                                : l10n.notActive,
                        valueColor: row.isDeadAtBirth
                            ? theme.colorScheme.error
                            : Colors.green.shade700,
                      ),
                      const SizedBox(height: 10),

                      // ── Gender (required for alive, optional for dead) ──
                      CustomDropdown<String>(
                        label: row.isDeadAtBirth
                            ? l10n.pigletBulkGenderOptionalDead
                            : l10n.gender,
                        hint: l10n.selectGender,
                        icon: Icons.wc_outlined,
                        value: row.gender,
                        dropdownItems: [
                          DropdownItem(value: 'male', label: l10n.male),
                          DropdownItem(value: 'female', label: l10n.female),
                          DropdownItem(
                            value: 'unknown',
                            label: l10n.pigletGenderUnknown,
                          ),
                        ],
                        onChanged: (v) => setState(() => row.gender = v),
                        isRequired: !row.isDeadAtBirth,
                      ),
                      const SizedBox(height: 12),

                      // ── Nickname (non-similar: individual name override) ──
                      CustomTextField(
                        controller: row.nicknameController,
                        label: l10n.pigletBulkNicknameOptional,
                        hintText: l10n.enterLivestockName,
                        prefixIcon: Icons.edit_outlined,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: row.weightController,
                        label: l10n.pigletBulkWeightPerRowLabel,
                        hintText: l10n.pigletBulkWeightPerRowHint,
                        prefixIcon: Icons.monitor_weight_outlined,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                      ),
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

  /// Renders a small label+value row inside a piglet preview card.
  Widget _buildPreviewInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Compact summary card displayed at the top of the preview step so users
  /// can verify ALL shared metadata before submitting the batch.
  Widget _buildSharedDataSummaryCard(AppLocalizations l10n, ThemeData theme) {
    String _nameFor<T>({
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

    final farmName = _nameFor(
      items: _farms,
      match: (f) => f.uuid == _selectedFarmUuid,
      name: (f) => f.name,
    );
    final typeName = _nameFor(
      items: _livestockTypes,
      match: (t) => t.id == _selectedLivestockTypeId,
      name: (t) => t.name,
    );
    final speciesName = _nameFor(
      items: _filteredSpecies,
      match: (s) => s.id == _selectedSpeciesId,
      name: (s) => s.name,
    );
    final breedName = _nameFor(
      items: _filteredBreeds,
      match: (b) => b.id == _selectedBreedId,
      name: (b) => b.name,
    );
    final stageName = _nameFor(
      items: _filteredStages,
      match: (s) => s.id == _selectedStageId,
      name: (s) => s.name,
    );
    final motherName = _nameFor(
      items: _eligibleMothers,
      match: (m) => m.uuid == _selectedMotherUuid,
      name: (m) => m.name.isNotEmpty ? m.name : '${l10n.livestock} #${m.id}',
    );
    final fatherName = _nameFor(
      items: _eligibleFathers,
      match: (f) => f.uuid == _selectedFatherUuid,
      name: (f) => f.name.isNotEmpty ? f.name : '${l10n.livestock} #${f.id}',
    );
    final methodName = _nameFor(
      items: _livestockObtainedMethods,
      match: (m) => m.id == _selectedLivestockObtainedMethodId,
      name: (m) => m.name,
    );
    final String birthEventLabel;
    final pendingDraft = widget.pendingBirthEventToPersist;
    if (pendingDraft != null) {
      final date = pendingDraft.startDate.split('T').first;
      final head = '${pendingDraft.eventType.toUpperCase()} — $date';
      if (_pigletRows.isEmpty) {
        birthEventLabel = head;
      } else {
        final t = _pigletRows.length;
        final d = _pigletRows.where((r) => r.isDeadAtBirth).length;
        birthEventLabel = d > 0
            ? '$head · ${l10n.pigletBulkLitterTotalDead(t, d)}'
            : '$head · ${l10n.pigletBulkLitterTotal(t)}';
      }
    } else if (_selectedBirthEventUuid != null) {
      final be = _birthEventByUuid(_selectedBirthEventUuid);
      birthEventLabel = be != null
          ? _formatBirthEventMenuLabel(be, l10n)
          : '—';
    } else {
      birthEventLabel = '—';
    }

    final dobStr = _selectedDateOfBirth != null
        ? DateFormat.yMMMd().format(_selectedDateOfBirth!)
        : '—';
    final enteredStr = _selectedDateFirstEnteredToFarm != null
        ? DateFormat.yMMMd().format(_selectedDateFirstEnteredToFarm!)
        : '—';
    final weight =
        _weightController.text.trim().isEmpty ? '—' : '${_weightController.text.trim()} kg';

    final rows = <_SummaryRow>[
      _SummaryRow(Icons.agriculture_outlined, l10n.farm, farmName),
      _SummaryRow(Icons.category_outlined, l10n.livestockType, typeName),
      _SummaryRow(Icons.pets_outlined, l10n.species, speciesName),
      _SummaryRow(Icons.menu_book_outlined, l10n.breed, breedName),
      if (_selectedStageId != null)
        _SummaryRow(
            Icons.stacked_line_chart_outlined, l10n.stage, stageName),
      _SummaryRow(Icons.cake_outlined, l10n.dateOfBirth, dobStr),
      _SummaryRow(Icons.login_outlined, l10n.dateEnteredFarmRequired, enteredStr),
      _SummaryRow(Icons.monitor_weight_outlined, l10n.weightKg, weight),
      _SummaryRow(Icons.source_outlined, l10n.obtainedMethod, methodName),
      if (_selectedBirthEventUuid != null || pendingDraft != null)
        _SummaryRow(Icons.child_friendly_outlined, l10n.birthEventOptional,
            birthEventLabel),
      if (_selectedMotherUuid != null)
        _SummaryRow(Icons.female_outlined, l10n.motherOptional, motherName),
      if (_selectedFatherUuid != null)
        _SummaryRow(Icons.male_outlined, l10n.fatherOptional, fatherName),
      if (_selectedPrimaryColor != null)
        _SummaryRow(Icons.palette_outlined, l10n.primaryColor,
            _selectedPrimaryColor!),
      if (_selectedSecondaryColor != null)
        _SummaryRow(Icons.color_lens_outlined, l10n.secondaryColor,
            _selectedSecondaryColor!),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Constants.primaryColor.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined,
                  color: Constants.primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.pigletBulkStepPreviewTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(r.icon,
                      size: 14,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.45)),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 120,
                    child: Text(
                      r.label,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              : l10n.pigletBulkTitle,
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
                      content: _buildCommonStep(l10n, theme),
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

/// Simple data holder used by the shared-data summary card in the preview step.
class _SummaryRow {
  const _SummaryRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}
