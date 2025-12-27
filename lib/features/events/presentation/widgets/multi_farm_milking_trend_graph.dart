import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/milking_model.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';

class MultiFarmMilkingTrendGraph extends StatefulWidget {
  final List<MilkingModel> milkingLogs;
  final Map<String, String> farmNamesMap;

  const MultiFarmMilkingTrendGraph({
    super.key,
    required this.milkingLogs,
    required this.farmNamesMap,
  });

  @override
  State<MultiFarmMilkingTrendGraph> createState() => _MultiFarmMilkingTrendGraphState();
}

class _MultiFarmMilkingTrendGraphState extends State<MultiFarmMilkingTrendGraph> {
  String _selectedPeriod = '6months'; // '6months' or 'year'
  String? _touchedFarmUuid;

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

  Map<String, Map<String, double>> _aggregateDataByFarmAndPeriod(String period) {
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
    final allMonths = <String>[];
    for (int i = 0; i < monthCount; i++) {
      final monthDate = DateTime(startDate.year, startDate.month + i, 1);
      final monthKey = DateFormat('MMM yyyy').format(monthDate);
      allMonths.add(monthKey);
    }

    // Map: farmUuid -> Map: month -> total litres
    final Map<String, Map<String, double>> farmData = {};

    // Initialize all farms with all months set to 0
    final farmUuidsSet = widget.milkingLogs
        .map((m) => m.farmUuid ?? 'unknown')
        .toSet();
    final farmUuids = farmUuidsSet.toList();
    
    for (final farmUuid in farmUuids) {
      farmData[farmUuid] = {};
      for (final month in allMonths) {
        farmData[farmUuid]![month] = 0.0;
      }
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
      final farmUuid = milking.farmUuid ?? 'unknown';
      final monthKey = DateFormat('MMM yyyy').format(logMonthStart);

      // Ensure farm exists (should already be initialized above, but handle edge case)
      farmData.putIfAbsent(farmUuid, () {
        final map = <String, double>{};
        for (final month in allMonths) {
          map[month] = 0.0;
        }
        return map;
      });
      
      if (farmData[farmUuid]!.containsKey(monthKey)) {
        farmData[farmUuid]![monthKey] = farmData[farmUuid]![monthKey]! + amount;
      }
    }

    // Ensure all farms have data for all months (already done above, but ensure sorted)
    for (final farmUuid in farmData.keys) {
      final sortedFarmData = <String, double>{};
      for (final month in allMonths) {
        sortedFarmData[month] = farmData[farmUuid]![month] ?? 0.0;
      }
      farmData[farmUuid] = sortedFarmData;
    }

    return farmData;
  }

  List<Color> _getFarmColors(int farmCount) {
    final colors = <Color>[
      primaryColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    
    // Repeat colors if more farms than available colors
    final result = <Color>[];
    for (int i = 0; i < farmCount; i++) {
      result.add(colors[i % colors.length]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final farmData = _aggregateDataByFarmAndPeriod(_selectedPeriod);
    final farmUuids = farmData.keys.toList();
    
    if (farmData.isEmpty || farmUuids.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.show_chart,
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

    final firstFarmData = farmData[farmUuids.first]!;
    final months = firstFarmData.keys.toList();
    
    // Calculate max value across all farms
    double maxValue = 0;
    for (final farm in farmData.values) {
      for (final value in farm.values) {
        if (value > maxValue) maxValue = value;
      }
    }
    maxValue = maxValue * 1.2; // Add 20% padding

    final farmColors = _getFarmColors(farmUuids.length);

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
                      l10n.milkingTrendByFarm,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${farmUuids.length} ${l10n.farms.toLowerCase()}',
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
                          _touchedFarmUuid = null;
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
            height: 350,
            child: LineChart(
              LineChartData(
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
                        if (index >= 0 && index < months.length) {
                          final date = DateFormat('MMM yyyy').parse(months[index]);
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
                          return const SizedBox.shrink();
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
                lineBarsData: farmUuids.asMap().entries.map((entry) {
                  final farmIndex = entry.key;
                  final farmUuid = entry.value;
                  final farmMonthData = farmData[farmUuid]!;
                  final isTouched = _touchedFarmUuid == farmUuid;
                  final color = farmColors[farmIndex];

                  return LineChartBarData(
                    spots: months.asMap().entries.map((monthEntry) {
                      final monthIndex = monthEntry.key;
                      final month = monthEntry.value;
                      final value = farmMonthData[month] ?? 0.0;
                      return FlSpot(monthIndex.toDouble(), value);
                    }).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: isTouched ? 4 : 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: isTouched,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: isDark ? Colors.grey[900]! : Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: false,
                    ),
                  );
                }).toList(),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) {
                      return isDark ? Colors.grey[800]! : Colors.grey[200]!;
                    },
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final farmUuid = farmUuids[spot.barIndex];
                        final farmName = widget.farmNamesMap[farmUuid] ?? 'Unknown Farm';
                        final value = spot.y;
                        final monthIndex = spot.x.toInt();
                        final month = monthIndex >= 0 && monthIndex < months.length
                            ? months[monthIndex]
                            : '';

                        return LineTooltipItem(
                          '$farmName\n${value.toStringAsFixed(1)} L',
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
                      }).toList();
                    },
                  ),
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (!event.isInterestedForInteractions ||
                        touchResponse == null ||
                        touchResponse.lineBarSpots == null ||
                        touchResponse.lineBarSpots!.isEmpty) {
                      setState(() {
                        _touchedFarmUuid = null;
                      });
                      return;
                    }

                    final spot = touchResponse.lineBarSpots!.first;
                    setState(() {
                      _touchedFarmUuid = farmUuids[spot.barIndex];
                    });
                  },
                ),
                minX: 0,
                maxX: (months.length - 1).toDouble(),
                minY: 0,
                maxY: maxValue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              children: farmUuids.asMap().entries.map((entry) {
                final farmIndex = entry.key;
                final farmUuid = entry.value;
                final farmName = widget.farmNamesMap[farmUuid] ?? 'Unknown Farm';
                final color = farmColors[farmIndex];
                final isSelected = _touchedFarmUuid == farmUuid;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _touchedFarmUuid = _touchedFarmUuid == farmUuid ? null : farmUuid;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? color : color.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 3,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          farmName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

