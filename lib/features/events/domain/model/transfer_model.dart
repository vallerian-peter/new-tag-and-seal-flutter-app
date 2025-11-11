class TransferModel {
  static const Object _unset = Object();

  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final String? toFarmUuid;
  final int? transporterId;
  final String? reason;
  final String? price;
  final String transferDate;
  final String? remarks;
  final String? status;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;
  final String? farmName;
  final String? toFarmName;
  final String? livestockName;

  const TransferModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    this.toFarmUuid,
    this.transporterId,
    this.reason,
    this.price,
    required this.transferDate,
    this.remarks,
    this.status,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
    this.farmName,
    this.toFarmName,
    this.livestockName,
  });

  TransferModel copyWith({
    Object? id = _unset,
    String? farmUuid,
    String? livestockUuid,
    Object? toFarmUuid = _unset,
    Object? transporterId = _unset,
    Object? reason = _unset,
    Object? price = _unset,
    String? transferDate,
    Object? remarks = _unset,
    Object? status = _unset,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
    Object? farmName = _unset,
    Object? toFarmName = _unset,
    Object? livestockName = _unset,
  }) {
    return TransferModel(
      id: identical(id, _unset) ? this.id : id as int?,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      toFarmUuid:
          identical(toFarmUuid, _unset) ? this.toFarmUuid : toFarmUuid as String?,
      transporterId: identical(transporterId, _unset)
          ? this.transporterId
          : transporterId as int?,
      reason:
          identical(reason, _unset) ? this.reason : reason as String?,
      price: identical(price, _unset) ? this.price : price as String?,
      transferDate: transferDate ?? this.transferDate,
      remarks:
          identical(remarks, _unset) ? this.remarks : remarks as String?,
      status:
          identical(status, _unset) ? this.status : status as String?,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      farmName: identical(farmName, _unset) ? this.farmName : farmName as String?,
      toFarmName: identical(toFarmName, _unset)
          ? this.toFarmName
          : toFarmName as String?,
      livestockName: identical(livestockName, _unset)
          ? this.livestockName
          : livestockName as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'toFarmUuid': toFarmUuid,
      'transporterId': transporterId,
      'reason': reason,
      'price': price,
      'transferDate': transferDate,
      'remarks': remarks,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'farmName': farmName,
      'toFarmName': toFarmName,
      'livestockName': livestockName,
    };
  }

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      toFarmUuid: json['toFarmUuid'] as String?,
      transporterId: json['transporterId'] as int?,
      reason: json['reason'] as String?,
      price: json['price']?.toString(),
      transferDate: json['transferDate'] as String,
      remarks: json['remarks'] as String?,
      status: json['status'] as String?,
      synced: (json['synced'] as bool?) ?? true,
      syncAction: json['syncAction'] as String? ?? 'create',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      farmName: json['farmName'] as String?,
      toFarmName: json['toFarmName'] as String?,
      livestockName: json['livestockName'] as String?,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'uuid': uuid,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'toFarmUuid': toFarmUuid,
      'transporterId': transporterId,
      'reason': reason,
      'price': price,
      'transferDate': transferDate,
      'remarks': remarks,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

