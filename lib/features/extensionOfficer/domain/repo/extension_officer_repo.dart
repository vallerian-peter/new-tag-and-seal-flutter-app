import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/models/extension_officer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/models/extension_officer_invite_model.dart';

abstract class ExtensionOfficerRepositoryInterface {
  /// Search for extension officer by email
  Future<ExtensionOfficerModel?> searchByEmail(String email);

  /// Create extension officer farm invite
  /// [accessCode] should be generated on the frontend before calling this method.
  Future<ExtensionOfficerInviteModel> createInvite(String extensionOfficerEmail, String accessCode);
}

