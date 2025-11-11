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
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/insemination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class InseminationFormScreen extends StatefulWidget {
  final InseminationModel? insemination;
  final String? farmUuid;
  final String? livestockUuid;

  const InseminationFormScreen({
    super.key,
    this.insemination,
    this.farmUuid,
    this.livestockUuid,
  });

  bool get isEditMode => insemination != null;

  @override
  State<InseminationFormScreen> createState() => _InseminationFormScreenState();
}

class _InseminationFormScreenState extends State<InseminationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey<FormState>();

  final _bullCodeController = TextEditingController();
  final _bullBreedController = TextEditingController();
  final _semenProductionDateController = TextEditingController();
  final _productionCountryController = TextEditingController();
  final _semenBatchNumberController = TextEditingController();
  final _internationalIdController = TextEditingController();
  final _aiCodeController = TextEditingController();
  final _manufacturerNameController = TextEditingController();
  final _semenSupplierController = TextEditingController();

  int _currentStep = 0;
  bool _isLoadingData = true;
  bool _isLoadingLivestock = false;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;

  DateTime? _lastHeatDate;
  DateTime? _inseminationDate;
  DateTime? _semenProductionDate;

  final _lastHeatDateController = TextEditingController();
  final _inseminationDateController = TextEditingController();

  int? _selectedHeatTypeId;
  int? _selectedInseminationServiceId;
  int? _selectedSemenStrawTypeId;

  List<DropdownItem<int>> _heatTypeItems = const [];
  List<DropdownItem<int>> _inseminationServiceItems = const [];
  List<DropdownItem<int>> _semenStrawTypeItems = const [];

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
    final insemination = widget.insemination;
    _selectedFarmUuid = widget.farmUuid;
    _selectedLivestockUuid = widget.livestockUuid;

    if (insemination == null) return;

    _selectedHeatTypeId = insemination.currentHeatTypeId;
    _selectedInseminationServiceId = insemination.inseminationServiceId;
    _selectedSemenStrawTypeId = insemination.semenStrawTypeId;

    _bullCodeController.text = insemination.bullCode ?? '';
    _bullBreedController.text = insemination.bullBreed ?? '';
    _productionCountryController.text = insemination.productionCountry ?? '';
    _semenBatchNumberController.text = insemination.semenBatchNumber ?? '';
    _internationalIdController.text = insemination.internationalId ?? '';
    _aiCodeController.text = insemination.aiCode ?? '';
    _manufacturerNameController.text = insemination.manufacturerName ?? '';
    _semenSupplierController.text = insemination.semenSupplier ?? '';

    _lastHeatDate = insemination.lastHeatDate != null
        ? DateTime.tryParse(insemination.lastHeatDate!)
        : null;
    _inseminationDate = insemination.inseminationDate != null
        ? DateTime.tryParse(insemination.inseminationDate!)
        : null;
    _semenProductionDate = insemination.semenProductionDate != null
        ? DateTime.tryParse(insemination.semenProductionDate!)
        : null;

    if (_lastHeatDate != null) {
      _lastHeatDateController.text = DateFormat.yMMMd().format(
        _lastHeatDate!.toLocal(),
      );
    }
    if (_inseminationDate != null) {
      _inseminationDateController.text = DateFormat.yMMMd().format(
        _inseminationDate!.toLocal(),
      );
    }
    if (_semenProductionDate != null) {
      _semenProductionDateController.text = DateFormat.yMMMd().format(
        _semenProductionDate!.toLocal(),
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

    if (!mounted) return;
    setState(() {
      _heatTypeItems = provider.heatTypes
          .map((type) => DropdownItem<int>(value: type.id, label: type.name))
          .toList();
      _inseminationServiceItems = provider.inseminationServices
          .map(
            (service) =>
                DropdownItem<int>(value: service.id, label: service.name),
          )
          .toList();
      _semenStrawTypeItems = provider.semenStrawTypes
          .map((type) => DropdownItem<int>(value: type.id, label: type.name))
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
    _bullCodeController.dispose();
    _bullBreedController.dispose();
    _semenProductionDateController.dispose();
    _productionCountryController.dispose();
    _semenBatchNumberController.dispose();
    _internationalIdController.dispose();
    _aiCodeController.dispose();
    _manufacturerNameController.dispose();
    _semenSupplierController.dispose();
    _lastHeatDateController.dispose();
    _inseminationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.insemination}'
        : l10n.addInsemination;
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
                          continueButtonText: null,
                          backButtonText: l10n.back,
                          finalStepButtonText: submitText,
                          steps: [
                            StepperStep(
                              title: l10n.basicInformation,
                              subtitle: l10n.inseminationDetailsSubtitle,
                              icon: Icons.biotech_outlined,
                              content: _buildStepOne(l10n, theme),
                            ),
                            StepperStep(
                              title: l10n.additionalDetails,
                              subtitle: l10n.inseminationNotesSubtitle,
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
        _buildSectionTitle(l10n.insemination),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _lastHeatDateController,
          label: l10n.lastHeatDate,
          hintText: l10n.lastHeatDate,
          prefixIcon: Icons.event_outlined,
          readOnly: true,
          onTap: () => _pickDate(DateField.lastHeat),
        ),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          label: l10n.heatType,
          hint: l10n.heatType,
          icon: Icons.whatshot_outlined,
          value: _selectedHeatTypeId,
          dropdownItems: _heatTypeItems,
          onChanged: (value) => setState(() => _selectedHeatTypeId = value),
          validator: (value) {
            if (value == null) {
              return l10n.heatTypeRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          label: l10n.inseminationService,
          hint: l10n.inseminationService,
          icon: Icons.medical_services_outlined,
          value: _selectedInseminationServiceId,
          dropdownItems: _inseminationServiceItems,
          onChanged: (value) =>
              setState(() => _selectedInseminationServiceId = value),
          validator: (value) {
            if (value == null) {
              return l10n.inseminationServiceRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          label: l10n.semenStrawType,
          hint: l10n.semenStrawType,
          icon: Icons.inventory_2_outlined,
          value: _selectedSemenStrawTypeId,
          dropdownItems: _semenStrawTypeItems,
          onChanged: (value) =>
              setState(() => _selectedSemenStrawTypeId = value),
          validator: (value) {
            if (value == null) {
              return l10n.semenStrawTypeRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _inseminationDateController,
          label: l10n.inseminationDate,
          hintText: l10n.inseminationDate,
          prefixIcon: Icons.event_available_outlined,
          readOnly: true,
          onTap: () => _pickDate(DateField.insemination),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.info_outline,
          message: l10n.ensureInseminationDetailsAccuracy,
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
        _buildOptionalTextField(
          controller: _bullCodeController,
          label: l10n.bullCode,
          icon: Icons.badge_outlined,
        ),
        _buildOptionalTextField(
          controller: _bullBreedController,
          label: l10n.bullBreed,
          icon: Icons.pets_outlined,
        ),
        CustomTextField(
          controller: _semenProductionDateController,
          label: l10n.semenProductionDate,
          hintText: l10n.semenProductionDate,
          prefixIcon: Icons.event_note_outlined,
          readOnly: true,
          onTap: () => _pickDate(DateField.semenProduction),
        ),
        const SizedBox(height: 16),
        _buildOptionalTextField(
          controller: _productionCountryController,
          label: l10n.productionCountry,
          icon: Icons.public_outlined,
        ),
        _buildOptionalTextField(
          controller: _semenBatchNumberController,
          label: l10n.semenBatchNumber,
          icon: Icons.numbers_outlined,
        ),
        _buildOptionalTextField(
          controller: _internationalIdController,
          label: l10n.internationalId,
          icon: Icons.assignment_ind_outlined,
        ),
        _buildOptionalTextField(
          controller: _aiCodeController,
          label: l10n.aiCode,
          icon: Icons.code_outlined,
        ),
        _buildOptionalTextField(
          controller: _manufacturerNameController,
          label: l10n.manufacturerName,
          icon: Icons.factory_outlined,
        ),
        _buildOptionalTextField(
          controller: _semenSupplierController,
          label: l10n.semenSupplier,
          icon: Icons.store_outlined,
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.lightbulb_outline,
          message: l10n.inseminationNotesInfo,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildOptionalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomTextField(
        controller: controller,
        label: label,
        hintText: label,
        prefixIcon: icon,
      ),
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

  Future<void> _pickDate(DateField field) async {
    final theme = Theme.of(context);
    DateTime initial = DateTime.now();
    switch (field) {
      case DateField.lastHeat:
        initial = _lastHeatDate ?? DateTime.now();
        break;
      case DateField.insemination:
        initial = _inseminationDate ?? DateTime.now();
        break;
      case DateField.semenProduction:
        initial = _semenProductionDate ?? DateTime.now();
        break;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
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
      final formatted = DateFormat.yMMMd().format(date.toLocal());
      switch (field) {
        case DateField.lastHeat:
          _lastHeatDate = date;
          _lastHeatDateController.text = formatted;
          break;
        case DateField.insemination:
          _inseminationDate = date;
          _inseminationDateController.text = formatted;
          break;
        case DateField.semenProduction:
          _semenProductionDate = date;
          _semenProductionDateController.text = formatted;
          break;
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
          ? l10n.confirmUpdateInsemination
          : l10n.confirmSaveInsemination,
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
    final lastHeatDateIso = _lastHeatDate?.toIso8601String();
    final inseminationDateIso = _inseminationDate?.toIso8601String();
    final semenProductionDateIso = _semenProductionDate?.toIso8601String();

    final heatTypeId = _selectedHeatTypeId!;
    final serviceId = _selectedInseminationServiceId!;
    final strawTypeId = _selectedSemenStrawTypeId!;

    try {
      if (widget.isEditMode) {
        final existing = widget.insemination!;
        final updatedModel = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid,
          lastHeatDate: lastHeatDateIso ?? existing.lastHeatDate,
          currentHeatTypeId: heatTypeId,
          inseminationServiceId: serviceId,
          semenStrawTypeId: strawTypeId,
          inseminationDate: inseminationDateIso ?? existing.inseminationDate,
          bullCode: _bullCodeController.text.trim().isEmpty
              ? null
              : _bullCodeController.text.trim(),
          bullBreed: _bullBreedController.text.trim().isEmpty
              ? null
              : _bullBreedController.text.trim(),
          semenProductionDate:
              semenProductionDateIso ?? existing.semenProductionDate,
          productionCountry: _productionCountryController.text.trim().isEmpty
              ? null
              : _productionCountryController.text.trim(),
          semenBatchNumber: _semenBatchNumberController.text.trim().isEmpty
              ? null
              : _semenBatchNumberController.text.trim(),
          internationalId: _internationalIdController.text.trim().isEmpty
              ? null
              : _internationalIdController.text.trim(),
          aiCode: _aiCodeController.text.trim().isEmpty
              ? null
              : _aiCodeController.text.trim(),
          manufacturerName: _manufacturerNameController.text.trim().isEmpty
              ? null
              : _manufacturerNameController.text.trim(),
          semenSupplier: _semenSupplierController.text.trim().isEmpty
              ? null
              : _semenSupplierController.text.trim(),
          updatedAt: nowIso,
        );

        final updated = await eventsProvider.updateInseminationWithDialog(
          context,
          updatedModel,
        );
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        }
      } else {
        final uuid =
            '${DateTime.now().millisecondsSinceEpoch}-${selectedLivestockUuid.hashCode}-insemination';

        final newModel = InseminationModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid,
          lastHeatDate: lastHeatDateIso,
          currentHeatTypeId: heatTypeId,
          inseminationServiceId: serviceId,
          semenStrawTypeId: strawTypeId,
          inseminationDate: inseminationDateIso,
          bullCode: _bullCodeController.text.trim().isEmpty
              ? null
              : _bullCodeController.text.trim(),
          bullBreed: _bullBreedController.text.trim().isEmpty
              ? null
              : _bullBreedController.text.trim(),
          semenProductionDate: semenProductionDateIso,
          productionCountry: _productionCountryController.text.trim().isEmpty
              ? null
              : _productionCountryController.text.trim(),
          semenBatchNumber: _semenBatchNumberController.text.trim().isEmpty
              ? null
              : _semenBatchNumberController.text.trim(),
          internationalId: _internationalIdController.text.trim().isEmpty
              ? null
              : _internationalIdController.text.trim(),
          aiCode: _aiCodeController.text.trim().isEmpty
              ? null
              : _aiCodeController.text.trim(),
          manufacturerName: _manufacturerNameController.text.trim().isEmpty
              ? null
              : _manufacturerNameController.text.trim(),
          semenSupplier: _semenSupplierController.text.trim().isEmpty
              ? null
              : _semenSupplierController.text.trim(),
          synced: false,
          syncAction: 'create',
          createdAt: nowIso,
          updatedAt: nowIso,
        );

        final created = await eventsProvider.addInseminationWithDialog(
          context,
          newModel,
        );
        if (created != null && mounted) {
          Navigator.pop(context, created);
        }
      }
    } catch (e) {
      log('❌ Error saving insemination log: $e');
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.inseminationLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }
}

enum DateField { lastHeat, insemination, semenProduction }
