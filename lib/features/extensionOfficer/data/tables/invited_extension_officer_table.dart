import 'package:drift/drift.dart';

@DataClassName('InvitedExtensionOfficer')
class InvitedExtensionOfficers extends Table {
  // Local ID
  IntColumn get id => integer().autoIncrement()();

  // Invite Details
  IntColumn get inviteId => integer().unique()(); // Remote ID of the invite
  TextColumn get accessCode => text()();

  // Officer Details (Denormalized)
  IntColumn get officerId => integer()(); // Remote ID of the officer
  TextColumn get firstName => text()();
  TextColumn get middleName => text().nullable()();
  TextColumn get lastName => text()();
  TextColumn get email => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get specialization => text().nullable()();

  // Additional officer metadata returned by the server
  TextColumn get organization => text().nullable()();
  IntColumn get countryId => integer().nullable()();
  IntColumn get regionId => integer().nullable()();
  IntColumn get districtId => integer().nullable()();
  IntColumn get wardId => integer().nullable()();
  BoolColumn get isVerified => boolean().nullable()();

  // Tracking
  DateTimeColumn get inviteDate =>
      dateTime().nullable()(); // created_at of the invite
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending/accepted

  // Sync columns
  BoolColumn get synced => boolean().withDefault(const Constant(true))();
  TextColumn get syncAction => text().withDefault(
    const Constant('server-create'),
  )(); // create/update/delete/server-*

  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
