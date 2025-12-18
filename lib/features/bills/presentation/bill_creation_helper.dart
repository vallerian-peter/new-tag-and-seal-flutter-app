import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/presentation/bill_create_dialog.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';

class BillCreationHelper {
  static const List<String> _technicalLogTypes = [
    EventLogTypes.medication,
    EventLogTypes.vaccination,
    EventLogTypes.deworming,
    EventLogTypes.insemination,
    EventLogTypes.pregnancy,
    EventLogTypes.calving,
    EventLogTypes.farrowing,
    EventLogTypes.abortedPregnancy,
    EventLogTypes.disposal,
    EventLogTypes.dryoff,
  ];

  static bool isTechnicalLog(String logType) {
    return _technicalLogTypes.contains(logType);
  }

  static Future<void> maybeCreateBillForLog({
    required BuildContext context,
    required String logType,
    required String farmUuid,
    required String subjectUuid,
    int quantity = 1,
    int numberOfLivestock = 1,
  }) async {
    if (!isTechnicalLog(logType)) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isExtensionOfficer) {
      return;
    }

    await showBillCreateDialogAndSave(
      context,
      farmUuid: farmUuid,
      subjectType: logType,
      subjectUuid: subjectUuid,
      livestockCount: numberOfLivestock,
    );
  }

  static Future<void> maybeCreateBillForLivestock({
    required BuildContext context,
    required String farmUuid,
    required String livestockUuid,
  }) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isExtensionOfficer) {
      return;
    }

    await showBillCreateDialogAndSave(
      context,
      farmUuid: farmUuid,
      subjectType: 'livestock',
      subjectUuid: livestockUuid,
      livestockCount: 1,
    );
  }
}
