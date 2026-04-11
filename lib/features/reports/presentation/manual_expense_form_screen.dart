import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/modern_alerts.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/provider/finance_expense_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// Matches [VaccineFormScreen] layout: same scaffold, stepper, section titles, and field widgets.
class ManualExpenseFormScreen extends StatefulWidget {
  const ManualExpenseFormScreen({super.key});

  @override
  State<ManualExpenseFormScreen> createState() =>
      _ManualExpenseFormScreenState();
}

class _ManualExpenseFormScreenState extends State<ManualExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  int _currentStep = 0;

  final _subjectController = TextEditingController();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  bool _isLoadingData = true;
  List<Farm> _farms = const [];
  String? _selectedFarmUuid;
  DateTime _expenseDate = DateTime.now();
  String _selectedStatus = 'paid';

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
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoadingData = true);
      final database = Provider.of<AppDatabase>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);

      var farms = await database.farmDao.getAllActiveFarms();

      if (auth.isFarmUser) {
        final uuids = (auth.currentProfile?['farmUuids'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        farms = farms.where((f) => uuids.contains(f.uuid)).toList();
      } else if (auth.isFarmer) {
        final farmerId = int.tryParse(
          auth.currentUser?['roleId']?.toString() ?? '',
        );
        if (farmerId != null) {
          farms = farms.where((f) => f.farmerId == farmerId).toList();
        }
      }

      if (!mounted) return;

      String? selected = _selectedFarmUuid;
      if (selected != null && farms.every((f) => f.uuid != selected)) {
        selected = null;
      }
      selected ??= farms.isNotEmpty ? farms.first.uuid : null;

      setState(() {
        _farms = farms;
        _selectedFarmUuid = selected;
        _isLoadingData = false;
      });
    } catch (e, st) {
      log('❌ Failed to load manual expense form: $e', stackTrace: st);
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.farmWithLivestockLoadFailed)),
      );
    }
  }

  Future<void> _pickExpenseDate(AppLocalizations l10n) async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
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
    if (picked != null) setState(() => _expenseDate = picked);
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
          l10n.manualExpenseTitle,
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
                  continueButtonText:
                      _currentStep == 0 ? l10n.continueButton : null,
                  backButtonText: l10n.back,
                  finalStepButtonText: l10n.save,
                  steps: [
                    StepperStep(
                      title: l10n.manualExpenseBasicStep,
                      subtitle: l10n.manualExpenseDetailsSubtitle,
                      icon: Icons.payments_outlined,
                      content: _buildBasicStep(l10n, theme),
                    ),
                    StepperStep(
                      title: l10n.manualExpenseAdditionalStep,
                      subtitle: l10n.manualExpenseAdditionalStepSubtitle,
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
                  Icons.receipt_long_outlined,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.manualExpenseTitle,
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
            l10n.manualExpenseDetailsSubtitle,
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
        .map(
          (farm) => DropdownItem<String>(
            value: farm.uuid,
            label: farm.name,
          ),
        )
        .toList();
    final hasFarm = _farms.isNotEmpty;
    final dateLabel = DateFormat.yMMMd().format(_expenseDate);

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
          _buildInfoMessage(
            theme,
            l10n.noFarmsFound,
            icon: Icons.info_outline,
          )
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
          icon: Icons.description_outlined,
          title: l10n.expenseSubject,
          subtitle: l10n.expenseSubjectHint,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: l10n.expenseSubject,
          hintText: l10n.expenseSubjectHint,
          prefixIcon: Icons.description_outlined,
          controller: _subjectController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.expenseSubjectRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.payments_outlined,
          title: l10n.expenseAmount,
          subtitle: l10n.expenseAmountHint,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: l10n.expenseAmount,
          hintText: l10n.expenseAmountHint,
          prefixIcon: Icons.attach_money,
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final n = double.tryParse(value?.trim() ?? '');
            if (n == null || n <= 0) {
              return l10n.expenseAmountRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.event_outlined,
          title: l10n.expenseDate,
          subtitle: l10n.selectExpenseDate,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _pickExpenseDate(l10n),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.expenseDate,
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
      DropdownItem(value: 'paid', label: l10n.paidStatus),
      DropdownItem(value: 'pending', label: l10n.pendingStatus),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          theme: theme,
          icon: Icons.numbers,
          title: l10n.expenseQuantity,
          subtitle: l10n.expenseQuantityHint,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: l10n.expenseQuantity,
          hintText: l10n.expenseQuantityHint,
          prefixIcon: Icons.numbers,
          controller: _quantityController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(
          theme: theme,
          icon: Icons.check_circle_outline,
          title: l10n.expensePaymentStatus,
          subtitle: l10n.selectExpensePaymentStatus,
        ),
        const SizedBox(height: 12),
        CustomDropdown<String>(
          label: l10n.expensePaymentStatus,
          hint: l10n.selectExpensePaymentStatus,
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
          title: l10n.expenseNotes,
          subtitle: l10n.expenseNotesHint,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: l10n.expenseNotes,
          hintText: l10n.expenseNotesHint,
          prefixIcon: Icons.notes_outlined,
          controller: _notesController,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          theme: theme,
          icon: Icons.info_outline,
          message: l10n.manualExpenseAccuracyNote,
        ),
      ],
    );
  }

  void _onStepContinue() {
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

    _confirmSubmit();
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _confirmSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    await ModernAlerts.showConfirmation(
      context: context,
      title: l10n.save,
      message: l10n.confirmSaveManualExpense,
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
    final farmUuid = _selectedFarmUuid;
    if (farmUuid == null || farmUuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.farmRequired)),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    final qty = int.tryParse(_quantityController.text.trim()) ?? 1;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final database = Provider.of<AppDatabase>(context, listen: false);
    final provider =
        Provider.of<FinanceExpenseProvider>(context, listen: false);

    int? farmerId;
    if (auth.isFarmer) {
      farmerId = int.tryParse(
        auth.currentUser?['roleId']?.toString() ?? '',
      );
    } else {
      final farm = await database.farmDao.getFarmByUuid(farmUuid);
      farmerId = farm?.farmerId;
    }

    if (!mounted) return;

    final uuid = const Uuid().v4();
    final notes = _notesController.text.trim();
    final subject = _subjectController.text.trim();

    final ok = await provider.addManualExpenseWithDialog(
      context,
      uuid: uuid,
      farmUuid: farmUuid,
      farmerId: farmerId,
      subjectType: subject,
      totalCost: amount,
      quantity: qty <= 0 ? 1 : qty,
      status: _selectedStatus,
      notes: notes.isEmpty ? null : notes,
      expenseDate: _expenseDate,
    );

    if (ok && mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget _buildInfoMessage(
    ThemeData theme,
    String message, {
    IconData icon = Icons.info_outline,
    InfoTone tone = InfoTone.neutral,
  }) {
    final baseColor = tone == InfoTone.warning
        ? Colors.amber
        : theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: baseColor),
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
        border: Border.all(
          color: primary.withValues(alpha: 0.2),
          width: 1,
        ),
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

enum InfoTone { neutral, warning }
