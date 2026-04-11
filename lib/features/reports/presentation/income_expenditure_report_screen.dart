import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/modern_alerts.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/number_formatter.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/domain/models/finance_expense_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/manual_expense_form_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/provider/finance_expense_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class IncomeExpenditureReportScreen extends StatefulWidget {
  const IncomeExpenditureReportScreen({super.key});

  @override
  State<IncomeExpenditureReportScreen> createState() =>
      _IncomeExpenditureReportScreenState();
}

class _IncomeExpenditureReportScreenState
    extends State<IncomeExpenditureReportScreen> {
  String _formatAmount(double amount) => NumberFormatter.formatCurrency(amount);

  Future<DateTimeRange?> _showStyledDateRangePicker(
    BuildContext context,
    DateTimeRange? initialRange,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? theme.scaffoldBackgroundColor
        : Constants.whiteColor;

    return showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: Constants.primaryColor,
              onPrimary: theme.colorScheme.onPrimary,
              onSurface: theme.colorScheme.onSurface,
              surface: backgroundColor,
              surfaceContainerHighest: backgroundColor,
            ),
            canvasColor: backgroundColor,
            cardColor: backgroundColor,
            scaffoldBackgroundColor: backgroundColor,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: backgroundColor,
              surfaceTintColor: Colors.transparent,
              rangeSelectionBackgroundColor: Constants.primaryColor.withValues(
                alpha: 0.22,
              ),
              rangeSelectionOverlayColor: WidgetStateProperty.all(
                Constants.primaryColor.withValues(alpha: 0.15),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Constants.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<FinanceExpenseProvider>();
      await provider.refresh();
    });
  }

  bool _canAccessReport(AuthProvider auth) {
    if (auth.isFarmer) return true;
    if (!auth.isFarmUser) return false;
    final roleTitle =
        (auth.currentProfile?['roleTitle'] as String?)?.toLowerCase().trim() ??
        '';
    return roleTitle == 'farm-manager' || roleTitle == 'farmer_manager';
  }

  double _sumAmount(List<FinanceExpenseModel> list, {String? status}) {
    return list
        .where(
          (b) =>
              status == null || b.status.toLowerCase() == status.toLowerCase(),
        )
        .fold(0.0, (sum, b) => sum + (double.tryParse(b.totalCost) ?? 0));
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _localizedExpenseStatus(AppLocalizations l10n, String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return l10n.paidStatus;
      case 'pending':
        return l10n.pendingStatus;
      default:
        return status;
    }
  }

  Widget _kpiCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _buildReportPdfBytes(
    List<FinanceExpenseModel> filtered,
    DateTimeRange? range,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    final printableDate = dateFmt.format(DateTime.now());
    final period = range == null
        ? l10n.allTime
        : '${DateFormat('yyyy-MM-dd').format(range.start)} - ${DateFormat('yyyy-MM-dd').format(range.end)}';

    final total = _sumAmount(filtered);
    final paid = _sumAmount(filtered, status: 'paid');
    final pending = _sumAmount(filtered, status: 'pending');
    final pdfBaseFont = await PdfGoogleFonts.notoSansRegular();
    final pdfBoldFont = await PdfGoogleFonts.notoSansBold();

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: pdfBaseFont, bold: pdfBoldFont),
        build: (context) => [
          pw.Text(
            l10n.incomeExpenditureReport,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('${l10n.generatedOn}: $printableDate'),
          pw.Text('${l10n.dateRange}: $period'),
          pw.SizedBox(height: 12),
          pw.Text(l10n.incomeReportExpenseEntriesSectionTitle(filtered.length)),
          pw.Text('${l10n.amount}: ${total.toStringAsFixed(2)}'),
          pw.Text('${l10n.paidStatus}: ${paid.toStringAsFixed(2)}'),
          pw.Text('${l10n.pendingStatus}: ${pending.toStringAsFixed(2)}'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [
              l10n.incomeReportPdfColumnReference,
              l10n.incomeReportPdfColumnDate,
              l10n.incomeReportPdfColumnSubject,
              l10n.incomeReportPdfColumnQuantity,
              l10n.amount,
              l10n.incomeReportPdfColumnStatus,
            ],
            data: filtered.map((b) {
              final dt = DateTime.tryParse(b.expenseDate ?? b.createdAt);
              final ref = b.billNo ??
                  (b.sourceUuid.length >= 8
                      ? b.sourceUuid.substring(0, 8).toUpperCase()
                      : b.sourceUuid);
              return [
                ref,
                dt != null
                    ? DateFormat('yyyy-MM-dd').format(dt)
                    : l10n.reportTableCellPlaceholder,
                b.subjectType ?? l10n.reportTableCellPlaceholder,
                '${b.quantity}',
                b.totalCost,
                _localizedExpenseStatus(l10n, b.status),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<void> _printReport(
    List<FinanceExpenseModel> filtered,
    DateTimeRange? range,
  ) async {
    final bytes = await _buildReportPdfBytes(filtered, range);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _downloadReport(
    List<FinanceExpenseModel> filtered,
    DateTimeRange? range,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await _buildReportPdfBytes(filtered, range);
      final fileName =
          'income_expenditures_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      // iOS sandbox paths are not always visible in Files app.
      // Use the native share sheet so users can "Save to Files" explicitly.
      if (Platform.isIOS) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
        if (!mounted) return;
        ModernAlerts.showSuccessToast(
          context,
          message: l10n.reportDownloaded,
        );
        return;
      }

      Directory? baseDir = await getDownloadsDirectory();
      baseDir ??= await getApplicationDocumentsDirectory();
      baseDir.createSync(recursive: true);

      if (!baseDir.existsSync()) {
        baseDir = await getTemporaryDirectory();
        baseDir.createSync(recursive: true);
      }

      final path = '${baseDir.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      ModernAlerts.showSuccessToast(
        context,
        message: '${l10n.reportDownloaded}: $path',
      );
    } catch (e) {
      if (!mounted) return;
      ModernAlerts.showErrorToast(context, message: '${l10n.error}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final reportProvider = context.watch<FinanceExpenseProvider>();
    final canAccess = _canAccessReport(auth);
    final filtered = reportProvider.expenses;
    final total = _sumAmount(filtered);
    final paid = _sumAmount(filtered, status: 'paid');
    final pending = _sumAmount(filtered, status: 'pending');
    final rangeText = reportProvider.range == null
        ? l10n.allTime
        : '${DateFormat('yyyy-MM-dd').format(reportProvider.range!.start)} - ${DateFormat('yyyy-MM-dd').format(reportProvider.range!.end)}';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          l10n.incomeExpenditureReport,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: canAccess
            ? [
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined),
                  onPressed: () async {
                    final picked = await _showStyledDateRangePicker(
                      context,
                      reportProvider.range,
                    );
                    if (picked == null || !mounted) return;
                    await reportProvider.setRange(picked);
                  },
                ),
                Theme(
                  data: theme.copyWith(
                    popupMenuTheme: PopupMenuThemeData(
                      color: theme.scaffoldBackgroundColor,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    tooltip: l10n.reportActions,
                    onSelected: (value) async {
                      if (value == 'add_expense') {
                        await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const ManualExpenseFormScreen(),
                          ),
                        );
                        if (mounted) {
                          await reportProvider.refresh();
                        }
                        return;
                      }
                      if (filtered.isEmpty) {
                        ModernAlerts.showErrorToast(
                          context,
                          message: l10n.noRecordsFoundForSelectedPeriod,
                        );
                        return;
                      }
                      if (value == 'print') {
                        await _printReport(filtered, reportProvider.range);
                      } else if (value == 'download') {
                        await _downloadReport(filtered, reportProvider.range);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'add_expense',
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 20,
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.addManualExpense,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'print',
                        child: Row(
                          children: [
                            Icon(
                              Icons.print_outlined,
                              size: 20,
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.printReport,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(
                              Icons.download_outlined,
                              size: 20,
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.downloadReport,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: !canAccess
          ? Center(child: Text(l10n.accessDeniedFarmerOrFarmManagerOnly))
          : reportProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
          ? RefreshIndicator(
              onRefresh: () => reportProvider.refresh(),
              backgroundColor: theme.scaffoldBackgroundColor,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 56,
                    color: theme.colorScheme.primary.withValues(alpha: 0.45),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRecordsFoundForSelectedPeriod,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const ManualExpenseFormScreen(),
                          ),
                        );
                        if (mounted) {
                          await reportProvider.refresh();
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(l10n.addManualExpense),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => reportProvider.refresh(),
              backgroundColor: theme.scaffoldBackgroundColor,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.35)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.22,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Constants.primaryColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.date_range_rounded,
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
                                l10n.dateRange,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.68,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                rangeText,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _kpiCard(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.amount,
                    value: _formatAmount(total),
                    color: Constants.primaryColor,
                  ),
                  const SizedBox(height: 10),
                  _kpiCard(
                    context: context,
                    icon: Icons.check_circle_outline,
                    title: l10n.paidStatus,
                    value: _formatAmount(paid),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  _kpiCard(
                    context: context,
                    icon: Icons.pending_actions_outlined,
                    title: l10n.pendingStatus,
                    value: _formatAmount(pending),
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.incomeReportExpenseEntriesSectionTitle(filtered.length),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...filtered.map((b) {
                    final amount = double.tryParse(b.totalCost) ?? 0;
                    final eventDate = DateTime.tryParse(
                      b.expenseDate ?? b.createdAt,
                    );
                    final statusColor = _statusColor(context, b.status);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.35)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  b.billNo ??
                                      b.sourceUuid
                                          .substring(0, 8)
                                          .toUpperCase(),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                _formatAmount(amount),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Constants.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (eventDate != null)
                                Text(
                                  DateFormat('yyyy-MM-dd').format(eventDate),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                              if (eventDate != null) const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  _localizedExpenseStatus(l10n, b.status),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b.subjectType ?? l10n.reportTableCellPlaceholder,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
