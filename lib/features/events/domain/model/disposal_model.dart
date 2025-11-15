class DisposalModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final int? disposalTypeId;
  final String reasons;
  final String? remarks;
  final String status;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const DisposalModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    this.disposalTypeId,
    required this.reasons,
    this.remarks,
    this.status = 'completed',
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  DisposalModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    int? disposalTypeId,
    String? reasons,
    String? remarks,
    String? status,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return DisposalModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      disposalTypeId: disposalTypeId ?? this.disposalTypeId,
      reasons: reasons ?? this.reasons,
      remarks: remarks ?? this.remarks,
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
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'disposalTypeId': disposalTypeId,
      'reasons': reasons,
      'remarks': remarks,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory DisposalModel.fromJson(Map<String, dynamic> json) {
    return DisposalModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      disposalTypeId: json['disposalTypeId'] as int?,
      reasons: json['reasons'] as String? ?? '',
      remarks: json['remarks'] as String?,
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
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'disposalTypeId': disposalTypeId,
      'reasons': reasons,
      'remarks': remarks,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

