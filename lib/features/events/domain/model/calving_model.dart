class CalvingModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final String startDate;
  final String? endDate;
  final int calvingTypeId;
  final int? calvingProblemsId;
  final int? reproductiveProblemId;
  final String? remarks;
  final String status;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const CalvingModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    required this.startDate,
    this.endDate,
    required this.calvingTypeId,
    this.calvingProblemsId,
    this.reproductiveProblemId,
    this.remarks,
    this.status = 'active',
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  CalvingModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    String? startDate,
    String? endDate,
    int? calvingTypeId,
    int? calvingProblemsId,
    int? reproductiveProblemId,
    String? remarks,
    String? status,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return CalvingModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      calvingTypeId: calvingTypeId ?? this.calvingTypeId,
      calvingProblemsId: calvingProblemsId ?? this.calvingProblemsId,
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
      'startDate': startDate,
      'endDate': endDate,
      'calvingTypeId': calvingTypeId,
      'calvingProblemsId': calvingProblemsId,
      'reproductiveProblemId': reproductiveProblemId,
      'remarks': remarks,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CalvingModel.fromJson(Map<String, dynamic> json) {
    return CalvingModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
      calvingTypeId: json['calvingTypeId'] as int,
      calvingProblemsId: json['calvingProblemsId'] as int?,
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
      'startDate': startDate,
      'endDate': endDate,
      'calvingTypeId': calvingTypeId,
      'calvingProblemsId': calvingProblemsId,
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
