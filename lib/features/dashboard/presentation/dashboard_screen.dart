import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/provider/sync-provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/sync.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/provider/all.additional.data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/login/login_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/action_card.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/farms_section.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/section_header.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/stat_card.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/farm_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/provider/farm_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/presentation/notification_screen.dart';

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
  bool _syncPromptShown = false;
  bool _isLogoutDialogOpen = false;
  
  String _userName = '';
  String _userEmail = '';

  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    getALlFarmsWithThereLivestocks();
    _loadEventSummary();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSyncToast());
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

  void _showSyncToast() {
    if (_syncPromptShown || !mounted) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (_syncPromptShown || !mounted) return;
      _syncPromptShown = true;
      final l10n = AppLocalizations.of(context)!;
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final theme = Theme.of(dialogContext);
          final isDark = theme.brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(l10n.sync),
            content: Text(
              l10n.dashboardSyncPrompt,
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _syncData();
                },
                child: Text(l10n.sync),
              ),
            ],
          );
        },
      );
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
    
    return WillPopScope(
      onWillPop: () async {
        await _onLogoutPressed();
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: DashboardDrawer(
          userName: _userName,
          userEmail: _userEmail,
          onLogout: _onLogoutPressed,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'dashboard_sync_fab',
          onPressed: () => _syncData(),
          child: _isSyncing
              ? const LoadingIndicator(size: 20, strokeWidth: 2, color: Colors.white)
              : const Icon(Iconsax.refresh_outline),
        ),
        appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${l10n.welcome},',
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
                      builder: (context) => const NotificationScreen(),
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
      ),
    );
  }

  Future<void> _onLogoutPressed() async {
    if (_isLogoutDialogOpen || !mounted) return;
    _isLogoutDialogOpen = true;

    final database = context.read<AppDatabase>();
    SyncUnsyncedSummary summary;
    try {
      summary = await Sync.getUnsyncedSummary(database);
    } catch (_) {
      summary = const SyncUnsyncedSummary.empty();
    }

    if (!mounted) {
      _isLogoutDialogOpen = false;
      return;
    }

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
                  _logoutFlow(syncBefore: true);
                },
                child: Text(l10n.syncAndLogout),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logoutFlow(syncBefore: false);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );

    _isLogoutDialogOpen = false;
  }

  Future<void> _logoutFlow({required bool syncBefore}) async {
    final l10n = AppLocalizations.of(context)!;
    final database = context.read<AppDatabase>();
    final authProvider = context.read<AuthProvider>();
    final additionalDataProvider = context.read<AdditionalDataProvider>();
    final eventsProvider = context.read<EventsProvider>();

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
      // Ignore cleanup errors but continue logout flow
    }

    eventsProvider.clear();
    additionalDataProvider.clearLocationData();

    if (!mounted) return;

    setState(() {
      farmsWithLivestock = [];
      _totalEventCount = 0;
      _syncPromptShown = false;
    });

    ScaffoldMessenger.of(context).clearSnackBars();

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
}

