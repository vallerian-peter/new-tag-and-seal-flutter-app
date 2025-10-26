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
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:developer';

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

  // Form field values
  String? _selectedFarmUuid;
  int? _selectedLivestockTypeId;
  int? _selectedSpeciesId;
  int? _selectedBreedId;
  String? _selectedGender;
  int? _selectedLivestockObtainedMethodId;
  String? _selectedMotherUuid;
  String? _selectedFatherUuid;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedDateFirstEnteredToFarm;
  String _selectedStatus = 'active';

  // Local data
  List<Farm> _farms = [];
  List<LivestockType> _livestockTypes = [];
  List<Specie> _species = [];
  List<Breed> _breeds = [];
  List<Breed> _filteredBreeds = [];
  List<LivestockObtainedMethod> _livestockObtainedMethods = [];
  List<Livestock> _eligibleMothers = [];
  List<Livestock> _eligibleFathers = [];

  bool _isLoadingData = true;
  bool _hasLoadedData = false;

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
  }

  /// Pre-fill form with existing livestock data
  void _prefillFormData() {
    final livestock = widget.livestock!;

    _nameController.text = livestock.name;
    _identificationNumberController.text = livestock.identificationNumber;
    _dummyTagIdController.text = livestock.dummyTagId;
    _barcodeTagIdController.text = livestock.barcodeTagId;
    _rfidTagIdController.text = livestock.rfidTagId;
    _weightController.text = livestock.weightAsOnRegistration.toString();

    _selectedFarmUuid = livestock.farmUuid;
    _selectedLivestockTypeId = livestock.livestockTypeId;
    _selectedSpeciesId = livestock.speciesId;
    _selectedBreedId = livestock.breedId;
    _selectedGender = livestock.gender;
    _selectedLivestockObtainedMethodId = livestock.livestockObtainedMethodId;
    _selectedMotherUuid = livestock.motherUuid;
    _selectedFatherUuid = livestock.fatherUuid;
    _selectedDateOfBirth = DateTime.parse(livestock.dateOfBirth);
    _selectedDateFirstEnteredToFarm = livestock.dateFirstEnteredToFarm;
    _selectedStatus = livestock.status;

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
      final livestockTypes = await database.livestockTypeDao.getAllLivestockTypes();
      final species = await database.specieDao.getAllSpecies();
      final breeds = await database.breedDao.getAllBreeds();
      final methods = await database.livestockObtainedMethodDao.getAllLivestockObtainedMethods();
      final allLivestock = await database.livestockDao.getAllLivestock();

      setState(() {
        _farms = farms;
        _livestockTypes = livestockTypes;
        _species = species;
        _breeds = breeds;
        _livestockObtainedMethods = methods;
        
        // Load eligible mothers (all female livestock, excluding current if editing)
        _eligibleMothers = allLivestock
            .where((l) => l.gender.toLowerCase() == 'female')
            .where((l) => isEditMode ? l.uuid != widget.livestock!.uuid : true) // Exclude self
            .toList();
        
        // Load eligible fathers (all male livestock, excluding current if editing)
        _eligibleFathers = allLivestock
            .where((l) => l.gender.toLowerCase() == 'male')
            .where((l) => isEditMode ? l.uuid != widget.livestock!.uuid : true) // Exclude self
            .toList();
        
        // Filter breeds immediately if livestock type is already selected (edit mode)
        if (_selectedLivestockTypeId != null) {
          _filteredBreeds = breeds.where((breed) => breed.livestockTypeId == _selectedLivestockTypeId).toList();
          log('✅ Filtered ${_filteredBreeds.length} breeds for type $_selectedLivestockTypeId');
        } else {
          _filteredBreeds = breeds;
        }
        
        _isLoadingData = false;
      });

      log('✅ Data loaded: ${_farms.length} farms, ${_livestockTypes.length} types, ${_species.length} species');
      log('✅ Eligible mothers: ${_eligibleMothers.length} (all females from all farms)');
      log('✅ Eligible fathers: ${_eligibleFathers.length} (all males from all farms)');
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
    if (_selectedLivestockTypeId == null) return;

    setState(() {
      _filteredBreeds = _breeds.where((breed) => breed.livestockTypeId == _selectedLivestockTypeId).toList();

      // Reset breed if not valid for current type
      if (_selectedBreedId != null) {
        final isValid = _filteredBreeds.any((b) => b.id == _selectedBreedId);
        if (!isValid) {
          _selectedBreedId = null;
        }
      }
    });
    log('✅ Filtered ${_filteredBreeds.length} breeds for type $_selectedLivestockTypeId');
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

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      final now = DateTime.now().toIso8601String();
      
      // Generate UUID if creating new livestock
      final uuid = widget.livestock?.uuid ?? 
          '${DateTime.now().millisecondsSinceEpoch}-${_nameController.text.hashCode.abs()}';

      // Get species ID from selected livestock type (they should match)
      final selectedSpeciesId = _selectedSpeciesId ?? _selectedLivestockTypeId!;

      if (isEditMode) {
        // Update existing livestock
        final updatedLivestock = Livestock(
          id: widget.livestock!.id,
          farmUuid: _selectedFarmUuid!,
          uuid: widget.livestock!.uuid,
          identificationNumber: _identificationNumberController.text.trim(),
          dummyTagId: _dummyTagIdController.text.trim(),
          barcodeTagId: _barcodeTagIdController.text.trim(),
          rfidTagId: _rfidTagIdController.text.trim(),
          livestockTypeId: _selectedLivestockTypeId!,
          name: _nameController.text.trim(),
          dateOfBirth: _selectedDateOfBirth!.toIso8601String().split('T')[0],
          motherUuid: _selectedMotherUuid,
          fatherUuid: _selectedFatherUuid,
          gender: _selectedGender!,
          breedId: _selectedBreedId!,
          speciesId: selectedSpeciesId,
          status: _selectedStatus,
          livestockObtainedMethodId: _selectedLivestockObtainedMethodId ?? 1,
          dateFirstEnteredToFarm: _selectedDateFirstEnteredToFarm!,
          weightAsOnRegistration: double.parse(_weightController.text.trim()),
          synced: false,
          syncAction: 'update',
          createdAt: widget.livestock!.createdAt,
          updatedAt: now,
        );

        await database.livestockDao.updateLivestock(updatedLivestock);
        log('✅ Livestock updated: ${updatedLivestock.name}');

        // Show success dialog
        if (!mounted) return;
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.livestockUpdatedSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );

        // Navigate back
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        // Create new livestock
        final livestockId = await database.livestockDao.insertLivestock(
          LivestocksCompanion.insert(
            farmUuid: _selectedFarmUuid!,
            uuid: uuid,
            identificationNumber: _identificationNumberController.text.trim(),
            dummyTagId: _dummyTagIdController.text.trim(),
            barcodeTagId: _barcodeTagIdController.text.trim(),
            rfidTagId: _rfidTagIdController.text.trim(),
            livestockTypeId: _selectedLivestockTypeId!,
            name: _nameController.text.trim(),
            dateOfBirth: _selectedDateOfBirth!.toIso8601String().split('T')[0],
            motherUuid: drift.Value(_selectedMotherUuid),
            fatherUuid: drift.Value(_selectedFatherUuid),
            gender: _selectedGender!,
            breedId: _selectedBreedId!,
            speciesId: selectedSpeciesId,
            status: drift.Value(_selectedStatus),
            livestockObtainedMethodId: _selectedLivestockObtainedMethodId ?? 1,
            dateFirstEnteredToFarm: _selectedDateFirstEnteredToFarm!,
            weightAsOnRegistration: double.parse(_weightController.text.trim()),
            synced: const drift.Value(false),
            syncAction: const drift.Value('create'),
            createdAt: now,
            updatedAt: now,
          ),
        );
        log('✅ Livestock registered: ${_nameController.text} (ID: $livestockId)');

        // Show success dialog
        if (!mounted) return;
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.livestockRegisteredSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );

        // Navigate back
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      log('❌ Error saving livestock: $e');
      
      // Show error dialog
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: '${l10n.failedToSaveLivestock}: ${e.toString()}',
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
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
              child: SingleChildScrollView(
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
            return DropdownItem<String>(
              value: farm.uuid,
              label: farm.name,
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedFarmUuid = value);
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
          label: '${l10n.livestock} ${l10n.name}',
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
          label: l10n.identificationNumber,
          hintText: l10n.enterIdentificationNumber,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.identificationNumberRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

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
        ),
        const SizedBox(height: 16),

        // Barcode Tag ID
        CustomTextField(
          controller: _barcodeTagIdController,
          label: l10n.barcodeTagId,
          hintText: l10n.enterBarcodeTagId,
        ),
        const SizedBox(height: 16),

        // RFID Tag ID
        CustomTextField(
          controller: _rfidTagIdController,
          label: l10n.rfidTagId,
          hintText: l10n.enterRfidTagId,
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
            return DropdownItem<int>(
              value: type.id,
              label: type.name,
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLivestockTypeId = value;
              _filterBreedsByLivestockType();
            });
          },
          validator: (value) {
            if (value == null) {
              return l10n.livestockTypeRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Species (Separate from Livestock Type)
        CustomDropdown<int>(
          label: l10n.species,
          hint: l10n.select,
          icon: Icons.pets_outlined,
          value: _selectedSpeciesId,
          dropdownItems: _species.map((species) {
            return DropdownItem<int>(
              value: species.id,
              label: species.name,
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedSpeciesId = value);
          },
          validator: (value) {
            if (value == null) {
              return l10n.speciesRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Breed (Filtered by Livestock Type)
        CustomDropdown<int>(
          key: ValueKey('breed_dropdown_${_selectedLivestockTypeId}_${_filteredBreeds.length}'), // Force rebuild when breeds change
          label: l10n.breed,
          hint: l10n.select,
          icon: Icons.menu_book_outlined,
          value: _selectedBreedId,
          dropdownItems: _filteredBreeds.map((breed) {
            return DropdownItem<int>(
              value: breed.id,
              label: breed.name,
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedBreedId = value);
          },
          validator: (value) {
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

        // Weight with Bluetooth
        WeightInputWithBluetooth(
          controller: _weightController,
          label: l10n.weightKg,
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
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDateOfBirth ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Constants.primaryColor, // header background color
                      onPrimary: Colors.white, // header text color
                      onSurface: Colors.black, // body text color
                    ),
                    dialogBackgroundColor: Colors.white,
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Constants.primaryColor, // button text color
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() => _selectedDateOfBirth = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDateOfBirth != null
                      ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                      : l10n.dateOfBirthRequired,
                  style: TextStyle(
                    color: _selectedDateOfBirth != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Constants.primaryColor),
              ],
            ),
          ),
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
            return DropdownItem<int>(
              value: method.id,
              label: method.name,
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedLivestockObtainedMethodId = value);
          },
        ),
        const SizedBox(height: 16),

        // Date First Entered to Farm
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDateFirstEnteredToFarm ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Constants.primaryColor, // header background color
                      onPrimary: Colors.white, // header text color
                      onSurface: Colors.black, // body text color
                    ),
                    dialogBackgroundColor: Colors.white,
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Constants.primaryColor, // button text color
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() => _selectedDateFirstEnteredToFarm = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDateFirstEnteredToFarm != null
                      ? '${_selectedDateFirstEnteredToFarm!.day}/${_selectedDateFirstEnteredToFarm!.month}/${_selectedDateFirstEnteredToFarm!.year}'
                      : l10n.dateEnteredFarmRequired,
                  style: TextStyle(
                    color: _selectedDateFirstEnteredToFarm != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Constants.primaryColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Section Title: Status
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
          dropdownItems: [
            DropdownItem(value: 'active', label: l10n.active),
            DropdownItem(value: 'notActive', label: l10n.notActive),
          ],
          onChanged: (value) {
            setState(() => _selectedStatus = value ?? 'active');
          },
        ),
      ],
    );
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
        color: Constants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Constants.primaryColor.withOpacity(0.3),
          width: 1,
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

