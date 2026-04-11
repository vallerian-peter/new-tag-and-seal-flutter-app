class LivestockMarkingModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final String markingType;
  final String? description;
  final String? notes;
  final String? eventDate;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const LivestockMarkingModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    required this.markingType,
    this.description,
    this.notes,
    this.eventDate,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  LivestockMarkingModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    String? markingType,
    String? description,
    String? notes,
    String? eventDate,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return LivestockMarkingModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      markingType: markingType ?? this.markingType,
      description: description ?? this.description,
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

  factory LivestockMarkingModel.fromJson(Map<String, dynamic> json) {
    return LivestockMarkingModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      markingType: (json['markingType'] as String?)?.trim().isNotEmpty == true
          ? (json['markingType'] as String).trim()
          : 'other',
      description: json['description'] as String?,
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
    'markingType': markingType,
    'description': description,
    'notes': notes,
    'eventDate': eventDate,
    'synced': synced,
    'syncAction': syncAction,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
