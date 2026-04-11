import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Bluetooth error types
enum BluetoothErrorType {
  notSupported,
  permissionsDenied,
  permissionsPermanentlyDenied,
  bluetoothOff,
  unknown,
}

/// Result class for permission checking
class PermissionResult {
  final bool granted;
  final BluetoothErrorType? errorType;
  final String? errorMessage;

  PermissionResult({
    required this.granted,
    this.errorType,
    this.errorMessage,
  });
}

/// Service for handling Bluetooth weight scale connections
///
/// Manages scanning, connecting, and receiving weight data from Bluetooth scales
class BluetoothWeightService {
  static final BluetoothWeightService _instance = BluetoothWeightService._internal();
  factory BluetoothWeightService() => _instance;
  BluetoothWeightService._internal();

  // Stream controllers
  final _devicesController = StreamController<List<BluetoothDevice>>.broadcast();
  final _weightDataController = StreamController<double>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  // Getters for streams
  Stream<List<BluetoothDevice>> get devicesStream => _devicesController.stream;
  Stream<double> get weightDataStream => _weightDataController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  // Current state
  BluetoothDevice? _connectedDevice;
  List<BluetoothDevice> _discoveredDevices = [];
  bool _isScanning = false;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  List<StreamSubscription<List<int>>>? _characteristicSubscriptions = [];
  Timer? _weightPollingTimer;
  BluetoothCharacteristic? _weightCharacteristic;
  double? _lastValidWeight;
  DateTime? _lastWeightUpdateTime;
  bool _isHandlingDisconnection = false; // Prevent recursive disconnect calls
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  /// Check and request Bluetooth permissions
  /// 
  /// Required permissions:
  /// - Android 12+ (API 31+): BLUETOOTH_SCAN, BLUETOOTH_CONNECT
  /// - Android < 12: BLUETOOTH, BLUETOOTH_ADMIN, ACCESS_FINE_LOCATION
  /// - iOS: Bluetooth usage description in Info.plist
  Future<PermissionResult> checkBluetoothPermissions() async {
    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        log('❌ Bluetooth not supported on this device');
        return PermissionResult(
          granted: false,
          errorType: BluetoothErrorType.notSupported,
          errorMessage: 'Bluetooth is not supported on this device',
        );
      }

      log('🔐 Requesting Bluetooth permissions...');

