import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/number_input.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/pregnancy_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/presentation/bill_creation_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';

class PregnancyFormScreen extends StatefulWidget {
  final PregnancyModel? pregnancy;
  final String? farmUuid;
  final String? livestockUuid;

  const PregnancyFormScreen({
    super.key,
    this.pregnancy,
    this.farmUuid,
    this.livestockUuid,
  });

  bool get isEditMode => pregnancy != null;

  @override
  State<PregnancyFormScreen> createState() => _PregnancyFormScreenState();
}

class _PregnancyFormScreenState extends State<PregnancyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey<FormState>();

  final _eventDateController = TextEditingController();
  final _noOfMonthsController = TextEditingController();
  final _testDateController = TextEditingController();
  final _remarksController = TextEditingController();

  int _currentStep = 0;
  bool _isLoadingData = true;
  bool _isLoadingLivestock = false;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;

  int? _selectedTestResultId;
  String _selectedStatus = 'active';
  DateTime? _selectedEventDate;
  DateTime? _selectedTestDate;

  List<DropdownItem<int>> _testResultItems = const [];

  @override
  void initState() {
    super.initState();
    _prefillFormIfEditing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  void _prefillFormIfEditing() {
    final pregnancy = widget.pregnancy;
    _selectedFarmUuid = widget.farmUuid;
    _selectedLivestockUuid = widget.livestockUuid;

    if (pregnancy == null) return;

    if (pregnancy.eventDate != null && pregnancy.eventDate!.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(pregnancy.eventDate!);
      if (parsed != null) {
        _selectedEventDate = parsed;
        _eventDateController.text = DateFormat.yMMMd().add_jm().format(parsed.toLocal());
      }
    }
    _selectedTestResultId = pregnancy.testResultId;
    _noOfMonthsController.text = pregnancy.noOfMonths ?? '';
    _remarksController.text = pregnancy.remarks ?? '';
    _selectedStatus = pregnancy.status;

    _selectedTestDate = pregnancy.testDate != null
        ? DateTime.tryParse(pregnancy.testDate!)
        : null;
    if (_selectedTestDate != null) {
      _testDateController.text = DateFormat.yMMMd().format(
        _selectedTestDate!.toLocal(),
      );
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoadingData = true);
    try {
      await _loadReferenceData();
      await _loadContextData();
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _loadReferenceData() async {
    final provider = Provider.of<LogAdditionalDataProvider>(
      context,
      listen: false,
    );
    await provider.ensureLoaded();

    final results = provider.testResults;
    log('📥 Loaded ${results.length} test results');
    if (!mounted) return;
    setState(() {
      _testResultItems = results
          .map(
            (result) => DropdownItem<int>(value: result.id, label: result.name),
          )
          .toList();
    });
  }

  Future<void> _loadContextData() async {
    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
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
      if (livestockUuid != null &&
          livestock.every((item) => item.uuid != livestockUuid)) {
        livestockUuid = null;
      }
      if (livestockUuid == null && livestock.isNotEmpty) {
        livestockUuid = livestock.first.uuid;
      }

      if (!mounted) return;
      setState(() {
        _farms = farms;
        _farmLivestock = livestock;
        _selectedFarmUuid = farmUuid;
        _selectedLivestockUuid = livestockUuid;
      });
    } catch (e) {
      log('❌ Failed to load context data: $e');
    }
  }

  void _onFarmSelected(String value) async {
    setState(() {
      _selectedFarmUuid = value;
      if (widget.livestockUuid == null) {
        _selectedLivestockUuid = null;
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
        if (_selectedLivestockUuid == null && livestock.isNotEmpty) {
          _selectedLivestockUuid = livestock.first.uuid;
        }
      });
    } catch (e) {
      log('❌ Failed to load livestock: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLivestock = false);
      }
    }
  }

  void _onLivestockSelected(String? value) {
    if (value == null) return;
    setState(() {
      _selectedLivestockUuid = value;
    });
  }

  List<DropdownItem<String>> _buildFarmDropdownItems() {
    return _farms
        .map((farm) => DropdownItem<String>(value: farm.uuid, label: farm.name))
        .toList();
  }

  List<DropdownItem<String>> _buildLivestockDropdownItems(
    AppLocalizations l10n,
  ) {
    return _farmLivestock
        .map(
          (item) => DropdownItem<String>(
            value: item.uuid,
            label: item.name.isNotEmpty
                ? item.name
                : '${l10n.livestock} #${item.id}',
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _eventDateController.dispose();
    _noOfMonthsController.dispose();
    _testDateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.pregnancy}'
        : l10n.addPregnancy;
    final submitText = widget.isEditMode ? l10n.update : l10n.save;

    return Scaffold(
      backgroundColor: Constants.veryLightGreyColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
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
      body: _isLoadingData
          ? const Center(child: LoadingIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: CustomStepper(
                          key: _stepperKey,
                          currentStep: _currentStep,
                          onStepContinue: _onStepContinue,
                          onStepCancel: _onStepCancel,
                          backButtonText: l10n.back,
                          finalStepButtonText: submitText,
                          continueButtonText: null,
                          steps: [
                            StepperStep(
                              title: l10n.basicInformation,
                              subtitle: l10n.pregnancyDetailsSubtitle,
                              icon: Icons.pregnant_woman_outlined,
                              content: _buildStepOne(l10n, theme),
                            ),
                            StepperStep(
                              title: l10n.additionalDetails,
                              subtitle: l10n.pregnancyNotesSubtitle,
                              icon: Icons.note_alt_outlined,
                              content: _buildStepTwo(l10n, theme),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStepOne(AppLocalizations l10n, ThemeData theme) {
    final farmItems = _buildFarmDropdownItems();
    final livestockItems = _buildLivestockDropdownItems(l10n);
    final isFarmLocked = widget.farmUuid != null && widget.farmUuid!.isNotEmpty;
    final isLivestockLocked =
        widget.livestockUuid != null && widget.livestockUuid!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.recordsAndLogs),
        const SizedBox(height: 20),
        if (_farms.isEmpty)
          _buildContextWarning(theme, l10n)
        else ...[
          CustomDropdown<String>(
            label: l10n.selectFarm,
            hint: l10n.selectFarm,
            icon: Icons.agriculture,
            value: _selectedFarmUuid,
            dropdownItems: farmItems,
            enabled: !isFarmLocked,
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
          else if (_farmLivestock.isEmpty)
            _buildNoLivestockInfo(theme, l10n)
          else
            CustomDropdown<String>(
              label: l10n.selectLivestock,
              hint: l10n.selectLivestock,
              icon: Icons.pets,
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
          const SizedBox(height: 24),
        ],
        _buildSectionTitle(l10n.pregnancy),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _eventDateController,
          label: l10n.eventDate,
          hintText: l10n.selectEventDate,
          prefixIcon: Icons.event_available_outlined,
          readOnly: true,
          onTap: _pickEventDate,
        ),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          label: l10n.testResult,
          hint: l10n.testResult,
          icon: Icons.assignment_turned_in_outlined,
          value: _selectedTestResultId,
          dropdownItems: _testResultItems,
          onChanged: (value) => setState(() => _selectedTestResultId = value),
          validator: (value) {
            if (value == null) {
              return l10n.testResultRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        NumberInput(
          controller: _noOfMonthsController,
          label: l10n.numberOfMonths,
          hintText: l10n.numberOfMonths,
          prefixIcon: Icons.calendar_month,
          allowDecimal: false,
          allowNegative: false,
          min: 1,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _testDateController,
          label: l10n.testDate,
          hintText: l10n.testDate,
          prefixIcon: Icons.event_outlined,
          readOnly: true,
          onTap: _pickTestDate,
          validator: (value) {
            if (_selectedTestDate == null) {
              return l10n.testDateRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          label: l10n.status,
          hint: l10n.status,
          icon: Icons.flag_outlined,
          value: _selectedStatus,
          dropdownItems: [
            DropdownItem(value: 'pending', label: l10n.statusPending),
            DropdownItem(value: 'active', label: l10n.statusActive),
            DropdownItem(value: 'not-active', label: l10n.statusNotActive),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedStatus = value);
          },
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.info_outline,
          message: l10n.ensurePregnancyDetailsAccuracy,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStepTwo(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.additionalNotes),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _remarksController,
          label: l10n.remarks,
          hintText: l10n.enterRemarksOptional,
          prefixIcon: Icons.notes_outlined,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.lightbulb_outline,
          message: l10n.pregnancyNotesInfo,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: Constants.largeTextSize,
        fontWeight: FontWeight.bold,
        color: Constants.primaryColor,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String message,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Constants.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: Constants.textSize,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextWarning(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l10n.logContextMissing,
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
      ),
    );
  }

  Widget _buildNoLivestockInfo(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l10n.noLivestockFound,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
    );
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
      _eventDateController.text = DateFormat.yMMMd().add_jm().format(combined.toLocal());
    });
  }

  Future<void> _pickTestDate() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? theme.scaffoldBackgroundColor 
        : whiteColor;
    final initialDate = _selectedTestDate ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

    _selectedTestDate = date;
    _testDateController.text = DateFormat.yMMMd().format(date.toLocal());
  }

  void _onStepContinue() async {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    await AlertDialogs.showConfirmation(
      context: context,
      title: widget.isEditMode ? l10n.update : l10n.save,
      message: widget.isEditMode
          ? l10n.confirmUpdatePregnancy
          : l10n.confirmSavePregnancy,
      confirmText: widget.isEditMode ? l10n.update : l10n.save,
      cancelText: l10n.cancel,
      onConfirm: () async {
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
    final selectedLivestockUuid =
        widget.livestockUuid ?? _selectedLivestockUuid;

    if (selectedFarmUuid == null ||
        selectedFarmUuid.isEmpty ||
        selectedLivestockUuid == null ||
        selectedLivestockUuid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.logContextMissing)));
      return;
    }

    final nowIso = DateTime.now().toIso8601String();
    final testResultId = _selectedTestResultId!;
    final testDateIso = _selectedTestDate?.toIso8601String();

    try {
      if (widget.isEditMode) {
        final existing = widget.pregnancy!;
        final eventDateIso = _selectedEventDate?.toIso8601String();
        final updatedModel = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid,
          testResultId: testResultId,
          eventDate: eventDateIso ?? existing.eventDate,
          noOfMonths: _noOfMonthsController.text.trim().isEmpty
              ? null
              : _noOfMonthsController.text.trim(),
          testDate: testDateIso ?? existing.testDate,
          status: _selectedStatus,
          remarks: _remarksController.text.trim().isEmpty
              ? null
              : _remarksController.text.trim(),
          updatedAt: nowIso,
        );

        AlertDialogs.showLoading(
          context: context,
          title: l10n.save,
          message: '',
          isDismissible: false,
        );
        
        final updated = await eventsProvider.updatePregnancy(updatedModel);
        
        if (mounted) {
          Navigator.of(context).pop();
          
          await BillCreationHelper.maybeCreateBillForLog(
            context: context,
            logType: EventLogTypes.pregnancy,
            farmUuid: selectedFarmUuid,
            subjectUuid: updated.uuid,
            quantity: 1,
            numberOfLivestock: 1,
          );
          
          if (mounted) {
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: '${l10n.success}!',
              buttonText: l10n.ok,
            );
            if (mounted) {
              Navigator.pop(context, updated);
            }
          }
        }
      } else {
        final uuid =
            '${DateTime.now().millisecondsSinceEpoch}-${selectedLivestockUuid.hashCode}-$testResultId';

        final eventDateIso = _selectedEventDate?.toIso8601String();
        final newModel = PregnancyModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid,
          testResultId: testResultId,
          eventDate: eventDateIso,
          noOfMonths: _noOfMonthsController.text.trim().isEmpty
              ? null
              : _noOfMonthsController.text.trim(),
          testDate: testDateIso,
          status: _selectedStatus,
          remarks: _remarksController.text.trim().isEmpty
              ? null
              : _remarksController.text.trim(),
          synced: false,
          syncAction: 'create',
          createdAt: nowIso,
          updatedAt: nowIso,
        );

        AlertDialogs.showLoading(
          context: context,
          title: l10n.save,
          message: '',
          isDismissible: false,
        );
        
        final created = await eventsProvider.addPregnancy(newModel);
        
        if (mounted) {
          Navigator.of(context).pop();
          
          await BillCreationHelper.maybeCreateBillForLog(
            context: context,
            logType: EventLogTypes.pregnancy,
            farmUuid: selectedFarmUuid,
            subjectUuid: created.uuid,
            quantity: 1,
            numberOfLivestock: 1,
          );
          
          if (mounted) {
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: '${l10n.success}!',
              buttonText: l10n.ok,
            );
            if (mounted) {
              Navigator.pop(context, created);
            }
          }
        }
      }
    } catch (e) {
      log('❌ Error saving pregnancy log: $e');
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.pregnancyLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }
}
