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
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/prepuce_reference_option.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/prepuce_condition_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

/// Same pattern as [DewormingFormScreen]: optional vet or extension officer via medical license.
enum _PrepuceTreatmentProvider { none, vet, extensionOfficer }

class PrepuceConditionFormScreen extends StatefulWidget {
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;

  const PrepuceConditionFormScreen({
    super.key,
    this.farmUuid,
    this.livestockUuid,
    this.isBulk = false,
    this.bulkLivestockUuids,
  });

  @override
  State<PrepuceConditionFormScreen> createState() =>
      _PrepuceConditionFormScreenState();
}

class _PrepuceConditionFormScreenState
    extends State<PrepuceConditionFormScreen> {
  final _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();
  final _eventDateController = TextEditingController();
  final _followUpController = TextEditingController();
  final _quantityController = TextEditingController();
  final _doseController = TextEditingController();
  final _medicalLicenseController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoadingContext = true;
  bool _isLoadingLivestock = false;
  bool _prepuceReferenceReady = true;
  int _currentStep = 0;

  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;
  List<Livestock> _farmLivestock = const [];
  List<Farm> _farms = const [];
  List<Livestock> _selectedBulkLivestock = const [];
  DateTime? _selectedEventDate;

  int? _conditionTypeId;
  int? _severityId;
  final Set<int> _clinicalSignIds = {};
  int? _causeRiskId;
  final Set<int> _treatmentGivenIds = {};
  List<DropdownItem<int>> _medicineItems = const [];
  List<DropdownItem<int>> _administrationRouteItems = const [];
  int? _selectedMedicineId;
  int? _selectedAdministrationRouteId;
  _PrepuceTreatmentProvider _treatmentProvider = _PrepuceTreatmentProvider.none;
  int? _breedingStatusId;
  int? _healingStatusId;
  DateTime? _followUpDate;

  bool get _isBulk => widget.isBulk;

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
    _followUpController.dispose();
    _quantityController.dispose();
    _doseController.dispose();
    _medicalLicenseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _isLoadingContext = true);
    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      await Future.wait([
        _loadContext(db),
        _loadLookups(),
        _loadMedicineAndRoutes(),
      ]);
    } catch (e, st) {
      log('Prepuce form init failed: $e', stackTrace: st);
    } finally {
      if (mounted) setState(() => _isLoadingContext = false);
    }
  }

  Future<void> _loadLookups() async {
    final data = Provider.of<LogAdditionalDataProvider>(context, listen: false);
    await data.ensureLoaded();
    if (!mounted) return;
    const requiredKinds = <String>[
      PrepuceReferenceKind.conditionType,
      PrepuceReferenceKind.severity,
      PrepuceReferenceKind.clinicalSign,
      PrepuceReferenceKind.treatmentGiven,
      PrepuceReferenceKind.breedingStatus,
    ];
    final missing = requiredKinds
        .where((k) => data.prepuceOptionsForKind(k).isEmpty)
        .toList(growable: false);

    setState(() {
      _prepuceReferenceReady = missing.isEmpty;
      // Force explicit user selections from synced rows only.
      _conditionTypeId = null;
      _severityId = null;
      _breedingStatusId = null;
      _clinicalSignIds.clear();
      _treatmentGivenIds.clear();
    });
  }

  Future<void> _loadMedicineAndRoutes() async {
    final data = Provider.of<LogAdditionalDataProvider>(context, listen: false);
    await data.ensureLoaded();
    if (!mounted) return;
    setState(() {
      _administrationRouteItems = data.administrationRoutes
          .map((r) => DropdownItem<int>(value: r.id, label: r.name))
          .toList();
      _medicineItems = data.medicines
          .map((m) => DropdownItem<int>(value: m.id, label: m.name))
          .toList();
    });
  }

  List<PrepuceReferenceOption> _sortedOptions(
    LogAdditionalDataProvider data,
    String kind,
  ) {
    final list = [...data.prepuceOptionsForKind(kind)]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  List<DropdownItem<int>> _dropdownItems(
    LogAdditionalDataProvider data,
    String kind,
  ) {
    final lc = Localizations.localeOf(context).languageCode;
    return _sortedOptions(data, kind)
        .map(
          (e) => DropdownItem<int>(
            value: e.referenceId,
            label: e.labelForLocale(lc),
          ),
        )
        .toList();
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
    });
  }

  Future<void> _onFarmSelected(String value) async {
    setState(() {
      _selectedFarmUuid = value;
      _isLoadingLivestock = true;
      if (!_isBulk) _selectedLivestockUuid = null;
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
      });
    } finally {
      if (mounted) setState(() => _isLoadingLivestock = false);
    }
  }

  bool _validateContext(AppLocalizations l10n) {
    if (_selectedFarmUuid == null || _selectedFarmUuid!.isEmpty) {
      AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.farmRequired,
        buttonText: l10n.ok,
      );
      return false;
    }
    if (_isBulk) {
      if (_selectedBulkLivestock.isEmpty) {
        AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.livestockRequired,
          buttonText: l10n.ok,
        );
        return false;
      }
      return true;
    }
    if (_selectedLivestockUuid == null || _selectedLivestockUuid!.isEmpty) {
      AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.livestockRequired,
        buttonText: l10n.ok,
      );
      return false;
    }
    return true;
  }

  bool _validateDetails(AppLocalizations l10n) {
    if (!_prepuceReferenceReady) {
      ModernAlerts.showErrorToast(context, message: l10n.somethingWentWrong);
      return false;
    }
    if (_selectedEventDate == null) {
      ModernAlerts.showErrorToast(context, message: l10n.eventDateRequired);
      return false;
    }
    if (_conditionTypeId == null ||
        _severityId == null ||
        _breedingStatusId == null) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.husbandryRequiredFields,
      );
      return false;
    }
    if (_clinicalSignIds.isEmpty) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.prepuceConditionSelectCodes,
      );
      return false;
    }
    if (_treatmentGivenIds.isEmpty) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.prepuceConditionTreatmentRequired,
      );
      return false;
    }
    return true;
  }

  bool _validateAssessmentStep(AppLocalizations l10n) {
    if (!_prepuceReferenceReady) {
      ModernAlerts.showErrorToast(context, message: l10n.somethingWentWrong);
      return false;
    }
    if (_selectedEventDate == null) {
      ModernAlerts.showErrorToast(context, message: l10n.eventDateRequired);
      return false;
    }
    if (_conditionTypeId == null || _severityId == null) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.husbandryRequiredFields,
      );
      return false;
    }
    if (_clinicalSignIds.isEmpty) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.prepuceConditionSelectCodes,
      );
      return false;
    }
    return true;
  }

  bool _validateTreatmentStep(AppLocalizations l10n) {
    if (!_prepuceReferenceReady) {
      ModernAlerts.showErrorToast(context, message: l10n.somethingWentWrong);
      return false;
    }
    if (_treatmentGivenIds.isEmpty) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.prepuceConditionTreatmentRequired,
      );
      return false;
    }
    if (_treatmentProvider != _PrepuceTreatmentProvider.none &&
        _medicalLicenseController.text.trim().isEmpty) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.medicalLicenseNumberRequired,
      );
      return false;
    }
    return true;
  }

  bool _validateOutcomeStep(AppLocalizations l10n) {
    if (!_prepuceReferenceReady) {
      ModernAlerts.showErrorToast(context, message: l10n.somethingWentWrong);
      return false;
    }
    if (_breedingStatusId == null) {
      ModernAlerts.showErrorToast(
        context,
        message: l10n.husbandryRequiredFields,
      );
      return false;
    }
    return true;
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

  Future<void> _pickFollowUp() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : whiteColor;
    final eventBase = _selectedEventDate ?? DateTime.now();
    final minDate = DateTime(eventBase.year, eventBase.month, eventBase.day);
    final rawInitial = _followUpDate ?? minDate;
    final initial = rawInitial.isBefore(minDate) ? minDate : rawInitial;
    final date = await showAppDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDate,
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
            datePickerTheme: DatePickerThemeData(
              backgroundColor: backgroundColor,
              surfaceTintColor: Colors.transparent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Constants.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;
    setState(() {
      _followUpDate = date;
      _followUpController.text = DateFormat.yMMMd().format(date.toLocal());
    });
  }

  Future<void> _onStepContinue() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_prepuceReferenceReady && _currentStep > 0) {
      ModernAlerts.showErrorToast(context, message: l10n.somethingWentWrong);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_currentStep == 0) {
      if (!_validateContext(l10n)) return;
      setState(() => _currentStep += 1);
      return;
    }
    if (_currentStep == 1) {
      if (!_validateAssessmentStep(l10n)) return;
      setState(() => _currentStep += 1);
      return;
    }
    if (_currentStep == 2) {
      if (!_validateTreatmentStep(l10n)) return;
      setState(() => _currentStep += 1);
      return;
    }
    if (!_validateOutcomeStep(l10n) || !_validateDetails(l10n)) return;

    await AlertDialogs.showConfirmation(
      context: context,
      title: l10n.save,
      message: '${l10n.confirm} ${l10n.prepuceConditionTitle}?',
      confirmText: l10n.save,
      cancelText: l10n.cancel,
      onConfirm: () async {
        if (!mounted) return;
        Navigator.of(context).pop(true);
        await _submit();
      },
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
    final followIso = _followUpDate?.toIso8601String();
    final license = _medicalLicenseController.text.trim();
    final vetId = _treatmentProvider == _PrepuceTreatmentProvider.vet
        ? (license.isEmpty ? null : license)
        : null;
    final extensionOfficerId =
        _treatmentProvider == _PrepuceTreatmentProvider.extensionOfficer
        ? (license.isEmpty ? null : license)
        : null;

    try {
      AlertDialogs.showLoading(
        context: context,
        title: l10n.save,
        message: '',
        isDismissible: false,
      );
      for (final livestockUuid in livestockUuids) {
        await provider.addPrepuceCondition(
          PrepuceConditionModel(
            uuid: _uuid.v4(),
            farmUuid: farmUuid,
            livestockUuid: livestockUuid,
            conditionTypeId: _conditionTypeId!,
            severityId: _severityId!,
            clinicalSignIds: _clinicalSignIds.toList()..sort(),
            causeRiskId: _causeRiskId,
            treatmentGivenIds: _treatmentGivenIds.toList()..sort(),
            medicineId: _selectedMedicineId,
            administrationRouteId: _selectedAdministrationRouteId,
            vetId: vetId,
            extensionOfficerId: extensionOfficerId,
            quantity: _quantityController.text.trim().isEmpty
                ? null
                : _quantityController.text.trim(),
            dose: _doseController.text.trim().isEmpty
                ? null
                : _doseController.text.trim(),
            breedingStatusId: _breedingStatusId!,
            healingStatusId: _healingStatusId,
            followUpDate: followIso,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            eventDate: eventDate,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      await AlertDialogs.showSuccess(
        context: context,
        title: l10n.success,
        message: l10n.eventLogSavedSuccessfully,
        buttonText: l10n.ok,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e, st) {
      log('Prepuce condition save failed: $e', stackTrace: st);
      if (!mounted) return;
      Navigator.of(context).pop();
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.somethingWentWrong,
        buttonText: l10n.ok,
      );
    }
  }

  Widget _chipSection(
    String title,
    List<PrepuceReferenceOption> options,
    Set<int> selected,
  ) {
    final lc = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final systemColor = Constants.primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: Constants.textSize,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options.map((opt) {
            final isOn = selected.contains(opt.referenceId);
            return FilterChip(
              showCheckmark: false,
              side: BorderSide(color: systemColor, width: 1.4),
              selectedColor: systemColor,
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOn) ...[
                    const Icon(Icons.check, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    opt.labelForLocale(lc),
                    style: TextStyle(
                      color: isOn ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              selected: isOn,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    selected.add(opt.referenceId);
                  } else {
                    selected.remove(opt.referenceId);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final refData = Provider.of<LogAdditionalDataProvider>(context);

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
          l10n.prepuceConditionTitle,
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
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDropdown<String>(
                          label: l10n.farm,
                          hint: l10n.selectFarm,
                          icon: Icons.agriculture_outlined,
                          value: _selectedFarmUuid,
                          dropdownItems: _farms
                              .map(
                                (f) =>
                                    DropdownItem(value: f.uuid, label: f.name),
                              )
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
                              final picked = await Navigator.of(context)
                                  .push<List<Livestock>>(
                                    MaterialPageRoute(
                                      builder: (_) => BulkLivestockSelectorPage(
                                        farmUuid: farmUuid,
                                        preselectedLivestock:
                                            _selectedBulkLivestock,
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
                                    setState(
                                      () => _selectedLivestockUuid = value,
                                    );
                                  },
                                ),
                        ],
                      ],
                    ),
                  ),
                  StepperStep(
                    title: l10n.additionalDetails,
                    subtitle: l10n.prepuceConditionTypeLabel,
                    icon: Icons.analytics_outlined,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _eventDateController,
                          label: l10n.eventDate,
                          hintText: l10n.selectEventDate,
                          readOnly: true,
                          prefixIcon: Icons.calendar_today,
                          onTap: _pickEventDate,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.eventDateRequired
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdown<int>(
                          label: l10n.prepuceConditionTypeLabel,
                          hint: l10n.prepuceConditionSelectCodes,
                          icon: Icons.category_outlined,
                          value: _conditionTypeId,
                          dropdownItems: _dropdownItems(
                            refData,
                            PrepuceReferenceKind.conditionType,
                          ),
                          onChanged: (v) =>
                              setState(() => _conditionTypeId = v),
                          validator: (v) =>
                              v == null ? l10n.husbandryRequiredFields : null,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdown<int>(
                          label: l10n.prepuceConditionSeverityLabel,
                          hint: l10n.prepuceConditionSelectCodes,
                          icon: Icons.warning_amber_outlined,
                          value: _severityId,
                          dropdownItems: _dropdownItems(
                            refData,
                            PrepuceReferenceKind.severity,
                          ),
                          onChanged: (v) => setState(() => _severityId = v),
                          validator: (v) =>
                              v == null ? l10n.husbandryRequiredFields : null,
                        ),
                        const SizedBox(height: 8),
                        _chipSection(
                          l10n.prepuceConditionClinicalSignsLabel,
                          _sortedOptions(
                            refData,
                            PrepuceReferenceKind.clinicalSign,
                          ),
                          _clinicalSignIds,
                        ),
                        CustomDropdown<int>(
                          label: l10n.prepuceConditionCauseLabel,
                          hint: l10n.prepuceConditionSelectCodes,
                          icon: Icons.help_outline,
                          isRequired: false,
                          value: _causeRiskId,
                          dropdownItems: _dropdownItems(
                            refData,
                            PrepuceReferenceKind.causeRisk,
                          ),
                          onChanged: (v) => setState(() => _causeRiskId = v),
                        ),
                      ],
                    ),
                  ),
                  StepperStep(
                    title: l10n.prepuceConditionTreatmentLabel,
                    subtitle: l10n.treatmentProvider,
                    icon: Icons.medical_services_outlined,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _chipSection(
                          l10n.prepuceConditionTreatmentLabel,
                          _sortedOptions(
                            refData,
                            PrepuceReferenceKind.treatmentGiven,
                          ),
                          _treatmentGivenIds,
                        ),
                        CustomDropdown<int>(
                          label: l10n.prepuceConditionRouteLabel,
                          hint: l10n.selectAdministrationRoute,
                          icon: Icons.route_outlined,
                          isRequired: false,
                          value: _selectedAdministrationRouteId,
                          dropdownItems: _administrationRouteItems,
                          onChanged: (v) => setState(
                            () => _selectedAdministrationRouteId = v,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomDropdown<int>(
                          label: l10n.medicine,
                          hint: l10n.selectMedicine,
                          icon: Icons.medication_outlined,
                          isRequired: false,
                          value: _selectedMedicineId,
                          dropdownItems: _medicineItems,
                          onChanged: (v) =>
                              setState(() => _selectedMedicineId = v),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _quantityController,
                          label: l10n.quantity,
                          hintText: l10n.enterNotesOptional,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _doseController,
                          label: l10n.dose,
                          hintText: l10n.enterDose,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdown<_PrepuceTreatmentProvider>(
                          label: l10n.treatmentProvider,
                          hint: l10n.selectTreatmentProvider,
                          icon: Icons.person_search_outlined,
                          value: _treatmentProvider,
                          dropdownItems: [
                            DropdownItem(
                              value: _PrepuceTreatmentProvider.none,
                              label: l10n.treatmentProviderNone,
                            ),
                            DropdownItem(
                              value: _PrepuceTreatmentProvider.vet,
                              label: l10n.treatmentProviderVet,
                            ),
                            DropdownItem(
                              value: _PrepuceTreatmentProvider.extensionOfficer,
                              label: l10n.treatmentProviderExtensionOfficer,
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _treatmentProvider =
                                  value ?? _PrepuceTreatmentProvider.none;
                              if (_treatmentProvider ==
                                  _PrepuceTreatmentProvider.none) {
                                _medicalLicenseController.clear();
                              }
                            });
                          },
                          isRequired: false,
                        ),
                        if (_treatmentProvider !=
                            _PrepuceTreatmentProvider.none) ...[
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _medicalLicenseController,
                            label: l10n.medicalLicenseNumber,
                            hintText: l10n.enterMedicalLicenseNumber,
                            prefixIcon: Icons.badge_outlined,
                            validator: (value) {
                              if (_treatmentProvider ==
                                  _PrepuceTreatmentProvider.none) {
                                return null;
                              }
                              if (value == null || value.trim().isEmpty) {
                                return l10n.medicalLicenseNumberRequired;
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  StepperStep(
                    title: l10n.prepuceConditionFollowUpLabel,
                    subtitle: l10n.notes,
                    icon: Icons.assignment_turned_in_outlined,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDropdown<int>(
                          label: l10n.prepuceConditionBreedingLabel,
                          hint: l10n.prepuceConditionSelectCodes,
                          icon: Icons.pets,
                          value: _breedingStatusId,
                          dropdownItems: _dropdownItems(
                            refData,
                            PrepuceReferenceKind.breedingStatus,
                          ),
                          onChanged: (v) =>
                              setState(() => _breedingStatusId = v),
                          validator: (v) =>
                              v == null ? l10n.husbandryRequiredFields : null,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdown<int>(
                          label: l10n.prepuceConditionHealingLabel,
                          hint: l10n.prepuceConditionSelectCodes,
                          icon: Icons.healing_outlined,
                          isRequired: false,
                          value: _healingStatusId,
                          dropdownItems: _dropdownItems(
                            refData,
                            PrepuceReferenceKind.healingStatus,
                          ),
                          onChanged: (v) =>
                              setState(() => _healingStatusId = v),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _followUpController,
                          label: l10n.prepuceConditionFollowUpLabel,
                          hintText: l10n.prepuceConditionFollowUpHint,
                          readOnly: true,
                          prefixIcon: Icons.event_available_outlined,
                          onTap: _pickFollowUp,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _notesController,
                          label: l10n.notes,
                          hintText: l10n.enterNotesOptional,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
