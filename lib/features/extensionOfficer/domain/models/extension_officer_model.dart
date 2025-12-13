class ExtensionOfficerModel {
  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String? phone;
  final String? specialization;

  const ExtensionOfficerModel({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    this.phone,
    this.specialization,
  });

  String get fullName =>
      [firstName, if (middleName != null && middleName!.trim().isNotEmpty) middleName, lastName]
          .whereType<String>()
          .join(' ');

  factory ExtensionOfficerModel.fromJson(Map<String, dynamic> json) {
    return ExtensionOfficerModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      specialization: json['specialization'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'specialization': specialization,
    };
  }
}

