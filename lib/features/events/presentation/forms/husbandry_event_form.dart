import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/app_date_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/modern_alerts.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/iron_injection_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/livestock_marking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/stage_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/tail_docking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/teeth_clipping_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

enum HusbandryEventType {
  ironInjection,
  teethClipping,
  tailDocking,
  livestockMarking,
  stageChange,
}

class HusbandryEventFormScreen extends StatefulWidget {
  final HusbandryEventType eventType;
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;

  const HusbandryEventFormScreen({
    super.key,
    required this.eventType,
    this.farmUuid,
    this.livestockUuid,
    this.isBulk = false,
    this.bulkLivestockUuids,
  });

  @override
  State<HusbandryEventFormScreen> createState() =>
      _HusbandryEventFormScreenState();
}

class _HusbandryEventFormScreenState extends State<HusbandryEventFormScreen> {
  final _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();
  final _eventDateController = TextEditingController();
  final _dosageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoadingContext = true;
  bool _isLoadingLivestock = false;
  bool _isLoadingReference = false;
  int _currentStep = 0;

  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;
  List<Livestock> _farmLivestock = const [];
  List<Farm> _farms = const [];
  List<Livestock> _selectedBulkLivestock = const [];
  DateTime? _selectedEventDate;
  int? _selectedMedicineId;
  String? _selectedTeethClippingMethod;
  String? _selectedTailDockingMethod;
  String? _selectedDosageUnit;
  String? _selectedMarkingType;
  int? _selectedFromStageId;
  int? _selectedToStageId;
  List<DropdownItem<int>> _medicineItems = const [];
  List<DropdownItem<int>> _stageItems = const [];
  List<DropdownItem<String>> _teethClippingMethodItems = const [];

  static const List<String> _dosageUnits = ['ml', 'l', 'mg', 'g', 'kg'];
  List<DropdownItem<String>> _markingTypeItems = const [];

  bool get _isBulk => widget.isBulk;
  bool get _isMethodRequired =>
      widget.eventType == HusbandryEventType.teethClipping ||
      widget.eventType == HusbandryEventType.tailDocking;

