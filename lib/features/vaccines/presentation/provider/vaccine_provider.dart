import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/domain/models/vaccine_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/domain/repo/vaccine_repo.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class VaccineProvider extends ChangeNotifier {
  VaccineProvider({required VaccineRepositoryInterface vaccinesRepository})
      : _repository = vaccinesRepository;

  final VaccineRepositoryInterface _repository;

  bool _isLoading = false;
  String? _error;
  List<VaccineModel> _vaccines = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<VaccineModel> get vaccines => _vaccines;

  Future<void> loadVaccines({String? farmUuid}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _repository.getVaccines(farmUuid: farmUuid);
      log(
        '📦 Loaded ${items.length} vaccines from local DB'
        '${farmUuid != null ? ' for farm $farmUuid' : ''}',
      );
      _vaccines = items;
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      log('❌ Failed to load vaccines: $e', stackTrace: stackTrace);
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<VaccineModel> addVaccine(VaccineModel model) async {
    try {
      final created = await _repository.createVaccine(model);
      _vaccines = [..._vaccines, created];
      notifyListeners();
      return created;
    } catch (e, stackTrace) {
      log('❌ Failed to create vaccine locally: $e', stackTrace: stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<VaccineModel> updateVaccine(VaccineModel model) async {
    try {
      final updated = await _repository.updateVaccine(model);
      _vaccines = _vaccines
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e, stackTrace) {
      log('❌ Failed to update vaccine locally: $e', stackTrace: stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<VaccineModel?> addVaccineWithDialog(
    BuildContext context,
    VaccineModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addVaccine(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.vaccineSavedSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.vaccineSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<VaccineModel?> updateVaccineWithDialog(
    BuildContext context,
    VaccineModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateVaccine(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.vaccineUpdatedSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.vaccineSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }
}
