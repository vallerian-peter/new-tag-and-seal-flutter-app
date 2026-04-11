import 'package:drift/drift.dart';

class TeethClippingMethods extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

