class BillModel {
  final int? id;
  final String uuid;
  final String? billNo;
  final String? farmUuid;
  final int? extensionOfficerId;
  final int? farmerId;
  final String? subjectType;
  final String? subjectUuid;
  final int quantity;
  final String amount;
  final String? status;
  final String? notes;
  final bool synced;
  final String syncAction;
  final String createdAt;
  final String updatedAt;

  const BillModel({
    this.id,
    required this.uuid,
    this.billNo,
    this.farmUuid,
    this.extensionOfficerId,
    this.farmerId,
    this.subjectType,
    this.subjectUuid,
    this.quantity = 1,
    required this.amount,
    this.status,
    this.notes,
    this.synced = true,
    this.syncAction = 'server-create',
    required this.createdAt,
    required this.updatedAt,
  });

  BillModel copyWith({
    int? id,
    String? uuid,
    String? billNo,
    String? farmUuid,
    int? extensionOfficerId,
    int? farmerId,
    String? subjectType,
    String? subjectUuid,
    int? quantity,
    String? amount,
    String? status,
    String? notes,
    bool? synced,
    String? syncAction,
    String? createdAt,
    String? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      billNo: billNo ?? this.billNo,
      farmUuid: farmUuid ?? this.farmUuid,
      extensionOfficerId: extensionOfficerId ?? this.extensionOfficerId,
      farmerId: farmerId ?? this.farmerId,
      subjectType: subjectType ?? this.subjectType,
      subjectUuid: subjectUuid ?? this.subjectUuid,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      synced: synced ?? this.synced,
      syncAction: syncAction ?? this.syncAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      billNo: json['billNo'] as String?,
      farmUuid: json['farmUuid'] as String?,
      extensionOfficerId: json['extensionOfficerId'] is int
          ? json['extensionOfficerId'] as int
          : int.tryParse('${json['extensionOfficerId']}'),
      farmerId: json['farmerId'] is int
          ? json['farmerId'] as int
          : int.tryParse('${json['farmerId']}'),
      subjectType: json['subjectType'] as String?,
      subjectUuid: json['subjectUuid'] as String?,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse('${json['quantity']}') ?? 1,
      amount: (json['amount'] ?? '').toString(),
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      synced: json['synced'] is bool ? json['synced'] as bool : true,
      syncAction: json['syncAction'] as String? ?? 'server-create',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'billNo': billNo,
      'farmUuid': farmUuid,
      'extensionOfficerId': extensionOfficerId,
      'farmerId': farmerId,
      'subjectType': subjectType,
      'subjectUuid': subjectUuid,
      'quantity': quantity,
      'amount': amount,
      'status': status,
      'notes': notes,
      'synced': synced,
      'syncAction': syncAction,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
