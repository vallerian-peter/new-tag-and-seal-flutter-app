class FinanceIncomeModel {
  final int? id;
  final String uuid;
  final String? sourceType;
  final String? sourceUuid;
  final String? farmUuid;
  final int? farmerId;
  final String? referenceNo;
  final String? subjectType;
  final int quantity;
  final String unitAmount;
  final String totalAmount;
  final String status;
  final String? notes;
  final String? incomeDate;
  final String createdAt;
  final String updatedAt;
  final bool synced;
  final String syncAction;

  const FinanceIncomeModel({
    this.id,
    required this.uuid,
    this.sourceType,
    this.sourceUuid,
    this.farmUuid,
    this.farmerId,
    this.referenceNo,
    this.subjectType,
    this.quantity = 1,
    required this.unitAmount,
    required this.totalAmount,
    this.status = 'pending',
    this.notes,
    this.incomeDate,
    required this.createdAt,
    required this.updatedAt,
    this.synced = true,
    this.syncAction = 'server-create',
  });
}
