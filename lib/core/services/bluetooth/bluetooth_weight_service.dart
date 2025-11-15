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

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
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

      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 10));
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
      await FlutterBluePlus.stopScan();
      _isScanning = false;
      log('✅ Scan stopped');
    } catch (e) {
      log('❌ Error stopping scan: $e');
    }
  }

  /// Connect to a Bluetooth device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      log('🔗 Connecting to ${device.platformName}...');

      // Disconnect from previous device if any
      if (_connectedDevice != null) {
        await disconnectDevice();
      }

      // Connect to device
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      _connectedDevice = device;
      _connectionStateController.add(true);

      log('✅ Connected to ${device.platformName}');

      // Discover services and characteristics
      await _discoverServicesAndSubscribe(device);

      return true;
    } catch (e) {
      log('❌ Error connecting to device: $e');
      _connectionStateController.add(false);
      return false;
    }
  }

  /// Discover services and subscribe to weight data notifications
  Future<void> _discoverServicesAndSubscribe(BluetoothDevice device) async {
    try {
      // Discover services
      final services = await device.discoverServices();
      log('🔍 Discovered ${services.length} services');

      // Look for weight characteristic (usually in a custom service)
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Check if characteristic supports notify
          if (characteristic.properties.notify) {
            log('📡 Found notify characteristic: ${characteristic.uuid}');

            // Subscribe to notifications
            await characteristic.setNotifyValue(true);
            
            characteristic.lastValueStream.listen((value) {
              if (value.isNotEmpty) {
                // Parse weight data (format depends on device)
                final weight = _parseWeightData(value);
                if (weight != null) {
                  log('📊 Weight received: $weight kg');
                  _weightDataController.add(weight);
                }
              }
            });
          }

          // If characteristic supports read, try reading it
          if (characteristic.properties.read) {
            try {
              final value = await characteristic.read();
              final weight = _parseWeightData(value);
              if (weight != null) {
                log('📊 Weight read: $weight kg');
                _weightDataController.add(weight);
              }
            } catch (e) {
              log('⚠️ Could not read characteristic: $e');
            }
          }
        }
      }
    } catch (e) {
      log('❌ Error discovering services: $e');
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
        await _connectedDevice!.disconnect();
        log('✅ Disconnected from ${_connectedDevice!.platformName}');
        _connectedDevice = null;
        _connectionStateController.add(false);
      }
    } catch (e) {
      log('❌ Error disconnecting: $e');
    }
  }

  /// Check if currently connected
  bool get isConnected => _connectedDevice != null;

  /// Get connected device name
  String? get connectedDeviceName => _connectedDevice?.platformName;

  /// Dispose streams
  void dispose() {
    _devicesController.close();
    _weightDataController.close();
    _connectionStateController.close();
  }
}

