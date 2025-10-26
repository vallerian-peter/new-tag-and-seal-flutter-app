# Farm Provider Usage Guide

## Overview

The `FarmProvider` now includes comprehensive state management with loading, error, and success states. All messages are localized for both English and Swahili.

## State Management

### Available States

- **`isLoading`**: `bool` - Indicates if any operation is in progress
- **`errorMessage`**: `String?` - Contains error message if operation failed
- **`successMessage`**: `String?` - Contains success message if operation succeeded
- **`loadingMessage`**: `String?` - Contains current loading message

### State Methods

- **`clearState()`**: Clears all states (loading, error, success)

## Usage Examples

### Example 1: Get All Farms with Loading UI

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/provider/farm_provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';

class FarmsListScreen extends StatefulWidget {
  @override
  State<FarmsListScreen> createState() => _FarmsListScreenState();
}

class _FarmsListScreenState extends State<FarmsListScreen> {
  List<Farm> _farms = [];
  
  @override
  void initState() {
    super.initState();
    _loadFarms();
  }
  
  Future<void> _loadFarms() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    
    try {
      final farms = await farmProvider.getFarms();
      setState(() {
        _farms = farms;
      });
    } catch (e) {
      // Error state is already managed by provider
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(farmProvider.errorMessage ?? 'Failed to load farms'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Farms')),
      body: farmProvider.isLoading
        ? const Center(child: LoadingIndicator())
        : _farms.isEmpty
          ? Center(child: Text('No farms found'))
          : ListView.builder(
              itemCount: _farms.length,
              itemBuilder: (context, index) {
                final farm = _farms[index];
                return ListTile(
                  title: Text(farm.name),
                  subtitle: Text(farm.referenceNo),
                );
              },
            ),
    );
  }
}
```

### Example 2: Create Farm with State Feedback

```dart
Future<void> _createFarm(Map<String, dynamic> farmData) async {
  final farmProvider = Provider.of<FarmProvider>(context, listen: false);
  
  try {
    final farm = await farmProvider.createFarm(farmData);
    
    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(farmProvider.successMessage ?? 'Farm created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back
      Navigator.pop(context, true);
    }
  } catch (e) {
    if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(farmProvider.errorMessage ?? 'Failed to create farm'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### Example 3: Get Farm with Livestock

```dart
Future<void> _loadFarmWithLivestock(int farmId) async {
  final farmProvider = Provider.of<FarmProvider>(context, listen: false);
  
  try {
    final farmData = await farmProvider.getFarmWithLivestock(farmId);
    
    if (farmData != null) {
      final farm = farmData['farm'] as Farm;
      final livestock = farmData['livestock'] as List<Livestock>;
      final count = farmData['livestockCount'] as int;
      
      print('Farm: ${farm.name}');
      print('Livestock count: $count');
      
      // Update UI with farm and livestock data
      setState(() {
        _currentFarm = farm;
        _livestock = livestock;
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(farmProvider.errorMessage ?? 'Failed to load farm'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### Example 4: Listening to State Changes

```dart
@override
Widget build(BuildContext context) {
  return Consumer<FarmProvider>(
    builder: (context, farmProvider, child) {
      // Access state
      if (farmProvider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (farmProvider.errorMessage != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(farmProvider.errorMessage!),
            ],
          ),
        );
      }
      
      if (farmProvider.successMessage != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 48, color: Colors.green),
              SizedBox(height: 16),
              Text(farmProvider.successMessage!),
            ],
          ),
        );
      }
      
      return YourContentWidget();
    },
  );
}
```

## Localization

All state messages are localized and support both English and Swahili:

### English Messages
- `loadingFarms`: "Loading farms..."
- `farmLoadedSuccessfully`: "Farm loaded successfully"
- `farmLoadFailed`: "Failed to load farm"
- `farmsLoadedSuccessfully`: "Farms loaded successfully"
- `farmsLoadFailed`: "Failed to load farms"
- `loadingFarmWithLivestock`: "Loading farm with livestock..."
- `farmWithLivestockLoadedSuccessfully`: "Farm with livestock loaded successfully"
- `farmWithLivestockLoadFailed`: "Failed to load farm with livestock"
- `noFarmFound`: "No farm found"
- `noFarmsFound`: "No farms found"

### Swahili Messages
- `loadingFarms`: "Inapakia mashamba..."
- `farmLoadedSuccessfully`: "Shamba limepokewa kwa mafanikio"
- `farmLoadFailed`: "Imeshindwa kupokea shamba"
- `farmsLoadedSuccessfully`: "Mashamba yamepokewa kwa mafanikio"
- `farmsLoadFailed`: "Imeshindwa kupokea mashamba"
- `loadingFarmWithLivestock`: "Inapakia shamba na mifugo..."
- `farmWithLivestockLoadedSuccessfully`: "Shamba na mifugo limepokewa kwa mafanikio"
- `farmWithLivestockLoadFailed`: "Imeshindwa kupokea shamba na mifugo"
- `noFarmFound`: "Hakuna shamba lililopatikana"
- `noFarmsFound`: "Hakuna mashamba yaliyopatikana"

## Best Practices

1. **Always use try-catch**: Handle exceptions and show appropriate error messages
2. **Check mounted**: Always check if widget is still mounted before updating state
3. **Clear state**: Call `clearState()` when navigating away from a screen
4. **Listen to provider**: Use `Consumer` or `watch` to react to state changes
5. **Show feedback**: Display loading indicators and success/error messages to users

