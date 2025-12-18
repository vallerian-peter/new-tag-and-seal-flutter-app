import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/presentation/provider/extension_officer_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/presentation/extension_officer_invite_form_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ExtensionOfficerListScreen extends StatefulWidget {
  const ExtensionOfficerListScreen({super.key});

  @override
  State<ExtensionOfficerListScreen> createState() =>
      _ExtensionOfficerListScreenState();
}

class _ExtensionOfficerListScreenState
    extends State<ExtensionOfficerListScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initialize(forceReload: true);
    });
  }

  Future<void> _initialize({bool forceReload = true}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final provider = context.read<ExtensionOfficerProvider>();

      if (forceReload || provider.officers.isEmpty) {
        await provider.loadInvitedExtensionOfficers();
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      log(
        '📋 ExtensionOfficerListScreen initialized: officers=${provider.officers.length}',
      );
    } catch (e, st) {
      log(
        '❌ Failed to initialize ExtensionOfficerListScreen: $e',
        error: e,
        stackTrace: st,
      );
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
    final provider = context.watch<ExtensionOfficerProvider>();

    final isBusy = _isLoading || provider.isLoading;
    final officers = provider.officers
        .where((o) => o.syncAction != 'deleted')
        .toList();

    if (isBusy) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.invitedExtensionOfficers)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.invitedExtensionOfficers)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.error, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _onRefresh, child: Text(l10n.retry)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('${l10n.invitedExtensionOfficers} (${officers.length})'),
        actions: [
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.retry,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: officers.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    child: Center(child: Text(l10n.noData)),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: officers.length,
                itemBuilder: (context, index) {
                  final officer = officers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ExtensionOfficerCard(
                      officer: officer,
                      onRefresh: _onRefresh,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ExtensionOfficerCard extends StatelessWidget {
  final dynamic officer;
  final VoidCallback onRefresh;

  const _ExtensionOfficerCard({required this.officer, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd().add_jm();
    final createdAt = officer.createdAt;
    final fullName = [
      officer.firstName,
      if (officer.middleName != null && officer.middleName!.trim().isNotEmpty)
        officer.middleName,
      officer.lastName,
    ].whereType<String>().join(' ');

    final backgroundColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.05)
        : Colors.white;
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white.withOpacity(0.06)
        : theme.colorScheme.outlineVariant.withOpacity(0.3);

    log('Officer verified status: ${officer.isVerified}');

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
                  color: theme.colorScheme.primary.withOpacity(0.1),
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
                      fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      officer.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () async {
                  await AlertDialogs.showConfirmation(
                          context: context,
                          title: l10n.deleteUser,
                          message: l10n.confirmDelete,
                          confirmText: l10n.delete,
                          cancelText: l10n.cancel,
                          onConfirm: () async {
                            final provider =
                                Provider.of<ExtensionOfficerProvider>(
                                  context,
                                  listen: false,
                                );
                            await provider
                                .markInvitedExtensionOfficerAsDeletedWithDialog(
                                  context,
                                  officer.inviteId,
                                );
                            onRefresh();
                    }
                  );
                },
                icon: Icon(
                  Iconsax.trash_bold, 
                  size: 18, 
                  color: Colors.red,
                ),
              ),

              // Theme(
              //   data: theme.copyWith(
              //     popupMenuTheme: PopupMenuThemeData(
              //       color: theme.scaffoldBackgroundColor,
              //     ),
              //   ),
              //   child: PopupMenuButton<int>(
              //     icon: Icon(
              //       Icons.more_vert,
              //       color: theme.colorScheme.onSurface.withOpacity(0.7),
              //     ),
              //     onSelected: (action) async {
              //       switch (action) {
              //         case 1:
              //           // Reuse the invite form screen for editing or viewing details if needed
              //           final result = await Navigator.of(context).push(
              //             MaterialPageRoute(
              //               builder: (_) => ExtensionOfficerInviteFormScreen(),
              //             ),
              //           );
              //           if (result != null) onRefresh();
              //           break;
              //         case 2:
              //           await AlertDialogs.showConfirmation(
              //             context: context,
              //             title: l10n.deleteUser,
              //             message: l10n.confirmDelete,
              //             confirmText: l10n.delete,
              //             cancelText: l10n.cancel,
              //             onConfirm: () async {
              //               final provider =
              //                   Provider.of<ExtensionOfficerProvider>(
              //                     context,
              //                     listen: false,
              //                   );
              //               await provider
              //                   .markInvitedExtensionOfficerAsDeletedWithDialog(
              //                     context,
              //                     officer.inviteId,
              //                   );
              //               onRefresh();
              //             },
              //           );
              //           break;
              //       }
              //     },
              //     itemBuilder: (context) => [
              //       PopupMenuItem(
              //         value: 1,
              //         child: Row(
              //           children: [
              //             Icon(
              //               Icons.edit,
              //               size: 18,
              //               color: Color.fromARGB(255, 58, 95, 60),
              //             ),
              //             const SizedBox(width: 12),
              //             Text(l10n.editUser),
              //           ],
              //         ),
              //       ),
              //       PopupMenuItem(
              //         value: 2,
              //         child: Row(
              //           children: [
              //             Icon(
              //               Icons.delete_outline,
              //               size: 18,
              //               color: Colors.red,
              //             ),
              //             const SizedBox(width: 12),
              //             Text(l10n.deleteUser),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

            ],
          ),

          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  officer.email,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  officer.phone ?? l10n.notProvided,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.organization,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  officer.organization ?? l10n.notProvided,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.specialization,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  officer.specialization ?? l10n.notProvided,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.verified,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  officer.isVerified == true ? l10n.yes : l10n.no,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.right,
                ),
              ),
              
            ],
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.createdAt,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(createdAt.toLocal()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
