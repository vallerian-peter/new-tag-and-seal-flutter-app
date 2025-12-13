import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/role_helper.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/livestock_form_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/presentation/vaccine_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/farm_bulk_actions_sheet.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/provider/all.additional.data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/livestock_image_helper.dart';

class FarmDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> farm;
  final VoidCallback? onRefresh;

  const FarmDetailsBottomSheet({
    super.key,
    required this.farm,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Get actual livestock data from farm
    final livestock = farm['livestock'] as List? ?? [];
    
    // Count livestock by gender
    int maleCount = 0;
    int femaleCount = 0;
    
    for (var animal in livestock) {
      if (animal is Livestock) {
        final gender = animal.gender;
        if (gender.toString().toLowerCase() == 'male') {
          maleCount++;
        } else if (gender.toString().toLowerCase() == 'female') {
          femaleCount++;
        }
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
            child: Row(
              children: [
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    FontAwesome.seedling_solid,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farm['name'] ?? l10n.farm,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        farm['location'] ?? l10n.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_FarmAction>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface,
                  ),
                  color: theme.scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case _FarmAction.bulkActions:
                        Navigator.pop(context); // Close the current bottom sheet
                        _showBulkActionsSheet(context, farm);
                        break;
                      case _FarmAction.addVaccine:
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        if (!RoleHelper.checkCanAddVaccine(context, l10n, authProvider)) {
                          return; // Access denied, toast already shown
                        }
                        Navigator.pop(context); // Close the current bottom sheet
                        _navigateToVaccineForm(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _FarmAction.bulkActions,
                      child: Row(
                        children: [
                          const Icon(Icons.layers_outlined, size: 18),
                          const SizedBox(width: 12),
                          Text(l10n.bulkActions),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _FarmAction.addVaccine,
                      child: Row(
                        children: [
                          const Icon(Icons.vaccines_outlined, size: 18),
                          const SizedBox(width: 12),
                          Text(l10n.addVaccine),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [

                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: l10n.total,
                    value: '${farm['livestockCount'] ?? 0}',
                    icon: Iconsax.pet_outline,
                    color: Constants.primaryColor,
                  ),
                ),

                const SizedBox(width: 16),
                
                Expanded(
                  child: _buildStatCardWithUnicode(
                    context: context,
                    title: l10n.male,
                    value: '$maleCount',
                    unicodeIcon: '♂',
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 16),
                
                Expanded(
                  child: _buildStatCardWithUnicode(
                    context: context,
                    title: l10n.female,
                    value: '$femaleCount',
                    unicodeIcon: '♀',
                    color: Colors.pink,
                  ),
                ),
                
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // Copy + FarmUuid
          _CopyFarmUuidWidget(
            farmUuid: farm['uuid'] as String,
            theme: theme,
          ),
          // Livestock List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [

                Text(
                  '${l10n.allLivestocksText} (${livestock.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const Spacer(),
                
                TextButton.icon(
                  onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    if (!RoleHelper.checkCanCreateLivestock(context, l10n, authProvider)) {
                      return; // Access denied, toast already shown
                    }
                    
                    Navigator.pop(context); // Close bottom sheet
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LivestockFormScreen(
                          preSelectedFarmUuid: farm['uuid'] as String,
                        ),
                      ),
                    );
                    
                    // Refresh dashboard if livestock was successfully registered
                    if (result == true && onRefresh != null) {
                      onRefresh!();
                    }
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                  ),
                  label: Text(
                    l10n.addLivestock,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Constants.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Livestock List
          Expanded(
            child: livestock.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.pet_outline,
                          size: 48,
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noLivestockFound,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: livestock.length,
                    itemBuilder: (context, index) {
                      final animal = livestock[index];
                      return _buildLivestockCard(context, animal);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 25,
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardWithUnicode({
    required BuildContext context,
    required String title,
    required String value,
    required String unicodeIcon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 25,
            child: Center(
              child: Text(
                unicodeIcon,
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivestockCard(BuildContext context, Livestock animal) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    print(animal);

    // Extract animal data
    final animalName = animal.name.isEmpty ? '---' : animal.name;
    final animalGender = animal.gender.isEmpty ? '---': animal.gender;
    
    // Calculate age from dateOfBirth
    final birthDate = DateTime.parse(animal.dateOfBirth);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? theme.colorScheme.surface.withValues(alpha: 0.1) : theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? [
                // Subtle shadow for dark theme
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ]
            : [
                // Light shadow for light theme
                BoxShadow(
                  color: Colors.grey.shade100,
                  offset: const Offset(-1, 2),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Row(
        children: [
          // Animal image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                scale: 6.0,
                image: AssetImage(
                  LivestockImageHelper.getPlaceholderForLivestock(animal),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Animal details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  animalName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Details in a more organized grid layout
                Row(
                  children: [
                    // Gender
                    Expanded(
                      child: _buildInfoItem(
                        context: context,
                        icon: animalGender.toLowerCase() == 'male' 
                            ? Icons.male 
                            : Icons.female,
                        iconColor: animalGender.toLowerCase() == 'male' 
                            ? Colors.blue 
                            : Colors.pink,
                        label: l10n.gender,
                        value: animalGender.toLowerCase() == 'male' 
                            ? l10n.male 
                            : l10n.female,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Age
                    Expanded(
                      child: _buildInfoItem(
                        context: context,
                        icon: Icons.cake_outlined,
                        iconColor: theme.colorScheme.primary,
                        label: 'Age',
                        value: '$age yr${age != 1 ? 's' : ''}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Second row: Species and Breed
                Row(
                  children: [
                    // Species - Using FutureBuilder to fetch species name
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _getSpeciesName(context, animal.speciesId),
                        builder: (context, snapshot) {
                          final species = snapshot.data ?? '---';
                          return _buildInfoItem(
                            context: context,
                            icon: Iconsax.pet_outline,
                            iconColor: theme.colorScheme.primary,
                            label: l10n.species,
                            value: species,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Breed - Using FutureBuilder to fetch breed name
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _getBreedName(context, animal.breedId),
                        builder: (context, snapshot) {
                          final breed = snapshot.data ?? '---';
                          return _buildInfoItem(
                            context: context,
                            icon: Icons.category_outlined,
                            iconColor: theme.colorScheme.primary,
                            label: l10n.breed,
                            value: breed,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper widget to build info items
  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: iconColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
  
  // Helper method to get species name using provider
  Future<String> _getSpeciesName(BuildContext context, int speciesId) async {
    try {
      final provider = Provider.of<AdditionalDataProvider>(context, listen: false);
      final name = await provider.getSpeciesNameById(speciesId);
      print('Species lookup for ID $speciesId: $name');
      return name;
    } catch (e) {
      print('Error fetching species: $e');
      return '---';
    }
  }
  
  // Helper method to get breed name using provider
  Future<String> _getBreedName(BuildContext context, int breedId) async {
    try {
      final provider = Provider.of<AdditionalDataProvider>(context, listen: false);
      final name = await provider.getBreedNameById(breedId);
      print('Breed lookup for ID $breedId: $name');
      return name;
    } catch (e) {
      print('Error fetching breed: $e');
      return '---';
    }
  }

  // Helper method to show bulk actions sheet
  void _showBulkActionsSheet(BuildContext context, Map<String, dynamic> farm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FarmBulkActionsSheet(farm: farm),
    );
  }

  // Helper method to navigate to vaccine form
  void _navigateToVaccineForm(BuildContext context) {
    final farmUuid = farm['uuid'] as String?;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccineFormScreen(
          farmUuid: farmUuid,
        ),
      ),
    ).then((_) {
      // Refresh the dashboard if vaccine was successfully created
      if (onRefresh != null) {
        onRefresh!();
      }
    });
  }
}

enum _FarmAction {
  bulkActions,
  addVaccine,
}

class _CopyFarmUuidWidget extends StatefulWidget {
  final String farmUuid;
  final ThemeData theme;

  const _CopyFarmUuidWidget({
    required this.farmUuid,
    required this.theme,
  });

  @override
  State<_CopyFarmUuidWidget> createState() => _CopyFarmUuidWidgetState();
}

class _CopyFarmUuidWidgetState extends State<_CopyFarmUuidWidget> {
  bool _isCopied = false;
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.farmUuid));
    setState(() {
      _isCopied = true;
    });
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _isCopied ? null : _handleCopy,
            icon: Icon(
              _isCopied ? Icons.check_circle : Icons.copy,
              color: _isCopied 
                  ? Colors.green 
                  : Constants.primaryColor,
              size: 17,
            ),
          ),
          Text(
            '${l10n?.farm} UUID: ${widget.farmUuid}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

