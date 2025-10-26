import 'package:drift/drift.dart';

@DataClassName('IdentityCardType')
class IdentityCardTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}