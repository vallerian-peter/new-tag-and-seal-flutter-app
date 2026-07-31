import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class BulkLivestockInfoCard extends StatelessWidget {
  const BulkLivestockInfoCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Constants.primaryColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: Constants.textSize,
                height: 1.35,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BulkLivestockSectionTitle extends StatelessWidget {
  const BulkLivestockSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: Constants.largeTextSize,
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: Constants.textSize - 1,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class BulkLivestockPreviewInfoRow extends StatelessWidget {
  const BulkLivestockPreviewInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 15, color: colors.onSurface.withValues(alpha: 0.45)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurface.withValues(alpha: 0.55),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? colors.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class BulkLivestockSummaryEntry {
  const BulkLivestockSummaryEntry(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class BulkLivestockSharedSummaryCard extends StatelessWidget {
  const BulkLivestockSharedSummaryCard({
    super.key,
    required this.title,
    required this.entries,
  });

  final String title;
  final List<BulkLivestockSummaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Constants.primaryColor.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fact_check_outlined,
                color: Constants.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    entry.icon,
                    size: 14,
                    color: colors.onSurface.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 120,
                    child: Text(
                      entry.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BulkLivestockReviewGuardCard extends StatelessWidget {
  const BulkLivestockReviewGuardCard({
    super.key,
    required this.total,
    required this.alive,
    required this.dead,
    required this.hasDisposalType,
  });

  final int total;
  final int alive;
  final int dead;
  final bool hasDisposalType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isConsistent = alive + dead == total && alive >= 0 && dead >= 0;
    final disposalState = dead == 0
        ? l10n.pigletBulkStatusNotApplicable
        : (hasDisposalType
              ? l10n.pigletBulkStatusReady
              : l10n.pigletBulkStatusRequired);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isConsistent
            ? Constants.primaryColor.withValues(alpha: 0.06)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConsistent
              ? Constants.primaryColor.withValues(alpha: 0.22)
              : theme.colorScheme.error.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConsistent ? Icons.verified_outlined : Icons.error_outline,
                color: isConsistent
                    ? Constants.primaryColor
                    : theme.colorScheme.error,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.pigletBulkSaveCheckTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BulkLivestockPreviewInfoRow(
            icon: Icons.groups_2_outlined,
            label: l10n.total,
            value: '$total',
          ),
          const SizedBox(height: 6),
          BulkLivestockPreviewInfoRow(
            icon: Icons.favorite_outlined,
            label: l10n.aliveCount,
            value: '$alive',
            valueColor: Colors.green.shade700,
          ),
          const SizedBox(height: 6),
          BulkLivestockPreviewInfoRow(
            icon: Icons.heart_broken_outlined,
            label: l10n.deadCount,
            value: '$dead',
            valueColor: dead > 0 ? theme.colorScheme.error : null,
          ),
          const SizedBox(height: 6),
          BulkLivestockPreviewInfoRow(
            icon: Icons.delete_forever_outlined,
            label: l10n.pigletBulkDisposalTypeLabel,
            value: disposalState,
            valueColor: dead > 0 && !hasDisposalType
                ? theme.colorScheme.error
                : null,
          ),
        ],
      ),
    );
  }
}
