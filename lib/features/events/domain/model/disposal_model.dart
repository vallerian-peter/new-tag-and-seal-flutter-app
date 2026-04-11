class DisposalModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final int? disposalTypeId;
  final String reasons;
  final String? remarks;
  final double? saleWeight;
  final double? salePrice;
  final String? buyerName;
  final String status;
  final String? eventDate;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const DisposalModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    this.disposalTypeId,
    required this.reasons,
    this.remarks,
    this.saleWeight,
    this.salePrice,
    this.buyerName,
    this.status = 'completed',
    this.eventDate,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  DisposalModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    int? disposalTypeId,
    String? reasons,
    String? remarks,
    double? saleWeight,
    double? salePrice,
    String? buyerName,
    String? status,
    String? eventDate,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return DisposalModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      disposalTypeId: disposalTypeId ?? this.disposalTypeId,
      reasons: reasons ?? this.reasons,
      remarks: remarks ?? this.remarks,
      saleWeight: saleWeight ?? this.saleWeight,
      salePrice: salePrice ?? this.salePrice,
      buyerName: buyerName ?? this.buyerName,
      status: status ?? this.status,
      eventDate: eventDate ?? this.eventDate,
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
      'disposalTypeId': disposalTypeId,
      'reasons': reasons,
      'remarks': remarks,
      'saleWeight': saleWeight,
      'salePrice': salePrice,
      'buyerName': buyerName,
      'status': status,
      'eventDate': eventDate,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory DisposalModel.fromJson(Map<String, dynamic> json) {
    return DisposalModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      disposalTypeId: json['disposalTypeId'] as int?,
      reasons: json['reasons'] as String? ?? '',
      remarks: json['remarks'] as String?,
      saleWeight: _parseDouble(json['saleWeight']),
      salePrice: _parseDouble(json['salePrice']),
      buyerName: json['buyerName'] as String?,
      status: (json['status'] as String?) ?? 'completed',
      eventDate: json['eventDate'] as String?,
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
      'disposalTypeId': disposalTypeId,
      'reasons': reasons,
      'remarks': remarks,
      'saleWeight': saleWeight,
      'salePrice': salePrice,
      'buyerName': buyerName,
      'status': status,
      'eventDate': eventDate,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

