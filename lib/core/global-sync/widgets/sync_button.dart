import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/provider/sync-provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

/// A reusable sync button widget that triggers sync with UI feedback
class SyncButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final double? borderRadius;

  const SyncButton({
    super.key,
    this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return CustomButton(
          text: syncProvider.isSyncing 
              ? l10n.syncing
              : (text ?? l10n.syncData),
          onPressed: syncProvider.isSyncing 
              ? null 
              : () => syncProvider.splashSyncWithDialog(context),
          isLoading: syncProvider.isSyncing,
          color: backgroundColor,
          textColor: textColor,
          width: padding?.horizontal ?? 200,
        );
      },
    );
  }
}

/// A sync status indicator widget
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        if (!syncProvider.isSyncing) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const LoadingIndicator(size: 16, strokeWidth: 2),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      syncProvider.syncStatus,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: syncProvider.syncProgressPercentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${syncProvider.syncProgress}/${syncProvider.totalSteps} ${l10n.stepsCompleted}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
