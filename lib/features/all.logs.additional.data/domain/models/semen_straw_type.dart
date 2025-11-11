class SemenStrawType {
  final int id;
  final String name;
  final String? category;

  const SemenStrawType({required this.id, required this.name, this.category});

  factory SemenStrawType.fromJson(Map<String, dynamic> json) {
    return SemenStrawType(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'category': category};
  }
}
