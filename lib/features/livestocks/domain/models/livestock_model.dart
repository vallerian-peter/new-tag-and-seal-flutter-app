/// Livestock domain model representing a livestock entity
class LivestockModel {
  final int id;
  final String farmUuid;  // Farm UUID reference
  final String uuid;
  final String identificationNumber;
  final String dummyTagId;
  final String barcodeTagId;
  final String rfidTagId;
  final int livestockTypeId;
  final String name;
  final String dateOfBirth;
  final String? motherUuid;  // Mother livestock UUID reference
  final String? fatherUuid;  // Father livestock UUID reference
  final String gender;
  final int breedId;
  final int speciesId;
  final String status;
  final int livestockObtainedMethodId;
  final DateTime dateFirstEnteredToFarm;
  final double weightAsOnRegistration;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const LivestockModel({
    required this.id,
    required this.farmUuid,  // Farm UUID
    required this.uuid,
    required this.identificationNumber,
    required this.dummyTagId,
    required this.barcodeTagId,
    required this.rfidTagId,
    required this.livestockTypeId,
    required this.name,
    required this.dateOfBirth,
    this.motherUuid,  // Mother UUID
    this.fatherUuid,  // Father UUID
    required this.gender,
    required this.breedId,
    required this.speciesId,
    this.status = 'active',
    required this.livestockObtainedMethodId,
    required this.dateFirstEnteredToFarm,
    required this.weightAsOnRegistration,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this model with updated fields
  LivestockModel copyWith({
    int? id,
    String? farmUuid,  // Farm UUID
    String? uuid,
    String? identificationNumber,
    String? dummyTagId,
    String? barcodeTagId,
    String? rfidTagId,
    int? livestockTypeId,
    String? name,
    String? dateOfBirth,
    String? motherUuid,  // Mother UUID
    String? fatherUuid,  // Father UUID
    String? gender,
    int? breedId,
    int? speciesId,
    String? status,
    int? livestockObtainedMethodId,
    DateTime? dateFirstEnteredToFarm,
    double? weightAsOnRegistration,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return LivestockModel(
      id: id ?? this.id,
      farmUuid: farmUuid ?? this.farmUuid,
      uuid: uuid ?? this.uuid,
      identificationNumber: identificationNumber ?? this.identificationNumber,
      dummyTagId: dummyTagId ?? this.dummyTagId,
      barcodeTagId: barcodeTagId ?? this.barcodeTagId,
      rfidTagId: rfidTagId ?? this.rfidTagId,
      livestockTypeId: livestockTypeId ?? this.livestockTypeId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      motherUuid: motherUuid ?? this.motherUuid,
      fatherUuid: fatherUuid ?? this.fatherUuid,
      gender: gender ?? this.gender,
      breedId: breedId ?? this.breedId,
      speciesId: speciesId ?? this.speciesId,
      status: status ?? this.status,
      livestockObtainedMethodId: livestockObtainedMethodId ?? this.livestockObtainedMethodId,
      dateFirstEnteredToFarm: dateFirstEnteredToFarm ?? this.dateFirstEnteredToFarm,
      weightAsOnRegistration: weightAsOnRegistration ?? this.weightAsOnRegistration,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for API (excludes local ID)
  Map<String, dynamic> toApiJson() {
    return {
      'farmUuid': farmUuid,
      'uuid': uuid,
      'identificationNumber': identificationNumber,
      'dummyTagId': dummyTagId,
      'barcodeTagId': barcodeTagId,
      'rfidTagId': rfidTagId,
      'livestockTypeId': livestockTypeId,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'motherUuid': motherUuid,
      'fatherUuid': fatherUuid,
      'gender': gender,
      'breedId': breedId,
      'speciesId': speciesId,
      'status': status,
      'livestockObtainedMethodId': livestockObtainedMethodId,
      'dateFirstEnteredToFarm': dateFirstEnteredToFarm.toIso8601String(),
      'weightAsOnRegistration': weightAsOnRegistration,
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
      'farmUuid': farmUuid,
      'uuid': uuid,
      'identificationNumber': identificationNumber,
      'dummyTagId': dummyTagId,
      'barcodeTagId': barcodeTagId,
      'rfidTagId': rfidTagId,
      'livestockTypeId': livestockTypeId,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'motherUuid': motherUuid,
      'fatherUuid': fatherUuid,
      'gender': gender,
      'breedId': breedId,
      'speciesId': speciesId,
      'status': status,
      'livestockObtainedMethodId': livestockObtainedMethodId,
      'dateFirstEnteredToFarm': dateFirstEnteredToFarm.toIso8601String(),
      'weightAsOnRegistration': weightAsOnRegistration,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create from JSON
  factory LivestockModel.fromJson(Map<String, dynamic> json) {
    return LivestockModel(
      id: json['id'] as int,
      farmUuid: json['farmUuid'] as String,  // Farm UUID
      uuid: json['uuid'] as String,
      identificationNumber: json['identificationNumber'] as String,
      dummyTagId: json['dummyTagId'] as String,
      barcodeTagId: json['barcodeTagId'] as String,
      rfidTagId: json['rfidTagId'] as String,
      livestockTypeId: json['livestockTypeId'] as int,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      motherUuid: json['motherUuid'] as String?,  // Mother UUID
      fatherUuid: json['fatherUuid'] as String?,  // Father UUID
      gender: json['gender'] as String,
      breedId: json['breedId'] as int,
      speciesId: json['speciesId'] as int,
      status: json['status'] as String? ?? 'active',
      livestockObtainedMethodId: json['livestockObtainedMethodId'] as int,
      dateFirstEnteredToFarm: DateTime.parse(json['dateFirstEnteredToFarm'] as String),
      weightAsOnRegistration: (json['weightAsOnRegistration'] as num).toDouble(),
      synced: json['synced'] as bool? ?? false,
      syncAction: json['syncAction'] as String? ?? 'create',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LivestockModel &&
        other.id == id &&
        other.farmUuid == farmUuid &&
        other.uuid == uuid &&
        other.identificationNumber == identificationNumber &&
        other.dummyTagId == dummyTagId &&
        other.barcodeTagId == barcodeTagId &&
        other.rfidTagId == rfidTagId &&
        other.livestockTypeId == livestockTypeId &&
        other.name == name &&
        other.dateOfBirth == dateOfBirth &&
        other.motherUuid == motherUuid &&
        other.fatherUuid == fatherUuid &&
        other.gender == gender &&
        other.breedId == breedId &&
        other.speciesId == speciesId &&
        other.status == status &&
        other.livestockObtainedMethodId == livestockObtainedMethodId &&
        other.dateFirstEnteredToFarm == dateFirstEnteredToFarm &&
        other.weightAsOnRegistration == weightAsOnRegistration &&
        other.synced == synced &&
        other.syncAction == syncAction &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      farmUuid,
      uuid,
      identificationNumber,
      dummyTagId,
      barcodeTagId,
      rfidTagId,
      livestockTypeId,
      name,
      dateOfBirth,
      motherUuid,
      fatherUuid,
      gender,
      breedId,
      speciesId,
      status,
      livestockObtainedMethodId,
      dateFirstEnteredToFarm,
      weightAsOnRegistration,
      synced,
      syncAction,
      createdAt,
      updatedAt,
    ]);
  }

  @override
  String toString() {
    return 'LivestockModel(id: $id, farmUuid: $farmUuid, uuid: $uuid, identificationNumber: $identificationNumber, dummyTagId: $dummyTagId, barcodeTagId: $barcodeTagId, rfidTagId: $rfidTagId, livestockTypeId: $livestockTypeId, name: $name, dateOfBirth: $dateOfBirth, motherUuid: $motherUuid, fatherUuid: $fatherUuid, gender: $gender, breedId: $breedId, speciesId: $speciesId, status: $status, livestockObtainedMethodId: $livestockObtainedMethodId, dateFirstEnteredToFarm: $dateFirstEnteredToFarm, weightAsOnRegistration: $weightAsOnRegistration, synced: $synced, syncAction: $syncAction, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
