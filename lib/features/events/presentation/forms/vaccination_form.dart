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
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/vaccination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/domain/models/vaccine_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class VaccinationFormScreen extends StatefulWidget {
  final VaccinationModel? vaccination;
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;

  const VaccinationFormScreen({
    super.key,
    this.vaccination,
    this.farmUuid,
    this.livestockUuid,
    this.isBulk = false,
    this.bulkLivestockUuids,
  });

  bool get isEditMode => vaccination != null;

  @override
  State<VaccinationFormScreen> createState() => _VaccinationFormScreenState();
}

class _VaccinationFormScreenState extends State<VaccinationFormScreen> {
  static const String _vaccinationNumberPrefix = 'VAC-';
  final _formKey = GlobalKey<FormState>();
  final _vaccinationNoController = TextEditingController();
  final _vetIdController = TextEditingController();
  final _extensionOfficerController = TextEditingController();

  int _currentStep = 0;
  bool _isLoadingContext = true;
  bool _isLoadingLivestock = false;
  bool _isLoadingVaccines = true;
  bool _isLoadingDiseases = true;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  List<VaccineModel> _allVaccines = const [];
  List<DropdownItem<int>> _vaccineItems = const [];
  List<DropdownItem<int>> _diseaseItems = const [];

  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;
  List<Livestock> _selectedBulkLivestock = [];
  int? _selectedVaccineId;
  int? _selectedDiseaseId;
  String _selectedStatus = 'completed';

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
    final vaccination = widget.vaccination;
    _selectedFarmUuid = widget.farmUuid ?? vaccination?.farmUuid;
    _selectedLivestockUuid =
        _isBulk ? null : widget.livestockUuid ?? vaccination?.livestockUuid;

    if (vaccination == null) return;

