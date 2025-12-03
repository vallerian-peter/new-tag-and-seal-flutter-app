class BirthProblem {
  final int id;
  final String name;
  final int? livestockTypeId; // null = generic, applies to all types

  const BirthProblem({
    required this.id,
    required this.name,
    this.livestockTypeId,
  });

  factory BirthProblem.fromJson(Map<String, dynamic> json) {
    return BirthProblem(
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

  /// Check if this birth problem is generic (applies to all livestock types)
  bool get isGeneric => livestockTypeId == null;

  /// Check if this birth problem applies to a specific livestock type
  bool appliesToLivestockType(int? livestockTypeId) {
    if (isGeneric) return true; // Generic problems apply to all
    return this.livestockTypeId == livestockTypeId;
  }
}

