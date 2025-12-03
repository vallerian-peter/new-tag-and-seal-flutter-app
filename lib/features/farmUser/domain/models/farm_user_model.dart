class FarmUserModel {
  final int? id;
  final String uuid;
  final List<String> farmUuids; // Multiple farm UUIDs
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? phone;
  final String email;
  final String roleTitle;
  final String gender;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const FarmUserModel({
    this.id,
    required this.uuid,
    this.farmUuids = const [], // Multiple farms
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.phone,
    required this.email,
    required this.roleTitle,
    required this.gender,
    required this.synced,
    required this.syncAction,
    required this.createdAt,
    required this.updatedAt,
  });

  // Legacy support: get first farm UUID (for backward compatibility)
  String get farmUuid => farmUuids.isNotEmpty ? farmUuids[0] : '';

  String get fullName =>
      [firstName, if (middleName != null && middleName!.trim().isNotEmpty) middleName, lastName]
          .whereType<String>()
          .join(' ');

  FarmUserModel copyWith({
    int? id,
    String? uuid,
    List<String>? farmUuids,
    String? firstName,
    String? middleName,
    String? lastName,
    String? phone,
    String? email,
    String? roleTitle,
    String? gender,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return FarmUserModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      farmUuids: farmUuids ?? this.farmUuids,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      roleTitle: roleTitle ?? this.roleTitle,
      gender: gender ?? this.gender,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FarmUserModel.fromJson(Map<String, dynamic> json) {
    // Handle farmUuids (new format) or farmUuid (legacy)
    List<String> farmUuids = [];

    if (json['farmUuids'] != null && json['farmUuids'] is List) {
      // New format: array of farm UUIDs
      farmUuids = List<String>.from(json['farmUuids']).where((u) => u.isNotEmpty).toList();
    } else if (json['farmUuid'] != null) {
      // Legacy format: single farm UUID (convert to array)
      final farmUuid = json['farmUuid'].toString();
      if (farmUuid.isNotEmpty) {
        farmUuids = [farmUuid];
      }
    }

    return FarmUserModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      farmUuids: farmUuids,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      roleTitle: json['roleTitle'] as String,
      gender: json['gender'] as String,
      synced: (json['synced'] as bool?) ?? true,
      syncAction: (json['syncAction'] as String?) ?? 'server-create',
      createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? json['updated_at'] ?? json['createdAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'farmUuid': farmUuid, // Legacy support: first farm UUID
      'farmUuids': farmUuids, // New format: array of UUIDs
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'roleTitle': roleTitle,
      'gender': gender,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}


