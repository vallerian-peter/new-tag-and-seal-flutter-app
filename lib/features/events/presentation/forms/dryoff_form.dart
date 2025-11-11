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
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/dryoff_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class DryoffFormScreen extends StatefulWidget {
  final DryoffModel? dryoff;
  final String? farmUuid;
  final String? livestockUuid;

  const DryoffFormScreen({
    super.key,
    this.dryoff,
    this.farmUuid,
    this.livestockUuid,
  });

  bool get isEditMode => dryoff != null;

  @override
  State<DryoffFormScreen> createState() => _DryoffFormScreenState();
}

class _DryoffFormScreenState extends State<DryoffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey<FormState>();

  final _reasonController = TextEditingController();
  final _remarksController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  int _currentStep = 0;
  bool _isLoadingData = true;
  bool _isLoadingLivestock = false;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;

  DateTime? _startDate;
  DateTime? _endDate;

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
    final dryoff = widget.dryoff;
    _selectedFarmUuid = widget.farmUuid;
    _selectedLivestockUuid = widget.livestockUuid;

    if (dryoff == null) return;

    _reasonController.text = dryoff.reason ?? '';
    _remarksController.text = dryoff.remarks ?? '';

    _startDate = DateTime.tryParse(dryoff.startDate);
    _endDate = dryoff.endDate != null
        ? DateTime.tryParse(dryoff.endDate!)
        : null;

    if (_startDate != null) {
      _startDateController.text = DateFormat.yMMMd().format(
        _startDate!.toLocal(),
      );
    }
    if (_endDate != null) {
      _endDateController.text = DateFormat.yMMMd().format(_endDate!.toLocal());
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoadingData = true);
    try {
      await _loadContextData();
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
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
    _reasonController.dispose();
    _remarksController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.dryoff}'
        : l10n.addDryoff;
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
                              subtitle: l10n.dryoffDetailsSubtitle,
                              icon: Icons.hourglass_bottom,
                              content: _buildStepOne(l10n, theme),
                            ),
                            StepperStep(
                              title: l10n.additionalDetails,
                              subtitle: l10n.dryoffNotesSubtitle,
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
        _buildSectionTitle(l10n.dryoff),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _startDateController,
          label: l10n.startDate,
          hintText: l10n.startDate,
          prefixIcon: Icons.event_outlined,
          readOnly: true,
          onTap: () => _pickDate(isStartDate: true),
          validator: (value) {
            if (_startDate == null) {
              return l10n.startDateRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _endDateController,
          label: l10n.endDate,
          hintText: l10n.endDate,
          prefixIcon: Icons.event_available_outlined,
          readOnly: true,
          onTap: () => _pickDate(isStartDate: false),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _reasonController,
          label: l10n.reason,
          hintText: l10n.reason,
          prefixIcon: Icons.info_outline,
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.info_outline,
          message: l10n.ensureDryoffDetailsAccuracy,
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
          message: l10n.dryoffNotesInfo,
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
        color: Constants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Constants.primaryColor.withOpacity(0.3)),
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
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1),
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

  Future<void> _pickDate({required bool isStartDate}) async {
    final theme = Theme.of(context);
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: Constants.primaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: Constants.primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
            dialogBackgroundColor: theme.brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
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

    setState(() {
      if (isStartDate) {
        _startDate = date;
        _startDateController.text = DateFormat.yMMMd().format(date.toLocal());
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = date;
          _endDateController.text = DateFormat.yMMMd().format(date.toLocal());
        }
      } else {
        _endDate = date;
        _endDateController.text = DateFormat.yMMMd().format(date.toLocal());
      }
    });
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
          ? l10n.confirmUpdateDryoff
          : l10n.confirmSaveDryoff,
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
    final startDateIso = _startDate?.toIso8601String() ?? nowIso;
    final endDateIso = _endDate?.toIso8601String();

    try {
      if (widget.isEditMode) {
        final existing = widget.dryoff!;
        final updatedModel = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid,
          startDate: startDateIso,
          endDate: endDateIso,
          reason: _reasonController.text.trim().isEmpty
              ? null
              : _reasonController.text.trim(),
          remarks: _remarksController.text.trim().isEmpty
              ? null
              : _remarksController.text.trim(),
          updatedAt: nowIso,
        );

        final updated = await eventsProvider.updateDryoffWithDialog(
          context,
          updatedModel,
        );
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        }
      } else {
        final uuid =
            '${DateTime.now().millisecondsSinceEpoch}-${selectedLivestockUuid.hashCode}-dryoff';

        final newModel = DryoffModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid,
          startDate: startDateIso,
          endDate: endDateIso,
          reason: _reasonController.text.trim().isEmpty
              ? null
              : _reasonController.text.trim(),
          remarks: _remarksController.text.trim().isEmpty
              ? null
              : _remarksController.text.trim(),
          synced: false,
          syncAction: 'create',
          createdAt: nowIso,
          updatedAt: nowIso,
        );

        final created = await eventsProvider.addDryoffWithDialog(
          context,
          newModel,
        );
        if (created != null && mounted) {
          Navigator.pop(context, created);
        }
      }
    } catch (e) {
      log('❌ Error saving dryoff log: $e');
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.dryoffLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }
}
