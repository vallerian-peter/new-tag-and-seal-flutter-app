class Disease {
  final int id;
  final String name;
  final String? status;

  const Disease({required this.id, required this.name, this.status});

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      status: json['status'] as String?,
    );
  }
}
