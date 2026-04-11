import 'dart:convert';

/// Domain model for a prepuce (sheath) condition log; maps to API JSON and Drift `PrepuceCondition`.
class PrepuceConditionModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final int conditionTypeId;
  final int severityId;
  final List<int> clinicalSignIds;
  final int? causeRiskId;
  final List<int> treatmentGivenIds;
  final int? medicineId;
  final int? administrationRouteId;
  final String? vetId;
  final String? extensionOfficerId;
  final String? quantity;
  final String? dose;
  final int breedingStatusId;
  final int? healingStatusId;
  final String? followUpDate;
  final String? notes;
  final String? eventDate;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const PrepuceConditionModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    required this.conditionTypeId,
    required this.severityId,
    this.clinicalSignIds = const [],
    this.causeRiskId,
    this.treatmentGivenIds = const [],
    this.medicineId,
    this.administrationRouteId,
    this.vetId,
    this.extensionOfficerId,
    this.quantity,
    this.dose,
    required this.breedingStatusId,
    this.healingStatusId,
    this.followUpDate,
    this.notes,
    this.eventDate,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  PrepuceConditionModel copyWith({
    int? id,
    String? uuid,
    String? farmUuid,
    String? livestockUuid,
    int? conditionTypeId,
    int? severityId,
    List<int>? clinicalSignIds,
    int? causeRiskId,
    List<int>? treatmentGivenIds,
    int? medicineId,
    int? administrationRouteId,
    String? vetId,
    String? extensionOfficerId,
    String? quantity,
    String? dose,
    int? breedingStatusId,
    int? healingStatusId,
    String? followUpDate,
    String? notes,
    String? eventDate,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return PrepuceConditionModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      conditionTypeId: conditionTypeId ?? this.conditionTypeId,
      severityId: severityId ?? this.severityId,
      clinicalSignIds: clinicalSignIds ?? this.clinicalSignIds,
      causeRiskId: causeRiskId ?? this.causeRiskId,
      treatmentGivenIds: treatmentGivenIds ?? this.treatmentGivenIds,
      medicineId: medicineId ?? this.medicineId,
      administrationRouteId:
          administrationRouteId ?? this.administrationRouteId,
      vetId: vetId ?? this.vetId,
      extensionOfficerId: extensionOfficerId ?? this.extensionOfficerId,
      quantity: quantity ?? this.quantity,
      dose: dose ?? this.dose,
      breedingStatusId: breedingStatusId ?? this.breedingStatusId,
      healingStatusId: healingStatusId ?? this.healingStatusId,
      followUpDate: followUpDate ?? this.followUpDate,
      notes: notes ?? this.notes,
      eventDate: eventDate ?? this.eventDate,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _isoOrNow(dynamic v) {
    if (v is String && v.isNotEmpty) return v;
    return DateTime.now().toIso8601String();
  }

  static List<int> _parseIntList(dynamic v) {
    if (v == null) return [];
    if (v is List) {
      final out = <int>[];
      for (final e in v) {
        if (e == null) continue;
        if (e is int) {
          if (e > 0) out.add(e);
        } else if (e is num) {
          final i = e.toInt();
          if (i > 0) out.add(i);
        } else {
          final i = int.tryParse(e.toString());
          if (i != null && i > 0) out.add(i);
        }
      }
      return out;
    }
    if (v is String && v.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is List) return _parseIntList(decoded);
      } catch (_) {}
    }
    return [];
  }

  static int? _parseId(dynamic v) {
    if (v == null) return null;
    if (v is int) return v > 0 ? v : null;
    if (v is num) {
      final i = v.toInt();
      return i > 0 ? i : null;
    }
    return int.tryParse(v.toString());
  }

  static int _requiredId(dynamic v, {int fallback = 0}) {
    final i = _parseId(v);
    if (i != null && i > 0) return i;
    return fallback;
  }

  factory PrepuceConditionModel.fromJson(Map<String, dynamic> json) {
    return PrepuceConditionModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      conditionTypeId: _requiredId(json['conditionTypeId']),
      severityId: _requiredId(json['severityId']),
      clinicalSignIds: _parseIntList(json['clinicalSignIds']),
      causeRiskId: _parseId(json['causeRiskId']),
      treatmentGivenIds: _parseIntList(json['treatmentGivenIds']),
      medicineId: _parseId(json['medicineId']),
      administrationRouteId: _parseId(json['administrationRouteId']),
      vetId: json['vetId'] as String?,
      extensionOfficerId: json['extensionOfficerId'] as String?,
      quantity: json['quantity'] as String?,
      dose: json['dose'] as String?,
      breedingStatusId: _requiredId(json['breedingStatusId']),
      healingStatusId: _parseId(json['healingStatusId']),
      followUpDate: json['followUpDate'] as String?,
      notes: json['notes'] as String?,
      eventDate: json['eventDate'] as String?,
      synced: (json['synced'] as bool?) ?? true,
      syncAction: json['syncAction'] as String? ?? 'create',
      createdAt: _isoOrNow(json['createdAt']),
      updatedAt: _isoOrNow(json['updatedAt']),
    );
  }

  Map<String, dynamic> toApiJson() => {
        'uuid': uuid,
        'farmUuid': farmUuid,
        'livestockUuid': livestockUuid,
        'conditionTypeId': conditionTypeId,
        'severityId': severityId,
        'clinicalSignIds': clinicalSignIds,
        if (causeRiskId != null) 'causeRiskId': causeRiskId,
        'treatmentGivenIds': treatmentGivenIds,
        'medicineId': medicineId,
        'administrationRouteId': administrationRouteId,
        'vetId': vetId,
        'extensionOfficerId': extensionOfficerId,
        'quantity': quantity,
        'dose': dose,
        'breedingStatusId': breedingStatusId,
        if (healingStatusId != null) 'healingStatusId': healingStatusId,
        'followUpDate': followUpDate,
        'notes': notes,
        'eventDate': eventDate,
        'synced': synced,
        'syncAction': syncAction,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
