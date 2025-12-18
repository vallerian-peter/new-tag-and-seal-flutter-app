import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/data/dao/extension_officer_dao.dart';
import 'dart:developer';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/data/remote/extension_officer_service.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/models/extension_officer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/models/extension_officer_invite_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/repo/extension_officer_repo.dart';

// Imports removed (duplicates)

class ExtensionOfficerRepository
    implements ExtensionOfficerRepositoryInterface {
  final AppDatabase _database;
  late final ExtensionOfficerDao _dao;

  ExtensionOfficerRepository(this._database) {
    _dao = _database.extensionOfficerDao;
  }

  @override
  Future<ExtensionOfficerModel?> searchByEmail(String email) async {
    try {
      final data = await ExtensionOfficerService.searchByEmail(email);
      if (data == null) return null;
      return ExtensionOfficerModel.fromJson(data);
    } catch (e, stackTrace) {
      log(
        '❌ Error searching extension officer: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<ExtensionOfficerInviteModel> createInvite(
    String extensionOfficerEmail,
    String accessCode,
  ) async {
    try {
      final data = await ExtensionOfficerService.createInvite(
        extensionOfficerEmail,
        accessCode,
      );
      final invite = ExtensionOfficerInviteModel.fromJson(data);

      // Store locally
      // Store locally
      try {
        await _dao.insertOrUpdateInvitedOfficer(
          InvitedExtensionOfficersCompanion(
            inviteId: Value(invite.id ?? 0),
            accessCode: Value(invite.accessCode),
            officerId: Value(invite.extensionOfficer.id),
            firstName: Value(invite.extensionOfficer.firstName),
            middleName: Value(invite.extensionOfficer.middleName),
            lastName: Value(invite.extensionOfficer.lastName),
            email: Value(invite.extensionOfficer.email),
            phone: Value(invite.extensionOfficer.phone),
            specialization: Value(invite.extensionOfficer.specialization),
            organization: Value(invite.extensionOfficer.organization),
            countryId: Value(invite.extensionOfficer.countryId),
            regionId: Value(invite.extensionOfficer.regionId),
            districtId: Value(invite.extensionOfficer.districtId),
            wardId: Value(invite.extensionOfficer.wardId),
            isVerified: Value(invite.extensionOfficer.isVerified),
            inviteDate: Value(DateTime.now()),
            status: const Value('pending'),
            synced: const Value(true),
            syncAction: const Value('server-create'),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } catch (e) {
        log('⚠️ Failed to store invited officer locally: $e');
        // Don't rethrow, let the invite proceed
      }

      return invite;
    } catch (e, stackTrace) {
      log(
        '❌ Error creating extension officer invite: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteInvite(int inviteId) async {
    try {
      await _dao.markInviteAsDeleted(inviteId);
    } catch (e, stackTrace) {
      log(
        '❌ Error deleting extension officer invite locally: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // We don't rethrow here because it might be a local-only issue
      // allowing the UI to optimistically update or retry later via sync
    }
  }

  @override
  Future<List<InvitedExtensionOfficer>> getAllLocalInvitedOfficers() async {
    try {
      return await _dao.getAllInvitedOfficers();
    } catch (e, st) {
      log(
        '❌ Error loading local invited extension officers: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
