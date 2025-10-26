class SchoolLevelModel {
  final int id;
  final String name;

  SchoolLevelModel({required this.id, required this.name});

  factory SchoolLevelModel.fromJson(Map<String, dynamic> json) {
    return SchoolLevelModel(
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