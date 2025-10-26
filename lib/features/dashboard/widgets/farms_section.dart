import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/section_header.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/empty_state.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/all_farms_bottom_sheet.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/farm_details_bottom_sheet.dart';

class FarmsSection extends StatelessWidget {
  final List<Map<String, dynamic>> farms;
  final VoidCallback? onRefresh;

  const FarmsSection({
    super.key,
    required this.farms,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with farm count
        SectionHeader(
          title: l10n.farms,
          trailing: '${farms.length} ${l10n.farms}',
          onTrailingTap: () => _showAllFarmsBottomSheet(context),
        ),
        
        const SizedBox(height: 16),
        
        if (farms.isEmpty)
          // Empty state for farms
          EmptyState(
            icon: FontAwesome.seedling_solid,
            message: l10n.noFarmsFound,
          )
        else if (farms.length > 2)
          // Grid view for multiple farms - exactly like old project
          SizedBox(
            width: double.maxFinite,
            height: size.height / 3.15, // fixed height so no overflow
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true, // important when inside scrollable
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 2,
                childAspectRatio: 2 / 3.9,
              ),
              itemCount: farms.length,
              itemBuilder: (context, index) {
                final farm = farms[index];
                return _buildFarmCard(context, farm);
              },
            ),
          )
        else
          // List view for few farms
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: farms.length,
            itemBuilder: (context, index) {
              final farm = farms[index];
              return _buildFarmCard(context, farm);
            },
          ),
      ],
    );
  }

  Widget _buildFarmCard(BuildContext context, Map<String, dynamic> farm) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final farmName = farm['name'] ?? l10n.farm;
    final livestockCount = farm['livestockCount'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showFarmDetailsBottomSheet(context, farm);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              // Glassmorphism/Liquid background
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
              boxShadow: [
                BoxShadow(
                  color: Constants.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Farm Icon with seedling-like styling
                Container(
                  width: 60,
                  height: 60,
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
                    boxShadow: [
                      BoxShadow(
                        color: Constants.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    FontAwesome.seedling_solid, // Using home icon as seedling-like
                    color: const Color.fromARGB(255, 233, 233, 233),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Farm Details with smaller name size
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        farmName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18, // Decreased from 25 to 18
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Livestock Count with primary color instead of green
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 0, 130, 39).withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
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
                                  livestockCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.livestock,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Arrow with subtle animation hint
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.grey[700] : Colors.grey[100])?.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAllFarmsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AllFarmsBottomSheet(
        farms: farms,
        onRefresh: onRefresh,
      ),
    );
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
