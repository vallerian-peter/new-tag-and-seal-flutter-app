import 'dart:developer';

import 'package:flutter/material.dart';
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
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class DisposalFormScreen extends StatefulWidget {
  final DisposalModel? disposal;
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;

  const DisposalFormScreen({
    super.key,
    this.disposal,
    this.farmUuid,
    this.livestockUuid,
    this.isBulk = false,
    this.bulkLivestockUuids,
  });

  bool get isEditMode => disposal != null;

  @override
  State<DisposalFormScreen> createState() => _DisposalFormScreenState();
}

class _DisposalFormScreenState extends State<DisposalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonsController = TextEditingController();
  final _remarksController = TextEditingController();

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
    _selectedLivestockUuid =
        _isBulk ? null : widget.livestockUuid ?? disposal?.livestockUuid;

    if (disposal == null) return;

    _reasonsController.text = disposal.reasons;
    _remarksController.text = disposal.remarks ?? '';
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
            .where((item) => livestock.any((animal) => animal.uuid == item.uuid))
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
        if (!_isBulk && _selectedLivestockUuid == null && livestock.isNotEmpty) {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.farmRequired)));
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
        return false;
      }
      return true;
    }

    if (_selectedLivestockUuid == null || _selectedLivestockUuid!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _reasonsController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.disposal}'
        : l10n.addDisposal;
    final submitLabel = widget.isEditMode ? l10n.update : l10n.save;

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
                        continueButtonText: null,
                        backButtonText: l10n.back,
                        finalStepButtonText: submitLabel,
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
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate() &&
          _hasValidLivestockSelection(l10n)) {
        setState(() => _currentStep = 1);
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (!_hasValidLivestockSelection(l10n)) return;

    await AlertDialogs.showConfirmation(
      context: context,
      title: widget.isEditMode ? l10n.update : l10n.save,
      message: widget.isEditMode
          ? l10n.confirmUpdateDisposal
          : l10n.confirmSaveDisposal,
      confirmText: widget.isEditMode ? l10n.update : l10n.save,
      cancelText: l10n.cancel,
      onConfirm: () async {
        if (!mounted) return;
        Navigator.of(context).pop(true);
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
    final livestockUuids = _isBulk
        ? _selectedBulkLivestock.map((livestock) => livestock.uuid).toList()
        : [
            if (widget.livestockUuid != null &&
                widget.livestockUuid!.isNotEmpty)
              widget.livestockUuid!
            else if (_selectedLivestockUuid != null &&
                _selectedLivestockUuid!.isNotEmpty)
              _selectedLivestockUuid!
          ];

    if (selectedFarmUuid == null || selectedFarmUuid.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.farmRequired)));
      return;
    }
    if (livestockUuids.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
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

    try {
      final remarks = _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim();

      if (widget.isEditMode && !_isBulk) {
        final existing = widget.disposal!;
        final updatedModel = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          disposalTypeId: disposalTypeId,
          reasons: reasons,
          remarks: remarks,
          status: _selectedStatus,
          synced: false,
          syncAction: existing.syncAction == 'create' ? 'create' : 'update',
          updatedAt: DateTime.now().toIso8601String(),
        );

        final updated = await eventsProvider.updateDisposalWithDialog(
          context,
          updatedModel,
        );
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        }
      } else if (_isBulk) {
        final created = await eventsProvider.addDisposalBatchWithDialog(
          context: context,
          farmUuid: selectedFarmUuid,
          livestockUuids: livestockUuids,
          disposalTypeId: disposalTypeId,
          reasons: reasons,
          remarks: remarks,
          status: _selectedStatus,
        );

        if (created.isNotEmpty && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final now = DateTime.now().toIso8601String();
        final uuid =
            'disposal-${DateTime.now().microsecondsSinceEpoch}-${livestockUuids.first.hashCode}';

        final newModel = DisposalModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          disposalTypeId: disposalTypeId,
          reasons: reasons,
          remarks: remarks,
          status: _selectedStatus,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );

        final created = await eventsProvider.addDisposalWithDialog(
          context,
          newModel,
        );
        if (created != null && mounted) {
          Navigator.pop(context, created);
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
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: baseColor.withValues(alpha: 0.25)),
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
