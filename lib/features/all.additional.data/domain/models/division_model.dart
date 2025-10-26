class DivisionModel {
  final int id;
  final String name;
  final int districtId;

  const DivisionModel({
    required this.id,
    required this.name,
    required this.districtId,
  });

  factory DivisionModel.fromJson(Map<String, dynamic> json) => DivisionModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    districtId: json['districtId'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'districtId': districtId,
  };
}

