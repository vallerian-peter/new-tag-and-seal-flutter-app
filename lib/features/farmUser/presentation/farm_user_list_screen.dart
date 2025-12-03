import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/domain/models/farm_user_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/presentation/farm_user_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/presentation/provider/farm_user_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class FarmUserListScreen extends StatefulWidget {
  const FarmUserListScreen({super.key});

  @override
  State<FarmUserListScreen> createState() => _FarmUserListScreenState();
}

class _FarmUserListScreenState extends State<FarmUserListScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, String> _farmNames = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initialize(forceReload: true);
      }
    });
  }

  Future<void> _initialize({bool forceReload = true}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final provider = context.read<FarmUserProvider>();
      final database = context.read<AppDatabase>();

      if (forceReload || provider.users.isEmpty) {
        await provider.loadFarmUsers();
      }

      final farms = await database.farmDao.getAllActiveFarms();
      final farmNameMap = <String, String>{
        for (final farm in farms) farm.uuid: farm.name,
      };

      if (!mounted) return;
      setState(() {
        _farmNames = farmNameMap;
        _isLoading = false;
      });

      log('📋 FarmUserListScreen initialized: users=${provider.users.length}, farms=${farmNameMap.length}');
    } catch (e, stackTrace) {
      log('❌ Failed to initialize FarmUserListScreen: $e', stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _onRefresh() async {
    await _initialize(forceReload: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<FarmUserProvider>();

    final isBusy = _isLoading || provider.isLoading;
    // Exclude locally deleted users (syncAction == 'deleted')
    final users =
        provider.users.where((u) => u.syncAction != 'deleted').toList();

    if (isBusy) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.invitedUsersText)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.invitedUsersText)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.error,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _onRefresh,
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('${l10n.invitedUsersText} (${users.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: l10n.retry,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: users.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    child: Center(
                      child: Text(
                        l10n.noData,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  // Get all farm names for this user's assigned farms
                  final farmNames = user.farmUuids
                      .map((uuid) => _farmNames[uuid] ?? l10n.unknownFarm)
                      .where((name) => name != l10n.unknownFarm || user.farmUuids.length == 1)
                      .toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FarmUserCard(
                      user: user,
                      farmNames: farmNames.isEmpty && user.farmUuids.isNotEmpty 
                          ? [l10n.unknownFarm] 
                          : farmNames,
                      onRefresh: _onRefresh,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _FarmUserCard extends StatelessWidget {
  final FarmUserModel user;
  final List<String> farmNames; // Changed to list for multiple farms
  final VoidCallback onRefresh;

  const _FarmUserCard({
    required this.user,
    required this.farmNames,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
        : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.3);

    final dateFormat = DateFormat.yMMMd().add_jm();
    final createdAt = DateTime.tryParse(user.createdAt);

    // Build farm display widget
    final farmDisplayWidget = farmNames.isEmpty
        ? Text(
            l10n.unknownFarm,
            style: theme.textTheme.bodyMedium,
          )
        : farmNames.length == 1
            ? Text(
                farmNames.first,
                style: theme.textTheme.bodyMedium,
              )
            : Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${farmNames.length} ${l10n.farms}:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ...farmNames.map((farmName) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          farmName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )),
                ],
              );

    final rows = <_DetailRow>[
      _DetailRow(label: l10n.role, value: user.roleTitle),
      if (user.phone != null && user.phone!.trim().isNotEmpty)
        _DetailRow(label: l10n.phoneNumber, value: user.phone!.trim()),
      _DetailRow(label: l10n.email, value: user.email),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.gender.toLowerCase() == 'male'
                          ? l10n.male
                          : l10n.female,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Theme(
                data: theme.copyWith(
                  popupMenuTheme: PopupMenuThemeData(
                    color: theme.scaffoldBackgroundColor,
                  ),
                ),
                child: PopupMenuButton<_FarmUserMenuAction>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  onSelected: (action) async {
                    switch (action) {
                      case _FarmUserMenuAction.editUser:
                        // Navigate to edit form
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FarmUserFormScreen(
                              farmUser: user,
                            ),
                          ),
                        );
                        if (result != null) {
                          // Refresh the list after edit
                          onRefresh();
                        }
                        break;
                      case _FarmUserMenuAction.deleteUser:
                        // Capture the screen context and user info before showing dialog
                        final screenContext = context;
                        final userToDelete = user;
                        
                        // Show confirmation dialog using shared AlertDialogs component
                        await AlertDialogs.showConfirmation(
                          context: screenContext,
                          title: l10n.deleteUser,
                          messageWidget: Text.rich(
                            TextSpan(
                              text: '${l10n.confirmDelete} ',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              children: [
                                TextSpan(
                                  text: userToDelete.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: '?'),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          confirmText: l10n.delete,
                          cancelText: l10n.cancel,
                          onConfirm: () async {
                            // Wait a frame to ensure confirmation dialog is fully dismissed
                            await Future.delayed(const Duration(milliseconds: 100));
                            
                            if (!screenContext.mounted) return;
                            
                            final provider = Provider.of<FarmUserProvider>(
                              screenContext,
                              listen: false,
                            );
                            await provider.markFarmUserAsDeletedWithDialog(
                              screenContext,
                              userToDelete.uuid,
                            );
                            if (screenContext.mounted) {
                              onRefresh();
                            }
                          },
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _FarmUserMenuAction.editUser,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.edit,
                            size: 18,
                            color: Color.fromARGB(255, 58, 95, 60),
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.editUser),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _FarmUserMenuAction.deleteUser,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.deleteUser),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Farms row - custom display
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    farmNames.length == 1 ? l10n.farm : l10n.farms,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: farmDisplayWidget,
                  ),
                ),
              ],
            ),
          ),
          // Other detail rows
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        row.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        row.value,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),
          if (createdAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.createdAt,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(createdAt.toLocal()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});
}

enum _FarmUserMenuAction {
  editUser,
  deleteUser,
}


