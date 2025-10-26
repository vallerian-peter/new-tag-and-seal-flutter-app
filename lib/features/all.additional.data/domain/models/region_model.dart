class RegionModel {
  final int id;
  final String name;
  final String shortName;
  final int countryId;

  const RegionModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.countryId,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    shortName: json['shortName'] ?? '',
    countryId: json['countryId'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'shortName': shortName,
    'countryId': countryId,
  };
}