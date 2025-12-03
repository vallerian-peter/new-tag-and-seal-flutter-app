enum FarmUserAccessScope {
  full,      // can manage livestock + all logs/events
  logsOnly,  // can create/view logs/events only
  readOnly,  // view-only access
}

class FarmUserPermissions {
  final FarmUserAccessScope scope;
  final bool canManageLivestock;
  final bool canCreateLogs;
  final bool canViewLogs;

  const FarmUserPermissions({
    required this.scope,
    required this.canManageLivestock,
    required this.canCreateLogs,
    required this.canViewLogs,
  });
}

/// Resolve permissions based on farm user's `roleTitle` from backend.
FarmUserPermissions resolveFarmUserPermissions(String roleTitle) {
  switch (roleTitle) {
    case 'farm-manager':
      return const FarmUserPermissions(
        scope: FarmUserAccessScope.full,
        canManageLivestock: true,
        canCreateLogs: true,
        canViewLogs: true,
      );

    case 'feeding-user':
    case 'weight-change-user':
    case 'deworming-user':
    case 'medication-user':
    case 'vaccination-user':
    case 'disposal-user':
    case 'birth-event-user':
    case 'aborted-pregnancy-user':
    case 'dryoff-user':
    case 'insemination-user':
    case 'pregnancy-user':
    case 'milking-user':
    case 'transfer-user':
      return const FarmUserPermissions(
        scope: FarmUserAccessScope.logsOnly,
        canManageLivestock: false,
        canCreateLogs: true,
        canViewLogs: true,
      );

    default:
      return const FarmUserPermissions(
        scope: FarmUserAccessScope.readOnly,
        canManageLivestock: false,
        canCreateLogs: false,
        canViewLogs: true,
      );
  }
}


