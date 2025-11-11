class CalvingType {
  final int id;
  final String name;

  const CalvingType({required this.id, required this.name});

  factory CalvingType.fromJson(Map<String, dynamic> json) {
    return CalvingType(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
