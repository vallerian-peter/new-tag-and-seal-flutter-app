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
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/birth_event_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/birth_type.dart' as models;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/birth_problem.dart' as models;
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/piglet_bulk_registration_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class BirthEventFormScreen extends StatefulWidget {
  final BirthEventModel? birthEvent;
  final String? farmUuid;
  final String? livestockUuid;

  const BirthEventFormScreen({
    super.key,
    this.birthEvent,
    this.farmUuid,
    this.livestockUuid,
  });

  bool get isEditMode => birthEvent != null;

  @override
  State<BirthEventFormScreen> createState() => _BirthEventFormScreenState();
}

class _BirthEventFormScreenState extends State<BirthEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey<FormState>();

  final _eventDateController = TextEditingController();
  final _remarksController = TextEditingController();
  final _totalBornController = TextEditingController();
  final _deadCountController = TextEditingController();

  int _currentStep = 0;
  bool _isLoadingData = true;
  bool _isLoadingLivestock = false;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;
  Livestock? _selectedLivestock;
  String? _eventType; // 'calving' or 'farrowing'
  String? _speciesName; // For labels

  int? _selectedBirthTypeId;
  int? _selectedBirthProblemId;
  int? _selectedReproductiveProblemId;
  String _selectedStatus = 'active';

  DateTime? _selectedEventDate;
  DateTime? _startDate;
  DateTime? _endDate;

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  List<DropdownItem<int>> _birthTypeItems = const [];
  List<DropdownItem<int>> _birthProblemItems = const [];
  List<DropdownItem<int>> _reproductiveProblemItems = const [];

  void _onLitterCountsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _prefillFormIfEditing();
    if (widget.birthEvent == null) {
      _deadCountController.text = '0';
    }
    _totalBornController.addListener(_onLitterCountsChanged);
    _deadCountController.addListener(_onLitterCountsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  void _prefillFormIfEditing() {
    final birthEvent = widget.birthEvent;
    _selectedFarmUuid = widget.farmUuid;
    _selectedLivestockUuid = widget.livestockUuid;

    if (birthEvent == null) return;

    if (birthEvent.eventDate != null && birthEvent.eventDate!.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(birthEvent.eventDate!);
      if (parsed != null) {
        _selectedEventDate = parsed;
        _eventDateController.text = DateFormat.yMMMd().add_jm().format(parsed.toLocal());
      }
    }
    _eventType = birthEvent.eventType;
    _selectedBirthTypeId = birthEvent.birthTypeId;
    _selectedBirthProblemId = birthEvent.birthProblemsId;
    _selectedReproductiveProblemId = birthEvent.reproductiveProblemId;
    _selectedStatus = birthEvent.status;
    _remarksController.text = birthEvent.remarks ?? '';
    _totalBornController.text = birthEvent.totalBorn?.toString() ?? '';
    _deadCountController.text = birthEvent.deadCount?.toString() ?? '0';

    _startDate = DateTime.tryParse(birthEvent.startDate);
    _endDate = birthEvent.endDate != null
        ? DateTime.tryParse(birthEvent.endDate!)
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
      // _loadContextData() will call _loadLivestockSpecies() and _loadReferenceData()
      // after livestock is loaded, so we don't need to call _loadReferenceData() again here
      await _loadContextData();
      
      // If livestock wasn't loaded in _loadContextData() (e.g., no livestockUuid provided),
      // still load reference data with all items as fallback
      if (_selectedLivestock == null) {
        await _loadReferenceData();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _loadLivestockSpecies() async {
    if (_selectedLivestockUuid == null) return;

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      final livestock = await database.livestockDao
          .getLivestockByUuid(_selectedLivestockUuid!);

      if (livestock == null) return;

      final species = await database.specieDao.getSpecieById(livestock.speciesId);

      if (!mounted) return;
      setState(() {
        _selectedLivestock = livestock;
        _speciesName = species?.name ?? 'cattle';
        // Determine eventType if not already set
        if (_eventType == null) {
          _eventType = EventLogTypes.getBirthEventType(_speciesName ?? 'cattle');
        }
      });
    } catch (e) {
      log('❌ Failed to load livestock species: $e');
    }
  }

  Future<void> _loadReferenceData() async {
    final provider = Provider.of<LogAdditionalDataProvider>(
      context,
      listen: false,
    );
    await provider.ensureLoaded();

    if (!mounted) return;
    
    // Use birth types/problems if available, otherwise fallback to calving types/problems
    final birthTypes = provider.birthTypes.isNotEmpty 
        ? provider.birthTypes 
        : provider.calvingTypes.map((ct) => models.BirthType(id: ct.id, name: ct.name)).toList();
    
    final birthProblems = provider.birthProblems.isNotEmpty 
        ? provider.birthProblems 
        : provider.calvingProblems.map((cp) => models.BirthProblem(id: cp.id, name: cp.name)).toList();
    
    // Filter by livestock type if available
    int? livestockTypeId;
    if (_selectedLivestock != null) {
      livestockTypeId = _selectedLivestock!.livestockTypeId;
    }
    
    setState(() {
      // Filter birth types by livestock type
      // If livestockTypeId is null (not loaded yet), show all items as fallback
      // Otherwise, show items matching livestockTypeId or generic items (where livestockTypeId is null)
      final filteredBirthTypes = birthTypes
          .where((type) {
            if (livestockTypeId == null) {
              // Livestock not loaded yet - show all items
              return true;
            }
            // Show items matching livestock type or generic items
            return type.livestockTypeId == null || type.livestockTypeId == livestockTypeId;
          })
          .map((type) => DropdownItem<int>(value: type.id, label: type.name))
          .toList();
      
      // Fallback: if filtered list is empty, show all items
      _birthTypeItems = filteredBirthTypes.isEmpty
          ? birthTypes.map((type) => DropdownItem<int>(value: type.id, label: type.name)).toList()
          : filteredBirthTypes;
      
      // Filter birth problems by livestock type
      final filteredBirthProblems = birthProblems
          .where((problem) {
            if (livestockTypeId == null) {
              // Livestock not loaded yet - show all items
              return true;
            }
            // Show items matching livestock type or generic items
            return problem.livestockTypeId == null || problem.livestockTypeId == livestockTypeId;
          })
          .map(
            (problem) =>
                DropdownItem<int>(value: problem.id, label: problem.name),
          )
          .toList();
      
      // Fallback: if filtered list is empty, show all items
      _birthProblemItems = filteredBirthProblems.isEmpty
          ? birthProblems.map((problem) => DropdownItem<int>(value: problem.id, label: problem.name)).toList()
          : filteredBirthProblems;
      
      // Reproductive problems are generic and apply to all livestock types - no filtering needed
      _reproductiveProblemItems = provider.reproductiveProblems
          .map(
            (problem) =>
                DropdownItem<int>(value: problem.id, label: problem.name),
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
      
      // Load species after livestock is selected
      if (livestockUuid != null) {
        await _loadLivestockSpecies();
        // Reload reference data to filter by livestock type
        await _loadReferenceData();
      }
    } catch (e) {
      log('❌ Failed to load context data: $e');
    }
  }

  void _onFarmSelected(String value) async {
    setState(() {
      _selectedFarmUuid = value;
      if (widget.livestockUuid == null) {
        _selectedLivestockUuid = null;
        _selectedLivestock = null;
        _speciesName = null;
        _eventType = null;
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
      
      // Load species for selected livestock
      if (_selectedLivestockUuid != null) {
        await _loadLivestockSpecies();
        // Reload reference data to filter by livestock type
        await _loadReferenceData();
      }
    } catch (e) {
      log('❌ Failed to load livestock: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLivestock = false);
      }
    }
  }

  void _onLivestockSelected(String? value) async {
    if (value == null) return;
    setState(() {
      _selectedLivestockUuid = value;
      _selectedLivestock = null;
      _speciesName = null;
      _eventType = null;
    });
    
    // Load species for selected livestock
    await _loadLivestockSpecies();
    // Reload reference data to filter by livestock type
    await _loadReferenceData();
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

  int? _parsePositiveIntOrNull(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get dynamic labels based on species
    final eventName = _eventType != null
        ? (_eventType == 'farrowing' ? l10n.farrowing : l10n.calving)
        : l10n.birthEvent;
    final title = widget.isEditMode
        ? '${l10n.edit} $eventName'
        : eventName;
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
                              subtitle: '${eventName} Details',
                              icon: Icons.child_friendly_outlined,
                              content: _buildStepOne(l10n, theme, eventName),
                            ),
                            StepperStep(
                              title: l10n.additionalDetails,
                              subtitle: '${eventName} Notes',
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

  Widget _buildStepOne(
    AppLocalizations l10n,
    ThemeData theme,
    String eventName,
  ) {
    final farmItems = _buildFarmDropdownItems();
    final livestockItems = _buildLivestockDropdownItems(l10n);
    final isFarmLocked = widget.farmUuid != null && widget.farmUuid!.isNotEmpty;
    final isLivestockLocked =
        widget.livestockUuid != null && widget.livestockUuid!.isNotEmpty;
    final isFarrowing = _eventType == 'farrowing';

    // Labels for birth type/problem
    final birthTypeLabel = l10n.birthType;
    final birthProblemLabel = l10n.birthProblem;

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
        _buildSectionTitle(eventName),
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
          controller: _totalBornController,
          label: l10n.totalBorn,
          hintText: l10n.enterTotalBornOptional,
          prefixIcon: Icons.numbers_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            final parsed = _parsePositiveIntOrNull(value ?? '');
            if ((value ?? '').trim().isNotEmpty && parsed == null) {
              return l10n.enterValidNumber;
            }
            if (parsed != null && parsed < 0) {
              return l10n.valueMustBeZeroOrMore;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _deadCountController,
          label: l10n.deadCount,
          hintText: l10n.deadCountDefaultsToZero,
          prefixIcon: Icons.heart_broken_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            final trimmed = (value ?? '').trim();
            if (trimmed.isNotEmpty) {
              final parsed = int.tryParse(trimmed);
              if (parsed == null) {
                return l10n.enterValidNumber;
              }
              if (parsed < 0) {
                return l10n.valueMustBeZeroOrMore;
              }
              final total = _parsePositiveIntOrNull(_totalBornController.text);
              if (total != null && parsed > total) {
                return l10n.deadCountExceedsTotalBorn;
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildDerivedAliveSummary(l10n),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          label: birthTypeLabel,
          hint: birthTypeLabel,
          icon: Icons.category_outlined,
          value: _selectedBirthTypeId,
          dropdownItems: _birthTypeItems,
          onChanged: (value) => setState(() => _selectedBirthTypeId = value),
          validator: (value) {
            if (value == null) {
              return isFarrowing
                  ? l10n.farrowingTypeRequired
                  : l10n.calvingTypeRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          label: birthProblemLabel,
          hint: birthProblemLabel,
          icon: Icons.warning_amber_outlined,
          value: _selectedBirthProblemId,
          dropdownItems: [
            const DropdownItem<int>(value: -1, label: '---'),
            ..._birthProblemItems,
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedBirthProblemId = value == -1 ? null : value;
            });
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          label: l10n.reproductiveProblem,
          hint: l10n.reproductiveProblem,
          icon: Icons.healing_outlined,
          value: _selectedReproductiveProblemId,
          dropdownItems: [
            const DropdownItem<int>(value: -1, label: '---'),
            ..._reproductiveProblemItems,
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedReproductiveProblemId = value == -1 ? null : value;
            });
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
            DropdownItem(value: 'not_active', label: l10n.statusNotActive),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedStatus = value);
          },
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.info_outline,
          message: isFarrowing
              ? l10n.ensureFarrowingDetailsAccuracy
              : l10n.ensureCalvingDetailsAccuracy,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStepTwo(AppLocalizations l10n, ThemeData theme) {
    final isFarrowing = _eventType == 'farrowing';
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
          message: isFarrowing
              ? l10n.farrowingNotesInfo
              : l10n.calvingNotesInfo,
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

  Widget _buildDerivedAliveSummary(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final totalRaw = _totalBornController.text.trim();
    final total = int.tryParse(totalRaw);
    final deadRaw = _deadCountController.text.trim();
    final dead = deadRaw.isEmpty ? 0 : (int.tryParse(deadRaw) ?? 0);

    if (totalRaw.isEmpty || total == null) {
      return Text(
        l10n.enterTotalBornToPreviewAlive,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
        ),
      );
    }

    final alive = total - dead;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.aliveCount}: $alive',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: alive < 0
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.aliveCountDerivedNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _totalBornController.removeListener(_onLitterCountsChanged);
    _deadCountController.removeListener(_onLitterCountsChanged);
    _eventDateController.dispose();
    _remarksController.dispose();
    _totalBornController.dispose();
    _deadCountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
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

  Future<void> _pickDate({required bool isStartDate}) async {
    final theme = Theme.of(context);
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? theme.scaffoldBackgroundColor 
        : whiteColor;
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
    // Use correct confirmation message based on event type (calving or farrowing)
    final isFarrowing = _eventType == 'farrowing';
    final confirmationMessage = widget.isEditMode
        ? (isFarrowing ? l10n.confirmUpdateFarrowing : l10n.confirmUpdateCalving)
        : (isFarrowing ? l10n.confirmSaveFarrowing : l10n.confirmSaveCalving);
    
    await AlertDialogs.showConfirmation(
      context: context,
      title: widget.isEditMode ? l10n.update : l10n.save,
      message: confirmationMessage,
      confirmText: widget.isEditMode ? l10n.update : l10n.save,
      cancelText: l10n.cancel,
      onConfirm: () async {
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

    // Ensure eventType is set
    if (_eventType == null) {
      final speciesName = _speciesName ?? 'cattle';
      _eventType = EventLogTypes.getBirthEventType(speciesName);
    }

    final nowIso = DateTime.now().toIso8601String();
    final startDateIso = _startDate?.toIso8601String();
    final endDateIso = _endDate?.toIso8601String();
    final birthTypeId = _selectedBirthTypeId!;
    final totalBorn = _parsePositiveIntOrNull(_totalBornController.text);
    final deadRaw = _deadCountController.text.trim();
    int deadCount = 0;
    if (deadRaw.isNotEmpty) {
      final parsedDead = int.tryParse(deadRaw);
      if (parsedDead == null) {
        if (!mounted) return;
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.enterValidNumber,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
      deadCount = parsedDead;
    }

    int? aliveCount;
    if (totalBorn != null) {
      if (deadCount > totalBorn) {
        if (!mounted) return;
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.deadCountExceedsTotalBorn,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
      aliveCount = totalBorn - deadCount;
    }

    try {
      if (widget.isEditMode) {
        final existing = widget.birthEvent!;
        final eventDateIso = _selectedEventDate?.toIso8601String();
        final updatedModel = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid,
          eventType: _eventType!,
          eventDate: eventDateIso ?? existing.eventDate,
          startDate: startDateIso ?? existing.startDate,
          endDate: endDateIso ?? existing.endDate,
          birthTypeId: birthTypeId,
          birthProblemsId: _selectedBirthProblemId,
          reproductiveProblemId: _selectedReproductiveProblemId,
          remarks: _remarksController.text.trim().isEmpty
              ? null
              : _remarksController.text.trim(),
          totalBorn: totalBorn,
          aliveCount: aliveCount,
          deadCount: deadCount,
          status: _selectedStatus,
          updatedAt: nowIso,
        );

        final updated = await eventsProvider.updateBirthEventWithDialog(
          context,
          updatedModel,
        );
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        }
      } else {
        final uuid =
            '${DateTime.now().millisecondsSinceEpoch}-${selectedLivestockUuid.hashCode}-$birthTypeId';

        final eventDateIso = _selectedEventDate?.toIso8601String();
        final newModel = BirthEventModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid,
          eventType: _eventType!,
          eventDate: eventDateIso,
          startDate: startDateIso ?? nowIso,
          endDate: endDateIso,
          birthTypeId: birthTypeId,
          birthProblemsId: _selectedBirthProblemId,
          reproductiveProblemId: _selectedReproductiveProblemId,
          remarks: _remarksController.text.trim().isEmpty
              ? null
              : _remarksController.text.trim(),
          totalBorn: totalBorn,
          aliveCount: aliveCount,
          deadCount: deadCount,
          status: _selectedStatus,
          synced: false,
          syncAction: 'create',
          createdAt: nowIso,
          updatedAt: nowIso,
        );

        final litterCount = totalBorn;
        if (litterCount != null && litterCount > 0) {
          if (!mounted) return;
          final bulkSaved = await Navigator.of(context, rootNavigator: true).push<bool>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: SafeArea(
                  child: PigletBulkRegistrationScreen(
                    pendingBirthEventToPersist: newModel,
                    preSelectedFarmUuid: selectedFarmUuid,
                    preSelectedMotherUuid: selectedLivestockUuid,
                  ),
                ),
              ),
            ),
          );
          if (mounted && bulkSaved == true) {
            Navigator.pop(context, true);
          }
          return;
        }

        final created = await eventsProvider.addBirthEventWithDialog(
          context,
          newModel,
        );
        if (created != null && mounted) {
          Navigator.pop(context, created);
        }
      }
    } catch (e) {
      log('❌ Error saving birth event: $e');
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: 'Failed to save birth event: $e',
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }
}

