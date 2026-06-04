import 'package:flutter/material.dart';

const String appDatePickerManualInputHint = 'day/month/yyyy';

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  TransitionBuilder? builder,
}) {
  final appLocale = Localizations.localeOf(context);
  final pickerLocale = appLocale.languageCode == 'en'
      ? const Locale('en', 'GB')
      : appLocale;

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: helpText,
    initialEntryMode: initialEntryMode,
    fieldHintText: appDatePickerManualInputHint,
    locale: pickerLocale,
    builder: builder,
  );
}
