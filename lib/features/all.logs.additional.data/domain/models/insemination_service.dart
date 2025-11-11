class InseminationService {
  final int id;
  final String name;

  const InseminationService({required this.id, required this.name});

  factory InseminationService.fromJson(Map<String, dynamic> json) {
    return InseminationService(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
