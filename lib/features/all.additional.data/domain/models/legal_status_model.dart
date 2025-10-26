class LegalStatusModel {
  final int id;
  final String name;

  const LegalStatusModel({
    required this.id,
    required this.name,
  });

  factory LegalStatusModel.fromJson(Map<String, dynamic> json) => LegalStatusModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}