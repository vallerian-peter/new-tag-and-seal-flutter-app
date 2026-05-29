import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/domain/models/finance_income_model.dart';

class FinanceIncomeRepository {
  final AppDatabase _database;

  FinanceIncomeRepository(this._database);

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<void> insertManualIncome({
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
    final qty = quantity <= 0 ? 1 : quantity;
    final unit = qty > 0 ? totalAmount / qty : totalAmount;
    final nowIso = DateTime.now().toIso8601String();
    final incomeIso = incomeDate.toIso8601String();
    await _database.financeIncomeDao.upsertIncomes([
      FinanceIncomesCompanion(
        uuid: Value(uuid),
        sourceType: sourceType != null && sourceType.isNotEmpty
            ? Value(sourceType)
            : const Value.absent(),
        sourceUuid: sourceUuid != null && sourceUuid.isNotEmpty
            ? Value(sourceUuid)
            : const Value.absent(),
        farmUuid: Value(farmUuid),
        farmerId: farmerId != null ? Value(farmerId) : const Value.absent(),
        referenceNo: referenceNo != null && referenceNo.isNotEmpty
            ? Value(referenceNo)
            : const Value.absent(),
        subjectType: Value(subjectType),
        quantity: Value(qty),
        unitAmount: Value(unit.toStringAsFixed(2)),
        totalAmount: Value(totalAmount.toStringAsFixed(2)),
        status: Value(status.toLowerCase()),
        notes: notes != null && notes.isNotEmpty
            ? Value(notes)
            : const Value.absent(),
        incomeDate: Value(incomeIso),
        createdAt: Value(nowIso),
        updatedAt: Value(nowIso),
        synced: const Value(false),
        syncAction: const Value('create'),
      ),
    ]);
  }

  Future<void> upsertDisposalIncomeFromDisposal(DisposalModel disposal) async {
    final salePrice = disposal.salePrice ?? 0;
    final existing = await _database.financeIncomeDao.getFinanceIncomeByUuid(
      disposal.uuid,
    );

    if (salePrice <= 0) {
      await _database.financeIncomeDao.deleteFinanceIncomeByUuid(disposal.uuid);
      return;
    }

    final nowIso = DateTime.now().toIso8601String();
    final farm = await _database.farmDao.getFarmByUuid(disposal.farmUuid);
    final farmerId = farm?.farmerId;
    final syncAction = existing == null
        ? 'create'
        : (existing.syncAction == 'create' ? 'create' : 'update');
    await _database.financeIncomeDao.upsertIncomes([
      FinanceIncomesCompanion(
        uuid: Value(disposal.uuid),
        sourceType: const Value('disposal'),
        sourceUuid: Value(disposal.uuid),
        farmUuid: Value(disposal.farmUuid),
        farmerId: farmerId != null ? Value(farmerId) : const Value.absent(),
        referenceNo:
            disposal.buyerName != null && disposal.buyerName!.isNotEmpty
            ? Value(disposal.buyerName!)
            : const Value.absent(),
        subjectType: Value(disposal.reasons),
        quantity: const Value(1),
        unitAmount: Value(salePrice.toStringAsFixed(2)),
        totalAmount: Value(salePrice.toStringAsFixed(2)),
        status: const Value('received'),
        notes: disposal.remarks != null && disposal.remarks!.isNotEmpty
            ? Value(disposal.remarks!)
            : const Value.absent(),
        incomeDate: Value(disposal.eventDate ?? disposal.createdAt),
        createdAt: Value(existing?.createdAt ?? nowIso),
        updatedAt: Value(nowIso),
        synced: const Value(false),
        syncAction: Value(syncAction),
      ),
    ]);
  }

  Future<void> upsertDisposalIncomesFromDisposals(
    List<DisposalModel> disposals,
  ) async {
    if (disposals.isEmpty) return;
    for (final disposal in disposals) {
      await upsertDisposalIncomeFromDisposal(disposal);
    }
  }

  Future<void> mergeFromServer(List<Map<String, dynamic>> raw) async {
    if (raw.isEmpty) return;
    final nowIso = DateTime.now().toIso8601String();
    final companions = <FinanceIncomesCompanion>[];

    for (final row in raw) {
      try {
        final uuid = row['uuid'] as String?;
        if (uuid == null || uuid.isEmpty) continue;

        final sourceType = row['sourceType']?.toString();
        final existing = await _database.financeIncomeDao
            .getFinanceIncomeByUuid(uuid);
        if (existing != null && !existing.synced) continue;

        final sourceUuid = row['sourceUuid']?.toString();
        final qty = (row['quantity'] is int)
            ? row['quantity'] as int
            : int.tryParse('${row['quantity'] ?? 1}') ?? 1;
        final unitAmount = row['unitAmount']?.toString();
        final totalAmount = row['totalAmount']?.toString();
        if (unitAmount == null ||
            unitAmount.isEmpty ||
            totalAmount == null ||
            totalAmount.isEmpty) {
          continue;
        }

        final incomeDateStr = row['incomeDate']?.toString();
        final createdAtStr = row['createdAt']?.toString();
        final updatedAtStr = row['updatedAt']?.toString();

        final farmerIdParsed = _parseOptionalInt(row['farmerId']);

        companions.add(
          FinanceIncomesCompanion(
            uuid: Value(uuid),
            sourceType: sourceType != null && sourceType.isNotEmpty
                ? Value(sourceType)
                : const Value.absent(),
            sourceUuid: sourceUuid != null && sourceUuid.isNotEmpty
                ? Value(sourceUuid)
                : const Value.absent(),
            farmUuid: row['farmUuid'] != null
                ? Value(row['farmUuid'] as String)
                : const Value.absent(),
            farmerId: farmerIdParsed != null
                ? Value(farmerIdParsed)
                : const Value.absent(),
            referenceNo: row['referenceNo'] != null
                ? Value(row['referenceNo'] as String)
                : const Value.absent(),
            subjectType: row['subjectType'] != null
                ? Value(row['subjectType'] as String)
                : const Value.absent(),
            quantity: Value(qty <= 0 ? 1 : qty),
            unitAmount: Value(unitAmount),
            totalAmount: Value(totalAmount),
            status: Value(
              (row['status'] as String?)?.toLowerCase() ?? 'received',
            ),
            notes: row['notes'] != null
                ? Value(row['notes'] as String)
                : const Value.absent(),
            incomeDate: incomeDateStr != null && incomeDateStr.isNotEmpty
                ? Value(incomeDateStr)
                : const Value.absent(),
            createdAt: Value(createdAtStr ?? nowIso),
            updatedAt: Value(updatedAtStr ?? nowIso),
            synced: const Value(true),
            syncAction: const Value('server-create'),
          ),
        );
      } catch (e, st) {
        log('❌ mergeFromServer finance income row: $e\n$st');
      }
    }

    if (companions.isNotEmpty) {
      await _database.financeIncomeDao.upsertIncomes(companions);
    }
  }

  Future<List<Map<String, dynamic>>> getUnsyncedIncomesForApi() async {
    final rows = await _database.financeIncomeDao.getUnsyncedIncomes();
    return rows
        .map(
          (e) => {
            'uuid': e.uuid,
            'sourceType': e.sourceType,
            'sourceUuid': e.sourceUuid,
            'farmUuid': e.farmUuid,
            'farmerId': e.farmerId,
            'referenceNo': e.referenceNo,
            'subjectType': e.subjectType,
            'quantity': e.quantity,
            'unitAmount': e.unitAmount,
            'totalAmount': e.totalAmount,
            'status': e.status,
            'notes': e.notes,
            'incomeDate': e.incomeDate,
            'createdAt': e.createdAt,
            'updatedAt': e.updatedAt,
            'synced': e.synced,
            'syncAction': e.syncAction,
          },
        )
        .toList();
  }

  Future<void> markIncomesAsSynced(List<String> uuids) async {
    await _database.financeIncomeDao.markIncomesAsSynced(uuids);
  }

  Future<List<FinanceIncomeModel>> getIncomes({
    String? farmUuid,
    int? farmerId,
    DateTimeRange? range,
  }) async {
    final rows = await _database.financeIncomeDao.getAllIncomes(
      farmUuid: farmUuid,
      farmerId: farmerId,
    );

    final filtered = range == null
        ? rows
        : rows.where((row) {
            final dt = DateTime.tryParse(row.incomeDate ?? row.createdAt);
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
          (r) => FinanceIncomeModel(
            id: r.id,
            uuid: r.uuid,
            sourceType: r.sourceType,
            sourceUuid: r.sourceUuid,
            farmUuid: r.farmUuid,
            farmerId: r.farmerId,
            referenceNo: r.referenceNo,
            subjectType: r.subjectType,
            quantity: r.quantity,
            unitAmount: r.unitAmount,
            totalAmount: r.totalAmount,
            status: r.status,
            notes: r.notes,
            incomeDate: r.incomeDate,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
            synced: r.synced,
            syncAction: r.syncAction,
          ),
        )
        .toList();
  }
}
