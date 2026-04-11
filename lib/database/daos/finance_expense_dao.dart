import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/data/tables/finance_expense_table.dart';

part 'finance_expense_dao.g.dart';

@DriftAccessor(tables: [FinanceExpenses])
class FinanceExpenseDao extends DatabaseAccessor<AppDatabase>
    with _$FinanceExpenseDaoMixin {
  FinanceExpenseDao(AppDatabase db) : super(db);

  Future<void> upsertExpenses(List<FinanceExpensesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch(
      (batch) => batch.insertAllOnConflictUpdate(financeExpenses, entries),
    );
  }

  Future<List<FinanceExpense>> getAllExpenses({
    String? farmUuid,
    int? farmerId,
  }) {
    final query = select(financeExpenses);
    if (farmUuid != null && farmUuid.isNotEmpty) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (farmerId != null) {
      query.where((tbl) => tbl.farmerId.equals(farmerId));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<void> clearAndReplaceFromBills(
    List<FinanceExpensesCompanion> entries,
  ) async {
    await transaction(() async {
      await (delete(
        financeExpenses,
      )..where((tbl) => tbl.sourceType.equals('bill'))).go();
      if (entries.isNotEmpty) {
        await upsertExpenses(entries);
      }
    });
  }

  /// Manual expenses pending upload: same pattern as bills/logs ([create], [update], [deleted]).
  Future<List<FinanceExpense>> getUnsyncedManualExpenses() {
    return (select(financeExpenses)
          ..where(
            (tbl) =>
                tbl.sourceType.equals('manual') &
                tbl.synced.equals(false) &
                (tbl.syncAction.equals('create') |
                    tbl.syncAction.equals('update') |
                    tbl.syncAction.equals('deleted')),
          ))
        .get();
  }

  Future<FinanceExpense?> getFinanceExpenseByUuid(String uuid) {
    return (select(financeExpenses)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<int> deleteFinanceExpenseByUuid(String uuid) {
    return (delete(financeExpenses)..where((t) => t.uuid.equals(uuid))).go();
  }

  Future<void> markManualExpensesSynced(Iterable<String> uuids) async {
    for (final uuid in uuids.toSet()) {
      final row = await getFinanceExpenseByUuid(uuid);
      if (row == null) continue;
      if (row.syncAction == 'deleted') {
        await deleteFinanceExpenseByUuid(uuid);
        continue;
      }
      await (update(financeExpenses)..where((t) => t.uuid.equals(uuid))).write(
        FinanceExpensesCompanion(
          synced: const Value(true),
          syncAction: const Value('server-create'),
        ),
      );
    }
  }
}
