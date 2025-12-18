import '../tables/invited_extension_officer_table.dart';
import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';

part 'extension_officer_dao.g.dart';

@DriftAccessor(tables: [InvitedExtensionOfficers])
class ExtensionOfficerDao extends DatabaseAccessor<AppDatabase>
    with _$ExtensionOfficerDaoMixin {
  ExtensionOfficerDao(AppDatabase db) : super(db);

  // Insert or Update Invited Officer (Upsert based on inviteId which is unique)
  Future<void> insertOrUpdateInvitedOfficer(
    Insertable<InvitedExtensionOfficer> entry,
  ) async {
    await into(invitedExtensionOfficers).insertOnConflictUpdate(entry);
  }

bool? _toBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  final s = v.toString().toLowerCase().trim();
  if (s == '1' || s == 'true') return true;
  if (s == '0' || s == 'false') return false;
  return null;
}

  // Get all invited officers (excluding deleted)
  Future<List<InvitedExtensionOfficer>> getAllInvitedOfficers() {
    return (select(
      invitedExtensionOfficers,
    )..where((t) => t.syncAction.isNotValue('deleted'))).get();
  }

  // Get invited officer by email
  Future<InvitedExtensionOfficer?> getInvitedOfficerByEmail(String email) {
    return (select(
      invitedExtensionOfficers,
    )..where((t) => t.email.equals(email))).getSingleOrNull();
  }

  // Clear all invited officers (for testing or full sync override)
  Future<void> clearAllInvitedOfficers() async {
    await delete(invitedExtensionOfficers).go();
  }

  // Sync Invited Officers: Batched insert/update
  Future<void> syncInvitedOfficers(List<Map<String, dynamic>> items) async {
    await batch((batch) {
      for (final item in items) {
        batch.insert(
          invitedExtensionOfficers,
          InvitedExtensionOfficersCompanion(
            inviteId: Value(
              item['inviteId'] is int
                  ? item['inviteId']
                  : int.parse(item['inviteId'].toString()),
            ),
            accessCode: Value(item['access_code'] ?? ''),
            officerId: Value(
              item['officerId'] is int
                  ? item['officerId']
                  : int.parse(item['officerId'].toString()),
            ),
            firstName: Value(item['firstName'] ?? ''),
            middleName: Value(item['middleName']),
            lastName: Value(item['lastName'] ?? ''),
            email: Value(item['email'] ?? ''),
            phone: Value(item['phone']),
            organization: Value(item['organization']),
            countryId: Value(
              item['countryId'] is int
                  ? item['countryId']
                  : (item['countryId'] != null
                        ? int.tryParse(item['countryId'].toString())
                        : null),
            ),
            regionId: Value(
              item['regionId'] is int
                  ? item['regionId']
                  : (item['regionId'] != null
                        ? int.tryParse(item['regionId'].toString())
                        : null),
            ),
            districtId: Value(
              item['districtId'] is int
                  ? item['districtId']
                  : (item['districtId'] != null
                        ? int.tryParse(item['districtId'].toString())
                        : null),
            ),
            wardId: Value(
              item['wardId'] is int
                  ? item['wardId']
                  : (item['wardId'] != null
                        ? int.tryParse(item['wardId'].toString())
                        : null),
            ),
            isVerified: Value(_toBool(item['isVerified'])),
            specialization: Value(item['specialization']),
            inviteDate: Value(
              item['inviteDate'] != null
                  ? DateTime.tryParse(item['inviteDate'])
                  : null,
            ),
            status: Value(item['status'] ?? 'pending'),
            synced: const Value(true),
            syncAction: const Value('server-update'),
            updatedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // Get unsynced invites
  Future<List<InvitedExtensionOfficer>> getUnsyncedInvites() {
    return (select(
      invitedExtensionOfficers,
    )..where((t) => t.synced.equals(false))).get();
  }

  // Mark invite as deleted (soft delete)
  Future<void> markInviteAsDeleted(int inviteId) async {
    await (update(
      invitedExtensionOfficers,
    )..where((t) => t.inviteId.equals(inviteId))).write(
      InvitedExtensionOfficersCompanion(
        synced: const Value(false),
        syncAction: const Value('deleted'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Mark invites as synced
  Future<void> markInvitesAsSynced(List<int> inviteIds) async {
    await (update(
      invitedExtensionOfficers,
    )..where((t) => t.inviteId.isIn(inviteIds))).write(
      InvitedExtensionOfficersCompanion(
        synced: const Value(true),
        syncAction: const Value(
          'server-update',
        ), // or remains deleted if it was deleted?
        // Actually if it was 'deleted' and we synced it, we should probably hard delete it now or keep it as synced deleted?
        // For now, let's just mark synced=true.
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Cleanup: Hard delete items that were marked as deleted and now successfully synced
    await (delete(invitedExtensionOfficers)..where(
          (t) => t.inviteId.isIn(inviteIds) & t.syncAction.equals('deleted'),
        ))
        .go();
  }
}
