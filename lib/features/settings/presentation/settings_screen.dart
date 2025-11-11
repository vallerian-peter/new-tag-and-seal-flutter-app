import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/sync.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/provider/all.additional.data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/login/login_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/main.dart';
import 'package:new_tag_and_seal_flutter_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Bootstrap.chevron_left, size: 20,),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.setting_2_outline,
                        color: Constants.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'App Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize your app experience',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Theme Settings
            _buildSettingsSection(
              context: context,
              title: 'Appearance',
              children: [
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.moon_outline,
                  title: l10n.theme,
                  subtitle: isDark ? 'Dark Mode' : 'Light Mode',
                  trailing: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        activeColor: Constants.primaryColor,
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Language Settings
            _buildSettingsSection(
              context: context,
              title: 'Language & Region',
              children: [
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.global_outline,
                  title: l10n.language,
                  subtitle: l10n.localeName == 'sw' ? 'Kiswahili' : 'English',
                  onTap: () => _showLocaleDialog(context),
                ),
              ],
            ),
            
            // Notifications & Account sections are hidden for now.
            
            const SizedBox(height: 24),
            
            // Support & About
            _buildSettingsSection(
              context: context,
              title: 'Support & About',
              children: [
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.info_circle_outline,
                  title: l10n.about,
                  subtitle: 'App version and information',
                  onTap: () {
                    _showAboutDialog(context, l10n);
                  },
                ),
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.support_outline,
                  title: l10n.helpSupport,
                  subtitle: 'Get help and support',
                  onTap: () {
                    // Handle help and support
                  },
                ),
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.document_text_outline,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    // Handle privacy policy
                  },
                ),
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.document_outline,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  onTap: () {
                    // Handle terms of service
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Logout Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _onLogoutPressed(context),
                  icon: const Icon(Iconsax.logout_outline),
                  label: Text(
                    l10n.logout,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Constants.primaryColor
                    .withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Constants.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing,
            ] else if (onTap != null) ...[
              Icon(
                Iconsax.arrow_right_3_outline,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(l10n.about),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tag & Seal'),
              const SizedBox(height: 8),
              Text('Version: 1.0.0'),
              const SizedBox(height: 8),
              Text('A comprehensive livestock management application.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final database = Provider.of<AppDatabase>(context, listen: false);
    SyncUnsyncedSummary summary;

    try {
      summary = await Sync.getUnsyncedSummary(database);
    } catch (_) {
      summary = const SyncUnsyncedSummary.empty();
    }

    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(l10n.logout),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary.hasPending
                  ? l10n.unsyncedDataWarning
                  : l10n.noUnsyncedDataMessage),
              if (summary.hasPending) ...[
                const SizedBox(height: 12),
                ..._buildUnsyncedSummaryItems(dialogContext, l10n, summary),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            if (summary.hasPending)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _logoutFlow(context, syncBefore: true);
                },
                child: Text(l10n.syncAndLogout),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logoutFlow(context, syncBefore: false);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutFlow(BuildContext context, {required bool syncBefore}) async {
    final l10n = AppLocalizations.of(context)!;
    final database = Provider.of<AppDatabase>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final additionalDataProvider =
        Provider.of<AdditionalDataProvider>(context, listen: false);
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    if (syncBefore) {
      AlertDialogs.showLoading(
        context: context,
        title: l10n.sync,
        message: l10n.syncingBeforeLogout,
        isDismissible: false,
      );

      try {
        await Sync.fullSyncPostData(database);
      } catch (error) {
        if (context.mounted) {
          await Navigator.of(context, rootNavigator: true).maybePop();
          await AlertDialogs.showError(
            context: context,
            title: l10n.syncFailed,
            message: error.toString(),
            buttonText: l10n.ok,
          );
        }
        return;
      }

      if (context.mounted) {
        await Navigator.of(context, rootNavigator: true).maybePop();
      }
    }

    await authProvider.logout(context);

    try {
      await database.clearAllData();
    } catch (_) {
      // Ignore database clearing errors but continue logout flow
    }

    eventsProvider.clear();
    additionalDataProvider.clearLocationData();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  List<Widget> _buildUnsyncedSummaryItems(
    BuildContext context,
    AppLocalizations l10n,
    SyncUnsyncedSummary summary,
  ) {
    final items = <Widget>[];

    void addItem(String label, int count) {
      if (count <= 0) return;
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    addItem(l10n.farms, summary.farms);
    addItem(l10n.livestock, summary.livestock);
    summary.logCounts.forEach(
      (logType, count) => addItem(_logLabel(l10n, logType), count),
    );
    addItem(l10n.vaccination, summary.vaccines);

    return items;
  }

  String _logLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'feedings':
        return l10n.feeding;
      case 'weightChanges':
        return l10n.weightChange;
      case 'dewormings':
        return l10n.deworming;
      case 'medications':
        return l10n.medication;
      case 'vaccinations':
        return l10n.vaccination;
      case 'disposals':
        return l10n.disposal;
      case 'milkings':
        return l10n.milking;
      case 'pregnancies':
        return l10n.pregnancy;
      case 'calvings':
        return l10n.calving;
      case 'dryoffs':
        return l10n.dryoff;
      case 'inseminations':
        return l10n.insemination;
      default:
        return key;
    }
  }

  void _showLocaleDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
          title: Text('${l10n.select} ${l10n.language}', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LocaleOptionTile(
                flag: '🇺🇸',
                label: 'English',
                selected: AppLocalizations.of(context)!.localeName == 'en',
                onTap: () {
                  Navigator.of(context).pop();
                  MyApp.setLocale(context, const Locale('en'));
                },
              ),
              const SizedBox(height: 12),
              _LocaleOptionTile(
                flag: '🇹🇿',
                label: 'Kiswahili',
                selected: AppLocalizations.of(context)!.localeName == 'sw',
                onTap: () {
                  Navigator.of(context).pop();
                  MyApp.setLocale(context, const Locale('sw'));
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }
}

class _LocaleOptionTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LocaleOptionTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Constants.primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Constants.primaryColor
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, color: Constants.primaryColor),
          ],
        ),
      ),
    );
  }
}






















