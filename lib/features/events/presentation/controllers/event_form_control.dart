import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/role_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/feeding_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/weight_change_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/deworming_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/treatment_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/vaccination_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/disposal_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/birth_event_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/aborted_pregnancy_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/insemination_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/pregnancy_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/milking_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/dryoff_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/transfer_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/husbandry_event_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/prepuce_condition_form.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

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

    // Check role access before proceeding (defensive check)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!RoleHelper.checkCanAccessLogType(
      context,
      l10n,
      authProvider,
      logType,
    )) {
      return; // Access denied, toast already shown
    }

    if (!allowEmptyContext &&
        !_validateContext(context, l10n, farmUuid, livestockUuid)) {
      return;
    }

    switch (logType) {
      case EventLogTypes.feeding:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FeedingFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.weightChange:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WeightChangeFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.deworming:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DewormingFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.treatment:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TreatmentFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.vaccination:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VaccinationFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.disposal:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DisposalFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
              onCompleted: onCompleted,
            ),
          ),
        );
        return;

      case EventLogTypes.calving:
      case EventLogTypes.farrowing:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BirthEventFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.abortedPregnancy:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AbortedPregnancyFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.insemination:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InseminationFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.pregnancy:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PregnancyFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.milking:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MilkingFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.dryoff:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DryoffFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;

      case EventLogTypes.transfer:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransferFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        // Only refresh if form completed successfully (result is not null)
        if (result != null) {
          onCompleted?.call();
        }
        return;
      case EventLogTypes.teethClipping:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HusbandryEventFormScreen(
              eventType: HusbandryEventType.teethClipping,
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        if (result != null) {
          onCompleted?.call();
        }
        return;
      case EventLogTypes.tailDocking:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HusbandryEventFormScreen(
              eventType: HusbandryEventType.tailDocking,
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        if (result != null) {
          onCompleted?.call();
        }
        return;
      case EventLogTypes.ironInjection:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HusbandryEventFormScreen(
              eventType: HusbandryEventType.ironInjection,
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        if (result != null) {
          onCompleted?.call();
        }
        return;
      case EventLogTypes.livestockMarking:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HusbandryEventFormScreen(
              eventType: HusbandryEventType.livestockMarking,
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        if (result != null) {
          onCompleted?.call();
        }
        return;
      case EventLogTypes.stageChange:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HusbandryEventFormScreen(
              eventType: HusbandryEventType.stageChange,
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        if (result != null) {
          onCompleted?.call();
        }
        return;
      case EventLogTypes.prepuceCondition:
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PrepuceConditionFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              isBulk: isBulk,
              bulkLivestockUuids: bulkLivestockUuids,
            ),
          ),
        );
        if (result != null) {
          onCompleted?.call();
        }
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
