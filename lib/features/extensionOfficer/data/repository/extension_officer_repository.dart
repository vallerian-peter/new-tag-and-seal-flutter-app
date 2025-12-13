import 'dart:developer';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/data/remote/extension_officer_service.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/models/extension_officer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/models/extension_officer_invite_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/repo/extension_officer_repo.dart';

class ExtensionOfficerRepository implements ExtensionOfficerRepositoryInterface {
  @override
  Future<ExtensionOfficerModel?> searchByEmail(String email) async {
    try {
      final data = await ExtensionOfficerService.searchByEmail(email);
      if (data == null) return null;
      return ExtensionOfficerModel.fromJson(data);
    } catch (e, stackTrace) {
      log('❌ Error searching extension officer: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ExtensionOfficerInviteModel> createInvite(String extensionOfficerEmail, String accessCode) async {
    try {
      final data = await ExtensionOfficerService.createInvite(extensionOfficerEmail, accessCode);
      return ExtensionOfficerInviteModel.fromJson(data);
    } catch (e, stackTrace) {
      log('❌ Error creating extension officer invite: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

