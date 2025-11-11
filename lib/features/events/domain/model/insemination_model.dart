class InseminationModel {
  final int? id;
  final String uuid;
  final String? farmUuid;
  final String livestockUuid;
  final String? lastHeatDate;
  final int currentHeatTypeId;
  final int inseminationServiceId;
  final int semenStrawTypeId;
  final String? inseminationDate;
  final String? bullCode;
  final String? bullBreed;
  final String? semenProductionDate;
  final String? productionCountry;
  final String? semenBatchNumber;
  final String? internationalId;
  final String? aiCode;
  final String? manufacturerName;
  final String? semenSupplier;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const InseminationModel({
    this.id,
    required this.uuid,
    this.farmUuid,
    required this.livestockUuid,
    this.lastHeatDate,
    required this.currentHeatTypeId,
    required this.inseminationServiceId,
    required this.semenStrawTypeId,
    this.inseminationDate,
    this.bullCode,
    this.bullBreed,
    this.semenProductionDate,
    this.productionCountry,
    this.semenBatchNumber,
    this.internationalId,
    this.aiCode,
    this.manufacturerName,
    this.semenSupplier,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  InseminationModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    String? lastHeatDate,
    int? currentHeatTypeId,
    int? inseminationServiceId,
    int? semenStrawTypeId,
    String? inseminationDate,
    String? bullCode,
    String? bullBreed,
    String? semenProductionDate,
    String? productionCountry,
    String? semenBatchNumber,
    String? internationalId,
    String? aiCode,
    String? manufacturerName,
    String? semenSupplier,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return InseminationModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      lastHeatDate: lastHeatDate ?? this.lastHeatDate,
      currentHeatTypeId: currentHeatTypeId ?? this.currentHeatTypeId,
      inseminationServiceId:
          inseminationServiceId ?? this.inseminationServiceId,
      semenStrawTypeId: semenStrawTypeId ?? this.semenStrawTypeId,
      inseminationDate: inseminationDate ?? this.inseminationDate,
      bullCode: bullCode ?? this.bullCode,
      bullBreed: bullBreed ?? this.bullBreed,
      semenProductionDate: semenProductionDate ?? this.semenProductionDate,
      productionCountry: productionCountry ?? this.productionCountry,
      semenBatchNumber: semenBatchNumber ?? this.semenBatchNumber,
      internationalId: internationalId ?? this.internationalId,
      aiCode: aiCode ?? this.aiCode,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      semenSupplier: semenSupplier ?? this.semenSupplier,
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
      'lastHeatDate': lastHeatDate,
      'currentHeatTypeId': currentHeatTypeId,
      'inseminationServiceId': inseminationServiceId,
      'semenStrawTypeId': semenStrawTypeId,
      'inseminationDate': inseminationDate,
      'bullCode': bullCode,
      'bullBreed': bullBreed,
      'semenProductionDate': semenProductionDate,
      'productionCountry': productionCountry,
      'semenBatchNumber': semenBatchNumber,
      'internationalId': internationalId,
      'aiCode': aiCode,
      'manufacturerName': manufacturerName,
      'semenSupplier': semenSupplier,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory InseminationModel.fromJson(Map<String, dynamic> json) {
    return InseminationModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String?,
      livestockUuid: json['livestockUuid'] as String,
      lastHeatDate: json['lastHeatDate'] as String?,
      currentHeatTypeId: json['currentHeatTypeId'] as int,
      inseminationServiceId: json['inseminationServiceId'] as int,
      semenStrawTypeId: json['semenStrawTypeId'] as int,
      inseminationDate: json['inseminationDate'] as String?,
      bullCode: json['bullCode'] as String?,
      bullBreed: json['bullBreed'] as String?,
      semenProductionDate: json['semenProductionDate'] as String?,
      productionCountry: json['productionCountry'] as String?,
      semenBatchNumber: json['semenBatchNumber'] as String?,
      internationalId: json['internationalId'] as String?,
      aiCode: json['aiCode'] as String?,
      manufacturerName: json['manufacturerName'] as String?,
      semenSupplier: json['semenSupplier'] as String?,
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
      'lastHeatDate': lastHeatDate,
      'currentHeatTypeId': currentHeatTypeId,
      'inseminationServiceId': inseminationServiceId,
      'semenStrawTypeId': semenStrawTypeId,
      'inseminationDate': inseminationDate,
      'bullCode': bullCode,
      'bullBreed': bullBreed,
      'semenProductionDate': semenProductionDate,
      'productionCountry': productionCountry,
      'semenBatchNumber': semenBatchNumber,
      'internationalId': internationalId,
      'aiCode': aiCode,
      'manufacturerName': manufacturerName,
      'semenSupplier': semenSupplier,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
