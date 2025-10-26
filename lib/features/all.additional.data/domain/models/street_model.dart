class StreetModel {
  final int id;
  final String name;
  final int wardId;

  const StreetModel({
    required this.id,
    required this.name,
    required this.wardId,
  });

  factory StreetModel.fromJson(Map<String, dynamic> json) => StreetModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    wardId: json['wardId'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'wardId': wardId,
  };
}