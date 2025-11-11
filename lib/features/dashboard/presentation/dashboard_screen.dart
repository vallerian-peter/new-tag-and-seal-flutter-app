import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/provider/sync-provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/farm_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/provider/farm_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/section_header.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/action_card.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/stat_card.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/farms_section.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/presentation/notification_screen.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSyncing = false;
  final _secureStorage = const FlutterSecureStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> farmsWithLivestock = [];
  int _totalEventCount = 0;
  
  String _userName = '';
  String _userEmail = '';

  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    getALlFarmsWithThereLivestocks();
    _loadEventSummary();
  }
  
  Future<void> _loadUserData() async {
    final firstname = await _secureStorage.read(key: 'firstname') ?? '';
    final surname = await _secureStorage.read(key: 'surname') ?? '';
    final email = await _secureStorage.read(key: 'email') ?? '';
    
    if (mounted) {
      setState(() {
        _userName = '$firstname $surname'.trim();
        if (_userName.isEmpty) {
          _userName = 'User';
        }
        _userEmail = email;
      });
    }
  }

  Future<void> _loadEventSummary() async {
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final summary = await eventsProvider.getEventSummary();
    if (mounted) {
      setState(() {
        _totalEventCount = summary.totalCount;
      });
    }
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    if (!mounted) return;

    setState(() {
      _isSyncing = true;
    });

    final syncProvider = Provider.of<SyncProvider>(context, listen: false);
    await syncProvider.splashSyncWithDialog(context);
    
    setState(() {
      _isSyncing = false;
    });
  }
  
  /// Calculate total livestock count from all farms
  int get totalLivestockCount {
    return farmsWithLivestock.fold<int>(
      0, 
      (sum, farm) => sum + (farm['livestockCount'] as int? ?? 0),
    );
  }

  Future<void> getALlFarmsWithThereLivestocks() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    // Get all farms with livestock WITHOUT dialogs
    final farmsData = await farmProvider.getAllFarmsWithLivestock();
    
    if (farmsData != null && farmsData.isNotEmpty) {
      print('✅ Found ${farmsData.length} farms with livestock');
      
      // Transform data to match FarmsSection expected format
      final transformedFarms = farmsData.map((farmData) {
        final farm = farmData['farm'];
        final livestock = farmData['livestock'] as List;
        final livestockCount = farmData['livestockCount'] as int;
        
        return {
          'name': farm.name,
          'livestockCount': livestockCount,
          'location': farm.physicalAddress ?? 'Unknown Location',  // Use fallback string
          'uuid': farm.uuid,
          'farmData': farm, // Keep full farm data for details
          'livestock': livestock, // Keep livestock list for details
        };
      }).toList();
      
      setState(() {
        farmsWithLivestock = transformedFarms;
      });
    } else {
      print('⚠️ No farms found or error occurred');
      setState(() {
        farmsWithLivestock = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: DashboardDrawer(
        userName: _userName,
        userEmail: _userEmail,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_sync_fab',
        onPressed: () => _syncData(),
        child: _isSyncing ? const LoadingIndicator(size: 20, strokeWidth: 2, color: Colors.white) : Icon(Iconsax.refresh_outline),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.welcome,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              _userName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            icon: Icon(
              FontAwesome.bars_solid,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Iconsax.notification_outline,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Positioned(
                top: 14,
                right: 16,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        onRefresh: () async {
          // await _loadUserData();
          await getALlFarmsWithThereLivestocks();
          await _loadEventSummary();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // My Farms Section
              FarmsSection(
                farms: farmsWithLivestock,
                onRefresh: getALlFarmsWithThereLivestocks,
              ),
              
              const SizedBox(height: 32),
              
              // Farm Management Section
              SectionHeader(
                title: l10n.farmManagementText,
                icon: Iconsax.setting_2_outline,
              ),
              
              const SizedBox(height: 16),
              
              // Create New Farm
              ActionCard(
                icon: Iconsax.add_circle_outline,
                title: l10n.createNewFarmText,
                subtitle: l10n.registerFarmDesc,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Constants.primaryColor,
                    Constants.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                onTap: () async {
                  // Navigate to create farm
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FarmFormScreen()),
                  );
                  
                  // Reload farms if farm was successfully created
                  if (result == true && mounted) {
                    await getALlFarmsWithThereLivestocks();
                  }
                },
              ),
              
              // Invite Farm User
              ActionCard(
                icon: Iconsax.user_add_outline,
                title: l10n.inviteFarmUserText,
                subtitle: l10n.collaborateText,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Constants.successColor,
                    Constants.successColor.withValues(alpha: 0.8),
                  ],
                ),
                onTap: () {
                  // Navigate to invite user
                },
              ),
              
              // Add Extension Officer
              ActionCard(
                icon: Iconsax.profile_2user_outline,
                title: l10n.addExtensionOfficerText,
                subtitle: l10n.inviteOfficerText,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Constants.tertiaryColor,
                    Constants.tertiaryColor.withValues(alpha: 0.8),
                  ],
                ),
                onTap: () {
                  // Navigate to add officer
                },
              ),
              
              const SizedBox(height: 32),
              
              // Quick Stats
              SectionHeader(
                title: l10n.analytics,
                icon: Bootstrap.bar_chart,
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: l10n.livestock,
                      value: '$totalLivestockCount',
                      icon: Iconsax.pet_outline,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: l10n.events,
                      value: '$_totalEventCount',
                      icon: Iconsax.calendar_outline,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