  @override
  void initState() {
    super.initState();
    _selectedFarmUuid = widget.farmUuid;
    _selectedLivestockUuid = widget.livestockUuid;
    _selectedEventDate = DateTime.now();
    _eventDateController.text = DateFormat.yMMMd().add_jm().format(
      _selectedEventDate!.toLocal(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _eventDateController.dispose();
    _dosageController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoadingContext = true;
      _isLoadingReference = true;
    });
    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      await Future.wait([_loadContext(db), _loadReferenceData(db)]);
    } catch (e, st) {
      log('Failed husbandry form init: $e', stackTrace: st);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingContext = false;
          _isLoadingReference = false;
        });
      }
    }
  }

  Future<void> _loadContext(AppDatabase db) async {
    final farms = await db.farmDao.getAllActiveFarms();
    String? farmUuid = _selectedFarmUuid;
    if (farmUuid != null && farms.every((f) => f.uuid != farmUuid)) {
      farmUuid = null;
    }
    farmUuid ??= farms.isNotEmpty ? farms.first.uuid : null;

    List<Livestock> livestock = [];
    if (farmUuid != null) {
      livestock = await db.livestockDao.getActiveLivestockByFarmUuid(farmUuid);
    }

    String? livestockUuid = _selectedLivestockUuid;
    if (!_isBulk) {
      if (livestockUuid != null &&
          livestock.every((item) => item.uuid != livestockUuid)) {
        livestockUuid = null;
      }
      livestockUuid ??=
          widget.livestockUuid ??
          (livestock.isNotEmpty ? livestock.first.uuid : null);
    }

    List<Livestock> selectedBulk = _selectedBulkLivestock;
    if (_isBulk) {
      final seeded = widget.bulkLivestockUuids ?? const [];
      if (selectedBulk.isEmpty && seeded.isNotEmpty) {
        selectedBulk = livestock.where((l) => seeded.contains(l.uuid)).toList();
      }
    }

    if (!mounted) return;
    setState(() {
      _farms = farms;
      _farmLivestock = livestock;
      _selectedFarmUuid = farmUuid;
      _selectedLivestockUuid = livestockUuid;
      _selectedBulkLivestock = selectedBulk;
      if (!_isBulk) {
        _syncFromStageFromSelectedLivestock();
      }
    });
  }

  Future<void> _loadReferenceData(AppDatabase db) async {
    final dataProvider = Provider.of<LogAdditionalDataProvider>(
      context,
      listen: false,
    );
    await dataProvider.ensureLoaded();
    final stageRows = await db.stageDao.getAllStages();
    final teethMethodRows = await db.logReferenceDao
        .getAllTeethClippingMethods();

    if (!mounted) return;
    setState(() {
      _medicineItems = dataProvider.medicines
          .map((m) => DropdownItem<int>(value: m.id, label: m.name))
          .toList();
      _teethClippingMethodItems = teethMethodRows
          .map((m) => m.name.trim())
          .where((name) => name.isNotEmpty)
          .map((name) => DropdownItem<String>(value: name, label: name))
          .toList();
      _stageItems = stageRows
          .map((s) => DropdownItem<int>(value: s.id, label: s.name))
          .toList();
      _selectedMedicineId ??= _medicineItems.isNotEmpty
          ? _medicineItems.first.value
          : null;
      _selectedTeethClippingMethod ??= _teethClippingMethodItems.isNotEmpty
          ? _teethClippingMethodItems.first.value
          : null;
      _selectedTailDockingMethod ??= _teethClippingMethodItems.isNotEmpty
          ? _teethClippingMethodItems.first.value
          : null;
      _selectedDosageUnit ??= _dosageUnits.first;
    });

    final markingRows = await db.eventDao.getLivestockMarkings();
    final syncedTypes =
        markingRows
            .map((row) => row.markingType.trim())
            .where((type) => type.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final allTypes = syncedTypes;
    if (!mounted) return;
    setState(() {
      _markingTypeItems = allTypes
          .map(
            (type) => DropdownItem<String>(
              value: type,
              label: type.replaceAll('_', ' '),
            ),
          )
          .toList();
      _selectedMarkingType ??= _markingTypeItems.isNotEmpty
          ? _markingTypeItems.first.value
          : null;
    });
  }

  void _syncFromStageFromSelectedLivestock() {
    Livestock? current;
    for (final item in _farmLivestock) {
      if (item.uuid == _selectedLivestockUuid) {
        current = item;
        break;
      }
    }
    _selectedFromStageId = current?.stageId;
  }

  Future<void> _onFarmSelected(String value) async {
    setState(() {
      _selectedFarmUuid = value;
      _isLoadingLivestock = true;
      if (_isBulk) _selectedBulkLivestock = const [];
    });
    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      final livestock = await db.livestockDao.getActiveLivestockByFarmUuid(
        value,
      );
      if (!mounted) return;
      setState(() {
        _farmLivestock = livestock;
        _selectedLivestockUuid = !_isBulk && livestock.isNotEmpty
            ? (widget.livestockUuid ?? livestock.first.uuid)
            : null;
        _syncFromStageFromSelectedLivestock();
      });
    } finally {
      if (mounted) setState(() => _isLoadingLivestock = false);
    }
  }

  bool _validateContext(AppLocalizations l10n) {
    if (_selectedFarmUuid == null || _selectedFarmUuid!.isEmpty) {
      ModernAlerts.showErrorToast(context, message: l10n.farmRequired);
      return false;
    }
    if (_isBulk) {
      if (_selectedBulkLivestock.isEmpty) {
        ModernAlerts.showErrorToast(context, message: l10n.livestockRequired);
        return false;
      }
      return true;
    }
    if (_selectedLivestockUuid == null || _selectedLivestockUuid!.isEmpty) {
      ModernAlerts.showErrorToast(context, message: l10n.livestockRequired);
      return false;
    }
    return true;
  }

  bool _validateEventFields(AppLocalizations l10n) {
    if (_selectedEventDate == null) {
      ModernAlerts.showErrorToast(context, message: l10n.eventDateRequired);
      return false;
    }
    if (_isMethodRequired) {
      if (widget.eventType == HusbandryEventType.teethClipping &&
          (_selectedTeethClippingMethod == null ||
              _selectedTeethClippingMethod!.trim().isEmpty)) {
        ModernAlerts.showErrorToast(
          context,
          message: l10n.husbandryRequiredFields,
        );
        return false;
      }
      if (widget.eventType == HusbandryEventType.tailDocking &&
          (_selectedTailDockingMethod == null ||
              _selectedTailDockingMethod!.trim().isEmpty)) {
        ModernAlerts.showErrorToast(
          context,
          message: l10n.husbandryRequiredFields,
        );
        return false;
      }
    }
    if (widget.eventType == HusbandryEventType.ironInjection) {
      if (_dosageController.text.trim().isEmpty ||
          _selectedDosageUnit == null ||
          _selectedMedicineId == null) {
        ModernAlerts.showErrorToast(
          context,
          message: l10n.husbandryRequiredFields,
        );
        return false;
      }
    }
    if (widget.eventType == HusbandryEventType.livestockMarking &&
        (_selectedMarkingType == null || _selectedMarkingType!.isEmpty)) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.husbandryRequiredFields,
      );
      return false;
    }
    if (widget.eventType == HusbandryEventType.stageChange &&
        _selectedToStageId == null) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.husbandryRequiredFields,
      );
      return false;
    }
    if (widget.eventType == HusbandryEventType.stageChange &&
        _selectedFromStageId != null &&
        _selectedFromStageId == _selectedToStageId) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.husbandryFromToStageMismatch,
      );
      return false;
    }
    return true;
  }

  Future<void> _onStepContinue() async {
    final l10n = AppLocalizations.of(context)!;
    if (_currentStep == 0) {
      if (!_validateContext(l10n)) return;
      setState(() => _currentStep = 1);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (!_validateEventFields(l10n)) return;
    await AlertDialogs.showConfirmation(
      context: context,
      title: l10n.save,
      message: '${l10n.confirm} ${_title(l10n)}?',
      confirmText: l10n.save,
      cancelText: l10n.cancel,
      onConfirm: () async {
        if (!mounted) return;
        Navigator.of(context).pop(true);
        await _submit();
      },
    );
  }

  Future<void> _pickEventDate() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : whiteColor;
    final initial = _selectedEventDate ?? DateTime.now();

    final date = await showAppDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: Constants.primaryColor,
              onPrimary: theme.colorScheme.onPrimary,
              onSurface: theme.colorScheme.onSurface,
              surface: backgroundColor,
              surfaceContainerHighest: backgroundColor,
            ),
            dialogBackgroundColor: backgroundColor,
            canvasColor: backgroundColor,
            cardColor: backgroundColor,
            scaffoldBackgroundColor: backgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? initial.hour,
      time?.minute ?? initial.minute,
    );
    setState(() => _selectedEventDate = picked);
    _eventDateController.text = DateFormat.yMMMd().add_jm().format(
      picked.toLocal(),
    );
  }

  void _onStepCancel() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _currentStep -= 1);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<EventsProvider>(context, listen: false);
    final farmUuid = _selectedFarmUuid!;
    final livestockUuids = _isBulk
        ? _selectedBulkLivestock.map((e) => e.uuid).toList()
        : [_selectedLivestockUuid!];
    final now = DateTime.now().toIso8601String();
    final eventDate = _selectedEventDate!.toIso8601String();

    try {
      AlertDialogs.showLoading(
        context: context,
        title: l10n.save,
        message: '',
        isDismissible: false,
      );
      for (final livestockUuid in livestockUuids) {
        switch (widget.eventType) {
          case HusbandryEventType.teethClipping:
            await provider.addTeethClipping(
              TeethClippingModel(
                uuid: _uuid.v4(),
                farmUuid: farmUuid,
                livestockUuid: livestockUuid,
                method: _selectedTeethClippingMethod,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
                eventDate: eventDate,
                createdAt: now,
                updatedAt: now,
              ),
            );
            break;
          case HusbandryEventType.tailDocking:
            await provider.addTailDocking(
              TailDockingModel(
                uuid: _uuid.v4(),
                farmUuid: farmUuid,
                livestockUuid: livestockUuid,
                method: _selectedTailDockingMethod,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
                eventDate: eventDate,
                createdAt: now,
                updatedAt: now,
              ),
            );
            break;
          case HusbandryEventType.ironInjection:
            await provider.addIronInjection(
              IronInjectionModel(
                uuid: _uuid.v4(),
                farmUuid: farmUuid,
                livestockUuid: livestockUuid,
                dosage:
                    '${_dosageController.text.trim()} ${_selectedDosageUnit!.trim()}',
                medicineId: _selectedMedicineId,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
                eventDate: eventDate,
                createdAt: now,
                updatedAt: now,
              ),
            );
            break;
          case HusbandryEventType.livestockMarking:
            await provider.addLivestockMarking(
              LivestockMarkingModel(
                uuid: _uuid.v4(),
                farmUuid: farmUuid,
                livestockUuid: livestockUuid,
                markingType: _selectedMarkingType!,
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
                eventDate: eventDate,
                createdAt: now,
                updatedAt: now,
              ),
            );
            break;
          case HusbandryEventType.stageChange:
            await provider.addStageChange(
              StageChangeModel(
                uuid: _uuid.v4(),
                farmUuid: farmUuid,
                livestockUuid: livestockUuid,
                fromStageId: _selectedFromStageId,
                toStageId: _selectedToStageId,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
                eventDate: eventDate,
                createdAt: now,
                updatedAt: now,
              ),
            );
            break;
        }
      }
      if (!mounted) return;
      Navigator.of(context).pop(); // loading
      await AlertDialogs.showSuccess(
        context: context,
        title: l10n.success,
        message: l10n.eventLogSavedSuccessfully,
        buttonText: l10n.ok,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e, st) {
      log('Failed to save husbandry event: $e', stackTrace: st);
      if (!mounted) return;
      Navigator.of(context).pop(); // loading
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.somethingWentWrong,
        buttonText: l10n.ok,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        leading: CustomBackButton(
          isEnabledBgColor: false,
          iconColor: theme.colorScheme.tertiary,
        ),
        title: Text(
          _title(l10n),
          style: TextStyle(
            fontSize: Constants.largeTextSize,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingContext
          ? const Center(child: LoadingIndicator())
          : Form(
              key: _formKey,
              child: CustomStepper(
                currentStep: _currentStep,
                onStepContinue: _onStepContinue,
                onStepCancel: _onStepCancel,
                backButtonText: l10n.back,
                finalStepButtonText: l10n.save,
                steps: [
                  StepperStep(
                    title: l10n.basicInformation,
                    subtitle: l10n.recordsAndLogs,
                    icon: Icons.analytics_outlined,
                    content: _buildContextStep(l10n),
                  ),
                  StepperStep(
                    title: l10n.additionalDetails,
                    subtitle: _title(l10n),
                    icon: Icons.event_note,
                    content: _buildDetailsStep(l10n),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildContextStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdown<String>(
          label: l10n.farm,
          hint: l10n.selectFarm,
          icon: Icons.agriculture_outlined,
          value: _selectedFarmUuid,
          dropdownItems: _farms
              .map((f) => DropdownItem(value: f.uuid, label: f.name))
              .toList(),
          onChanged: (value) {
            if (value == null || value.isEmpty) return;
            _onFarmSelected(value);
          },
        ),
        const SizedBox(height: 12),
        if (_isBulk) ...[
          BulkLivestockSummaryTile(
            count: _selectedBulkLivestock.length,
            onTap: () async {
              final farmUuid = _selectedFarmUuid;
              if (farmUuid == null || farmUuid.isEmpty) return;
              final picked = await Navigator.of(context).push<List<Livestock>>(
                MaterialPageRoute(
                  builder: (_) => BulkLivestockSelectorPage(
                    farmUuid: farmUuid,
                    preselectedLivestock: _selectedBulkLivestock,
                  ),
                ),
              );
              if (picked == null || !mounted) return;
              setState(() => _selectedBulkLivestock = picked);
            },
          ),
        ] else ...[
          _isLoadingLivestock
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LoadingIndicator(),
                )
              : CustomDropdown<String>(
                  label: l10n.livestock,
                  hint: l10n.selectLivestock,
                  icon: Icons.pets_outlined,
                  value: _selectedLivestockUuid,
                  dropdownItems: _farmLivestock
                      .map(
                        (l) => DropdownItem(
                          value: l.uuid,
                          label: l.identificationNumber,
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedLivestockUuid = value);
                    _syncFromStageFromSelectedLivestock();
                  },
                ),
        ],
      ],
    );
  }

  Widget _buildDetailsStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _eventDateController,
          label: l10n.eventDate,
          hintText: l10n.selectEventDate,
          readOnly: true,
          prefixIcon: Icons.calendar_today,
          onTap: _pickEventDate,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.eventDateRequired : null,
        ),
        const SizedBox(height: 16),
        if (_isMethodRequired) ...[
          if (widget.eventType == HusbandryEventType.teethClipping) ...[
            CustomDropdown<String>(
              label: l10n.procedureMethod,
              hint: l10n.selectProcedureMethod,
              icon: Icons.build_outlined,
              value: _selectedTeethClippingMethod,
              dropdownItems: _teethClippingMethodItems,
              onChanged: (v) =>
                  setState(() => _selectedTeethClippingMethod = v),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.doseRequired : null,
            ),
          ] else if (widget.eventType == HusbandryEventType.tailDocking) ...[
            CustomDropdown<String>(
              label: l10n.procedureMethod,
              hint: l10n.selectProcedureMethod,
              icon: Icons.build_outlined,
              value: _selectedTailDockingMethod,
              dropdownItems: _teethClippingMethodItems,
              onChanged: (v) => setState(() => _selectedTailDockingMethod = v),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.doseRequired : null,
            ),
          ],
          const SizedBox(height: 16),
        ],
        if (widget.eventType == HusbandryEventType.ironInjection) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 50,
                child: CustomTextField(
                  controller: _dosageController,
                  label: '${l10n.dose} *',
                  hintText: l10n.enterDose,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.doseRequired
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 50,
                child: CustomDropdown<String>(
                  label: l10n.quantityUnit,
                  hint: l10n.selectUnit,
                  icon: Icons.straighten_outlined,
                  value: _selectedDosageUnit,
                  dropdownItems: _dosageUnits
                      .map((u) => DropdownItem<String>(value: u, label: u))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDosageUnit = v),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? l10n.unitRequired : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingReference
              ? const LoadingIndicator()
              : CustomDropdown<int>(
                  label: l10n.medicine,
                  hint: l10n.selectMedicine,
                  icon: Icons.medication_outlined,
                  value: _selectedMedicineId,
                  dropdownItems: _medicineItems,
                  onChanged: (v) => setState(() => _selectedMedicineId = v),
                  validator: (v) => v == null ? l10n.medicineRequired : null,
                ),
          const SizedBox(height: 16),
        ],
        if (widget.eventType == HusbandryEventType.livestockMarking) ...[
          CustomDropdown<String>(
            label: l10n.markingType,
            hint: l10n.markingType,
            icon: Icons.sell_outlined,
            value: _selectedMarkingType,
            dropdownItems: _markingTypeItems,
            onChanged: (v) => setState(() => _selectedMarkingType = v),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? l10n.identityTypeRequired
                : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _descriptionController,
            label: l10n.description,
            hintText: l10n.enterNotesOptional,
          ),
          const SizedBox(height: 16),
        ],
        if (widget.eventType == HusbandryEventType.stageChange) ...[
          CustomDropdown<int>(
            label: l10n.fromStage,
            hint: l10n.selectFromStage,
            icon: Icons.alt_route_outlined,
            value: _selectedFromStageId,
            isRequired: false,
            dropdownItems: _stageItems,
            onChanged: (v) => setState(() => _selectedFromStageId = v),
          ),
          const SizedBox(height: 16),
          CustomDropdown<int>(
            label: l10n.toStage,
            hint: l10n.selectToStage,
            icon: Icons.alt_route_outlined,
            value: _selectedToStageId,
            dropdownItems: _stageItems,
            onChanged: (v) => setState(() => _selectedToStageId = v),
            validator: (v) => v == null ? l10n.livestockTypeRequired : null,
          ),
          const SizedBox(height: 16),
        ],
        CustomTextField(
          controller: _notesController,
          label: l10n.notes,
          hintText: l10n.enterNotesOptional,
          maxLines: 4,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _title(AppLocalizations l10n) {
    switch (widget.eventType) {
      case HusbandryEventType.ironInjection:
        return l10n.ironInjection;
      case HusbandryEventType.teethClipping:
        return l10n.teethClipping;
      case HusbandryEventType.tailDocking:
        return l10n.tailDocking;
      case HusbandryEventType.livestockMarking:
        return l10n.livestockMarking;
      case HusbandryEventType.stageChange:
        return l10n.stageChange;
    }
  }
}
