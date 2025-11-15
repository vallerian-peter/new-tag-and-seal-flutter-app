import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/controllers/events_view_control.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/controllers/event_form_control.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/livestock_form_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/data/repository/livestock_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/provider/all.additional.data_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class LivestockDetailsModal {
  static void show({
    required BuildContext context,
    required Livestock livestock,
    required Map<String, String> farmNames,
    required VoidCallback onRefresh,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Pull down bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with image, name, and actions menu
                      _buildHeaderWithActions(context, livestock, isDark, onRefresh),

                      const SizedBox(height: 24),

                      // Info cards - Horizontal scrollable
                      _buildInfoCards(context, livestock, farmNames, isDark),

                      const SizedBox(height: 24),

                      // Log Records Section
                      Text(
                        // 'Records & Logs',
                        l10n.recordsAndLogs,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Log buttons
                      _buildLogButtons(
                        context,
                        livestock,
                        farmNames[livestock.farmUuid],
                        isDark,
                        onRefresh,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHeaderWithActions(
    BuildContext context,
    Livestock livestock,
    bool isDark,
    VoidCallback onRefresh,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      children: [
        // Livestock image
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.contain,
              scale: 6.0,
              image: AssetImage(
                livestock.gender.toLowerCase() == 'male'
                    ? 'assets/images/placeholders/bull-1.png'
                    : 'assets/images/placeholders/cow-1.png',
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Name and age
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                livestock.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.age}: ${_calculateAge(livestock.dateOfBirth)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Actions Menu
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          color: isDark ? Colors.grey[800] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LivestockFormScreen(livestock: livestock),
                ),
              ).then((_) => onRefresh());
            } else if (value == 'delete') {
              Navigator.pop(context);
              _showDeleteConfirmation(context, livestock, onRefresh);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Iconsax.edit_outline, size: 18, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(l10n.editLivestock),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Iconsax.trash_outline, size: 18, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(l10n.deleteLivestock),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildInfoCards(
    BuildContext context,
    Livestock livestock,
    Map<String, String> farmNames,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildInfoCard(
            context,
            l10n.identificationNumber,
            livestock.identificationNumber,
            Icons.numbers,
            Colors.purple,
            isDark,
          ),
          const SizedBox(width: 12),
          _buildInfoCard(
            context,
            l10n.farm,
            farmNames[livestock.farmUuid] ?? l10n.unknownFarm,
            Icons.agriculture,
            Colors.green,
            isDark,
          ),
          const SizedBox(width: 12),
          _buildInfoCard(
            context,
            l10n.gender,
            livestock.gender.toLowerCase() == 'male' ? l10n.male : l10n.female,
            livestock.gender.toLowerCase() == 'male' ? Icons.male : Icons.female,
            livestock.gender.toLowerCase() == 'male' ? Colors.blue : Colors.pink,
            isDark,
          ),
          const SizedBox(width: 12),
          _buildInfoCard(
            context,
            l10n.dateOfBirth,
            livestock.dateOfBirth,
            Icons.cake,
            Colors.orange,
            isDark,
          ),
          const SizedBox(width: 12),
          FutureBuilder<String>(
            future: _getBreedName(context, livestock.breedId),
            builder: (context, snapshot) => _buildInfoCard(
              context,
              l10n.breed,
              snapshot.data ?? '---',
              Icons.pets,
              Colors.teal,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          FutureBuilder<String>(
            future: _getSpeciesName(context, livestock.speciesId),
            builder: (context, snapshot) => _buildInfoCard(
              context,
              l10n.species,
              snapshot.data ?? '---',
              Iconsax.pet_outline,
              Colors.indigo,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          _buildInfoCard(
            context,
            l10n.weight,
            '${livestock.weightAsOnRegistration.toStringAsFixed(0)} kg',
            Icons.monitor_weight,
            Colors.brown,
            isDark,
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static Widget _buildLogButtons(
    BuildContext context,
    Livestock livestock,
    String? farmName,
    bool isDark,
    VoidCallback onRefresh,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isFemale = livestock.gender.toLowerCase() == 'female';

    final logs = _buildLogConfigs(context, livestock, farmName, l10n, onRefresh);
    final applicableLogs = logs
        .where((log) => isFemale ? log.supportsFemale : log.supportsMale)
        .toList();

    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    return FutureBuilder<Map<String, int>>(
      future: eventsProvider.loadLogCounts(
        farmUuid: livestock.farmUuid,
        livestockUuid: livestock.uuid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              AppLocalizations.of(context)!.eventsLoadFailed,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final counts = snapshot.data ?? {};

        return Column(
          children: [
            for (int i = 0; i < applicableLogs.length; i++) ...[
              _buildLogButton(
                context: context,
                config: applicableLogs[i],
                isDark: isDark,
                count: counts[applicableLogs[i].logType] ?? 0,
              ),
              if (i != applicableLogs.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  static List<_LogConfig> _buildLogConfigs(
    BuildContext context,
    Livestock livestock,
    String? farmName,
    AppLocalizations l10n,
    VoidCallback onRefresh,
  ) {
    final farmUuid = livestock.farmUuid;
    final livestockUuid = livestock.uuid;

    return [
      _LogConfig(
        logType: EventLogTypes.feeding,
        title: l10n.feeding,
        icon: Icons.restaurant,
        color: Colors.green,
        supportsMale: true,
        supportsFemale: true,
        onAdd: (ctx) => EventFormControl.open(
          context: context,
          logType: EventLogTypes.feeding,
          title: l10n.feeding,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          onCompleted: onRefresh,
        ),
        onView: (ctx) => EventsViewControl.openLogs(
          context: context,
          logType: EventLogTypes.feeding,
          title: l10n.feeding,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          farmName: farmName,
          livestockName: livestock.name,
        ),
      ),
      _LogConfig(
        logType: EventLogTypes.insemination,
        title: l10n.insemination,
        icon: Icons.favorite,
        color: Colors.redAccent,
        supportsMale: false,
        supportsFemale: true,
        onAdd: (ctx) => _showComingSoon(ctx, l10n.insemination),
        onView: (ctx) => _showComingSoon(ctx, l10n.insemination),
      ),
      _LogConfig(
        logType: EventLogTypes.pregnancy,
        title: l10n.pregnancy,
        icon: Icons.pregnant_woman,
        color: Colors.purple,
        supportsMale: false,
        supportsFemale: true,
        onAdd: (ctx) => _showComingSoon(ctx, l10n.pregnancy),
        onView: (ctx) => _showComingSoon(ctx, l10n.pregnancy),
      ),
      _LogConfig(
        logType: EventLogTypes.deworming,
        title: l10n.deworming,
        icon: Icons.bug_report_outlined,
        color: Colors.teal,
        supportsMale: true,
        supportsFemale: true,
        onAdd: (ctx) => EventFormControl.open(
          context: ctx,
          logType: EventLogTypes.deworming,
          title: l10n.deworming,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          onCompleted: onRefresh,
        ),
        onView: (ctx) => EventsViewControl.openLogs(
          context: ctx,
          logType: EventLogTypes.deworming,
          title: l10n.deworming,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          farmName: farmName,
          livestockName: livestock.name,
        ),
      ),
      _LogConfig(
        logType: EventLogTypes.weightChange,
        title: l10n.weightChange,
        icon: Icons.monitor_weight,
        color: Colors.orange,
        supportsMale: true,
        supportsFemale: true,
        onAdd: (ctx) => EventFormControl.open(
          context: ctx,
          logType: EventLogTypes.weightChange,
          title: l10n.weightChange,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          isBulk: false,
          onCompleted: onRefresh,
        ),
        onView: (ctx) => EventsViewControl.openLogs(
          context: ctx,
          logType: EventLogTypes.weightChange,
          title: l10n.weightChange,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          farmName: farmName,
          livestockName: livestock.name,
        ),
      ),
      _LogConfig(
        logType: EventLogTypes.medication,
        title: l10n.medication,
        icon: Icons.medical_services_outlined,
        color: Colors.purple,
        supportsMale: true,
        supportsFemale: true,
        onAdd: (ctx) => EventFormControl.open(
          context: ctx,
          logType: EventLogTypes.medication,
          title: l10n.medication,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          onCompleted: onRefresh,
        ),
        onView: (ctx) => EventsViewControl.openLogs(
          context: ctx,
          logType: EventLogTypes.medication,
          title: l10n.medication,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          farmName: farmName,
          livestockName: livestock.name,
        ),
      ),
      _LogConfig(
        logType: EventLogTypes.vaccination,
        title: l10n.vaccination,
        icon: Icons.vaccines_outlined,
        color: Colors.lightBlue,
        supportsMale: true,
        supportsFemale: true,
        onAdd: (ctx) => EventFormControl.open(
          context: ctx,
          logType: EventLogTypes.vaccination,
          title: l10n.vaccination,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          onCompleted: onRefresh,
        ),
        onView: (ctx) => EventsViewControl.openLogs(
          context: ctx,
          logType: EventLogTypes.vaccination,
          title: l10n.vaccination,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          farmName: farmName,
          livestockName: livestock.name,
        ),
      ),
      _LogConfig(
        logType: EventLogTypes.disposal,
        title: l10n.disposal,
        icon: Icons.delete_sweep_outlined,
        color: Colors.brown,
        supportsMale: true,
        supportsFemale: true,
        onAdd: (ctx) => EventFormControl.open(
          context: ctx,
          logType: EventLogTypes.disposal,
          title: l10n.disposal,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          onCompleted: onRefresh,
        ),
        onView: (ctx) => EventsViewControl.openLogs(
          context: ctx,
          logType: EventLogTypes.disposal,
          title: l10n.disposal,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          farmName: farmName,
          livestockName: livestock.name,
        ),
      ),
      _LogConfig(
        logType: EventLogTypes.milking,
        title: l10n.milking,
        icon: Icons.water_drop_outlined,
        color: Colors.lightBlueAccent,
        supportsMale: true,
        supportsFemale: true,
        onAdd: (ctx) => _showComingSoon(ctx, l10n.milking),
        onView: (ctx) => _showComingSoon(ctx, l10n.milking),
      ),
      _LogConfig(
        logType: EventLogTypes.calving,
        title: l10n.calving,
        icon: Icons.child_friendly,
        color: Colors.brown,
        supportsMale: false,
        supportsFemale: true,
        onAdd: (ctx) => _showComingSoon(ctx, l10n.calving),
        onView: (ctx) => _showComingSoon(ctx, l10n.calving),
      ),
      _LogConfig(
        logType: EventLogTypes.vaccination,
        title: l10n.vaccination,
        icon: Icons.vaccines,
        color: const Color(0xFF4CAF50),
        supportsMale: true,
        supportsFemale: true,
        onAdd: (ctx) => _showComingSoon(ctx, l10n.vaccination),
        onView: (ctx) => _showComingSoon(ctx, l10n.vaccination),
      ),
      _LogConfig(
        logType: EventLogTypes.dryoff,
        title: l10n.dryoff,
        icon: Icons.opacity_outlined,
        color: Colors.blueGrey,
        supportsMale: false,
        supportsFemale: true,
        onAdd: (ctx) => _showComingSoon(ctx, l10n.dryoff),
        onView: (ctx) => _showComingSoon(ctx, l10n.dryoff),
      ),
      _LogConfig(
        logType: EventLogTypes.medication,
        title: l10n.medication,
        icon: Icons.medical_services,
        color: Colors.indigo,
        supportsMale: true,
        supportsFemale: true,
        onAdd: (ctx) => _showComingSoon(ctx, l10n.medication),
        onView: (ctx) => _showComingSoon(ctx, l10n.medication),
      ),
      _LogConfig(
        logType: EventLogTypes.milking,
        title: l10n.milking,
        icon: Icons.water_drop,
        color: Colors.lightBlue,
        supportsMale: false,
        supportsFemale: true,
        onAdd: (ctx) => _showComingSoon(ctx, l10n.milking),
        onView: (ctx) => _showComingSoon(ctx, l10n.milking),
      ),
    ];
  }

  static Widget _buildLogButton({
    required BuildContext context,
    required _LogConfig config,
    required bool isDark,
    required int count,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.grey[800] : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: config.color.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        onPressed: () => config.onAdd?.call(context),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(config.icon, color: config.color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                config.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: config.color,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // View icon
            GestureDetector(
              onTap: config.onView != null
                  ? () => config.onView!(context)
                  : () => _showComingSoon(context, config.title),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.visibility,
                  size: 18,
                  color: config.color,
                ),
              ),
            ),

            const SizedBox(width: 15),

            // Click to add log
            GestureDetector(
              onTap: config.onAdd != null
                  ? () => config.onAdd!(context)
                  : () => _showComingSoon(context, config.title),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: config.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showDeleteConfirmation(
    BuildContext context,
    Livestock livestock,
    VoidCallback onRefresh,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: Text(
            l10n.deleteLivestock,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            '${l10n.confirmDelete} ${livestock.name}?',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteLivestock(context, livestock, onRefresh);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _deleteLivestock(
    BuildContext context,
    Livestock livestock,
    VoidCallback onRefresh,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      final livestockRepository = LivestockRepository(database);

      // Mark livestock as deleted
      await livestockRepository.markLivestockAsDeleted(livestock.id);

      // Refresh the list
      onRefresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${livestock.name} ${l10n.deletedSuccessfully}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      log('Error deleting livestock: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToDelete} ${livestock.name}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static String _calculateAge(String dateOfBirth) {
    try {
      DateTime birthDate = DateTime.parse(dateOfBirth);
      DateTime now = DateTime.now();
      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;

      if (months < 0) {
        years--;
        months += 12;
      }

      if (years > 0) {
        if (months == 0) {
          return '$years ${years == 1 ? "year" : "years"}';
        }
        return '$years ${years == 1 ? "year" : "years"} $months ${months == 1 ? "month" : "months"}';
      } else if (months > 0) {
        return '$months ${months == 1 ? "month" : "months"}';
      } else {
        return 'Less than a month';
      }
    } catch (e) {
      log('Error calculating age: $e');
      return '--';
    }
  }

  static Future<String> _getSpeciesName(BuildContext context, int speciesId) async {
    try {
      final provider = Provider.of<AdditionalDataProvider>(context, listen: false);
      return await provider.getSpeciesNameById(speciesId);
    } catch (e) {
      log('Error fetching species: $e');
      return '---';
    }
  }

  static Future<String> _getBreedName(BuildContext context, int breedId) async {
    try {
      final provider = Provider.of<AdditionalDataProvider>(context, listen: false);
      return await provider.getBreedNameById(breedId);
    } catch (e) {
      log('Error fetching breed: $e');
      return '---';
    }
  }

  static void _showComingSoon(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title - ${l10n.comingSoon}')),
    );
  }
}

class _LogConfig {
  final String logType;
  final String title;
  final IconData icon;
  final Color color;
  final bool supportsMale;
  final bool supportsFemale;
  final void Function(BuildContext)? onAdd;
  final void Function(BuildContext)? onView;

  const _LogConfig({
    required this.logType,
    required this.title,
    required this.icon,
    required this.color,
    required this.supportsMale,
    required this.supportsFemale,
    this.onAdd,
    this.onView,
  });
}
