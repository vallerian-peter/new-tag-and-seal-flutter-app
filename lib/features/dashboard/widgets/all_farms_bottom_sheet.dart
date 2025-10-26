import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/farm_details_bottom_sheet.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/provider/farm_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/farm_form.dart';

class AllFarmsBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> farms;
  final VoidCallback? onRefresh;

  const AllFarmsBottomSheet({
    super.key,
    required this.farms,
    this.onRefresh,
  });

  @override
  State<AllFarmsBottomSheet> createState() => _AllFarmsBottomSheetState();
}

class _AllFarmsBottomSheetState extends State<AllFarmsBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredFarms = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFarms);
    _filteredFarms = List.from(widget.farms);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFarms() {
    if (!mounted) return;
    
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _filteredFarms = List.from(widget.farms);
      });
      return;
    }

    final filtered = widget.farms.where((farm) {
      final farmName = (farm['name'] ?? '').toString().toLowerCase();
      final livestockCount = (farm['livestockCount'] ?? 0).toString();
      
      return farmName.contains(query) || livestockCount.contains(query);
    }).toList();

    setState(() {
      _filteredFarms = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.allFarms,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.allFarmsDescription,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.farms.length} ${l10n.farms}',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '${l10n.searchText} ${l10n.farms}...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          
          // Results count
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredFarms.length} ${l10n.farms.toLowerCase()} ${l10n.foundText.toLowerCase()}',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          
          // Farms List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _filteredFarms.isEmpty
                  ? _buildEmptyState(isDark, l10n)
                  : _buildFarmsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty ? Icons.search_off : FontAwesome.seedling_solid,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty ? l10n.noFarmsFound : l10n.noFarmsFound,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty 
                ? l10n.tryDifferentSearchTerm
                : l10n.addFarm,
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmsList() {
    return ListView.builder(
      itemCount: _filteredFarms.length,
      itemBuilder: (context, index) {
        final farm = _filteredFarms[index];
        final l10n = AppLocalizations.of(context)!;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Slidable(
            key: ValueKey(farm['uuid'] ?? index),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
                // Edit Action
                SlidableAction(
                  onPressed: (_) => _handleEditFarm(context, farm),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: l10n.edit,
                ),
                // Delete Action
                SlidableAction(
                  onPressed: (_) => _handleDeleteFarm(context, farm),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: l10n.delete,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showFarmDetailsBottomSheet(context, farm);
              },
              child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Constants.primaryColor.withValues(alpha: 0.1),
                    Constants.primaryColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Constants.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  // Farm Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Constants.primaryColor,
                          Constants.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      FontAwesome.seedling_solid,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Farm Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm['name'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color.fromARGB(255, 0, 125, 31).withValues(alpha: 0.6),
                                    const Color.fromARGB(255, 0, 162, 59).withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Iconsax.pet_outline,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${farm['livestockCount'] ?? 0}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 8),

                            Text(l10n.livestocks, 
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  void _handleEditFarm(BuildContext context, Map<String, dynamic> farm) async {
    // Close the bottom sheet first
    Navigator.pop(context);
    
    // Navigate to farm form with farm data for editing
    final farmData = farm['farmData'] as Farm?;
    
    if (farmData != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FarmFormScreen(farm: farmData),
        ),
      );
      
      // Refresh farms list after returning from edit form if farm was updated
      if (result == true && widget.onRefresh != null) {
        widget.onRefresh!();
      }
    }
  }

  void _handleDeleteFarm(BuildContext context, Map<String, dynamic> farm) {
    // Don't pop the bottom sheet yet - show confirmation dialog first
    _showDeleteConfirmationDialog(context, farm);
  }

  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> farm) {
    final l10n = AppLocalizations.of(context)!;
    
    AlertDialogs.showConfirmation(
      context: context,
      title: l10n.delete,
      message: '${l10n.deleteConfirmationMessage}\n\n${farm['name'] ?? l10n.farm}',
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      onConfirm: () async {
        // Close the bottom sheet first
        Navigator.pop(context);
        // Then perform delete
        await _performDelete(context, farm);
      },
      onCancel: () {
        // Close the confirmation dialog only, bottom sheet stays open
        Navigator.pop(context);
      },
    );
  }

  Future<void> _performDelete(BuildContext context, Map<String, dynamic> farm) async {
    log('🌾🌾 Farms: ${farm}');
    final l10n = AppLocalizations.of(context)!;
    final farmId = farm['id'];
    
    if (farmId == null) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: 'Invalid farm ID',
        buttonText: l10n.ok,
      );
      return;
    }

    try {
      // Mark farm as deleted (soft delete with syncAction='deleted')
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final success = await farmProvider.markFarmAsDeleted(farmId);
      
      if (success) {
        // Remove from filtered list to update UI
        setState(() {
          _filteredFarms.removeWhere((f) => f['id'] == farmId);
        });

        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: '${farm['name']} marked for deletion',
          buttonText: l10n.ok,
        );
      } else {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: 'Failed to mark farm for deletion',
          buttonText: l10n.ok,
        );
      }
    } catch (e) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: 'Error deleting farm: $e',
        buttonText: l10n.ok,
      );
    }
  }

  void _showFarmDetailsBottomSheet(BuildContext context, Map<String, dynamic> farm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FarmDetailsBottomSheet(farm: farm),
    );
  }
}
