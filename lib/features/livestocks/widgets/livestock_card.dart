import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/provider/all.additional.data_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class LivestockCard extends StatelessWidget {
  final Livestock livestock;
  final String farmName;
  final VoidCallback onTap;

  const LivestockCard({
    super.key,
    required this.livestock,
    required this.farmName,
    required this.onTap,
  });

  bool _isMaleGender(String gender) {
    return gender.toLowerCase() == 'male';
  }

  String _calculateAge(String dateOfBirth, BuildContext context) {
    try {
      DateTime birthDate = DateTime.parse(dateOfBirth);
      DateTime now = DateTime.now();
      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;

      if (months < 0) {
        years--;
        months += 12;
      }

      final l10n = AppLocalizations.of(context)!;
      
      if (years > 0) {
        if (months == 0) {
          return years == 1 ? '1 ${l10n.year}' : '$years ${l10n.years}';
        }
        return years == 1
            ? '1 ${l10n.year} $months ${months == 1 ? l10n.month : l10n.months}'
            : '$years ${l10n.years} $months ${months == 1 ? l10n.month : l10n.months}';
      } else {
        return months == 1 ? '1 ${l10n.month}' : '$months ${l10n.months}';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  Future<String> _getSpeciesName(BuildContext context, int speciesId) async {
    try {
      final provider = Provider.of<AdditionalDataProvider>(context, listen: false);
      return await provider.getSpeciesNameById(speciesId);
    } catch (e) {
      log('Error fetching species: $e');
      return '---';
    }
  }

  Future<String> _getBreedName(BuildContext context, int breedId) async {
    try {
      final provider = Provider.of<AdditionalDataProvider>(context, listen: false);
      return await provider.getBreedNameById(breedId);
    } catch (e) {
      log('Error fetching breed: $e');
      return '---';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isMale = _isMaleGender(livestock.gender);
    final genderText = isMale ? l10n.male : l10n.female;
    final age = _calculateAge(livestock.dateOfBirth, context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Name and Gender
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            livestock.name.isNotEmpty
                                ? livestock.name
                                : '${l10n.livestock} #${livestock.id}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : Constants.primaryColor,
                              fontSize: 22,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                FontAwesome.seedling_solid,
                                size: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  farmName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                    // Gender Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isMale
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.pink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isMale ? Colors.blue : Colors.pink,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isMale ? Icons.male : Icons.female,
                            color: isMale ? Colors.blue : Colors.pink,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            genderText,
                            style: TextStyle(
                              color: isMale ? Colors.blue : Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Main Content Row
                Row(
                  children: [
                    // Livestock Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.transparent : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          scale: 6.0,
                          image: AssetImage(
                            isMale
                                ? 'assets/images/placeholders/bull-1.png'
                                : 'assets/images/placeholders/cow-1.png',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Details Grid
                    Expanded(
                      child: Column(
                        children: [
                          // First Row of Details
                          Row(
                            children: [
                              Expanded(
                                child: _DetailItem(
                                  label: l10n.age,
                                  value: age,
                                  icon: Iconsax.cake_outline,
                                ),
                              ),
                              Expanded(
                                child: _DetailItem(
                                  label: l10n.weight,
                                  value: '${livestock.weightAsOnRegistration.toStringAsFixed(0)}kg',
                                  icon: Iconsax.weight_outline,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Second Row of Details
                          Row(
                            children: [
                              Expanded(
                                child: FutureBuilder<String>(
                                  future: _getSpeciesName(context, livestock.speciesId),
                                  builder: (context, snapshot) {
                                    return _DetailItem(
                                      label: l10n.species,
                                      value: snapshot.data ?? '---',
                                      icon: Iconsax.pet_outline,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: FutureBuilder<String>(
                                  future: _getBreedName(context, livestock.breedId),
                                  builder: (context, snapshot) {
                                    return _DetailItem(
                                      label: l10n.breed,
                                      value: snapshot.data ?? '---',
                                      icon: Icons.category_outlined,
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

                const SizedBox(height: 16),

                // Action Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      l10n.tapForMoreDetails,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Constants.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
