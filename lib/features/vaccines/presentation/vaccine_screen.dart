import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/domain/models/vaccine_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/presentation/provider/vaccine_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, String> _farmNames = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initialize();
      }
    });
  }

  Future<void> _initialize({bool forceReload = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final vaccineProvider = context.read<VaccineProvider>();
      final database = context.read<AppDatabase>();

      if (forceReload || vaccineProvider.vaccines.isEmpty) {
        await vaccineProvider.loadVaccines();
      }

      final farms = await database.farmDao.getAllActiveFarms();
      final farmNameMap = <String, String>{
        for (final farm in farms) farm.uuid: farm.name,
      };

      if (!mounted) return;
      setState(() {
        _farmNames = farmNameMap;
        _isLoading = false;
      });

      log('📋 VaccineScreen initialized: vaccines=${vaccineProvider.vaccines.length}, farms=${farmNameMap.length}');
    } catch (e, stackTrace) {
      log('❌ Failed to initialize VaccineScreen: $e', stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _onRefresh() async {
    await _initialize(forceReload: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final vaccineProvider = context.watch<VaccineProvider>();

    final isBusy = _isLoading || vaccineProvider.isLoading;
    final vaccines = vaccineProvider.vaccines;

    if (isBusy) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.vaccinesText)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.vaccinesText)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.vaccineSaveFailed,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _onRefresh,
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vaccinesText),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: l10n.retry,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: vaccines.isEmpty
            ? ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    child: Center(
                      child: Text(
                        l10n.noData,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vaccines.length,
                itemBuilder: (context, index) {
                  final vaccine = vaccines[index];
                  final farmName = vaccine.farmUuid != null
                      ? _farmNames[vaccine.farmUuid!]
                      : null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VaccineCard(
                      vaccine: vaccine,
                      farmName: farmName,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _VaccineCard extends StatelessWidget {
  final VaccineModel vaccine;
  final String? farmName;

  const _VaccineCard({
    required this.vaccine,
    required this.farmName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
        : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.3);

    final createdAt = DateTime.tryParse(vaccine.createdAt);
    final updatedAt = DateTime.tryParse(vaccine.updatedAt);
    final dateFormat = DateFormat.yMMMd().add_jm();

    final rows = <_DetailRow>[
      _DetailRow(label: l10n.farm, value: farmName ?? l10n.unknownFarm),
      if (vaccine.lot != null && vaccine.lot!.trim().isNotEmpty)
        _DetailRow(label: l10n.lotNumber, value: vaccine.lot!.trim()),
      if (vaccine.formulationType != null &&
          vaccine.formulationType!.trim().isNotEmpty)
        _DetailRow(
          label: l10n.formulationType,
          value: vaccine.formulationType!.trim(),
        ),
      if (vaccine.dose != null && vaccine.dose!.trim().isNotEmpty)
        _DetailRow(label: l10n.doseAmount, value: vaccine.dose!.trim()),
      if (vaccine.vaccineSchedule != null &&
          vaccine.vaccineSchedule!.trim().isNotEmpty)
        _DetailRow(
          label: l10n.vaccineSchedule,
          value: _formatSchedule(vaccine.vaccineSchedule!, l10n),
        ),
      if (updatedAt != null)
        _DetailRow(
          label: l10n.updatedAt,
          value: dateFormat.format(updatedAt.toLocal()),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.vaccines_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccine.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatStatus(vaccine.status, l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        row.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        row.value,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),
          if (createdAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.createdAt,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(createdAt.toLocal()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatSchedule(String schedule, AppLocalizations l10n) {
    switch (schedule.toLowerCase()) {
      case 'regular':
        return l10n.vaccineScheduleRegular;
      case 'booster':
        return l10n.vaccineScheduleBooster;
      case 'seasonal':
        return l10n.vaccineScheduleSeasonal;
      case 'emergency':
        return l10n.vaccineScheduleEmergency;
      default:
        return schedule;
    }
  }

  String _formatStatus(String? status, AppLocalizations l10n) {
    switch ((status ?? '').toLowerCase()) {
      case 'active':
        return l10n.active;
      case 'inactive':
        return l10n.notActive;
      case 'expired':
        return l10n.serviceUnavailable;
      default:
        return status ?? '--';
    }
  }
}

class _DetailRow {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});
}
