class LivestockTypeModel {
  final int? id;
  final String name;

  const LivestockTypeModel({
    this.id,
    required this.name,
  });

  LivestockTypeModel copyWith({
    int? id,
    String? name,
  }) {
    return LivestockTypeModel(
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






