import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/core/services/bluetooth/bluetooth_weight_service.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:developer';

/// Reusable Modern Bluetooth Weight Scale Bottom Sheet
///
/// Shows available Bluetooth weight scales, connects to selected device,
/// and returns the weight value
class BluetoothWeightBottomSheet extends StatefulWidget {
  final ValueChanged<double> onWeightReceived;

  const BluetoothWeightBottomSheet({
    super.key,
    required this.onWeightReceived,
  });

  /// Show the bottom sheet
  static Future<double?> show(BuildContext context) async {
    return await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => BluetoothWeightBottomSheet(
        onWeightReceived: (weight) {
          Navigator.of(context).pop(weight);
        },
      ),
    );
  }

  @override
  State<BluetoothWeightBottomSheet> createState() => _BluetoothWeightBottomSheetState();
}

class _BluetoothWeightBottomSheetState extends State<BluetoothWeightBottomSheet> {
  final _bluetoothService = BluetoothWeightService();
  
  bool _isScanning = false;
  bool _isConnected = false;
  double? _receivedWeight;
  String? _connectedDeviceName;
  List<BluetoothDevice> _availableDevices = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startBluetoothScan();
    _listenToStreams();
  }

  void _listenToStreams() {
    // Listen to discovered devices
    _bluetoothService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _availableDevices = devices;
        });
      }
    });

    // Listen to weight data
    _bluetoothService.weightDataStream.listen((weight) {
      if (mounted) {
        setState(() {
          _receivedWeight = weight;
        });
      }
    });

    // Listen to connection state
    _bluetoothService.connectionStateStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          if (isConnected) {
            _connectedDeviceName = _bluetoothService.connectedDeviceName;
          }
        });
      }
    });
  }

  Future<void> _startBluetoothScan() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      await _bluetoothService.startScan();
    } catch (e) {
      log('❌ Scan error: $e');
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

  void _saveWeight() {
    if (_receivedWeight != null) {
      widget.onWeightReceived(_receivedWeight!);
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
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        FontAwesome.bluetooth_brand,
                        color: Constants.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bluetooth Weight Scale', // TODO: Add l10n.bluetoothWeightScale
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isConnected 
                                ? 'Connected to $_connectedDeviceName' 
                                : 'Connect to measure weight', // TODO: Add l10n.connectToMeasureWeight
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (_errorMessage != null)
                      _buildErrorState(theme, _errorMessage!),
                    
                    if (!_isConnected) ...[
                      // Scanning/Device List State
                      if (_isScanning)
                        _buildScanningState(theme)
                      else if (_availableDevices.isEmpty)
                        _buildNoDevicesState(theme, l10n)
                      else
                        _buildDeviceList(theme),
                    ] else ...[
                      // Connected State
                      _buildConnectedState(theme, l10n),
                    ],
                  ],
                ),
              ),

              // Bottom Actions
              if (_isConnected && _receivedWeight != null)
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
                        onPressed: _saveWeight,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Weight', // TODO: Add l10n.saveWeight
                          style: TextStyle(
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

  Widget _buildErrorState(ThemeData theme, String error) {
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
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Constants.dangerColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Constants.dangerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningState(ThemeData theme) {
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
            'Scanning for devices...', // TODO: Add l10n.scanningForDevices
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure your scale is turned on', // TODO: Add l10n.makeSureScaleOn
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
            FontAwesome.bluetooth_brand,
            size: 64,
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No devices found', // TODO: Add l10n.noDevicesFound
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure Bluetooth is enabled and scale is on', // TODO: Add l10n.makeBluetoothEnabledAndScaleOn
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startBluetoothScan,
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Again'), // TODO: Add l10n.scanAgain
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

  Widget _buildDeviceList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Devices (${_availableDevices.length})', // TODO: Add l10n.availableDevices
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _startBluetoothScan,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Scan'), // TODO: Add l10n.scan
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
              : 'Unknown Device';
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              elevation: 2,
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
                          FontAwesome.weight_scale_solid,
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
        // Connection Success
        Container(
          padding: const EdgeInsets.all(20),
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
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected', // TODO: Add l10n.connected
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Constants.successColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _connectedDeviceName ?? 'Unknown Device',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Weight Display
        Container(
          padding: const EdgeInsets.all(32),
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
              Icon(
                FontAwesome.weight_scale_solid,
                size: 48,
                color: Constants.primaryColor.withOpacity(0.8),
              ),
              const SizedBox(height: 16),
              Text(
                'Current Weight', // TODO: Add l10n.currentWeight
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              if (_receivedWeight != null)
                Text(
                  '${_receivedWeight!.toStringAsFixed(2)} kg',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor,
                    fontSize: 48,
                  ),
                )
              else
                Column(
                  children: [
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Waiting for weight data...', // TODO: Add l10n.waitingForWeightData
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Place livestock on the scale and wait for stable reading', // TODO: Add l10n.placeOnScaleInstruction
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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

