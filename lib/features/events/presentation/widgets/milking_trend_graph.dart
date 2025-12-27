import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/milking_model.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';

class MilkingTrendGraph extends StatefulWidget {
  final List<MilkingModel> milkingLogs;
  final String livestockName;

  const MilkingTrendGraph({
    super.key,
    required this.milkingLogs,
    required this.livestockName,
  });

  @override
  State<MilkingTrendGraph> createState() => _MilkingTrendGraphState();
}

class _MilkingTrendGraphState extends State<MilkingTrendGraph> {
  String _selectedPeriod = '6months'; // '6months' or 'year'
  int? _touchedIndex;

  double _parseAmountToLitres(String rawAmount) {
    if (rawAmount.trim().isEmpty) return 0;

    final normalized = rawAmount.trim().toLowerCase();
    final match =
        RegExp(r'^([0-9]*\.?[0-9]+)\s*([a-zA-Z]*)').firstMatch(normalized);
    if (match == null) {
      return double.tryParse(normalized) ?? 0;
    }

    final numericPart = double.tryParse(match.group(1) ?? '') ?? 0;
    final unit = (match.group(2) ?? '').trim();

    if (unit == 'ml') {
      return numericPart / 1000.0;
    }

    return numericPart;
  }

  /// Gets the effective date for a milking log (eventDate ?? createdAt)
  DateTime? _getEffectiveDate(MilkingModel milking) {
    if (milking.eventDate != null && milking.eventDate!.trim().isNotEmpty) {
      return DateTime.tryParse(milking.eventDate!);
    }
    return DateTime.tryParse(milking.createdAt);
  }

  Map<String, double> _aggregateDataByPeriod(String period) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    DateTime startDate;
    int monthCount;

    if (period == '6months') {
      // Current month + 5 months back = 6 months total (including current)
      startDate = DateTime(now.year, now.month - 5, 1);
      monthCount = 6;
    } else {
      // Year: 12 months including current month (current month + 11 months back)
      startDate = DateTime(now.year, now.month - 11, 1);
      monthCount = 12;
    }

    // Generate all months in the range first
    final Map<String, double> aggregated = {};
    for (int i = 0; i < monthCount; i++) {
      final monthDate = DateTime(startDate.year, startDate.month + i, 1);
      final monthKey = DateFormat('MMM yyyy').format(monthDate);
      aggregated[monthKey] = 0.0;
    }

    // Aggregate data from milking logs
    for (final milking in widget.milkingLogs) {
      final effectiveDate = _getEffectiveDate(milking);
      if (effectiveDate == null) continue;

      // Check if within range (from startDate to current month end)
      final logMonthStart = DateTime(effectiveDate.year, effectiveDate.month, 1);
      if (logMonthStart.isBefore(startDate) || logMonthStart.isAfter(currentMonthStart)) {
        continue;
      }

      final amount = _parseAmountToLitres(milking.amount);
      final monthKey = DateFormat('MMM yyyy').format(logMonthStart);
      
      if (aggregated.containsKey(monthKey)) {
        aggregated[monthKey] = aggregated[monthKey]! + amount;
      }
    }

    // Sort by date
    final sortedKeys = aggregated.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMM yyyy').parse(a);
        final dateB = DateFormat('MMM yyyy').parse(b);
        return dateA.compareTo(dateB);
      });

    final sortedMap = <String, double>{};
    for (final key in sortedKeys) {
      sortedMap[key] = aggregated[key]!;
    }

    return sortedMap;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final aggregatedData = _aggregateDataByPeriod(_selectedPeriod);
    final labels = aggregatedData.keys.toList();
    final values = aggregatedData.values.toList();

    if (aggregatedData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 64,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noData,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxValue = values.isNotEmpty
        ? values.reduce((a, b) => a > b ? a : b) * 1.2
        : 10.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handler
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header with title and period selector
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.milkingTrend,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.livestockName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Period dropdown
              Theme(
                data: theme.copyWith(
                  dropdownMenuTheme: DropdownMenuThemeData(
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(theme.scaffoldBackgroundColor),
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    underline: const SizedBox(),
                    dropdownColor: theme.scaffoldBackgroundColor,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onSurface,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: '6months',
                        child: Text(l10n.last6Months),
                      ),
                      DropdownMenuItem(
                        value: 'year',
                        child: Text(l10n.lastYear),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPeriod = value;
                          _touchedIndex = null;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) {
                      return isDark ? Colors.grey[800]! : Colors.grey[200]!;
                    },
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = labels[groupIndex];
                      final value = rod.toY;
                      return BarTooltipItem(
                        '${value.toStringAsFixed(1)} L',
                        TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                            TextSpan(
                              text: '\n$month',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        _touchedIndex = null;
                        return;
                      }
                      _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          // Show abbreviated month names
                          final date = DateFormat('MMM yyyy').parse(labels[index]);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('MMM').format(date),
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) {
                          return const Text('');
                        }
                        return Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                    left: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: labels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final isTouched = index == _touchedIndex;
                  final barValue = values[index];

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: barValue,
                        color: isTouched
                            ? primaryColor.withOpacity(0.8)
                            : primaryColor,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Summary stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  l10n.total,
                  values.fold<double>(0, (sum, val) => sum + val)
                      .toStringAsFixed(1),
                  'L',
                ),
                _buildStatItem(
                  context,
                  l10n.average,
                  values.isNotEmpty
                      ? (values.fold<double>(0, (sum, val) => sum + val) /
                              values.length)
                          .toStringAsFixed(1)
                      : '0.0',
                  'L',
                ),
                _buildStatItem(
                  context,
                  l10n.maximum,
                  values.isNotEmpty
                      ? values.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)
                      : '0.0',
                  'L',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    String unit,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

