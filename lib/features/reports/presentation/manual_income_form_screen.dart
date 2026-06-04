import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/app_date_picker.dart';
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
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/provider/finance_income_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ManualIncomeFormScreen extends StatefulWidget {
  const ManualIncomeFormScreen({super.key});

  @override
  State<ManualIncomeFormScreen> createState() => _ManualIncomeFormScreenState();
}

class _ManualIncomeFormScreenState extends State<ManualIncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  int _currentStep = 0;

  final _subjectController = TextEditingController();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _referenceController = TextEditingController();
  final _customSourceTypeController = TextEditingController();

  bool _isLoadingData = true;
  List<Farm> _farms = const [];
  String? _selectedFarmUuid;
  DateTime _incomeDate = DateTime.now();
  String _selectedStatus = 'received';
  bool _hasSource = false;
  String? _selectedSourceType = 'sale';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _referenceController.dispose();
    _customSourceTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoadingData = true);
      final database = Provider.of<AppDatabase>(context, listen: false);
      final farms = await database.farmDao.getAllActiveFarms();

      if (!mounted) return;

      String? selected = _selectedFarmUuid;
      if (selected != null && farms.every((farm) => farm.uuid != selected)) {
        selected = null;
      }
      selected ??= farms.isNotEmpty ? farms.first.uuid : null;

      setState(() {
        _farms = farms;
        _selectedFarmUuid = selected;
        _isLoadingData = false;
      });
    } catch (e, st) {
      log('❌ Failed to load manual income form: $e', stackTrace: st);
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.farmsLoadFailed)));
    }
  }

  void _onHasSourceChanged(bool value) {
    setState(() {
      _hasSource = value;
      if (!value) {
        _selectedSourceType = 'sale';
        _customSourceTypeController.clear();
      }
    });
  }

  Future<void> _pickIncomeDate(AppLocalizations l10n) async {
    final theme = Theme.of(context);
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _incomeDate,
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (ctx, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: Constants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _incomeDate = picked);
  }

  bool _validateCurrentStep(FormState formState) {
    final isValid = formState.validate();
    if (!isValid) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Constants.veryLightGreyColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: Theme.of(context).brightness != Brightness.dark
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        elevation: 0,
        leading: CustomBackButton(
          isEnabledBgColor: false,
          iconColor: theme.colorScheme.primary,
        ),
        title: Text(
          l10n.manualIncomeTitle,
          style: TextStyle(
            fontSize: Constants.largeTextSize,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoadingData
            ? const Center(child: LoadingIndicator())
            : Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: CustomStepper(
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  continueButtonText: _currentStep == 0
                      ? l10n.continueButton
                      : null,
                  backButtonText: l10n.back,
                  finalStepButtonText: l10n.save,
                  steps: [
                    StepperStep(
                      title: l10n.manualIncomeBasicStep,
                      subtitle: l10n.manualIncomeDetailsSubtitle,
                      icon: Icons.trending_up,
                      content: _buildBasicStep(l10n, theme),
                    ),
                    StepperStep(
                      title: l10n.manualIncomeAdditionalStep,
                      subtitle: l10n.manualIncomeAdditionalStepSubtitle,
                      icon: Icons.edit_note_outlined,
                      content: _buildAdditionalStep(l10n, theme),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.manualIncomeTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.manualIncomeDetailsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicStep(AppLocalizations l10n, ThemeData theme) {
    final farmItems = _farms
        .map((farm) => DropdownItem<String>(value: farm.uuid, label: farm.name))
        .toList();
    final hasFarm = _farms.isNotEmpty;
    final dateLabel = DateFormat.yMMMd().format(_incomeDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(l10n, theme),
        const SizedBox(height: 24),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.agriculture_outlined,
          title: l10n.selectFarm,
          subtitle: l10n.selectFarm,
        ),
        const SizedBox(height: 12),
        if (!hasFarm)
          _buildInfoMessage(theme, l10n.noFarmsFound, icon: Icons.info_outline)
        else
          CustomDropdown<String>(
            label: l10n.selectFarm,
            hint: l10n.selectFarm,
            icon: Icons.agriculture_outlined,
            value: _selectedFarmUuid,
            dropdownItems: farmItems,
            onChanged: (value) {
              setState(() => _selectedFarmUuid = value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.farmRequired;
              }
              return null;
            },
          ),
        const SizedBox(height: 24),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.link_outlined,
          title: l10n.incomeSourceSectionTitle,
          subtitle: l10n.incomeSourceSectionSubtitle,
        ),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _hasSource,
          onChanged: _onHasSourceChanged,
          title: Text(l10n.incomeHasSource),
          subtitle: Text(l10n.incomeHasSourceHint),
          secondary: const Icon(Icons.link_outlined),
        ),
        if (_hasSource) ...[
          const SizedBox(height: 12),
          CustomDropdown<String>(
            label: l10n.incomeSourceType,
            hint: l10n.selectIncomeSourceType,
            icon: Icons.source_outlined,
            value: _selectedSourceType,
            dropdownItems: [
              DropdownItem(value: 'sale', label: l10n.incomeSourceTypeSale),
              DropdownItem(
                value: 'service',
                label: l10n.incomeSourceTypeService,
              ),
              DropdownItem(value: 'other', label: l10n.other),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSourceType = value;
                if (value != 'other') {
                  _customSourceTypeController.clear();
                }
              });
            },
            validator: (value) {
              if (!_hasSource) return null;
              if (value == null || value.isEmpty) {
                return l10n.incomeSourceTypeRequired;
              }
              return null;
            },
          ),
          if (_selectedSourceType == 'other') ...[
            const SizedBox(height: 12),
            CustomTextField(
              label: l10n.incomeSourceTypeOther,
              hintText: l10n.incomeSourceTypeOtherHint,
              prefixIcon: Icons.edit_outlined,
              controller: _customSourceTypeController,
              validator: (value) {
                if (_hasSource &&
                    _selectedSourceType == 'other' &&
                    (value == null || value.trim().isEmpty)) {
                  return l10n.incomeSourceTypeOtherRequired;
                }
                return null;
              },
            ),
          ],
        ],
        const SizedBox(height: 24),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.description_outlined,
          title: l10n.incomeSubject,
          subtitle: l10n.incomeSubjectHint,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: l10n.incomeSubject,
          hintText: l10n.incomeSubjectHint,
          prefixIcon: Icons.description_outlined,
          controller: _subjectController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.incomeSubjectRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.payments_outlined,
          title: l10n.incomeAmount,
          subtitle: l10n.incomeAmountHint,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: l10n.incomeAmount,
          hintText: l10n.incomeAmountHint,
          prefixIcon: Icons.attach_money,
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          validator: (value) {
            final n = double.tryParse(value?.trim() ?? '');
            if (n == null || n <= 0) {
              return l10n.incomeAmountRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.event_outlined,
          title: l10n.incomeDate,
          subtitle: l10n.selectIncomeDate,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _pickIncomeDate(l10n),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.incomeDate,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: Text(
              dateLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalStep(AppLocalizations l10n, ThemeData theme) {
    final statusItems = [
      DropdownItem(value: 'received', label: l10n.receivedStatus),
      DropdownItem(value: 'pending', label: l10n.pendingStatus),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          theme: theme,
          icon: Icons.numbers,
          title: l10n.incomeQuantity,
          subtitle: l10n.incomeQuantityHint,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: l10n.incomeQuantity,
          hintText: l10n.incomeQuantityHint,
          prefixIcon: Icons.numbers,
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            final qty = int.tryParse(value?.trim() ?? '');
            if (qty == null || qty <= 0) {
              return l10n.incomeQuantityRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.check_circle_outline,
          title: l10n.incomePaymentStatus,
          subtitle: l10n.selectIncomeStatus,
        ),
        const SizedBox(height: 12),
        CustomDropdown<String>(
          label: l10n.incomePaymentStatus,
          hint: l10n.selectIncomeStatus,
          icon: Icons.check_circle_outline,
          value: _selectedStatus,
          dropdownItems: statusItems,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedStatus = value);
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.notes_outlined,
          title: l10n.incomeNotes,
          subtitle: l10n.incomeNotesHint,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: l10n.incomeNotes,
          hintText: l10n.incomeNotesHint,
          prefixIcon: Icons.notes_outlined,
          controller: _notesController,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: '${l10n.referenceNumber} (${l10n.optionalFieldHint})',
          hintText: l10n.optionalFieldHint,
          prefixIcon: Icons.tag_outlined,
          controller: _referenceController,
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          theme: theme,
          icon: Icons.info_outline,
          message: l10n.manualIncomeAccuracyNote,
        ),
      ],
    );
  }

  void _onStepContinue() {
    final formState = _formKey.currentState;
    if (formState == null) return;

    if (!_validateCurrentStep(formState)) {
      return;
    }

    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
      return;
    }

    _confirmSubmit();
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _confirmSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    await AlertDialogs.showConfirmation(
      context: context,
      title: l10n.save,
      message: l10n.confirmSaveManualIncome,
      confirmText: l10n.save,
      cancelText: l10n.cancel,
      onConfirm: () async {
        await _submit();
      },
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final farmUuid = _selectedFarmUuid;
    if (farmUuid == null || farmUuid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.farmRequired)));
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }

    final qty = int.tryParse(_quantityController.text.trim());
    if (qty == null || qty <= 0) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }

    final database = Provider.of<AppDatabase>(context, listen: false);
    final provider = Provider.of<FinanceIncomeProvider>(context, listen: false);
    final farm = await database.farmDao.getFarmByUuid(farmUuid);
    final farmerId = farm?.farmerId;

    if (!mounted) return;

    final uuid = const Uuid().v4();
    final notes = _notesController.text.trim();
    final subject = _subjectController.text.trim();
    final reference = _referenceController.text.trim();
    final customSourceType = _customSourceTypeController.text.trim();
    final sourceType = !_hasSource
        ? null
        : (_selectedSourceType == 'other'
              ? (customSourceType.isEmpty ? null : customSourceType)
              : _selectedSourceType);

    final ok = await provider.addManualIncomeWithDialog(
      context,
      uuid: uuid,
      farmUuid: farmUuid,
      farmerId: farmerId,
      sourceType: sourceType,
      sourceUuid: null,
      referenceNo: reference.isEmpty ? null : reference,
      subjectType: subject,
      totalAmount: amount,
      quantity: qty,
      status: _selectedStatus,
      notes: notes.isEmpty ? null : notes,
      incomeDate: _incomeDate,
    );

    if (ok && mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget _buildInfoMessage(
    ThemeData theme,
    String message, {
    IconData icon = Icons.info_outline,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Constants.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: primary.withValues(alpha: 0.75),
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
