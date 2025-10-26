import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/gps_location_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/provider/farm_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Modern Farm Registration Form Screen
/// 
/// A multi-step form for registering a new farm or updating an existing farm.
/// Uses the same design pattern as RegisterScreen for consistency.
class FarmFormScreen extends StatefulWidget {
  final Farm? farm; // Farm to edit (null for create mode)
  
  const FarmFormScreen({
    super.key,
    this.farm,
  });

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Check if we're in edit mode
  bool get isEditMode => widget.farm != null;
  
  // Controllers for Step 1: Basic Farm Information
  final _nameController = TextEditingController();
  final _regionalRegNoController = TextEditingController();
  
  // Controllers for Step 2: Farm Size & Measurements
  final _sizeController = TextEditingController();
  final _latitudesController = TextEditingController();
  final _longitudesController = TextEditingController();
  
  // Controllers for Step 3: Address Information
  final _physicalAddressController = TextEditingController();
  
  // Form field values
  String? _selectedSizeUnit;
  int? _selectedLegalStatusId;
  int? _selectedCountryId;
  int? _selectedRegionId;
  int? _selectedDistrictId;
  int? _selectedWardId;
  int? _selectedVillageId;
  
  // Local data from database
  List<Country> _countries = [];
  List<Region> _regions = [];
  List<District> _districts = [];
  List<Ward> _wards = [];
  List<Village> _villages = [];
  List<LegalStatus> _legalStatuses = [];
  
  bool _isLoadingData = true;
  bool _hasLoadedData = false;
  
  @override
  void initState() {
    super.initState();
    debugPrint('🔍 FarmFormScreen initState - farm: ${widget.farm?.name ?? "null"}');
    debugPrint('🔍 isEditMode: $isEditMode');
    // Pre-fill form if editing existing farm
    if (isEditMode) {
      _prefillFormData();
    }
    // Note: Cannot access Provider here - will load in didChangeDependencies
  }
  
