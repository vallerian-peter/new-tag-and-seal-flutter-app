/// One cached option from sync (`prepuceConditionTypes`, `prepuceSeverities`, …).
class PrepuceReferenceOption {
  final String kind;
  final int referenceId;
  final String name;
  final String? nameSw;

  const PrepuceReferenceOption({
    required this.kind,
    required this.referenceId,
    required this.name,
    this.nameSw,
  });

  factory PrepuceReferenceOption.fromJson(
    Map<String, dynamic> json, {
    required String kind,
  }) {
    final id = json['id'];
    return PrepuceReferenceOption(
      kind: kind,
      referenceId: id is int ? id : int.parse(id.toString()),
      name: (json['name'] as String?)?.trim() ?? '',
      nameSw: (json['nameSw'] as String?)?.trim(),
    );
  }

  String labelForLocale(String? languageCode) {
    final lc = languageCode?.toLowerCase() ?? 'en';
    if (lc.startsWith('sw')) {
      final s = nameSw?.trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return name.isNotEmpty ? name : '$referenceId';
  }
}

/// [kind] values must match keys used when persisting sync rows.
abstract final class PrepuceReferenceKind {
  static const conditionType = 'condition_type';
  static const severity = 'severity';
  static const clinicalSign = 'clinical_sign';
  static const causeRisk = 'cause_risk';
  static const treatmentGiven = 'treatment_given';
  static const breedingStatus = 'breeding_status';
  static const healingStatus = 'healing_status';
}
