class LivestockObtainedMethodModel {
  final int? id;
  final String name;

  const LivestockObtainedMethodModel({
    this.id,
    required this.name,
  });

  LivestockObtainedMethodModel copyWith({
    int? id,
    String? name,
  }) {
    return LivestockObtainedMethodModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

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






