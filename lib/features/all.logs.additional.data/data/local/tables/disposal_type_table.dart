import 'package:drift/drift.dart';

class DisposalTypes extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}
