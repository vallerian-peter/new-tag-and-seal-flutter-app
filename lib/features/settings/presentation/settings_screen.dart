import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/theme/theme_provider.dart';

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
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Constants.primaryColor.withValues(alpha: 0.1),
                    Colors.grey.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
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
                  subtitle: 'English',
                  onTap: () {
                    // Handle language selection
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notification Settings
            _buildSettingsSection(
              context: context,
              title: 'Notifications',
              children: [
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.notification_outline,
                  title: l10n.notifications,
                  subtitle: 'Manage notification preferences',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // Handle notification toggle
                    },
                    activeColor: Constants.primaryColor,
                  ),
                ),
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.notification_bing_outline,
                  title: 'Push Notifications',
                  subtitle: 'Receive push notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // Handle push notification toggle
                    },
                    activeColor: Constants.primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Account Settings
            _buildSettingsSection(
              context: context,
              title: 'Account',
              children: [
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.user_edit_outline,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    // Handle edit profile
                  },
                ),
                _buildSettingOption(
                  context: context,
                  icon: Iconsax.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {
                    // Handle change password
                  },
                ),
              ],
            ),
            
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
            _buildSettingsSection(
              context: context,
              title: 'Account Actions',
              children: [
                _buildLogoutOption(context, l10n),
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
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
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
                color: Constants.primaryColor.withValues(alpha: 0.1),
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

  Widget _buildLogoutOption(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        _showLogoutDialog(context, l10n);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Iconsax.logout_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.logout,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sign out of your account',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3_outline,
              color: Colors.red.withValues(alpha: 0.5),
              size: 16,
            ),
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
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(l10n.logout),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle logout logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }
}












