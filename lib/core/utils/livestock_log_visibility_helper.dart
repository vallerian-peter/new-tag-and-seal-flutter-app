import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';

/// Central place to decide which event log types are valid for a given livestock.
class LivestockLogVisibilityHelper {
  /// Returns true if the given [logType] should be available for this [livestock].
  ///
  /// Uses `livestock.livestockTypeId` to scope species‑specific logs like
  /// calving, milking, and dry‑off to appropriate types (e.g. cattle only).
  static bool supportsLogType(Livestock livestock, String logType) {
    final typeId = livestock.livestockTypeId;

    switch (logType) {
      case EventLogTypes.calving:
        // Calving: cattle only
        return typeId == 1;

      case EventLogTypes.farrowing:
        // Farrowing: pigs only (Swine)
        return typeId == 2;

      case EventLogTypes.milking:
      case EventLogTypes.dryoff:
        // Restrict milk‑related logs to dairy animals (currently cattle only)
        return typeId == 1;

      case EventLogTypes.abortedPregnancy:
        // Aborted pregnancy: currently relevant for cattle and pigs
        return typeId == 1 || typeId == 2;

      // Generic logs – allowed for all livestock types
      case EventLogTypes.feeding:
      case EventLogTypes.deworming:
      case EventLogTypes.weightChange:
      case EventLogTypes.medication:
      case EventLogTypes.vaccination:
      case EventLogTypes.disposal:
        return true;

      // Future: tighten when we introduce species‑specific logs
      default:
        return true;
    }
  }
}


