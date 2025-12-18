import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/database/daos/bill_dao.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/data/tables/bill_table.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/domain/models/bill_model.dart';

class BillsRepository {
  final AppDatabase _database;
  late final BillDao _dao;

  BillsRepository(this._database) {
    _dao = _database.billDao;
  }

  // Store server bills locally (UPSERT + prune server-created if missing)
  Future<void> syncBills(List<Map<String, dynamic>> bills) async {
    if (bills.isEmpty) {
      log('🧾 No bills provided for sync');
      return;
    }

    final companions = <BillsCompanion>[];
    final remoteUuids = <String>{};

    for (final raw in bills) {
      try {
        final model = _mapServerJsonToModel(raw);
        remoteUuids.add(model.uuid);
        companions.add(_modelToCompanion(model));
      } catch (e, stackTrace) {
        log('❌ Error syncing bill entry: $e\n$stackTrace');
      }
    }

    if (companions.isEmpty) {
      log('⚠️ No valid bills to sync after processing payload');
      return;
    }

    await _dao.upsertBills(companions);
    await _dao.deleteServerBillsNotIn(remoteUuids);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedBillsForApi() async {
    final unsynced = await _dao.getUnsyncedBills();
    return unsynced.map((entity) {
      return {
        'uuid': entity.uuid,
        'billNo': entity.billNo,
        'farmUuid': entity.farmUuid,
        'extensionOfficerId': entity.extensionOfficerId,
        'farmerId': entity.farmerId,
        'subjectType': entity.subjectType,
        'subjectUuid': entity.subjectUuid,
        'quantity': entity.quantity,
        'amount': entity.amount,
        'status': entity.status,
        'notes': entity.notes,
        'synced': entity.synced,
        'syncAction': entity.syncAction,
        'createdAt': entity.createdAt,
        'updatedAt': entity.updatedAt,
      };
    }).toList();
  }

  Future<void> markBillsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;

    for (final uuid in uuids.toSet()) {
      final existing = await _dao.getBillByUuid(uuid);
      if (existing == null) {
        log('⚠️ Bill not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _dao.deleteBillByUuid(uuid);
        log('🗑️ Removed bill after synced delete: $uuid');
      } else {
        final model = _mapEntityToModel(existing).copyWith(
          synced: true,
        );
        await _dao.upsertBills([_modelToCompanion(model)]);
        log('✅ Marked bill as synced: $uuid');
      }
    }
  }

  Future<BillModel> createBill(BillModel model) async {
    final prepared = _prepareForLocalWrite(model, isCreate: true);
    await _dao.upsertBills([_modelToCompanion(prepared)]);
    log('💾 Bill created locally: ${prepared.uuid}');
    return prepared;
  }

  Future<BillModel> updateBill(BillModel model) async {
    final prepared = _prepareForLocalWrite(model, isCreate: false);
    await _dao.upsertBills([_modelToCompanion(prepared)]);
    log('💾 Bill updated locally: ${prepared.uuid}');
    return prepared;
  }

  Future<List<BillModel>> getBills({int? extensionOfficerId}) async {
    final entities = await _dao.getBills();
    final models = entities.map(_mapEntityToModel).toList();
    if (extensionOfficerId != null) {
      return models
          .where((b) => (b.extensionOfficerId ?? -1) == extensionOfficerId)
          .toList();
    }
    return models;
  }

  // ===================== Mappers =====================

  BillsCompanion _modelToCompanion(BillModel model) {
    return BillsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      billNo: model.billNo != null ? Value(model.billNo!) : const Value.absent(),
      farmUuid: model.farmUuid != null ? Value(model.farmUuid!) : const Value.absent(),
      extensionOfficerId: model.extensionOfficerId != null ? Value(model.extensionOfficerId!) : const Value.absent(),
      farmerId: model.farmerId != null ? Value(model.farmerId!) : const Value.absent(),
      subjectType: model.subjectType != null ? Value(model.subjectType!) : const Value.absent(),
      subjectUuid: model.subjectUuid != null ? Value(model.subjectUuid!) : const Value.absent(),
      quantity: Value(model.quantity),
      amount: Value(model.amount),
      status: model.status != null ? Value(model.status!) : const Value.absent(),
      notes: model.notes != null ? Value(model.notes!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  BillModel _mapServerJsonToModel(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    final nowIso = DateTime.now().toIso8601String();

    final uuid = sanitized['uuid'] as String?;
    if (uuid == null || uuid.trim().isEmpty) {
      throw StateError('Bill sync entry missing uuid');
    }

    sanitized['uuid'] = uuid;
    sanitized['amount'] = (sanitized['amount'] ?? '').toString();
    sanitized['synced'] = true;
    sanitized['syncAction'] = 'server-create';
    sanitized['createdAt'] =
        sanitized['createdAt'] != null ? sanitized['createdAt'].toString() : nowIso;
    sanitized['updatedAt'] = sanitized['updatedAt'] != null
        ? sanitized['updatedAt'].toString()
        : sanitized['createdAt'];

    return BillModel.fromJson(sanitized);
  }

  BillModel _mapEntityToModel(Bill entity) {
    return BillModel(
      id: entity.id,
      uuid: entity.uuid,
      billNo: entity.billNo,
      farmUuid: entity.farmUuid,
      extensionOfficerId: entity.extensionOfficerId,
      farmerId: entity.farmerId,
      subjectType: entity.subjectType,
      subjectUuid: entity.subjectUuid,
      quantity: entity.quantity,
      amount: entity.amount,
      status: entity.status,
      notes: entity.notes,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  BillModel _prepareForLocalWrite(
    BillModel model, {
    required bool isCreate,
  }) {
    final nowIso = DateTime.now().toIso8601String();
    final createdAt = model.createdAt.isNotEmpty ? model.createdAt : nowIso;
    final syncAction = isCreate
        ? 'create'
        : (model.syncAction == 'create' ? 'create' : 'update');

    return model.copyWith(
      synced: false,
      syncAction: syncAction,
      createdAt: createdAt,
      updatedAt: nowIso,
    );
  }
}
