import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/sync.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/provider/all.additional.data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/login/login_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/provider/farm_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/features/settings/presentation/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _secureStorage = const FlutterSecureStorage();
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userRole = '';
  bool _isLoading = true;
  bool _isStatsLoading = true;
  List<Map<String, dynamic>> _farmsWithLivestock = [];
  int _totalEventCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAnalytics();
  }

  Future<void> _loadUserData() async {
    final firstname = await _secureStorage.read(key: 'firstname') ?? '';
    final surname = await _secureStorage.read(key: 'surname') ?? '';
    final email = await _secureStorage.read(key: 'email') ?? '';
    final phone = await _secureStorage.read(key: 'phone1') ?? '';
    final role = await _secureStorage.read(key: 'role') ?? 'Farmer';
    
    if (mounted) {
      setState(() {
        _userName = '$firstname $surname'.trim();
        if (_userName.isEmpty) {
          _userName = 'User';
        }
        _userEmail = email;
        _userPhone = phone;
        _userRole = role;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      final farmProvider =
          Provider.of<FarmProvider>(context, listen: false);
      final eventsProvider =
          Provider.of<EventsProvider>(context, listen: false);

      final farmsData = await farmProvider.getAllFarmsWithLivestock();
      final eventSummary = await eventsProvider.getEventSummary();

      if (!mounted) return;

      final transformed = (farmsData ?? [])
          .map<Map<String, dynamic>>((farmData) {
        final farm = farmData['farm'];
        final livestock = farmData['livestock'] as List? ?? const [];
        final livestockCount = farmData['livestockCount'] as int? ?? livestock.length;

        return {
          'name': farm.name,
          'livestockCount': livestockCount,
          'uuid': farm.uuid,
        };
      }).toList();

      setState(() {
        _farmsWithLivestock = transformed;
        _totalEventCount = eventSummary.totalCount;
        _isStatsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _farmsWithLivestock = const [];
        _totalEventCount = 0;
        _isStatsLoading = false;
      });
    }
  }

  int get _totalLivestockCount => _farmsWithLivestock.fold<int>(
        0,
        (sum, farm) => sum + (farm['livestockCount'] as int? ?? 0),
      );

  int get _totalFarmCount => _farmsWithLivestock.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [

                  // Gradient Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Constants.primaryColor,
                          Constants.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [

                            Row(
                              children: [
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Iconsax.setting_2_outline,
                                      color: Colors.white, size: 22),
                                  onPressed: _openSettings,
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Profile Avatar with Gradient Border
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Colors.white, Colors.white70],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Iconsax.user_outline,
                                size: 50,
                                color: Constants.primaryColor,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Profile Details Card
                  Transform.translate(
                    offset: const Offset(0, 5),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: isDark ? null : LinearGradient(
                          colors: [
                            Constants.primaryColor.withValues(alpha: 0.05),
                            Colors.grey.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.grey.withValues(alpha: 0.1),
                            blurRadius: isDark ? 0 : 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // User Details Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? Colors.grey.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark 
                                    ? Colors.grey.withValues(alpha: 0.6)
                                    : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Iconsax.user_tick_outline,
                                      color: Constants.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.personalInformation,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Constants.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                _buildDetailItem(
                                  context: context,
                                  icon: Iconsax.user_outline,
                                  label: l10n.firstName,
                                  value: _userName,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                _buildDetailItem(
                                  context: context,
                                  icon: Iconsax.sms_outline,
                                  label: l10n.email,
                                  value: _userEmail,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                _buildDetailItem(
                                  context: context,
                                  icon: Iconsax.call_outline,
                                  label: l10n.phone1,
                                  value: _userPhone.isNotEmpty ? _userPhone : '${l10n.notProvided}',
                                ),
                                
                                const SizedBox(height: 16),
                                
                                _buildDetailItem(
                                  context: context,
                                  icon: Iconsax.shield_tick_outline,
                                  label: l10n.role,
                                  value: _userRole,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Profile Stats
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: _isStatsLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: LoadingIndicator(size: 28),
                            ),
                          )
                        : Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: l10n.livestock,
                                  value: '$_totalLivestockCount',
                            icon: Iconsax.pet_outline,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: l10n.events,
                                  value: '$_totalEventCount',
                            icon: Iconsax.calendar_outline,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: l10n.farms,
                                  value: '$_totalFarmCount',
                            icon: FontAwesome.seedling_solid,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                
                  const SizedBox(height: 20),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: CustomButton(
                      text: l10n.logout,
                      onPressed: _onLogoutPressed,
                      isLoading: false,
                      width: double.infinity,
                      color: Colors.redAccent,
                    ),
                  ),

                  const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Constants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Constants.primaryColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? null : LinearGradient(
          colors: [
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: isDark ? Colors.grey[800] : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? theme.colorScheme.outline.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onLogoutPressed() async {
    final database = Provider.of<AppDatabase>(context, listen: false);
    SyncUnsyncedSummary summary;

    try {
      summary = await Sync.getUnsyncedSummary(database);
    } catch (_) {
      summary = const SyncUnsyncedSummary.empty();
    }

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade700 : Colors.white,
          surfaceTintColor: Colors.transparent,
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
                ..._buildUnsyncedSummaryItems(l10n, summary),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            if (summary.hasPending)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logoutFlow(syncBefore: true);
                },
                child: Text(l10n.syncAndLogout),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logoutFlow(syncBefore: false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutFlow({required bool syncBefore}) async {
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
      // ignore database clearing errors but continue logout flow
    }

    eventsProvider.clear();
    additionalDataProvider.clearLocationData();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openSettings() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  List<Widget> _buildUnsyncedSummaryItems(
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

