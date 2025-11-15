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
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/feeding_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// Feeding Form Screen
///
/// Used to create or edit feeding logs. Mirrors the styling and UX patterns
/// defined by `FarmFormScreen` (multi-step, dialogs, localization, theme aware).
class FeedingFormScreen extends StatefulWidget {
  final FeedingModel? feeding;
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;

  const FeedingFormScreen({
    super.key,
    this.farmUuid,
    this.livestockUuid,
    this.feeding,
    this.isBulk = false,
    this.bulkLivestockUuids,
  });

  bool get isEditMode => feeding != null;

  @override
  State<FeedingFormScreen> createState() => _FeedingFormScreenState();
}

class _FeedingFormScreenState extends State<FeedingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nextFeedingTimeController = TextEditingController();
  final _remarksController = TextEditingController();

  int _currentStep = 0;
  int? _selectedFeedingTypeId;
  bool _isLoadingData = true;
  List<DropdownItem<int>> _feedingTypeItems = const [];
  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  List<Livestock> _selectedBulkLivestock = const [];
  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;
  bool _isLoadingLivestock = false;
  DateTime? _selectedNextFeedingTime;
  static const List<DropdownItem<String>> _unitItems = [
    DropdownItem<String>(value: 'g', label: 'g'),
    DropdownItem<String>(value: 'kg', label: 'kg'),
    DropdownItem<String>(value: 'ton', label: 'ton'),
  ];
  String _selectedUnit = 'kg';
  bool get _isBulk => widget.isBulk;

  @override
  void initState() {
    super.initState();
    _prefillFormIfEditing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  void _prefillFormIfEditing() {
    final feeding = widget.feeding;
    _selectedFarmUuid = widget.farmUuid;
    _selectedLivestockUuid = _isBulk ? null : widget.livestockUuid;

    if (feeding == null) return;

    _selectedFeedingTypeId = feeding.feedingTypeId;
    final parsedAmount = _parseAmountAndUnit(feeding.amount);
    _amountController.text = parsedAmount.$1;
    if (_unitItems.any((item) => item.value == parsedAmount.$2)) {
      _selectedUnit = parsedAmount.$2;
    }
    _selectedNextFeedingTime = DateTime.tryParse(feeding.nextFeedingTime);
    if (_selectedNextFeedingTime != null) {
      _nextFeedingTimeController.text = _formatDisplayDateTime(_selectedNextFeedingTime!);
    } else {
      _nextFeedingTimeController.clear();
    }
    _remarksController.text = feeding.remarks ?? '';
  }

  Future<void> _loadFeedingTypes() async {
    try {
      final logAdditionalProvider =
          Provider.of<LogAdditionalDataProvider>(context, listen: false);
      await logAdditionalProvider.loadFromLocal();

      final feedingTypes = logAdditionalProvider.feedingTypes;
      log('📥 Loaded ${feedingTypes.length} feeding types');
      for (final type in feedingTypes) {
        log(' • FeedingType -> id: ${type.id}, name: ${type.name}');
      }
      if (!mounted) return;
      setState(() {
        _feedingTypeItems = feedingTypes
            .map(
              (type) => DropdownItem<int>(
                value: type.id,
                label: type.name,
              ),
            )
            .toList();
      });
    } catch (e) {
      debugPrint('❌ Failed to load feeding types: $e');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.eventsLoadFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      });
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoadingData = true);
    try {
      await _loadFeedingTypes();
      await _loadContextData();
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _loadContextData() async {
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
      debugPrint('❌ Failed to load farm/livestock context: $e');
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
      debugPrint('❌ Failed to load livestock for farm: $e');
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

  (String, String) _parseAmountAndUnit(String amount) {
    final trimmed = amount.trim();
    final regex = RegExp(r'^([0-9]+(?:\.[0-9]+)?)([a-zA-Z]+)?$');
    final match = regex.firstMatch(trimmed);
    if (match != null) {
      final numeric = match.group(1) ?? trimmed;
      final unit = (match.group(2) ?? '').trim();
      return (numeric, unit.isNotEmpty ? unit : _selectedUnit);
    }
    return (trimmed, _selectedUnit);
  }

  String _formatDisplayDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_jm().format(dateTime.toLocal());
  }

  List<DropdownItem<String>> _buildFarmDropdownItems() {
    return _farms
        .map(
          (farm) => DropdownItem<String>(
            value: farm.uuid,
            label: farm.name,
          ),
        )
        .toList();
  }

  List<DropdownItem<String>> _buildLivestockDropdownItems(AppLocalizations l10n) {
    return _farmLivestock
        .map(
          (item) => DropdownItem<String>(
            value: item.uuid,
            label: item.name.isNotEmpty
                ? item.name
                : '${l10n.livestock} #${item.id}',
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nextFeedingTimeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title =
        widget.isEditMode ? '${l10n.edit} ${l10n.feeding}' : l10n.addFeeding;
    final submitText =
        widget.isEditMode ? l10n.update : l10n.save; // localization required

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
      body: _isLoadingData
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
                        subtitle: l10n.feedingDetailsSubtitle,
                        icon: Icons.restaurant_outlined,
                        content: _buildStepOne(l10n, theme),
                      ),
                      StepperStep(
                        title: l10n.additionalDetails,
                        subtitle: l10n.feedingNotesSubtitle,
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

  Widget _buildStepOne(AppLocalizations l10n, ThemeData theme) {
    final farmDropdownItems = _buildFarmDropdownItems();
    final livestockDropdownItems = _buildLivestockDropdownItems(l10n);
    final isFarmLocked = widget.farmUuid != null && widget.farmUuid!.isNotEmpty;
    final isLivestockLocked =
        widget.livestockUuid != null && widget.livestockUuid!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.recordsAndLogs),
        const SizedBox(height: 20),
        if (_farms.isEmpty)
          _buildContextWarning(theme, l10n)
        else ...[
          CustomDropdown<String>(
            label: l10n.selectFarm,
            hint: l10n.selectFarm,
            icon: Icons.agriculture,
            value: _selectedFarmUuid,
            dropdownItems: farmDropdownItems,
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
            _buildNoLivestockInfo(theme, l10n)
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
              dropdownItems: livestockDropdownItems,
              enabled: !isLivestockLocked,
              onChanged: (value) => _onLivestockSelected(value),
              validator: (value) {
                if ((value == null || value.isEmpty) &&
                    (widget.livestockUuid == null ||
                        widget.livestockUuid!.isEmpty)) {
                  return l10n.livestockRequired;
                }
                return null;
              },
            ),
          const SizedBox(height: 24),
        ],

        _buildSectionTitle(l10n.feedingDetails),
        const SizedBox(height: 20),
        CustomDropdown<int>(
          label: l10n.feedingType,
          hint: l10n.selectFeedingType,
          icon: Icons.category_outlined,
          value: _selectedFeedingTypeId,
          dropdownItems: _feedingTypeItems,
          onChanged: (value) => setState(() => _selectedFeedingTypeId = value),
          validator: (value) {
            if (value == null) {
              return l10n.feedingTypeRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: _amountController,
                label: l10n.amount,
                hintText: l10n.enterAmount,
                prefixIcon: Icons.scale_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.amountRequired;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown<String>(
                label: l10n.unit,
                hint: l10n.unit,
                icon: Icons.straighten_outlined,
                value: _selectedUnit,
                dropdownItems: _unitItems,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedUnit = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _nextFeedingTimeController,
          label: l10n.nextFeedingTime,
          hintText: l10n.enterNextFeedingTime,
          prefixIcon: Icons.schedule_outlined,
          readOnly: true,
          onTap: _pickNextFeedingDateTime,
          validator: (value) {
            if (_selectedNextFeedingTime == null) {
              return l10n.nextFeedingTimeRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.info_outline,
          message: l10n.ensureFeedingDetailsAccuracy,
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
        const SizedBox(height: 20),
        CustomTextField(
          controller: _remarksController,
          label: l10n.remarks,
          hintText: l10n.enterRemarksOptional,
          prefixIcon: Icons.notes_outlined,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.lightbulb_outline,
          message: l10n.feedingNotesInfo,
          theme: theme,
        ),
      ],
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

  Widget _buildContextWarning(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        l10n.logContextMissing,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildNoLivestockInfo(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l10n.noLivestockFound,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
    );
  }

  Future<void> _pickNextFeedingDateTime() async {
    final initialDate = _selectedNextFeedingTime ??
        (widget.feeding != null
            ? DateTime.parse(widget.feeding!.nextFeedingTime)
            : DateTime.now());

    final theme = Theme.of(context);
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year, initialDate.month, initialDate.day),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: Constants.primaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: Constants.primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
            dialogBackgroundColor: theme.brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
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
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: Constants.primaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: Constants.primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
            dialogBackgroundColor: theme.brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
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
    if (time == null) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    _selectedNextFeedingTime = combined;
    _nextFeedingTimeController.text = _formatDisplayDateTime(combined);
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
          ? l10n.confirmUpdateFeeding
          : l10n.confirmSaveFeeding,
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

    final feedingTypeId = _selectedFeedingTypeId!;
    final amount = _amountController.text.trim();
    final amountWithUnit =
        amount.isNotEmpty ? '$amount$_selectedUnit' : amount;
    final nextFeedingTimeIso = _selectedNextFeedingTime?.toIso8601String() ?? '';
    final remarks = _remarksController.text.trim().isEmpty
        ? null
        : _remarksController.text.trim();
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
        _selectedBulkLivestock.map((livestock) => livestock.uuid).toList();
    if (_isBulk && bulkLivestockUuids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.livestockRequired)),
      );
      return;
    }

    try {
      if (widget.isEditMode && _isBulk) {
        log('⚠️ Bulk editing is not supported for feedings.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.comingSoon)),
        );
        return;
      }

      if (widget.isEditMode) {
        final existing = widget.feeding!;
        final effectiveNextFeedingTime =
            nextFeedingTimeIso.isNotEmpty ? nextFeedingTimeIso : existing.nextFeedingTime;
        final updatedModel = existing.copyWith(
          feedingTypeId: feedingTypeId,
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid!,
          nextFeedingTime: effectiveNextFeedingTime,
          amount: amountWithUnit,
          remarks: remarks,
          updatedAt: DateTime.now().toIso8601String(),
        );

        final updated =
            await eventsProvider.updateFeedingWithDialog(context, updatedModel);
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        }
      } else if (_isBulk) {
        final effectiveNextFeedingTime =
            nextFeedingTimeIso.isNotEmpty ? nextFeedingTimeIso : DateTime.now().toIso8601String();
        await eventsProvider.addFeedingBatchWithDialog(
          context: context,
          farmUuid: selectedFarmUuid,
          livestockUuids: bulkLivestockUuids,
          feedingTypeId: feedingTypeId,
          nextFeedingTime: effectiveNextFeedingTime,
          amount: amountWithUnit,
          remarks: remarks,
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final now = DateTime.now().toIso8601String();
        final effectiveNextFeedingTime =
            nextFeedingTimeIso.isNotEmpty ? nextFeedingTimeIso : now;
        final uuid =
            '${DateTime.now().millisecondsSinceEpoch}-${selectedLivestockUuid.hashCode}-$feedingTypeId';

        final newModel = FeedingModel(
          uuid: uuid,
          feedingTypeId: feedingTypeId,
          farmUuid: selectedFarmUuid,
          livestockUuid: selectedLivestockUuid!,
          nextFeedingTime: effectiveNextFeedingTime,
          amount: amountWithUnit,
          remarks: remarks,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );

        final created = await eventsProvider.addFeedingWithDialog(context, newModel);
        if (created != null && mounted) {
          Navigator.pop(context, created);
        }
      }
    } catch (e) {
      debugPrint('❌ Error saving feeding log: $e');
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.feedingLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }
}