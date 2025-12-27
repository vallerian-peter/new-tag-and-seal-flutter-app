class TreatmentModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final int? diseaseId;
  final int? medicineId;
  final String? quantity;
  final String? withdrawalPeriod;
  final String? medicationDate;
  final String? nextMedicationDate;
  final String? remarks;
  final String? eventDate;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const TreatmentModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    this.diseaseId,
    this.medicineId,
    this.quantity,
    this.withdrawalPeriod,
    this.medicationDate,
    this.nextMedicationDate,
    this.remarks,
    this.eventDate,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  TreatmentModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    int? diseaseId,
    int? medicineId,
    String? quantity,
    String? withdrawalPeriod,
    String? medicationDate,
    String? nextMedicationDate,
    String? remarks,
    String? eventDate,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return TreatmentModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      diseaseId: diseaseId ?? this.diseaseId,
      medicineId: medicineId ?? this.medicineId,
      quantity: quantity ?? this.quantity,
      withdrawalPeriod: withdrawalPeriod ?? this.withdrawalPeriod,
      medicationDate: medicationDate ?? this.medicationDate,
      nextMedicationDate: nextMedicationDate ?? this.nextMedicationDate,
      remarks: remarks ?? this.remarks,
      eventDate: eventDate ?? this.eventDate,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'diseaseId': diseaseId,
      'medicineId': medicineId,
      'quantity': quantity,
      'withdrawalPeriod': withdrawalPeriod,
      'medicationDate': medicationDate,
      'nextMedicationDate': nextMedicationDate,
      'remarks': remarks,
      'eventDate': eventDate,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      diseaseId: json['diseaseId'] as int?,
      medicineId: json['medicineId'] as int?,
      quantity: json['quantity'] as String?,
      withdrawalPeriod: json['withdrawalPeriod'] as String?,
      medicationDate: json['medicationDate'] as String?,
      nextMedicationDate: json['nextMedicationDate'] as String?,
      remarks: json['remarks'] as String?,
      eventDate: json['eventDate'] as String?,
      synced: (json['synced'] as bool?) ?? true,
      syncAction: json['syncAction'] as String? ?? 'create',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'uuid': uuid,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'diseaseId': diseaseId,
      'medicineId': medicineId,
      'quantity': quantity,
      'withdrawalPeriod': withdrawalPeriod,
      'medicationDate': medicationDate,
      'nextMedicationDate': nextMedicationDate,
      'remarks': remarks,
      'eventDate': eventDate,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

