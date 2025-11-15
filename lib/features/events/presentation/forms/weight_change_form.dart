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
import 'package:new_tag_and_seal_flutter_app/core/components/weight_input_with_bluetooth.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/weight_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Weight Change Form Screen
///
/// Mirrors the structure and UX established in [FeedingFormScreen],
/// providing a multi-step experience with context selection and
/// Bluetooth-enabled weight capture.
class WeightChangeFormScreen extends StatefulWidget {
  final WeightChangeModel? weightChange;
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;

  const WeightChangeFormScreen({
    super.key,
    this.weightChange,
    this.farmUuid,
    this.livestockUuid,
    this.isBulk = false,
    this.bulkLivestockUuids,
  });

  bool get isEditMode => weightChange != null;

  @override
  State<WeightChangeFormScreen> createState() => _WeightChangeFormScreenState();
}

class _WeightChangeFormScreenState extends State<WeightChangeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey<FormState>();

  final _oldWeightController = TextEditingController();
  final _newWeightController = TextEditingController();
  final _remarksController = TextEditingController();

  static const List<DropdownItem<String>> _weightUnitItems = [
    DropdownItem<String>(value: 'g', label: 'g'),
    DropdownItem<String>(value: 'kg', label: 'kg'),
    DropdownItem<String>(value: 'ton', label: 'ton'),
  ];

  int _currentStep = 0;
  bool _isLoadingContext = true;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  List<Livestock> _selectedBulkLivestock = const [];
  bool _isLoadingLivestock = false;

  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;
  String _selectedOldWeightUnit = 'kg';
  String _selectedNewWeightUnit = 'kg';
  bool get _isBulk => widget.isBulk;

  @override
  void initState() {
    super.initState();
    _prefillIfEditing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeContext();
      }
    });
  }

  void _prefillIfEditing() {
    final weightChange = widget.weightChange;
    _selectedFarmUuid = widget.farmUuid;
    _selectedLivestockUuid = _isBulk ? null : widget.livestockUuid;

    if (weightChange == null) return;

    if (weightChange.oldWeight != null && weightChange.oldWeight!.trim().isNotEmpty) {
      final parsedOld = _parseWeight(weightChange.oldWeight!.trim());
      _oldWeightController.text = parsedOld.$1;
      _selectedOldWeightUnit = parsedOld.$2;
    }

    if (weightChange.newWeight.trim().isNotEmpty) {
      final parsedNew = _parseWeight(weightChange.newWeight.trim());
      _newWeightController.text = parsedNew.$1;
      _selectedNewWeightUnit = parsedNew.$2;
    }

    _remarksController.text = weightChange.remarks ?? '';

  }

  Future<void> _initializeContext() async {
    setState(() => _isLoadingContext = true);
    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
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
        livestock =
            await database.livestockDao.getActiveLivestockByFarmUuid(farmUuid);
      }

      String? livestockUuid = _selectedLivestockUuid;
      if (livestockUuid != null &&
          livestock.every((item) => item.uuid != livestockUuid)) {
        livestockUuid = null;
      }
      if (livestockUuid == null && livestock.isNotEmpty) {
        livestockUuid = livestock.first.uuid;
      }

      if (!mounted) return;
      setState(() {
        _farms = farms;
        _farmLivestock = livestock;
        _selectedFarmUuid = farmUuid;
        if (_isBulk) {
          final initialSelectionUuids = widget.bulkLivestockUuids ??
              _selectedBulkLivestock.map((item) => item.uuid).toList();
          _selectedBulkLivestock = livestock
              .where((item) => initialSelectionUuids.contains(item.uuid))
              .toList();
          _selectedLivestockUuid = null;
        } else {
          _selectedLivestockUuid = livestockUuid;
          _selectedBulkLivestock = const [];
        }
      });
    } catch (e) {
      debugPrint('❌ Failed to load context data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingContext = false);
      }
    }
  }

  Future<void> _onFarmSelected(String value) async {
    setState(() {
      _selectedFarmUuid = value;
      if (widget.livestockUuid == null) {
        _selectedLivestockUuid = null;
      }
      _isLoadingLivestock = true;
    });

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      final livestock =
          await database.livestockDao.getActiveLivestockByFarmUuid(value);

      if (!mounted) return;
      setState(() {
        _farmLivestock = livestock;
        if (_isBulk) {
          final validUuids = livestock.map((item) => item.uuid).toSet();
          _selectedBulkLivestock = _selectedBulkLivestock
              .where((item) => validUuids.contains(item.uuid))
              .toList();
        } else {
          if (_selectedLivestockUuid == null && livestock.isNotEmpty) {
            _selectedLivestockUuid = livestock.first.uuid;
          } else if (_selectedLivestockUuid != null &&
              livestock.every((item) => item.uuid != _selectedLivestockUuid)) {
            _selectedLivestockUuid =
                livestock.isNotEmpty ? livestock.first.uuid : null;
          }
        }
      });
    } catch (e) {
      debugPrint('❌ Failed to load livestock: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLivestock = false);
      }
    }
  }

  void _onLivestockSelected(String? value) {
    if (value == null) return;
    setState(() {
      _selectedLivestockUuid = value;
    });
  }

  Future<void> _openBulkLivestockSelector(AppLocalizations l10n) async {
    final farmUuid = _selectedFarmUuid;
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

    if (selection != null) {
      setState(() {
        _selectedBulkLivestock = selection;
      });
    }
  }

  (String, String) _parseWeight(String weight) {
    final trimmed = weight.trim();
    final regex = RegExp(r'^([0-9]+(?:\.[0-9]+)?)([a-zA-Z]+)?$');
    final match = regex.firstMatch(trimmed);
    if (match != null) {
      final numeric = match.group(1) ?? trimmed;
      final unit = (match.group(2) ?? '').trim().toLowerCase();
      if (_weightUnitItems.any((item) => item.value == unit)) {
        return (numeric, unit);
      }
      return (numeric, 'kg');
    }
    return (trimmed, 'kg');
  }

  @override
  void dispose() {
    _oldWeightController.dispose();
    _newWeightController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.weightChange}'
        : l10n.weightChange;
    final submitText = widget.isEditMode ? l10n.update : l10n.save;

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
      body: _isLoadingContext
          ? const Center(child: LoadingIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Form(
                  key: _formKey,
                  child: CustomStepper(
                    key: _stepperKey,
                    currentStep: _currentStep,
                    onStepContinue: _onStepContinue,
                    onStepCancel: _onStepCancel,
                    continueButtonText: null,
                    backButtonText: l10n.back,
                    finalStepButtonText: submitText,
                    steps: [
                      StepperStep(
                        title: l10n.basicInformation,
                        subtitle: l10n.recordsAndLogs,
                        icon: Icons.monitor_weight_outlined,
                        content: _buildStepOne(l10n, theme),
                      ),
                      StepperStep(
                        title: l10n.additionalDetails,
                        subtitle: l10n.additionalNotes,
                        icon: Icons.note_alt_outlined,
                        content: _buildStepTwo(l10n, theme),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStepOne(AppLocalizations l10n, ThemeData theme) {
    final farmItems = _farms
        .map(
          (farm) => DropdownItem<String>(
            value: farm.uuid,
            label: farm.name,
          ),
        )
        .toList();
    final livestockItems = _farmLivestock
        .map(
          (item) => DropdownItem<String>(
            value: item.uuid,
            label: item.name.isNotEmpty ? item.name : '${l10n.livestock} #${item.id}',
          ),
        )
        .toList();

    final isFarmLocked = widget.farmUuid != null && widget.farmUuid!.isNotEmpty;
    final isLivestockLocked =
        widget.livestockUuid != null && widget.livestockUuid!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.recordsAndLogs),
        const SizedBox(height: 20),
        if (_farms.isEmpty)
          _buildInfoBanner(
            message: l10n.logContextMissing,
            theme: theme,
            color: Colors.amber,
          )
        else ...[
          CustomDropdown<String>(
            label: l10n.selectFarm,
            hint: l10n.selectFarm,
            icon: Icons.agriculture,
            value: _selectedFarmUuid,
            dropdownItems: farmItems,
            enabled: !isFarmLocked,
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
          else if (_farmLivestock.isEmpty)
            _buildInfoBanner(
              message: l10n.noLivestockFound,
              theme: theme,
              color: theme.colorScheme.primary,
            )
          else if (_isBulk)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BulkLivestockSummaryTile(
                  count: _selectedBulkLivestock.length,
                  onTap: () => _openBulkLivestockSelector(l10n),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openBulkLivestockSelector(l10n),
                  icon: const Icon(Icons.playlist_add_check),
                  label: Text(
                    _selectedBulkLivestock.isEmpty
                        ? l10n.selectLivestock
                        : l10n.edit,
                  ),
                ),
              ],
            )
          else
            CustomDropdown<String>(
              label: l10n.selectLivestock,
              hint: l10n.selectLivestock,
              icon: Icons.pets,
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
        _buildSectionTitle(l10n.weightChange),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _oldWeightController,
          label: l10n.previousWeight,
          hintText: l10n.previousWeight,
          prefixIcon: Icons.history,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true, signed: false),
        ),
        const SizedBox(height: 12),
        CustomDropdown<String>(
          label: l10n.unit,
          hint: l10n.unit,
          icon: Icons.straighten,
          value: _selectedOldWeightUnit,
          dropdownItems: _weightUnitItems,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedOldWeightUnit = value);
          },
        ),
        const SizedBox(height: 16),
        WeightInputWithBluetooth(
          controller: _newWeightController,
          label: l10n.currentWeight,
          hintText: l10n.currentWeight,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.weightRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        CustomDropdown<String>(
          label: l10n.unit,
          hint: l10n.unit,
          icon: Icons.straighten,
          value: _selectedNewWeightUnit,
          dropdownItems: _weightUnitItems,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedNewWeightUnit = value);
          },
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.info_outline,
          message: l10n.ensureWeightDetailsAccuracy,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStepTwo(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.additionalNotes),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _remarksController,
          label: l10n.remarks,
          hintText: l10n.enterRemarksOptional,
          prefixIcon: Icons.notes_outlined,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: Constants.largeTextSize,
        fontWeight: FontWeight.bold,
        color: Constants.primaryColor,
      ),
    );
  }

  Widget _buildInfoBanner({
    required String message,
    required ThemeData theme,
    Color color = Colors.amber,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String message,
    required ThemeData theme,
  }) {
    return Container(
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
            icon,
            color: Constants.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: Constants.textSize,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() async {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    await AlertDialogs.showConfirmation(
      context: context,
      title: widget.isEditMode ? l10n.update : l10n.save,
      message: widget.isEditMode
          ? l10n.confirmUpdateWeightChange
          : l10n.confirmSaveWeightChange,
      confirmText: widget.isEditMode ? l10n.update : l10n.save,
      cancelText: l10n.cancel,
      onConfirm: () async {
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
    final selectedLivestockUuid = widget.livestockUuid ?? _selectedLivestockUuid;

    if (selectedFarmUuid == null || selectedFarmUuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logContextMissing)),
      );
      return;
    }

    if (!_isBulk &&
        (selectedLivestockUuid == null || selectedLivestockUuid.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logContextMissing)),
      );
      return;
    }

    final bulkLivestockUuids =
        _selectedBulkLivestock.map((item) => item.uuid).toList();
    if (_isBulk && bulkLivestockUuids.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.livestockRequired)));
      return;
    }

    try {
      final oldWeightValue = _oldWeightController.text.trim();
      final formattedOldWeight =
          oldWeightValue.isEmpty ? null : '$oldWeightValue$_selectedOldWeightUnit';
      final newWeightValue = _newWeightController.text.trim();
      final formattedNewWeight = '$newWeightValue$_selectedNewWeightUnit';

      if (widget.isEditMode && _isBulk) {
        log('⚠️ Bulk editing not supported for weight changes.');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
        return;
      }

      if (widget.isEditMode) {
        final existing = widget.weightChange!;
        final updated = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid!,
          oldWeight: formattedOldWeight,
          newWeight: formattedNewWeight,
          remarks: _remarksController.text.trim().isEmpty
              ? null
              : _remarksController.text.trim(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        final saved = await eventsProvider.updateWeightChangeWithDialog(
          context,
          updated,
        );
        if (saved != null && mounted) {
          Navigator.pop(context, saved);
        }
      } else if (_isBulk) {
        await eventsProvider.addWeightChangeBatchWithDialog(
          context: context,
          farmUuid: selectedFarmUuid,
          livestockUuids: bulkLivestockUuids,
          oldWeight: formattedOldWeight,
          newWeight: formattedNewWeight,
          remarks: _remarksController.text.trim().isEmpty
              ? null
              : _remarksController.text.trim(),
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final now = DateTime.now().toIso8601String();
        final uuid =
            '${DateTime.now().millisecondsSinceEpoch}-${selectedLivestockUuid.hashCode}-weight';

        final model = WeightChangeModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid!,
          oldWeight: formattedOldWeight,
          newWeight: formattedNewWeight,
          remarks: _remarksController.text.trim().isEmpty
              ? null
              : _remarksController.text.trim(),
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );

        final saved = await eventsProvider.addWeightChangeWithDialog(
          context,
          model,
        );
        if (saved != null && mounted) {
          Navigator.pop(context, saved);
        }
      }
    } catch (e) {
      log('❌ Error saving weight change: $e');
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.weightLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }
}

