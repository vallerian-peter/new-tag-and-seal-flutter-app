import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/app_date_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/searchable_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/insemination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/presentation/bill_creation_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';

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

  final _eventDateController = TextEditingController();
  final _bullCodeController = TextEditingController();
  final _bullBreedController = TextEditingController();
  final _semenProductionDateController = TextEditingController();
  final _productionCountryOtherController = TextEditingController();
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

  DateTime? _selectedEventDate;
  DateTime? _lastHeatDate;
  DateTime? _inseminationDate;
  DateTime? _semenProductionDate;

  final _lastHeatDateController = TextEditingController();
  final _inseminationDateController = TextEditingController();

  int? _selectedHeatTypeId;
  int? _selectedInseminationServiceId;
  int? _selectedSemenStrawTypeId;
  String? _selectedProductionCountry;

  List<DropdownItem<int>> _heatTypeItems = const [];
  List<DropdownItem<int>> _inseminationServiceItems = const [];
  List<DropdownItem<int>> _semenStrawTypeItems = const [];
  List<DropdownItem<String>> _productionCountryItems = const [];

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

    if (insemination.eventDate != null &&
        insemination.eventDate!.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(insemination.eventDate!);
      if (parsed != null) {
        _selectedEventDate = parsed;
        _eventDateController.text = DateFormat.yMMMd().add_jm().format(
          parsed.toLocal(),
        );
      }
    }
    _selectedHeatTypeId = insemination.currentHeatTypeId;
    _selectedInseminationServiceId = insemination.inseminationServiceId;
    _selectedSemenStrawTypeId = insemination.semenStrawTypeId;

    _bullCodeController.text = insemination.bullCode ?? '';
    _bullBreedController.text = insemination.bullBreed ?? '';
    final productionCountry = insemination.productionCountry ?? '';
    // Check if the saved country is in our list
    final countryList = _getProductionCountries()
        .map((item) => item.value)
        .toList();
    if (countryList.contains(productionCountry)) {
      _selectedProductionCountry = productionCountry;
    } else if (productionCountry.isNotEmpty) {
      // It's a custom "Other" value
      _selectedProductionCountry = 'Other';
      _productionCountryOtherController.text = productionCountry;
    }
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
      _buildProductionCountryItems();
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _buildProductionCountryItems() {
    final countries = _getProductionCountries();
    setState(() {
      _productionCountryItems = countries;
    });
  }

  List<DropdownItem<String>> _getProductionCountries() {
    const countryList = [
      'Tanzania',
      'Kenya',
      'Uganda',
      'Rwanda',
      'Burundi',
      'Ethiopia',
      'South Sudan',
      'Somalia',
      'Djibouti',
      'Eritrea',
      'Sudan',
      'Egypt',
      'Libya',
      'Tunisia',
      'Algeria',
      'Morocco',
      'South Africa',
      'Zimbabwe',
      'Zambia',
      'Malawi',
      'Mozambique',
      'Botswana',
      'Namibia',
      'Angola',
      'Ghana',
      'Nigeria',
      'Senegal',
      'Ivory Coast',
      'Cameroon',
      'Democratic Republic of the Congo',
      'United States',
      'Canada',
      'Brazil',
      'Argentina',
      'United Kingdom',
      'France',
      'Germany',
      'Italy',
      'Spain',
      'Netherlands',
      'Belgium',
      'Denmark',
      'Sweden',
      'Norway',
      'Australia',
      'New Zealand',
      'India',
      'China',
      'Japan',
      'Other',
    ];

    return countryList
        .map((country) => DropdownItem<String>(value: country, label: country))
        .toList();
  }

  Future<void> _loadReferenceData() async {
    try {
      final provider = Provider.of<LogAdditionalDataProvider>(
        context,
        listen: false,
      );

      // Ensure data is loaded from local database
      await provider.ensureLoaded();

      final heatTypesCount = provider.heatTypes.length;
      final inseminationServicesCount = provider.inseminationServices.length;
      final semenStrawTypesCount = provider.semenStrawTypes.length;

      log(
        '📊 Insemination form: Reference data loaded - HeatTypes: $heatTypesCount, InseminationServices: $inseminationServicesCount, SemenStrawTypes: $semenStrawTypesCount',
      );

      if (heatTypesCount == 0 ||
          inseminationServicesCount == 0 ||
          semenStrawTypesCount == 0) {
        log(
          '⚠️ Insemination form: Some reference data is missing. Please sync to get the latest data from the server.',
        );
      }

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

      log(
        '✅ Insemination form: Reference data items created - HeatTypes: ${_heatTypeItems.length}, InseminationServices: ${_inseminationServiceItems.length}, SemenStrawTypes: ${_semenStrawTypeItems.length}',
      );
    } catch (e, stackTrace) {
      log(
        '❌ Insemination form: Error loading reference data: $e',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      // Set empty lists on error to prevent crashes
      setState(() {
        _heatTypeItems = const [];
        _inseminationServiceItems = const [];
        _semenStrawTypeItems = const [];
      });
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
    _eventDateController.dispose();
    _bullCodeController.dispose();
    _bullBreedController.dispose();
    _semenProductionDateController.dispose();
    _productionCountryOtherController.dispose();
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
    final isDark = theme.brightness == Brightness.dark;

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.insemination}'
        : l10n.addInsemination;
    final submitText = widget.isEditMode ? l10n.update : l10n.save;

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
          controller: _eventDateController,
          label: l10n.eventDate,
          hintText: l10n.selectEventDate,
          prefixIcon: Icons.event_available_outlined,
          readOnly: true,
          onTap: _pickEventDate,
        ),
        const SizedBox(height: 16),
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
        SearchableDropdown<String>(
          label: l10n.productionCountry,
          hint: l10n.productionCountry,
          icon: Icons.public_outlined,
          value: _selectedProductionCountry,
          dropdownItems: _productionCountryItems,
          isRequired: false,
          onChanged: (value) {
            setState(() {
              _selectedProductionCountry = value;
              // Clear other text field if not "Other"
              if (value != 'Other') {
                _productionCountryOtherController.clear();
              }
            });
          },
        ),
        if (_selectedProductionCountry == 'Other') ...[
          const SizedBox(height: 16),
          CustomTextField(
            controller: _productionCountryOtherController,
            label: l10n.productionCountry,
            hintText: l10n.productionCountry,
            prefixIcon: Icons.public_outlined,
          ),
        ],
        const SizedBox(height: 16),
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

    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : whiteColor;
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
        final eventDateIso = _selectedEventDate?.toIso8601String();
        final updatedModel = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid,
          eventDate: eventDateIso ?? existing.eventDate,
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
          productionCountry: _selectedProductionCountry == 'Other'
              ? (_productionCountryOtherController.text.trim().isEmpty
                    ? null
                    : _productionCountryOtherController.text.trim())
              : _selectedProductionCountry,
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

        AlertDialogs.showLoading(
          context: context,
          title: l10n.save,
          message: '',
          isDismissible: false,
        );

        final updated = await eventsProvider.updateInsemination(updatedModel);

        if (mounted) {
          Navigator.of(context).pop();

          await BillCreationHelper.maybeCreateBillForLog(
            context: context,
            logType: EventLogTypes.insemination,
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
            '${DateTime.now().millisecondsSinceEpoch}-${selectedLivestockUuid.hashCode}-insemination';

        final eventDateIso = _selectedEventDate?.toIso8601String();
        final newModel = InseminationModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid,
          eventDate: eventDateIso,
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
          productionCountry: _selectedProductionCountry == 'Other'
              ? (_productionCountryOtherController.text.trim().isEmpty
                    ? null
                    : _productionCountryOtherController.text.trim())
              : _selectedProductionCountry,
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

        AlertDialogs.showLoading(
          context: context,
          title: l10n.save,
          message: '',
          isDismissible: false,
        );

        final created = await eventsProvider.addInsemination(newModel);

        if (mounted) {
          Navigator.of(context).pop();

          await BillCreationHelper.maybeCreateBillForLog(
            context: context,
            logType: EventLogTypes.insemination,
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
