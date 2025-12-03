class AbortedPregnancyModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final String abortionDate;
  final int? reproductiveProblemId;
  final String? remarks;
  final String status;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const AbortedPregnancyModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    required this.abortionDate,
    this.reproductiveProblemId,
    this.remarks,
    this.status = 'active',
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  AbortedPregnancyModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    String? abortionDate,
    int? reproductiveProblemId,
    String? remarks,
    String? status,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return AbortedPregnancyModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      abortionDate: abortionDate ?? this.abortionDate,
      reproductiveProblemId:
          reproductiveProblemId ?? this.reproductiveProblemId,
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
      'abortionDate': abortionDate,
      'reproductiveProblemId': reproductiveProblemId,
      'remarks': remarks,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory AbortedPregnancyModel.fromJson(Map<String, dynamic> json) {
    return AbortedPregnancyModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      abortionDate: json['abortionDate'] as String,
      reproductiveProblemId: json['reproductiveProblemId'] as int?,
      remarks: json['remarks'] as String?,
      status: json['status'] as String? ?? 'active',
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
      'abortionDate': abortionDate,
      'reproductiveProblemId': reproductiveProblemId,
      'remarks': remarks,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

