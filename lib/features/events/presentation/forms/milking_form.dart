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
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/milking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MilkingFormScreen extends StatefulWidget {
  final MilkingModel? milking;
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;

  const MilkingFormScreen({
    super.key,
    this.milking,
    this.farmUuid,
    this.livestockUuid,
    this.isBulk = false,
    this.bulkLivestockUuids,
  });

  bool get isEditMode => milking != null;

  @override
  State<MilkingFormScreen> createState() => _MilkingFormScreenState();
}

class _MilkingFormScreenState extends State<MilkingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _lactometerReadingController = TextEditingController();
  final _solidController = TextEditingController();
  final _solidNonFatController = TextEditingController();
  final _proteinController = TextEditingController();
  final _correctedLactometerReadingController = TextEditingController();
  final _totalSolidsController = TextEditingController();
  final _colonyFormingUnitsController = TextEditingController();
  final _acidityController = TextEditingController();

  int _currentStep = 0;
  bool _isLoadingData = true;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;
  List<Livestock> _selectedBulkLivestock = [];
  bool _isLoadingLivestock = false;

  int? _selectedMilkingMethodId;
  String _selectedSession = 'morning';
  String _selectedStatus = 'active';
  String _selectedAmountUnit = 'l';

  List<DropdownItem<int>> _milkingMethodItems = const [];
  final List<String> _amountUnits = const ['l', 'ml'];

  bool get _isBulk => widget.isBulk;

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
    final milking = widget.milking;
    _selectedFarmUuid = widget.farmUuid;
    _selectedLivestockUuid = _isBulk ? null : widget.livestockUuid;

    if (milking == null) return;

    _selectedMilkingMethodId = milking.milkingMethodId;
    _parseAmountWithUnit(milking.amount);
    _lactometerReadingController.text = milking.lactometerReading;
    _solidController.text = milking.solid;
    _solidNonFatController.text = milking.solidNonFat;
    _proteinController.text = milking.protein;
    _correctedLactometerReadingController.text =
        milking.correctedLactometerReading;
    _totalSolidsController.text = milking.totalSolids;
    _colonyFormingUnitsController.text = milking.colonyFormingUnits;
    _acidityController.text = milking.acidity ?? '';
    _selectedSession = milking.session;
    _selectedStatus = milking.status;
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
    final logAdditionalProvider = Provider.of<LogAdditionalDataProvider>(
      context,
      listen: false,
    );
    await logAdditionalProvider.ensureLoaded();
    final methods = logAdditionalProvider.milkingMethods;
    log('📥 Loaded ${methods.length} milking methods');
    if (!mounted) return;
    setState(() {
      _milkingMethodItems = methods
          .map(
            (method) => DropdownItem<int>(value: method.id, label: method.name),
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
    } catch (e) {
      log('❌ Failed to load context data: $e');
    }
  }

  void _onFarmSelected(String value) async {
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
    } catch (e) {
      log('❌ Failed to load livestock: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLivestock = false);
      }
    }
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
          genderFilter: 'female',
          lockGenderFilter: true,
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
    _amountController.dispose();
    _lactometerReadingController.dispose();
    _solidController.dispose();
    _solidNonFatController.dispose();
    _proteinController.dispose();
    _correctedLactometerReadingController.dispose();
    _totalSolidsController.dispose();
    _colonyFormingUnitsController.dispose();
    _acidityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.milking}'
        : l10n.addMilking;
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
                          steps: [
                            StepperStep(
                              title: l10n.basicInformation,
                              subtitle: l10n.milkingDetailsSubtitle,
                              icon: Icons.local_drink_outlined,
                              content: _buildStepOne(l10n, theme),
                            ),
                            StepperStep(
                              title: l10n.additionalDetails,
                              subtitle: l10n.milkingNotesSubtitle,
                              icon: Icons.science_outlined,
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
    final farmDropdownItems = _buildFarmDropdownItems();
    final livestockDropdownItems = _buildLivestockDropdownItems(l10n);
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
            dropdownItems: farmDropdownItems,
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
            _buildNoLivestockInfo(theme, l10n)
          else
            CustomDropdown<String>(
              label: l10n.selectLivestock,
              hint: l10n.selectLivestock,
              icon: Icons.pets,
              value: _selectedLivestockUuid,
              dropdownItems: livestockDropdownItems,
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
        _buildSectionTitle(l10n.milking),
        const SizedBox(height: 20),
        CustomDropdown<int>(
          label: l10n.milkingMethod,
          hint: l10n.milkingMethod,
          icon: Icons.precision_manufacturing_outlined,
          value: _selectedMilkingMethodId,
          dropdownItems: _milkingMethodItems,
          onChanged: (value) =>
              setState(() => _selectedMilkingMethodId = value),
          validator: (value) {
            if (value == null) {
              return l10n.milkingMethodRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _amountController,
                label: l10n.amount,
                hintText: l10n.enterAmount,
                prefixIcon: Icons.scale_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.amountRequired;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: CustomDropdown<String>(
                label: l10n.unit,
                hint: l10n.unit,
                icon: Icons.straighten_outlined,
                value: _selectedAmountUnit,
                dropdownItems: _buildAmountUnitItems(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedAmountUnit = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomDropdown<String>(
                label: l10n.session,
                hint: l10n.session,
                icon: Icons.timelapse_outlined,
                value: _selectedSession,
                dropdownItems: const [
                  DropdownItem(value: 'morning', label: 'Morning'),
                  DropdownItem(value: 'evening', label: 'Evening'),
                  DropdownItem(value: 'night', label: 'Night'),
                  DropdownItem(value: 'midnight', label: 'Midnight'),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedSession = value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown<String>(
                label: l10n.status,
                hint: l10n.status,
                icon: Icons.flag_outlined,
                value: _selectedStatus,
                dropdownItems: [
                  DropdownItem(value: 'pending', label: l10n.statusPending),
                  DropdownItem(value: 'active', label: l10n.statusActive),
                  DropdownItem(
                    value: 'not-active',
                    label: l10n.statusNotActive,
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedStatus = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.info_outline,
          message: l10n.ensureMilkingDetailsAccuracy,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStepTwo(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.additionalDetails),
        const SizedBox(height: 20),
        _buildMeasurementField(
          controller: _lactometerReadingController,
          label: l10n.lactometerReading,
          isPercentage: true,
        ),
        _buildMeasurementField(
          controller: _solidController,
          label: l10n.solids,
          isPercentage: true,
        ),
        _buildMeasurementField(
          controller: _solidNonFatController,
          label: l10n.solidNonFat,
          isPercentage: true,
        ),
        _buildMeasurementField(
          controller: _proteinController,
          label: l10n.protein,
          isPercentage: true,
        ),
        _buildMeasurementField(
          controller: _correctedLactometerReadingController,
          label: l10n.correctedLactometerReading,
          isPercentage: true,
        ),
        _buildMeasurementField(
          controller: _totalSolidsController,
          label: l10n.totalSolids,
          isPercentage: true,
        ),
        _buildMeasurementField(
          controller: _colonyFormingUnitsController,
          label: l10n.colonyFormingUnits,
        ),
        CustomTextField(
          controller: _acidityController,
          label: l10n.acidity,
          hintText: l10n.acidity,
          prefixIcon: Icons.science,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.lightbulb_outline,
          message: l10n.milkingNotesInfo,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildMeasurementField({
    required TextEditingController controller,
    required String label,
    bool isPercentage = false,
  }) {
    final effectiveLabel = isPercentage ? '$label (%)' : label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomTextField(
        controller: controller,
        label: effectiveLabel,
        hintText: effectiveLabel,
        prefixIcon: Icons.analytics_outlined,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  List<DropdownItem<String>> _buildAmountUnitItems() {
    return _amountUnits
        .map(
          (unit) => DropdownItem<String>(
            value: unit,
            label: unit.toUpperCase(),
          ),
        )
        .toList();
  }

  void _parseAmountWithUnit(String? value) {
    _selectedAmountUnit = _amountUnits.first;

    if (value == null || value.trim().isEmpty) {
      _amountController.clear();
      return;
    }

    final parts = value.split(',');
    final primary = parts.first.trim();
    final secondary =
        parts.length > 1 ? parts.last.trim().toLowerCase() : null;

    final match =
        RegExp(r'^([0-9]+(?:\.[0-9]+)?)\s*([a-zA-Z]+)?$').firstMatch(primary);

    String resolvedAmount = primary;
    String? primaryUnit;

    if (match != null) {
      resolvedAmount = match.group(1) ?? primary;
      primaryUnit = match.group(2)?.toLowerCase();
    }

    _amountController.text = resolvedAmount;

    final resolvedUnitCandidates = [
      if (secondary != null && secondary.isNotEmpty) secondary,
      if (primaryUnit != null && primaryUnit.isNotEmpty) primaryUnit,
    ];

    for (final candidate in resolvedUnitCandidates) {
      if (_amountUnits.contains(candidate)) {
        _selectedAmountUnit = candidate;
        return;
      }
    }

    _selectedAmountUnit = _amountUnits.first;
  }

  String _composeAmountWithUnit() {
    final amount = _amountController.text.trim();
    if (amount.isEmpty) return amount;
    return '$amount$_selectedAmountUnit';
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
          ? l10n.confirmUpdateMilking
          : l10n.confirmSaveMilking,
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
    final livestockUuids = _isBulk
        ? _selectedBulkLivestock.map((livestock) => livestock.uuid).toList()
        : [
            if (widget.livestockUuid != null && widget.livestockUuid!.isNotEmpty)
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

    final milkingMethodId = _selectedMilkingMethodId!;
    final nowIso = DateTime.now().toIso8601String();
    final amountWithUnit = _composeAmountWithUnit();
    final lactometerReading = _lactometerReadingController.text.trim();
    final solid = _solidController.text.trim();
    final solidNonFat = _solidNonFatController.text.trim();
    final protein = _proteinController.text.trim();
    final correctedLactometerReading =
        _correctedLactometerReadingController.text.trim();
    final totalSolids = _totalSolidsController.text.trim();
    final colonyFormingUnits = _colonyFormingUnitsController.text.trim();
    final acidityText = _acidityController.text.trim();
    final normalizedAcidity = acidityText.isEmpty ? null : acidityText;

    try {
      if (widget.isEditMode && !_isBulk) {
        final existing = widget.milking!;
        final updatedModel = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          milkingMethodId: milkingMethodId,
          amount: amountWithUnit,
          lactometerReading: lactometerReading,
          solid: solid,
          solidNonFat: solidNonFat,
          protein: protein,
          correctedLactometerReading: correctedLactometerReading,
          totalSolids: totalSolids,
          colonyFormingUnits: colonyFormingUnits,
          acidity: normalizedAcidity,
          session: _selectedSession,
          status: _selectedStatus,
          updatedAt: nowIso,
        );

        final updated = await eventsProvider.updateMilkingWithDialog(
          context,
          updatedModel,
        );
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        }
      } else if (_isBulk) {
        final created = await eventsProvider.addMilkingBatchWithDialog(
          context: context,
          farmUuid: selectedFarmUuid,
          livestockUuids: livestockUuids,
          milkingMethodId: milkingMethodId,
          amount: amountWithUnit,
          lactometerReading: lactometerReading,
          solid: solid,
          solidNonFat: solidNonFat,
          protein: protein,
          correctedLactometerReading: correctedLactometerReading,
          totalSolids: totalSolids,
          colonyFormingUnits: colonyFormingUnits,
          acidity: normalizedAcidity,
          session: _selectedSession,
          status: _selectedStatus,
        );

        if (created.isNotEmpty && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final uuid =
            '${DateTime.now().millisecondsSinceEpoch}-${livestockUuids.first.hashCode}-$milkingMethodId';

        final newModel = MilkingModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          milkingMethodId: milkingMethodId,
          amount: amountWithUnit,
          lactometerReading: lactometerReading,
          solid: solid,
          solidNonFat: solidNonFat,
          protein: protein,
          correctedLactometerReading: correctedLactometerReading,
          totalSolids: totalSolids,
          colonyFormingUnits: colonyFormingUnits,
          acidity: normalizedAcidity,
          session: _selectedSession,
          status: _selectedStatus,
          synced: false,
          syncAction: 'create',
          createdAt: nowIso,
          updatedAt: nowIso,
        );

        final created = await eventsProvider.addMilkingWithDialog(
          context,
          newModel,
        );
        if (created != null && mounted) {
          Navigator.pop(context, created);
        }
      }
    } catch (e) {
      log('❌ Error saving milking log: $e');
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.milkingLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }
}
