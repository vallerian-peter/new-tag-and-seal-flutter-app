import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/data/tables/finance_income_table.dart';

part 'finance_income_dao.g.dart';

@DriftAccessor(tables: [FinanceIncomes])
class FinanceIncomeDao extends DatabaseAccessor<AppDatabase>
    with _$FinanceIncomeDaoMixin {
  FinanceIncomeDao(super.db);

  Future<void> upsertIncomes(List<FinanceIncomesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch(
      (batch) => batch.insertAllOnConflictUpdate(financeIncomes, entries),
    );
  }

  Future<List<FinanceIncome>> getAllIncomes({String? farmUuid, int? farmerId}) {
    final query = select(financeIncomes);
    if (farmUuid != null && farmUuid.isNotEmpty) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (farmerId != null) {
      query.where((tbl) => tbl.farmerId.equals(farmerId));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<FinanceIncome>> getUnsyncedIncomes() {
    return (select(financeIncomes)..where(
          (tbl) =>
              tbl.synced.equals(false) &
              (tbl.syncAction.equals('create') |
                  tbl.syncAction.equals('update') |
                  tbl.syncAction.equals('deleted')),
        ))
        .get();
  }

  Future<FinanceIncome?> getFinanceIncomeByUuid(String uuid) {
    return (select(
      financeIncomes,
    )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<int> deleteFinanceIncomeByUuid(String uuid) {
    return (delete(financeIncomes)..where((t) => t.uuid.equals(uuid))).go();
  }

  Future<void> markIncomesAsSynced(Iterable<String> uuids) async {
    for (final uuid in uuids.toSet()) {
      final row = await getFinanceIncomeByUuid(uuid);
      if (row == null) continue;
      if (row.syncAction == 'deleted') {
        await deleteFinanceIncomeByUuid(uuid);
        continue;
      }
      await (update(financeIncomes)..where((t) => t.uuid.equals(uuid))).write(
        const FinanceIncomesCompanion(
          synced: Value(true),
          syncAction: Value('server-create'),
        ),
      );
    }
  }

  Future<void> markDisposalIncomeAsDeleted(String sourceUuid) async {
    final row =
        await (select(financeIncomes)..where(
              (t) =>
                  t.sourceType.equals('disposal') &
                  t.sourceUuid.equals(sourceUuid),
            ))
            .getSingleOrNull();
    if (row == null) return;

    await (update(financeIncomes)..where((t) => t.uuid.equals(row.uuid))).write(
      const FinanceIncomesCompanion(
        synced: Value(false),
        syncAction: Value('deleted'),
      ),
    );
  }
}
