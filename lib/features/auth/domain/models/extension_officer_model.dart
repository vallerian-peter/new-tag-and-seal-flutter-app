/// ExtensionOfficer Model
///
/// Represents an extension officer's profile information for login and access control.
class ExtensionOfficerModel {
  // Basic Information
  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String? licenseNumber;
  final String? address;
  final int? countryId;
  final int? regionId;
  final int? districtId;
  final int? wardId;
  final String? organization;
  final bool isVerified;
  final String? specialization;

  // Constructor
  const ExtensionOfficerModel({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    this.licenseNumber,
    this.address,
    this.countryId,
    this.regionId,
    this.districtId,
    this.wardId,
    this.organization,
    required this.isVerified,
    this.specialization,
  });

  // Factory method to create from JSON
  factory ExtensionOfficerModel.fromJson(Map<String, dynamic> json) {
    return ExtensionOfficerModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      gender: json['gender'] as String,
      licenseNumber: json['licenseNumber'] as String?,
      address: json['address'] as String?,
      countryId: json['countryId'] as int?,
      regionId: json['regionId'] as int?,
      districtId: json['districtId'] as int?,
      wardId: json['wardId'] as int?,
      organization: json['organization'] as String?,
      isVerified: json['isVerified'] == true,
      specialization: json['specialization'] as String?,
    );
  }
}
