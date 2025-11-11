import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/domain/models/vaccine_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/presentation/provider/vaccine_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Screen for creating or editing a vaccine entry.
///
/// - Respects localization by sourcing all strings from `AppLocalizations`.
/// - Reads theme data via `Theme.of(context)` for dynamic styling.
/// - Returns a [VaccineModel] when the form validates successfully.
class VaccineFormScreen extends StatefulWidget {
  final VaccineModel? vaccine;
  final String? farmUuid;

  const VaccineFormScreen({
    super.key,
    this.vaccine,
    this.farmUuid,
  });

  bool get isEditMode => vaccine != null;

  @override
  State<VaccineFormScreen> createState() => _VaccineFormScreenState();
}

class _VaccineFormScreenState extends State<VaccineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _lotController = TextEditingController();
  final _doseAmountController = TextEditingController();
  bool _isLoadingData = true;

  List<Farm> _farms = const [];
  List<DropdownItem<int>> _vaccineTypeItems = const [];
  String? _selectedFarmUuid;
  int? _selectedVaccineTypeId;
  String _selectedStatus = 'active';
  String? _selectedFormulationType;
  String _selectedDoseUnit = 'ml';
  String? _selectedSchedule;
  static const List<String> _doseUnits = [
    'ml',
    'l',
    'cc',
    'mg',
    'g'
  ];
  static const List<String> _scheduleOptions = [
    'regular',
    'booster',
    'seasonal',
    'emergency',
  ];

  @override
  void initState() {
    super.initState();
    _prefillInitialValues();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _prefillInitialValues() {
    final vaccine = widget.vaccine;
    _selectedFarmUuid = widget.farmUuid ?? vaccine?.farmUuid;
    if (vaccine == null) {
      _selectedSchedule = _scheduleOptions.first;
      return;
    }

    _nameController.text = vaccine.name;
    _lotController.text = vaccine.lot ?? '';
    if (vaccine.status != null && vaccine.status!.isNotEmpty) {
      _selectedStatus = vaccine.status!;
    }
    const allowedFormulations = {'live-attenuated', 'inactivated'};
    if (vaccine.formulationType != null &&
        allowedFormulations.contains(vaccine.formulationType)) {
      _selectedFormulationType = vaccine.formulationType;
    }
    _selectedVaccineTypeId = vaccine.vaccineTypeId;
    _selectedSchedule = _scheduleOptions.contains(vaccine.vaccineSchedule)
        ? vaccine.vaccineSchedule
        : _scheduleOptions.first;
    _parseDoseString(vaccine.dose);
  }

  void _parseDoseString(String? dose) {
    if (dose == null || dose.isEmpty) return;
    final match = RegExp(r'^([0-9]+(?:\.[0-9]+)?)\s*([a-zA-Z]+)?$').firstMatch(dose.trim());
    if (match != null) {
      _doseAmountController.text = match.group(1) ?? '';
      final unit = match.group(2);
      if (unit != null && _doseUnits.contains(unit.toLowerCase())) {
        _selectedDoseUnit = unit.toLowerCase();
      }
    } else {
      _doseAmountController.text = dose;
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoadingData = true);
      final database = Provider.of<AppDatabase>(context, listen: false);
      final farms = await database.farmDao.getAllActiveFarms();
      final vaccineTypes = await database.vaccineTypeDao.getAllVaccineTypes();

      log('📥 VaccineForm data fetch -> farms: ${farms.length}, vaccineTypes: ${vaccineTypes.length}');

      if (!mounted) return;

      final vaccineTypeItems = vaccineTypes
          .map(
            (type) => DropdownItem<int>(
              value: type.id,
              label: type.name,
            ),
          )
          .toList();

      if (vaccineTypeItems.isNotEmpty) {
        log('📋 Available vaccine types: ${vaccineTypeItems.map((item) => '${item.value}:${item.label}').join(', ')}');
      } else {
        log('⚠️ No vaccine types found in local cache');
      }

      String? selectedFarm = _selectedFarmUuid;
      if (selectedFarm != null &&
          farms.every((farm) => farm.uuid != selectedFarm)) {
        selectedFarm = null;
      }
      selectedFarm ??= farms.isNotEmpty ? farms.first.uuid : null;

      int? selectedVaccineTypeId = _selectedVaccineTypeId;
      if (selectedVaccineTypeId != null &&
          vaccineTypeItems.every((item) => item.value != selectedVaccineTypeId)) {
        selectedVaccineTypeId = null;
      }
      if (selectedVaccineTypeId == null && vaccineTypeItems.isNotEmpty) {
        selectedVaccineTypeId = vaccineTypeItems.first.value;
      }

      setState(() {
        _farms = farms;
        _vaccineTypeItems = vaccineTypeItems;
        _selectedFarmUuid = selectedFarm;
        _selectedVaccineTypeId = selectedVaccineTypeId;
        _selectedSchedule ??= _scheduleOptions.first;
        _isLoadingData = false;
      });
    } catch (error, stackTrace) {
      log('❌ Failed to load vaccine form data: $error', stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      final messenger = ScaffoldMessenger.of(context);
      final l10n = AppLocalizations.of(context)!;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.farmWithLivestockLoadFailed)),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lotController.dispose();
    _doseAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final title = widget.isEditMode ? l10n.edit : l10n.addVaccine;
    final actionLabel = widget.isEditMode ? l10n.update : l10n.save;

    return Scaffold(
      backgroundColor: Constants.veryLightGreyColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: Theme.of(context).brightness != Brightness.dark
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        elevation: 0,
        leading: CustomBackButton(
          isEnabledBgColor: false,
          iconColor: theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: Constants.largeTextSize,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoadingData
            ? const Center(child: LoadingIndicator())
            : Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: CustomStepper(
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  continueButtonText: _currentStep == 0 ? l10n.continueButton : null,
                  backButtonText: l10n.back,
                  finalStepButtonText: actionLabel,
                  steps: [
                    StepperStep(
                      title: l10n.basicInformation,
                      subtitle: l10n.recordsAndLogs,
                      icon: Icons.notes_outlined,
                      content: _buildBasicInformationStep(l10n, theme),
                    ),
                    StepperStep(
                      title: l10n.additionalDetails,
                      subtitle: l10n.vaccineDetailsSubtitle,
                      icon: Icons.science_outlined,
                      content: _buildAdditionalDetailsStep(l10n, theme),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.vaccines_outlined,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.vaccineDetails,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.vaccineDetailsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformationStep(AppLocalizations l10n, ThemeData theme) {
    final farmItems = _farms
        .map(
          (farm) => DropdownItem<String>(
            value: farm.uuid,
            label: farm.name,
          ),
        )
        .toList();

    final hasFarm = _farms.isNotEmpty;
    final hasVaccineTypes = _vaccineTypeItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(l10n, theme),
        const SizedBox(height: 24),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.agriculture_outlined,
          title: l10n.selectFarm,
          subtitle: l10n.selectFarm,
        ),
        const SizedBox(height: 12),
        if (!hasFarm)
          _buildInfoMessage(
            theme,
            l10n.noFarmsFound,
            icon: Icons.info_outline,
          )
        else
          CustomDropdown<String>(
            label: l10n.selectFarm,
            hint: l10n.selectFarm,
            icon: Icons.agriculture_outlined,
            value: _selectedFarmUuid,
            dropdownItems: farmItems,
            onChanged: (value) {
              setState(() => _selectedFarmUuid = value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.farmRequired;
              }
              return null;
            },
          ),
        const SizedBox(height: 24),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.category_outlined,
          title: l10n.vaccineType,
          subtitle: l10n.selectVaccineType,
        ),
        const SizedBox(height: 12),
        if (!hasVaccineTypes)
          _buildInfoMessage(
            theme,
            l10n.vaccineTypesMissing,
            icon: Icons.warning_amber_rounded,
            tone: InfoTone.warning,
          )
        else
          CustomDropdown<int>(
            label: l10n.vaccineType,
            hint: l10n.selectVaccineType,
            icon: Icons.category_outlined,
            value: _selectedVaccineTypeId,
            dropdownItems: _vaccineTypeItems,
            onChanged: (value) {
              setState(() => _selectedVaccineTypeId = value);
            },
            validator: (value) {
              if (_vaccineTypeItems.isNotEmpty && value == null) {
                return l10n.vaccineTypeRequired;
              }
              return null;
            },
          ),
        const SizedBox(height: 24),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.vaccines_outlined,
          title: l10n.vaccineDetails,
          subtitle: l10n.vaccineDetailsSubtitle,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: l10n.name,
          hintText: l10n.name,
          prefixIcon: Icons.vaccines_outlined,
          controller: _nameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.nameRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsStep(AppLocalizations l10n, ThemeData theme) {
    final statusItems = [
      DropdownItem(value: 'active', label: l10n.active),
      DropdownItem(value: 'notActive', label: l10n.notActive),
    ];
    final formulationItems = [
      DropdownItem(value: 'live-attenuated', label: l10n.formulationLiveAttenuated),
      DropdownItem(value: 'inactivated', label: l10n.formulationInactivated),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          theme: theme,
          icon: Icons.confirmation_number_outlined,
          title: l10n.lotNumber,
          subtitle: l10n.enterLotNumber,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: l10n.lotNumber,
          hintText: l10n.enterLotNumber,
          prefixIcon: Icons.confirmation_number_outlined,
          controller: _lotController,
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.science_outlined,
          title: l10n.formulationType,
          subtitle: l10n.selectFormulationType,
        ),
        const SizedBox(height: 12),
        CustomDropdown<String>(
          label: l10n.formulationType,
          hint: l10n.selectFormulationType,
          icon: Icons.science_outlined,
          value: _selectedFormulationType,
          dropdownItems: formulationItems,
          onChanged: (value) {
            setState(() => _selectedFormulationType = value);
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.medical_services_outlined,
          title: l10n.doseAmount,
          subtitle: l10n.enterDoseAmount,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                label: l10n.doseAmount,
                hintText: l10n.enterDoseAmount,
                prefixIcon: Icons.numbers,
                controller: _doseAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown<String>(
                label: l10n.doseUnit,
                hint: l10n.selectDoseUnit,
                icon: Icons.straighten_outlined,
                value: _selectedDoseUnit,
                dropdownItems: _doseUnits
                    .map(
                      (unit) => DropdownItem(
                        value: unit,
                        label: unit.toUpperCase(),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedDoseUnit = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.event_outlined,
          title: l10n.vaccineSchedule,
          subtitle: l10n.selectVaccineSchedule,
        ),
        const SizedBox(height: 12),
        CustomDropdown<String>(
          label: l10n.vaccineSchedule,
          hint: l10n.selectVaccineSchedule,
          icon: Icons.event_outlined,
          value: _selectedSchedule,
          dropdownItems: _scheduleOptions
              .map(
                (option) => DropdownItem(
                  value: option,
                  label: _scheduleLabel(option, l10n),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedSchedule = value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.selectVaccineSchedule;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.check_circle_outline,
          title: l10n.vaccineStatus,
          subtitle: l10n.selectStatus,
        ),
        const SizedBox(height: 12),
        CustomDropdown<String>(
          label: l10n.vaccineStatus,
          hint: l10n.selectStatus,
          icon: Icons.check_circle_outline,
          value: _selectedStatus,
          dropdownItems: statusItems,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedStatus = value);
          },
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          theme: theme,
          icon: Icons.info_outline,
          message: l10n.ensureVaccineDetailsAccuracy,
        ),
      ],
    );
  }

  void _onStepContinue() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    if (!formState.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }

    if (_vaccineTypeItems.isNotEmpty && _selectedVaccineTypeId == null) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }

    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
      return;
    }

    await _confirmSubmit();
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _confirmSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    await AlertDialogs.showConfirmation(
      context: context,
      title: widget.isEditMode ? l10n.update : l10n.save,
      message:
          widget.isEditMode ? l10n.confirmUpdateVaccine : l10n.confirmSaveVaccine,
      confirmText: widget.isEditMode ? l10n.update : l10n.save,
      cancelText: l10n.cancel,
      onConfirm: () async {
        Navigator.of(context).pop(true);
        await _submit();
      },
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final vaccineProvider =
        Provider.of<VaccineProvider>(context, listen: false);

    final farmUuid = _selectedFarmUuid;
    if (farmUuid == null || farmUuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.farmRequired)),
      );
      return;
    }

    final doseValue = _composeDoseString();
    final scheduleValue = _selectedSchedule ?? _scheduleOptions.first;
    final nowIso = DateTime.now().toIso8601String();

    try {
      if (widget.isEditMode) {
        final existing = widget.vaccine!;
        final updatedModel = existing.copyWith(
          farmUuid: farmUuid,
          name: _nameController.text.trim(),
          lot: _lotController.text.trim().isEmpty ? null : _lotController.text.trim(),
          formulationType: _selectedFormulationType,
          dose: doseValue,
          status: _selectedStatus,
          vaccineTypeId: _selectedVaccineTypeId,
          vaccineSchedule: scheduleValue,
          synced: false,
          syncAction: existing.syncAction == 'create' ? 'create' : 'update',
          updatedAt: nowIso,
        );

        final updated =
            await vaccineProvider.updateVaccineWithDialog(context, updatedModel);
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        }
      } else {
        final uuid = _generateUuid();
        final newModel = VaccineModel(
          id: null,
          uuid: uuid,
          farmUuid: farmUuid,
          name: _nameController.text.trim(),
          lot: _lotController.text.trim().isEmpty ? null : _lotController.text.trim(),
          formulationType: _selectedFormulationType,
          dose: doseValue,
          status: _selectedStatus,
          vaccineTypeId: _selectedVaccineTypeId,
          vaccineSchedule: scheduleValue,
          synced: false,
          syncAction: 'create',
          createdAt: nowIso,
          updatedAt: nowIso,
        );

        final created =
            await vaccineProvider.addVaccineWithDialog(context, newModel);
        if (created != null && mounted) {
          Navigator.pop(context, created);
        }
      }
    } catch (e, stackTrace) {
      log('❌ Failed to save vaccine: $e', stackTrace: stackTrace);
    }
  }

  Widget _buildInfoMessage(
    ThemeData theme,
    String message, {
    IconData icon = Icons.info_outline,
    InfoTone tone = InfoTone.neutral,
  }) {
    final baseColor = tone == InfoTone.warning
        ? Colors.amber
        : theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: baseColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: baseColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Constants.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Constants.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _composeDoseString() {
    final amount = _doseAmountController.text.trim();
    if (amount.isEmpty) return null;
    return '$amount$_selectedDoseUnit';
  }

  String _scheduleLabel(String value, AppLocalizations l10n) {
    switch (value) {
      case 'regular':
        return l10n.vaccineScheduleRegular;
      case 'booster':
        return l10n.vaccineScheduleBooster;
      case 'seasonal':
        return l10n.vaccineScheduleSeasonal;
      case 'emergency':
        return l10n.vaccineScheduleEmergency;
      default:
        return value;
    }
  }

  String _generateUuid() {
    final microseconds = DateTime.now().microsecondsSinceEpoch;
    return 'vaccine-$microseconds';
  }

  Widget _buildSectionTitle({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: primary.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum InfoTone { neutral, warning }

