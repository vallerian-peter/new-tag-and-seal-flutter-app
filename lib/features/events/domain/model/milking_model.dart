class MilkingModel {
  final int? id;
  final String uuid;
  final String? farmUuid;
  final String livestockUuid;
  final int? milkingMethodId;
  final String amount;
  final String lactometerReading;
  final String solid;
  final String solidNonFat;
  final String protein;
  final String correctedLactometerReading;
  final String totalSolids;
  final String colonyFormingUnits;
  final String? acidity;
  final String session;
  final String status;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const MilkingModel({
    this.id,
    required this.uuid,
    this.farmUuid,
    required this.livestockUuid,
    this.milkingMethodId,
    required this.amount,
    required this.lactometerReading,
    required this.solid,
    required this.solidNonFat,
    required this.protein,
    required this.correctedLactometerReading,
    required this.totalSolids,
    required this.colonyFormingUnits,
    this.acidity,
    this.session = 'morning',
    this.status = 'active',
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  MilkingModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    int? milkingMethodId,
    String? amount,
    String? lactometerReading,
    String? solid,
    String? solidNonFat,
    String? protein,
    String? correctedLactometerReading,
    String? totalSolids,
    String? colonyFormingUnits,
    String? acidity,
    String? session,
    String? status,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return MilkingModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      milkingMethodId: milkingMethodId ?? this.milkingMethodId,
      amount: amount ?? this.amount,
      lactometerReading: lactometerReading ?? this.lactometerReading,
      solid: solid ?? this.solid,
      solidNonFat: solidNonFat ?? this.solidNonFat,
      protein: protein ?? this.protein,
      correctedLactometerReading:
          correctedLactometerReading ?? this.correctedLactometerReading,
      totalSolids: totalSolids ?? this.totalSolids,
      colonyFormingUnits: colonyFormingUnits ?? this.colonyFormingUnits,
      acidity: acidity ?? this.acidity,
      session: session ?? this.session,
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
      'milkingMethodId': milkingMethodId,
      'amount': amount,
      'lactometerReading': lactometerReading,
      'solid': solid,
      'solidNonFat': solidNonFat,
      'protein': protein,
      'correctedLactometerReading': correctedLactometerReading,
      'totalSolids': totalSolids,
      'colonyFormingUnits': colonyFormingUnits,
      'acidity': acidity,
      'session': session,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory MilkingModel.fromJson(Map<String, dynamic> json) {
    return MilkingModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String?,
      livestockUuid: json['livestockUuid'] as String,
      milkingMethodId: json['milkingMethodId'] as int?,
      amount: json['amount'] as String,
      lactometerReading: json['lactometerReading'] as String,
      solid: json['solid'] as String,
      solidNonFat: json['solidNonFat'] as String,
      protein: json['protein'] as String,
      correctedLactometerReading: json['correctedLactometerReading'] as String,
      totalSolids: json['totalSolids'] as String,
      colonyFormingUnits: json['colonyFormingUnits'] as String,
      acidity: json['acidity'] as String?,
      session: json['session'] as String? ?? 'morning',
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
      'milkingMethodId': milkingMethodId,
      'amount': amount,
      'lactometerReading': lactometerReading,
      'solid': solid,
      'solidNonFat': solidNonFat,
      'protein': protein,
      'correctedLactometerReading': correctedLactometerReading,
      'totalSolids': totalSolids,
      'colonyFormingUnits': colonyFormingUnits,
      'acidity': acidity,
      'session': session,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
