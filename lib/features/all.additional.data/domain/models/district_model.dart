class DistrictModel {
  final int id;
  final String name;
  final int regionId;

  const DistrictModel({
    required this.id,
    required this.name,
    required this.regionId,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    regionId: json['regionId'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'regionId': regionId,
  };
}