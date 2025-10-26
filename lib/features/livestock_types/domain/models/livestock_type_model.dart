class LivestockTypeModel {
  final int? id;
  final String name;

  const LivestockTypeModel({
    this.id,
    required this.name,
  });

  /// Create a copy of this model with the given fields replaced with new values
  LivestockTypeModel copyWith({
    int? id,
    String? name,
  }) {
    return LivestockTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  /// Convert to JSON for API (excludes local ID)
  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
    };
  }

  /// Convert to JSON (includes local ID)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Create from JSON
  factory LivestockTypeModel.fromJson(Map<String, dynamic> json) {
    return LivestockTypeModel(
      id: json['id'] as int?,
      name: json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LivestockTypeModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hashAll([id, name]);

  @override
  String toString() {
    return 'LivestockTypeModel(id: $id, name: $name)';
  }
}
