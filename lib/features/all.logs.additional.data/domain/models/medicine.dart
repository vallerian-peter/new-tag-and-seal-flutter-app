class Medicine {
  final int id;
  final String name;
  final int? medicineTypeId;

  const Medicine({required this.id, required this.name, this.medicineTypeId});

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      medicineTypeId:
          json['medicineTypeId'] as int? ?? json['medicine_type_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'medicineTypeId': medicineTypeId};
  }
}
