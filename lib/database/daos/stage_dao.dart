import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../features/all.additional.data/data/local/tables/stage_table.dart';

part 'stage_dao.g.dart';

@DriftAccessor(tables: [Stages])
class StageDao extends DatabaseAccessor<AppDatabase> with _$StageDaoMixin {
  StageDao(AppDatabase db) : super(db);

  Future<List<Stage>> getAllStages() => select(stages).get();

  Future<Stage?> getStageById(int id) =>
      (select(stages)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<void> upsertStages(List<StagesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAll(stages, entries, mode: InsertMode.insertOrReplace);
    });
  }
}
