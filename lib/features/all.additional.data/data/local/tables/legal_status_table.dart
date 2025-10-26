import 'package:drift/drift.dart';

@DataClassName('LegalStatus')
class LegalStatuses extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}