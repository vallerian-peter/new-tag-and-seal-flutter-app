class TailDockingMethod {
  final int id;
  final String name;

  const TailDockingMethod({required this.id, required this.name});

  factory TailDockingMethod.fromJson(Map<String, dynamic> json) {
    return TailDockingMethod(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
