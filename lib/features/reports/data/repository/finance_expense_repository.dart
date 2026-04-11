import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/domain/models/finance_expense_model.dart';

class FinanceExpenseRepository {
  final AppDatabase _database;

  FinanceExpenseRepository(this._database);

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<void> rebuildBillExpensesFromLocalBills() async {
    final bills = await _database.billDao.getBills();
    final nowIso = DateTime.now().toIso8601String();
    final companions = <FinanceExpensesCompanion>[];

    for (final bill in bills) {
      final qty = bill.quantity <= 0 ? 1 : bill.quantity;
      final total = double.tryParse(bill.amount) ?? 0;
      final unit = qty > 0 ? total / qty : total;
      companions.add(
        FinanceExpensesCompanion(
          uuid: Value('bill-expense-${bill.uuid}'),
          sourceType: const Value('bill'),
          sourceUuid: Value(bill.uuid),
          farmUuid: bill.farmUuid != null
              ? Value(bill.farmUuid!)
              : const Value.absent(),
          farmerId: bill.farmerId != null
              ? Value(bill.farmerId!)
              : const Value.absent(),
          billNo: bill.billNo != null
              ? Value(bill.billNo!)
              : const Value.absent(),
          subjectType: bill.subjectType != null
              ? Value(bill.subjectType!)
              : const Value.absent(),
          quantity: Value(qty),
          unitCost: Value(unit.toStringAsFixed(2)),
          totalCost: Value(total.toStringAsFixed(2)),
          status: Value(bill.status.toLowerCase()),
          notes: bill.notes != null ? Value(bill.notes!) : const Value.absent(),
          expenseDate: Value(bill.createdAt),
          createdAt: Value(bill.createdAt),
          updatedAt: Value(nowIso),
          synced: const Value(true),
          // Derived from local bill rows (same idea as bills table default server-create)
          syncAction: const Value('server-create'),
        ),
      );
    }

    await _database.financeExpenseDao.clearAndReplaceFromBills(companions);
  }

  /// Merges server-side manual finance expenses into local cache (API uses camelCase).
  ///
  /// Does not overwrite rows the user still has pending to upload ([synced] == false).
  Future<void> mergeFromServer(List<Map<String, dynamic>> raw) async {
    if (raw.isEmpty) return;
    final nowIso = DateTime.now().toIso8601String();
    final companions = <FinanceExpensesCompanion>[];
    for (final row in raw) {
      try {
        final uuid = row['uuid'] as String?;
        if (uuid == null || uuid.isEmpty) continue;

        final sourceType = (row['sourceType'] as String?) ?? 'manual';
        if (sourceType == 'manual') {
          final existing = await _database.financeExpenseDao
              .getFinanceExpenseByUuid(uuid);
          if (existing != null && !existing.synced) continue;
        }

        final sourceUuid = (row['sourceUuid'] as String?) ?? uuid;
        final qty = (row['quantity'] is int)
            ? row['quantity'] as int
            : int.tryParse('${row['quantity'] ?? 1}') ?? 1;

        final unitCost = row['unitCost']?.toString();
        final totalCost = row['totalCost']?.toString();
        if (unitCost == null ||
            unitCost.isEmpty ||
            totalCost == null ||
            totalCost.isEmpty) {
          continue;
        }

        final expenseDateStr = row['expenseDate']?.toString();
        final createdAtStr = row['createdAt']?.toString();
        final updatedAtStr = row['updatedAt']?.toString();

        final farmerIdParsed = _parseOptionalInt(row['farmerId']);

        companions.add(
          FinanceExpensesCompanion(
            uuid: Value(uuid),
            sourceType: Value(sourceType),
            sourceUuid: Value(sourceUuid),
            farmUuid: row['farmUuid'] != null
                ? Value(row['farmUuid'] as String)
                : const Value.absent(),
            farmerId: farmerIdParsed != null
                ? Value(farmerIdParsed)
                : const Value.absent(),
            billNo: row['billNo'] != null
                ? Value(row['billNo'] as String)
                : const Value.absent(),
            subjectType: row['subjectType'] != null
                ? Value(row['subjectType'] as String)
                : const Value.absent(),
            quantity: Value(qty <= 0 ? 1 : qty),
            unitCost: Value(unitCost),
            totalCost: Value(totalCost),
            status: Value(
              (row['status'] as String?)?.toLowerCase() ?? 'pending',
            ),
            notes: row['notes'] != null
                ? Value(row['notes'] as String)
                : const Value.absent(),
            expenseDate: expenseDateStr != null && expenseDateStr.isNotEmpty
                ? Value(expenseDateStr)
                : const Value.absent(),
            createdAt: Value(createdAtStr ?? nowIso),
            updatedAt: Value(updatedAtStr ?? nowIso),
            synced: const Value(true),
            syncAction: const Value('server-create'),
          ),
        );
      } catch (e, st) {
        log('❌ mergeFromServer finance expense row: $e\n$st');
      }
    }
    if (companions.isNotEmpty) {
      await _database.financeExpenseDao.upsertExpenses(companions);
    }
  }

