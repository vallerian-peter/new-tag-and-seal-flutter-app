class DisposalType {
  final int id;
  final String name;

  const DisposalType({required this.id, required this.name});

  factory DisposalType.fromJson(Map<String, dynamic> json) {
    return DisposalType(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}
