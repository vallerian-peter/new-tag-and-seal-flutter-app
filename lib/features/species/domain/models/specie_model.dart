class SpecieModel {
  final int? id;
  final String name;

  const SpecieModel({
    this.id,
    required this.name,
  });

  /// Create a copy of this model with the given fields replaced with new values
  SpecieModel copyWith({
    int? id,
    String? name,
  }) {
    return SpecieModel(
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
  factory SpecieModel.fromJson(Map<String, dynamic> json) {
    return SpecieModel(
      id: json['id'] as int?,
      name: json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpecieModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hashAll([id, name]);

  @override
  String toString() {
    return 'SpecieModel(id: $id, name: $name)';
  }
}
