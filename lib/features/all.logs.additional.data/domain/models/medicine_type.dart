class MedicineType {
  final int id;
  final String name;

  const MedicineType({required this.id, required this.name});

  factory MedicineType.fromJson(Map<String, dynamic> json) {
    return MedicineType(id: json['id'] as int, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
