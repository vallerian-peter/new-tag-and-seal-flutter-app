class LivestockMarkingType {
  final int id;
  final String name;

  const LivestockMarkingType({required this.id, required this.name});

  factory LivestockMarkingType.fromJson(Map<String, dynamic> json) {
    return LivestockMarkingType(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
