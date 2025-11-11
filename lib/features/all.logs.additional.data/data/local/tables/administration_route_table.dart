import 'package:drift/drift.dart';

@DataClassName('AdministrationRouteData')
class AdministrationRoutes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}
