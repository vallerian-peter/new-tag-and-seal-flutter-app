import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/feeding_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/weight_change_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/deworming_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/medication_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/vaccination_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/disposal_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/milking_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/pregnancy_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/calving_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/dryoff_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/insemination_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/view_events.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class EventsViewControl {
  static Future<void> openForm({
    required BuildContext context,
    required String logType,
    required String title,
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    if (farmUuid == null ||
        farmUuid.isEmpty ||
        livestockUuid == null ||
        livestockUuid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.logContextMissing)));
      return;
    }

    switch (logType) {
      case EventLogTypes.feeding:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FeedingFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      case EventLogTypes.weightChange:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WeightChangeFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      case EventLogTypes.deworming:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DewormingFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      case EventLogTypes.medication:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MedicationFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      case EventLogTypes.vaccination:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VaccinationFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      case EventLogTypes.disposal:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DisposalFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      case EventLogTypes.milking:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MilkingFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      case EventLogTypes.pregnancy:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PregnancyFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      case EventLogTypes.calving:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CalvingFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      case EventLogTypes.dryoff:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DryoffFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      case EventLogTypes.insemination:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InseminationFormScreen(
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title - ${l10n.comingSoon}')));
    }
  }

  static Future<void> openLogs({
    required BuildContext context,
    required String logType,
    required String title,
    String? farmUuid,
    required String livestockUuid,
    String? farmName,
    String? livestockName,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    switch (logType) {
      case EventLogTypes.feeding:
      case EventLogTypes.weightChange:
      case EventLogTypes.deworming:
      case EventLogTypes.medication:
      case EventLogTypes.vaccination:
      case EventLogTypes.disposal:
      case EventLogTypes.milking:
      case EventLogTypes.pregnancy:
      case EventLogTypes.calving:
      case EventLogTypes.dryoff:
      case EventLogTypes.insemination:
        final eventsProvider = Provider.of<EventsProvider>(
          context,
          listen: false,
        );
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ViewEventsScreen(
              title: title,
              logType: logType,
              farmUuid: farmUuid,
              livestockUuid: livestockUuid,
              eventsProvider: eventsProvider,
              farmName: farmName,
              livestockName: livestockName,
              showHeaderContextBadges: true,
              showCardContextRows: false,
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title - ${l10n.comingSoon}')));
    }
  }
}
