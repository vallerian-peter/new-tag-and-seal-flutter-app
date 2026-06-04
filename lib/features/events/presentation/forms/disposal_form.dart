import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/app_date_picker.dart';
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
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/presentation/bill_creation_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/provider/finance_income_provider.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';

class DisposalFormScreen extends StatefulWidget {
  final DisposalModel? disposal;
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;
  final VoidCallback? onCompleted;

  const DisposalFormScreen({
    super.key,
    this.disposal,
    this.farmUuid,
    this.livestockUuid,
    this.isBulk = false,
    this.bulkLivestockUuids,
    this.onCompleted,
  });

  bool get isEditMode => disposal != null;

  @override
  State<DisposalFormScreen> createState() => _DisposalFormScreenState();
}

class _DisposalFormScreenState extends State<DisposalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventDateController = TextEditingController();
  final _reasonsController = TextEditingController();
  final _remarksController = TextEditingController();
  final _saleWeightController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _buyerNameController = TextEditingController();

  int _currentStep = 0;
  bool _isLoadingContext = true;
  bool _isLoadingLivestock = false;
  bool _isLoadingDisposalTypes = false;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  List<DropdownItem<int>> _disposalTypeItems = const [];

  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;
  List<Livestock> _selectedBulkLivestock = [];
  int? _selectedDisposalTypeId;
  DateTime? _selectedEventDate;
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
    final disposal = widget.disposal;
    _selectedFarmUuid = widget.farmUuid ?? disposal?.farmUuid;
    _selectedLivestockUuid = _isBulk
        ? null
        : widget.livestockUuid ?? disposal?.livestockUuid;

    if (disposal == null) return;

    if (disposal.eventDate != null && disposal.eventDate!.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(disposal.eventDate!);
      if (parsed != null) {
        _selectedEventDate = parsed;
        _eventDateController.text = DateFormat.yMMMd().add_jm().format(
          parsed.toLocal(),
        );
      }
    }
    _reasonsController.text = disposal.reasons;
    _remarksController.text = disposal.remarks ?? '';
    _saleWeightController.text = disposal.saleWeight?.toString() ?? '';
    _salePriceController.text = disposal.salePrice?.toString() ?? '';
    _buyerNameController.text = disposal.buyerName ?? '';
    _selectedDisposalTypeId = disposal.disposalTypeId;
    if (disposal.status.isNotEmpty) {
      _selectedStatus = disposal.status;
    }
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoadingContext = true;
      _isLoadingDisposalTypes = true;
    });
    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      await _loadContextData(database);
      await _loadDisposalTypes();
    } catch (e, stackTrace) {
      log('❌ Failed to initialize disposal form: $e', stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingContext = false;
          _isLoadingDisposalTypes = false;
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
            .where(
              (item) => livestock.any((animal) => animal.uuid == item.uuid),
            )
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

  Future<void> _loadDisposalTypes() async {
    try {
      final referenceProvider = Provider.of<LogAdditionalDataProvider>(
        context,
        listen: false,
      );

      if (!referenceProvider.isLoading &&
          referenceProvider.disposalTypes.isEmpty) {
        await referenceProvider.loadFromLocal();
      }

      final items = referenceProvider.disposalTypes
          .map((type) => DropdownItem<int>(value: type.id, label: type.name))
          .toList();

      log('🗑️ Disposal form: Loaded ${items.length} disposal types');

      if (!mounted) return;
      setState(() {
        _disposalTypeItems = items;
      });

      if (_selectedDisposalTypeId == null && items.isNotEmpty) {
        setState(() => _selectedDisposalTypeId = items.first.value);
      }
    } catch (e, stackTrace) {
      log('❌ Failed to load disposal types: $e', stackTrace: stackTrace);
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
        if (!_isBulk &&
            _selectedLivestockUuid == null &&
            livestock.isNotEmpty) {
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
  }

  void _onLivestockSelected(String? value) {
    if (value == null) return;
    setState(() => _selectedLivestockUuid = value);
  }

  Future<void> _openBulkLivestockSelector(AppLocalizations l10n) async {
    final farmUuid = _selectedFarmUuid ?? widget.farmUuid;
    if (farmUuid == null || farmUuid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.farmRequired)));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
        return false;
      }
      return true;
    }

    if (_selectedLivestockUuid == null || _selectedLivestockUuid!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _eventDateController.dispose();
    _reasonsController.dispose();
    _remarksController.dispose();
    _saleWeightController.dispose();
    _salePriceController.dispose();
    _buyerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if we're in edit mode (same pattern as Farm form)
    final isEditMode = widget.isEditMode;

    final title = isEditMode
        ? '${l10n.edit} ${l10n.disposal}'
        : l10n.addDisposal;

    // Button text changes based on edit mode and current step (same pattern as Farm form)
    final buttonText = _currentStep == 1
        ? (isEditMode ? l10n.update : l10n.save)
        : l10n.continueButton;

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
      body: (_isLoadingContext || _isLoadingDisposalTypes)
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
                        continueButtonText: buttonText,
                        backButtonText: l10n.back,
                        finalStepButtonText:
                            null, // Use continueButtonText instead
                        steps: [
                          StepperStep(
                            title: l10n.basicInformation,
                            subtitle: l10n.recordsAndLogs,
                            icon: Icons.analytics_outlined,
                            content: _buildContextStep(l10n, theme),
                          ),
                          StepperStep(
                            title: l10n.disposalDetails,
                            subtitle: l10n.disposalDetailsSubtitle,
                            icon: Icons.change_circle_outlined,
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
            message: l10n.logContextMissing,
            theme: theme,
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
              message: l10n.noLivestockFound,
              theme: theme,
              icon: Icons.pets_outlined,
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
        _buildInfoBanner(
          message: l10n.disposalContextInfo,
          theme: theme,
          icon: Icons.info_outline,
        ),
      ],
    );
  }

  Widget _buildDetailsStep(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.disposalDetails, theme),
        const SizedBox(height: 16),
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
          controller: _reasonsController,
          label: l10n.disposalReasons,
          hintText: l10n.enterDisposalReasons,
          prefixIcon: Icons.article_outlined,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.disposalReasons;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        if (_disposalTypeItems.isEmpty)
          _buildInfoBanner(
            message: l10n.disposalTypeOptionsMissing,
            theme: theme,
            icon: Icons.warning_amber_rounded,
            tone: InfoBannerTone.warning,
          )
        else
          CustomDropdown<int>(
            label: l10n.disposalTypeId,
            hint: l10n.selectDisposalType,
            icon: Icons.category_outlined,
            value: _selectedDisposalTypeId,
            dropdownItems: _disposalTypeItems,
            onChanged: (value) =>
                setState(() => _selectedDisposalTypeId = value),
            validator: (value) {
              if (_disposalTypeItems.isNotEmpty && value == null) {
                return l10n.disposalTypeRequired;
              }
              return null;
            },
          ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          label: l10n.disposalStatus,
          hint: l10n.selectStatus,
          icon: Icons.verified_outlined,
          value: _selectedStatus,
          dropdownItems: _statusItems(l10n),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedStatus = value);
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _remarksController,
          label: l10n.remarks,
          hintText: l10n.enterRemarksOptional,
          prefixIcon: Icons.notes_outlined,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _saleWeightController,
          label: l10n.saleWeight,
          hintText: l10n.optionalFieldHint,
          prefixIcon: Icons.scale_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _salePriceController,
          label: '${l10n.salePrice}${_isSaleDisposalTypeSelected ? ' *' : ''}',
          hintText: l10n.optionalFieldHint,
          prefixIcon: Icons.attach_money_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final raw = value?.trim() ?? '';
            if (_isSaleDisposalTypeSelected && raw.isEmpty) {
              return l10n.salePrice;
            }
            if (raw.isNotEmpty && double.tryParse(raw) == null) {
              return l10n.salePrice;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _buyerNameController,
          label: l10n.buyerName,
          hintText: l10n.optionalFieldHint,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 24),
        _buildInfoBanner(
          message: l10n.disposalNotesInfo,
          theme: theme,
          icon: Icons.lightbulb_outline,
        ),
      ],
    );
  }

  void _onStepContinue() async {
    final l10n = AppLocalizations.of(context)!;

    // Same pattern as Farm form: validate current step before moving forward
    if (_currentStep < 1) {
      if (_formKey.currentState!.validate() &&
          _hasValidLivestockSelection(l10n)) {
        setState(() => _currentStep++);
      }
      return;
    }

    // Final step - validate and show confirmation dialog (same pattern as Farm form)
    if (_formKey.currentState!.validate() &&
        _hasValidLivestockSelection(l10n)) {
      final isEditMode = widget.isEditMode;

      // Show confirmation dialog
      await AlertDialogs.showConfirmation(
        context: context,
        title: isEditMode ? l10n.update : l10n.save,
        message: isEditMode
            ? l10n.confirmUpdateDisposal
            : l10n.confirmSaveDisposal,
        confirmText: isEditMode ? l10n.update : l10n.save,
        cancelText: l10n.cancel,
        onConfirm: () async {
          Navigator.of(context).pop(true);
          await _submit();
        },
      );
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final financeIncomeProvider = Provider.of<FinanceIncomeProvider>(
      context,
      listen: false,
    );

    final selectedFarmUuid = widget.farmUuid ?? _selectedFarmUuid;
    final livestockUuids = _isBulk
        ? _selectedBulkLivestock.map((livestock) => livestock.uuid).toList()
        : [
            if (widget.livestockUuid != null &&
                widget.livestockUuid!.isNotEmpty)
              widget.livestockUuid!
            else if (_selectedLivestockUuid != null &&
                _selectedLivestockUuid!.isNotEmpty)
              _selectedLivestockUuid!,
          ];

    if (selectedFarmUuid == null || selectedFarmUuid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.farmRequired)));
      return;
    }
    if (livestockUuids.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
      return;
    }

    final reasons = _reasonsController.text.trim();
    if (reasons.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.disposalReasons)));
      return;
    }

    final disposalTypeId = _selectedDisposalTypeId;
    if (_disposalTypeItems.isNotEmpty && disposalTypeId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.disposalTypeRequired)));
      return;
    }

    final saleWeight = _parseOptionalDouble(_saleWeightController.text);
    final salePrice = _parseOptionalDouble(_salePriceController.text);
    final buyerName = _buyerNameController.text.trim().isEmpty
        ? null
        : _buyerNameController.text.trim();

    if (_isSaleDisposalTypeSelected && salePrice == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.salePrice)));
      return;
    }

    try {
      final remarks = _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim();

      // Check if we're in edit mode (same pattern as Farm form)
      final isEditMode = widget.isEditMode;

      if (isEditMode && !_isBulk) {
        // Update existing disposal (same pattern as Farm form - use method without dialog)
        final existing = widget.disposal!;
        final eventDateIso = _selectedEventDate?.toIso8601String();
        final updatedModel = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          disposalTypeId: disposalTypeId,
          eventDate: eventDateIso ?? existing.eventDate,
          reasons: reasons,
          remarks: remarks,
          saleWeight: saleWeight,
          salePrice: salePrice,
          buyerName: buyerName,
          status: _selectedStatus,
          synced: false,
          syncAction: existing.syncAction == 'create' ? 'create' : 'update',
          updatedAt: DateTime.now().toIso8601String(),
        );

        AlertDialogs.showLoading(
          context: context,
          title: l10n.save,
          message: '',
          isDismissible: false,
        );

        final updated = await eventsProvider.updateDisposal(updatedModel);

        if (mounted) {
          Navigator.of(context).pop();

          await financeIncomeProvider.upsertDisposalIncome(updated);

          await BillCreationHelper.maybeCreateBillForLog(
            context: context,
            logType: EventLogTypes.disposal,
            farmUuid: selectedFarmUuid,
            subjectUuid: updated.uuid,
            quantity: 1,
            numberOfLivestock: 1,
          );

          if (mounted) {
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: '${l10n.success}!',
              buttonText: l10n.ok,
            );
            if (mounted) {
              Navigator.pop(context, updated);
            }
          }
        }
      } else if (_isBulk) {
        // Bulk creation - keep existing dialog-based flow
        AlertDialogs.showLoading(
          context: context,
          title: l10n.save,
          message: l10n.bulkOperationInProgress,
          isDismissible: false,
        );

        final created = <DisposalModel>[];
        for (final animalUuid in livestockUuids) {
          final now = DateTime.now().toIso8601String();
          final uuid =
              'disposal-${DateTime.now().microsecondsSinceEpoch}-${animalUuid.hashCode}';
          final eventDateIso = _selectedEventDate?.toIso8601String();
          final model = DisposalModel(
            uuid: uuid,
            farmUuid: selectedFarmUuid,
            livestockUuid: animalUuid,
            disposalTypeId: disposalTypeId,
            eventDate: eventDateIso,
            reasons: reasons,
            remarks: remarks,
            saleWeight: saleWeight,
            salePrice: salePrice,
            buyerName: buyerName,
            status: _selectedStatus,
            synced: false,
            syncAction: 'create',
            createdAt: now,
            updatedAt: now,
          );
          created.add(await eventsProvider.addDisposal(model));
        }

        if (mounted) {
          Navigator.of(context).pop();

          await financeIncomeProvider.upsertDisposalIncomes(created);

          await BillCreationHelper.maybeCreateBillForLog(
            context: context,
            logType: EventLogTypes.disposal,
            farmUuid: selectedFarmUuid,
            subjectUuid: created.first.uuid,
            quantity: 1,
            numberOfLivestock: livestockUuids.length,
          );

          if (mounted) {
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: '${l10n.success}!',
              buttonText: l10n.ok,
            );
            if (mounted) {
              Navigator.pop(context, true);
              widget.onCompleted?.call();
            }
          }
        }
      } else {
        // Create new disposal - keep existing dialog-based flow
        final now = DateTime.now().toIso8601String();
        final uuid =
            'disposal-${DateTime.now().microsecondsSinceEpoch}-${livestockUuids.first.hashCode}';

        final eventDateIso = _selectedEventDate?.toIso8601String();
        final newModel = DisposalModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          disposalTypeId: disposalTypeId,
          eventDate: eventDateIso,
          reasons: reasons,
          remarks: remarks,
          saleWeight: saleWeight,
          salePrice: salePrice,
          buyerName: buyerName,
          status: _selectedStatus,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );

        AlertDialogs.showLoading(
          context: context,
          title: l10n.save,
          message: '',
          isDismissible: false,
        );

        final created = await eventsProvider.addDisposal(newModel);

        if (mounted) {
          Navigator.of(context).pop();

          await financeIncomeProvider.upsertDisposalIncome(created);

          await BillCreationHelper.maybeCreateBillForLog(
            context: context,
            logType: EventLogTypes.disposal,
            farmUuid: selectedFarmUuid,
            subjectUuid: created.uuid,
            quantity: 1,
            numberOfLivestock: 1,
          );

          if (mounted) {
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: '${l10n.success}!',
              buttonText: l10n.ok,
            );
            if (mounted) {
              Navigator.pop(context, true);
              widget.onCompleted?.call();
            }
          }
        }
      }
    } catch (e, stackTrace) {
      log('❌ Failed to save disposal log: $e', stackTrace: stackTrace);
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.disposalLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }

  List<DropdownItem<String>> _statusItems(AppLocalizations l10n) => [
    DropdownItem(value: 'pending', label: l10n.statusPending),
    DropdownItem(value: 'completed', label: l10n.statusCompleted),
    DropdownItem(value: 'failed', label: l10n.statusFailed),
  ];

  Future<void> _pickEventDate() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : whiteColor;
    final initial = _selectedEventDate ?? DateTime.now();

    final date = await showAppDatePicker(
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
      _eventDateController.text = DateFormat.yMMMd().add_jm().format(
        combined.toLocal(),
      );
    });
  }

  bool get _isSaleDisposalTypeSelected {
    final selectedId = _selectedDisposalTypeId;
    if (selectedId == null) return false;
    for (final item in _disposalTypeItems) {
      if (item.value == selectedId) {
        final label = item.label.toLowerCase();
        return label.contains('sale') ||
            label.contains('sold') ||
            label.contains('uuzaji');
      }
    }
    return false;
  }

  double? _parseOptionalDouble(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Constants.primaryColor,
      ),
    );
  }

  Widget _buildInfoBanner({
    required String message,
    required ThemeData theme,
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
        color: baseColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
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
