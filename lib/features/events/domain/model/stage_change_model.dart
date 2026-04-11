class StageChangeModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final int? fromStageId;
  final int? toStageId;
  final String? notes;
  final String? eventDate;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const StageChangeModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    this.fromStageId,
    this.toStageId,
    this.notes,
    this.eventDate,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  StageChangeModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    int? fromStageId,
    int? toStageId,
    String? notes,
    String? eventDate,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return StageChangeModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      fromStageId: fromStageId ?? this.fromStageId,
      toStageId: toStageId ?? this.toStageId,
      notes: notes ?? this.notes,
      eventDate: eventDate ?? this.eventDate,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  static String _isoOrNow(dynamic v) {
    if (v is String && v.isNotEmpty) return v;
    return DateTime.now().toIso8601String();
  }

  factory StageChangeModel.fromJson(Map<String, dynamic> json) {
    return StageChangeModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      fromStageId: _parseInt(json['fromStageId']),
      toStageId: _parseInt(json['toStageId']),
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
    'fromStageId': fromStageId,
    'toStageId': toStageId,
    'notes': notes,
    'eventDate': eventDate,
    'synced': synced,
    'syncAction': syncAction,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
