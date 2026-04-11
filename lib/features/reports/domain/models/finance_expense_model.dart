class FinanceExpenseModel {
  final int? id;
  final String uuid;
  final String sourceType;
  final String sourceUuid;
  final String? farmUuid;
  final int? farmerId;
  final String? billNo;
  final String? subjectType;
  final int quantity;
  final String unitCost;
  final String totalCost;
  final String status;
  final String? notes;
  final String? expenseDate;
  final String createdAt;
  final String updatedAt;

  const FinanceExpenseModel({
    this.id,
    required this.uuid,
    required this.sourceType,
    required this.sourceUuid,
    this.farmUuid,
    this.farmerId,
    this.billNo,
    this.subjectType,
    this.quantity = 1,
    required this.unitCost,
    required this.totalCost,
    this.status = 'pending',
    this.notes,
    this.expenseDate,
    required this.createdAt,
    required this.updatedAt,
  });
}
