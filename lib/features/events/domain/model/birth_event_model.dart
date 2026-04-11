class BirthEventModel {
  final int? id;
  final String uuid;
  final String farmUuid;
  final String livestockUuid;
  final String eventType; // 'calving' or 'farrowing'
  final String startDate;
  final String? endDate;
  final int birthTypeId; // Renamed from calvingTypeId
  final int? birthProblemsId; // Renamed from calvingProblemsId
  final int? reproductiveProblemId;
  final String? remarks;
  final int? totalBorn;
  final int? aliveCount;
  final int? deadCount;
  final String status;
  final String? eventDate;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const BirthEventModel({
    this.id,
    required this.uuid,
    required this.farmUuid,
    required this.livestockUuid,
    required this.eventType,
    required this.startDate,
    this.endDate,
    required this.birthTypeId,
    this.birthProblemsId,
    this.reproductiveProblemId,
    this.remarks,
    this.totalBorn,
    this.aliveCount,
    this.deadCount,
    this.status = 'active',
    this.eventDate,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the event name based on eventType
  String getEventName() {
    return eventType == 'farrowing' ? 'Farrowing' : 'Calving';
  }

  /// Get the offspring name based on eventType
  String getOffspringName() {
    return eventType == 'farrowing' ? 'Piglet' : 'Calf';
  }

  BirthEventModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    String? eventType,
    String? startDate,
    String? endDate,
    int? birthTypeId,
    int? birthProblemsId,
    int? reproductiveProblemId,
    String? remarks,
    int? totalBorn,
    int? aliveCount,
    int? deadCount,
    String? status,
    String? eventDate,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return BirthEventModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      eventType: eventType ?? this.eventType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      birthTypeId: birthTypeId ?? this.birthTypeId,
      birthProblemsId: birthProblemsId ?? this.birthProblemsId,
      reproductiveProblemId:
          reproductiveProblemId ?? this.reproductiveProblemId,
      remarks: remarks ?? this.remarks,
      totalBorn: totalBorn ?? this.totalBorn,
      aliveCount: aliveCount ?? this.aliveCount,
      deadCount: deadCount ?? this.deadCount,
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
      'eventType': eventType,
      'startDate': startDate,
      'endDate': endDate,
      'birthTypeId': birthTypeId,
      'birthProblemsId': birthProblemsId,
      'reproductiveProblemId': reproductiveProblemId,
      'remarks': remarks,
      'totalBorn': totalBorn,
      'aliveCount': aliveCount,
      'deadCount': deadCount,
      'status': status,
      'eventDate': eventDate,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory BirthEventModel.fromJson(Map<String, dynamic> json) {
    return BirthEventModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      eventType: json['eventType'] as String? ?? 'calving', // Default to calving for backward compatibility
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
      birthTypeId: (json['birthTypeId'] as int?) ?? 
                   (json['calvingTypeId'] as int?) ?? 
                   0, // Support both field names for migration, default to 0 if missing
      birthProblemsId: (json['birthProblemsId'] as int?) ?? 
                              (json['calvingProblemsId'] as int?), // Support both field names for migration
      reproductiveProblemId: json['reproductiveProblemId'] as int?,
      remarks: json['remarks'] as String?,
      totalBorn: (json['totalBorn'] as num?)?.toInt(),
      aliveCount: (json['aliveCount'] as num?)?.toInt(),
      deadCount: (json['deadCount'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'active',
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
      'eventType': eventType,
      'startDate': startDate,
      'endDate': endDate,
      'birthTypeId': birthTypeId,
      'birthProblemsId': birthProblemsId,
      'reproductiveProblemId': reproductiveProblemId,
      'remarks': remarks,
      'totalBorn': totalBorn,
      'aliveCount': aliveCount,
      'deadCount': deadCount,
      'status': status,
      'eventDate': eventDate,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Convert from old CalvingModel (for migration)
  factory BirthEventModel.fromCalvingModel(
    dynamic calvingModel, {
    String? eventType,
  }) {
    // Try to determine eventType from livestock if not provided
    String determinedEventType = eventType ?? 'calving';

    return BirthEventModel(
      id: calvingModel.id,
      uuid: calvingModel.uuid,
      farmUuid: calvingModel.farmUuid,
      livestockUuid: calvingModel.livestockUuid,
      eventType: determinedEventType,
      startDate: calvingModel.startDate,
      endDate: calvingModel.endDate,
      birthTypeId: calvingModel.calvingTypeId,
      birthProblemsId: calvingModel.calvingProblemsId,
      reproductiveProblemId: calvingModel.reproductiveProblemId,
      remarks: calvingModel.remarks,
      status: calvingModel.status,
      synced: calvingModel.synced,
      syncAction: calvingModel.syncAction,
      createdAt: calvingModel.createdAt,
      updatedAt: calvingModel.updatedAt,
    );
  }
}

