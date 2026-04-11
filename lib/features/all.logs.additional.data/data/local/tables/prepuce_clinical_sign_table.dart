import 'package:drift/drift.dart';

@DataClassName('PrepuceClinicalSign')
class PrepuceClinicalSigns extends Table {
  @override
  String get tableName => 'prepuce_clinical_signs';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameSw => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
