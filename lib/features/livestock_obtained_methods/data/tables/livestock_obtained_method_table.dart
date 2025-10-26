import 'package:drift/drift.dart';

@DataClassName('LivestockObtainedMethod')
class LivestockObtainedMethods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}
