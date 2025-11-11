class PregnancyModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final int testResultId;
  final String? noOfMonths;
  final String? testDate;
  final String status;
  final String? remarks;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const PregnancyModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    required this.testResultId,
    this.noOfMonths,
    this.testDate,
    this.status = 'active',
    this.remarks,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  PregnancyModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    int? testResultId,
    String? noOfMonths,
    String? testDate,
    String? status,
    String? remarks,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return PregnancyModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      testResultId: testResultId ?? this.testResultId,
      noOfMonths: noOfMonths ?? this.noOfMonths,
      testDate: testDate ?? this.testDate,
      status: status ?? this.status,
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
      'testResultId': testResultId,
      'noOfMonths': noOfMonths,
      'testDate': testDate,
      'status': status,
      'remarks': remarks,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory PregnancyModel.fromJson(Map<String, dynamic> json) {
    return PregnancyModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      testResultId: json['testResultId'] as int,
      noOfMonths: json['noOfMonths'] as String?,
      testDate: json['testDate'] as String?,
      status: json['status'] as String? ?? 'active',
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
      'testResultId': testResultId,
      'noOfMonths': noOfMonths,
      'testDate': testDate,
      'status': status,
      'remarks': remarks,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
