class VaccineModel {
  final int? id;
  final String uuid;
  final String? farmUuid;
  final String name;
  final String? lot;
  final String? formulationType;
  final String? dose;
  final String? status;
  final int? vaccineTypeId;
  final String? vaccineSchedule;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const VaccineModel({
    this.id,
    required this.uuid,
    this.farmUuid,
    required this.name,
    this.lot,
    this.formulationType,
    this.dose,
    this.status,
    this.vaccineTypeId,
    this.vaccineSchedule,
    this.synced = true,
    this.syncAction = 'server-create',
    required this.createdAt,
    required this.updatedAt,
  });

  VaccineModel copyWith({
    int? id,
    String? uuid,
    String? farmUuid,
    String? name,
    String? lot,
    String? formulationType,
    String? dose,
    String? status,
    int? vaccineTypeId,
    String? vaccineSchedule,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return VaccineModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      name: name ?? this.name,
      lot: lot ?? this.lot,
      formulationType: formulationType ?? this.formulationType,
      dose: dose ?? this.dose,
      status: status ?? this.status,
      vaccineTypeId: vaccineTypeId ?? this.vaccineTypeId,
      vaccineSchedule: vaccineSchedule ?? this.vaccineSchedule,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String?,
      name: json['name'] as String? ?? '',
      lot: json['lot'] as String?,
      formulationType: json['formulationType'] as String?,
      dose: json['dose'] as String?,
      status: json['status'] as String?,
      vaccineTypeId: json['vaccineTypeId'] as int?,
      vaccineSchedule: json['vaccineSchedule'] as String?,
      synced: json['synced'] is bool ? json['synced'] as bool : true,
      syncAction: json['syncAction'] as String? ?? 'server-create',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'farmUuid': farmUuid,
      'name': name,
      'lot': lot,
      'formulationType': formulationType,
      'dose': dose,
      'status': status,
      'vaccineTypeId': vaccineTypeId,
      'vaccineSchedule': vaccineSchedule,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

