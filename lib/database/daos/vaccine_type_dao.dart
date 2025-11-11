import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/data/tables/vaccine_type_table.dart';

import '../app_database.dart';

part 'vaccine_type_dao.g.dart';

@DriftAccessor(tables: [VaccineTypes])
class VaccineTypeDao extends DatabaseAccessor<AppDatabase>
    with _$VaccineTypeDaoMixin {
  VaccineTypeDao(AppDatabase db) : super(db);

  Future<void> upsertVaccineTypes(List<VaccineTypesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(vaccineTypes, entries);
    });
  }

  Future<List<VaccineType>> getAllVaccineTypes() {
    return (select(
      vaccineTypes,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.name)])).get();
  }

  Future<void> clearVaccineTypes() async {
    await delete(vaccineTypes).go();
  }
}
