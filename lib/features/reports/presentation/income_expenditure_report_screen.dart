import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/modern_alerts.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/number_formatter.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/domain/models/finance_expense_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/domain/models/finance_income_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/manual_expense_form_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/manual_income_form_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/provider/finance_expense_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/provider/finance_income_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
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
  static const MethodChannel _downloadsChannel = MethodChannel(
    'reports/downloads',
  );
  _LedgerFilter _ledgerFilter = _LedgerFilter.all;

  String _formatAmount(double amount) => NumberFormatter.formatCurrency(amount);

  Future<void> _refreshReportData({DateTimeRange? range}) async {
    final financeProvider = context.read<FinanceExpenseProvider>();
    final incomeProvider = context.read<FinanceIncomeProvider>();
    final selectedRange = range ?? financeProvider.range;

    if (range != null) {
      await Future.wait([
        financeProvider.setRange(range),
        incomeProvider.setRange(range),
      ]);
      return;
    }

    await Future.wait([
      financeProvider.refresh(),
      incomeProvider.setRange(selectedRange),
    ]);
  }

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
      await _refreshReportData();
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

  String _localizedIncomeStatus(AppLocalizations l10n, String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return l10n.receivedStatus;
      case 'pending':
        return l10n.pendingStatus;
      default:
        return status;
    }
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _shortReference(String? value) {
    final normalized = (value ?? '').trim();
    if (normalized.isEmpty) return '—';
    if (normalized.length <= 8) return normalized.toUpperCase();
    return normalized.substring(0, 8).toUpperCase();
  }

  List<_LedgerEntry> _filterLedgerEntries(
    List<_LedgerEntry> entries,
    _LedgerFilter filter,
  ) {
    switch (filter) {
      case _LedgerFilter.all:
        return entries;
      case _LedgerFilter.income:
        return entries
            .where((entry) => entry.kind == _LedgerEntryKind.income)
            .toList();
      case _LedgerFilter.expense:
        return entries
            .where((entry) => entry.kind == _LedgerEntryKind.expenditure)
            .toList();
    }
  }

  List<_LedgerEntry> _buildIncomeEntries(
    List<FinanceIncomeModel> incomes,
    AppLocalizations l10n,
  ) {
    return incomes.map((d) {
      final date = _parseDate(d.incomeDate ?? d.createdAt);
      final subject = [
        if ((d.subjectType ?? '').trim().isNotEmpty) d.subjectType!.trim(),
        if ((d.referenceNo ?? '').trim().isNotEmpty) d.referenceNo!.trim(),
      ].join(' • ');

      return _LedgerEntry(
        kind: _LedgerEntryKind.income,
        reference: (d.referenceNo?.trim().isNotEmpty ?? false)
            ? d.referenceNo!.trim()
            : _shortReference(d.sourceUuid ?? d.uuid),
        date: date,
        subject: subject.isEmpty ? l10n.reportTableCellPlaceholder : subject,
        quantity: d.quantity,
        amount: double.tryParse(d.totalAmount) ?? 0,
        status: _localizedIncomeStatus(l10n, d.status),
      );
    }).toList()..sort((a, b) {
      final left = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
  }

  List<_LedgerEntry> _buildExpenditureEntries(
    List<FinanceExpenseModel> expenses,
    AppLocalizations l10n,
  ) {
    return expenses.map((b) {
      final date = _parseDate(b.expenseDate ?? b.createdAt);
      final reference = b.billNo?.trim().isNotEmpty == true
          ? b.billNo!.trim()
          : _shortReference(b.sourceUuid);

      return _LedgerEntry(
        kind: _LedgerEntryKind.expenditure,
        reference: reference,
        date: date,
        subject: b.subjectType?.trim().isNotEmpty == true
            ? b.subjectType!.trim()
            : l10n.reportTableCellPlaceholder,
        quantity: b.quantity,
        amount: double.tryParse(b.totalCost) ?? 0,
        status: _localizedExpenseStatus(l10n, b.status),
      );
    }).toList()..sort((a, b) {
      final left = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
  }

  double _sumLedgerAmount(List<_LedgerEntry> entries) {
    return entries.fold<double>(0, (sum, entry) => sum + entry.amount);
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

  Widget _filterPill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = selected
        ? Constants.primaryColor
        : (isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white);
    final foregroundColor = selected
        ? Colors.white
        : theme.colorScheme.onSurface;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: backgroundColor,
      selectedColor: Constants.primaryColor,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: foregroundColor,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected
            ? Constants.primaryColor
            : theme.colorScheme.outline.withValues(alpha: 0.22),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _ledgerEntryCard({
    required BuildContext context,
    required _LedgerEntry entry,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isIncome = entry.kind == _LedgerEntryKind.income;
    final accentColor = isIncome ? Colors.green : Colors.orange;
    final borderColor = accentColor.withValues(alpha: 0.2);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isIncome ? Icons.trending_up : Icons.trending_down,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.reference,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _formatAmount(entry.amount),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (entry.date != null) ...[
            Text(
              DateFormat('yyyy-MM-dd').format(entry.date!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            entry.subject,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  isIncome
                      ? l10n.incomeReportIncomeLabel
                      : l10n.incomeReportExpenditureLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  entry.status,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _buildReportPdfBytes(
    List<_LedgerEntry> incomeEntries,
    List<_LedgerEntry> expenditureEntries,
    DateTimeRange? range,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    final printableDate = dateFmt.format(DateTime.now());
    final period = range == null
        ? l10n.allTime
        : '${DateFormat('yyyy-MM-dd').format(range.start)} - ${DateFormat('yyyy-MM-dd').format(range.end)}';

    final totalIncome = _sumLedgerAmount(incomeEntries);
    final totalExpenditure = _sumLedgerAmount(expenditureEntries);
    final netBalance = totalIncome - totalExpenditure;
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
          pw.Text(
            '${l10n.incomeReportTotalIncome}: ${totalIncome.toStringAsFixed(2)}',
          ),
          pw.Text(
            '${l10n.incomeReportTotalExpenditure}: ${totalExpenditure.toStringAsFixed(2)}',
          ),
          pw.Text(
            '${l10n.incomeReportNetBalance}: ${netBalance.toStringAsFixed(2)}',
          ),
          pw.SizedBox(height: 16),
          if (incomeEntries.isNotEmpty) ...[
            pw.Text(
              l10n.incomeReportIncomeEntriesSectionTitle(incomeEntries.length),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: [
                l10n.incomeReportPdfColumnReference,
                l10n.incomeReportPdfColumnDate,
                l10n.incomeReportPdfColumnSubject,
                l10n.incomeReportPdfColumnQuantity,
                l10n.amount,
                l10n.incomeReportPdfColumnStatus,
              ],
              data: incomeEntries.map((entry) {
                return [
                  entry.reference,
                  entry.date != null
                      ? DateFormat('yyyy-MM-dd').format(entry.date!)
                      : l10n.reportTableCellPlaceholder,
                  entry.subject,
                  '${entry.quantity}',
                  entry.amount.toStringAsFixed(2),
                  entry.status,
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 16),
          ],
          if (expenditureEntries.isNotEmpty) ...[
            pw.Text(
              l10n.incomeReportExpenseEntriesSectionTitle(
                expenditureEntries.length,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: [
                l10n.incomeReportPdfColumnReference,
                l10n.incomeReportPdfColumnDate,
                l10n.incomeReportPdfColumnSubject,
                l10n.incomeReportPdfColumnQuantity,
                l10n.amount,
                l10n.incomeReportPdfColumnStatus,
              ],
              data: expenditureEntries.map((entry) {
                return [
                  entry.reference,
                  entry.date != null
                      ? DateFormat('yyyy-MM-dd').format(entry.date!)
                      : l10n.reportTableCellPlaceholder,
                  entry.subject,
                  '${entry.quantity}',
                  entry.amount.toStringAsFixed(2),
                  entry.status,
                ];
              }).toList(),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  Future<void> _printReport(
    List<_LedgerEntry> incomeEntries,
    List<_LedgerEntry> expenditureEntries,
    DateTimeRange? range,
  ) async {
    final bytes = await _buildReportPdfBytes(
      incomeEntries,
      expenditureEntries,
      range,
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _downloadReport(
    List<_LedgerEntry> incomeEntries,
    List<_LedgerEntry> expenditureEntries,
    DateTimeRange? range,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await _buildReportPdfBytes(
        incomeEntries,
        expenditureEntries,
        range,
      );
      final fileName =
          'income_expenditures_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      // iOS sandbox paths are not always visible in Files app.
      // Use the native share sheet so users can "Save to Files" explicitly.
      if (Platform.isIOS) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
        if (!mounted) return;
        ModernAlerts.showSuccessToast(context, message: l10n.reportDownloaded);
        return;
      }

      if (Platform.isAndroid) {
        await _downloadReportToAndroidDownloads(bytes, fileName, l10n);
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

  Future<void> _downloadReportToAndroidDownloads(
    Uint8List bytes,
    String fileName,
    AppLocalizations l10n,
  ) async {
    final requiresPermission = await _downloadsChannel.invokeMethod<bool>(
      'requiresLegacyStoragePermission',
    );

    if (requiresPermission == true) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (!mounted) return;
        ModernAlerts.showErrorToast(
          context,
          message: '${l10n.error}: Storage permission denied.',
        );
        return;
      }
    }

    final savedPath = await _downloadsChannel.invokeMethod<String>(
      'savePdfToDownloads',
      {'fileName': fileName, 'bytes': bytes},
    );

    if (!mounted) return;
    ModernAlerts.showSuccessToast(
      context,
      message: savedPath == null || savedPath.isEmpty
          ? l10n.reportDownloaded
          : '${l10n.reportDownloaded}: $savedPath',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final reportProvider = context.watch<FinanceExpenseProvider>();
    final incomeProvider = context.watch<FinanceIncomeProvider>();
    final canAccess = _canAccessReport(auth);
    final allExpenditureEntries = _buildExpenditureEntries(
      reportProvider.expenses,
      l10n,
    );
    final allIncomeEntries = _buildIncomeEntries(incomeProvider.incomes, l10n);
    final expenditureEntries = _filterLedgerEntries(
      allExpenditureEntries,
      _ledgerFilter,
    );
    final incomeEntries = _filterLedgerEntries(allIncomeEntries, _ledgerFilter);
    final totalIncome = _sumLedgerAmount(allIncomeEntries);
    final totalExpenditure = _sumLedgerAmount(allExpenditureEntries);
    final netBalance = totalIncome - totalExpenditure;
    final hasRecords =
        allIncomeEntries.isNotEmpty || allExpenditureEntries.isNotEmpty;
    final hasFilteredRecords =
        incomeEntries.isNotEmpty || expenditureEntries.isNotEmpty;
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
                    await _refreshReportData(range: picked);
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
                          await _refreshReportData();
                        }
                        return;
                      }
                      if (value == 'add_income') {
                        await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const ManualIncomeFormScreen(),
                          ),
                        );
                        if (mounted) {
                          await _refreshReportData();
                        }
                        return;
                      }
                      if (!hasRecords) {
                        ModernAlerts.showErrorToast(
                          context,
                          message: l10n.noRecordsFoundForSelectedPeriod,
                        );
                        return;
                      }
                      if (value == 'print') {
                        await _printReport(
                          incomeEntries,
                          expenditureEntries,
                          reportProvider.range,
                        );
                      } else if (value == 'download') {
                        await _downloadReport(
                          incomeEntries,
                          expenditureEntries,
                          reportProvider.range,
                        );
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
                        value: 'add_income',
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 20,
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.addManualIncome,
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
          : (reportProvider.loading || incomeProvider.loading)
          ? const Center(child: CircularProgressIndicator())
          : !hasRecords
          ? RefreshIndicator(
              onRefresh: _refreshReportData,
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
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
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
                              await _refreshReportData();
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: Text(l10n.addManualExpense),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => const ManualIncomeFormScreen(),
                              ),
                            );
                            if (mounted) {
                              await _refreshReportData();
                            }
                          },
                          icon: const Icon(Icons.trending_up),
                          label: Text(l10n.addManualIncome),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshReportData,
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _kpiCard(
                          context: context,
                          icon: Icons.trending_up,
                          title: l10n.incomeReportTotalIncome,
                          value: _formatAmount(totalIncome),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _kpiCard(
                          context: context,
                          icon: Icons.trending_down,
                          title: l10n.incomeReportTotalExpenditure,
                          value: _formatAmount(totalExpenditure),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _kpiCard(
                    context: context,
                    icon: netBalance >= 0
                        ? Icons.account_balance_wallet_outlined
                        : Icons.warning_amber_outlined,
                    title: l10n.incomeReportNetBalance,
                    value: _formatAmount(netBalance),
                    color: netBalance >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _filterPill(
                        label: l10n.incomeReportFilterAll,
                        selected: _ledgerFilter == _LedgerFilter.all,
                        onTap: () =>
                            setState(() => _ledgerFilter = _LedgerFilter.all),
                      ),
                      _filterPill(
                        label: l10n.incomeReportFilterIncome,
                        selected: _ledgerFilter == _LedgerFilter.income,
                        onTap: () => setState(
                          () => _ledgerFilter = _LedgerFilter.income,
                        ),
                      ),
                      _filterPill(
                        label: l10n.incomeReportFilterExpense,
                        selected: _ledgerFilter == _LedgerFilter.expense,
                        onTap: () => setState(
                          () => _ledgerFilter = _LedgerFilter.expense,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (!hasFilteredRecords)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: Text(
                          l10n.noRecordsFoundForSelectedPeriod,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    if (incomeEntries.isNotEmpty) ...[
                      Text(
                        l10n.incomeReportIncomeEntriesSectionTitle(
                          incomeEntries.length,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...incomeEntries.map(
                        (entry) =>
                            _ledgerEntryCard(context: context, entry: entry),
                      ),
                    ],
                    if (expenditureEntries.isNotEmpty) ...[
                      if (incomeEntries.isNotEmpty) const SizedBox(height: 8),
                      Text(
                        l10n.incomeReportExpenseEntriesSectionTitle(
                          expenditureEntries.length,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...expenditureEntries.map(
                        (entry) =>
                            _ledgerEntryCard(context: context, entry: entry),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}

enum _LedgerEntryKind { income, expenditure }

enum _LedgerFilter { all, income, expense }

class _LedgerEntry {
  final _LedgerEntryKind kind;
  final String reference;
  final DateTime? date;
  final String subject;
  final int quantity;
  final double amount;
  final String status;

  const _LedgerEntry({
    required this.kind,
    required this.reference,
    required this.date,
    required this.subject,
    required this.quantity,
    required this.amount,
    required this.status,
  });
}
