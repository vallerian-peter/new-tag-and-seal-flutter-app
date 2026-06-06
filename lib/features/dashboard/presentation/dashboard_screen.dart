import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/role_helper.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/provider/sync-provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/sync.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/provider/all.additional.data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/login/login_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/action_card.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/dashboard_drawer.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/farms_section.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/section_header.dart';
import 'package:new_tag_and_seal_flutter_app/features/dashboard/widgets/stat_card.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/farm_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/presentation/farm_user_form.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/presentation/extension_officer_invite_form_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/provider/farm_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/presentation/provider/notification_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/provider/finance_income_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/reports/presentation/provider/finance_expense_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/presentation/notification_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  static const String _syncPromptStorageKey = 'dashboard_sync_prompt_shown';
  bool _isSyncing = false;
  final _secureStorage = const FlutterSecureStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> farmsWithLivestock = [];
  int _totalEventCount = 0;
  SyncUnsyncedSummary _unsyncedSummary = const SyncUnsyncedSummary.empty();
  bool _isLogoutDialogOpen = false;
  FarmProvider? _farmProvider; // Store reference for cleanup
  EventsProvider? _eventsProvider;
  FinanceExpenseProvider? _financeExpenseProvider;
  FinanceIncomeProvider? _financeIncomeProvider;

  String _userName = '';
  String _userEmail = '';
  String? _roleTitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    getALlFarmsWithThereLivestocks();
    _loadEventSummary();
    _loadUnsyncedSummary();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSyncToast());

    // Listen to FarmProvider changes to auto-refresh when farms are created/updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _farmProvider = Provider.of<FarmProvider>(context, listen: false);
        _farmProvider?.addListener(_onFarmProviderChanged);
        _eventsProvider = Provider.of<EventsProvider>(context, listen: false);
        _eventsProvider?.addListener(_onEventsProviderChanged);
        _financeExpenseProvider = Provider.of<FinanceExpenseProvider>(
          context,
          listen: false,
        );
        _financeExpenseProvider?.addListener(_onFinanceExpenseProviderChanged);
        _financeIncomeProvider = Provider.of<FinanceIncomeProvider>(
          context,
          listen: false,
        );
        _financeIncomeProvider?.addListener(_onFinanceIncomeProviderChanged);
      }
    });
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    _farmProvider?.removeListener(_onFarmProviderChanged);
    _eventsProvider?.removeListener(_onEventsProviderChanged);
    _financeExpenseProvider?.removeListener(_onFinanceExpenseProviderChanged);
    _financeIncomeProvider?.removeListener(_onFinanceIncomeProviderChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      getALlFarmsWithThereLivestocks();
      _loadEventSummary();
      _loadUnsyncedSummary();
    }
  }

  /// Called when FarmProvider notifies listeners (e.g., after farm creation)
  void _onFarmProviderChanged() {
    if (mounted) {
      debugPrint('🔄 FarmProvider changed - refreshing dashboard...');
      getALlFarmsWithThereLivestocks();
    }
  }

  /// Called when events change so the dashboard counts stay current.
  void _onEventsProviderChanged() {
    if (mounted) {
      debugPrint('🔄 EventsProvider changed - refreshing dashboard counts...');
      _loadEventSummary();
      _loadUnsyncedSummary();
    }
  }

  /// Called when manual expenses change so the unsynced banner stays current.
  void _onFinanceExpenseProviderChanged() {
    if (mounted) {
      debugPrint(
        '🔄 FinanceExpenseProvider changed - refreshing unsynced summary...',
      );
      _loadUnsyncedSummary();
    }
  }

  /// Called when manual incomes change so the unsynced banner stays current.
  void _onFinanceIncomeProviderChanged() {
    if (mounted) {
      debugPrint(
        '🔄 FinanceIncomeProvider changed - refreshing unsynced summary...',
      );
      _loadUnsyncedSummary();
    }
  }

  Future<void> _loadUserData() async {
    final firstname = await _secureStorage.read(key: 'firstname') ?? '';
    final surname = await _secureStorage.read(key: 'surname') ?? '';
    final email = await _secureStorage.read(key: 'email') ?? '';
    final roleTitle = await _secureStorage.read(key: 'roleTitle');

    if (mounted) {
      setState(() {
        _userName = '$firstname $surname'.trim();
        if (_userName.isEmpty) {
          _userName = 'User';
        }
        _userEmail = email;
        _roleTitle = roleTitle;
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

  Future<void> _loadUnsyncedSummary() async {
    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      final summary = await Sync.getUnsyncedSummary(database);
      if (!mounted) return;
      setState(() {
        _unsyncedSummary = summary;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _unsyncedSummary = const SyncUnsyncedSummary.empty();
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

    // After successful sync (and user taps OK on the dialog), refresh dashboard data
    if (!mounted) return;
    await getALlFarmsWithThereLivestocks();
    await _loadEventSummary();
    await _loadUnsyncedSummary();

    if (!mounted) return;
    setState(() {
      _isSyncing = false;
    });
  }

  Future<void> _showSyncToast() async {
    if (!mounted) return;

    // Check if sync prompt has been shown before for this user/role
    final prefs = await SharedPreferences.getInstance();
    final userId = await _secureStorage.read(key: 'userId') ?? '';
    final role = await _secureStorage.read(key: 'role') ?? '';
    final normalizedRole = role.toLowerCase().replaceAll(RegExp(r'[ _-]+'), '');
    final syncKey = '${_syncPromptStorageKey}_${userId}_${normalizedRole}';

    // Check if prompt was already shown
    final hasShownBefore = prefs.getBool(syncKey) ?? false;
    if (hasShownBefore) {
      print('✅ Sync prompt already shown for user $userId with role $role');
      return;
    }

    // Show prompt once per dashboard mount, after a short delay
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Mark as shown in SharedPreferences
    await prefs.setBool(syncKey, true);
    print('📝 Marked sync prompt as shown for user $userId with role $role');

    final l10n = AppLocalizations.of(context)!;
    // Use dialogContext for Navigator to avoid using a disposed context

    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false, // Make dialog non-dismissible (mandatory sync)
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final isDark = theme.brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(l10n.sync),
          content: Text(
            l10n.dashboardSyncPrompt,
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            // Only sync button - mandatory sync
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _syncData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.sync),
            ),
          ],
        );
      },
    );
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
          'location':
              farm.physicalAddress ?? 'Unknown Location', // Use fallback string
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

    await _loadEventSummary();
    await _loadUnsyncedSummary();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final notificationProvider = context.watch<NotificationProvider>();
    final totalNotifications = notificationProvider.notifications.length;
    final authProvider = context.read<AuthProvider>();
    final isFarmer = authProvider.isFarmer;
    final isExtensionOfficer = authProvider.isExtensionOfficer;
    final roleTitleNormalized =
        (((authProvider.currentProfile?['roleTitle'] as String?) ?? '')
            .toLowerCase()
            .trim());
    final isFarmManager = authProvider.isFarmUser
        ? (roleTitleNormalized == 'farm-manager' ||
              roleTitleNormalized == 'farmer_manager')
        : false;
    final isVaccinationFarmUser = authProvider.isFarmUser
        ? (((authProvider.currentProfile?['roleTitle'] as String?) ?? '')
                  .toLowerCase()
                  .trim() ==
              'vaccination-user')
        : false;
    final hasDrawerAccess =
        isFarmer ||
        isFarmManager ||
        isExtensionOfficer ||
        isVaccinationFarmUser;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        await _onLogoutPressed();
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: hasDrawerAccess
            ? Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final localIsFarmer = authProvider.isFarmer;
                  final localIsExtensionOfficer =
                      authProvider.isExtensionOfficer;
                  final localRoleTitleNormalized =
                      (((authProvider.currentProfile?['roleTitle']
                                  as String?) ??
                              '')
                          .toLowerCase()
                          .trim());
                  final localIsFarmManager = authProvider.isFarmUser
                      ? (localRoleTitleNormalized == 'farm-manager' ||
                            localRoleTitleNormalized == 'farmer_manager')
                      : false;
                  final localIsVaccinationFarmUser = authProvider.isFarmUser
                      ? (((authProvider.currentProfile?['roleTitle']
                                        as String?) ??
                                    '')
                                .toLowerCase()
                                .trim() ==
                            'vaccination-user')
                      : false;
                  if (!(localIsFarmer ||
                      localIsFarmManager ||
                      localIsExtensionOfficer ||
                      localIsVaccinationFarmUser)) {
                    return const SizedBox.shrink();
                  }
                  return DashboardDrawer(
                    userName: _userName,
                    userEmail: _userEmail,
                    roleTitle: _roleTitle,
                    onLogout: _onLogoutPressed,
                    showFarmUsersLink: localIsFarmer,
                    showExtensionsLink: localIsFarmer,
                    showBillsLink: localIsFarmer || localIsExtensionOfficer,
                    showReportsLink: localIsFarmer || localIsFarmManager,
                  );
                },
              )
            : null,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            bottom: _unsyncedSummary.hasPending ? 75 : 0,
          ),
          child: FloatingActionButton(
            heroTag: 'dashboard_sync_fab',
            onPressed: () => _syncData(),
            child: _isSyncing
                ? const LoadingIndicator(
                    size: 20,
                    strokeWidth: 2,
                    color: Colors.white,
                  )
                : const Icon(Iconsax.refresh_outline, color: Colors.white),
          ),
        ),
        appBar: AppBar(
          centerTitle: hasDrawerAccess,
          automaticallyImplyLeading: false,
          leadingWidth: hasDrawerAccess ? null : 0,
          titleSpacing: hasDrawerAccess ? null : 0,
          toolbarHeight: kToolbarHeight,
          title: hasDrawerAccess
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${l10n.welcome},',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
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
                )
              : Transform.translate(
                  offset: const Offset(0, 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${l10n.welcome},',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
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
                  ),
                ),

          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: hasDrawerAccess
              ? Align(
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
                )
              : null,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Iconsax.notification_outline,
                      color: theme.colorScheme.onSurface,
                    ),
                    if (totalNotifications > 0)
                      Positioned(
                        top: -6,
                        right: -8,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            totalNotifications > 9
                                ? '9+'
                                : '$totalNotifications',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              onRefresh: () async {
                // await _loadUserData();
                await getALlFarmsWithThereLivestocks();
                await _loadEventSummary();
                await _loadUnsyncedSummary();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  _unsyncedSummary.hasPending ? 140 : 80,
                ),
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
                        // Check if user is a farmer
                        if (!RoleHelper.checkFarmerRole(context, l10n)) {
                          return;
                        }

                        // Navigate to create farm
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FarmFormScreen(),
                          ),
                        );

                        debugPrint(
                          '🔄 Dashboard received navigation result: $result',
                        );

                        // Reload farms and event summary if farm was successfully created
                        if (result == true && mounted) {
                          debugPrint('🔄 Refreshing dashboard data...');
                          await getALlFarmsWithThereLivestocks();
                          debugPrint('✅ Dashboard refresh completed');
                        } else {
                          debugPrint(
                            '⚠️ Dashboard refresh skipped - result: $result, mounted: $mounted',
                          );
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
                        // Check if user is a farmer
                        if (!RoleHelper.checkFarmerRole(context, l10n)) {
                          return;
                        }

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FarmUserFormScreen(),
                          ),
                        );
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
                        // Check if user is a farmer
                        if (!RoleHelper.checkFarmerRole(context, l10n)) {
                          return;
                        }

                        // Navigate to extension officer invite form
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const ExtensionOfficerInviteFormScreen(),
                          ),
                        );
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

            if (_unsyncedSummary.hasPending)
              Positioned(
                left: 12,
                right: 12,
                bottom: 16,
                child: SafeArea(
                  top: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 84, 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.65),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sync_problem_rounded,
                          size: 20,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.syncRequiredMessage(
                              _unsyncedSummary.totalPending,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(l10n.logout),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.hasPending
                    ? l10n.unsyncedDataWarning
                    : l10n.noUnsyncedDataMessage,
              ),
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
        if (context.mounted) {
          await context.read<LogAdditionalDataProvider>().loadFromLocal();
        }
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
    });

    // Clear sync prompt flag so it's shown again next time user logs in (per user+role and legacy)
    final prefs = await SharedPreferences.getInstance();
    final userId = await _secureStorage.read(key: 'userId') ?? '';
    final role = await _secureStorage.read(key: 'role') ?? '';
    final normalizedRole = role.toLowerCase().replaceAll(RegExp(r'[ _-]+'), '');
    final syncKey = '${_syncPromptStorageKey}_${userId}_${normalizedRole}';
    await prefs.remove(syncKey);
    await prefs.remove(_syncPromptStorageKey); // legacy cleanup

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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
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
    addItem(l10n.invitedUsersText, summary.farmUsers);

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
      case 'calving':
        return l10n.calving;
      case 'farrowings':
      case 'farrowing':
        return l10n.farrowing;
      case 'dryoffs':
        return l10n.dryoff;
      case 'inseminations':
        return l10n.insemination;
      case 'transfers':
      case 'transfer':
        return l10n.transfer;
      case 'abortedPregnancies':
      case 'abortedPregnancy':
        return l10n.abortedPregnancy;
      default:
        return key;
    }
  }
}
