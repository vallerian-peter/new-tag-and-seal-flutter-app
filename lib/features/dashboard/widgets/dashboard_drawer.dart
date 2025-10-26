import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/theme/theme_provider.dart';

class DashboardDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;

  const DashboardDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [

          // Header with logo and user info
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Constants.primaryColor.withValues(alpha: 0.8), Constants.primaryColor]
                    : [Constants.primaryColor, Constants.primaryColor.withValues(alpha: 0.8)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 12),
                    
                    // Logo placeholder
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FontAwesome.seedling_solid,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    
                    // User info - simplified to prevent overflow
                    Center(
                      child: Column(
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            l10n.farmer,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home,
                  title: l10n.homeText,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.heart_outline,
                  title: l10n.vaccinesText,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to vaccines
                  },
                ),
                
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.people_outline,
                  title: l10n.invitedUsersText,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to invited users
                  },
                ),
                
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.user_tick_outline,
                  title: l10n.invitedOfficersText,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to invited officers
                  },
                ),
                
                Divider(color: isDark ? Colors.grey[600] : Colors.grey[300]),
                
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.logout_outline,
                  title: l10n.logout,
                  isLogout: true,
                  onTap: () {
                    Navigator.pop(context);
                    // Handle logout
                  },
                ),
              ],
            ),
          ),
          
          // Theme toggle
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.darkModeText,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.grey.shade700,
                  ),
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: Constants.primaryColor,
                      inactiveTrackColor: Colors.grey.shade200,
                      inactiveThumbColor: Colors.grey.shade600,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isLogout
                ? Colors.red.withValues(alpha: 0.1)
                : Constants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isLogout
                ? Colors.redAccent
                : const Color.fromARGB(255, 87, 162, 151),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isLogout
                ? Colors.red
                : (isDark ? Colors.white : Colors.grey.shade700),
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        hoverColor: isLogout
            ? Colors.red.withValues(alpha: 0.1)
            : Constants.primaryColor.withValues(alpha: 0.1),
      ),
    );
  }
}