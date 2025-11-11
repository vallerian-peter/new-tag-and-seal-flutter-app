class TestResult {
  final int id;
  final String name;

  const TestResult({required this.id, required this.name});

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
