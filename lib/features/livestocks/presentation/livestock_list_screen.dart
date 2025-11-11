import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/livestock_form_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/provider/livestock_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/widgets/livestock_stat_card.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/widgets/livestock_filter_pills.dart';
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
  String _selectedFilter = 'All';
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchData();
      }
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
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    final livestockProvider =
        Provider.of<LivestockProvider>(context, listen: false);
    livestockProvider.filterLivestock(_currentSearchQuery, filter);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentSearchQuery = query;
    });
    final livestockProvider =
        Provider.of<LivestockProvider>(context, listen: false);
    livestockProvider.filterLivestock(query, _selectedFilter);
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
                                            .withOpacity(0.6),
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
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: LivestockStatCard(
                                  title: l10n.male,
                                  value: '${livestockProvider.maleCount}',
                                  icon: Bootstrap.gender_male,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: LivestockStatCard(
                                  title: l10n.female,
                                  value: '${livestockProvider.femaleCount}',
                                  icon: Bootstrap.gender_female,
                                  color: Colors.pink,
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

                          // Filter Pills
                          LivestockFilterPills(
                            selectedFilter: _selectedFilter,
                            onFilterSelected: _onFilterSelected,
                            filters: [
                              FilterOption(label: l10n.allText, value: 'All'),
                              FilterOption(label: l10n.male, value: 'Male'),
                              FilterOption(label: l10n.female, value: 'Female'),
                            ],
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const LivestockFormScreen()),
          ).then((_) => _fetchData());
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
}
