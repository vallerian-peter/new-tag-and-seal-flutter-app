import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/livestock_list_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/events_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/profile/presentation/profile_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/scanner/presentation/scanner_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens for navigation
  final List<Widget> _screens = [
    const DashboardScreen(),      // Index 0
    const LivestockListScreen(),  // Index 1
    const EventsScreen(),         // Index 3
    const ProfileScreen(),        // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _selectedIndex > 2 ? _selectedIndex - 1 : _selectedIndex, // Skip scanner index
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 4),
            child: GNav(
              // Configuration
              backgroundColor: Colors.transparent,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              activeColor: Constants.primaryColor,
              tabBackgroundColor: Constants.primaryColor.withValues(alpha: 0.1),
              gap: 2,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: GnavStyle.google,
              
              // Navigation items
              tabs: [
                // Dashboard
                GButton(
                  icon: _selectedIndex == 0 ? Iconsax.home_bold : Iconsax.home_outline,
                  iconActiveColor: Constants.primaryColor,
                  text: l10n.start,
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _selectedIndex == 0 
                        ? Constants.primaryColor 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  iconSize: 25,
                ),
                
                // Livestocks
                GButton(
                  icon: _selectedIndex == 1 ? Iconsax.pet_bold : Iconsax.pet_outline,
                  iconActiveColor: Constants.primaryColor,
                  text: l10n.livestocks,
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _selectedIndex == 1 
                        ? Constants.primaryColor 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  iconSize: 25,
                ),
                
                // Scanner (Floating Action Button)
                GButton(
                  icon: _selectedIndex == 2 ? Iconsax.scan_bold : Iconsax.scan_outline,
                  iconActiveColor: _selectedIndex == 2 ? Colors.white : Colors.black87,
                  text: '',
                  backgroundColor: _selectedIndex == 2 ? const Color.fromARGB(255, 222, 133, 7) : Colors.transparent,
                  iconSize: 25,
                  padding: const EdgeInsets.all(12),
                ),
                
                // Events
                GButton(
                  icon: _selectedIndex == 3 ? Iconsax.calendar_bold : Iconsax.calendar_outline,
                  iconActiveColor: Constants.primaryColor,
                  text: l10n.events,
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _selectedIndex == 3 
                        ? Constants.primaryColor 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  iconSize: 25,
                ),
                
                // Profile
                GButton(
                  icon: _selectedIndex == 4 ? Iconsax.user_bold : Iconsax.user_outline,
                  iconActiveColor: Constants.primaryColor,
                  text: l10n.profile,
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _selectedIndex == 4 
                        ? Constants.primaryColor 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  iconSize: 25,
                ),
              ],
              
              // Handle navigation
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                // Handle scanner action
                if (index == 2) {
                  _handleScannerAction();
                  return;
                }
                
                // For regular screens, use the index directly
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Handle scanner button action
  void _handleScannerAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerScreen(),
      ),
    ).then((result) {
      // Return to dashboard (index 0) after scanner closes
      if (mounted) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }
}

