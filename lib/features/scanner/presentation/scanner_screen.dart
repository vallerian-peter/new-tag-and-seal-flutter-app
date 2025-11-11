import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/widgets/livestock_details_modal.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum TagScanMode { qr, barcode, rfid }

Future<String?> showTagScannerBottomSheet(
  BuildContext context,
  TagScanMode mode,
) async {
  final l10n = AppLocalizations.of(context)!;
  final configs = _buildScanModeConfigs(l10n);
  final config = configs.firstWhere((c) => c.mode == mode);

  if (!_isScanSupported(mode)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.scanUnsupportedDevice)),
    );
    return null;
  }

  if (config.usesCamera && !await _ensureCameraPermission(context)) {
    return null;
  }

  MobileScannerController? controller;
  if (config.usesCamera) {
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      torchEnabled: false,
      formats: config.formats,
    );
  }

  String? result;
  try {
    result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScanBottomSheet(
        config: config,
        controller: controller,
      ),
    );
  } on MissingPluginException {
    controller?.dispose();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scanUnsupportedDevice)),
      );
    }
    return null;
  }

  controller?.dispose();

  if (result == null) return null;
  final trimmed = result.trim();
  return trimmed.isEmpty ? null : trimmed;
}

bool _isScanSupported(TagScanMode mode) {
  if (mode == TagScanMode.rfid) {
    return true;
  }
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

Future<bool> _ensureCameraPermission(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  if (kIsWeb) {
    return true;
  }

  var status = await Permission.camera.status;
  if (status.isGranted) {
    return true;
  }

  if (status.isPermanentlyDenied || status.isRestricted) {
    if (!context.mounted) return false;
    final goToSettings = await _showPermissionSettingsDialog(context, l10n);
    if (goToSettings == true) {
      await openAppSettings();
    }
    return false;
  }

  if (context.mounted) {
    final shouldRequest = await _showPermissionRationaleDialog(context, l10n);
    if (shouldRequest != true) {
      return false;
    }
  }

  status = await Permission.camera.request();
  if (status.isGranted) {
    return true;
  }

  if (status.isPermanentlyDenied || status.isRestricted) {
    if (context.mounted) {
      final goToSettings = await _showPermissionSettingsDialog(context, l10n);
      if (goToSettings == true) {
        await openAppSettings();
      }
    }
    return false;
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.scanPermissionDenied)),
    );
  }
  return false;
}

Future<bool?> _showPermissionRationaleDialog(
  BuildContext context,
  AppLocalizations l10n,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog.adaptive(
        title: Text(l10n.scanPermissionRationaleTitle),
        content: Text(l10n.scanPermissionRationaleMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.scanPermissionNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text(l10n.scanPermissionAllow),
          ),
        ],
      );
    },
  );
}

Future<bool?> _showPermissionSettingsDialog(
  BuildContext context,
  AppLocalizations l10n,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog.adaptive(
        title: Text(l10n.scanPermissionSettingsTitle),
        content: Text(l10n.scanPermissionSettingsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.scanPermissionNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text(l10n.scanPermissionGoToSettings),
          ),
        ],
      );
    },
  );
}

List<_ScanModeConfig> _buildScanModeConfigs(AppLocalizations l10n) {
  return [
    _ScanModeConfig(
      mode: TagScanMode.qr,
      title: l10n.scanOptionQr,
      description: l10n.scanOptionQrDescription,
      icon: Iconsax.scan_outline,
      startIcon: Icons.qr_code_scanner,
      accentColor: Colors.orangeAccent,
      usesCamera: true,
      formats: const [BarcodeFormat.qrCode],
    ),
    _ScanModeConfig(
      mode: TagScanMode.barcode,
      title: l10n.scanOptionBarcode,
      description: l10n.scanOptionBarcodeDescription,
      icon: Iconsax.barcode_outline,
      startIcon: Icons.qr_code,
      accentColor: Colors.blueAccent,
      usesCamera: true,
      formats: const [
        BarcodeFormat.aztec,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.dataMatrix,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.pdf417,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
    ),
    _ScanModeConfig(
      mode: TagScanMode.rfid,
      title: l10n.scanOptionRfid,
      description: l10n.scanOptionRfidDescription,
      icon: Iconsax.radar_outline,
      startIcon: Icons.nfc,
      accentColor: Colors.teal,
      usesCamera: false,
      formats: const [],
    ),
  ];
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  TagScanMode _selectedMode = TagScanMode.qr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final configs = _buildScanModeConfigs(l10n);
    final selectedConfig =
        configs.firstWhere((element) => element.mode == _selectedMode);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.scanTagsTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.close_circle_outline,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.scanTagsSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            _ScanModeSelector(
              configs: configs,
              selectedMode: _selectedMode,
              onModeSelected: (mode) => setState(() => _selectedMode = mode),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _ScanPreviewCard(config: selectedConfig),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startScan(selectedConfig),
                icon: Icon(selectedConfig.startIcon, size: 18),
                label: Text(l10n.scanStartButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startScan(_ScanModeConfig config) async {
    final l10n = AppLocalizations.of(context)!;

    if (!_isScanSupported(config.mode)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scanUnsupportedDevice)),
      );
      return;
    }

    if (config.usesCamera && !await _ensureCameraPermission(context)) {
      return;
    }

    MobileScannerController? controller;

    if (config.usesCamera) {
      controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        torchEnabled: false,
        formats: config.formats,
      );
    }

    String? result;
    try {
      result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _ScanBottomSheet(
          config: config,
          controller: controller,
        ),
      );
    } on MissingPluginException {
      controller?.dispose();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scanUnsupportedDevice)),
      );
      return;
    }

    controller?.dispose();

    if (!mounted || result == null || result.isEmpty) return;

    await _handleScanResult(result.trim());
  }

  Future<void> _handleScanResult(String value) async {
    if (value.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final database = context.read<AppDatabase>();

    final match = await database.livestockDao.getLivestockByTagValue(value);

    if (!mounted) return;

    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scanResultNotFound(value))),
      );
      return;
    }

    final withFarm = await database.livestockDao.getLivestockWithFarm(match.id);

    if (!mounted) return;

    final farmName = withFarm?.farm.name ?? l10n.unknownFarm;
    final farmNames = {match.farmUuid: farmName};

    LivestockDetailsModal.show(
      context: context,
      livestock: match,
      farmNames: farmNames,
      onRefresh: () {},
    );
  }
}

