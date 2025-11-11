class DewormingModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final int? administrationRouteId;
  final int? medicineId;
  final String? vetId;
  final String? extensionOfficerId;
  final String? quantity;
  final String? dose;
  final String? nextAdministrationDate;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const DewormingModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    this.administrationRouteId,
    this.medicineId,
    this.vetId,
    this.extensionOfficerId,
    this.quantity,
    this.dose,
    this.nextAdministrationDate,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  DewormingModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    int? administrationRouteId,
    int? medicineId,
    String? vetId,
    String? extensionOfficerId,
    String? quantity,
    String? dose,
    String? nextAdministrationDate,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return DewormingModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      administrationRouteId:
          administrationRouteId ?? this.administrationRouteId,
      medicineId: medicineId ?? this.medicineId,
      vetId: vetId ?? this.vetId,
      extensionOfficerId: extensionOfficerId ?? this.extensionOfficerId,
      quantity: quantity ?? this.quantity,
      dose: dose ?? this.dose,
      nextAdministrationDate:
          nextAdministrationDate ?? this.nextAdministrationDate,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory DewormingModel.fromJson(Map<String, dynamic> json) {
    return DewormingModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      administrationRouteId: json['administrationRouteId'] as int?,
      medicineId: json['medicineId'] as int?,
      vetId: json['vetId'] as String?,
      extensionOfficerId: json['extensionOfficerId'] as String?,
      quantity: json['quantity'] as String?,
      dose: json['dose'] as String?,
      nextAdministrationDate: json['nextAdministrationDate'] as String?,
      synced: (json['synced'] as bool?) ?? true,
      syncAction: json['syncAction'] as String? ?? 'create',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'administrationRouteId': administrationRouteId,
      'medicineId': medicineId,
      'vetId': vetId,
      'extensionOfficerId': extensionOfficerId,
      'quantity': quantity,
      'dose': dose,
      'nextAdministrationDate': nextAdministrationDate,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'uuid': uuid,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'administrationRouteId': administrationRouteId,
      'medicineId': medicineId,
      'vetId': vetId,
      'extensionOfficerId': extensionOfficerId,
      'quantity': quantity,
      'dose': dose,
      'nextAdministrationDate': nextAdministrationDate,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
