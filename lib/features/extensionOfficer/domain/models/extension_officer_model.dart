class ExtensionOfficerModel {
  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String? phone;
  final String? specialization;
  final String? organization;
  final int? countryId;
  final int? regionId;
  final int? districtId;
  final int? wardId;
  final bool? isVerified;

  const ExtensionOfficerModel({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    this.phone,
    this.specialization,
    this.organization,
    this.countryId,
    this.regionId,
    this.districtId,
    this.wardId,
    this.isVerified,
  });

  String get fullName => [
    firstName,
    if (middleName != null && middleName!.trim().isNotEmpty) middleName,
    lastName,
  ].whereType<String>().join(' ');

  factory ExtensionOfficerModel.fromJson(Map<String, dynamic> json) {
    return ExtensionOfficerModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      specialization: json['specialization'] as String?,
      organization: json['organization'] as String?,
      countryId: json['countryId'] as int?,
      regionId: json['regionId'] as int?,
      districtId: json['districtId'] as int?,
      wardId: json['wardId'] as int?,
      isVerified: (() {
        final v = json['isVerified'];
        if (v == null) return null;
        if (v is bool) return v;
        final s = v.toString().toLowerCase();
        if (s == '1' || s == 'true') return true;
        if (s == '0' || s == 'false') return false;
        return null;
      })(),
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
      'organization': organization,
      'countryId': countryId,
      'regionId': regionId,
      'districtId': districtId,
      'wardId': wardId,
      'isVerified': isVerified,
    };
  }
}