class _ScanModeSelector extends StatelessWidget {
  final List<_ScanModeConfig> configs;
  final TagScanMode selectedMode;
  final ValueChanged<TagScanMode> onModeSelected;

  const _ScanModeSelector({
    required this.configs,
    required this.selectedMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: configs.map((config) {
        final isSelected = config.mode == selectedMode;
        return ChoiceChip(
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          avatar: Icon(
            config.icon,
            size: 18,
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurface.withOpacity(0.65),
          ),
          selected: isSelected,
          label: Text(config.title),
          onSelected: (_) => onModeSelected(config.mode),
          backgroundColor: theme.colorScheme.surface,
          selectedColor: config.accentColor,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: isSelected
                  ? config.accentColor
                  : theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ScanPreviewCard extends StatelessWidget {
  final _ScanModeConfig config;

  const _ScanPreviewCard({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
            padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
              color: config.accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
              config.icon,
              size: 72,
              color: config.accentColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
            config.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            config.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanModeConfig {
  final TagScanMode mode;
  final String title;
  final String description;
  final IconData icon;
  final IconData startIcon;
  final Color accentColor;
  final bool usesCamera;
  final List<BarcodeFormat> formats;

  const _ScanModeConfig({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
    required this.startIcon,
    required this.accentColor,
    required this.usesCamera,
    required this.formats,
  });
}

class _ScanBottomSheet extends StatefulWidget {
  final _ScanModeConfig config;
  final MobileScannerController? controller;

  const _ScanBottomSheet({required this.config, this.controller});

  @override
  State<_ScanBottomSheet> createState() => _ScanBottomSheetState();
}

class _ScanBottomSheetState extends State<_ScanBottomSheet> {
  bool _hasCaptured = false;
  late final TextEditingController _manualController;
  String _manualValue = '';

  @override
  void initState() {
    super.initState();
    _manualController = TextEditingController();
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                  widget.config.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.config.description,
                textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 0.75,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.config.usesCamera
                        ? MobileScanner(
                            controller: widget.controller!,
                            overlay: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: widget.config.accentColor,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onDetect: _onDetect,
                          )
                        : _RfidPlaceholder(accentColor: widget.config.accentColor),
                  ),
                ),
                const SizedBox(height: 16),
                if (!widget.config.usesCamera) ...[
                  Text(
                    l10n.scanRfidPlaceholder,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _manualController,
                    onChanged: (value) => setState(() {
                      _manualValue = value.trim();
                    }),
                    decoration: InputDecoration(
                      labelText: l10n.scanManualPlaceholder,
                      prefixIcon: const Icon(Iconsax.radar_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed:
                        _manualValue.isEmpty ? null : () => _submitManual(),
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.config.accentColor,
                    foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.scanManualConfirm),
                  ),
                  const SizedBox(height: 8),
                ],
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ],
              ),
          ),
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasCaptured) return;
    final barcode = capture.barcodes.firstWhere(
      (code) => (code.rawValue ?? '').isNotEmpty,
      orElse: () => capture.barcodes.first,
    );
    final value = barcode.rawValue;
    if (value == null || value.isEmpty) {
      return;
    }
    _hasCaptured = true;
    widget.controller?.stop();
    Navigator.of(context).pop(value);
  }

  void _submitManual() {
    if (_hasCaptured) return;
    final trimmed = _manualValue.trim();
    if (trimmed.isEmpty) return;
    _hasCaptured = true;
    Navigator.of(context).pop(trimmed);
  }
}

class _RfidPlaceholder extends StatelessWidget {
  final Color accentColor;

  const _RfidPlaceholder({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface.withOpacity(0.9),
      child: Center(
        child: Icon(
          Iconsax.radar_outline,
          color: accentColor,
          size: 72,
        ),
      ),
    );
  }
}

