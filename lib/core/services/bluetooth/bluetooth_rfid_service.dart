import 'dart:async';
import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bluetooth_weight_service.dart'; // Reuse error types

/// Service for handling Bluetooth RFID scanner connections
///
/// Manages scanning, connecting, and receiving RFID tag data from Bluetooth scanners
class BluetoothRfidService {
  static final BluetoothRfidService _instance = BluetoothRfidService._internal();
  factory BluetoothRfidService() => _instance;
  BluetoothRfidService._internal();

  // Stream controllers
  final _devicesController = StreamController<List<BluetoothDevice>>.broadcast();
  final _tagDataController = StreamController<String>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  // Getters for streams
  Stream<List<BluetoothDevice>> get devicesStream => _devicesController.stream;
  Stream<String> get tagDataStream => _tagDataController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  // Current state
  BluetoothDevice? _connectedDevice;
  List<BluetoothDevice> _discoveredDevices = [];
  bool _isScanning = false;

  /// Check and request Bluetooth permissions (reuse from weight service)
  Future<PermissionResult> checkBluetoothPermissions() async {
    try {
      if (await FlutterBluePlus.isSupported == false) {
        log('❌ Bluetooth not supported on this device');
        return PermissionResult(
          granted: false,
          errorType: BluetoothErrorType.notSupported,
          errorMessage: 'Bluetooth is not supported on this device',
        );
      }

      log('🔐 Requesting Bluetooth permissions...');

      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetooth,
        Permission.location,
      ].request();

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

  /// Start scanning for Bluetooth RFID scanners
  /// Returns error type if scan fails, null if successful
  Future<BluetoothErrorType?> startScan() async {
    try {
      if (_isScanning) {
        log('⚠️ Already scanning');
        return null;
      }

      if (await FlutterBluePlus.isSupported == false) {
        log('❌ Bluetooth not supported');
        return BluetoothErrorType.notSupported;
      }

      final permissionResult = await checkBluetoothPermissions();
      if (!permissionResult.granted) {
        return permissionResult.errorType;
      }

      final isOn = await isBluetoothOn();
      if (!isOn) {
        log('⚠️ Bluetooth is turned off');
        return BluetoothErrorType.bluetoothOff;
      }

      _isScanning = true;
      _discoveredDevices.clear();

      log('🔍 Starting Bluetooth scan for RFID scanners...');

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          final deviceName = r.device.platformName.toLowerCase();
          
          // Filter for RFID scanners (check device name contains RFID-related keywords)
          if (deviceName.contains('rfid') || 
              deviceName.contains('nfc') || 
              deviceName.contains('scanner') ||
              deviceName.contains('reader') ||
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

  /// Connect to a Bluetooth RFID scanner device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      log('🔗 Connecting to ${device.platformName}...');

      if (_connectedDevice != null) {
        await disconnectDevice();
      }

      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      _connectedDevice = device;
      _connectionStateController.add(true);

      log('✅ Connected to ${device.platformName}');

      await _discoverServicesAndSubscribe(device);

      return true;
    } catch (e) {
      log('❌ Error connecting to device: $e');
      _connectionStateController.add(false);
      return false;
    }
  }

  /// Discover services and subscribe to RFID tag data notifications
  Future<void> _discoverServicesAndSubscribe(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      log('🔍 Discovered ${services.length} services');

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Subscribe to notifications for tag data
          if (characteristic.properties.notify) {
            log('📡 Found notify characteristic: ${characteristic.uuid}');

            await characteristic.setNotifyValue(true);
            
            characteristic.lastValueStream.listen((value) {
              if (value.isNotEmpty) {
                final tagId = _parseTagData(value);
                if (tagId != null && tagId.isNotEmpty) {
                  log('🏷️ RFID Tag received: $tagId');
                  _tagDataController.add(tagId);
                }
              }
            });
          }

          // If characteristic supports read, try reading it
          if (characteristic.properties.read) {
            try {
              final value = await characteristic.read();
              final tagId = _parseTagData(value);
              if (tagId != null && tagId.isNotEmpty) {
                log('🏷️ RFID Tag read: $tagId');
                _tagDataController.add(tagId);
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

  /// Parse RFID tag data from Bluetooth bytes
  /// 
  /// RFID scanners typically send tag IDs as:
  /// - ASCII string: "E2001234567890123456\n"
  /// - Hex string: "E2001234567890123456"
  /// - Binary: Raw bytes that need conversion
  String? _parseTagData(List<int> data) {
    try {
      if (data.isEmpty) return null;

      // Try parsing as ASCII string first (most common)
      final asciiString = String.fromCharCodes(data).trim();
      if (asciiString.isNotEmpty) {
        // Remove common delimiters
        final cleaned = asciiString
            .replaceAll('\r', '')
            .replaceAll('\n', '')
            .replaceAll('\t', '')
            .replaceAll(' ', '')
            .trim();
        
        if (cleaned.isNotEmpty) {
          return cleaned;
        }
      }

      // Try parsing as hex string
      final hexString = data.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      if (hexString.isNotEmpty) {
        return hexString.toUpperCase();
      }

      log('⚠️ Could not parse RFID tag data: $data');
      return null;
    } catch (e) {
      log('❌ Error parsing RFID tag data: $e');
      return null;
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
    _tagDataController.close();
    _connectionStateController.close();
  }
}

