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
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/provider/livestock_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Key _dashboardKey = UniqueKey();
  Key _profileKey = UniqueKey();
  
  /// Change the selected tab index programmatically
  void changeTab(int index) {
    if (index == 2) {
      _handleScannerAction();
      return;
    }
    
    setState(() {
      if (index == 0) {
        _dashboardKey = UniqueKey();
      } else if (index == 4) {
        _profileKey = UniqueKey();
      }
      _selectedIndex = index;
    });
    
    // Auto-refresh data when entering specific tabs
    if (index == 1) {
      _refreshLivestockTab();
    } else if (index == 3) {
      _refreshEventsTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Screens for navigation (Dashboard uses a key so we can force a refresh)
    final screens = [
      DashboardScreen(key: _dashboardKey),   // Index 0
      const LivestockListScreen(),           // Index 1
      const EventsScreen(),                  // Index 3
      ProfileScreen(key: _profileKey),       // Index 4
    ];
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _selectedIndex > 2 ? _selectedIndex - 1 : _selectedIndex, // Skip scanner index
        children: screens,
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
                  // If navigating to Dashboard, force a fresh instance so it reloads farms
                  if (index == 0) {
                    _dashboardKey = UniqueKey();
                  } else if (index == 4) {
                    // Force a fresh ProfileScreen so it reloads stats
                    _profileKey = UniqueKey();
                  }
                  _selectedIndex = index;
                });

                // Auto-refresh data when entering specific tabs
                if (index == 1) {
                  // Livestock tab
                  _refreshLivestockTab();
                } else if (index == 3) {
                  // Events tab
                  _refreshEventsTab();
                }
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

  /// Refresh data when entering the Livestock tab
  void _refreshLivestockTab() {
    try {
      final livestockProvider = context.read<LivestockProvider>();
      final database = context.read<AppDatabase>();

      // Refresh livestock list
      livestockProvider.fetchAllLivestock();

      // Refresh farm names used by livestock cards
      database.farmDao.getAllActiveFarms().then((farms) {
        final farmNamesMap = <String, String>{};
        for (final farm in farms) {
          farmNamesMap[farm.uuid] = farm.name;
        }
        livestockProvider.setFarmNames(farmNamesMap);
      });
    } catch (_) {
      // If providers are not available in this context, safely ignore
    }
  }

  /// Refresh data when entering the Events tab
  void _refreshEventsTab() {
    try {
      final eventsProvider = context.read<EventsProvider>();
      // Refresh events list; EventsScreen will handle its own additional state
      eventsProvider.loadAllEvents();
    } catch (_) {
      // If provider is not available, safely ignore
    }
  }
}

