class HeatType {
  final int id;
  final String name;

  const HeatType({required this.id, required this.name});

  factory HeatType.fromJson(Map<String, dynamic> json) {
    return HeatType(id: json['id'] as int, name: json['name'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
