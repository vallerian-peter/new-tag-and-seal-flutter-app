import 'dart:developer';
import 'dart:math' hide log;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/toast_alerts.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/section_header.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/multi_select_checkbox_list.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/domain/models/farm_user_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/presentation/provider/farm_user_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class FarmUserFormScreen extends StatefulWidget {
  final FarmUserModel? farmUser;

  const FarmUserFormScreen({
    super.key,
    this.farmUser,
  });

  bool get isEditMode => farmUser != null;

  @override
  State<FarmUserFormScreen> createState() => _FarmUserFormScreenState();
}

class _FarmUserFormScreenState extends State<FarmUserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  int _currentStep = 0;

  bool _isLoading = false;
  List<Farm> _farms = const [];

  Set<String> _selectedFarmUuids = {}; // Changed to Set for multiple farms
  String? _selectedRoleTitle;
  String? _selectedGender;

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFarms();
        if (widget.isEditMode && widget.farmUser != null) {
          _initializeEditMode();
        }
      }
    });
  }

  void _initializeEditMode() {
    final user = widget.farmUser!;
    _selectedFarmUuids = user.farmUuids.toSet(); // Initialize with multiple farms
    _selectedRoleTitle = user.roleTitle;
    _selectedGender = user.gender;
    _firstNameController.text = user.firstName;
    _middleNameController.text = user.middleName ?? '';
    _lastNameController.text = user.lastName;
    _phoneController.text = user.phone ?? '';
    _emailController.text = user.email;
  }

  Future<void> _loadFarms() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final database = context.read<AppDatabase>();
      final farms = await database.farmDao.getAllActiveFarms();
      if (!mounted) return;
      setState(() {
        _farms = farms;
        // Don't auto-select farms - user must choose
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _farms = const [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await _confirmSubmit();
  }

  Future<void> _confirmSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    await AlertDialogs.showConfirmation(
      context: context,
      title: l10n.save,
      message: widget.isEditMode
          ? l10n.confirmSaveFarmUser
          : l10n.confirmSaveFarmUser,
      confirmText: l10n.save,
      cancelText: l10n.cancel,
      onConfirm: () async {
        Navigator.of(context).pop(true);
        await _submit();
      },
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final farmUserProvider =
        Provider.of<FarmUserProvider>(context, listen: false);

    final farmUuids = _selectedFarmUuids.toList();
    if (farmUuids.isEmpty) {
      ToastAlerts.showError(
        context,
        message: l10n.farmRequired,
      );
      return;
    }

    final roleTitle = _selectedRoleTitle;
    if (roleTitle == null || roleTitle.isEmpty) {
      ToastAlerts.showError(
        context,
        message: l10n.pleaseSelect,
      );
      return;
    }

    final gender = _selectedGender;
    if (gender == null || gender.isEmpty) {
      ToastAlerts.showError(
        context,
        message: l10n.genderRequired,
      );
      return;
    }

    final nowIso = DateTime.now().toIso8601String();

    try {
      if (widget.isEditMode && widget.farmUser != null) {
        // Update existing farm user
        final updatedModel = widget.farmUser!.copyWith(
          farmUuids: farmUuids, // Multiple farms
          firstName: _firstNameController.text.trim(),
          middleName: _middleNameController.text.trim().isEmpty
              ? null
              : _middleNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim(),
          roleTitle: roleTitle,
          gender: gender,
          updatedAt: nowIso,
        );

        final updated =
            await farmUserProvider.updateFarmUserWithDialog(context, updatedModel);
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        }
      } else {
        // Create new farm user
        final uuid = _generateUuid();
        final newModel = FarmUserModel(
          id: null,
          uuid: uuid,
          farmUuids: farmUuids, // Multiple farms
          firstName: _firstNameController.text.trim(),
          middleName: _middleNameController.text.trim().isEmpty
              ? null
              : _middleNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim(),
          roleTitle: roleTitle,
          gender: gender,
          synced: false,
          syncAction: 'create',
          createdAt: nowIso,
          updatedAt: nowIso,
        );

        final created =
            await farmUserProvider.addFarmUserWithDialog(context, newModel);
        if (created != null && mounted) {
          Navigator.pop(context, created);
        }
      }
    } catch (e, stackTrace) {
      log('❌ Failed to save farm user: $e', stackTrace: stackTrace);
    }
  }

  String _generateUuid() {
    final microseconds = DateTime.now().microsecondsSinceEpoch;
    // Generate a 5‑digit random number (10000–99999)
    final randomFiveDigits = 10000 + Random().nextInt(90000);

    final uuid = '$microseconds-$randomFiveDigits-farmUser';
    log('🔐 DEBUG: Generated FarmUser UUID: $uuid');
    return uuid;
  }

  Future<void> _onStepContinue() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    if (!formState.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }

    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
      return;
    }

    await _onSave();
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).maybePop();
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final roleOptions = <String, String>{
      'farm-manager': '${l10n.farmManagementText} ${l10n.user}',
      'feeding-user': '${l10n.feeding} ${l10n.user}',
      'weight-change-user': '${l10n.weightChange} ${l10n.user}',
      'deworming-user': '${l10n.deworming} ${l10n.user}',
      'medication-user': '${l10n.medication} ${l10n.user}',
      'vaccination-user': '${l10n.vaccination} ${l10n.user}',
      'disposal-user': '${l10n.disposal} ${l10n.user}',
      'birth-event-user': '${l10n.birthEvent} ${l10n.user}',
      'aborted-pregnancy-user': '${l10n.abortedPregnancy} ${l10n.user}',
      'dryoff-user': '${l10n.dryoff} ${l10n.user}',
      'insemination-user': '${l10n.insemination} ${l10n.user}',
      'pregnancy-user': '${l10n.pregnancy} ${l10n.user}',
      'milking-user': '${l10n.milking} ${l10n.user}',
      'transfer-user': '${l10n.transfer} ${l10n.user}',
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        systemOverlayStyle: theme.brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomBackButton(
          isEnabledBgColor: false,
          iconColor: theme.colorScheme.primary,
        ),
        title: Text(
          widget.isEditMode ? l10n.editFarmUserText : l10n.inviteFarmUserText,
          style: TextStyle(
            fontSize: Constants.largeTextSize,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidateMode,
                  child: CustomStepper(
                    currentStep: _currentStep,
                    onStepContinue: _onStepContinue,
                    onStepCancel: _onStepCancel,
                    continueButtonText:
                        _currentStep == 0 ? l10n.continueButton : null,
                    backButtonText: l10n.back,
                    finalStepButtonText: l10n.save,
                    steps: [
                      StepperStep(
                        title: l10n.basicInformation,
                        subtitle: l10n.farmManagementText,
                        icon: Icons.agriculture_outlined,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              icon: Icons.info_outline,
                              title: l10n.basicInformation,
                              subtitle: l10n.farmManagementText,
                            ),
                            const SizedBox(height: 16),
                            // Multiple Farms Selection with Checkboxes
                            MultiSelectCheckboxList<Farm>(
                              label: l10n.farm,
                              items: _farms,
                              selectedItems: _farms
                                  .where((farm) => _selectedFarmUuids.contains(farm.uuid))
                                  .toSet(),
                              itemLabel: (farm) => farm.name,
                              itemSubtitle: (farm) => farm.referenceNo,
                              onSelectionChanged: (selected) {
                                setState(() {
                                  _selectedFarmUuids = selected.map((f) => f.uuid).toSet();
                                });
                              },
                              emptyMessage: l10n.noFarmsFound,
                              errorMessage: _autovalidateMode == AutovalidateMode.always &&
                                      _selectedFarmUuids.isEmpty
                                  ? l10n.farmRequired
                                  : null,
                              successMessage: _selectedFarmUuids.isNotEmpty
                                  ? '${_selectedFarmUuids.length} ${_selectedFarmUuids.length == 1 ? l10n.farm : l10n.farms} selected'
                                  : null,
                              showSelectAll: _farms.length > 1,
                              selectAllLabel: 'Select All',
                            ),
                            const SizedBox(height: 24),
                            CustomDropdown<String>(
                              label: l10n.role,
                              hint: l10n.pleaseSelect,
                              icon: Icons.badge_outlined,
                              value: _selectedRoleTitle,
                              dropdownItems: roleOptions.entries
                                  .map(
                                    (entry) => DropdownItem<String>(
                                      value: entry.key,
                                      label: entry.value,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoleTitle = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.pleaseSelect;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      StepperStep(
                        title: l10n.additionalDetails,
                        subtitle: l10n.basicInformation,
                        icon: Icons.person_outline,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              icon: Icons.person_outline,
                              title: l10n.additionalDetails,
                              subtitle: l10n.basicInformation,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: l10n.firstName,
                              hintText: l10n.enterFirstName,
                              prefixIcon: Icons.person_outline,
                              controller: _firstNameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.firstNameRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              label: l10n.middleName,
                              hintText: l10n.middleName,
                              prefixIcon: Icons.person_outline,
                              controller: _middleNameController,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              label: l10n.surname,
                              hintText: l10n.enterSurname,
                              prefixIcon: Icons.person_outline,
                              controller: _lastNameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.surnameRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              label: l10n.phoneNumber,
                              hintText: l10n.enterPhoneNumber,
                              prefixIcon: Icons.phone,
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              label: l10n.email,
                              hintText: l10n.email,
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return l10n.emailRequired;
                                }
                                if (!value.contains('@')) {
                                  return l10n.validEmailRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomDropdown<String>(
                              label: l10n.gender,
                              hint: l10n.selectGender,
                              icon: Icons.wc_outlined,
                              value: _selectedGender,
                              dropdownItems: [
                                DropdownItem(
                                    value: 'male', label: l10n.male),
                                DropdownItem(
                                    value: 'female', label: l10n.female),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.genderRequired;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}


