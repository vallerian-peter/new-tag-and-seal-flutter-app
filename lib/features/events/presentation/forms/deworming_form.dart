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
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/deworming_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class DewormingFormScreen extends StatefulWidget {
  final DewormingModel? deworming;
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;

  const DewormingFormScreen({
    super.key,
    this.deworming,
    this.farmUuid,
    this.livestockUuid,
    this.isBulk = false,
    this.bulkLivestockUuids,
  });

  bool get isEditMode => deworming != null;

  @override
  State<DewormingFormScreen> createState() => _DewormingFormScreenState();
}

class _DewormingFormScreenState extends State<DewormingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey<FormState>();

  final _quantityController = TextEditingController();
  final _doseController = TextEditingController();
  final _nextAdministrationController = TextEditingController();
  final _medicalLicenseController = TextEditingController();

  int _currentStep = 0;
  bool _isLoadingData = true;
  bool _isLoadingLivestock = false;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  List<Livestock> _selectedBulkLivestock = const [];
  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;

  List<DropdownItem<int>> _administrationRouteItems = const [];
  List<DropdownItem<int>> _medicineItems = const [];
  int? _selectedAdministrationRouteId;
  int? _selectedMedicineId;

  DateTime? _selectedNextAdministrationDate;
  _TreatmentProviderType _selectedProviderType = _TreatmentProviderType.none;
  bool get _isBulk => widget.isBulk;

  @override
  void initState() {
    super.initState();
    _prefillIfEditing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  void _prefillIfEditing() {
    final deworming = widget.deworming;
    _selectedFarmUuid = widget.farmUuid;
    _selectedLivestockUuid = _isBulk ? null : widget.livestockUuid;

    if (deworming == null) return;

    _selectedAdministrationRouteId = deworming.administrationRouteId;
    _selectedMedicineId = deworming.medicineId;
    _quantityController.text = deworming.quantity ?? '';
    _doseController.text = deworming.dose ?? '';

    if (deworming.vetId != null && deworming.vetId!.trim().isNotEmpty) {
      _selectedProviderType = _TreatmentProviderType.vet;
      _medicalLicenseController.text = deworming.vetId!;
    } else if (deworming.extensionOfficerId != null &&
        deworming.extensionOfficerId!.trim().isNotEmpty) {
      _selectedProviderType = _TreatmentProviderType.extensionOfficer;
      _medicalLicenseController.text = deworming.extensionOfficerId!;
    }

    if (deworming.nextAdministrationDate != null &&
        deworming.nextAdministrationDate!.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(deworming.nextAdministrationDate!);
      if (parsed != null) {
        _selectedNextAdministrationDate = parsed;
        _nextAdministrationController.text = _formatDisplayDate(parsed);
      }
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoadingData = true);
    try {
      await _loadLogReferences();
      await _loadContextData();
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _loadLogReferences() async {
    try {
      final logProvider =
          Provider.of<LogAdditionalDataProvider>(context, listen: false);
      await logProvider.loadFromLocal();

      if (!mounted) return;
      setState(() {
        _administrationRouteItems = logProvider.administrationRoutes
            .map(
              (route) => DropdownItem<int>(
                value: route.id,
                label: route.name,
              ),
            )
            .toList();
        _medicineItems = logProvider.medicines
            .map(
              (medicine) => DropdownItem<int>(
                value: medicine.id,
                label: medicine.name,
              ),
            )
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.eventsLoadFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
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
        livestock =
            await database.livestockDao.getActiveLivestockByFarmUuid(farmUuid);
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
        if (_isBulk) {
          final initialSelectionUuids = widget.bulkLivestockUuids ??
              _selectedBulkLivestock.map((item) => item.uuid).toList();
          _selectedBulkLivestock = livestock
              .where((item) => initialSelectionUuids.contains(item.uuid))
              .toList();
          _selectedLivestockUuid = null;
        } else {
          _selectedLivestockUuid = livestockUuid;
          _selectedBulkLivestock = const [];
        }
      });
    } catch (e) {
      debugPrint('❌ Failed to load context data: $e');
    }
  }

  Future<void> _onFarmSelected(String value) async {
    setState(() {
      _selectedFarmUuid = value;
      if (widget.livestockUuid == null) {
        _selectedLivestockUuid = null;
      }
      _isLoadingLivestock = true;
    });

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      final livestock =
          await database.livestockDao.getActiveLivestockByFarmUuid(value);

      if (!mounted) return;
      setState(() {
        _farmLivestock = livestock;
        if (_isBulk) {
          final validUuids = livestock.map((item) => item.uuid).toSet();
          _selectedBulkLivestock = _selectedBulkLivestock
              .where((item) => validUuids.contains(item.uuid))
              .toList();
        } else {
          if (_selectedLivestockUuid == null && livestock.isNotEmpty) {
            _selectedLivestockUuid = livestock.first.uuid;
          } else if (_selectedLivestockUuid != null &&
              livestock.every((item) => item.uuid != _selectedLivestockUuid)) {
            _selectedLivestockUuid =
                livestock.isNotEmpty ? livestock.first.uuid : null;
          }
        }
      });
    } catch (e) {
      debugPrint('❌ Failed to load livestock for farm: $e');
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

  Future<void> _openBulkLivestockSelector(AppLocalizations l10n) async {
    final farmUuid = _selectedFarmUuid;
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

    if (selection != null) {
      setState(() {
        _selectedBulkLivestock = selection;
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _doseController.dispose();
    _nextAdministrationController.dispose();
    _medicalLicenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.deworming}'
        : l10n.addDeworming;
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Form(
                  key: _formKey,
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
                        subtitle: l10n.recordsAndLogs,
                        icon: Icons.info_outline,
                        content: _buildStepOne(l10n, theme),
                      ),
                      StepperStep(
                        title: l10n.dewormingDetails,
                        subtitle: l10n.dosageDetails,
                        icon: Icons.medical_services_outlined,
                        content: _buildStepTwo(l10n, theme),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStepOne(AppLocalizations l10n, ThemeData theme) {
    final farmItems = _farms
        .map(
          (farm) => DropdownItem<String>(
            value: farm.uuid,
            label: farm.name,
          ),
        )
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
        _buildSectionTitle(l10n.recordsAndLogs),
        const SizedBox(height: 20),
        if (_farms.isEmpty)
          _buildInfoBanner(
            message: l10n.logContextMissing,
            theme: theme,
            color: Colors.amber,
          )
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
            _buildInfoBanner(
              message: l10n.noLivestockFound,
              theme: theme,
              color: theme.colorScheme.primary,
            )
          else if (_isBulk)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BulkLivestockSummaryTile(
                  count: _selectedBulkLivestock.length,
                  onTap: () => _openBulkLivestockSelector(l10n),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openBulkLivestockSelector(l10n),
                  icon: const Icon(Icons.playlist_add_check),
                  label: Text(
                    _selectedBulkLivestock.isEmpty
                        ? l10n.selectLivestock
                        : l10n.edit,
                  ),
                ),
              ],
            )
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
        ],
        const SizedBox(height: 24),
        _buildSectionTitle(l10n.dewormingDetails),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          label: l10n.administrationRoute,
          hint: l10n.selectAdministrationRoute,
          icon: Icons.route,
          value: _selectedAdministrationRouteId,
          dropdownItems: _administrationRouteItems,
          onChanged: (value) => setState(() {
            _selectedAdministrationRouteId = value;
          }),
          validator: (value) {
            if (value == null) {
              return l10n.administrationRouteRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          label: l10n.medicine,
          hint: l10n.selectMedicine,
          icon: Icons.medical_services,
          value: _selectedMedicineId,
          dropdownItems: _medicineItems,
          onChanged: (value) => setState(() {
            _selectedMedicineId = value;
          }),
          validator: (value) {
            if (value == null) {
              return l10n.medicineRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<_TreatmentProviderType>(
          label: l10n.treatmentProvider,
          hint: l10n.selectTreatmentProvider,
          icon: Icons.person_search_outlined,
          value: _selectedProviderType,
          dropdownItems: [
            DropdownItem(
              value: _TreatmentProviderType.none,
              label: l10n.treatmentProviderNone,
            ),
            DropdownItem(
              value: _TreatmentProviderType.vet,
              label: l10n.treatmentProviderVet,
            ),
            DropdownItem(
              value: _TreatmentProviderType.extensionOfficer,
              label: l10n.treatmentProviderExtensionOfficer,
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedProviderType = value ?? _TreatmentProviderType.none;
              if (_selectedProviderType == _TreatmentProviderType.none) {
                _medicalLicenseController.clear();
              }
            });
          },
          isRequired: false,
        ),
        if (_selectedProviderType != _TreatmentProviderType.none) ...[
          const SizedBox(height: 16),
          CustomTextField(
            controller: _medicalLicenseController,
            label: l10n.medicalLicenseNumber,
            hintText: l10n.enterMedicalLicenseNumber,
            prefixIcon: Icons.badge_outlined,
            validator: (value) {
              if (_selectedProviderType == _TreatmentProviderType.none) {
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
    );
  }

  Widget _buildStepTwo(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.dosageDetails),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _quantityController,
          label: l10n.quantity,
          hintText: l10n.enterQuantity,
          prefixIcon: Icons.format_list_numbered,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.quantityRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _doseController,
          label: l10n.dose,
          hintText: l10n.enterDose,
          prefixIcon: Icons.science_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.doseRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _nextAdministrationController,
          label: l10n.nextAdministrationDate,
          hintText: l10n.nextAdministrationDate,
          prefixIcon: Icons.calendar_today,
          readOnly: true,
          onTap: _pickNextAdministrationDate,
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.info_outline,
          message: l10n.ensureDewormingDetailsAccuracy,
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

  Widget _buildInfoBanner({
    required String message,
    required ThemeData theme,
    Color color = Colors.amber,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 14,
        ),
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
        border: Border.all(
          color: Constants.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Constants.primaryColor,
            size: 24,
          ),
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
          ? l10n.confirmUpdateDeworming
          : l10n.confirmSaveDeworming,
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

  Future<void> _pickNextAdministrationDate() async {
    final theme = Theme.of(context);
    final initialDate = _selectedNextAdministrationDate ?? DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year, initialDate.month, initialDate.day),
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

    if (selected == null) return;

    setState(() {
      _selectedNextAdministrationDate = selected;
      _nextAdministrationController.text = _formatDisplayDate(selected);
    });
  }

  String _formatDisplayDate(DateTime date) {
    return DateFormat.yMMMd().format(date.toLocal());
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    final selectedFarmUuid = widget.farmUuid ?? _selectedFarmUuid;
    final selectedLivestockUuid = widget.livestockUuid ?? _selectedLivestockUuid;

    if (selectedFarmUuid == null || selectedFarmUuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logContextMissing)),
      );
      return;
    }

    if (!_isBulk &&
        (selectedLivestockUuid == null || selectedLivestockUuid.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logContextMissing)),
      );
      return;
    }

    final bulkLivestockUuids =
        _selectedBulkLivestock.map((item) => item.uuid).toList();
    if (_isBulk && bulkLivestockUuids.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
      return;
    }

    try {
      String? vetId;
      String? extensionOfficerId;
      final licenseText = _medicalLicenseController.text.trim();
      if (_selectedProviderType == _TreatmentProviderType.vet) {
        vetId = licenseText.isEmpty ? null : licenseText;
      } else if (_selectedProviderType == _TreatmentProviderType.extensionOfficer) {
        extensionOfficerId = licenseText.isEmpty ? null : licenseText;
      }

      final nextAdministrationIso =
          _selectedNextAdministrationDate?.toIso8601String();

      if (widget.isEditMode && _isBulk) {
        debugPrint('⚠️ Bulk editing is not supported for deworming logs.');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
        return;
      }

      if (widget.isEditMode) {
        final existing = widget.deworming!;
        final updated = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid!,
          administrationRouteId: _selectedAdministrationRouteId,
          medicineId: _selectedMedicineId,
          vetId: vetId,
          extensionOfficerId: extensionOfficerId,
          quantity: _quantityController.text.trim(),
          dose: _doseController.text.trim(),
          nextAdministrationDate: nextAdministrationIso ?? existing.nextAdministrationDate,
          updatedAt: DateTime.now().toIso8601String(),
        );

        final saved = await eventsProvider.updateDewormingWithDialog(
          context,
          updated,
        );
        if (saved != null && mounted) {
          Navigator.pop(context, saved);
        }
      } else if (_isBulk) {
        await eventsProvider.addDewormingBatchWithDialog(
          context: context,
          farmUuid: selectedFarmUuid,
          livestockUuids: bulkLivestockUuids,
          administrationRouteId: _selectedAdministrationRouteId,
          medicineId: _selectedMedicineId,
          quantity: _quantityController.text.trim(),
          dose: _doseController.text.trim(),
          nextAdministrationDate: nextAdministrationIso,
          vetId: vetId,
          extensionOfficerId: extensionOfficerId,
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final now = DateTime.now().toIso8601String();
        final uuid =
            '${DateTime.now().millisecondsSinceEpoch}-${selectedLivestockUuid.hashCode}-deworming';

        final model = DewormingModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid!,
          administrationRouteId: _selectedAdministrationRouteId,
          medicineId: _selectedMedicineId,
          vetId: vetId,
          extensionOfficerId: extensionOfficerId,
          quantity: _quantityController.text.trim(),
          dose: _doseController.text.trim(),
          nextAdministrationDate: nextAdministrationIso,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );

        final saved = await eventsProvider.addDewormingWithDialog(
          context,
          model,
        );
        if (saved != null && mounted) {
          Navigator.pop(context, saved);
        }
      }
    } catch (e) {
      debugPrint('❌ Error saving deworming log: $e');
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.dewormingLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }
}

enum _TreatmentProviderType {
  none,
  vet,
  extensionOfficer,
}

