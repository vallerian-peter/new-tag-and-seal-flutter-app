import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/features/home/presentation/home_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // Determine navigation target based on title
    int? targetTabIndex;
    if (title == l10n.livestock) {
      targetTabIndex = 1; // Livestock tab
    } else if (title == l10n.events) {
      targetTabIndex = 3; // Events tab
    } else if (title == l10n.farms) {
      targetTabIndex = 0; // Dashboard tab (farms section)
    }
    
    return InkWell(
      onTap: onTap ?? () {
        if (targetTabIndex != null) {
          // Find HomeScreen state and change tab
          final homeState = context.findAncestorStateOfType<HomeScreenState>();
          if (homeState != null) {
            homeState.changeTab(targetTabIndex);
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

