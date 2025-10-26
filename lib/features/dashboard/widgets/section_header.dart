import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final IconData? icon;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.icon,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [

              Icon(
                  icon ?? FontAwesome.seedling_solid,
                  size: 18,
                  color: Constants.successColor,
                ),
                const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
          
              // if (icon != null) ...[
                
              // ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    trailing!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Bootstrap.chevron_right,
                    size: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
