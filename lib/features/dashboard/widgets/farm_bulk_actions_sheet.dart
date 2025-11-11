import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/controllers/event_form_control.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class FarmBulkActionsSheet extends StatelessWidget {
  final Map<String, dynamic> farm;

  const FarmBulkActionsSheet({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final farmName = (farm['name'] ?? l10n.farm).toString();
    final farmLocation = (farm['location'] ?? l10n.location).toString();

    final actions = _buildActions(l10n);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.bulkActions,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFarmInfoCard(theme, farmName, farmLocation),
            const SizedBox(height: 20),
            ...List.generate(actions.length, (index) {
              final action = actions[index];
              return Padding(
                padding:
                    EdgeInsets.only(bottom: index == actions.length - 1 ? 0 : 12),
                child: _BulkActionButton(
                  config: action,
                  onTap: () => _handleActionTap(context, action, l10n),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _handleActionTap(
    BuildContext context,
    _BulkActionConfig config,
    AppLocalizations l10n,
  ) {
    if (config.logType == null || !config.supportsBulk) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
      return;
    }

    final farmUuid = (farm['uuid'] ?? farm['farmUuid'] ?? '').toString();
    if (farmUuid.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.logContextMissing)));
      return;
    }

    EventFormControl.open(
      context: context,
      logType: config.logType!,
      title: config.title,
      farmUuid: farmUuid,
      livestockUuid: null,
      isBulk: true,
      onCompleted: () => Navigator.of(context).maybePop(),
    );
  }

  Widget _buildFarmInfoCard(
    ThemeData theme,
    String farmName,
    String farmLocation,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
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
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Text(
                  farmName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),
                
                Text(
                  farmLocation,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_BulkActionConfig> _buildActions(AppLocalizations l10n) {
    return [
      _BulkActionConfig(
        title: '${l10n.bulk} ${l10n.deworming}',
        icon: Icons.bug_report_outlined,
        color: Colors.teal,
        logType: EventLogTypes.deworming,
        supportsBulk: true,
      ),
      _BulkActionConfig(
        title: '${l10n.bulk} ${l10n.disposal}',
        icon: Icons.delete_sweep_outlined,
        color: Colors.deepOrangeAccent,
        logType: EventLogTypes.disposal,
        supportsBulk: true,
      ),
      _BulkActionConfig(
        title: '${l10n.bulk} ${l10n.feeding}',
        icon: Icons.restaurant,
        color: Colors.green,
        logType: EventLogTypes.feeding,
        supportsBulk: true,
      ),
      _BulkActionConfig(
        title: '${l10n.bulk} ${l10n.medication}',
        icon: Icons.medical_services_outlined,
        color: Colors.indigo,
        logType: EventLogTypes.medication,
        supportsBulk: true,
      ),
      _BulkActionConfig(
        title: '${l10n.bulk} ${l10n.milking}',
        icon: Icons.water_drop_outlined,
        color: Colors.lightBlue,
        logType: EventLogTypes.milking,
        supportsBulk: true,
      ),
      _BulkActionConfig(
        title: '${l10n.bulk} ${l10n.transfer}',
        icon: Icons.change_circle_outlined,
        color: Colors.purpleAccent,
        logType: EventLogTypes.transfer,
        supportsBulk: true,
      ),
      _BulkActionConfig(
        title: '${l10n.bulk} ${l10n.vaccination}',
        icon: Icons.vaccines_outlined,
        color: const Color(0xFF4CAF50),
        logType: EventLogTypes.vaccination,
        supportsBulk: true,
      ),
    ];
  }
}

class _BulkActionConfig {
  final String title;
  final IconData icon;
  final Color color;
  final String? logType;
  final bool supportsBulk;

  const _BulkActionConfig({
    required this.title,
    required this.icon,
    required this.color,
    this.logType,
    this.supportsBulk = false,
  });
}

class _BulkActionButton extends StatelessWidget {
  final _BulkActionConfig config;
  final VoidCallback onTap;

  const _BulkActionButton({required this.config, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: config.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                config.icon,
                color: config.color,
                size: 22,
              ),
            ),
            
            const SizedBox(width: 16),

            Expanded(
              child: Text(
                config.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: config.color,
            ),
          ],
        ),
      ),
    );
  }
}

