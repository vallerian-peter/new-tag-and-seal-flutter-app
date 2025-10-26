/// Farm domain model representing a farm entity
class FarmModel {
  final int id;
  final int farmerId;
  final String uuid;
  final String referenceNo;
  final String regionalRegNo;
  final String name;
  final String size;  // Changed to String to match backend varchar
  final String sizeUnit;
  final String latitudes;  // Changed to String to match backend varchar
  final String longitudes;  // Changed to String to match backend varchar
  final String physicalAddress;
  final int? villageId;
  final int wardId;
  final int districtId;
  final int regionId;
  final int countryId;
  final int legalStatusId;
  final String status;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const FarmModel({
    required this.id,
    required this.farmerId,
    required this.uuid,
    required this.referenceNo,
    required this.regionalRegNo,
    required this.name,
    required this.size,
    required this.sizeUnit,
    required this.latitudes,
    required this.longitudes,
    required this.physicalAddress,
    this.villageId,
    required this.wardId,
    required this.districtId,
    required this.regionId,
    required this.countryId,
    required this.legalStatusId,
    this.status = 'active',
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this model with updated fields
  FarmModel copyWith({
    int? id,
    int? farmerId,
    String? uuid,
    String? referenceNo,
    String? regionalRegNo,
    String? name,
    String? size,
    String? sizeUnit,
    String? latitudes,
    String? longitudes,
    String? physicalAddress,
    int? villageId,
    int? wardId,
    int? districtId,
    int? regionId,
    int? countryId,
    int? legalStatusId,
    String? status,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return FarmModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      uuid: uuid ?? this.uuid,
      referenceNo: referenceNo ?? this.referenceNo,
      regionalRegNo: regionalRegNo ?? this.regionalRegNo,
      name: name ?? this.name,
      size: size ?? this.size,
      sizeUnit: sizeUnit ?? this.sizeUnit,
      latitudes: latitudes ?? this.latitudes,
      longitudes: longitudes ?? this.longitudes,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      villageId: villageId ?? this.villageId,
      wardId: wardId ?? this.wardId,
      districtId: districtId ?? this.districtId,
      regionId: regionId ?? this.regionId,
      countryId: countryId ?? this.countryId,
      legalStatusId: legalStatusId ?? this.legalStatusId,
      status: status ?? this.status,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for API (excludes local ID)
  Map<String, dynamic> toApiJson() {
    return {
      'farmerId': farmerId,
      'uuid': uuid,
      'referenceNo': referenceNo,
      'regionalRegNo': regionalRegNo,
      'name': name,
      'size': size,
      'sizeUnit': sizeUnit,
      'latitudes': latitudes,
      'longitudes': longitudes,
      'physicalAddress': physicalAddress,
      'villageId': villageId,
      'wardId': wardId,
      'districtId': districtId,
      'regionId': regionId,
      'countryId': countryId,
      'legalStatusId': legalStatusId,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Convert to JSON (includes local ID)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'uuid': uuid,
      'referenceNo': referenceNo,
      'regionalRegNo': regionalRegNo,
      'name': name,
      'size': size,
      'sizeUnit': sizeUnit,
      'latitudes': latitudes,
      'longitudes': longitudes,
      'physicalAddress': physicalAddress,
      'villageId': villageId,
      'wardId': wardId,
      'districtId': districtId,
      'regionId': regionId,
      'countryId': countryId,
      'legalStatusId': legalStatusId,
      'status': status,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create from JSON
  /// 
  /// Handles both string and numeric inputs for size/latitudes/longitudes
  /// for backward compatibility and API flexibility
  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'] as int,
      farmerId: json['farmerId'] as int,
      uuid: json['uuid'] as String,
      referenceNo: json['referenceNo'] as String,
      regionalRegNo: json['regionalRegNo'] as String,
      name: json['name'] as String,
      size: json['size']?.toString() ?? '0',  // Handle both num and String
      sizeUnit: json['sizeUnit'] as String,
      latitudes: json['latitudes']?.toString() ?? '0',  // Handle both num and String
      longitudes: json['longitudes']?.toString() ?? '0',  // Handle both num and String
      physicalAddress: json['physicalAddress'] as String,
      villageId: json['villageId'] as int?,
      wardId: json['wardId'] as int,
      districtId: json['districtId'] as int,
      regionId: json['regionId'] as int,
      countryId: json['countryId'] as int,
      legalStatusId: json['legalStatusId'] as int,
      status: json['status'] as String? ?? 'active',
      synced: json['synced'] as bool? ?? false,
      syncAction: json['syncAction'] as String? ?? 'create',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FarmModel &&
        other.id == id &&
        other.farmerId == farmerId &&
        other.uuid == uuid &&
        other.referenceNo == referenceNo &&
        other.regionalRegNo == regionalRegNo &&
        other.name == name &&
        other.size == size &&
        other.sizeUnit == sizeUnit &&
        other.latitudes == latitudes &&
        other.longitudes == longitudes &&
        other.physicalAddress == physicalAddress &&
        other.villageId == villageId &&
        other.wardId == wardId &&
        other.districtId == districtId &&
        other.regionId == regionId &&
        other.countryId == countryId &&
        other.legalStatusId == legalStatusId &&
        other.status == status &&
        other.synced == synced &&
        other.syncAction == syncAction &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      farmerId,
      uuid,
      referenceNo,
      regionalRegNo,
      name,
      size,
      sizeUnit,
      latitudes,
      longitudes,
      physicalAddress,
      villageId,
      wardId,
      districtId,
      regionId,
      countryId,
      legalStatusId,
      status,
      synced,
      syncAction,
      createdAt,
      updatedAt,
    ]);
  }

  @override
  String toString() {
    return 'FarmModel(id: $id, farmerId: $farmerId, uuid: $uuid, referenceNo: $referenceNo, regionalRegNo: $regionalRegNo, name: $name, size: $size, sizeUnit: $sizeUnit, latitudes: $latitudes, longitudes: $longitudes, physicalAddress: $physicalAddress, villageId: $villageId, wardId: $wardId, districtId: $districtId, regionId: $regionId, countryId: $countryId, legalStatusId: $legalStatusId, status: $status, synced: $synced, syncAction: $syncAction, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
