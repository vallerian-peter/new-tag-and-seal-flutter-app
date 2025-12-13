import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/error_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/models/extension_officer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/models/extension_officer_invite_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/domain/repo/extension_officer_repo.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class ExtensionOfficerProvider extends ChangeNotifier {
  final ExtensionOfficerRepositoryInterface _repository;

  ExtensionOfficerProvider({required ExtensionOfficerRepositoryInterface repository})
      : _repository = repository;

  bool _isSearching = false;
  bool _isInviting = false;
  ExtensionOfficerModel? _foundOfficer;
  ExtensionOfficerInviteModel? _createdInvite;
  String? _error;

  bool get isSearching => _isSearching;
  bool get isInviting => _isInviting;
  ExtensionOfficerModel? get foundOfficer => _foundOfficer;
  ExtensionOfficerInviteModel? get createdInvite => _createdInvite;
  String? get error => _error;

  /// Search for extension officer by email
  Future<ExtensionOfficerModel?> searchByEmail(String email) async {
    _isSearching = true;
    _error = null;
    _foundOfficer = null;
    notifyListeners();

    try {
      final officer = await _repository.searchByEmail(email);
      _foundOfficer = officer;
      _isSearching = false;
      notifyListeners();
      return officer;
    } catch (e, stackTrace) {
      log('❌ Error searching extension officer: $e', error: e, stackTrace: stackTrace);
      _error = e.toString();
      _isSearching = false;
      _foundOfficer = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Create extension officer farm invite
  /// [accessCode] should be generated on the frontend before calling this method.
  Future<ExtensionOfficerInviteModel> createInvite(String extensionOfficerEmail, String accessCode) async {
    _isInviting = true;
    _error = null;
    notifyListeners();

    try {
      final invite = await _repository.createInvite(extensionOfficerEmail, accessCode);
      _createdInvite = invite;
      _isInviting = false;
      notifyListeners();
      return invite;
    } catch (e, stackTrace) {
      log('❌ Error creating extension officer invite: $e', error: e, stackTrace: stackTrace);
      _error = e.toString();
      _isInviting = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Search extension officer with error handling dialog
  Future<ExtensionOfficerModel?> searchByEmailWithDialog(
    BuildContext context,
    String email,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final officer = await searchByEmail(email);
      if (officer == null && context.mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.extensionOfficerNotFound,
          buttonText: l10n.ok,
        );
      }
      return officer;
    } catch (e) {
      if (!context.mounted) return null;
      final errorMessage = ErrorHelper.formatErrorMessage(e.toString(), l10n);
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: errorMessage,
        buttonText: l10n.ok,
      );
      return null;
    }
  }

  /// Create invite with error handling dialog
  /// [accessCode] should be generated on the frontend before calling this method.
  Future<ExtensionOfficerInviteModel?> createInviteWithDialog(
    BuildContext context,
    String extensionOfficerEmail,
    String accessCode,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.inviting,
      message: l10n.creatingInvite,
      isDismissible: false,
    );

    try {
      final invite = await createInvite(extensionOfficerEmail, accessCode);

      if (!context.mounted) return null;
      Navigator.of(context).pop(); // Close loading dialog

      await AlertDialogs.showSuccess(
        context: context,
        title: l10n.success,
        message: l10n.extensionOfficerInvitedSuccessfully,
        buttonText: l10n.ok,
      );

      return invite;
    } catch (e) {
      if (!context.mounted) return null;
      Navigator.of(context).pop(); // Close loading dialog

      final errorMessage = ErrorHelper.formatErrorMessage(e.toString(), l10n);
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: errorMessage,
        buttonText: l10n.ok,
      );
      return null;
    }
  }

  /// Clear found officer
  void clearFoundOfficer() {
    _foundOfficer = null;
    notifyListeners();
  }

  /// Clear created invite
  void clearCreatedInvite() {
    _createdInvite = null;
    notifyListeners();
  }
}

