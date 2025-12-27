

class WeightChangeModel {
    final int? id;
    final String uuid;
    final String farmUuid;
    final String livestockUuid;
  final String? oldWeight;
    final String newWeight;
  final String? remarks;
  final String? eventDate;
    final bool synced;
    final String syncAction;
    final String createdAt;
    final String updatedAt; 
    
    WeightChangeModel({
      this.id,
      required this.uuid,
      required this.farmUuid,
      required this.livestockUuid,
    this.oldWeight,
      required this.newWeight,
    this.remarks,
    this.eventDate,
      this.synced = false,
      this.syncAction = 'create',
      required this.createdAt,
      required this.updatedAt,
    });

  WeightChangeModel copyWith({
    int? id,
    String? farmUuid,
    String? livestockUuid,
    String? oldWeight,
    String? newWeight,
    String? remarks,
    String? eventDate,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return WeightChangeModel(
      id: id ?? this.id,
      uuid: uuid,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      oldWeight: oldWeight ?? this.oldWeight,
      newWeight: newWeight ?? this.newWeight,
      remarks: remarks ?? this.remarks,
      eventDate: eventDate ?? this.eventDate,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WeightChangeModel.fromJson(Map<String, dynamic> json) {
      return WeightChangeModel(
        id: json['id'] as int?,
        uuid: json['uuid'] as String,
        farmUuid: json['farmUuid'] as String,
        livestockUuid: json['livestockUuid'] as String,
      oldWeight: json['oldWeight'] as String?,
        newWeight: json['newWeight'] as String,
      remarks: json['remarks'] as String?,
      eventDate: json['eventDate'] as String?,
      synced: (json['synced'] as bool?) ?? true,
      syncAction: json['syncAction'] as String? ?? 'create',
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
    } 

    Map<String, dynamic> toJson() { 
      return {
        'id': id,
        'uuid': uuid,
        'farmUuid': farmUuid,
        'livestockUuid': livestockUuid,
        'oldWeight': oldWeight,
        'newWeight': newWeight,
        'remarks': remarks,
        'eventDate': eventDate,
        'synced': synced,
        'syncAction': syncAction,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
    }

  Map<String, dynamic> toApiJson() {
    return {
      'uuid': uuid,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'oldWeight': oldWeight,
      'newWeight': newWeight,
      'remarks': remarks,
      'eventDate': eventDate,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