  /// Pre-fill form with existing farm data
  void _prefillFormData() {
    final farm = widget.farm!;
    
    _nameController.text = farm.name;
    _regionalRegNoController.text = farm.regionalRegNo;
    _sizeController.text = farm.size.toString();
    _latitudesController.text = farm.latitudes.toString();
    _longitudesController.text = farm.longitudes.toString();
    _physicalAddressController.text = farm.physicalAddress;
    
    _selectedSizeUnit = farm.sizeUnit;
    _selectedLegalStatusId = farm.legalStatusId;
    _selectedCountryId = farm.countryId;
    _selectedRegionId = farm.regionId;
    _selectedDistrictId = farm.districtId;
    _selectedWardId = farm.wardId;
    _selectedVillageId = farm.villageId;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data only once when dependencies are ready
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      _loadDataFromDatabase();
    }
  }
  
  Future<void> _loadDataFromDatabase() async {
    setState(() => _isLoadingData = true);
    
    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      
      // Load all location data and reference data from local database
      final countries = await database.locationDao.getAllCountries();
      final regions = await database.locationDao.getAllRegions();
      final districts = await database.locationDao.getAllDistricts();
      final wards = await database.locationDao.getAllWards();
      final villages = await database.locationDao.getAllVillages();
      final legalStatuses = await database.referenceDataDao.getAllLegalStatuses();
      
      setState(() {
        _countries = countries;
        _regions = regions;
        _districts = districts;
        _wards = wards;
        _villages = villages;
        _legalStatuses = legalStatuses;
        _isLoadingData = false;
      });
    } catch (e) {
      debugPrint('Error loading data from database: $e');
      setState(() => _isLoadingData = false);
      
      // Show error after build completes
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load location data: ${e.toString()}'),
                backgroundColor: Constants.dangerColor,
              ),
            );
          }
        });
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _regionalRegNoController.dispose();
    _sizeController.dispose();
    _latitudesController.dispose();
    _longitudesController.dispose();
    _physicalAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    // Debug: Check edit mode and button text
    debugPrint('🔍 Edit Mode: $isEditMode, Current Step: $_currentStep');
    final buttonText = _currentStep == 2 
      ? (isEditMode ? l10n.update : l10n.register)
      : l10n.continueButton;
    debugPrint('🔍 Button Text: $buttonText');

    return Scaffold(
      backgroundColor: Constants.veryLightGreyColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,  // Dark icons for light background
          statusBarBrightness: Brightness.light,     // iOS: light status bar
        ),
        leading: CustomBackButton(
          isEnabledBgColor: false,
          iconColor: Theme.of(context).colorScheme.tertiary,
          iconSize: 24,
        ),
        title: Text(
          isEditMode ? '${l10n.edit} ${l10n.farm}': l10n.registerNewFarm,
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
                  isLoading: false, // Loading handled by provider dialogs
                  continueButtonText: buttonText,
                  backButtonText: l10n.back,
                  steps: [
                    StepperStep(
                      title: l10n.basicInformation,
                      subtitle: l10n.farmNameReferenceDetails,
                      icon: Icons.agriculture_outlined,
                      content: _buildBasicInfoStep(l10n),
                    ),
                    StepperStep(
                      title: l10n.sizeMeasurements,
                      subtitle: l10n.farmMeasurementsCoordinates,
                      icon: Icons.straighten_outlined,
                      content: _buildSizeMeasurementsStep(l10n),
                    ),
                    StepperStep(
                      title: l10n.addressLegal,
                      subtitle: l10n.physicalLocationLegalStatus,
                      icon: Icons.location_on_outlined,
                      content: _buildAddressLegalStep(l10n),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
  
  // Step 1: Basic Farm Information
  Widget _buildBasicInfoStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.farmDetails),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _nameController,
          label: l10n.farmName,
          hintText: l10n.enterFarmName,
          prefixIcon: Icons.home_work_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.farmNameRequired;
            }
            if (value.length < 3) {
              return l10n.farmNameMinLength;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _regionalRegNoController,
          label: l10n.regionalRegistrationNumber,
          hintText: l10n.enterRegionalRegNumber,
          prefixIcon: Icons.numbers_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.regionalRegNumberRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        Container(
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
                Icons.info_outline,
                color: Constants.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.ensureReferenceAccuracy,
                  style: TextStyle(
                    fontSize: Constants.textSize,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Step 2: Size & Measurements
  Widget _buildSizeMeasurementsStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.farmMeasurements),
        const SizedBox(height: 20),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                controller: _sizeController,
                label: l10n.farmSize,
                hintText: l10n.enterSize,
                prefixIcon: Icons.square_foot_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.sizeRequired;
                  }
                  if (double.tryParse(value) == null) {
                    return l10n.enterValidNumber;
                  }
                  if (double.parse(value) <= 0) {
                    return l10n.sizeMustBePositive;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown<String>(
                value: _selectedSizeUnit,
                label: l10n.unit,
                hint: l10n.selectUnit,
                icon: Icons.straighten_outlined,
                dropdownItems: _getSizeUnitItems(l10n),
                onChanged: (value) => setState(() => _selectedSizeUnit = value),
                validator: (value) {
                  if (value == null) {
                    return l10n.unitRequired;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        
        _buildSectionTitle(l10n.gpsCoordinates),

        const SizedBox(height: 20),
            
        GpsLocationButton(
          onLocationFetched: (latitude, longitude) {
            setState(() {
              _latitudesController.text = latitude.toStringAsFixed(6);
              _longitudesController.text = longitude.toStringAsFixed(6);
            });
          },
        ),

        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _latitudesController,
          label: l10n.latitude,
          hintText: l10n.latitudeExample,
          prefixIcon: Icons.my_location_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.latitudeRequired;
            }
            final lat = double.tryParse(value);
            if (lat == null) {
              return l10n.enterValidLatitude;
            }
            if (lat < -90 || lat > 90) {
              return l10n.latitudeRange;
            }
            return null;
          },
        ),

        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _longitudesController,
          label: l10n.longitude,
          hintText: l10n.longitudeExample,
          prefixIcon: Icons.explore_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.longitudeRequired;
            }
            final lng = double.tryParse(value);
            if (lng == null) {
              return l10n.enterValidLongitude;
            }
            if (lng < -180 || lng > 180) {
              return l10n.longitudeRange;
            }
            return null;
          },
        ),
    
      ],
    );
  }
  
  // Step 3: Address & Legal Information
  Widget _buildAddressLegalStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.physicalAddress),
        const SizedBox(height: 20),
        
        CustomTextField(
          controller: _physicalAddressController,
          label: l10n.physicalAddress,
          hintText: l10n.enterPhysicalAddress,
          prefixIcon: Icons.home_outlined,
          maxLines: 1,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.physicalAddressRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        _buildSectionTitle(l10n.locationDetails),
        const SizedBox(height: 16),
        
        // Country Dropdown
        CustomDropdown<int>(
          value: _selectedCountryId,
          label: l10n.country,
          hint: l10n.selectCountry,
          icon: Icons.public_outlined,
          items: _countries.map((c) => c.id).toList(),
          itemLabels: _countries.map((c) => c.name).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCountryId = value;
              _selectedRegionId = null;
              _selectedDistrictId = null;
              _selectedWardId = null;
              _selectedVillageId = null;
            });
          },
          validator: (value) {
            if (value == null) {
              return l10n.countryRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Region Dropdown
        CustomDropdown<int>(
          value: _selectedRegionId,
          label: l10n.region,
          hint: l10n.selectRegion,
          icon: Icons.map_outlined,
          items: _selectedCountryId != null 
              ? _regions.where((r) => r.countryId == _selectedCountryId).map((r) => r.id).toList()
              : [],
          itemLabels: _selectedCountryId != null
              ? _regions.where((r) => r.countryId == _selectedCountryId).map((r) => r.name).toList()
              : [],
          onChanged: (value) {
            setState(() {
              _selectedRegionId = value;
              _selectedDistrictId = null;
              _selectedWardId = null;
              _selectedVillageId = null;
            });
          },
          validator: (value) {
            if (value == null) {
              return l10n.regionRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // District Dropdown
        CustomDropdown<int>(
          value: _selectedDistrictId,
          label: l10n.district,
          hint: l10n.selectDistrict,
          icon: Icons.location_city_outlined,
          items: _selectedRegionId != null
              ? _districts.where((d) => d.regionId == _selectedRegionId).map((d) => d.id).toList()
              : [],
          itemLabels: _selectedRegionId != null
              ? _districts.where((d) => d.regionId == _selectedRegionId).map((d) => d.name).toList()
              : [],
          onChanged: (value) {
            setState(() {
              _selectedDistrictId = value;
              _selectedWardId = null;
              _selectedVillageId = null;
            });
          },
          validator: (value) {
            if (value == null) {
              return l10n.districtRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Ward Dropdown
        CustomDropdown<int>(
          value: _selectedWardId,
          label: l10n.ward,
          hint: l10n.selectWard,
          icon: Icons.place_outlined,
          items: _selectedDistrictId != null
              ? _wards.where((w) => w.districtId == _selectedDistrictId).map((w) => w.id).toList()
              : [],
          itemLabels: _selectedDistrictId != null
              ? _wards.where((w) => w.districtId == _selectedDistrictId).map((w) => w.name).toList()
              : [],
          onChanged: (value) {
            setState(() {
              _selectedWardId = value;
              _selectedVillageId = null;
            });
          },
          validator: (value) {
            if (value == null) {
              return l10n.wardRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Village Dropdown (Optional)
        CustomDropdown<int>(
          value: _selectedVillageId,
          label: '${l10n.village} (${l10n.optional})',
          hint: l10n.selectVillage,
          icon: Icons.home_work_outlined,
          items: _selectedWardId != null
              ? _villages.where((v) => v.wardId == _selectedWardId).map((v) => v.id).toList()
              : [],
          itemLabels: _selectedWardId != null
              ? _villages.where((v) => v.wardId == _selectedWardId).map((v) => v.name).toList()
              : [],
          onChanged: (value) => setState(() => _selectedVillageId = value),
          // No validator - field is optional
        ),
        const SizedBox(height: 20),
        
        _buildSectionTitle(l10n.legalInformation),
        const SizedBox(height: 16),
        
        // Legal Status Dropdown
        CustomDropdown<int>(
          value: _selectedLegalStatusId,
          label: l10n.legalStatus,
          hint: l10n.selectLegalStatus,
          icon: Icons.gavel_outlined,
          items: _legalStatuses.map((s) => s.id).toList(),
          itemLabels: _legalStatuses.map((s) => s.name).toList(),
          onChanged: (value) => setState(() => _selectedLegalStatusId = value),
          validator: (value) {
            if (value == null) {
              return l10n.legalStatusRequired;
            }
            return null;
          },
        ),
        
        const SizedBox(height: 24),
        
        Container(
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
                Icons.check_circle_outline,
                color: Constants.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.reviewBeforeSubmit,
                  style: TextStyle(
                    fontSize: Constants.textSize,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Reusable widget builders
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Constants.largeTextSize,
        fontWeight: FontWeight.bold,
        color: Constants.primaryColor,
      ),
    );
  }
  
  /// Get size unit dropdown items with localized labels and API enum values
  /// 
  /// Returns list of items where:
  /// - value: API enum (e.g., 'acre', 'hectare') - stored in database
  /// - label: Localized text (e.g., 'Acres', 'Ekari') - shown to user
  List<DropdownItem<String>> _getSizeUnitItems(AppLocalizations l10n) {
    return [
      DropdownItem(value: 'acre', label: l10n.acres),
      DropdownItem(value: 'hectare', label: l10n.hectares),
      DropdownItem(value: 'square_meter', label: l10n.squareMeters),
      DropdownItem(value: 'square_kilometer', label: l10n.squareKilometers),
    ];
  }
  
  // Step navigation logic
  void _onStepContinue() async {
    if (_currentStep < 2) {
      // Validate current step using form validation
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else {
      // Final step - validate and show confirmation dialog
      if (_formKey.currentState!.validate()) {
        final l10n = AppLocalizations.of(context)!;
        
        // Show confirmation dialog
        await AlertDialogs.showConfirmation(
          context: context,
          title: isEditMode ? l10n.update : l10n.register,
          message: isEditMode ? l10n.confirmUpdateFarm : l10n.confirmRegisterFarm,
          confirmText: isEditMode ? l10n.update : l10n.register,
          cancelText: l10n.cancel,
          onConfirm: () async {
            Navigator.of(context).pop(true);
            await _submitFarmRegistration();
          },
        );
      }
    }
  }
  
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }
  
  Future<void> _submitFarmRegistration() async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      // Generate simple UUID (timestamp-based)
      final uuid = '${DateTime.now().millisecondsSinceEpoch}-${_nameController.text.hashCode}';
      
      // Generate Reference Number: REF-{timestamp}{random}
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (timestamp % 999999).toString().padLeft(6, '0');
      final referenceNo = 'REF-$timestamp-$random';
      
      // Prepare farm data
      final farmData = {
        'uuid': uuid,
        'name': _nameController.text,
        'referenceNo': referenceNo,
        'regionalRegNo': _regionalRegNoController.text,
        'size': _sizeController.text.trim(),  // Send as String (matches backend varchar)
        'sizeUnit': _selectedSizeUnit,  // Already stores API enum: 'acre', 'hectare', 'square_meter', 'square_kilometer'
        'latitudes': _latitudesController.text.trim(),  // Send as String (matches backend varchar)
        'longitudes': _longitudesController.text.trim(),  // Send as String (matches backend varchar)
        'physicalAddress': _physicalAddressController.text,
        'countryId': _selectedCountryId,
        'regionId': _selectedRegionId,
        'districtId': _selectedDistrictId,
        'wardId': _selectedWardId,
        'villageId': _selectedVillageId,
        'legalStatusId': _selectedLegalStatusId,
        'status': 'active',
      };

      // Save to local database via FarmProvider
      if (!mounted) return;
      
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      
      if (isEditMode) {
        // Update existing farm
        final updatedFarm = await farmProvider.updateFarmWithoutDialog(
          widget.farm!.id,
          farmData,
          syncAction: 'update',
          synced: false,
        );
        
        if (updatedFarm != null) {
          debugPrint('✅ Farm updated locally: ${updatedFarm.name} (ID: ${updatedFarm.id})');
          
          // Show success dialog
          await AlertDialogs.showSuccess(
            context: context,
            title: l10n.success,
            message: l10n.farmUpdatedSuccessfully,
            buttonText: l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
          );
          
          // Navigate back after success dialog is dismissed
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          // Show error dialog
          await AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message: l10n.farmUpdateFailed,
            buttonText: l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
          );
        }
      } else {
        // Create new farm
        final createdFarm = await farmProvider.createFarmWithDialog(context, farmData);
        
        // Success/error dialogs are already shown by the provider
        if (createdFarm != null) {
          debugPrint('✅ Farm saved locally: ${createdFarm.name} (ID: ${createdFarm.id})');
          debugPrint('Farm details: uuid: ${createdFarm.uuid}, size: ${createdFarm.size}, status: ${createdFarm.status}');
          
          // Navigate back after success dialog is dismissed
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error saving farm: $e');
      // Error dialog is already shown by the provider
    }
  }
}
