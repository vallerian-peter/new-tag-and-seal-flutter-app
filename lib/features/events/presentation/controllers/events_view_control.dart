import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/forms/feeding_form.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logContextMissing)),
      );
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
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title - ${l10n.comingSoon}')),
        );
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
        final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
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
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title - ${l10n.comingSoon}')),
        );
    }
  }
}