    if (vaccination.vaccinationNo != null &&
        vaccination.vaccinationNo!.trim().isNotEmpty) {
      final number = vaccination.vaccinationNo!.trim();
      _vaccinationNoController.text =
          number.startsWith(_vaccinationNumberPrefix)
          ? number.substring(_vaccinationNumberPrefix.length)
          : number;
    } else {
      _vaccinationNoController.clear();
    }
    _selectedDiseaseId = vaccination.diseaseId;
    _vetIdController.text = vaccination.vetId ?? '';
    _extensionOfficerController.text = vaccination.extensionOfficerId ?? '';
    if (vaccination.vaccineId != null) {
      _selectedVaccineId = vaccination.vaccineId;
    }
    if (vaccination.status.isNotEmpty) {
      _selectedStatus = vaccination.status;
    }
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoadingContext = true;
      _isLoadingVaccines = true;
      _isLoadingDiseases = true;
    });

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);

      await Future.wait([
        _loadContextData(database),
        _loadVaccines(database),
        _loadDiseases(),
      ]);
    } catch (e, stackTrace) {
      log(
        '❌ Failed to initialize vaccination form: $e',
        stackTrace: stackTrace,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingContext = false;
          _isLoadingVaccines = false;
          _isLoadingDiseases = false;
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

  Future<void> _loadVaccines(AppDatabase database) async {
    final vaccines = await database.vaccineDao.getVaccines();
    log('💉 Loaded ${vaccines.length} vaccines for vaccination form');

    if (!mounted) return;
    setState(() {
      _allVaccines = vaccines
          .map(
            (entity) => VaccineModel(
              id: entity.id,
              uuid: entity.uuid,
              farmUuid: entity.farmUuid,
              name: entity.name,
              lot: entity.lot,
              formulationType: entity.formulationType,
              dose: entity.dose,
              status: entity.status,
              vaccineTypeId: entity.vaccineTypeId,
              vaccineSchedule: entity.vaccineSchedule,
              synced: entity.synced,
              syncAction: entity.syncAction,
              createdAt: entity.createdAt,
              updatedAt: entity.updatedAt,
            ),
          )
          .toList();
    });

    _rebuildVaccineItems(_selectedFarmUuid);
  }

  void _rebuildVaccineItems(String? farmUuid) {
    if (!mounted) return;

    final filtered = _allVaccines.where((vaccine) {
      if (vaccine.id == null) return false;
      if (farmUuid == null || farmUuid.isEmpty) {
        return vaccine.farmUuid == null || vaccine.farmUuid!.isEmpty;
      }
      return vaccine.farmUuid == farmUuid;
    }).toList();

    filtered.sort((a, b) => (b.updatedAt).compareTo(a.updatedAt));

    final items = filtered
        .map(
          (vaccine) =>
              DropdownItem<int>(value: vaccine.id!, label: vaccine.name),
        )
        .toList();

    int? selected = _selectedVaccineId;
    if (selected != null && items.every((item) => item.value != selected)) {
      selected = null;
    }
    if (selected == null && items.isNotEmpty) {
      selected = items.first.value;
    }

    setState(() {
      _vaccineItems = items;
      _selectedVaccineId = selected;
    });
  }

  Future<void> _loadDiseases() async {
    try {
      final referenceProvider = Provider.of<LogAdditionalDataProvider>(
        context,
        listen: false,
      );

      await referenceProvider.ensureLoaded();

      final items = referenceProvider.diseases
          .map(
            (disease) =>
                DropdownItem<int>(value: disease.id, label: disease.name),
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _diseaseItems = items;
      });

      if (_selectedDiseaseId != null &&
          items.every((item) => item.value != _selectedDiseaseId)) {
        setState(() => _selectedDiseaseId = null);
      }
    } catch (e, stackTrace) {
      log(
        '❌ Failed to load diseases for vaccination form: $e',
        stackTrace: stackTrace,
      );
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

    _rebuildVaccineItems(value);
  }

  void _onLivestockSelected(String? value) {
    if (value == null) return;
    setState(() {
      _selectedLivestockUuid = value;
    });
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
    _vaccinationNoController.dispose();
    _vetIdController.dispose();
    _extensionOfficerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.vaccination}'
        : l10n.addVaccination;
    final submitLabel = widget.isEditMode ? l10n.update : l10n.save;

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
      body: (_isLoadingContext || _isLoadingVaccines || _isLoadingDiseases)
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
                            title: l10n.vaccinationDetails,
                            subtitle: l10n.vaccinationDetailsSubtitle,
                            icon: Icons.vaccines_outlined,
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
            l10n.logContextMissing,
            theme,
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
              l10n.noLivestockFound,
              theme,
              tone: InfoBannerTone.warning,
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
        _buildSectionTitle(l10n.vaccinationDetails, theme),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _vaccinationNoController,
          label: l10n.vaccinationNumber,
          hintText: l10n.enterVaccinationNumber,
          prefixIcon: Icons.confirmation_number_outlined,
          prefixText: _vaccinationNumberPrefix,
        ),
        const SizedBox(height: 16),
        if (_vaccineItems.isEmpty)
          _buildInfoBanner(
            l10n.vaccineOptionsMissing,
            theme,
            icon: Icons.warning_amber_rounded,
            tone: InfoBannerTone.warning,
          )
        else
          CustomDropdown<int>(
            label: l10n.selectVaccine,
            hint: l10n.selectVaccine,
            icon: Icons.vaccines_outlined,
            value: _selectedVaccineId,
            dropdownItems: _vaccineItems,
            onChanged: (value) => setState(() => _selectedVaccineId = value),
          ),
        const SizedBox(height: 16),
        if (_isLoadingDiseases)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_diseaseItems.isEmpty)
          _buildInfoBanner(
            l10n.diseaseOptionsMissing,
            theme,
            icon: Icons.warning_amber_rounded,
            tone: InfoBannerTone.warning,
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
        CustomDropdown<String>(
          label: l10n.vaccinationStatus,
          hint: l10n.selectStatus,
          icon: Icons.verified_outlined,
          value: _selectedStatus,
          dropdownItems: _statusItems(l10n),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedStatus = value);
          },
        ),
        const SizedBox(height: 24),
        _buildInfoBanner(
          l10n.vaccinationContextInfo,
          theme,
          icon: Icons.info_outline,
        ),
      ],
    );
  }

  Widget _buildDetailsStep(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.vaccinationPersonnelDetails, theme),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _vetIdController,
          label: l10n.vetLicense,
          hintText: l10n.enterVetLicenseOptional,
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _extensionOfficerController,
          label: l10n.extensionOfficerLicense,
          hintText: l10n.enterExtensionOfficerLicenseOptional,
          prefixIcon: Icons.person_search_outlined,
        ),
        const SizedBox(height: 24),
        _buildInfoBanner(
          l10n.vaccinationNotesInfo,
          theme,
          icon: Icons.lightbulb_outline,
        ),
      ],
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
          ? l10n.confirmUpdateVaccination
          : l10n.confirmSaveVaccination,
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

    try {
      final vaccinationNumberSuffix = _vaccinationNoController.text.trim();
      final vaccinationNumber = vaccinationNumberSuffix.isEmpty
          ? null
          : '$_vaccinationNumberPrefix$vaccinationNumberSuffix';

      if (widget.isEditMode && !_isBulk) {
        final existing = widget.vaccination!;
        final updatedModel = existing.copyWith(
          vaccinationNo: vaccinationNumber,
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          vaccineId: _selectedVaccineId,
          diseaseId: _selectedDiseaseId,
          vetId: _vetIdController.text.trim().isEmpty
              ? null
              : _vetIdController.text.trim(),
          extensionOfficerId: _extensionOfficerController.text.trim().isEmpty
              ? null
              : _extensionOfficerController.text.trim(),
          status: _selectedStatus,
          synced: false,
          syncAction: existing.syncAction == 'create' ? 'create' : 'update',
          updatedAt: DateTime.now().toIso8601String(),
        );

        final updated = await eventsProvider.updateVaccinationWithDialog(
          context,
          updatedModel,
        );
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        }
      } else if (_isBulk) {
        final created = await eventsProvider.addVaccinationBatchWithDialog(
          context: context,
          farmUuid: selectedFarmUuid,
          livestockUuids: livestockUuids,
          vaccinationNo: vaccinationNumber,
          vaccineId: _selectedVaccineId,
          diseaseId: _selectedDiseaseId,
          vetId:
              _vetIdController.text.trim().isEmpty ? null : _vetIdController.text.trim(),
          extensionOfficerId: _extensionOfficerController.text.trim().isEmpty
              ? null
              : _extensionOfficerController.text.trim(),
          status: _selectedStatus,
        );

        if (created.isNotEmpty && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final now = DateTime.now().toIso8601String();
        final uuid =
            'vaccination-${DateTime.now().microsecondsSinceEpoch}-${livestockUuids.first.hashCode}';

        final newModel = VaccinationModel(
          uuid: uuid,
          vaccinationNo: vaccinationNumber,
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          vaccineId: _selectedVaccineId,
          diseaseId: _selectedDiseaseId,
          vetId: _vetIdController.text.trim().isEmpty
              ? null
              : _vetIdController.text.trim(),
          extensionOfficerId: _extensionOfficerController.text.trim().isEmpty
              ? null
              : _extensionOfficerController.text.trim(),
          status: _selectedStatus,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );

        final created = await eventsProvider.addVaccinationWithDialog(
          context,
          newModel,
        );
        if (created != null && mounted) {
          Navigator.pop(context, created);
        }
      }
    } catch (e, stackTrace) {
      log('❌ Failed to save vaccination log: $e', stackTrace: stackTrace);
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.vaccinationLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }

  List<DropdownItem<String>> _statusItems(AppLocalizations l10n) => [
    DropdownItem(value: 'scheduled', label: l10n.statusScheduled),
    DropdownItem(value: 'completed', label: l10n.statusCompleted),
    DropdownItem(value: 'cancelled', label: l10n.statusCancelled),
  ];

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Constants.primaryColor,
      ),
    );
  }

  Widget _buildInfoBanner(
    String message,
    ThemeData theme, {
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
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: baseColor.withValues(alpha: 0.25)),
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
