import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/core/services/bluetooth/bluetooth_rfid_service.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'dart:developer';
import 'package:new_tag_and_seal_flutter_app/core/services/bluetooth/bluetooth_weight_service.dart';

/// Reusable Modern Bluetooth RFID Scanner Bottom Sheet
///
/// Shows available Bluetooth RFID scanners, connects to selected device,
/// and returns the RFID tag value
class BluetoothRfidBottomSheet extends StatefulWidget {
  final ValueChanged<String> onTagReceived;

  const BluetoothRfidBottomSheet({
    super.key,
    required this.onTagReceived,
  });

  /// Show the bottom sheet
  static Future<String?> show(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => BluetoothRfidBottomSheet(
        onTagReceived: (tag) {
          Navigator.of(context).pop(tag);
        },
      ),
    );
  }

  @override
  State<BluetoothRfidBottomSheet> createState() => _BluetoothRfidBottomSheetState();
}

class _BluetoothRfidBottomSheetState extends State<BluetoothRfidBottomSheet> {
  final _bluetoothService = BluetoothRfidService();
  
  bool _isScanning = false;
  bool _isConnected = false;
  String? _receivedTag;
  String? _connectedDeviceName;
  List<BluetoothDevice> _availableDevices = [];
  String? _errorMessage;
  BluetoothErrorType? _errorType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startBluetoothScan();
      }
    });
    _listenToStreams();
  }

  void _listenToStreams() {
    _bluetoothService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _availableDevices = devices;
        });
      }
    });

    _bluetoothService.tagDataStream.listen((tag) {
      if (mounted) {
        setState(() {
          _receivedTag = tag;
        });
        // Auto-submit when tag is received
        if (tag.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              widget.onTagReceived(tag);
            }
          });
        }
      }
    });

    _bluetoothService.connectionStateStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          if (isConnected) {
            _connectedDeviceName = _bluetoothService.connectedDeviceName;
          } else {
            _receivedTag = null;
          }
        });
      }
    });
  }

  Future<void> _startBluetoothScan() async {
    final l10n = AppLocalizations.of(context)!;
    bool loadingShown = false;

    final permissionResult = await _bluetoothService.checkBluetoothPermissions();
    if (!permissionResult.granted) {
      final message = permissionResult.errorMessage ?? l10n.bluetoothPermissionsRequired;
      if (mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: message,
          buttonText: permissionResult.errorType == BluetoothErrorType.permissionsPermanentlyDenied
              ? l10n.openSettings
              : l10n.ok,
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
            if (permissionResult.errorType == BluetoothErrorType.permissionsPermanentlyDenied) {
              await _bluetoothService.openSettings();
            }
          },
        );
      }
      setState(() {
        _isScanning = false;
        _errorType = permissionResult.errorType ?? BluetoothErrorType.permissionsDenied;
        _errorMessage = message;
      });
      return;
    }

    final isBluetoothOn = await _bluetoothService.isBluetoothOn();
    if (!isBluetoothOn) {
      await _showEnableBluetoothDialog(l10n);
      setState(() {
        _isScanning = false;
        _errorType = BluetoothErrorType.bluetoothOff;
        _errorMessage = l10n.bluetoothTurnOnRequired;
      });
      return;
    }
    
    if (mounted) {
      loadingShown = true;
      AlertDialogs.showLoading(
        context: context,
        title: l10n.scanningForDevices,
        message: 'Make sure Bluetooth is enabled and your RFID scanner is turned on',
      );
    }

    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _errorType = null;
    });

    try {
      if (Platform.isAndroid) {
        final locationEnabled = await Geolocator.isLocationServiceEnabled();
        if (!locationEnabled) {
          if (mounted && loadingShown) {
            Navigator.of(context, rootNavigator: true).pop();
            loadingShown = false;
          }
          if (mounted) {
            await AlertDialogs.showError(
              context: context,
              title: l10n.error,
              message: l10n.bluetoothLocationRequired,
              buttonText: l10n.ok,
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            );
          }
          setState(() {
            _isScanning = false;
            _errorType = BluetoothErrorType.unknown;
            _errorMessage = l10n.bluetoothLocationRequired;
          });
          return;
        }
      }

      final errorType = await _bluetoothService.startScan();
      
      if (mounted && loadingShown) {
        Navigator.of(context, rootNavigator: true).pop();
        loadingShown = false;
      }
      
      if (mounted) {
        if (errorType != null) {
          setState(() {
            _errorType = errorType;
            _errorMessage = _getErrorMessage(errorType, l10n);
          });
        } else {
          setState(() {
            _errorMessage = null;
            _errorType = null;
          });
        }
      }
    } catch (e) {
      log('❌ Scan error: $e');
      if (mounted && loadingShown) {
        Navigator.of(context, rootNavigator: true).pop();
        loadingShown = false;
      }
      if (mounted) {
        setState(() {
          _errorType = BluetoothErrorType.unknown;
          _errorMessage = l10n.bluetoothUnknownError;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _showEnableBluetoothDialog(AppLocalizations l10n) async {
    if (!mounted) return;

    await AlertDialogs.showConfirmation(
      context: context,
      title: l10n.bluetoothTurnOnRequired,
      message: l10n.bluetoothTurnOnInstructions,
      confirmText: l10n.enableBluetooth,
      cancelText: l10n.cancel,
      onConfirm: () async {
        Navigator.of(context).pop();
        try {
          await FlutterBluePlus.turnOn();
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) {
            await _startBluetoothScan();
          }
        } catch (e) {
          log('❌ Unable to automatically enable Bluetooth: $e');
          await _bluetoothService.openSettings();
        }
      },
      onCancel: () {
        Navigator.of(context).pop();
      },
    );
  }

  String _getErrorMessage(BluetoothErrorType errorType, AppLocalizations l10n) {
    switch (errorType) {
      case BluetoothErrorType.notSupported:
        return l10n.bluetoothNotSupported;
      case BluetoothErrorType.permissionsDenied:
        return l10n.bluetoothPermissionsRequired;
      case BluetoothErrorType.permissionsPermanentlyDenied:
        return l10n.bluetoothPermissionsPermanentlyDenied;
      case BluetoothErrorType.bluetoothOff:
        return l10n.bluetoothTurnOnRequired;
      case BluetoothErrorType.unknown:
        return l10n.bluetoothUnknownError;
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final success = await _bluetoothService.connectToDevice(device);
      if (!success && mounted) {
        setState(() {
          _errorMessage = 'Failed to connect to device';
        });
      }
    } catch (e) {
      log('❌ Connection error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _saveTag() {
    if (_receivedTag != null && _receivedTag!.isNotEmpty) {
      widget.onTagReceived(_receivedTag!);
    }
  }

  @override
  void dispose() {
    _bluetoothService.disconnectDevice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.nfc,
                        color: Constants.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bluetooth RFID Scanner',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isConnected 
                                ? 'Connected to ${_connectedDeviceName ?? l10n.unknownDevice}'
                                : 'Connect to scan RFID tags',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    if (_errorMessage != null)
                      _buildErrorState(theme, l10n),
                    
                    if (!_isConnected) ...[
                      if (_isScanning)
                        _buildScanningState(theme, l10n)
                      else if (_availableDevices.isEmpty)
                        _buildNoDevicesState(theme, l10n)
                      else
                        _buildDeviceList(theme, l10n),
                    ] else ...[
                      _buildConnectedState(theme, l10n),
                    ],
                  ],
                ),
              ),
              if (_isConnected && _receivedTag != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTag,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Use Tag: $_receivedTag',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n) {
    final showSettingsButton = _errorType == BluetoothErrorType.permissionsPermanentlyDenied;
    final showRetryPermissionsButton = _errorType == BluetoothErrorType.permissionsDenied;
    final showEnableBluetoothButton = _errorType == BluetoothErrorType.bluetoothOff;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.dangerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Constants.dangerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Constants.dangerColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _errorMessage ?? l10n.bluetoothUnknownError,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Constants.dangerColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (showSettingsButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await _bluetoothService.openSettings();
                },
                icon: const Icon(Icons.settings, size: 18),
                label: Text(l10n.openSettings),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Constants.dangerColor,
                  side: const BorderSide(color: Constants.dangerColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else if (showRetryPermissionsButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await _startBluetoothScan();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.retry),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Constants.dangerColor,
                  side: const BorderSide(color: Constants.dangerColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else if (showEnableBluetoothButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showEnableBluetoothDialog(l10n),
                icon: const Icon(Icons.bluetooth, size: 18),
                label: Text(l10n.enableBluetooth),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Constants.primaryColor,
                  side: BorderSide(color: Constants.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScanningState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.scanningForDevices,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure Bluetooth is enabled and your RFID scanner is turned on',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDevicesState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nfc,
            size: 64,
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noDevicesFound,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure Bluetooth is enabled and your RFID scanner is turned on',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startBluetoothScan,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.scanAgain),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Devices (${_availableDevices.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _startBluetoothScan,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.scan),
              style: TextButton.styleFrom(
                foregroundColor: Constants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._availableDevices.map((device) {
          final deviceName = device.platformName.isNotEmpty 
              ? device.platformName 
              : l10n.unknownDevice;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              elevation: 2,
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _connectToDevice(device),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Constants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.nfc,
                          color: Constants.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deviceName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              device.remoteId.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Constants.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConnectedState(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Constants.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Constants.successColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Constants.successColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.connected,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Constants.successColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _connectedDeviceName ?? l10n.unknownDevice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constants.primaryColor.withOpacity(0.1),
                Constants.primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Constants.primaryColor.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.nfc,
                size: 40,
                color: Constants.primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                'Scan RFID Tag',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              if (_receivedTag != null)
                Text(
                  _receivedTag!,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor,
                    fontSize: 24,
                  ),
                )
              else
                Column(
                  children: [
                    const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Waiting for tag scan...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Point your RFID scanner at a tag to scan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

