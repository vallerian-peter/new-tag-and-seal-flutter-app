import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class BulkLivestockDifferenceOption {
  const BulkLivestockDifferenceOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    this.disabledReason,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final String? disabledReason;
}

class BulkLivestockDifferenceSelector extends StatelessWidget {
  const BulkLivestockDifferenceSelector({
    super.key,
    required this.enabled,
    required this.hasSelection,
    required this.onEnabledChanged,
    required this.options,
  });

  final bool enabled;
  final bool hasSelection;
  final ValueChanged<bool> onEnabledChanged;
  final List<BulkLivestockDifferenceOption> options;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? Constants.primaryColor.withValues(alpha: 0.28)
              : theme.colorScheme.outline.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.rule_folder_outlined,
                  color: Constants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pigletBulkDifferentDataQuestion,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.pigletBulkDifferentDataHelp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.68,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                activeThumbColor: Constants.primaryColor,
                activeTrackColor: Constants.primaryColor.withValues(
                  alpha: 0.28,
                ),
                onChanged: onEnabledChanged,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 14),
            Text(
              l10n.pigletBulkChooseDifferentFields,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options
                  .map((option) => _DifferenceChip(option: option))
                  .toList(growable: false),
            ),
            if (!hasSelection) ...[
              const SizedBox(height: 10),
              Text(
                l10n.pigletBulkSelectAtLeastOneDifferentField,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DifferenceChip extends StatelessWidget {
  const _DifferenceChip({required this.option});

  final BulkLivestockDifferenceOption option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = option.selected
        ? Colors.white
        : (option.enabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.38));

    final chip = FilterChip(
      selected: option.selected,
      showCheckmark: false,
      avatar: Icon(option.icon, size: 18, color: foregroundColor),
      label: Text(option.label),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: Constants.primaryColor,
      disabledColor: theme.cardColor.withValues(alpha: 0.55),
      pressElevation: 0,
      elevation: 0,
      side: BorderSide(
        color: option.selected
            ? Constants.primaryColor
            : theme.colorScheme.outline.withValues(alpha: 0.28),
      ),
      labelStyle: TextStyle(
        color: foregroundColor,
        fontWeight: option.selected ? FontWeight.w700 : FontWeight.w500,
      ),
      onSelected: option.enabled ? option.onChanged : null,
    );

    if (option.enabled || option.disabledReason == null) return chip;
    return Tooltip(message: option.disabledReason!, child: chip);
  }
}
