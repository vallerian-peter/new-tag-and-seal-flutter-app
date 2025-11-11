class MilkingMethod {
  final int id;
  final String name;

  const MilkingMethod({required this.id, required this.name});

  factory MilkingMethod.fromJson(Map<String, dynamic> json) {
    return MilkingMethod(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
