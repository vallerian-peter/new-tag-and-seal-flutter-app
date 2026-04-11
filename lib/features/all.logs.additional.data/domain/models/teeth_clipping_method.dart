class TeethClippingMethod {
  final int id;
  final String name;

  const TeethClippingMethod({required this.id, required this.name});

  factory TeethClippingMethod.fromJson(Map<String, dynamic> json) {
    return TeethClippingMethod(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

