class VaccineTypeModel {
  final int id;
  final String name;

  const VaccineTypeModel({
    required this.id,
    required this.name,
  });

  factory VaccineTypeModel.fromJson(Map<String, dynamic> json) {
    return VaccineTypeModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}

