class LivestockObtainedMethodModel {
  final int? id;
  final String name;

  const LivestockObtainedMethodModel({
    this.id,
    required this.name,
  });

  /// Create a copy of this model with the given fields replaced with new values
  LivestockObtainedMethodModel copyWith({
    int? id,
    String? name,
  }) {
    return LivestockObtainedMethodModel(
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
  factory LivestockObtainedMethodModel.fromJson(Map<String, dynamic> json) {
    return LivestockObtainedMethodModel(
      id: json['id'] as int?,
      name: json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LivestockObtainedMethodModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hashAll([id, name]);

  @override
  String toString() {
    return 'LivestockObtainedMethodModel(id: $id, name: $name)';
  }
}
