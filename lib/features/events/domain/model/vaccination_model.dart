class VaccinationModel {
  final int? id;
  final String uuid;
  final String? vaccinationNo;
  final String farmUuid;
  final String livestockUuid;
  final int? vaccineId;
  final int? diseaseId;
  final String? vetId;
  final String? extensionOfficerId;
  final String status;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const VaccinationModel({
    this.id,
    required this.uuid,
    this.vaccinationNo,
    required this.farmUuid,
    required this.livestockUuid,
    this.vaccineId,
    this.diseaseId,
    this.vetId,
    this.extensionOfficerId,
    this.status = 'completed',
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  VaccinationModel copyWith({
    int? id,
    String? vaccinationNo,
    String? farmUuid,
    String? livestockUuid,
    int? vaccineId,
    int? diseaseId,
    String? vetId,
    String? extensionOfficerId,
    String? status,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return VaccinationModel(
      id: id ?? this.id,
      uuid: uuid,
      vaccinationNo: vaccinationNo ?? this.vaccinationNo,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      vaccineId: vaccineId ?? this.vaccineId,
      diseaseId: diseaseId ?? this.diseaseId,
      vetId: vetId ?? this.vetId,
      extensionOfficerId: extensionOfficerId ?? this.extensionOfficerId,
      status: status ?? this.status,
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
      'vaccinationNo': vaccinationNo,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'vaccineId': vaccineId,
      'diseaseId': diseaseId,
      'vetId': vetId,
      'extensionOfficerId': extensionOfficerId,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory VaccinationModel.fromJson(Map<String, dynamic> json) {
    return VaccinationModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      vaccinationNo: json['vaccinationNo'] as String?,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      vaccineId: json['vaccineId'] as int?,
      diseaseId: json['diseaseId'] as int?,
      vetId: json['vetId'] as String?,
      extensionOfficerId: json['extensionOfficerId'] as String?,
      status: (json['status'] as String?) ?? 'completed',
      synced: (json['synced'] as bool?) ?? true,
      syncAction: json['syncAction'] as String? ?? 'create',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'uuid': uuid,
      'vaccinationNo': vaccinationNo,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'vaccineId': vaccineId,
      'diseaseId': diseaseId,
      'vetId': vetId,
      'extensionOfficerId': extensionOfficerId,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
