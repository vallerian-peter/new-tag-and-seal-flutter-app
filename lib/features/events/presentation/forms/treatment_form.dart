import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/treatment_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/presentation/bill_creation_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';

class TreatmentFormScreen extends StatefulWidget {
  final TreatmentModel? treatment;
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;

  const TreatmentFormScreen({
    super.key,
    this.treatment,
    this.farmUuid,
    this.livestockUuid,
    this.isBulk = false,
    this.bulkLivestockUuids,
  });

  bool get isEditMode => treatment != null;

  @override
  State<TreatmentFormScreen> createState() => _TreatmentFormScreenState();
}

class _TreatmentFormScreenState extends State<TreatmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _withdrawalController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _medicationDateController = TextEditingController();
  final _nextMedicationDateController = TextEditingController();
  final _remarksController = TextEditingController();

  int _currentStep = 0;
  bool _isLoadingContext = true;
  bool _isLoadingLivestock = false;
  bool _isLoadingReference = true;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  List<DropdownItem<int>> _medicineItems = const [];
  List<DropdownItem<int>> _diseaseItems = const [];

  final List<String> _quantityUnits = const ['ml', 'l', 'mg', 'g', 'kg'];
  final List<String> _withdrawalUnits = const [
    'min',
    'hrs',
    'days',
    'weeks',
    'months',
    'years',
  ];

  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;
  List<Livestock> _selectedBulkLivestock = [];
  int? _selectedMedicineId;
  DateTime? _selectedEventDate;
  DateTime? _selectedMedicationDate;
  DateTime? _selectedNextMedicationDate;
  int? _selectedDiseaseId;
  String? _selectedQuantityUnit;
  String? _selectedWithdrawalUnit;

  bool get _isBulk => widget.isBulk;

  @override
  void initState() {
    super.initState();
    _prefillIfEditing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initialize();
      }
    });
  }

  void _prefillIfEditing() {
    final treatment = widget.treatment;
    _selectedFarmUuid = widget.farmUuid ?? treatment?.farmUuid;
    _selectedLivestockUuid =
        _isBulk ? null : widget.livestockUuid ?? treatment?.livestockUuid;

    if (treatment == null) return;

    _parseQuantityString(treatment.quantity);
    _parseWithdrawalString(treatment.withdrawalPeriod);
    _remarksController.text = treatment.remarks ?? '';
    _selectedDiseaseId = treatment.diseaseId;

    if (treatment.eventDate != null &&
        treatment.eventDate!.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(treatment.eventDate!);
      if (parsed != null) {
        _selectedEventDate = parsed;
        _eventDateController.text = DateFormat.yMMMd().add_jm().format(parsed.toLocal());
      }
    }

    if (treatment.medicationDate != null &&
        treatment.medicationDate!.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(treatment.medicationDate!);
      if (parsed != null) {
        _selectedMedicationDate = parsed;
        _medicationDateController.text = DateFormat.yMMMd().add_jm().format(
          parsed.toLocal(),
        );
      }
    }

    if (treatment.nextMedicationDate != null &&
        treatment.nextMedicationDate!.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(treatment.nextMedicationDate!);
      if (parsed != null) {
        _selectedNextMedicationDate = parsed;
        _nextMedicationDateController.text = DateFormat.yMMMd().add_jm().format(
          parsed.toLocal(),
        );
      }
    }

    _selectedMedicineId = treatment.medicineId;
    _selectedQuantityUnit ??= _quantityUnits.first;
    _selectedWithdrawalUnit ??= _withdrawalUnits.first;
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoadingContext = true;
      _isLoadingReference = true;
    });

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      await Future.wait([_loadContextData(database), _loadReferenceData()]);
    } catch (e, stackTrace) {
      log('❌ Failed to initialize treatment form: $e', stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingContext = false;
          _isLoadingReference = false;
          _selectedQuantityUnit ??= _quantityUnits.first;
          _selectedWithdrawalUnit ??= _withdrawalUnits.first;
        });
      }
    }
  }

  Future<void> _loadContextData(AppDatabase database) async {
    final farms = await database.farmDao.getAllActiveFarms();

    String? farmUuid = _selectedFarmUuid;
    if (farmUuid != null && farms.every((farm) => farm.uuid != farmUuid)) {
      farmUuid = null;
    }
    if (farmUuid == null && farms.isNotEmpty) {
      farmUuid = farms.first.uuid;
    }

    List<Livestock> livestock = [];
    if (farmUuid != null && farmUuid.isNotEmpty) {
      livestock = await database.livestockDao.getActiveLivestockByFarmUuid(
        farmUuid,
      );
    }

    String? livestockUuid = _selectedLivestockUuid;
    if (!_isBulk) {
    if (livestockUuid != null &&
        livestock.every((item) => item.uuid != livestockUuid)) {
      livestockUuid = null;
    }
    if (livestockUuid == null && livestock.isNotEmpty) {
      livestockUuid = livestock.first.uuid;
      }
    }

    List<Livestock> selectedBulkLivestock = _selectedBulkLivestock;
    if (_isBulk) {
      final initialSelection = widget.bulkLivestockUuids ?? const [];
      if (selectedBulkLivestock.isEmpty && initialSelection.isNotEmpty) {
        selectedBulkLivestock = livestock
            .where((item) => initialSelection.contains(item.uuid))
            .toList();
      } else {
        selectedBulkLivestock = selectedBulkLivestock
            .where((item) => livestock.any((animal) => animal.uuid == item.uuid))
            .toList();
      }
    }

    if (!mounted) return;
    setState(() {
      _farms = farms;
      _farmLivestock = livestock;
      _selectedFarmUuid = farmUuid;
      _selectedLivestockUuid = livestockUuid;
      _selectedBulkLivestock = selectedBulkLivestock;
    });
  }

  Future<void> _loadReferenceData() async {
    try {
      final provider = Provider.of<LogAdditionalDataProvider>(
        context,
        listen: false,
      );
      
      log('🔄 Medication form: Ensuring reference data is loaded...');
      await provider.ensureLoaded();
      log('✅ Medication form: Reference data loading completed');

      // Load medicines
      final medicines = provider.medicines;
      log('💊 Medication form: Loaded ${medicines.length} medicines');
      if (!mounted) return;
      setState(() {
        _medicineItems = medicines
            .map(
              (medicine) =>
                  DropdownItem<int>(value: medicine.id, label: medicine.name),
            )
            .toList();
      });

      if (_medicineItems.isNotEmpty) {
        if (_selectedMedicineId == null ||
            _medicineItems.every((item) => item.value != _selectedMedicineId)) {
          setState(() => _selectedMedicineId = _medicineItems.first.value);
        }
      } else {
        setState(() => _selectedMedicineId = null);
      }

      // Load diseases
      final diseases = provider.diseases;
      log('🦠 Medication form: Loaded ${diseases.length} diseases');
      final diseaseItems = diseases
          .map(
            (disease) =>
                DropdownItem<int>(value: disease.id, label: disease.name),
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _diseaseItems = diseaseItems;
        if (_selectedDiseaseId != null &&
            diseaseItems.every((item) => item.value != _selectedDiseaseId)) {
          _selectedDiseaseId = null;
        }
      });
      
      log('✅ Medication form: Reference data loaded - Medicines: ${_medicineItems.length}, Diseases: ${_diseaseItems.length}');
    } catch (e, stackTrace) {
      log(
        '❌ Failed to load reference data for medication form: $e',
        stackTrace: stackTrace,
      );
      // Ensure we still set empty lists on error
      if (mounted) {
        setState(() {
          _medicineItems = const [];
          _diseaseItems = const [];
        });
      }
    }
  }

  Future<void> _onFarmSelected(String value) async {
    setState(() {
      _selectedFarmUuid = value;
      if (!_isBulk && widget.livestockUuid == null) {
        _selectedLivestockUuid = null;
      }
      if (_isBulk) {
        _selectedBulkLivestock = [];
      }
      _isLoadingLivestock = true;
    });

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      final livestock = await database.livestockDao
          .getActiveLivestockByFarmUuid(value);

      if (!mounted) return;
      setState(() {
        _farmLivestock = livestock;
        if (!_isBulk && _selectedLivestockUuid == null && livestock.isNotEmpty) {
          _selectedLivestockUuid = livestock.first.uuid;
        }
      });
    } catch (e, stackTrace) {
      log('❌ Failed to load livestock for farm: $e', stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() => _isLoadingLivestock = false);
      }
    }
  }

  void _onLivestockSelected(String? value) {
    if (value == null) return;
    setState(() => _selectedLivestockUuid = value);
  }

  Future<void> _openBulkLivestockSelector(AppLocalizations l10n) async {
    final farmUuid = _selectedFarmUuid ?? widget.farmUuid;
    if (farmUuid == null || farmUuid.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.farmRequired)));
      return;
    }

    final selection = await Navigator.of(context).push<List<Livestock>>(
      MaterialPageRoute(
        builder: (_) => BulkLivestockSelectorPage(
          farmUuid: farmUuid,
          preselectedLivestock: _selectedBulkLivestock,
        ),
      ),
    );

    if (!mounted || selection == null) return;
    setState(() {
      _selectedBulkLivestock = selection;
    });
  }

  bool _hasValidLivestockSelection(AppLocalizations l10n) {
    if (_isBulk) {
      if (_selectedBulkLivestock.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
        return false;
      }
      return true;
    }

    if (_selectedLivestockUuid == null || _selectedLivestockUuid!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _withdrawalController.dispose();
    _medicationDateController.dispose();
    _nextMedicationDateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.treatment ?? l10n.medication}'
        : (l10n.addTreatment ?? l10n.addMedication);
    final submitLabel = widget.isEditMode ? l10n.update : l10n.save;

    final isLoading = _isLoadingContext || _isLoadingReference;

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
          title,
          style: TextStyle(
            fontSize: Constants.largeTextSize,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: LoadingIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: CustomStepper(
                        currentStep: _currentStep,
                        onStepContinue: _onStepContinue,
                        onStepCancel: _onStepCancel,
                        continueButtonText: null,
                        backButtonText: l10n.back,
                        finalStepButtonText: submitLabel,
                        steps: [
                          StepperStep(
                            title: l10n.basicInformation,
                            subtitle: l10n.recordsAndLogs,
                            icon: Icons.analytics_outlined,
                            content: _buildContextStep(l10n, theme),
                          ),
                          StepperStep(
                            title: l10n.medicationDetails,
                            subtitle: l10n.medicationDetailsSubtitle,
                            icon: Icons.medical_services_outlined,
                            content: _buildDetailsStep(l10n, theme),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContextStep(AppLocalizations l10n, ThemeData theme) {
    final farmItems = _farms
        .map((farm) => DropdownItem<String>(value: farm.uuid, label: farm.name))
        .toList();
    final livestockItems = _farmLivestock
        .map(
          (item) => DropdownItem<String>(
            value: item.uuid,
            label: item.name.isNotEmpty
                ? item.name
                : '${l10n.livestock} #${item.id}',
          ),
        )
        .toList();

    final isFarmLocked = widget.farmUuid != null && widget.farmUuid!.isNotEmpty;
    final isLivestockLocked =
        widget.livestockUuid != null && widget.livestockUuid!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.recordsAndLogs, theme),
        const SizedBox(height: 20),
        if (_farms.isEmpty)
          _buildInfoBanner(
            message: l10n.logContextMissing,
            theme: theme,
            tone: InfoBannerTone.warning,
            icon: Icons.info_outline,
          )
        else ...[
          CustomDropdown<String>(
            label: l10n.selectFarm,
            hint: l10n.selectFarm,
            icon: Icons.agriculture_outlined,
            value: _selectedFarmUuid,
            dropdownItems: farmItems,
            enabled: !_isBulk && !isFarmLocked,
            onChanged: (value) {
              if (value == null || value == _selectedFarmUuid) return;
              _onFarmSelected(value);
            },
            validator: (value) {
              if ((value == null || value.isEmpty) &&
                  (widget.farmUuid == null || widget.farmUuid!.isEmpty)) {
                return l10n.farmRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (_isLoadingLivestock)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_isBulk)
            BulkLivestockSummaryTile(
              count: _selectedBulkLivestock.length,
              onTap: () => _openBulkLivestockSelector(l10n),
            )
          else if (_farmLivestock.isEmpty)
            _buildInfoBanner(
              message: l10n.noLivestockFound,
              theme: theme,
              tone: InfoBannerTone.warning,
              icon: Icons.info_outline,
            )
          else
            CustomDropdown<String>(
              label: l10n.selectLivestock,
              hint: l10n.selectLivestock,
              icon: Icons.pets_outlined,
              value: _selectedLivestockUuid,
              dropdownItems: livestockItems,
              enabled: !isLivestockLocked,
              onChanged: _onLivestockSelected,
              validator: (value) {
                if ((value == null || value.isEmpty) &&
                    (widget.livestockUuid == null ||
                        widget.livestockUuid!.isEmpty)) {
                  return l10n.livestockRequired;
                }
                return null;
              },
            ),
        ],
        const SizedBox(height: 24),
        _buildSectionTitle(l10n.medicationDetails, theme),
        const SizedBox(height: 16),
        if (_medicineItems.isEmpty)
          _buildInfoBanner(
            message: l10n.medicineRequired,
            theme: theme,
            tone: InfoBannerTone.warning,
            icon: Icons.warning_amber_rounded,
          )
        else
          CustomDropdown<int>(
            label: l10n.selectMedicine,
            hint: l10n.selectMedicine,
            icon: Icons.medical_services_outlined,
            value: _selectedMedicineId,
            dropdownItems: _medicineItems,
            onChanged: (value) => setState(() => _selectedMedicineId = value),
            validator: (value) {
              if (_medicineItems.isNotEmpty && value == null) {
                return l10n.medicineRequired;
              }
              return null;
            },
          ),
        const SizedBox(height: 16),
        const SizedBox(height: 24),
        _buildInfoBanner(
          message: l10n.medicationContextInfo,
          theme: theme,
          icon: Icons.info_outline,
        ),
      ],
    );
  }

  Widget _buildDetailsStep(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.medicationDetails, theme),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _quantityController,
                label: l10n.quantity,
                hintText: l10n.enterQuantity,
                prefixIcon: Icons.scale_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.quantityRequired;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown<String>(
                label: l10n.quantityUnit,
                hint: l10n.selectQuantityUnit,
                icon: Icons.straighten_outlined,
                value: _selectedQuantityUnit,
                dropdownItems: _buildQuantityUnitItems(l10n),
                onChanged: (value) =>
                    setState(() => _selectedQuantityUnit = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _withdrawalController,
                label: l10n.withdrawalPeriod,
                hintText: l10n.enterWithdrawalPeriodOptional,
                prefixIcon: Icons.timer_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown<String>(
                label: l10n.withdrawalUnit,
                hint: l10n.selectWithdrawalUnit,
                icon: Icons.av_timer_outlined,
                value: _selectedWithdrawalUnit,
                dropdownItems: _buildWithdrawalUnitItems(l10n),
                onChanged: (value) =>
                    setState(() => _selectedWithdrawalUnit = value),
                isRequired: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingReference)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_diseaseItems.isEmpty)
          _buildInfoBanner(
            message: l10n.diseaseOptionsMissing,
            theme: theme,
            tone: InfoBannerTone.warning,
            icon: Icons.warning_amber_rounded,
          )
        else
          CustomDropdown<int>(
            label: l10n.diseaseId,
            hint: l10n.selectDisease,
            icon: Icons.biotech_outlined,
            value: _selectedDiseaseId,
            dropdownItems: _diseaseItems,
            onChanged: (value) => setState(() => _selectedDiseaseId = value),
            isRequired: false,
          ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _eventDateController,
          label: l10n.eventDate,
          hintText: l10n.selectEventDate,
          prefixIcon: Icons.event_available_outlined,
          readOnly: true,
          onTap: _pickEventDate,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _medicationDateController,
          label: l10n.medicationDate,
          hintText: l10n.selectMedicationDate,
          prefixIcon: Icons.event_outlined,
          readOnly: true,
          onTap: _pickMedicationDate,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _nextMedicationDateController,
          label: l10n.nextMedicationDate ?? 'Next Medication Date',
          hintText: l10n.selectNextMedicationDate ?? 'Select Next Medication Date',
          prefixIcon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: _pickNextMedicationDate,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _remarksController,
          label: l10n.remarks,
          hintText: l10n.enterRemarksOptional,
          prefixIcon: Icons.notes_outlined,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        _buildInfoBanner(
          message: l10n.medicationNotesInfo,
          theme: theme,
          icon: Icons.lightbulb_outline,
        ),
      ],
    );
  }

  Future<void> _pickNextMedicationDate() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? theme.scaffoldBackgroundColor 
        : whiteColor;
    final initial = _selectedNextMedicationDate ?? DateTime.now();
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
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

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
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
            timePickerTheme: TimePickerThemeData(
              backgroundColor: backgroundColor,
              dialBackgroundColor: backgroundColor,
              hourMinuteColor: backgroundColor,
              hourMinuteTextColor: theme.colorScheme.onSurface,
              dialHandColor: Constants.primaryColor,
              dialTextColor: theme.colorScheme.onSurface,
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

    if (time == null || !mounted) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedNextMedicationDate = combined;
      _nextMedicationDateController.text = DateFormat.yMMMd().add_jm().format(
        combined.toLocal(),
      );
    });
  }

  Future<void> _pickEventDate() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? theme.scaffoldBackgroundColor 
        : whiteColor;
    final initial = _selectedEventDate ?? DateTime.now();

    final date = await showDatePicker(
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

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
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
            timePickerTheme: TimePickerThemeData(
              backgroundColor: backgroundColor,
              dialBackgroundColor: backgroundColor,
              hourMinuteColor: backgroundColor,
              hourMinuteTextColor: theme.colorScheme.onSurface,
              dialHandColor: Constants.primaryColor,
              dialTextColor: theme.colorScheme.onSurface,
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

    if (time == null || !mounted) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedEventDate = combined;
      _eventDateController.text = DateFormat.yMMMd().add_jm().format(
        combined.toLocal(),
      );
    });
  }

  Future<void> _pickMedicationDate() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? theme.scaffoldBackgroundColor 
        : whiteColor;
    final initial = _selectedMedicationDate ?? DateTime.now();

    final date = await showDatePicker(
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

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
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
            timePickerTheme: TimePickerThemeData(
              backgroundColor: backgroundColor,
              dialBackgroundColor: backgroundColor,
              hourMinuteColor: backgroundColor,
              hourMinuteTextColor: theme.colorScheme.onSurface,
              dialHandColor: Constants.primaryColor,
              dialTextColor: theme.colorScheme.onSurface,
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

    if (time == null || !mounted) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedMedicationDate = combined;
      _medicationDateController.text = DateFormat.yMMMd().add_jm().format(
        combined.toLocal(),
      );
    });
  }

  void _onStepContinue() async {
    final l10n = AppLocalizations.of(context)!;
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate() &&
          _hasValidLivestockSelection(l10n)) {
        setState(() => _currentStep = 1);
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (!_hasValidLivestockSelection(l10n)) return;

    await AlertDialogs.showConfirmation(
      context: context,
      title: widget.isEditMode ? l10n.update : l10n.save,
      message: widget.isEditMode
          ? l10n.confirmUpdateTreatment
          : l10n.confirmSaveTreatment,
      confirmText: widget.isEditMode ? l10n.update : l10n.save,
      cancelText: l10n.cancel,
      onConfirm: () async {
        if (!mounted) return;
        Navigator.of(context).pop(true);
        await _submit();
      },
    );
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    final selectedFarmUuid = widget.farmUuid ?? _selectedFarmUuid;
    final livestockUuids = _isBulk
        ? _selectedBulkLivestock.map((livestock) => livestock.uuid).toList()
        : [
            if (widget.livestockUuid != null &&
                widget.livestockUuid!.isNotEmpty)
              widget.livestockUuid!
            else if (_selectedLivestockUuid != null &&
                _selectedLivestockUuid!.isNotEmpty)
              _selectedLivestockUuid!
          ];

    if (selectedFarmUuid == null || selectedFarmUuid.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.farmRequired)));
      return;
    }
    if (livestockUuids.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
      return;
    }

    if (_medicineItems.isNotEmpty && _selectedMedicineId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.medicineRequired)));
      return;
    }

    try {
      final quantity =
          _composeQuantityString() ?? _quantityController.text.trim();
      final withdrawal = _composeWithdrawalString();
      final remarks = _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim();
      final eventDateIso = _selectedEventDate?.toIso8601String();
      final medicationDateIso = _selectedMedicationDate?.toIso8601String();
      final nextMedicationDateIso = _selectedNextMedicationDate?.toIso8601String();

      if (widget.isEditMode && !_isBulk) {
        final existing = widget.treatment!;
        final updatedModel = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          medicineId: _selectedMedicineId,
          diseaseId: _selectedDiseaseId,
          quantity: quantity,
          withdrawalPeriod: withdrawal,
          eventDate: eventDateIso ?? existing.eventDate,
          medicationDate: medicationDateIso ?? existing.medicationDate,
          nextMedicationDate: nextMedicationDateIso ?? existing.nextMedicationDate,
          remarks: remarks,
          synced: false,
          syncAction: existing.syncAction == 'create' ? 'create' : 'update',
          updatedAt: DateTime.now().toIso8601String(),
        );

        // Show loading
        AlertDialogs.showLoading(
          context: context,
          title: l10n.save,
          message: '',
          isDismissible: false,
        );
        
        final updated = await eventsProvider.updateTreatment(updatedModel);
        
        if (mounted) {
          Navigator.of(context).pop(); // Close loading
          
          // Show bill dialog first (if extension officer)
          await BillCreationHelper.maybeCreateBillForLog(
            context: context,
            logType: EventLogTypes.treatment,
            farmUuid: selectedFarmUuid,
            subjectUuid: updated.uuid,
            quantity: 1,
            numberOfLivestock: 1,
          );
          
          // Then show success
          if (mounted) {
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: l10n.treatmentLogSaved,
              buttonText: l10n.ok,
            );
            if (mounted) {
              Navigator.pop(context, updated);
            }
          }
        }
      } else if (_isBulk) {
        // Show loading
        AlertDialogs.showLoading(
          context: context,
          title: l10n.save,
          message: l10n.bulkOperationInProgress,
          isDismissible: false,
        );
        
        // Create batch manually
        final created = <TreatmentModel>[];
        for (final animalUuid in livestockUuids) {
          final now = DateTime.now().toIso8601String();
          final uuid = 'treatment-${DateTime.now().microsecondsSinceEpoch}-${animalUuid.hashCode}';
          final model = TreatmentModel(
            uuid: uuid,
            farmUuid: selectedFarmUuid,
            livestockUuid: animalUuid,
            medicineId: _selectedMedicineId,
            diseaseId: _selectedDiseaseId,
            quantity: quantity,
            withdrawalPeriod: withdrawal,
            eventDate: eventDateIso,
            medicationDate: medicationDateIso ?? now,
            nextMedicationDate: nextMedicationDateIso,
            remarks: remarks,
            synced: false,
            syncAction: 'create',
            createdAt: now,
            updatedAt: now,
          );
          created.add(await eventsProvider.addTreatment(model));
        }

        if (mounted) {
          Navigator.of(context).pop(); // Close loading
          
          // Show bill dialog first (if extension officer)
          await BillCreationHelper.maybeCreateBillForLog(
            context: context,
            logType: EventLogTypes.treatment,
            farmUuid: selectedFarmUuid,
            subjectUuid: created.first.uuid,
            quantity: 1,
            numberOfLivestock: livestockUuids.length,
          );
          
          // Then show success
          if (mounted) {
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: l10n.treatmentLogSaved,
              buttonText: l10n.ok,
            );
            if (mounted) {
              Navigator.pop(context, true);
            }
          }
        }
      } else {
        final now = DateTime.now().toIso8601String();
        final uuid =
            'treatment-${DateTime.now().microsecondsSinceEpoch}-${livestockUuids.first.hashCode}';

        final newModel = TreatmentModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          medicineId: _selectedMedicineId,
          diseaseId: _selectedDiseaseId,
          quantity: quantity,
          withdrawalPeriod: withdrawal,
          eventDate: eventDateIso,
          medicationDate: medicationDateIso ?? now,
          nextMedicationDate: nextMedicationDateIso,
          remarks: remarks,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );

        // Show loading
        AlertDialogs.showLoading(
          context: context,
          title: l10n.save,
          message: '',
          isDismissible: false,
        );
        
        final created = await eventsProvider.addTreatment(newModel);
        
        if (mounted) {
          Navigator.of(context).pop(); // Close loading
          
          // Show bill dialog first (if extension officer)
          await BillCreationHelper.maybeCreateBillForLog(
            context: context,
            logType: EventLogTypes.treatment,
            farmUuid: selectedFarmUuid,
            subjectUuid: created.uuid,
            quantity: 1,
            numberOfLivestock: 1,
          );
          
          // Then show success
          if (mounted) {
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: l10n.treatmentLogSaved,
              buttonText: l10n.ok,
            );
            if (mounted) {
              Navigator.pop(context, created);
            }
          }
        }
      }
    } catch (e, stackTrace) {
      log('❌ Failed to save medication log: $e', stackTrace: stackTrace);
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.treatmentLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }

  void _parseQuantityString(String? value) {
    if (value == null || value.trim().isEmpty) {
      _quantityController.clear();
      return;
    }
    final match = RegExp(
      r'^([0-9]+(?:\.[0-9]+)?)\s*([a-zA-Z]+)?$',
    ).firstMatch(value.trim());
    if (match != null) {
      _quantityController.text = match.group(1) ?? '';
      final unit = match.group(2);
      if (unit != null && _quantityUnits.contains(unit)) {
        _selectedQuantityUnit = unit;
      }
    } else {
      _quantityController.text = value;
    }
  }

  void _parseWithdrawalString(String? value) {
    if (value == null || value.trim().isEmpty) {
      _withdrawalController.clear();
      return;
    }
    final match = RegExp(
      r'^([0-9]+(?:\.[0-9]+)?)\s*([a-zA-Z]+)?$',
    ).firstMatch(value.trim());
    if (match != null) {
      _withdrawalController.text = match.group(1) ?? '';
      final unit = match.group(2);
      if (unit != null && _withdrawalUnits.contains(unit)) {
        _selectedWithdrawalUnit = unit;
      }
    } else {
      _withdrawalController.text = value;
    }
  }

  String? _composeQuantityString() {
    final amount = _quantityController.text.trim();
    if (amount.isEmpty) return null;
    final unit = _selectedQuantityUnit ?? _quantityUnits.first;
    return '$amount$unit';
  }

  String? _composeWithdrawalString() {
    final amount = _withdrawalController.text.trim();
    if (amount.isEmpty) return null;
    final unit = _selectedWithdrawalUnit ?? _withdrawalUnits.first;
    return '$amount$unit';
  }

  List<DropdownItem<String>> _buildQuantityUnitItems(AppLocalizations l10n) {
    return _quantityUnits
        .map(
          (unit) => DropdownItem<String>(
            value: unit,
            label: _quantityUnitLabel(l10n, unit),
          ),
        )
        .toList();
  }

  List<DropdownItem<String>> _buildWithdrawalUnitItems(AppLocalizations l10n) {
    return _withdrawalUnits
        .map(
          (unit) => DropdownItem<String>(
            value: unit,
            label: _withdrawalUnitLabel(l10n, unit),
          ),
        )
        .toList();
  }

  String _quantityUnitLabel(AppLocalizations l10n, String unit) {
    switch (unit) {
      case 'ml':
        return l10n.quantityUnitMl;
      case 'l':
        return l10n.quantityUnitL;
      case 'mg':
        return l10n.quantityUnitMg;
      case 'g':
        return l10n.quantityUnitG;
      case 'kg':
        return l10n.quantityUnitKg;
      default:
        return unit;
    }
  }

  String _withdrawalUnitLabel(AppLocalizations l10n, String unit) {
    switch (unit) {
      case 'min':
        return l10n.withdrawalUnitMinutes;
      case 'hrs':
        return l10n.withdrawalUnitHours;
      case 'days':
        return l10n.withdrawalUnitDays;
      case 'weeks':
        return l10n.withdrawalUnitWeeks;
      case 'months':
        return l10n.withdrawalUnitMonths;
      case 'years':
        return l10n.withdrawalUnitYears;
      default:
        return unit;
    }
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Constants.primaryColor,
      ),
    );
  }

  Widget _buildInfoBanner({
    required String message,
    required ThemeData theme,
    IconData icon = Icons.info_outline,
    InfoBannerTone tone = InfoBannerTone.neutral,
  }) {
    final baseColor = tone == InfoBannerTone.warning
        ? Colors.amber
        : theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: baseColor),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

enum InfoBannerTone { neutral, warning }
