class ReproductiveProblem {
  final int id;
  final String name;

  const ReproductiveProblem({required this.id, required this.name});

  factory ReproductiveProblem.fromJson(Map<String, dynamic> json) {
    return ReproductiveProblem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
