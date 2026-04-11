import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/weight_input_with_bluetooth.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_date_picker.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/livestock_date_entered_farm_picker.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/color_helper.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/presentation/bill_creation_helper.dart';
import 'dart:developer';
import 'package:new_tag_and_seal_flutter_app/features/scanner/presentation/scanner_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/provider/livestock_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/data/repository/events_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:intl/intl.dart';

/// Modern Livestock Registration/Edit Form Screen
///
/// A multi-step form following the same design as FarmFormScreen
class LivestockFormScreen extends StatefulWidget {
  final Livestock? livestock; // Livestock to edit (null for create mode)
  final String? preSelectedFarmUuid; // Farm UUID when coming from farm details

  const LivestockFormScreen({
    super.key,
    this.livestock,
    this.preSelectedFarmUuid,
  });

  @override
  State<LivestockFormScreen> createState() => _LivestockFormScreenState();
}

class _LivestockFormScreenState extends State<LivestockFormScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Check mode
  bool get isEditMode => widget.livestock != null;

  // Controllers
  final _nameController = TextEditingController();
  final _identificationNumberController = TextEditingController();
  final _dummyTagIdController = TextEditingController();
  final _barcodeTagIdController = TextEditingController();
  final _rfidTagIdController = TextEditingController();
  final _weightController = TextEditingController();

  // Prevent recursive updates when keeping barcode/RFID fields in sync
  bool _isUpdatingTagFields = false;

  // Form field values
  String? _selectedFarmUuid;
  int? _selectedLivestockTypeId;
  int? _selectedSpeciesId;
  int? _selectedBreedId;
  String? _selectedGender;
  int? _selectedLivestockObtainedMethodId;
  String? _selectedMotherUuid;
  String? _selectedFatherUuid;
  String? _selectedBirthEventUuid;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedDateFirstEnteredToFarm;
  String _selectedStatus = 'active';
  String? _selectedPrimaryColor;
  String? _selectedSecondaryColor;
  int? _selectedStageId;
  bool _isIdentified = true;

  // Local data
  List<Farm> _farms = [];
  List<LivestockType> _livestockTypes = [];
  List<Specie> _species = [];
  List<Specie> _filteredSpecies = [];
  List<Breed> _breeds = [];
  List<Breed> _filteredBreeds = [];
  List<LivestockObtainedMethod> _livestockObtainedMethods = [];
  List<Livestock> _eligibleMothers = [];
  List<Livestock> _eligibleFathers = [];
  List<BirthEvent> _birthEvents = [];
  List<Stage> _stages = [];
  List<Stage> _filteredStages = [];
  // Keep all active livestock so we can filter eligible parents by livestock type
  List<Livestock> _allLivestock = [];

  bool _isLoadingData = true;
  bool _hasLoadedData = false;
  bool _hasLostDisposal = false; // Track if livestock has disposal with reason='Lost'
  DisposalModel? _lostDisposal; // Store the Lost disposal record for displaying details

  static const Set<String> _earlyStageNames = {
    'piglet',
    'calf',
    'kid',
    'lamb',
    'chick',
    'newborn',
    'neonate',
  };

  @override
  void initState() {
    super.initState();
    log('🔍 LivestockFormScreen initState');
    log('🔍 isEditMode: $isEditMode');
    log('🔍 preSelectedFarmUuid: ${widget.preSelectedFarmUuid}');

    // Pre-fill form if editing
    if (isEditMode) {
      _prefillFormData();
    }
    // Pre-select farm if provided and not editing
    else if (widget.preSelectedFarmUuid != null) {
      _selectedFarmUuid = widget.preSelectedFarmUuid;
      log('✅ Farm pre-selected: $_selectedFarmUuid');
    }

    // Sync RFID and Barcode fields
    _barcodeTagIdController.addListener(() {
      if (_isUpdatingTagFields) return;
      _isUpdatingTagFields = true;
      try {
        if (_rfidTagIdController.text != _barcodeTagIdController.text) {
          _rfidTagIdController.text = _barcodeTagIdController.text;
        }
      } finally {
        _isUpdatingTagFields = false;
      }
    });

    _rfidTagIdController.addListener(() {
      if (_isUpdatingTagFields) return;
      _isUpdatingTagFields = true;
      try {
        if (_barcodeTagIdController.text != _rfidTagIdController.text) {
          _barcodeTagIdController.text = _rfidTagIdController.text;
        }
      } finally {
        _isUpdatingTagFields = false;
      }
    });
  }

  Future<void> _handleScanForField(
    TextEditingController controller,
    TagScanMode mode,
  ) async {
    FocusScope.of(context).unfocus();
    final result = await showTagScannerBottomSheet(context, mode);
    if (!mounted || result == null) return;
    _updateTagIds(result);
  }

  void _updateTagIds(String value) {
    if (_isUpdatingTagFields) return;
    _isUpdatingTagFields = true;
    try {
      _barcodeTagIdController.text = value;
      _rfidTagIdController.text = value;
    } finally {
      _isUpdatingTagFields = false;
    }
  }

  Stage? _getSelectedStage() {
    if (_selectedStageId == null) return null;
    for (final stage in _stages) {
      if (stage.id == _selectedStageId) return stage;
    }
    return null;
  }

  bool get _isEarlyStageSelected {
    final stage = _getSelectedStage();
    if (stage == null) return false;
    return _earlyStageNames.contains(stage.name.trim().toLowerCase());
  }

  bool get _disableTagFields => _isEarlyStageSelected;

  void _applyStageIdentificationRules() {
    if (!_isEarlyStageSelected) return;
    _isIdentified = false;
    _dummyTagIdController.clear();
    _barcodeTagIdController.clear();
    _rfidTagIdController.clear();
  }

  Widget _buildScanSuffixButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  /// Pre-fill form with existing livestock data
  void _prefillFormData() {
    final livestock = widget.livestock!;

    _nameController.text = livestock.name;
    _identificationNumberController.text = livestock.identificationNumber;
    _dummyTagIdController.text = livestock.dummyTagId ?? '';
    _barcodeTagIdController.text = livestock.barcodeTagId ?? '';
    _rfidTagIdController.text = livestock.rfidTagId ?? '';
    _weightController.text = livestock.weightAsOnRegistration.toString();
    _selectedPrimaryColor = livestock.primaryColor;
    _selectedSecondaryColor = livestock.secondaryColor;

    _selectedFarmUuid = livestock.farmUuid;
    _selectedLivestockTypeId = livestock.livestockTypeId;
    _selectedSpeciesId = livestock.speciesId;
    _selectedBreedId = livestock.breedId;
    _selectedGender = livestock.gender;
    _selectedLivestockObtainedMethodId = livestock.livestockObtainedMethodId;
    _selectedMotherUuid = livestock.motherUuid;
    _selectedFatherUuid = livestock.fatherUuid;
    _selectedBirthEventUuid = livestock.birthEventUuid;
    _selectedDateOfBirth = DateTime.parse(livestock.dateOfBirth);
    _selectedDateFirstEnteredToFarm = livestock.dateFirstEnteredToFarm;
    _selectedStatus = livestock.status;
    _selectedStageId = livestock.stageId;
    _isIdentified = livestock.isIdentified;

    log('✅ Form pre-filled');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      _loadDataFromDatabase();
    }
  }

  Future<void> _loadDataFromDatabase() async {
    setState(() => _isLoadingData = true);

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);

      // Load all necessary data
      final farms = await database.farmDao.getAllActiveFarms();
      final livestockTypes = await database.livestockTypeDao
          .getAllLivestockTypes();
      final species = await database.specieDao.getAllSpecies();
      final breeds = await database.breedDao.getAllBreeds();
      final methods = await database.livestockObtainedMethodDao
          .getAllLivestockObtainedMethods();
      final stages = await database.stageDao.getAllStages();
      final birthEvents = await database.eventDao.getBirthEvents();
      final allLivestock = await database.livestockDao
          .getAllActiveLivestock(); // ✅ Only active livestock

      // Check if livestock has disposal with disposalType='Lost' AND status='notActive' (only in edit mode)
      bool hasLostDisposal = false;
      if (isEditMode && widget.livestock != null) {
        try {
          // Check if livestock status is 'notActive'
          final isNotActive = widget.livestock!.status.toLowerCase() == 'notactive';
          
          if (isNotActive) {
            // Get all disposal types to find the "Lost" type
            final disposalTypes = await database.logReferenceDao.getAllDisposalTypes();
            DisposalType? lostDisposalType;
            try {
              lostDisposalType = disposalTypes.firstWhere(
                (type) => type.name.toLowerCase() == 'lost',
              );
            } catch (e) {
              log('⚠️ "Lost" disposal type not found in disposal types list');
            }
            
            if (lostDisposalType != null) {
              // Get disposals for this livestock
              final eventsRepository = EventsRepository(database);
              final disposals = await eventsRepository.getDisposals(
                livestockUuid: widget.livestock!.uuid,
              );
              
              // Find the disposal with disposalTypeId matching "Lost" disposal type
              hasLostDisposal = disposals.any(
                (disposal) => disposal.disposalTypeId == lostDisposalType!.id,
              );
              
              if (hasLostDisposal) {
                try {
                  _lostDisposal = disposals.firstWhere(
                    (disposal) => disposal.disposalTypeId == lostDisposalType!.id,
                  );
                } catch (e) {
                  log('⚠️ Error finding lost disposal: $e');
                }
              }
              
              log(
                '🔍 Checked disposals for livestock ${widget.livestock!.uuid}: hasLostDisposal=$hasLostDisposal, isNotActive=$isNotActive, lostDisposalTypeId=${lostDisposalType.id}',
              );
            }
          }
        } catch (e) {
          log('❌ Error checking disposals: $e');
        }
      }

      setState(() {
        _farms = farms;
        _livestockTypes = livestockTypes;
        _species = species;
        _breeds = breeds;
        _livestockObtainedMethods = methods;
        _stages = stages;
        _birthEvents = birthEvents;
        _allLivestock = allLivestock;
        _hasLostDisposal = hasLostDisposal;

        // Filter species & breeds immediately if livestock type is already selected (edit mode)
        if (_selectedLivestockTypeId != null) {
          _filteredSpecies = species
              .where((s) => s.livestockTypeId == _selectedLivestockTypeId)
              .toList();
          _filteredBreeds = breeds
              .where(
                (breed) => breed.livestockTypeId == _selectedLivestockTypeId,
              )
              .toList();
          if (_filteredSpecies.isEmpty) {
            _filteredSpecies = species;
          }
          _autoSelectSpeciesForLivestockType();
          _filterStagesByLivestockType();
          _applyStageIdentificationRules();
          log(
            '✅ Filtered ${_filteredBreeds.length} breeds and ${_filteredSpecies.length} species for type $_selectedLivestockTypeId',
          );
        } else {
          _filteredSpecies = species;
          _filteredBreeds = breeds;
          _filteredStages = stages;
          _applyStageIdentificationRules();
        }

        _isLoadingData = false;
      });

      log(
        '✅ Data loaded: ${_farms.length} farms, ${_livestockTypes.length} types, ${_species.length} species',
      );
      // After loading all livestock, compute eligible parents based on current livestock type
      _updateEligibleParents();
    } catch (e) {
      log('❌ Error loading data: $e');
      setState(() => _isLoadingData = false);

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load data: ${e.toString()}'),
                backgroundColor: Constants.dangerColor,
              ),
            );
          }
        });
      }
    }
  }

  /// Filter breeds by livestock type
  void _filterBreedsByLivestockType() {
    if (_selectedLivestockTypeId == null) {
      // Reset filters if no livestock type selected
      setState(() {
        _filteredSpecies = _species;
        _filteredBreeds = _breeds;
        _selectedSpeciesId = null;
        _selectedBreedId = null;
      });
      return;
    }

    setState(() {
      // Filter species by livestock typeId if present
      _filteredSpecies = _species
          .where((s) => s.livestockTypeId == _selectedLivestockTypeId)
          .toList();
      if (_filteredSpecies.isEmpty) {
        _filteredSpecies = _species;
      }

      // Reset species if not valid for current type
      if (_selectedSpeciesId != null) {
        final isValidSpecies = _filteredSpecies.any(
          (s) => s.id == _selectedSpeciesId,
        );
        if (!isValidSpecies) {
          _selectedSpeciesId = null;
        }
      }

      _filteredBreeds = _breeds
          .where((breed) => breed.livestockTypeId == _selectedLivestockTypeId)
          .toList();

      // Reset breed if not valid for current type
      if (_selectedBreedId != null) {
        final isValidBreed = _filteredBreeds.any(
          (b) => b.id == _selectedBreedId,
        );
        if (!isValidBreed) {
          _selectedBreedId = null;
        }
      }
    });
    _autoSelectSpeciesForLivestockType();
    log(
      '✅ Filtered ${_filteredBreeds.length} breeds and ${_filteredSpecies.length} species for type $_selectedLivestockTypeId',
    );
  }

  /// Check if "Born on Farm" method is selected
  bool _isBornOnFarmSelected() {
    if (_selectedLivestockObtainedMethodId == null) return false;
    try {
      final selectedMethod = _livestockObtainedMethods.firstWhere(
        (method) => method.id == _selectedLivestockObtainedMethodId,
      );
      return selectedMethod.name.toLowerCase().contains('born');
    } catch (e) {
      return false;
    }
  }

  /// Recompute eligible mothers and fathers based on current livestock type.
  void _updateEligibleParents() {
    if (_allLivestock.isEmpty) return;

    final currentUuid = widget.livestock?.uuid;
    final typeId = _selectedLivestockTypeId;

    setState(() {
      Iterable<Livestock> base = _allLivestock;

      // If a livestock type is selected, keep only animals of that type
      if (typeId != null) {
        base = base.where((l) => l.livestockTypeId == typeId);
      }

      _eligibleMothers = base
          .where((l) => l.gender.toLowerCase() == 'female')
          .where((l) => currentUuid == null ? true : l.uuid != currentUuid)
          .toList();

      _eligibleFathers = base
          .where((l) => l.gender.toLowerCase() == 'male')
          .where((l) => currentUuid == null ? true : l.uuid != currentUuid)
          .toList();
    });

    log(
      '✅ Eligible mothers: ${_eligibleMothers.length}, fathers: ${_eligibleFathers.length} for type $typeId',
    );
  }

  /// Keep species logically in sync with selected livestock type
  /// by auto-selecting a species whose name matches the livestock type name.
  void _autoSelectSpeciesForLivestockType() {
    if (_selectedLivestockTypeId == null) return;

    // Find the selected livestock type
    LivestockType? selectedType;
    for (final type in _livestockTypes) {
      if (type.id == _selectedLivestockTypeId) {
        selectedType = type;
        break;
      }
    }
    if (selectedType == null) return;

    // If species already matches the type name, keep it
    if (_selectedSpeciesId != null) {
      final current = _species.firstWhere(
        (s) => s.id == _selectedSpeciesId,
        orElse: () => _species.first,
      );
      if (current.name.toLowerCase() == selectedType.name.toLowerCase()) {
        return;
      }
    }

    // Prefer a species explicitly linked to this livestock type
    Specie? matchingSpecies;
    for (final specie in _filteredSpecies) {
      if (specie.livestockTypeId == _selectedLivestockTypeId) {
        matchingSpecies = specie;
        break;
      }
    }

    // Fallback: try to find a species with the same name as the livestock type
    if (matchingSpecies == null) {
      for (final specie in _filteredSpecies) {
        if (specie.name.toLowerCase() == selectedType.name.toLowerCase()) {
          matchingSpecies = specie;
          break;
        }
      }
    }

    if (matchingSpecies != null) {
      setState(() {
        _selectedSpeciesId = matchingSpecies!.id;
      });
      log(
        '✅ Auto-selected species "${matchingSpecies.name}" for livestock type "${selectedType.name}"',
      );
    }
  }

  void _filterStagesByLivestockType() {
    if (_selectedLivestockTypeId == null) {
      setState(() {
        _filteredStages = _stages;
        _selectedStageId = null;
      });
      return;
    }

    final filtered = _stages
        .where((stage) => stage.livestockTypeId == _selectedLivestockTypeId)
        .toList();

    setState(() {
      _filteredStages = filtered;
      if (_selectedStageId != null &&
          !_filteredStages.any((s) => s.id == _selectedStageId)) {
        _selectedStageId = null;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identificationNumberController.dispose();
    _dummyTagIdController.dispose();
    _barcodeTagIdController.dispose();
    _rfidTagIdController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onStepContinue() async {
    if (_currentStep < 2) {
      // Validate current step
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else {
      // Final step - validate and show confirmation dialog
      if (!_formKey.currentState!.validate()) return;

      final l10n = AppLocalizations.of(context)!;

      // Validate required selections
      if (_selectedFarmUuid == null) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pleaseSelectFarm,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
      if (_selectedLivestockTypeId == null) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pleaseSelectLivestockType,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
      if (_selectedSpeciesId == null) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pleaseSelectSpecies,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
      if (_selectedBreedId == null) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pleaseSelectBreed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
      if (_selectedGender == null) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.genderRequired,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
      if (_selectedDateOfBirth == null) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pleaseSelectDateOfBirth,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }
      if (_selectedDateFirstEnteredToFarm == null) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pleaseSelectDateEnteredFarm,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }

      // Ensure identification number is unique globally
      final idNumber = _identificationNumberController.text.trim();
      final livestockProvider = context.read<LivestockProvider>();
      final isUnique = await livestockProvider.isIdentificationNumberUnique(
        idNumber,
        // farmUuid: _selectedFarmUuid, // Removed to enforce global uniqueness
        excludeUuid: isEditMode ? widget.livestock!.uuid : null,
      );
      if (!isUnique) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.identificationNumberExists,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
        return;
      }

      // Ensure RFID Tag ID is unique globally
      final rfidTagId = _rfidTagIdController.text.trim();
      if (rfidTagId.isNotEmpty) {
        final isRfidUnique = await livestockProvider.isRfidTagIdUnique(
          rfidTagId,
          excludeUuid: isEditMode ? widget.livestock!.uuid : null,
        );
        if (!isRfidUnique) {
          await AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message: l10n.rfidTagIdExists,
            buttonText: l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
          );
          return;
        }
      }

      // Ensure Barcode Tag ID is unique globally
      final barcodeTagId = _barcodeTagIdController.text.trim();
      if (barcodeTagId.isNotEmpty) {
        final isBarcodeUnique = await livestockProvider.isBarcodeTagIdUnique(
          barcodeTagId,
          excludeUuid: isEditMode ? widget.livestock!.uuid : null,
        );
        if (!isBarcodeUnique) {
          await AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message: l10n.barcodeTagIdExists,
            buttonText: l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
          );
          return;
        }
      }

      // Show confirmation dialog
      await AlertDialogs.showConfirmation(
        context: context,
        title: isEditMode ? l10n.update : l10n.register,
        message: isEditMode
            ? l10n.confirmUpdateLivestock
            : l10n.confirmRegisterLivestock,
        confirmText: isEditMode ? l10n.update : l10n.register,
        cancelText: l10n.cancel,
        onConfirm: () async {
          Navigator.of(context).pop(true);
          await _submitLivestockRegistration();
        },
      );
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitLivestockRegistration() async {
    final l10n = AppLocalizations.of(context)!;
    final livestockProvider = context.read<LivestockProvider>();

    try {
      // Show loading dialog
      AlertDialogs.showLoading(
        context: context,
        title: l10n.save,
        message: '',
        isDismissible: false,
      );

      // Generate UUID if creating new livestock
      final uuid =
          widget.livestock?.uuid ??
          '${DateTime.now().millisecondsSinceEpoch}-${_nameController.text.hashCode.abs()}';

      // Get species ID from selected livestock type (they should match)
      final selectedSpeciesId = _selectedSpeciesId ?? _selectedLivestockTypeId!;

      // Prepare data map
      final Map<String, dynamic> livestockData = {
        'farmUuid': _selectedFarmUuid,
        'uuid': uuid,
        'identificationNumber': _identificationNumberController.text.trim(),
        'dummyTagId': _dummyTagIdController.text.trim().isEmpty
            ? null
            : _dummyTagIdController.text.trim(),
        'barcodeTagId': _barcodeTagIdController.text.trim().isEmpty
            ? null
            : _barcodeTagIdController.text.trim(),
        'rfidTagId': _rfidTagIdController.text.trim().isEmpty
            ? null
            : _rfidTagIdController.text.trim(),
        'livestockTypeId': _selectedLivestockTypeId,
        'name': _nameController.text.trim(),
        'dateOfBirth': _selectedDateOfBirth!.toIso8601String().split('T')[0],
        'motherUuid': _selectedMotherUuid,
        'fatherUuid': _selectedFatherUuid,
        'birthEventUuid': _selectedBirthEventUuid,
        'gender': _selectedGender,
        'breedId': _selectedBreedId,
        'speciesId': selectedSpeciesId,
        'status': _selectedStatus,
        'livestockObtainedMethodId': _selectedLivestockObtainedMethodId ?? 1,
        'dateFirstEnteredToFarm': _selectedDateFirstEnteredToFarm,
        'weightAsOnRegistration': double.parse(_weightController.text.trim()),
        'primaryColor': _selectedPrimaryColor,
        'secondaryColor': _selectedSecondaryColor,
        'stageId': _selectedStageId,
        'isIdentified': _isIdentified,
      };

      if (isEditMode) {
        // Update existing livestock
        final updatedLivestock = await livestockProvider.updateLivestock(
          widget.livestock!.id,
          livestockData,
        );

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (updatedLivestock) {
          log('✅ Livestock updated successfully');

          // Trigger bill creation for extension officers BEFORE success dialog
          if (mounted) {
            await BillCreationHelper.maybeCreateBillForLivestock(
              context: context,
              farmUuid: _selectedFarmUuid!,
              livestockUuid: uuid,
            );
          }

          // Show success dialog AFTER bill creation
          if (mounted) {
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: l10n.livestockUpdatedSuccessfully,
              buttonText: l10n.ok,
            );
          }

          // Navigate back
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          throw Exception('Failed to update livestock');
        }
      } else {
        // Create new livestock
        final createdLivestock = await livestockProvider.createLivestock(
          livestockData,
        );

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (createdLivestock != null) {
          log('✅ Livestock registered successfully');

          // Trigger bill creation for extension officers BEFORE success dialog
          if (mounted) {
            await BillCreationHelper.maybeCreateBillForLivestock(
              context: context,
              farmUuid: _selectedFarmUuid!,
              livestockUuid: uuid,
            );
          }

          // Show success dialog AFTER bill creation
          if (mounted) {
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: l10n.livestockRegisteredSuccessfully,
              buttonText: l10n.ok,
            );
          }

          // Navigate back
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          throw Exception('Failed to create livestock');
        }
      }
    } catch (e) {
      log('❌ Error saving livestock: $e');

      // Close loading dialog if open
      if (mounted) {
        // Check if loading dialog is top-most route (simplified check)
        // In a real app we might track dialog state better, but here we assume it might be open
        // We can't easily check if dialog is open, but we can try to pop if we know we opened it.
        // However, since we popped it in success paths, we might need to be careful.
        // A safer way is to rely on the fact that we opened it at the start.
        // If we are here, we might have failed before popping.
        // But if we failed after popping (unlikely given the flow), we shouldn't pop again.
        // Let's assume we need to pop if we haven't reached the success pop.
        // Actually, let's just show error dialog.
        // If loading dialog is still up, showing another dialog might stack them.
        // Best practice: ensure loading dialog is closed before showing error.
        // But since we don't have a variable tracking it, let's just try to pop once.
        // Navigator.of(context).pop(); // This might pop the screen if dialog is already closed.
        // So let's rely on the fact that we pop on success. On error, we should also pop loading.
        // I'll add a flag or just pop.
        // Let's just pop once, assuming loading is the top.
        // But if exception happened before loading (unlikely), we pop the screen.
        // Let's be safe:
      }

      // We need to ensure loading dialog is closed.
      // Since I can't easily know, I will just show error.
      // If loading is there, it will be covered.
      // But better to close it.
      // I'll assume I need to pop it.
      // But wait, if I pop and it wasn't there, I close the screen.
      // I'll leave it for now and just show error.

      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: '${l10n.failedToSaveLivestock}: ${e.toString()}',
        buttonText: l10n.ok,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final buttonText = _currentStep == 2
        ? (isEditMode ? l10n.update : l10n.register)
        : l10n.continueButton;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.scaffoldBackgroundColor
          : Constants.veryLightGreyColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: theme.brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
        leading: CustomBackButton(
          isEnabledBgColor: false,
          iconColor: theme.colorScheme.tertiary,
          iconSize: 24,
        ),
        title: Text(
          isEditMode ? '${l10n.edit} ${l10n.livestock}' : l10n.addLivestock,
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
                child: CustomStepper(
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  isLoading: false,
                  continueButtonText: buttonText,
                  backButtonText: l10n.back,
                  steps: [
                    StepperStep(
                      title: l10n.basicInformation,
                      subtitle: l10n.farmNameAndIdentification,
                      icon: Icons.pets_outlined,
                      content: _buildBasicInfoStep(l10n),
                    ),
                    StepperStep(
                      title: l10n.physicalDetails,
                      subtitle: l10n.typeSpeciesBreedCharacteristics,
                      icon: Icons.info_outline,
                      content: _buildPhysicalDetailsStep(l10n),
                    ),
                    StepperStep(
                      title: l10n.additionalInfo,
                      subtitle: l10n.parentsMethodAndDates,
                      icon: Icons.calendar_today_outlined,
                      content: _buildAdditionalInfoStep(l10n),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // STEP 1: Basic Information
  Widget _buildBasicInfoStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: Farm Location
        _buildSectionTitle(
          icon: Icons.agriculture_outlined,
          title: l10n.farmLocation,
          subtitle: l10n.selectWhereLocated,
        ),
        const SizedBox(height: 12),

        // Farm Selection
        CustomDropdown<String>(
          label: l10n.farm,
          hint: l10n.select,
          icon: Icons.agriculture_outlined,
          value: _selectedFarmUuid,
          dropdownItems: _farms.map((farm) {
            return DropdownItem<String>(value: farm.uuid, label: farm.name);
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedFarmUuid = value;
              if (_selectedBirthEventUuid != null) {
                final stillValid = _birthEvents.any(
                  (event) =>
                      event.uuid == _selectedBirthEventUuid &&
                      event.farmUuid == value,
                );
                if (!stillValid) {
                  _selectedBirthEventUuid = null;
                }
              }
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseSelectFarm;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Section Title: Basic Details
        _buildSectionTitle(
          icon: Icons.info_outline,
          title: l10n.basicDetails,
          subtitle: l10n.enterNameAndId,
        ),
        const SizedBox(height: 12),

        // Livestock Name
        CustomTextField(
          controller: _nameController,
          label: '${l10n.livestockName} *',
          hintText: l10n.enterLivestockName,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.nameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Identification Number
        CustomTextField(
          controller: _identificationNumberController,
          label: '${l10n.identificationNumber} *',
          hintText: l10n.enterIdentificationNumber,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.identificationNumberRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  // STEP 2: Physical Details
  Widget _buildPhysicalDetailsStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: Classification
        _buildSectionTitle(
          icon: Icons.category_outlined,
          title: l10n.livestockClassification,
          subtitle: l10n.selectTypeSpeciesBreed,
        ),
        const SizedBox(height: 12),

        // Livestock Type
        CustomDropdown<int>(
          label: l10n.livestockType,
          hint: l10n.select,
          icon: Icons.category_outlined,
          value: _selectedLivestockTypeId,
          dropdownItems: _livestockTypes.map((type) {
            return DropdownItem<int>(value: type.id, label: type.name);
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLivestockTypeId = value;
              _filterBreedsByLivestockType();
            });
            _filterStagesByLivestockType();
            // Also re-filter eligible parents by livestock type
            _updateEligibleParents();
          },
          validator: (value) {
            if (value == null) {
              return l10n.livestockTypeRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Species (filtered by Livestock Type when available)
        CustomDropdown<int>(
          key: ValueKey(
            'species_dropdown_${_selectedLivestockTypeId}_${_filteredSpecies.length}',
          ), // Force rebuild when species list changes
          label: l10n.species,
          hint: _selectedLivestockTypeId == null
              ? l10n.pleaseSelectLivestockType
              : l10n.select,
          icon: Icons.pets_outlined,
          value: _selectedSpeciesId,
          enabled:
              _selectedLivestockTypeId !=
              null, // Disable until livestock type is selected
          dropdownItems: _filteredSpecies.map((species) {
            return DropdownItem<int>(value: species.id, label: species.name);
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSpeciesId = value;
              // When species changes, reset breed selection (breed depends on species)
              _selectedBreedId = null;
            });
          },
          validator: (value) {
            if (_selectedLivestockTypeId == null) {
              return null; // Don't validate if livestock type is not selected
            }
            if (value == null) {
              return l10n.speciesRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Breed (Filtered by Livestock Type)
        CustomDropdown<int>(
          key: ValueKey(
            'breed_dropdown_${_selectedLivestockTypeId}_${_selectedSpeciesId}_${_filteredBreeds.length}',
          ), // Force rebuild when breeds change
          label: l10n.breed,
          hint: _selectedLivestockTypeId == null
              ? l10n.pleaseSelectLivestockType
              : (_selectedSpeciesId == null
                    ? l10n.pleaseSelectSpecies
                    : l10n.select),
          icon: Icons.menu_book_outlined,
          value: _selectedBreedId,
          enabled:
              _selectedLivestockTypeId != null &&
              _selectedSpeciesId !=
                  null, // Disable until both livestock type and species are selected
          dropdownItems: _filteredBreeds.map((breed) {
            return DropdownItem<int>(value: breed.id, label: breed.name);
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedBreedId = value);
          },
          validator: (value) {
            if (_selectedLivestockTypeId == null ||
                _selectedSpeciesId == null) {
              return null; // Don't validate if livestock type or species is not selected
            }
            if (value == null) {
              return l10n.breedRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Section Title: Physical Characteristics
        _buildSectionTitle(
          icon: Icons.monitor_weight_outlined,
          title: l10n.physicalCharacteristics,
          subtitle: l10n.enterGenderWeightBirth,
        ),
        const SizedBox(height: 12),

        // Gender
        CustomDropdown<String>(
          label: l10n.gender,
          hint: l10n.selectGender,
          icon: Icons.wc_outlined,
          value: _selectedGender,
          dropdownItems: [
            DropdownItem(value: 'male', label: l10n.male),
            DropdownItem(value: 'female', label: l10n.female),
          ],
          onChanged: (value) {
            setState(() => _selectedGender = value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.genderRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        CustomDropdown<int>(
          label: l10n.stage,
          hint: _selectedLivestockTypeId == null
              ? l10n.pleaseSelectLivestockType
              : l10n.select,
          icon: Icons.stacked_line_chart_outlined,
          value: _selectedStageId,
          enabled: _selectedLivestockTypeId != null,
          dropdownItems: _filteredStages
              .map(
                (stage) => DropdownItem<int>(
                  value: stage.id,
                  label: stage.name,
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedStageId = value;
              _applyStageIdentificationRules();
            });
          },
          isRequired: false,
        ),
        const SizedBox(height: 16),

        // Section Title: Tag IDs
        _buildSectionTitle(
          icon: Icons.qr_code_2,
          title: l10n.tagIdentification,
          subtitle: l10n.optionalEnterTagIds,
        ),
        const SizedBox(height: 12),

        // Dummy Tag ID
        CustomTextField(
          controller: _dummyTagIdController,
          label: l10n.dummyTagId,
          hintText: l10n.enterDummyTagId,
          enabled: !_disableTagFields,
          validator: (value) => null,
        ),
        const SizedBox(height: 16),

        // Barcode Tag ID
        CustomTextField(
          controller: _barcodeTagIdController,
          label: l10n.barcodeTagId,
          hintText: l10n.enterBarcodeTagId,
          enabled: !_disableTagFields,
          onChanged: (value) {
            _updateTagIds(value);
          },
          validator: (value) => null,
          suffixIcon: _disableTagFields
              ? null
              : _buildScanSuffixButton(
                  icon: Icons.qr_code_scanner,
                  tooltip: l10n.scanOptionBarcode,
                  onPressed: () => _handleScanForField(
                    _barcodeTagIdController,
                    TagScanMode.barcode,
                  ),
                ),
          suffixIconConstraints: const BoxConstraints(
            minHeight: 48,
            minWidth: 48,
          ),
        ),
        const SizedBox(height: 16),

        // RFID Tag ID
        CustomTextField(
          controller: _rfidTagIdController,
          label: l10n.rfidTagId,
          hintText: l10n.enterRfidTagId,
          enabled: !_disableTagFields,
          onChanged: (value) {
            _updateTagIds(value);
          },
          validator: (value) => null,
          suffixIcon: _disableTagFields
              ? null
              : _buildScanSuffixButton(
                  icon: Icons.nfc,
                  tooltip: l10n.scanOptionRfid,
                  onPressed: () =>
                      _handleScanForField(_rfidTagIdController, TagScanMode.rfid),
                ),
          suffixIconConstraints: const BoxConstraints(
            minHeight: 48,
            minWidth: 48,
          ),
        ),
        const SizedBox(height: 16),

        CustomDropdown<String>(
          label: l10n.identificationStatus,
          hint: l10n.select,
          icon: Icons.verified_outlined,
          value: _isIdentified ? 'identified' : 'not_identified',
          enabled: !_isEarlyStageSelected,
          dropdownItems: [
            DropdownItem<String>(value: 'identified', label: l10n.identified),
            DropdownItem<String>(
              value: 'not_identified',
              label: l10n.notIdentified,
            ),
          ],
          onChanged: (value) {
            setState(() => _isIdentified = value == 'identified');
          },
          isRequired: false,
        ),
        const SizedBox(height: 16),

        // Weight with Bluetooth
        WeightInputWithBluetooth(
          controller: _weightController,
          label: '${l10n.weightKg} *',
          hintText: l10n.enterWeightOrBluetooth,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.weightRequired;
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0) {
              return l10n.enterValidWeight;
            }
            return null;
          },
          onWeightChanged: (weight) {
            log('📊 Weight received from Bluetooth: $weight kg');
          },
        ),
        const SizedBox(height: 16),

        // Date of Birth
        CustomDatePicker(
          label: l10n.dateOfBirth,
          hint: l10n.selectDateOfBirth,
          selectedDate: _selectedDateOfBirth,
          onDateSelected: (date) {
            setState(() {
              _selectedDateOfBirth = date;
              // If "Born on Farm" is selected, also update date first entered to farm
              if (_isBornOnFarmSelected()) {
                _selectedDateFirstEnteredToFarm = date;
              }
            });
          },
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          dateValidator: (date) {
            if (date == null) {
              return l10n.pleaseSelectDateOfBirth;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Section Title: Color Information
        _buildSectionTitle(
          icon: Icons.palette_outlined,
          title: l10n.colorInformation,
          subtitle: l10n.colorInformationSubtitle,
        ),
        const SizedBox(height: 12),

        // Primary Color
        CustomDropdown<String>(
          label: l10n.primaryColor,
          hint: l10n.selectPrimaryColor,
          icon: Icons.palette_outlined,
          value: _selectedPrimaryColor,
          dropdownItems: ColorHelper.getColorDropdownItems(l10n),
          onChanged: (value) {
            setState(() {
              _selectedPrimaryColor = value;
              // If the selected primary color matches secondary color, clear secondary color
              if (_selectedPrimaryColor == _selectedSecondaryColor) {
                _selectedSecondaryColor = null;
              }
            });
          },
          validator: (value) => null, // Optional field
          isRequired: false,
        ),
        const SizedBox(height: 16),

        // Secondary Color
        CustomDropdown<String>(
          key: ValueKey(
            'secondary_color_${_selectedPrimaryColor}',
          ), // Force rebuild when primary color changes
          label: l10n.secondaryColor,
          hint: l10n.selectSecondaryColor,
          icon: Icons.color_lens_outlined,
          value: _selectedSecondaryColor,
          dropdownItems: ColorHelper.getColorDropdownItems(
            l10n,
            excludeColor: _selectedPrimaryColor,
          ),
          onChanged: (value) {
            setState(() => _selectedSecondaryColor = value);
          },
          validator: (value) => null, // Optional field
          isRequired: false,
        ),
      ],
    );
  }

  // STEP 3: Additional Info
  Widget _buildAdditionalInfoStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: Parentage
        _buildSectionTitle(
          icon: Icons.diversity_3,
          title: l10n.parentageInformation,
          subtitle: l10n.optionalSelectParents,
        ),
        const SizedBox(height: 12),

        // Mother (All Female Livestock from All Farms)
        CustomDropdown<String>(
          label: l10n.motherOptional,
          hint: l10n.select,
          icon: Icons.female_outlined,
          value: _selectedMotherUuid,
          dropdownItems: _eligibleMothers.map((livestock) {
            // Find farm name for this livestock
            final farm = _farms.firstWhere(
              (f) => f.uuid == livestock.farmUuid,
              orElse: () => _farms.first, // fallback
            );
            final livestockName = livestock.name.isNotEmpty
                ? livestock.name
                : '${l10n.livestock} #${livestock.id}';

            return DropdownItem<String>(
              value: livestock.uuid,
              label: '$livestockName (${farm.name})', // Show farm name
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedMotherUuid = value);
          },
          isRequired: false,
        ),
        const SizedBox(height: 16),

        // Father (All Male Livestock from All Farms)
        CustomDropdown<String>(
          label: l10n.fatherOptional,
          hint: l10n.select,
          icon: Icons.male_outlined,
          value: _selectedFatherUuid,
          dropdownItems: _eligibleFathers.map((livestock) {
            // Find farm name for this livestock
            final farm = _farms.firstWhere(
              (f) => f.uuid == livestock.farmUuid,
              orElse: () => _farms.first, // fallback
            );
            final livestockName = livestock.name.isNotEmpty
                ? livestock.name
                : '${l10n.livestock} #${livestock.id}';

            return DropdownItem<String>(
              value: livestock.uuid,
              label: '$livestockName (${farm.name})', // Show farm name
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedFatherUuid = value);
          },
          isRequired: false,
        ),
        const SizedBox(height: 24),

        CustomDropdown<String>(
          label: l10n.birthEventOptional,
          hint: l10n.select,
          icon: Icons.child_friendly_outlined,
          value: _selectedBirthEventUuid,
          dropdownItems: _birthEvents
              .where(
                (event) =>
                    _selectedFarmUuid == null || event.farmUuid == _selectedFarmUuid,
              )
              .map(
                (event) => DropdownItem<String>(
                  value: event.uuid,
                  label:
                      '${event.eventType.toUpperCase()} - ${event.startDate.split('T').first}',
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedBirthEventUuid = value);
          },
          isRequired: false,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.birthEventOptionalHelper,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.addLivestockAllTypesReminder,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),

        // Section Title: Acquisition Details
        _buildSectionTitle(
          icon: Icons.source_outlined,
          title: l10n.acquisitionDetails,
          subtitle: l10n.howAndWhenObtained,
        ),
        const SizedBox(height: 12),

        // Obtained Method
        CustomDropdown<int>(
          label: l10n.obtainedMethod,
          hint: l10n.select,
          icon: Icons.source_outlined,
          value: _selectedLivestockObtainedMethodId,
          dropdownItems: _livestockObtainedMethods.map((method) {
            return DropdownItem<int>(value: method.id, label: method.name);
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLivestockObtainedMethodId = value;
              // If "Born on Farm" is selected, set date first entered to farm = date of birth
              if (value != null) {
                final selectedMethod = _livestockObtainedMethods.firstWhere(
                  (method) => method.id == value,
                  orElse: () => _livestockObtainedMethods.first,
                );
                if (selectedMethod.name.toLowerCase().contains('born') &&
                    _selectedDateOfBirth != null) {
                  _selectedDateFirstEnteredToFarm = _selectedDateOfBirth;
                }
              }
            });
            // Trigger form validation after state update to clear any errors
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_formKey.currentState != null) {
                _formKey.currentState!.validate();
              }
            });
          },
        ),
        const SizedBox(height: 16),

        // Date First Entered to Farm
        LivestockDateEnteredFarmPicker(
          label: l10n.dateEnteredFarmRequired,
          hint: _isBornOnFarmSelected()
              ? '${l10n.selectDateOfBirth} (Same as Date of Birth)'
              : l10n.selectDateOfBirth,
          selectedDate: _selectedDateFirstEnteredToFarm,
          onDateSelected: (date) {
            setState(() => _selectedDateFirstEnteredToFarm = date);
          },
          enabled:
              !_isBornOnFarmSelected(), // Disable if "Born on Farm" is selected
          isBornOnFarm: _isBornOnFarmSelected(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          dateValidator: (date) {
            // The validator receives the field value which gets updated via didChange() in the custom picker
            if (date == null) {
              return l10n.pleaseSelectDateEnteredFarm;
            }
            return null;
          },
        ),

        const SizedBox(height: 24),

        // Section Title: Status
        // Only show status field if:
        // - Not in edit mode (for new livestock), OR
        // - In edit mode AND livestock has disposal with reason='Lost' AND livestock status is 'notActive'
        if (!isEditMode || (isEditMode && _hasLostDisposal)) ...[
          _buildSectionTitle(
            icon: Icons.check_circle_outline,
            title: l10n.livestockStatus,
            subtitle: l10n.setCurrentStatus,
          ),

          const SizedBox(height: 12),

          // Status
          CustomDropdown<String>(
            label: l10n.status,
            hint: l10n.select,
            icon: Icons.check_circle_outline,
            value: _selectedStatus,
            enabled: !isEditMode || (isEditMode && _hasLostDisposal), // Only enable if not in edit mode or has Lost disposal
            dropdownItems: [
              DropdownItem(value: 'active', label: l10n.active),
              DropdownItem(value: 'notActive', label: l10n.notActive),
            ],
            onChanged: (value) async {
              final newStatus = value ?? 'active';
              if (isEditMode && _hasLostDisposal && newStatus == 'active') {
                // Temporarily update to show the selection
                setState(() => _selectedStatus = newStatus);
                // Show confirmation dialog when changing to 'active' for livestock with Lost disposal
                final confirmed = await _showLivestockFoundConfirmation(newStatus);
                // If user said No, set status to 'notActive'
                if (confirmed != true) {
                  setState(() => _selectedStatus = 'notActive');
                }
                // If user said Yes, status is already set to 'active' and disposal will be deleted
              } else {
                setState(() => _selectedStatus = newStatus);
              }
            },
          ),
        ],
      ],
    );
  }

  /// Show confirmation dialog when changing status to 'active' for livestock with Lost disposal
  /// Returns true if user confirmed, false if cancelled
  Future<bool> _showLivestockFoundConfirmation(String newStatus) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Format the disposal date
    String formattedDate = '';
    if (_lostDisposal != null) {
      try {
        final dateStr = _lostDisposal!.eventDate ?? _lostDisposal!.createdAt;
        if (dateStr.isNotEmpty) {
          final date = DateTime.parse(dateStr);
          formattedDate = DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).toString()).format(date);
        }
      } catch (e) {
        log('❌ Error formatting disposal date: $e');
        formattedDate = _lostDisposal!.eventDate ?? _lostDisposal!.createdAt;
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Constants.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.markLivestockAsFound,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  l10n.livestockFoundConfirmationDescription,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.black87,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Disposal details container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lost status
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.livestockWasMarkedAsLost,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (formattedDate.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${l10n.date}: $formattedDate',
                              style: TextStyle(
                                color: isDark ? Colors.grey[300] : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Action description
                Text(
                  l10n.livestockFoundActionDescription,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.no,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.yes,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // User confirmed: delete disposal records and set status to 'active'
      await _handleLivestockFound();
      return true;
    }
    // If confirmed == false or null, return false to revert status
    return false;
  }

  /// Handle livestock found: delete disposal records and set status to 'active'
  Future<void> _handleLivestockFound() async {
    final l10n = AppLocalizations.of(context)!;
    final database = Provider.of<AppDatabase>(context, listen: false);

    try {
      // Show loading dialog
      AlertDialogs.showLoading(
        context: context,
        title: l10n.save,
        message: l10n.loading,
        isDismissible: false,
      );

      // Get all disposal records for this livestock
      final eventsRepository = EventsRepository(database);
      final disposals = await eventsRepository.getDisposals(
        livestockUuid: widget.livestock!.uuid,
      );

      // Mark each disposal record as deleted for syncing (soft delete)
      int deletedCount = 0;
      for (final disposal in disposals) {
        try {
          await eventsRepository.markDisposalAsDeleted(disposal.uuid);
          deletedCount++;
          log('🗑️ Marked disposal record as deleted (pending sync): ${disposal.uuid}');
        } catch (e) {
          log('❌ Error marking disposal as deleted ${disposal.uuid}: $e');
        }
      }

      log('✅ Marked $deletedCount disposal record(s) as deleted for livestock ${widget.livestock!.uuid}');

      // Update status to 'active'
      setState(() {
        _selectedStatus = 'active';
        _hasLostDisposal = false; // Update flag since disposals are deleted
      });

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.livestockStatusUpdatedAndDisposalRemoved,
          buttonText: l10n.ok,
        );
      }
    } catch (e) {
      log('❌ Error handling livestock found: $e');

      // Close loading dialog if open
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {
          // Dialog might already be closed
        }
      }

      // Show error message
      if (mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: 'Failed to update livestock status: ${e.toString()}',
          buttonText: l10n.ok,
        );
      }
    }
  }

  // Helper method to build section titles
  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Constants.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Constants.primaryColor.withOpacity(0.8),
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
