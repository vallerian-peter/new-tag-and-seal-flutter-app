class CountryModel {
  final int id;
  final String name;
  final String shortName;

  const CountryModel({
    required this.id,
    required this.name,
    required this.shortName,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    shortName: json['shortName'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'shortName': shortName,
  };
}