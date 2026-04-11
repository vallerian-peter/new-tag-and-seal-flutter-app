import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/modern_alerts.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/data/repository/finance_expense_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/domain/models/finance_expense_model.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class FinanceExpenseProvider extends ChangeNotifier {
  final FinanceExpenseRepository _repository;

  FinanceExpenseProvider({required FinanceExpenseRepository repository})
    : _repository = repository;

  bool _loading = false;
  bool get loading => _loading;

  DateTimeRange? _range;
  DateTimeRange? get range => _range;

  List<FinanceExpenseModel> _expenses = const [];
  List<FinanceExpenseModel> get expenses => _expenses;

  Future<void> refresh({String? farmUuid, int? farmerId}) async {
    _loading = true;
    notifyListeners();
    await _repository.rebuildBillExpensesFromLocalBills();
    _expenses = await _repository.getExpenses(
      farmUuid: farmUuid,
      farmerId: farmerId,
      range: _range,
    );
    _loading = false;
    notifyListeners();
  }

  Future<void> setRange(
    DateTimeRange? range, {
    String? farmUuid,
    int? farmerId,
  }) async {
    _range = range;
    await refresh(farmUuid: farmUuid, farmerId: farmerId);
  }

  /// Save a manual expense locally (loading/success/error via [ModernAlerts]).
  Future<bool> addManualExpenseWithDialog(
    BuildContext context, {
    required String uuid,
    required String farmUuid,
    int? farmerId,
    required String subjectType,
    required double totalCost,
    int quantity = 1,
    String status = 'paid',
    String? notes,
    required DateTime expenseDate,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    ModernAlerts.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      await _repository.insertManualExpense(
        uuid: uuid,
        farmUuid: farmUuid,
        farmerId: farmerId,
        subjectType: subjectType,
        totalCost: totalCost,
        quantity: quantity,
        status: status,
        notes: notes,
        expenseDate: expenseDate,
      );
      await refresh();

      if (context.mounted) {
        Navigator.of(context).pop();
        await ModernAlerts.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.manualExpenseSavedSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        await ModernAlerts.showError(
          context: context,
          title: l10n.error,
          message: l10n.manualExpenseSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return false;
    }
  }
}
