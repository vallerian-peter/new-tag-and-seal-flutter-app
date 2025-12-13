import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_date_picker.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/provider/all.additional.data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = const FlutterSecureStorage();

  // Controllers for Personal Information
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  // Controllers for Contact Information
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _physicalAddressController = TextEditingController();

  // Controllers for Identity Information
  final _identityNumberController = TextEditingController();

  // Controllers for Additional Information
  final _farmerOrganizationController = TextEditingController();

  // Form field values
  String? _selectedGender;
  String? _selectedFarmerType;
  int? _selectedIdentityCardTypeId;
  int? _selectedSchoolLevelId;
  int? _selectedCountryId;
  int? _selectedRegionId;
  int? _selectedDistrictId;
  int? _selectedWardId;
  int? _selectedVillageId;
  int? _selectedStreetId;

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _loadLocationsIfNeeded();
    });
  }

  Future<void> _loadLocationsIfNeeded() async {
    final additionalDataProvider = Provider.of<AdditionalDataProvider>(
      context,
      listen: false,
    );

    if (!additionalDataProvider.hasLocationData &&
        !additionalDataProvider.isLoadingLocations) {
      additionalDataProvider.clearLocationError();
      await additionalDataProvider.fetchLocationsWithDialogs(context);
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Load profile data from secure storage
      final profileJson = await _secureStorage.read(key: 'profile');
      final firstname = await _secureStorage.read(key: 'firstname') ?? '';
      final surname = await _secureStorage.read(key: 'surname') ?? '';
      final email = await _secureStorage.read(key: 'email') ?? '';
      final phone1 = await _secureStorage.read(key: 'phone1') ?? '';
      final phone2 = await _secureStorage.read(key: 'phone2') ?? '';
      final physicalAddress = await _secureStorage.read(key: 'physicalAddress') ?? '';
      final dateOfBirth = await _secureStorage.read(key: 'dateOfBirth') ?? '';
      final gender = await _secureStorage.read(key: 'gender') ?? '';

      // Parse profile JSON if available
      Map<String, dynamic>? profileData;
      if (profileJson != null && profileJson.isNotEmpty) {
        try {
          profileData = Map<String, dynamic>.from(
            // Parse JSON string
            profileJson.startsWith('{') 
              ? jsonDecode(profileJson) 
              : {}
          );
        } catch (e) {
          log('Error parsing profile JSON: $e');
        }
      }

      // Populate form fields with current data
      if (mounted) {
        setState(() {
          _firstNameController.text = firstname;
          _surnameController.text = surname;
          _emailController.text = email;
          _phone1Controller.text = phone1;
          _phone2Controller.text = phone2;
          _physicalAddressController.text = physicalAddress;
          _dateOfBirthController.text = dateOfBirth;
          _selectedGender = gender.isNotEmpty ? gender.toLowerCase() : null;

          // Load from profile if available
          if (profileData != null) {
            _middleNameController.text = profileData['middleName']?.toString() ?? '';
            _identityNumberController.text = profileData['identityNumber']?.toString() ?? '';
            _farmerOrganizationController.text = profileData['farmerOrganizationMembership']?.toString() ?? '';
            _selectedFarmerType = profileData['farmerType']?.toString().toLowerCase();
            _selectedIdentityCardTypeId = profileData['identityCardTypeId'] as int?;
            _selectedSchoolLevelId = profileData['schoolLevelId'] as int?;
            _selectedCountryId = profileData['countryId'] as int?;
            _selectedRegionId = profileData['regionId'] as int?;
            _selectedDistrictId = profileData['districtId'] as int?;
            _selectedWardId = profileData['wardId'] as int?;
            _selectedVillageId = profileData['villageId'] as int?;
            _selectedStreetId = profileData['streetId'] as int?;
          }

          _isLoadingData = false;
        });
      }
    } catch (e) {
      log('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _surnameController.dispose();
    _dateOfBirthController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _emailController.dispose();
    _physicalAddressController.dispose();
    _identityNumberController.dispose();
    _farmerOrganizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomBackButton(
          isEnabledBgColor: false,
          iconColor: theme.colorScheme.onSurface,
          iconSize: 24,
        ),
        title: Text(
          l10n.editProfile,
          style: TextStyle(
            fontSize: Constants.largeTextSize,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AdditionalDataProvider>(
        builder: (context, additionalDataProvider, child) {
          if (_isLoadingData || additionalDataProvider.isLoadingLocations) {
            return const Center(child: LoadingIndicator());
          }

          if (additionalDataProvider.locationError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Constants.dangerColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.networkError,
                      style: TextStyle(
                        fontSize: Constants.largeTextSize,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      additionalDataProvider.locationError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Constants.textSize,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _loadLocationsIfNeeded(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.tryAgain),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!additionalDataProvider.hasLocationData) {
            return const Center(child: LoadingIndicator());
          }

          return SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    _buildSectionTitle(l10n.personalInformation),
                    const SizedBox(height: 20),
                    _buildPersonalInfoFields(l10n),
                    
                    const SizedBox(height: 32),
                    
                    // Contact Information Section
                    _buildSectionTitle(l10n.contactDetails),
                    const SizedBox(height: 20),
                    _buildContactInfoFields(l10n),
                    
                    const SizedBox(height: 32),
                    
                    // Identity Information Section
                    _buildSectionTitle(l10n.identityCardType),
                    const SizedBox(height: 20),
                    _buildIdentityInfoFields(l10n, additionalDataProvider),
                    
                    const SizedBox(height: 32),
                    
                    // Location Information Section
                    _buildSectionTitle(l10n.addressInformation),
                    const SizedBox(height: 20),
                    _buildLocationInfoFields(l10n, additionalDataProvider),
                    
                    const SizedBox(height: 32),
                    
                    // Additional Information Section
                    _buildSectionTitle(l10n.additionalDetails),
                    const SizedBox(height: 20),
                    _buildAdditionalInfoFields(l10n),
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: _isLoading ? l10n.loading : l10n.save,
                        color: Constants.primaryColor,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _handleSave,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildPersonalInfoFields(AppLocalizations l10n) {
    return Column(
      children: [
        CustomTextField(
          controller: _firstNameController,
          label: l10n.firstName,
          hintText: l10n.enterFirstName,
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.firstNameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _middleNameController,
          label: l10n.middleName,
          hintText: l10n.enterMiddleName,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _surnameController,
          label: l10n.surname,
          hintText: l10n.enterSurname,
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.surnameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDatePicker(
          controller: _dateOfBirthController,
          label: l10n.dateOfBirth,
          hint: l10n.selectDateOfBirth,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.dateOfBirthRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          value: _selectedGender,
          label: l10n.gender,
          hint: l10n.selectGender,
          icon: Icons.wc_outlined,
          dropdownItems: [
            DropdownItem(value: 'male', label: l10n.male),
            DropdownItem(value: 'female', label: l10n.female),
          ],
          onChanged: (value) => setState(() => _selectedGender = value),
          validator: (value) {
            if (value == null) {
              return l10n.genderRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactInfoFields(AppLocalizations l10n) {
    return Column(
      children: [
        CustomTextField(
          controller: _phone1Controller,
          label: l10n.phone1,
          hintText: l10n.enterPhoneNumber,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.phoneRequired;
            }
            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
              return l10n.validPhoneRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phone2Controller,
          label: '${l10n.phone2} (${l10n.optional})',
          hintText: l10n.enterAlternatePhone,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: l10n.email,
          hintText: l10n.enterEmail,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          enabled: false, // Email should not be editable
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.emailRequired;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return l10n.validEmailRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _physicalAddressController,
          label: l10n.physicalAddress,
          hintText: l10n.enterPhysicalAddress,
          prefixIcon: Icons.home_outlined,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.physicalAddressRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildIdentityInfoFields(
    AppLocalizations l10n,
    AdditionalDataProvider additionalDataProvider,
  ) {
    return Column(
      children: [
        CustomDropdown<int>(
          value: _selectedIdentityCardTypeId,
          label: l10n.identityCardType,
          hint: l10n.selectIdType,
          icon: Icons.badge_outlined,
          items: additionalDataProvider.identityCardTypes
              .map((t) => t.id)
              .toList(),
          itemLabels: additionalDataProvider.identityCardTypes
              .map((t) => t.name)
              .toList(),
          onChanged: (value) =>
              setState(() => _selectedIdentityCardTypeId = value),
          validator: (value) {
            if (value == null) {
              return l10n.identityTypeRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _identityNumberController,
          label: l10n.identityNumber,
          hintText: l10n.enterIdNumber,
          prefixIcon: Icons.numbers_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.identityNumberRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          value: _selectedSchoolLevelId,
          label: l10n.schoolLevel,
          hint: l10n.selectEducationLevel,
          icon: Icons.school_outlined,
          items: additionalDataProvider.schoolLevels.map((s) => s.id).toList(),
          itemLabels: additionalDataProvider.schoolLevels
              .map((s) => s.name)
              .toList(),
          onChanged: (value) => setState(() => _selectedSchoolLevelId = value),
          validator: (value) {
            if (value == null) {
              return l10n.educationLevelRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationInfoFields(
    AppLocalizations l10n,
    AdditionalDataProvider additionalDataProvider,
  ) {
    return Column(
      children: [
        CustomDropdown<int>(
          value: _selectedCountryId,
          label: l10n.country,
          hint: l10n.selectCountry,
          icon: Icons.public_outlined,
          items: additionalDataProvider.countries.map((c) => c.id).toList(),
          itemLabels: additionalDataProvider.countries
              .map((c) => c.name)
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCountryId = value;
              _selectedRegionId = null;
              _selectedDistrictId = null;
              _selectedWardId = null;
              _selectedVillageId = null;
              _selectedStreetId = null;
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
        CustomDropdown<int>(
          value: _selectedRegionId,
          label: l10n.region,
          hint: l10n.selectRegion,
          icon: Icons.map_outlined,
          items: _selectedCountryId != null
              ? additionalDataProvider
                    .getRegionsByCountry(_selectedCountryId!)
                    .map((r) => r.id)
                    .toList()
              : [],
          itemLabels: _selectedCountryId != null
              ? additionalDataProvider
                    .getRegionsByCountry(_selectedCountryId!)
                    .map((r) => r.name)
                    .toList()
              : [],
          onChanged: (value) {
            setState(() {
              _selectedRegionId = value;
              _selectedDistrictId = null;
              _selectedWardId = null;
              _selectedVillageId = null;
              _selectedStreetId = null;
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
        CustomDropdown<int>(
          value: _selectedDistrictId,
          label: l10n.district,
          hint: l10n.selectDistrict,
          icon: Icons.location_city_outlined,
          items: _selectedRegionId != null
              ? additionalDataProvider
                    .getDistrictsByRegion(_selectedRegionId!)
                    .map((d) => d.id)
                    .toList()
              : [],
          itemLabels: _selectedRegionId != null
              ? additionalDataProvider
                    .getDistrictsByRegion(_selectedRegionId!)
                    .map((d) => d.name)
                    .toList()
              : [],
          onChanged: (value) {
            setState(() {
              _selectedDistrictId = value;
              _selectedWardId = null;
              _selectedVillageId = null;
              _selectedStreetId = null;
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
        CustomDropdown<int>(
          value: _selectedWardId,
          label: l10n.ward,
          hint: l10n.selectWard,
          icon: Icons.place_outlined,
          items: _selectedDistrictId != null
              ? additionalDataProvider
                    .getWardsByDistrict(_selectedDistrictId!)
                    .map((w) => w.id)
                    .toList()
              : [],
          itemLabels: _selectedDistrictId != null
              ? additionalDataProvider
                    .getWardsByDistrict(_selectedDistrictId!)
                    .map((w) => w.name)
                    .toList()
              : [],
          onChanged: (value) {
            setState(() {
              _selectedWardId = value;
              _selectedVillageId = null;
              _selectedStreetId = null;
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
        CustomDropdown<int>(
          value: _selectedVillageId,
          label: '${l10n.village} (${l10n.optional})',
          hint: l10n.selectVillage,
          icon: Icons.home_work_outlined,
          items: _selectedWardId != null
              ? additionalDataProvider
                    .getVillagesByWard(_selectedWardId!)
                    .map((v) => v.id)
                    .toList()
              : [],
          itemLabels: _selectedWardId != null
              ? additionalDataProvider
                    .getVillagesByWard(_selectedWardId!)
                    .map((v) => v.name)
                    .toList()
              : [],
          onChanged: (value) => setState(() => _selectedVillageId = value),
        ),
        const SizedBox(height: 16),
        CustomDropdown<int>(
          value: _selectedStreetId,
          label: '${l10n.street} (${l10n.optional})',
          hint: l10n.selectStreet,
          icon: Icons.signpost_outlined,
          items: _selectedWardId != null
              ? additionalDataProvider
                    .getStreetsByWard(_selectedWardId!)
                    .map((s) => s.id)
                    .toList()
              : [],
          itemLabels: _selectedWardId != null
              ? additionalDataProvider
                    .getStreetsByWard(_selectedWardId!)
                    .map((s) => s.name)
                    .toList()
              : [],
          onChanged: (value) => setState(() => _selectedStreetId = value),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoFields(AppLocalizations l10n) {
    return Column(
      children: [
        CustomDropdown<String>(
          value: _selectedFarmerType,
          label: l10n.farmerType,
          hint: l10n.selectFarmerType,
          icon: Icons.agriculture_outlined,
          dropdownItems: [
            DropdownItem(value: 'individual', label: l10n.individual),
            DropdownItem(value: 'organization', label: l10n.organization),
          ],
          onChanged: (value) => setState(() => _selectedFarmerType = value),
          validator: (value) {
            if (value == null) {
              return l10n.farmerTypeRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _farmerOrganizationController,
          label: l10n.farmerOrganizationMembership,
          hintText: l10n.enterOrganizationName,
          prefixIcon: Icons.group_outlined,
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          l10n.editProfile,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          l10n.confirmUpdateProfile,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Constants.primaryColor,
            ),
            child: Text(
              l10n.save,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement API call to update profile
      // For now, just show success message
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.profileUpdated,
          message: l10n.profileUpdatedSuccessfully,
          buttonText: l10n.ok,
          onPressed: () {
            Navigator.of(context).pop(); // Go back to profile screen
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: e.toString(),
          buttonText: l10n.ok,
        );
      }
    }
  }
}

