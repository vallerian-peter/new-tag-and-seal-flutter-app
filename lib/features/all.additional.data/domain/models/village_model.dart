/// Village domain model
class VillageModel {
  final int id;
  final String name;
  final int wardId;

  VillageModel({
    required this.id,
    required this.name,
    required this.wardId,
  });

  /// Create VillageModel from JSON
  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      wardId: json['wardId'] as int? ?? 0,
    );
  }

  /// Convert VillageModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'wardId': wardId,
    };
  }
}
