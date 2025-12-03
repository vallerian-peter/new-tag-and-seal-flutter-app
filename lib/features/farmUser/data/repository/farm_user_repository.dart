import 'dart:convert';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/database/daos/farm_user_dao.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/domain/models/farm_user_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/domain/repo/farm_user_repo.dart';

class FarmUserRepository implements FarmUserRepositoryInterface {
  final AppDatabase _database;
  late final FarmUserDao _dao;

  FarmUserRepository(this._database) {
    _dao = _database.farmUserDao;
  }

  @override
  Future<void> syncFarmUsers(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) {
      log('👥 No farm users provided for sync');
      return;
    }

    final companions = <FarmUsersCompanion>[];
    final remoteUuids = <String>{};

    for (final raw in items) {
      try {
        final model = _mapServerJsonToModel(raw);
        remoteUuids.add(model.uuid);
        companions.add(_modelToCompanion(model));
      } catch (e, stackTrace) {
        log('❌ Error syncing farm user entry: $e\n$stackTrace');
      }
    }

    if (companions.isEmpty) {
      log('⚠️ No valid farm users to sync after processing payload');
      return;
    }

    await _dao.upsertFarmUsers(companions);
    await _dao.deleteServerFarmUsersNotIn(remoteUuids);
  }

  @override
  Future<List<FarmUserModel>> getFarmUsers({String? farmUuid}) async {
    final entities = await _dao.getFarmUsers(farmUuid: farmUuid);
    return entities.map(_mapEntityToModel).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedFarmUsersForApi() async {
    final unsynced = await _dao.getUnsyncedFarmUsers();
    return unsynced.map((entity) {
      // Parse JSON string from database to array
      final farmUuids = _parseFarmUuidsFromJson(entity.farmUuid);
      
      return {
        'uuid': entity.uuid,
        'farmUuid': farmUuids.isNotEmpty ? farmUuids[0] : '', // Legacy support
        'farmUuids': farmUuids, // New format: array
        'firstName': entity.firstName,
        'middleName': entity.middleName,
        'lastName': entity.lastName,
        'phone': entity.phone,
        'email': entity.email,
        'roleTitle': entity.roleTitle,
        'gender': entity.gender,
        'synced': entity.synced,
        'syncAction': entity.syncAction,
        'createdAt': entity.createdAt,
        'updatedAt': entity.updatedAt,
      };
    }).toList();
  }

  @override
  Future<void> markFarmUsersAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;

    for (final uuid in uuids.toSet()) {
      final existing = await _dao.getFarmUserByUuid(uuid);
      if (existing == null) {
        log('⚠️ Farm user not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _dao.deleteFarmUserByUuid(uuid);
        log('🗑️ Removed farm user after synced delete: $uuid');
      } else {
        final model = _mapEntityToModel(existing).copyWith(
          synced: true,
        );
        await _dao.upsertFarmUsers([_modelToCompanion(model)]);
        log('✅ Marked farm user as synced: $uuid');
      }
    }
  }

  @override
  Future<FarmUserModel> createFarmUser(FarmUserModel model) async {
    final prepared = _prepareForLocalWrite(model, isCreate: true);
    await _dao.upsertFarmUsers([_modelToCompanion(prepared)]);
    log('💾 Farm user created locally: ${prepared.uuid}');
    return prepared;
  }

  @override
  Future<FarmUserModel> updateFarmUser(FarmUserModel model) async {
    final prepared = _prepareForLocalWrite(model, isCreate: false);
    await _dao.upsertFarmUsers([_modelToCompanion(prepared)]);
    log('💾 Farm user updated locally: ${prepared.uuid}');
    return prepared;
  }

  @override
  Future<bool> markFarmUserAsDeleted(String uuid) async {
    final existing = await _dao.getFarmUserByUuid(uuid);
    if (existing == null) {
      log('⚠️ Farm user not found when marking as deleted: $uuid');
      return false;
    }

    final nowIso = DateTime.now().toIso8601String();
    final model = _mapEntityToModel(existing).copyWith(
      synced: false,
      syncAction: 'deleted',
      updatedAt: nowIso,
    );
    await _dao.upsertFarmUsers([_modelToCompanion(model)]);
    log('🗑️ Marked farm user as deleted (pending sync): $uuid');
    return true;
  }

  FarmUserModel _prepareForLocalWrite(
    FarmUserModel model, {
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

  FarmUsersCompanion _modelToCompanion(FarmUserModel model) {
    // Convert farmUuids array to JSON string for storage
    final farmUuidJson = _encodeFarmUuidsToJson(model.farmUuids);
    
    return FarmUsersCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: Value(farmUuidJson), // Store as JSON string
      firstName: Value(model.firstName),
      middleName:
          model.middleName != null ? Value(model.middleName!) : const Value.absent(),
      lastName: Value(model.lastName),
      phone: model.phone != null ? Value(model.phone!) : const Value.absent(),
      email: Value(model.email),
      roleTitle: Value(model.roleTitle),
      gender: Value(model.gender),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  FarmUserModel _mapServerJsonToModel(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    final nowIso = DateTime.now().toIso8601String();

    final uuid = sanitized['uuid'] as String?;
    if (uuid == null || uuid.trim().isEmpty) {
      throw StateError('FarmUser sync entry missing uuid');
    }

    sanitized['uuid'] = uuid;
    sanitized['firstName'] =
        (sanitized['firstName'] as String?)?.trim().isNotEmpty == true
            ? (sanitized['firstName'] as String).trim()
            : 'User';
    sanitized['synced'] = true;
    sanitized['syncAction'] = 'server-create';
    sanitized['createdAt'] =
        sanitized['createdAt'] != null ? sanitized['createdAt'].toString() : nowIso;
    sanitized['updatedAt'] = sanitized['updatedAt'] != null
        ? sanitized['updatedAt'].toString()
        : sanitized['createdAt'];

    return FarmUserModel.fromJson(sanitized);
  }

  FarmUserModel _mapEntityToModel(FarmUser entity) {
    // Parse JSON string from database to array
    final farmUuids = _parseFarmUuidsFromJson(entity.farmUuid);
    
    return FarmUserModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuids: farmUuids,
      firstName: entity.firstName,
      middleName: entity.middleName,
      lastName: entity.lastName,
      phone: entity.phone,
      email: entity.email,
      roleTitle: entity.roleTitle,
      gender: entity.gender,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts farmUuids array to JSON string for database storage
  String _encodeFarmUuidsToJson(List<String> farmUuids) {
    if (farmUuids.isEmpty) {
      return '';
    }
    
    if (farmUuids.length == 1) {
      // Store as single string if only one UUID (backward compatible)
      return farmUuids[0];
    }
    
    // Store as JSON array string if multiple UUIDs
    return jsonEncode(farmUuids);
  }

  /// Parses JSON string from database to farmUuids array
  List<String> _parseFarmUuidsFromJson(String farmUuidJson) {
    if (farmUuidJson.isEmpty) {
      return [];
    }

    try {
      // Try to parse as JSON array
      final decoded = jsonDecode(farmUuidJson);
      if (decoded is List) {
        return List<String>.from(decoded).where((u) => u.isNotEmpty).toList();
      }
    } catch (e) {
      // Not valid JSON, treat as single UUID string (legacy format)
      return [farmUuidJson];
    }

    // If parsing failed, treat as single UUID string
    return [farmUuidJson];
  }
}


