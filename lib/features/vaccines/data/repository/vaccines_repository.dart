import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/database/daos/vaccine_dao.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/domain/models/vaccine_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/domain/repo/vaccine_repo.dart';

class VaccinesRepository implements VaccineRepositoryInterface {
  final AppDatabase _database;
  late final VaccineDao _dao;

  VaccinesRepository(this._database) {
    _dao = _database.vaccineDao;
  }

  @override
  Future<void> syncVaccines(List<Map<String, dynamic>> vaccines) async {
    if (vaccines.isEmpty) {
      log('💉 No vaccines provided for sync');
      return;
    }

    final companions = <VaccinesCompanion>[];
    final remoteUuids = <String>{};

    for (final raw in vaccines) {
      try {
        final model = _mapServerJsonToModel(raw);
        remoteUuids.add(model.uuid);
        companions.add(_modelToCompanion(model));
      } catch (e, stackTrace) {
        log('❌ Error syncing vaccine entry: $e\n$stackTrace');
      }
    }

    if (companions.isEmpty) {
      log('⚠️ No valid vaccines to sync after processing payload');
      return;
    }

    await _dao.upsertVaccines(companions);
    await _dao.deleteServerVaccinesNotIn(remoteUuids);
  }

  @override
  Future<List<VaccineModel>> getVaccines({String? farmUuid}) async {
    final entities = await _dao.getVaccines(farmUuid: farmUuid);
    return entities.map(_mapEntityToModel).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedVaccinesForApi() async {
    final unsynced = await _dao.getUnsyncedVaccines();
    return unsynced.map((entity) {
      return {
        'uuid': entity.uuid,
        'farmUuid': entity.farmUuid,
        'name': entity.name,
        'lot': entity.lot,
        'formulationType': entity.formulationType,
        'dose': entity.dose,
        'status': entity.status,
        'vaccineTypeId': entity.vaccineTypeId,
        'vaccineSchedule': entity.vaccineSchedule,
        'synced': entity.synced,
        'syncAction': entity.syncAction,
        'createdAt': entity.createdAt,
        'updatedAt': entity.updatedAt,
      };
    }).toList();
  }

  @override
  Future<void> markVaccinesAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;

    for (final uuid in uuids.toSet()) {
      final existing = await _dao.getVaccineByUuid(uuid);
      if (existing == null) {
        log('⚠️ Vaccine not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _dao.deleteVaccineByUuid(uuid);
        log('🗑️ Removed vaccine after synced delete: $uuid');
      } else {
        final model = _mapEntityToModel(existing).copyWith(
          synced: true,
        );
        await _dao.upsertVaccines([_modelToCompanion(model)]);
        log('✅ Marked vaccine as synced: $uuid');
      }
    }
  }

  @override
  Future<VaccineModel?> getVaccineByUuid(String uuid) async {
    final entity = await _dao.getVaccineByUuid(uuid);
    return entity != null ? _mapEntityToModel(entity) : null;
  }

  @override
  Future<VaccineModel> createVaccine(VaccineModel model) async {
    final nowIso = DateTime.now().toIso8601String();
    final sanitized = model.copyWith(
      synced: false,
      syncAction: 'create',
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : nowIso,
      updatedAt: nowIso,
    );

    await _dao.upsertVaccines([_modelToCompanion(sanitized)]);
    final inserted = await _dao.getVaccineByUuid(sanitized.uuid);
    if (inserted == null) {
      throw StateError('Failed to insert vaccine ${sanitized.uuid}');
    }
    log('💾 Created vaccine locally: ${sanitized.uuid} (farm=${sanitized.farmUuid})');
    return _mapEntityToModel(inserted);
  }

  @override
  Future<VaccineModel> updateVaccine(VaccineModel model) async {
    final nowIso = DateTime.now().toIso8601String();
    final nextSyncAction =
        model.syncAction == 'create' || model.syncAction == 'update'
            ? model.syncAction
            : 'update';

    final sanitized = model.copyWith(
      synced: false,
      syncAction: nextSyncAction,
      updatedAt: nowIso,
    );

    await _dao.upsertVaccines([_modelToCompanion(sanitized)]);
    final updated = await _dao.getVaccineByUuid(sanitized.uuid);
    if (updated == null) {
      throw StateError('Failed to update vaccine ${sanitized.uuid}');
    }
    log('📝 Updated vaccine locally: ${sanitized.uuid} (syncAction=${sanitized.syncAction})');
    return _mapEntityToModel(updated);
  }

  VaccinesCompanion _modelToCompanion(VaccineModel model) {
    return VaccinesCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: model.farmUuid != null ? Value(model.farmUuid!) : const Value.absent(),
      name: Value(model.name),
      lot: model.lot != null ? Value(model.lot!) : const Value.absent(),
      formulationType: model.formulationType != null ? Value(model.formulationType!) : const Value.absent(),
      dose: model.dose != null ? Value(model.dose!) : const Value.absent(),
      status: model.status != null ? Value(model.status!) : const Value.absent(),
      vaccineTypeId: model.vaccineTypeId != null ? Value(model.vaccineTypeId!) : const Value.absent(),
      vaccineSchedule: model.vaccineSchedule != null ? Value(model.vaccineSchedule!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  VaccineModel _mapServerJsonToModel(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    final nowIso = DateTime.now().toIso8601String();

    final uuid = sanitized['uuid'] as String?;
    if (uuid == null || uuid.trim().isEmpty) {
      throw StateError('Vaccine sync entry missing uuid');
    }

    sanitized['uuid'] = uuid;
    sanitized['name'] = (sanitized['name'] as String?)?.trim().isNotEmpty == true
        ? (sanitized['name'] as String).trim()
        : 'Unnamed Vaccine';
    sanitized['synced'] = true;
    sanitized['syncAction'] = 'server-create';
    sanitized['createdAt'] =
        sanitized['createdAt'] != null ? sanitized['createdAt'].toString() : nowIso;
    sanitized['updatedAt'] = sanitized['updatedAt'] != null
        ? sanitized['updatedAt'].toString()
        : sanitized['createdAt'];

    return VaccineModel.fromJson(sanitized);
  }

  VaccineModel _mapEntityToModel(Vaccine entity) {
    return VaccineModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      name: entity.name,
      lot: entity.lot,
      formulationType: entity.formulationType,
      dose: entity.dose,
      status: entity.status,
      vaccineTypeId: entity.vaccineTypeId,
      vaccineSchedule: entity.vaccineSchedule,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

