class DryoffModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final String startDate;
  final String? endDate;
  final String? reason;
  final String? remarks;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const DryoffModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    required this.startDate,
    this.endDate,
    this.reason,
    this.remarks,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  DryoffModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    String? startDate,
    String? endDate,
    String? reason,
    String? remarks,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return DryoffModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      remarks: remarks ?? this.remarks,
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
      'reason': reason,
      'remarks': remarks,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory DryoffModel.fromJson(Map<String, dynamic> json) {
    return DryoffModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
      reason: json['reason'] as String?,
      remarks: json['remarks'] as String?,
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
      'reason': reason,
      'remarks': remarks,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
