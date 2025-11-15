import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/feeding_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/weight_change_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/deworming_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/medication_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/vaccination_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/disposal_form.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

/// Centralized navigation handler for event-log forms.
class EventFormControl {
  static Future<void> open({
    required BuildContext context,
    required String logType,
    required String title,
    String? farmUuid,
    String? livestockUuid,
    bool isBulk = false,
    List<String>? bulkLivestockUuids,
    bool allowEmptyContext = false,
    VoidCallback? onCompleted,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    if (!allowEmptyContext &&
        !_validateContext(context, l10n, farmUuid, livestockUuid)) {
      return;
    }

    switch (logType) {
      case EventLogTypes.feeding:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FeedingFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        onCompleted?.call();
        return;

      case EventLogTypes.weightChange:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WeightChangeFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        onCompleted?.call();
        return;

      case EventLogTypes.deworming:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DewormingFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        onCompleted?.call();
        return;

      case EventLogTypes.medication:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MedicationFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        onCompleted?.call();
        return;

      case EventLogTypes.vaccination:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VaccinationFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        onCompleted?.call();
        return;

      case EventLogTypes.disposal:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DisposalFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        onCompleted?.call();
        return;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title - ${l10n.comingSoon}')),
        );
    }
  }

  static bool _validateContext(
    BuildContext context,
    AppLocalizations l10n,
    String? farmUuid,
    String? livestockUuid,
  ) {
    if (farmUuid == null ||
        farmUuid.isEmpty ||
        livestockUuid == null ||
        livestockUuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logContextMissing)),
      );
      return false;
    }
    return true;
  }
}