      // Request necessary permissions for Android 12+
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetooth,
        Permission.location,
      ].request();

      // Check if all required permissions are granted
      bool allGranted = true;
      bool permanentlyDenied = false;
      
      statuses.forEach((permission, status) {
        log('  ${permission.toString()}: ${status.toString()}');
        if (!status.isGranted && !status.isLimited) {
          allGranted = false;
        }
        if (status.isPermanentlyDenied) {
          permanentlyDenied = true;
        }
      });

      if (allGranted) {
        log('✅ All Bluetooth permissions granted');
        return PermissionResult(granted: true);
      } else {
        log('⚠️ Some Bluetooth permissions denied');
        
        if (permanentlyDenied) {
          log('⚠️ Permissions permanently denied - user must enable in settings');
          return PermissionResult(
            granted: false,
            errorType: BluetoothErrorType.permissionsPermanentlyDenied,
            errorMessage: 'Bluetooth permissions were permanently denied. Please enable them in app settings.',
          );
        } else {
          return PermissionResult(
            granted: false,
            errorType: BluetoothErrorType.permissionsDenied,
            errorMessage: 'Bluetooth permissions are required to scan for devices',
          );
        }
      }
    } catch (e) {
      log('❌ Error checking Bluetooth permissions: $e');
      return PermissionResult(
        granted: false,
        errorType: BluetoothErrorType.unknown,
        errorMessage: 'An error occurred while checking permissions: $e',
      );
    }
  }

  /// Check if Bluetooth permissions are already granted (without requesting)
  Future<bool> hasBluetoothPermissions() async {
    try {
      final bluetoothScan = await Permission.bluetoothScan.status;
      final bluetoothConnect = await Permission.bluetoothConnect.status;
      final location = await Permission.location.status;

      return (bluetoothScan.isGranted || bluetoothScan.isLimited) &&
             (bluetoothConnect.isGranted || bluetoothConnect.isLimited) &&
             (location.isGranted || location.isLimited);
    } catch (e) {
      log('❌ Error checking permission status: $e');
      return false;
    }
  }

  /// Check if Bluetooth is turned on
  Future<bool> isBluetoothOn() async {
    try {
      final adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    } catch (e) {
      log('❌ Error checking Bluetooth state: $e');
      return false;
    }
  }

  /// Open app settings for user to manually grant permissions
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Start scanning for Bluetooth weight scales
  /// Returns error type if scan fails, null if successful
  Future<BluetoothErrorType?> startScan() async {
    try {
      if (_isScanning) {
        log('⚠️ Already scanning');
        return null;
      }

      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        log('❌ Bluetooth not supported');
        return BluetoothErrorType.notSupported;
      }

      // Check permissions first
      final permissionResult = await checkBluetoothPermissions();
      if (!permissionResult.granted) {
        return permissionResult.errorType;
      }

      // Check if Bluetooth is turned on
      final isOn = await isBluetoothOn();
      if (!isOn) {
        log('⚠️ Bluetooth is turned off');
        return BluetoothErrorType.bluetoothOff;
      }

      _isScanning = true;
      _discoveredDevices.clear();

      log('🔍 Starting Bluetooth scan for weight scales...');

      // Cancel any existing scan subscription
      await _scanResultsSubscription?.cancel();
      
      // Listen to scan results BEFORE starting scan
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          // Filter for weight scales (check device name contains weight-related keywords)
          final deviceName = r.device.platformName.toLowerCase();
          
          if (deviceName.contains('scale') || 
              deviceName.contains('weight') || 
              deviceName.contains('balance') ||
              deviceName.isNotEmpty) { // Allow all devices for now
            
            // Avoid duplicates
            if (!_discoveredDevices.any((d) => d.remoteId == r.device.remoteId)) {
              _discoveredDevices.add(r.device);
              log('📱 Found device: ${r.device.platformName} (${r.device.remoteId})');
              _devicesController.add(List.from(_discoveredDevices));
            }
          }
        }
      });

      // Start scanning WITHOUT timeout - we'll manage the duration ourselves
      await FlutterBluePlus.startScan(
        androidUsesFineLocation: true,
      );

      // Wait for scan to complete (scan for 10 seconds to find all devices)
      await Future.delayed(const Duration(seconds: 10));
      
      // Stop scanning after duration
      await stopScan();

      return null; // Success
    } catch (e) {
      log('❌ Error during Bluetooth scan: $e');
      _isScanning = false;
      return BluetoothErrorType.unknown;
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    try {
      if (_isScanning) {
        await FlutterBluePlus.stopScan();
        _isScanning = false;
        log('✅ Scan stopped');
      }
    } catch (e) {
      log('❌ Error stopping scan: $e');
      _isScanning = false;
    }
  }

  /// Connect to a Bluetooth device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      log('🔗 Connecting to ${device.platformName}...');

      // Check if device is available before attempting connection
      try {
        final currentState = await device.connectionState.first.timeout(
          const Duration(seconds: 2),
          onTimeout: () => BluetoothConnectionState.disconnected,
        );
        if (currentState == BluetoothConnectionState.disconnected) {
          // Device might be turned off or out of range
          final deviceName = device.platformName;
          log('⚠️ Device $deviceName appears to be disconnected/unavailable');
        }
      } catch (e) {
        log('⚠️ Could not check device state: $e');
      }

      // Disconnect from previous device if any
      if (_connectedDevice != null) {
        await disconnectDevice();
      }

      // Cancel previous connection state subscription if any
      await _connectionStateSubscription?.cancel();

      // Listen to device connection state changes BEFORE connecting
      _connectionStateSubscription = device.connectionState.listen((state) async {
        log('📡 Device connection state changed: $state');
        final isConnected = state == BluetoothConnectionState.connected;
        
        if (isConnected && _connectedDevice?.remoteId == device.remoteId) {
          _connectionStateController.add(true);
          log('✅ Device connected: ${device.platformName}');
          _isHandlingDisconnection = false; // Reset flag on successful connection
        } else if (!isConnected && _connectedDevice?.remoteId == device.remoteId && !_isHandlingDisconnection) {
          // Connection lost - disconnect, remove device from list, and restart scan
          _isHandlingDisconnection = true; // Prevent recursive calls
          final disconnectedDevice = _connectedDevice;
          log('⚠️ Connection lost to ${disconnectedDevice?.platformName}, cleaning up and removing device...');
          
          // Disconnect and clean up (without canceling subscription here to avoid issues)
          try {
            await _cancelCharacteristicSubscriptions();
            _lastValidWeight = null;
            _lastWeightUpdateTime = null;
            _weightCharacteristic = null;
            
            // Remove device from discovered devices list
            if (disconnectedDevice != null) {
              _discoveredDevices.removeWhere((d) => d.remoteId == disconnectedDevice.remoteId);
              log('🗑️ Removed ${disconnectedDevice.platformName} from discovered devices list');
              _devicesController.add(List.from(_discoveredDevices));
            }
            
            try {
              await disconnectedDevice!.disconnect();
            } catch (e) {
              log('⚠️ Error during disconnect (may already be disconnected): $e');
            }
            
            // Clear all connection state
            log('✅ Disconnected from ${disconnectedDevice?.platformName ?? 'Device'}');
            _connectedDevice = null;
            _connectionStateController.add(false);
            
            // Cancel subscription after cleanup
            await _connectionStateSubscription?.cancel();
            _connectionStateSubscription = null;
            
            // Wait a moment before restarting scan to allow cleanup
            await Future.delayed(const Duration(milliseconds: 1000));
            
            // Restart scanning for devices
            if (!_isScanning) {
              log('🔄 Restarting device scan after disconnection...');
              await startScan();
            }
          } catch (e) {
            log('❌ Error handling disconnection: $e');
            _connectedDevice = null;
            _connectionStateController.add(false);
            // Still try to remove device from list even on error
            if (disconnectedDevice != null) {
              _discoveredDevices.removeWhere((d) => d.remoteId == disconnectedDevice.remoteId);
              _devicesController.add(List.from(_discoveredDevices));
            }
          } finally {
            _isHandlingDisconnection = false;
          }
        }
      });

      // For automatic pairing, create bond first (Android only)
      // This will show the pairing dialog automatically without requiring user to go to settings
      log('🔐 Initiating pairing/bonding process...');
      
      try {
        // Listen to bond state changes to track pairing progress
        final bondSubscription = device.bondState.listen((bondState) {
          log('🔐 Bond state changed: $bondState');
        });
        
        // Cancel bond subscription when device disconnects
        device.cancelWhenDisconnected(bondSubscription);
        
        // Create bond to trigger pairing dialog (Android only, iOS handles automatically)
        // This will show the pairing dialog if device is not already paired
        await device.createBond();
        log('✅ Bond creation initiated');
        
        // Wait a moment for bonding to complete
        await Future.delayed(const Duration(milliseconds: 1500));
      } catch (bondError) {
        log('⚠️ Bonding may not be needed or already bonded: $bondError');
        // Continue with connection anyway - some devices don't need explicit bonding
      }
      
      // Connect to device (pairing dialog should have appeared if needed)
      log('🔗 Connecting to device...');
      await device.connect(
        timeout: const Duration(seconds: 20),
        autoConnect: false, // Must be false to allow MTU negotiation
        // Note: We rely on strict filtering in _discoverServicesAndSubscribe to only
        // subscribe to the weight characteristic (fec8/ffe1) and validate data format (ST,GS).
        // This prevents processing data from other characteristics that flutter_blue_plus
        // may read during service discovery.
      );

      // Wait a bit for connection state to stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if actually connected
      final connectionState = await device.connectionState.first;
      if (connectionState != BluetoothConnectionState.connected) {
        log('❌ Connection failed, state: $connectionState');
        _connectionStateController.add(false);
        await _connectionStateSubscription?.cancel();
        _connectionStateSubscription = null;
        return false;
      }

      _connectedDevice = device;
      _connectionStateController.add(true);

      log('✅ Connected to ${device.platformName}');

      // Discover services and characteristics
      await _discoverServicesAndSubscribe(device);

      return true;
    } catch (e) {
      log('❌ Error connecting to device: $e');
      _connectionStateController.add(false);
      await _connectionStateSubscription?.cancel();
      _connectionStateSubscription = null;
      
      // If connection failed (timeout, device unavailable), remove device from list
      // This handles cases where device was turned off or is out of range
      final deviceId = device.remoteId;
      final deviceName = device.platformName;
      _discoveredDevices.removeWhere((d) => d.remoteId == deviceId);
      log('🗑️ Removed unavailable device $deviceName from discovered devices list');
      _devicesController.add(List.from(_discoveredDevices));
      
      _connectedDevice = null;
      return false;
    }
  }

  /// Discover services and subscribe to weight data notifications
  Future<void> _discoverServicesAndSubscribe(BluetoothDevice device) async {
    try {
      // Cancel any existing subscriptions
      await _cancelCharacteristicSubscriptions();
      _weightCharacteristic = null;
      _lastValidWeight = null;
      _lastWeightUpdateTime = null;
      
      // Discover services
      final services = await device.discoverServices();
      log('🔍 Discovered ${services.length} services');

      // The UUIDs that send the actual weight data for this scale type (ST,GS format)
      const knownWeightUuids = ['fec8', 'ffe1'];
      
      // Look ONLY for weight characteristics with known UUIDs (fec8, ffe1)
      // These are the characteristics that send actual weight data in ST,GS format
      for (BluetoothService service in services) {
        log('🔍 Service UUID: ${service.uuid}');
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          final uuidStr = characteristic.uuid.toString().toLowerCase();
          log('  📡 Characteristic UUID: ${characteristic.uuid}, Properties: ${characteristic.properties}');
          
          // Check for the known weight UUID and that it supports data streaming
          final isWeightCharacteristic = knownWeightUuids.any((uuid) => uuidStr.contains(uuid));
          
          if (isWeightCharacteristic && (characteristic.properties.notify || characteristic.properties.indicate)) {
            log('✅ Found weight characteristic with notify: ${characteristic.uuid}');

            try {
              // Subscribe to notifications
              await characteristic.setNotifyValue(true);
              log('✅ Subscribed to notifications for weight characteristic: ${characteristic.uuid}');
              
              // Set as the primary weight characteristic
              _weightCharacteristic = characteristic;
              
              // Use lastValueStream for real-time updates - THIS IS THE ONLY SOURCE
              final subscription = characteristic.lastValueStream.listen((value) {
                log('📊 Raw data received via notify from ${characteristic.uuid}: $value (${value.length} bytes)');
                if (value.isNotEmpty) {
                  // Check if data matches weight format (ST,GS pattern)
                  final asciiString = String.fromCharCodes(value);
                  if (asciiString.contains('ST,GS') || asciiString.contains('GS,')) {
                    // This is definitely weight data
                    final weight = _parseWeightData(value);
                    if (weight != null && _isValidWeight(weight)) {
                      log('📊 ✅ Valid weight received via notify: $weight kg');
                      _updateWeight(weight);
                    } else {
                      log('⚠️ Could not parse valid weight from ${characteristic.uuid}: $weight');
                    }
                  } else {
                    log('⚠️ Data from ${characteristic.uuid} does not match weight format, ignoring');
                  }
                } else {
                  log('⚠️ Received empty data from ${characteristic.uuid}');
                }
              }, onError: (error) {
                log('❌ Error in weight characteristic notify stream ${characteristic.uuid}: $error');
              });
              
              _characteristicSubscriptions?.add(subscription);
              log('✅ Added subscription for weight characteristic ${characteristic.uuid}');
              
              // Found the one we need, stop searching immediately and exit function
              log('✅ Successfully subscribed to weight characteristic, stopping discovery');
              return; // Exit the function once the correct characteristic is found
            } catch (e) {
              log('❌ Error subscribing to weight characteristic ${characteristic.uuid}: $e');
            }
          }
        }
      }

      // DO NOT poll any characteristics - only use notify stream
      // Polling causes interference and reads from wrong characteristics
      if (_weightCharacteristic == null) {
        log('⚠️ No weight characteristic (fec8/ffe1) with notify found');
      } else {
        log('✅ Using weight characteristic ${_weightCharacteristic!.uuid} via notify stream only');
      }
    } catch (e) {
      log('❌ Error discovering services: $e');
    }
  }

  /// Check if weight value is valid (filters out invalid parsed data)
  bool _isValidWeight(double weight) {
    // Filter out invalid weights:
    // - Very large negative values (unrealistic, likely parsing errors)
    // - Extremely small scientific notation values (parsing errors)
    // - Extremely large values (unrealistic)
    // - Zero and small negative values are valid (empty scale or tare offset)
    
    // Allow small negative values (common for tare/zero offset, e.g., -0.2 kg)
    // But reject very large negative values (likely parsing errors)
    if (weight < -10.0) return false; // Reject very large negative values
    
    if (weight > 10000) return false; // Max 10 tons
    
    // Reject any value that looks like scientific notation (parsing errors)
    // These are usually from incorrectly parsing device info as weight
    final weightStr = weight.toString();
    if (weightStr.contains('e-') || weightStr.contains('E-')) {
      return false; // Scientific notation = parsing error
    }
    
    // Reject very small positive values (likely parsing errors from device info)
    // But allow small negative values (they're valid for tare/zero offset)
    if (weight > 0 && weight < 0.01) {
      return false;
    }
    
    return true;
  }

  /// Update weight with debouncing to prevent rapid UI updates
  void _updateWeight(double weight) {
    final now = DateTime.now();
    
    // Debounce: only update if weight changed significantly or enough time passed
    if (_lastValidWeight != null && _lastWeightUpdateTime != null) {
      final weightDiff = (weight - _lastValidWeight!).abs();
      final timeDiff = now.difference(_lastWeightUpdateTime!);
      
      // Update if weight changed by more than 0.05kg (50g) or 300ms passed
      // This prevents rapid flickering while still being responsive
      if (weightDiff < 0.05 && timeDiff.inMilliseconds < 300) {
        return; // Skip update, too soon and too small change
      }
    }
    
    _lastValidWeight = weight;
    _lastWeightUpdateTime = now;
    _weightDataController.add(weight);
  }


  /// Cancel all characteristic subscriptions
  Future<void> _cancelCharacteristicSubscriptions() async {
    _weightPollingTimer?.cancel();
    _weightPollingTimer = null;
    
    if (_characteristicSubscriptions != null) {
      for (var subscription in _characteristicSubscriptions!) {
        await subscription.cancel();
      }
      _characteristicSubscriptions?.clear();
    }
  }

  /// Parse weight data from Bluetooth bytes
  /// 
  /// This is a generic parser. Actual implementation depends on your weight scale's protocol.
  /// Common formats:
  /// - ASCII string: "125.5\n"
  /// - Binary: Little-endian float/int
  /// - Custom protocol: Depends on manufacturer
  double? _parseWeightData(List<int> data) {
    try {
      // Try parsing as ASCII string first (common for many scales)
      final asciiString = String.fromCharCodes(data).trim();
      if (asciiString.isNotEmpty) {
        final parsedFromAscii = _parseAsciiPayload(asciiString);
        if (parsedFromAscii != null) {
          return parsedFromAscii;
        }

        final directWeight = double.tryParse(asciiString);
        if (directWeight != null && directWeight >= 0) {
          return directWeight;
        }
      }

      // Try binary parsing (4-byte float, little-endian)
      if (data.length >= 4) {
        final bytes = Uint8List.fromList(data.sublist(0, 4));
        final buffer = ByteData.sublistView(bytes);
        final weight = buffer.getFloat32(0, Endian.little);
        if (weight >= 0 && weight < 10000) { // Sanity check (0-10000 kg)
          return weight;
        }
      }

      // If we have 2 bytes, try parsing as uint16
      if (data.length >= 2) {
        final bytes = Uint8List.fromList(data.sublist(0, 2));
        final buffer = ByteData.sublistView(bytes);
        final weight = buffer.getUint16(0, Endian.little) / 100.0; // Divide by 100 if in grams
        if (weight >= 0 && weight < 10000) {
          return weight;
        }
      }

      log('⚠️ Could not parse weight data: $data');
      return null;
    } catch (e) {
      log('❌ Error parsing weight data: $e');
      return null;
    }
  }

  double? _parseAsciiPayload(String payload) {
    if (payload.isEmpty) return null;

    final normalized = payload.replaceAll('\r', '').replaceAll('\n', '').trim();
    if (normalized.isEmpty) return null;

    // Pattern: ST,GS,123.45kg (optionally with trailing TW/BCC codes)
    final fullPattern = RegExp(r'ST,GS,([+-]?\d{1,7}\.\d+)([a-zA-Z]+)(\d{3})(.)');
    final shortPattern = RegExp(r'ST,GS,([+-]?\d{1,7}\.\d+)([a-zA-Z]+)');
    final simplePattern = RegExp(r'([+-]?\d+(?:\.\d+)?)[\s]*([a-zA-Z]+)');

    RegExpMatch? match = fullPattern.firstMatch(normalized);
    if (match == null) {
      match = shortPattern.firstMatch(normalized);
    }
    match ??= simplePattern.firstMatch(normalized);

    if (match != null) {
      final weightStr = match.group(1);
      final unit = match.groupCount >= 2 ? match.group(2) : null;

      if (weightStr != null) {
        final value = double.tryParse(weightStr);
        if (value != null) {
          return _convertWeightByUnit(value, unit);
        }
      }
    }

    final numericOnly = double.tryParse(normalized);
    return numericOnly;
  }

  double? _convertWeightByUnit(double value, String? unit) {
    if (unit == null || unit.isEmpty) return value;
    switch (unit.toLowerCase()) {
      case 'kg':
        return value;
      case 'g':
        return value / 1000.0;
      case 'oz':
        return value * 0.0283495;
      case 'lb':
        return value * 0.453592;
      default:
        return value;
    }
  }

  /// Disconnect from current device
  Future<void> disconnectDevice() async {
    try {
      if (_connectedDevice != null) {
        final deviceName = _connectedDevice!.platformName;
        final deviceId = _connectedDevice!.remoteId;
        
        // Cancel characteristic subscriptions and polling first
        await _cancelCharacteristicSubscriptions();
        
        // Cancel connection state subscription to prevent recursive calls
        await _connectionStateSubscription?.cancel();
        _connectionStateSubscription = null;
        
        // Disconnect from device
        try {
          await _connectedDevice!.disconnect();
        } catch (e) {
          log('⚠️ Error during disconnect (may already be disconnected): $e');
        }
        
        // Remove device from discovered devices list
        _discoveredDevices.removeWhere((d) => d.remoteId == deviceId);
        log('🗑️ Removed $deviceName from discovered devices list');
        _devicesController.add(List.from(_discoveredDevices));
        
        log('✅ Disconnected from $deviceName');
        _connectedDevice = null;
        _connectionStateController.add(false);
        
        // Reset weight data and characteristic
        _lastValidWeight = null;
        _lastWeightUpdateTime = null;
        _weightCharacteristic = null;
      }
    } catch (e) {
      log('❌ Error disconnecting: $e');
      _connectedDevice = null;
      _connectionStateController.add(false);
    }
  }

  /// Check if currently connected
  bool get isConnected => _connectedDevice != null;

  /// Get connected device name
  String? get connectedDeviceName => _connectedDevice?.platformName;

  /// Dispose streams
  void dispose() {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;
    _weightPollingTimer?.cancel();
    _weightPollingTimer = null;
    _cancelCharacteristicSubscriptions();
    _devicesController.close();
    _weightDataController.close();
    _connectionStateController.close();
  }
}

