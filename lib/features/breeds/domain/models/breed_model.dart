class BreedModel {
  final int? id;
  final String name;
  final String group;
  final int livestockTypeId;

  const BreedModel({
    this.id,
    required this.name,
    required this.group,
    required this.livestockTypeId,
  });

  /// Create a copy of this model with the given fields replaced with new values
  BreedModel copyWith({
    int? id,
    String? name,
    String? group,
    int? livestockTypeId,
  }) {
    return BreedModel(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      livestockTypeId: livestockTypeId ?? this.livestockTypeId,
    );
  }

  /// Convert to JSON for API (excludes local ID)
  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
      'group': group,
      'livestockTypeId': livestockTypeId,
    };
  }

  /// Convert to JSON (includes local ID)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'group': group,
      'livestockTypeId': livestockTypeId,
    };
  }

  /// Create from JSON
  factory BreedModel.fromJson(Map<String, dynamic> json) {
    return BreedModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      group: json['group'] as String,
      livestockTypeId: json['livestockTypeId'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BreedModel && 
           other.id == id && 
           other.name == name && 
           other.group == group && 
           other.livestockTypeId == livestockTypeId;
  }

  @override
  int get hashCode => Object.hashAll([id, name, group, livestockTypeId]);

  @override
  String toString() {
    return 'BreedModel(id: $id, name: $name, group: $group, livestockTypeId: $livestockTypeId)';
  }
}
