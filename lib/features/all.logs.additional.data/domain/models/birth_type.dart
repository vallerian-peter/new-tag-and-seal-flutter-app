class BirthType {
  final int id;
  final String name;
  final int? livestockTypeId; // null = generic, applies to all types

  const BirthType({
    required this.id,
    required this.name,
    this.livestockTypeId,
  });

  factory BirthType.fromJson(Map<String, dynamic> json) {
    return BirthType(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      livestockTypeId: json['livestockTypeId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'livestockTypeId': livestockTypeId,
    };
  }

  /// Check if this birth type is generic (applies to all livestock types)
  bool get isGeneric => livestockTypeId == null;

  /// Check if this birth type applies to a specific livestock type
  bool appliesToLivestockType(int? livestockTypeId) {
    if (isGeneric) return true; // Generic types apply to all
    return this.livestockTypeId == livestockTypeId;
  }
}

