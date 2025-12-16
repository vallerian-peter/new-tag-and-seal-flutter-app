import 'package:new_tag_and_seal_flutter_app/features/farmUser/domain/farm_user_permissions.dart';

/// Extension Officer permissions resolver
///
/// Extension officers should be able to view and create technical logs
/// (medication, vaccination, etc.) but not manage livestock.
FarmUserPermissions resolveExtensionOfficerPermissions() {
  return const FarmUserPermissions(
    scope: FarmUserAccessScope.logsOnly,
    canManageLivestock: false,
    canCreateLogs: true,
    canViewLogs: true,
  );
}
