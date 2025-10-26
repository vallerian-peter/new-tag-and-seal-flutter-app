class WardModel {
  final int id;
  final String name;
  final int districtId;

  const WardModel({
    required this.id,
    required this.name,
    required this.districtId,
  });

  factory WardModel.fromJson(Map<String, dynamic> json) => WardModel(
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