import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_date_picker.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/error_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/provider/all.additional.data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/home/presentation/home_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // AuthProvider will be accessed via Provider.of<AuthProvider>(context)
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for Step 1: Personal Information
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  
  // Controllers for Step 2: Contact Information
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _physicalAddressController = TextEditingController();
  
  // Controllers for Step 3: Identity Information
  final _identityNumberController = TextEditingController();
  
  // Controllers for Step 4: Location Information
  // We'll store IDs from dropdowns
  
  // Controllers for Step 5: Additional Information
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
  
  @override
  void initState() {
    super.initState();
    // Fetch locations when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocationsIfNeeded();
    });
  }
  
  Future<void> _loadLocationsIfNeeded() async {
    final additionalDataProvider = Provider.of<AdditionalDataProvider>(context, listen: false);
    
    // Only load if not already loaded
    if (!additionalDataProvider.hasLocationData && !additionalDataProvider.isLoadingLocations) {
      await additionalDataProvider.fetchLocationsWithDialogs(context);
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

   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Constants.veryLightGreyColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomBackButton(
          isEnabledBgColor: false,
          iconColor: Theme.of(context).colorScheme.tertiary,
          iconSize: 24,
        ),
        title: Text(
          l10n.register,
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
 
          if(!additionalDataProvider.hasLocationData) {
            return const Center(child: LoadingIndicator());
          }
        
          return SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: CustomStepper(
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  isLoading: _isLoading,
                  steps: [
                    StepperStep(
                      title: l10n.personalInfoStep,
                      subtitle: l10n.personalInfoStepSubtitle,
                      icon: Icons.person_outline,
                      content: _buildPersonalInfoStep(),
                    ),
                    StepperStep(
                      title: l10n.contactInfoStep,
                      subtitle: l10n.contactInfoStepSubtitle,
                      icon: Icons.contact_phone_outlined,
                      content: _buildContactInfoStep(),
                    ),
                    StepperStep(
                      title: l10n.identityInfoStep,
                      subtitle: l10n.identityInfoStepSubtitle,
                      icon: Icons.badge_outlined,
                      content: _buildIdentityInfoStep(),
                    ),
                    StepperStep(
                      title: l10n.locationInfoStep,
                      subtitle: l10n.locationInfoStepSubtitle,
                      icon: Icons.location_on_outlined,
                      content: _buildLocationInfoStep(),
                    ),
                    StepperStep(
                      title: l10n.additionalInfoStep,
                      subtitle: l10n.additionalInfoStepSubtitle,
                      icon: Icons.info_outline,
                      content: _buildAdditionalInfoStep(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),    
    );
  }

  //               StepperStep(
  //                 title: l10n.personalInfoStep,
  //                 subtitle: l10n.personalInfoStepSubtitle,
  //                 icon: Icons.person_outline,
  //                 content: _buildPersonalInfoStep(),
  //               ),
  //               StepperStep(
  //                 title: l10n.contactInfoStep,
  //                 subtitle: l10n.contactInfoStepSubtitle,
  //                 icon: Icons.contact_phone_outlined,
  //                 content: _buildContactInfoStep(),
  //               ),
  //               StepperStep(
  //                 title: l10n.identityInfoStep,
  //                 subtitle: l10n.identityInfoStepSubtitle,
  //                 icon: Icons.badge_outlined,
  //                 content: _buildIdentityInfoStep(),
  //               ),
  //               StepperStep(
  //                 title: l10n.locationInfoStep,
  //                 subtitle: l10n.locationInfoStepSubtitle,
  //                 icon: Icons.location_on_outlined,
  //                 content: _buildLocationInfoStep(),
  //               ),
  //               StepperStep(
  //                 title: l10n.additionalInfoStep,
  //                 subtitle: l10n.additionalInfoStepSubtitle,
  //                 icon: Icons.info_outline,
  // }
  
  // Step 1: Personal Information
  Widget _buildPersonalInfoStep() {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.personalInformation),
        const SizedBox(height: 20),
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
          items: [l10n.male, l10n.female],
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
  
  // Step 2: Contact Information
  Widget _buildContactInfoStep() {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.contactDetails),
        const SizedBox(height: 20),
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
          label: l10n.phone2,
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
  
  // Step 3: Identity Information
  Widget _buildIdentityInfoStep() {
    final l10n = AppLocalizations.of(context)!;
    final additionalDataProvider = Provider.of<AdditionalDataProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.identityCardType),
        const SizedBox(height: 20),
        
        // Identity Card Type Dropdown
        CustomDropdown<int>(
          value: _selectedIdentityCardTypeId,
          label: l10n.identityCardType,
          hint: l10n.selectIdType,
          icon: Icons.badge_outlined,
          items: additionalDataProvider.identityCardTypes.map((t) => t.id).toList(),
          itemLabels: additionalDataProvider.identityCardTypes.map((t) => t.name).toList(),
          onChanged: (value) => setState(() => _selectedIdentityCardTypeId = value),
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
        
        // School Level Dropdown
        CustomDropdown<int>(
          value: _selectedSchoolLevelId,
          label: l10n.schoolLevel,
          hint: l10n.selectEducationLevel,
          icon: Icons.school_outlined,
          items: additionalDataProvider.schoolLevels.map((s) => s.id).toList(),
          itemLabels: additionalDataProvider.schoolLevels.map((s) => s.name).toList(),
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
  
  // Step 4: Location Information
  Widget _buildLocationInfoStep() {
    final l10n = AppLocalizations.of(context)!;
    final additionalDataProvider = Provider.of<AdditionalDataProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.addressInformation),
        const SizedBox(height: 20),
        
        // Country Dropdown
        CustomDropdown<int>(
          value: _selectedCountryId,
          label: l10n.country,
          hint: l10n.selectCountry,
          icon: Icons.public_outlined,
          items: additionalDataProvider.countries.map((c) => c.id).toList(),
          itemLabels: additionalDataProvider.countries.map((c) => c.name).toList(),
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
        
        // Region Dropdown
        CustomDropdown<int>(
          value: _selectedRegionId,
          label: l10n.region,
          hint: l10n.selectRegion,
          icon: Icons.map_outlined,
          items: _selectedCountryId != null 
              ? additionalDataProvider.getRegionsByCountry(_selectedCountryId!).map((r) => r.id).toList()
              : [],
          itemLabels: _selectedCountryId != null
              ? additionalDataProvider.getRegionsByCountry(_selectedCountryId!).map((r) => r.name).toList()
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
        
        // District Dropdown
        CustomDropdown<int>(
          value: _selectedDistrictId,
          label: l10n.district,
          hint: l10n.selectDistrict,
          icon: Icons.location_city_outlined,
          items: _selectedRegionId != null
              ? additionalDataProvider.getDistrictsByRegion(_selectedRegionId!).map((d) => d.id).toList()
              : [],
          itemLabels: _selectedRegionId != null
              ? additionalDataProvider.getDistrictsByRegion(_selectedRegionId!).map((d) => d.name).toList()
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
        
        // Ward Dropdown
        CustomDropdown<int>(
          value: _selectedWardId,
          label: l10n.ward,
          hint: l10n.selectWard,
          icon: Icons.place_outlined,
          items: _selectedDistrictId != null
              ? additionalDataProvider.getWardsByDistrict(_selectedDistrictId!).map((w) => w.id).toList()
              : [],
          itemLabels: _selectedDistrictId != null
              ? additionalDataProvider.getWardsByDistrict(_selectedDistrictId!).map((w) => w.name).toList()
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
        
        // Village Dropdown (Optional)
        CustomDropdown<int>(
          value: _selectedVillageId,
          label: '${l10n.village} (${l10n.optional})',
          hint: l10n.selectVillage,
          icon: Icons.home_work_outlined,
          items: _selectedWardId != null
              ? additionalDataProvider.getVillagesByWard(_selectedWardId!).map((v) => v.id).toList()
              : [],
          itemLabels: _selectedWardId != null
              ? additionalDataProvider.getVillagesByWard(_selectedWardId!).map((v) => v.name).toList()
              : [],
          onChanged: (value) => setState(() => _selectedVillageId = value),
          // No validator - field is optional
        ),
        const SizedBox(height: 16),
        
        // Street Dropdown (Optional)
        CustomDropdown<int>(
          value: _selectedStreetId,
          label: '${l10n.street} (${l10n.optional})',
          hint: l10n.selectStreet,
          icon: Icons.signpost_outlined,
          items: _selectedWardId != null
              ? additionalDataProvider.getStreetsByWard(_selectedWardId!).map((s) => s.id).toList()
              : [],
          itemLabels: _selectedWardId != null
              ? additionalDataProvider.getStreetsByWard(_selectedWardId!).map((s) => s.name).toList()
              : [],
          onChanged: (value) => setState(() => _selectedStreetId = value),
          // No validator - field is optional
        ),
      ],
    );
  }
  
  // Step 5: Additional Information
  Widget _buildAdditionalInfoStep() {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.additionalDetails),
        const SizedBox(height: 20),
        CustomDropdown<String>(
          value: _selectedFarmerType,
          label: l10n.farmerType,
          hint: l10n.selectFarmerType,
          icon: Icons.agriculture_outlined,
          items: [l10n.individual, l10n.organization],
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
                  l10n.reviewInfoMessage,
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
  
  
  
  
  // Step navigation logic
  void _onStepContinue() async {
    if (_currentStep < 4) {
      // Validate current step using form validation
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else {
      // Final step - submit form
      if (_formKey.currentState!.validate()) {
        await _submitRegistration();
      }
    }
  }
  
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }
  
  
  Future<void> _submitRegistration() async {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);
    
    try {
      // Prepare registration data with authentication fields
      final registrationData = {
        // Authentication fields
        'username': _emailController.text, // Use email as username
        'email': _emailController.text,
        'password': _emailController.text, // Use email as password
        // 'password_confirmation': _emailController.text,
        
        // Personal information
        'firstName': _firstNameController.text,
        'middleName': _middleNameController.text,
        'surname': _surnameController.text,
        'phone1': _phone1Controller.text,
        'phone2': _phone2Controller.text,
        'physicalAddress': _physicalAddressController.text,
        'farmerOrganizationMembership': _farmerOrganizationController.text,
        'dateOfBirth': _dateOfBirthController.text,
        'gender': _selectedGender?.toLowerCase(),
        
        // Identity information
        'identityCardTypeId': _selectedIdentityCardTypeId,
        'identityNumber': _identityNumberController.text,
        'schoolLevelId': _selectedSchoolLevelId,
        
        // Location information
        'streetId': _selectedStreetId,
        'villageId': _selectedVillageId,
        'wardId': _selectedWardId,
        'districtId': _selectedDistrictId,
        'regionId': _selectedRegionId,
        'countryId': _selectedCountryId,
        
        // Farmer information
        'farmerType': _selectedFarmerType?.toLowerCase(),
      };

      final isRegistered = await authProvider.registerFarmer(context: context, farmerData: registrationData);

      if (isRegistered && mounted) {
        // Registration successful - navigate to dashboard
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const HomeScreen())
        );
      }
    } catch (e) {
      if (mounted) {
        // Show user-friendly error dialog
        final errorMessage = ErrorHelper.formatErrorMessage(e.toString(), l10n);
        final errorTitle = ErrorHelper.getErrorTitle(e.toString(), l10n);
        
        await AlertDialogs.showError(
          context: context,
          title: errorTitle,
          message: errorMessage,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
