class IdentityCardTypeModel {
  final int id;
  final String name;

  IdentityCardTypeModel({required this.id, required this.name});

  factory IdentityCardTypeModel.fromJson(Map<String, dynamic> json) {
    return IdentityCardTypeModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}