  Future<List<Map<String, dynamic>>> getUnsyncedManualExpensesForApi() async {
    final rows =
        await _database.financeExpenseDao.getUnsyncedManualExpenses();
    return rows
        .map(
          (e) => {
            'uuid': e.uuid,
            'sourceType': e.sourceType,
            'sourceUuid': e.sourceUuid,
            'farmUuid': e.farmUuid,
            'farmerId': e.farmerId,
            'billNo': e.billNo,
            'subjectType': e.subjectType,
            'quantity': e.quantity,
            'unitCost': e.unitCost,
            'totalCost': e.totalCost,
            'status': e.status,
            'notes': e.notes,
            'expenseDate': e.expenseDate,
            'createdAt': e.createdAt,
            'updatedAt': e.updatedAt,
            'synced': e.synced,
            'syncAction': e.syncAction,
          },
        )
        .toList();
  }

  Future<void> markManualExpensesAsSynced(List<String> uuids) async {
    await _database.financeExpenseDao.markManualExpensesSynced(uuids);
  }

  Future<void> insertManualExpense({
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
    final qty = quantity <= 0 ? 1 : quantity;
    final unit = qty > 0 ? totalCost / qty : totalCost;
    final nowIso = DateTime.now().toIso8601String();
    final expenseIso = expenseDate.toIso8601String();
    await _database.financeExpenseDao.upsertExpenses([
      FinanceExpensesCompanion(
        uuid: Value(uuid),
        sourceType: const Value('manual'),
        sourceUuid: Value(uuid),
        farmUuid: Value(farmUuid),
        farmerId: farmerId != null
            ? Value(farmerId)
            : const Value.absent(),
        billNo: const Value.absent(),
        subjectType: Value(subjectType),
        quantity: Value(qty),
        unitCost: Value(unit.toStringAsFixed(2)),
        totalCost: Value(totalCost.toStringAsFixed(2)),
        status: Value(status.toLowerCase()),
        notes: notes != null && notes.isNotEmpty
            ? Value(notes)
            : const Value.absent(),
        expenseDate: Value(expenseIso),
        createdAt: Value(nowIso),
        updatedAt: Value(nowIso),
        synced: const Value(false),
        syncAction: const Value('create'),
      ),
    ]);
  }

  Future<List<FinanceExpenseModel>> getExpenses({
    String? farmUuid,
    int? farmerId,
    DateTimeRange? range,
  }) async {
    final rows = await _database.financeExpenseDao.getAllExpenses(
      farmUuid: farmUuid,
      farmerId: farmerId,
    );

    final filtered = range == null
        ? rows
        : rows.where((row) {
            final dt = DateTime.tryParse(row.expenseDate ?? row.createdAt);
            if (dt == null) return false;
            final start = DateTime(
              range.start.year,
              range.start.month,
              range.start.day,
            );
            final end = DateTime(
              range.end.year,
              range.end.month,
              range.end.day,
              23,
              59,
              59,
            );
            return !dt.isBefore(start) && !dt.isAfter(end);
          }).toList();

    return filtered
        .map(
          (r) => FinanceExpenseModel(
            id: r.id,
            uuid: r.uuid,
            sourceType: r.sourceType,
            sourceUuid: r.sourceUuid,
            farmUuid: r.farmUuid,
            farmerId: r.farmerId,
            billNo: r.billNo,
            subjectType: r.subjectType,
            quantity: r.quantity,
            unitCost: r.unitCost,
            totalCost: r.totalCost,
            status: r.status,
            notes: r.notes,
            expenseDate: r.expenseDate,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }
}
