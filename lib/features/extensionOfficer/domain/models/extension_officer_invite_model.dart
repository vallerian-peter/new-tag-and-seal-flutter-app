import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/models/extension_officer_model.dart';

class ExtensionOfficerInviteModel {
  final int? id;
  final String accessCode;
  final int extensionOfficerId;
  final ExtensionOfficerModel extensionOfficer;

  const ExtensionOfficerInviteModel({
    this.id,
    required this.accessCode,
    required this.extensionOfficerId,
    required this.extensionOfficer,
  });

  factory ExtensionOfficerInviteModel.fromJson(Map<String, dynamic> json) {
    return ExtensionOfficerInviteModel(
      id: json['id'] as int?,
      accessCode: json['access_code'] as String,
      extensionOfficerId: json['extensionOfficerId'] as int? ?? 
                         (json['extensionOfficer'] as Map<String, dynamic>?)?['id'] as int? ?? 0,
      extensionOfficer: ExtensionOfficerModel.fromJson(
        json['extensionOfficer'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'access_code': accessCode,
      'extensionOfficerId': extensionOfficerId,
      'extensionOfficer': extensionOfficer.toJson(),
    };
  }
}

