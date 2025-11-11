class AdministrationRoute {
  final int id;
  final String name;

  const AdministrationRoute({required this.id, required this.name});

  factory AdministrationRoute.fromJson(Map<String, dynamic> json) {
    return AdministrationRoute(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
