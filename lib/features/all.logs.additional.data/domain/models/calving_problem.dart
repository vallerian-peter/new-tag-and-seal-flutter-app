class CalvingProblem {
  final int id;
  final String name;

  const CalvingProblem({required this.id, required this.name});

  factory CalvingProblem.fromJson(Map<String, dynamic> json) {
    return CalvingProblem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
