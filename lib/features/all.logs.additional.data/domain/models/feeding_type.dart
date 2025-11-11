class FeedingType {
  final int id;
  final String name;

  FeedingType({required this.id, required this.name});

  factory FeedingType.fromJson(Map<String, dynamic> json) {
    return FeedingType(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
