import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/modern_alerts.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/data/repository/finance_income_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/domain/models/finance_income_model.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class FinanceIncomeProvider extends ChangeNotifier {
  final FinanceIncomeRepository _repository;

  FinanceIncomeProvider({required FinanceIncomeRepository repository})
    : _repository = repository;

  bool _loading = false;
  bool get loading => _loading;

  DateTimeRange? _range;
  DateTimeRange? get range => _range;

  List<FinanceIncomeModel> _incomes = const [];
  List<FinanceIncomeModel> get incomes => _incomes;

  Future<void> refresh({String? farmUuid, int? farmerId}) async {
    _loading = true;
    notifyListeners();
    _incomes = await _repository.getIncomes(
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

  Future<bool> addManualIncomeWithDialog(
    BuildContext context, {
    required String uuid,
    required String farmUuid,
    int? farmerId,
    String? sourceType,
    String? sourceUuid,
    String? referenceNo,
    required String subjectType,
    required double totalAmount,
    int quantity = 1,
    String status = 'received',
    String? notes,
    required DateTime incomeDate,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    ModernAlerts.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      await _repository.insertManualIncome(
        uuid: uuid,
        farmUuid: farmUuid,
        farmerId: farmerId,
        sourceType: sourceType,
        sourceUuid: sourceUuid,
        referenceNo: referenceNo,
        subjectType: subjectType,
        totalAmount: totalAmount,
        quantity: quantity,
        status: status,
        notes: notes,
        incomeDate: incomeDate,
      );
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      await refresh(farmUuid: farmUuid, farmerId: farmerId);
      if (context.mounted) {
        await ModernAlerts.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.incomeSaved,
          buttonText: l10n.ok,
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        ModernAlerts.showErrorToast(context, message: '${l10n.error}: $e');
      }
      return false;
    }
  }

  Future<void> upsertDisposalIncome(DisposalModel disposal) async {
    await _repository.upsertDisposalIncomeFromDisposal(disposal);
    await refresh();
  }

  Future<void> upsertDisposalIncomes(List<DisposalModel> disposals) async {
    await _repository.upsertDisposalIncomesFromDisposals(disposals);
    await refresh();
  }
}
