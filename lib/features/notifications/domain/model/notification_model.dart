class NotificationModel {
  final int? id;
  final String? farmUuid;
  final String? farmName;
  final String? livestockUuid;
  final String? livestockName;
  final String title;
  final String? description;
  final String scheduledAt;
  final bool isCompleted;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const NotificationModel({
    this.id,
    this.farmUuid,
    this.farmName,
    this.livestockUuid,
    this.livestockName,
    required this.title,
    this.description,
    required this.scheduledAt,
    this.isCompleted = false,
    this.synced = false,
    this.syncAction = 'create',
    required this.createdAt,
    required this.updatedAt,
  });

  NotificationModel copyWith({
    Object? id = _unset,
    Object? farmUuid = _unset,
    Object? farmName = _unset,
    Object? livestockUuid = _unset,
    Object? livestockName = _unset,
    String? title,
    Object? description = _unset,
    String? scheduledAt,
    bool? isCompleted,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationModel(
      id: identical(id, _unset) ? this.id : id as int?,
      farmUuid:
          identical(farmUuid, _unset) ? this.farmUuid : farmUuid as String?,
      farmName:
          identical(farmName, _unset) ? this.farmName : farmName as String?,
      livestockUuid: identical(livestockUuid, _unset)
          ? this.livestockUuid
          : livestockUuid as String?,
      livestockName: identical(livestockName, _unset)
          ? this.livestockName
          : livestockName as String?,
      title: title ?? this.title,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isCompleted: isCompleted ?? this.isCompleted,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmUuid': farmUuid,
      'farmName': farmName,
      'livestockUuid': livestockUuid,
      'livestockName': livestockName,
      'title': title,
      'description': description,
      'scheduledAt': scheduledAt,
      'isCompleted': isCompleted,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      farmUuid: json['farmUuid'] as String?,
      farmName: json['farmName'] as String?,
      livestockUuid: json['livestockUuid'] as String?,
      livestockName: json['livestockName'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledAt: json['scheduledAt'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      synced: json['synced'] as bool? ?? false,
      syncAction: json['syncAction'] as String? ?? 'create',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toApiJson() => toJson();
}

const Object _unset = Object();

