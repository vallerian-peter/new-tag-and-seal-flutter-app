import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_dropdown.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_stepper.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/transfer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_selector_page.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/bulk_livestock_summary_tile.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class TransferFormScreen extends StatefulWidget {
  final TransferModel? transfer;
  final String? farmUuid;
  final String? livestockUuid;
  final bool isBulk;
  final List<String>? bulkLivestockUuids;

  const TransferFormScreen({
    super.key,
    this.transfer,
    this.farmUuid,
    this.livestockUuid,
    this.isBulk = false,
    this.bulkLivestockUuids,
  });

  bool get isEditMode => transfer != null;

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toFarmUuidController = TextEditingController();
  final _transporterIdController = TextEditingController();
  final _reasonController = TextEditingController();
  final _priceController = TextEditingController();
  final _remarksController = TextEditingController();
  final _transferDateController = TextEditingController();
  String _selectedCurrency = 'Tshs';

  int _currentStep = 0;
  bool _isLoadingContext = true;
  bool _isLoadingLivestock = false;

  List<Farm> _farms = const [];
  List<Livestock> _farmLivestock = const [];
  List<Livestock> _selectedBulkLivestock = const [];

  String? _selectedFarmUuid;
  String? _selectedLivestockUuid;
  String _selectedStatus = 'completed';
  DateTime? _selectedTransferDate;

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
    final transfer = widget.transfer;

    _selectedFarmUuid = widget.farmUuid ?? transfer?.farmUuid;
    _selectedLivestockUuid =
        _isBulk ? null : widget.livestockUuid ?? transfer?.livestockUuid;

    if (transfer == null) {
      final now = DateTime.now();
      _selectedTransferDate = now;
      _transferDateController.text =
          DateFormat.yMMMd().add_jm().format(now.toLocal());
      return;
    }

    _toFarmUuidController.text = transfer.toFarmUuid ?? '';
    _transporterIdController.text =
        transfer.transporterId != null ? '${transfer.transporterId}' : '';
    _reasonController.text = transfer.reason ?? '';
    _priceController.text = transfer.price ?? '';
    _remarksController.text = transfer.remarks ?? '';

    if (transfer.status != null && transfer.status!.isNotEmpty) {
      _selectedStatus = transfer.status!;
    }

    if (transfer.price != null && transfer.price!.isNotEmpty) {
      final price = transfer.price!;
      final match = RegExp(r'^([0-9]+(?:\.[0-9]+)?)\s?([A-Za-z$£€]+)$')
          .firstMatch(price);
      if (match != null) {
        _priceController.text = match.group(1)!;
        _selectedCurrency = match.group(2)!;
      } else {
        _priceController.text = price;
      }
    }

    final parsedDate = DateTime.tryParse(transfer.transferDate);
    if (parsedDate != null) {
      _selectedTransferDate = parsedDate;
      _transferDateController.text =
          DateFormat.yMMMd().add_jm().format(parsedDate.toLocal());
    }
  }

  Future<void> _initialize() async {
    setState(() => _isLoadingContext = true);
    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      await _loadContextData(database);
    } catch (e, stackTrace) {
      log('❌ Failed to initialize transfer form: $e', stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() => _isLoadingContext = false);
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
      if (livestockUuid == null &&
          livestock.isNotEmpty &&
          (widget.livestockUuid == null || widget.livestockUuid!.isEmpty)) {
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
      final livestock =
          await database.livestockDao.getActiveLivestockByFarmUuid(value);

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
    _toFarmUuidController.dispose();
    _transporterIdController.dispose();
    _reasonController.dispose();
    _priceController.dispose();
    _remarksController.dispose();
    _transferDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title = widget.isEditMode
        ? '${l10n.edit} ${l10n.transfer}'
        : l10n.addTransfer;
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
      body: _isLoadingContext
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
                            title: l10n.transferDetails,
                            subtitle: l10n.transferDetailsSubtitle,
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
          message: l10n.transferContextInfo,
          theme: theme,
          icon: Icons.info_outline,
        ),
      ],
    );
  }

  Widget _buildDetailsStep(AppLocalizations l10n, ThemeData theme) {
    final statusItems = [
      DropdownItem<String>(value: 'scheduled', label: l10n.statusScheduled),
      DropdownItem<String>(value: 'pending', label: l10n.statusPending),
      DropdownItem<String>(value: 'completed', label: l10n.statusCompleted),
      DropdownItem<String>(value: 'cancelled', label: l10n.statusCancelled),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.transferDetails, theme),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _toFarmUuidController,
          label: l10n.toFarmUuidLabel,
          hintText: l10n.enterToFarmUuid,
          prefixIcon: Icons.agriculture_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.toFarmUuidRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildInfoBanner(
          message: l10n.transferToFarmUuidWarning,
          theme: theme,
          icon: Icons.warning_amber_rounded,
          tone: InfoBannerTone.warning,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _transporterIdController,
          label: l10n.transporterIdLabel,
          hintText: l10n.enterTransporterId,
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _reasonController,
          label: l10n.reason,
          hintText: l10n.enterTransferReason,
          prefixIcon: Icons.article_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: _priceController,
                label: l10n.transferPriceLabel,
                hintText: l10n.enterTransferPrice,
                prefixIcon: Icons.payments_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CustomDropdown<String>(
                label: l10n.transferCurrencyLabel,
                hint: l10n.selectTransferCurrency,
                icon: Icons.currency_exchange_outlined,
                value: _selectedCurrency,
                dropdownItems: [
                  DropdownItem(value: 'Tshs', label: l10n.currencyTsh),
                  DropdownItem(value: '\$', label: l10n.currencyUsd),
                  DropdownItem(value: '£', label: l10n.currencyGbp),
                  DropdownItem(value: '€', label: l10n.currencyEur),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedCurrency = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _transferDateController,
          label: l10n.transferDateLabel,
          hintText: l10n.selectTransferDate,
          prefixIcon: Icons.calendar_month_outlined,
          readOnly: true,
          onTap: _pickTransferDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.transferDateRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          label: l10n.transferStatusLabel,
          hint: l10n.transferStatusLabel,
          icon: Icons.flag_outlined,
          value: _selectedStatus,
          dropdownItems: statusItems,
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
          maxLines: 3,
        ),
      ],
    );
  }

  Future<void> _pickTransferDate() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final initialDate = _selectedTransferDate ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: l10n.selectTransferDate,
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: l10n.selectTransferDate,
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
      _selectedTransferDate = combined;
      _transferDateController.text =
          DateFormat.yMMMd().add_jm().format(combined.toLocal());
    });
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
          ? l10n.confirmUpdateTransfer
          : l10n.confirmSaveTransfer,
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

    final toFarmUuid = _toFarmUuidController.text.trim();
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
    if (toFarmUuid.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.toFarmUuidRequired)));
      return;
    }

    final transporterIdText = _transporterIdController.text.trim();
    int? transporterId;
    if (transporterIdText.isNotEmpty) {
      transporterId = int.tryParse(transporterIdText);
      if (transporterId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invalidTransporterId)),
        );
        return;
      }
    }

    final reason = _reasonController.text.trim().isEmpty
        ? null
        : _reasonController.text.trim();
    final rawPrice = _priceController.text.trim();
    final price = rawPrice.isEmpty ? null : '$rawPrice$_selectedCurrency';
    final remarks = _remarksController.text.trim().isEmpty
        ? null
        : _remarksController.text.trim();
    final transferDateIso =
        _selectedTransferDate?.toIso8601String() ?? DateTime.now().toIso8601String();

    try {
      if (widget.isEditMode && !_isBulk) {
        final existing = widget.transfer!;
        final updatedModel = existing.copyWith(
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          toFarmUuid: toFarmUuid,
          transporterId: transporterId,
          reason: reason,
          price: price,
          transferDate: transferDateIso,
          remarks: remarks,
          status: _selectedStatus,
          synced: false,
          syncAction: existing.syncAction == 'create' ? 'create' : 'update',
          updatedAt: DateTime.now().toIso8601String(),
        );

        final updated = await eventsProvider.updateTransferWithDialog(
          context,
          updatedModel,
        );
        if (updated != null && mounted) {
          Navigator.pop(context, updated);
        }
      } else if (_isBulk) {
        final created = await eventsProvider.addTransferBatchWithDialog(
          context: context,
          farmUuid: selectedFarmUuid,
          livestockUuids: livestockUuids,
          toFarmUuid: toFarmUuid,
          transporterId: transporterId,
          reason: reason,
          price: price,
          transferDate: transferDateIso,
          remarks: remarks,
          status: _selectedStatus,
        );
        if (created.isNotEmpty && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final now = DateTime.now();
        final uuid =
            'transfer-${now.microsecondsSinceEpoch}-${livestockUuids.first.hashCode}';

        final newModel = TransferModel(
          uuid: uuid,
          farmUuid: selectedFarmUuid,
          livestockUuid: livestockUuids.first,
          toFarmUuid: toFarmUuid,
          transporterId: transporterId,
          reason: reason,
          price: price,
          transferDate: transferDateIso,
          remarks: remarks,
          status: _selectedStatus,
          synced: false,
          syncAction: 'create',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
          farmName: null,
          toFarmName: null,
          livestockName: null,
        );

        final created = await eventsProvider.addTransferWithDialog(
          context,
          newModel,
        );
        if (created != null && mounted) {
          Navigator.pop(context, created);
        }
      }
    } catch (e, stackTrace) {
      log('❌ Failed to save transfer log: $e', stackTrace: stackTrace);
      if (!mounted) return;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.transferLogSaveFailed,
        buttonText: l10n.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Constants.largeTextSize - 2,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInfoBanner({
    required String message,
    required ThemeData theme,
    required IconData icon,
    InfoBannerTone tone = InfoBannerTone.neutral,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = tone == InfoBannerTone.warning
        ? (isDark
            ? Colors.orange.withOpacity(0.15)
            : Colors.orange.withOpacity(0.1))
        : (isDark
            ? theme.colorScheme.surface.withOpacity(0.6)
            : Colors.white);
    final borderColor = tone == InfoBannerTone.warning
        ? Colors.orange.withOpacity(0.3)
        : theme.colorScheme.outline.withOpacity(0.12);
    final iconColor =
        tone == InfoBannerTone.warning ? Colors.orange : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.75),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum InfoBannerTone { neutral, warning }

