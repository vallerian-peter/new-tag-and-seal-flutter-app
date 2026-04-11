import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/role_helper.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/livestock_form_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/piglet_bulk_registration_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/provider/livestock_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/widgets/livestock_stat_card.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/widgets/livestock_card.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/widgets/livestock_details_modal.dart';
import 'package:provider/provider.dart';

/// Livestock List Screen
/// 
/// Architecture Flow:
/// Screen → Provider → Domain Repo → Data Repository → DAO
class LivestockListScreen extends StatefulWidget {
  const LivestockListScreen({super.key});

  @override
  State<LivestockListScreen> createState() => _LivestockListScreenState();
}

class _LivestockListScreenState extends State<LivestockListScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenderFilter = 'All';
  String _selectedStatusFilter = 'All';
  int? _selectedLivestockTypeId;
  int? _selectedStageId;
  String? _selectedMotherFilterUuid;
  String? _selectedFatherFilterUuid;
  String _currentSearchQuery = '';
  List<LivestockType> _livestockTypes = [];
  List<Stage> _allStages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Fetch data after the first frame so Provider dependencies are guaranteed to be available.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _fetchLivestockTypes();
      await _fetchData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchData();
    }
  }

  /// Fetch livestock types immediately (lightweight operation)
  Future<void> _fetchLivestockTypes() async {
    if (!mounted) return;

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      final livestockProvider =
          Provider.of<LivestockProvider>(context, listen: false);

      final livestockTypes = await database.livestockTypeDao.getAllLivestockTypes();
      final stages = await database.stageDao.getAllStages();

      if (!mounted) return;

      final livestockTypeNamesMap = <int, String>{};
      for (final type in livestockTypes) {
        livestockTypeNamesMap[type.id] = type.name;
      }
      livestockProvider.setLivestockTypeNames(livestockTypeNamesMap);

      setState(() {
        _livestockTypes = livestockTypes;
        _allStages = stages;
        _syncStageSelectionWithType();
      });
    } catch (_) {
      // Reference data may be empty before first sync; list still usable.
    }
  }

  Future<void> _fetchData() async {
    final livestockProvider =
        Provider.of<LivestockProvider>(context, listen: false);
    final database = Provider.of<AppDatabase>(context, listen: false);

    // Fetch livestock through provider
    await livestockProvider.fetchAllLivestock();

    // Fetch farm names
    final farms = await database.farmDao.getAllActiveFarms();
    final farmNamesMap = <String, String>{};
    for (var farm in farms) {
      farmNamesMap[farm.uuid] = farm.name;
    }
    livestockProvider.setFarmNames(farmNamesMap);

    // Refresh livestock types in case they were updated during sync.
    if (mounted) {
      await _fetchLivestockTypes();
    }
  }

  List<Stage> get _stagesForSelectedType {
    if (_selectedLivestockTypeId == null) return const [];
    final list = _allStages
        .where((s) => s.livestockTypeId == _selectedLivestockTypeId)
        .toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  void _syncStageSelectionWithType() {
    if (_selectedStageId == null) return;
    if (_selectedLivestockTypeId == null) {
      _selectedStageId = null;
      return;
    }
    final valid = _stagesForSelectedType.any((s) => s.id == _selectedStageId);
    if (!valid) {
      _selectedStageId = null;
    }
  }

  void _onLivestockTypeFilterSelected(int? typeId) {
    setState(() {
      _selectedLivestockTypeId = typeId; // null means "All"
      _syncStageSelectionWithType();
    });
    _applyFilters();
  }

  void _onStageFilterSelected(int? stageId) {
    setState(() {
      _selectedStageId = stageId;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final livestockProvider =
        Provider.of<LivestockProvider>(context, listen: false);
    livestockProvider.filterLivestock(
      _currentSearchQuery,
      genderFilter: _selectedGenderFilter,
      statusFilter: _selectedStatusFilter,
      livestockTypeId: _selectedLivestockTypeId,
      stageId: _selectedStageId,
      motherUuid: _selectedMotherFilterUuid,
      fatherUuid: _selectedFatherFilterUuid,
    );
  }

  bool get _noAdvancedFilters =>
      _selectedGenderFilter == 'All' &&
      _selectedStatusFilter == 'All' &&
      _selectedLivestockTypeId == null &&
      _selectedStageId == null &&
      _selectedMotherFilterUuid == null &&
      _selectedFatherFilterUuid == null;

  void _onSearchChanged(String query) {
    setState(() {
      _currentSearchQuery = query;
    });
    _applyFilters();
  }

  void _onClearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _onSortSelected(String sortOption) {
    final livestockProvider =
        Provider.of<LivestockProvider>(context, listen: false);
    livestockProvider.sortLivestock(sortOption);
  }

  Future<void> _showRegisterLivestockSheet(AppLocalizations l10n) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!RoleHelper.checkCanCreateLivestock(context, l10n, authProvider)) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) {
        final sheetTheme = Theme.of(ctx);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    l10n.registerLivestockHowTitle,
                    style: sheetTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.pets, color: Constants.primaryColor),
                  title: Text(l10n.registerLivestockSingleOption),
                  subtitle: Text(l10n.registerLivestockSingleOptionDesc),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LivestockFormScreen(),
                      ),
                    );
                    if (result == true && mounted) await _fetchData();
                  },
                ),
                
                Divider(
                  color: Theme.of(context).colorScheme.tertiary.withAlpha(30),
                ),

                ListTile(
                  leading: Icon(
                    Icons.groups_2_outlined,
                    color: Constants.primaryColor,
                  ),
                  title: Text(l10n.registerPigletLitterOption),
                  subtitle: Text(l10n.registerPigletLitterOptionDesc),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PigletBulkRegistrationScreen(),
                      ),
                    );
                    if (result == true && mounted) await _fetchData();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<LivestockProvider>(
          builder: (context, livestockProvider, child) {
            return RefreshIndicator(
              color: Colors.black87,
              backgroundColor: Colors.white,
              onRefresh: _fetchData,
              child: CustomScrollView(
                slivers: [

                  // Header
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, 
                      vertical: 5
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.allLivestocksText,
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.manageAndTrackLivestockText,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: _fetchData,
                                icon: const Icon(Icons.refresh),
                                tooltip: l10n.refresh,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Stats Cards
                          Row(
                            children: [
                              Expanded(
                                child: LivestockStatCard(
                                  title: l10n.total,
                                  value: '${livestockProvider.totalCount}',
                                  icon: Iconsax.pet_outline,
                                  color: Constants.primaryColor,
                                  isSelected: _noAdvancedFilters,
                                  onTap: () {
                                    setState(() {
                                      _selectedGenderFilter = 'All';
                                      _selectedStatusFilter = 'All';
                                      _selectedLivestockTypeId = null;
                                      _selectedStageId = null;
                                      _selectedMotherFilterUuid = null;
                                      _selectedFatherFilterUuid = null;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ),
                              
                              const SizedBox(width: 12),

                              Expanded(
                                child: LivestockStatCard(
                                  title: l10n.male,
                                  value: '${livestockProvider.maleCount}',
                                  icon: Bootstrap.gender_male,
                                  color: Colors.blue,
                                  isSelected: _selectedGenderFilter == 'Male',
                                  onTap: () {
                                    setState(() {
                                      _selectedGenderFilter = _selectedGenderFilter == 'Male' ? 'All' : 'Male';
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ),

                              const SizedBox(width: 12),
                              
                              Expanded(
                                child: LivestockStatCard(
                                  title: l10n.female,
                                  value: '${livestockProvider.femaleCount}',
                                  icon: Bootstrap.gender_female,
                                  color: Colors.pink,
                                  isSelected: _selectedGenderFilter == 'Female',
                                  onTap: () {
                                    setState(() {
                                      _selectedGenderFilter = _selectedGenderFilter == 'Female' ? 'All' : 'Female';
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: l10n.searchText,
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                  fontSize: 16,
                                ),
                                prefixIcon: Icon(
                                  Iconsax.search_normal_outline,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                  size: 22,
                                ),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_searchController.text.isNotEmpty)
                                      IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.5),
                                          size: 20,
                                        ),
                                        onPressed: _onClearSearch,
                                      ),
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Iconsax.sort_outline,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.5),
                                      ),
                                      color: isDarkMode
                                          ? Colors.grey[700]
                                          : Colors.white,
                                      onSelected: _onSortSelected,
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                            value: 'A to Z',
                                            child: Text(l10n.sortAtoZ)),
                                        PopupMenuItem(
                                            value: 'Z to A',
                                            child: Text(l10n.sortZtoA)),
                                        PopupMenuItem(
                                            value: 'Newest First',
                                            child: Text(l10n.newestFirst)),
                                        PopupMenuItem(
                                            value: 'Oldest First',
                                            child: Text(l10n.oldestFirst)),
                                      ],
                                    ),
                                  ],
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Combined Filters Row - All horizontal
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // All Filter
                                _buildFilterPill(
                                  context,
                                  label: l10n.allText,
                                  isSelected: _noAdvancedFilters,
                                  onTap: () {
                                    setState(() {
                                      _selectedGenderFilter = 'All';
                                      _selectedStatusFilter = 'All';
                                      _selectedLivestockTypeId = null;
                                      _selectedStageId = null;
                                      _selectedMotherFilterUuid = null;
                                      _selectedFatherFilterUuid = null;
                                    });
                                    _applyFilters();
                                  },
                                ),
                                const SizedBox(width: 8),
                                // Gender Filters
                                _buildFilterPill(
                                  context,
                                  label: l10n.male,
                                  isSelected: _selectedGenderFilter == 'Male',
                                  onTap: () {
                                    setState(() {
                                      _selectedGenderFilter = _selectedGenderFilter == 'Male' ? 'All' : 'Male';
                                    });
                                    _applyFilters();
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildFilterPill(
                                  context,
                                  label: l10n.female,
                                  isSelected: _selectedGenderFilter == 'Female',
                                  onTap: () {
                                    setState(() {
                                      _selectedGenderFilter = _selectedGenderFilter == 'Female' ? 'All' : 'Female';
                                    });
                                    _applyFilters();
                                  },
                                ),
                                const SizedBox(width: 8),
                                // Status Filters
                                _buildFilterPill(
                                  context,
                                  label: _selectedMotherFilterUuid == null
                                      ? l10n.filterByMother
                                      : '${l10n.filterByMother}: ${_parentNameByUuid(_selectedMotherFilterUuid!, livestockProvider)}',
                                  isSelected: _selectedMotherFilterUuid != null,
                                  onTap: () => _showParentFilterSheet(
                                    isMother: true,
                                    livestockProvider: livestockProvider,
                                    l10n: l10n,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildFilterPill(
                                  context,
                                  label: _selectedFatherFilterUuid == null
                                      ? l10n.filterByFather
                                      : '${l10n.filterByFather}: ${_parentNameByUuid(_selectedFatherFilterUuid!, livestockProvider)}',
                                  isSelected: _selectedFatherFilterUuid != null,
                                  onTap: () => _showParentFilterSheet(
                                    isMother: false,
                                    livestockProvider: livestockProvider,
                                    l10n: l10n,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildFilterPill(
                                  context,
                                  label: l10n.active,
                                  isSelected: _selectedStatusFilter == 'active',
                                  onTap: () {
                                    setState(() {
                                      _selectedStatusFilter = _selectedStatusFilter == 'active' ? 'All' : 'active';
                                    });
                                    _applyFilters();
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildFilterPill(
                                  context,
                                  label: l10n.notActive,
                                  isSelected: _selectedStatusFilter == 'notActive',
                                  onTap: () {
                                    setState(() {
                                      _selectedStatusFilter = _selectedStatusFilter == 'notActive' ? 'All' : 'notActive';
                                    });
                                    _applyFilters();
                                  },
                                ),
                                const SizedBox(width: 12),
                                // Livestock type + stage (stage options depend on type)
                                SizedBox(
                                  width: 148,
                                  child: _buildLivestockTypeDropdown(context, l10n),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 152,
                                  child: _buildStageFilterDropdown(context, l10n),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  if (livestockProvider.isLoading)
                    _buildLoadingState()
                  else if (livestockProvider.allLivestock.isEmpty)
                    _buildEmptyState(l10n)
                  else if (livestockProvider.filteredLivestock.isEmpty)
                    _buildNoSearchResults(l10n)
                  else
                    _buildLivestockList(livestockProvider),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'livestock_list_fab',
        onPressed: () => _showRegisterLivestockSheet(l10n),
        backgroundColor: Constants.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.addLivestock,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SliverFillRemaining(
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.pet_outline,
              size: 64,
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noLivestockFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addFirstLivestockMessage,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_normal_outline,
              size: 64,
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noResultsFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryDifferentKeywords,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivestockList(LivestockProvider livestockProvider) {
    final l10n = AppLocalizations.of(context)!;

    return SliverPadding(
      // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final livestock = livestockProvider.filteredLivestock[index];
            return LivestockCard(
              livestock: livestock,
              farmName: livestockProvider.farmNames[livestock.farmUuid] ??
                l10n.unknownFarm,
              onTap: () => LivestockDetailsModal.show(
                context: context,
                livestock: livestock,
                farmNames: livestockProvider.farmNames,
                onRefresh: _fetchData,
              ),
            );
          },
          childCount: livestockProvider.filteredLivestock.length,
        ),
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Constants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Constants.primaryColor
                : theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _parentNameByUuid(String uuid, LivestockProvider livestockProvider) {
    for (final l in livestockProvider.allLivestock) {
      if (l.uuid == uuid) {
        return l.name.isNotEmpty ? l.name : '#${l.id}';
      }
    }
    return '—';
  }

  Future<void> _showParentFilterSheet({
    required bool isMother,
    required LivestockProvider livestockProvider,
    required AppLocalizations l10n,
  }) async {
    final theme = Theme.of(context);
    final targetGender = isMother ? 'female' : 'male';
    final parents = livestockProvider.allLivestock
        .where((l) => l.gender.toLowerCase() == targetGender)
        .toList();
    parents.sort((a, b) {
      final an = a.name.isNotEmpty ? a.name : '#${a.id}';
      final bn = b.name.isNotEmpty ? b.name : '#${b.id}';
      return an.toLowerCase().compareTo(bn.toLowerCase());
    });

    final selectedUuid = isMother ? _selectedMotherFilterUuid : _selectedFatherFilterUuid;
    final searchController = TextEditingController();
    String query = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (ctx) {
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.72;
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final filtered = parents.where((p) {
              if (query.trim().isEmpty) return true;
              final n = p.name.isNotEmpty ? p.name : '#${p.id}';
              final idNo = p.identificationNumber;
              final q = query.toLowerCase();
              return n.toLowerCase().contains(q) || idNo.toLowerCase().contains(q);
            }).toList();

            int childrenCountFor(String parentUuid) {
              if (isMother) {
                return livestockProvider.allLivestock
                    .where((c) => c.motherUuid == parentUuid)
                    .length;
              }
              return livestockProvider.allLivestock
                  .where((c) => c.fatherUuid == parentUuid)
                  .length;
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: sheetHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMother ? l10n.filterByMother : l10n.filterByFather,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchController,
                        onChanged: (v) => setLocal(() => query = v),
                        decoration: InputDecoration(
                          hintText: l10n.searchText,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              if (isMother) {
                                _selectedMotherFilterUuid = null;
                              } else {
                                _selectedFatherFilterUuid = null;
                              }
                            });
                            _applyFilters();
                            Navigator.of(ctx).pop();
                          },
                          child: Text(l10n.allText),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => Divider(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            height: 1,
                          ),
                          itemBuilder: (_, i) {
                            final parent = filtered[i];
                            final parentLabel = parent.name.isNotEmpty
                                ? parent.name
                                : '${l10n.livestock} #${parent.id}';
                            final childrenCount = childrenCountFor(parent.uuid);
                            final isSelected = selectedUuid == parent.uuid;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              selected: isSelected,
                              selectedTileColor:
                                  Constants.primaryColor.withValues(alpha: 0.08),
                              title: Text(
                                parentLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                l10n.parentFilterChildrenCount(childrenCount),
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              onTap: () {
                                setState(() {
                                  if (isMother) {
                                    _selectedMotherFilterUuid = parent.uuid;
                                  } else {
                                    _selectedFatherFilterUuid = parent.uuid;
                                  }
                                });
                                _applyFilters();
                                Navigator.of(ctx).pop();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    searchController.dispose();
  }

  /// Shared compact menu control for reference filters (type, stage) in the filter row.
  Widget _buildCompactReferenceFilterMenu({
    required Key menuKey,
    required String displayText,
    required bool enabled,
    required bool selectionActive,
    required ValueChanged<int?> onSelected,
    required List<PopupMenuEntry<int?>> Function(BuildContext context) itemBuilder,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return PopupMenuButton<int?>(
      key: menuKey,
      onSelected: enabled
          ? onSelected
          : (_) {
              // Menu does not open when disabled; kept for API compatibility.
            },
      itemBuilder: itemBuilder,
      enabled: enabled,
      color: isDarkMode ? Colors.grey[700] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? theme.colorScheme.outline.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selectionActive ? FontWeight.w600 : FontWeight.w500,
                  color: selectionActive
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 22,
              color: theme.colorScheme.onSurface.withOpacity(enabled ? 0.5 : 0.25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivestockTypeDropdown(BuildContext context, AppLocalizations l10n) {
    String displayText = l10n.livestockType;
    if (_selectedLivestockTypeId != null && _livestockTypes.isNotEmpty) {
      for (final type in _livestockTypes) {
        if (type.id == _selectedLivestockTypeId) {
          displayText = type.name;
          break;
        }
      }
    }

    return _buildCompactReferenceFilterMenu(
      menuKey: ValueKey('livestock_type_menu_${_livestockTypes.length}'),
      displayText: displayText,
      enabled: true,
      selectionActive: _selectedLivestockTypeId != null,
      onSelected: _onLivestockTypeFilterSelected,
      itemBuilder: (ctx) {
        final items = <PopupMenuEntry<int?>>[
          PopupMenuItem<int?>(
            value: null,
            child: Text(l10n.allText, style: const TextStyle(fontSize: 12)),
          ),
        ];
        for (final type in _livestockTypes) {
          items.add(
            PopupMenuItem<int?>(
              value: type.id,
              child: Text(type.name, style: const TextStyle(fontSize: 12)),
            ),
          );
        }
        return items;
      },
    );
  }

  Widget _buildStageFilterDropdown(BuildContext context, AppLocalizations l10n) {
    final stages = _stagesForSelectedType;
    final typeSelected = _selectedLivestockTypeId != null;
    final hasStages = stages.isNotEmpty;
    final enabled = typeSelected && hasStages;

    late String displayText;
    if (!typeSelected) {
      displayText = l10n.pleaseSelectLivestockType;
    } else if (!hasStages) {
      displayText = l10n.noStagesForThisType;
    } else if (_selectedStageId != null) {
      displayText = l10n.stage;
      for (final s in stages) {
        if (s.id == _selectedStageId) {
          displayText = s.name;
          break;
        }
      }
    } else {
      displayText = '${l10n.allText} · ${l10n.stage}';
    }

    return _buildCompactReferenceFilterMenu(
      menuKey: ValueKey(
        'stage_menu_${_selectedLivestockTypeId}_${stages.length}_$_selectedStageId',
      ),
      displayText: displayText,
      enabled: enabled,
      selectionActive: enabled && _selectedStageId != null,
      onSelected: _onStageFilterSelected,
      itemBuilder: (ctx) {
        final items = <PopupMenuEntry<int?>>[
          PopupMenuItem<int?>(
            value: null,
            child: Text(
              '${l10n.allText} (${l10n.stage})',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ];
        for (final stage in stages) {
          items.add(
            PopupMenuItem<int?>(
              value: stage.id,
              child: Text(stage.name, style: const TextStyle(fontSize: 12)),
            ),
          );
        }
        return items;
      },
    );
  }
}
