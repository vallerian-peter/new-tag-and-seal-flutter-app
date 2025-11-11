//  'uuid',
// 'feedingTypeId',
// 'farmUuid',
// 'livestockUuid',
// 'nextFeedingTime',
// 'amount',
// 'remarks',
// 'synced',
// 'syncAction',
// 'createdAt',
// 'updatedAt',

class FeedingModel {
  final int? id;
  final String uuid;
  final int feedingTypeId;
  final String farmUuid;
  final String livestockUuid;
  final String nextFeedingTime;
  final String amount;
  final String? remarks;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  FeedingModel({
    this.id,
    required this.uuid,
    required this.feedingTypeId,
    required this.farmUuid,
    required this.livestockUuid,
    required this.nextFeedingTime,
    required this.amount,
    this.remarks,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  FeedingModel copyWith({
    int? id,
    int? feedingTypeId,
    String? farmUuid,
    String? livestockUuid,
    String? nextFeedingTime,
    String? amount,
    String? remarks,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return FeedingModel(
      id: id ?? this.id,
      uuid: uuid,
      feedingTypeId: feedingTypeId ?? this.feedingTypeId,
      farmUuid: farmUuid ?? this.farmUuid,
      livestockUuid: livestockUuid ?? this.livestockUuid,
      nextFeedingTime: nextFeedingTime ?? this.nextFeedingTime,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
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
      'feedingTypeId': feedingTypeId,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'nextFeedingTime': nextFeedingTime,
      'amount': amount,
      'remarks': remarks,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory FeedingModel.fromJson(Map<String, dynamic> json) {
    return FeedingModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      feedingTypeId: json['feedingTypeId'] as int,
      farmUuid: json['farmUuid'] as String,
      livestockUuid: json['livestockUuid'] as String,
      nextFeedingTime: json['nextFeedingTime'] as String,
      amount: json['amount'] as String,
      remarks: json['remarks'] as String?,
      synced: (json['synced'] as bool?) ?? true,
      syncAction: json['syncAction'] as String? ?? 'create',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'uuid': uuid,
      'feedingTypeId': feedingTypeId,
      'farmUuid': farmUuid,
      'livestockUuid': livestockUuid,
      'nextFeedingTime': nextFeedingTime,
      'amount': amount,
      'remarks': remarks,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
