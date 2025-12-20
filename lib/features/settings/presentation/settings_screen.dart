import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/change_password/change_password_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/about/presentation/about_us_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/support/presentation/support_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/legal/presentation/privacy_policy_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/legal/presentation/terms_of_service_screen.dart';
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
                        l10n.settingsAppHeaderTitle,
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
                    l10n.settingsAppHeaderSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Settings
            _buildSettingsSection(
              context: context,
              title: l10n.settingsAccountTitle,
              children: [
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.lock_outline,
                  title: l10n.changePassword,
                  subtitle: l10n.changePasswordSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Theme Settings
            _buildSettingsSection(
              context: context,
              title: l10n.settingsAppearanceTitle,
              children: [
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.moon_outline,
                  title: l10n.theme,
                  subtitle: isDark ? l10n.settingsThemeDark : l10n.settingsThemeLight,
                  trailing: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Switch(
                        value: themeProvider.isDarkMode,
                        activeTrackColor: Constants.primaryColor,
                        inactiveTrackColor: Colors.grey.shade300,
                        inactiveThumbColor: Colors.grey.shade800,
                        activeColor: Constants.primaryColor,
                        thumbColor: WidgetStateProperty.all(const Color.fromARGB(255, 43, 68, 53)),
                        trackOutlineColor: WidgetStateProperty.all(Colors.grey.shade700),
                        trackOutlineWidth: WidgetStateProperty.all(1),
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
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
              title: l10n.settingsLanguageRegionTitle,
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
              title: l10n.settingsSupportTitle,
              children: [
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.info_circle_outline,
                  title: l10n.about,
                  subtitle: l10n.settingsAboutSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutUsScreen(),
                      ),
                    );
                  },
                ),

                _buildSettingOption(
                  context: context,
                  icon: Iconsax.support_outline,
                  title: l10n.helpSupport,
                  subtitle: l10n.settingsHelpSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportScreen(),
                      ),
                    );
                  },
                ),

                _buildSettingOption(
                  context: context,
                  icon: Iconsax.document_text_outline,
                  title: l10n.privacyPolicy,
                  subtitle: l10n.privacyPolicySubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),

                _buildSettingOption(
                  context: context,
                  icon: Iconsax.document_outline,
                  title: l10n.termsOfService,
                  subtitle: l10n.termsOfServiceSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen(),
                      ),
                    );
                  },
                ),

              ],
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
                label: l10n.settingsLanguageEnglish,
                selected: AppLocalizations.of(context)!.localeName == 'en',
                onTap: () {
                  Navigator.of(context).pop();
                  MyApp.setLocale(context, const Locale('en'));
                },
              ),
              const SizedBox(height: 12),
              _LocaleOptionTile(
                flag: '🇹🇿',
                label: l10n.settingsLanguageSwahili,
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






















