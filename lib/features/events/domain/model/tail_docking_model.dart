class TailDockingModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final String? method;
  final String? notes;
  final String? eventDate;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const TailDockingModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    this.method,
    this.notes,
    this.eventDate,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  TailDockingModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    String? method,
    String? notes,
    String? eventDate,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return TailDockingModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      method: method ?? this.method,
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

  factory TailDockingModel.fromJson(Map<String, dynamic> json) {
    return TailDockingModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      method: json['method'] as String?,
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
    'method': method,
    'notes': notes,
    'eventDate': eventDate,
    'synced': synced,
    'syncAction': syncAction,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
