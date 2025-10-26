import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/livestock_form_screen.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class LivestockListScreen extends StatefulWidget {
  const LivestockListScreen({super.key});

  @override
  State<LivestockListScreen> createState() => _LivestockListScreenState();
}

class _LivestockListScreenState extends State<LivestockListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<Livestock> _allLivestock = [];
  List<Livestock> _filteredLivestock = [];
  Map<String, String> _farmNames = {};  // Map<farmUuid, farmName>
  bool _isLoading = true;
  String _selectedFilter = 'All'; // Default filter
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchLivestockData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLivestockData() async {
    setState(() => _isLoading = true);
    
    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      
      // Fetch all livestock from database
      final livestock = await database.livestockDao.getAllLivestock();
      
      // Fetch farm names - map by UUID since farmUuid stores farm UUID
      final farms = await database.farmDao.getAllActiveFarms();
      final farmNamesMap = <String, String>{};  // Map<UUID, FarmName>
      for (var farm in farms) {
        farmNamesMap[farm.uuid] = farm.name;  // Map by farm UUID
      }
      
      setState(() {
        _allLivestock = livestock;
        _filteredLivestock = livestock;
        _farmNames = farmNamesMap;  // Map<String, String>
        _isLoading = false;
      });
      
      log('✅ Loaded ${livestock.length} livestock from ${farms.length} farms');
    } catch (e) {
      log('❌ Error fetching livestock: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterLivestock(String query) {
    setState(() {
      _currentSearchQuery = query;
      
      // Start with all livestock
      List<Livestock> baseList = _allLivestock;
      
      // First apply gender filter if not "All"
      if (_selectedFilter != 'All') {
        baseList = _allLivestock.where((livestock) {
          final gender = livestock.gender.toLowerCase();
          if (_selectedFilter == 'Male') {
            return gender == 'male' || gender == 'm' || gender == '1' || gender == 'kiume';
          } else if (_selectedFilter == 'Female') {
            return gender == 'female' || gender == 'f' || gender == '2' || gender == 'jike';
          }
          return true;
        }).toList();
      }
      
      // Then apply search filter
      if (query.isEmpty) {
        _filteredLivestock = baseList;
      } else {
        String searchQuery = query.toLowerCase();
        _filteredLivestock = baseList.where((livestock) {
          final matchesName = livestock.name.toLowerCase().contains(searchQuery);
          final matchesId = livestock.identificationNumber.toLowerCase().contains(searchQuery) ||
                           livestock.dummyTagId.toLowerCase().contains(searchQuery) ||
                           livestock.id.toString().contains(searchQuery);
          final matchesFarm = (_farmNames[livestock.farmUuid] ?? '').toLowerCase().contains(searchQuery);
          final matchesGender = livestock.gender.toLowerCase().contains(searchQuery);
          
          return matchesName || matchesId || matchesFarm || matchesGender;
        }).toList();
      }
    });
  }

  void _onFilterChanged(String filterKey) {
    setState(() {
      _selectedFilter = filterKey;
    });
    _filterLivestock(_currentSearchQuery);
  }

  void _onSearchChanged(String query) {
    _filterLivestock(query);
  }

  void _onClearSearch() {
    _searchController.clear();
    _filterLivestock('');
  }

  void _onSortSelected(String sortOption) {
    setState(() {
      if (sortOption == 'A to Z') {
        _filteredLivestock.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else if (sortOption == 'Z to A') {
        _filteredLivestock.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      } else if (sortOption == 'Newest First') {
        _filteredLivestock.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (sortOption == 'Oldest First') {
        _filteredLivestock.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
    });
  }

  String _calculateAge(String dateOfBirth) {
    try {
      DateTime birthDate = DateTime.parse(dateOfBirth);
      DateTime now = DateTime.now();
      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;
      
      if (months < 0) {
        years--;
        months += 12;
      }
      
      if (years > 0) {
        if (months == 0) {
          return years == 1 ? '1 year' : '$years years';
        }
        return years == 1
            ? '1 year $months ${months == 1 ? 'month' : 'months'}'
            : '$years years $months ${months == 1 ? 'month' : 'months'}';
      } else {
        return months == 1 ? '1 month' : '$months months';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  bool _isMaleGender(String gender) {
    final genderLower = gender.toLowerCase();
    return genderLower == 'male' || genderLower == 'm' || genderLower == '1' || genderLower == 'kiume';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Count livestock by gender
    final maleCount = _allLivestock.where((l) => _isMaleGender(l.gender)).length;
    final femaleCount = _allLivestock.length - maleCount;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchLivestockData,
          child: Container(
            padding: const EdgeInsets.only(top: 30, right: 20, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.allLivestocksText,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // TODO: Add localization key: manageAndTrackLivestock
                            'Manage and track all your livestock',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _fetchLivestockData,
                      icon: const Icon(Icons.refresh),
                      // TODO: Add 'refresh' key to localization
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        title: l10n.total,
                        value: '${_allLivestock.length}',
                        icon: Iconsax.pet_outline,
                        color: Constants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCardWithUnicode(
                        context: context,
                        title: l10n.male,
                        value: '$maleCount',
                        unicodeIcon: '♂',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCardWithUnicode(
                        context: context,
                        title: l10n.female,
                        value: '$femaleCount',
                        unicodeIcon: '♀',
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Search Bar
                if (_allLivestock.isNotEmpty)
                  _buildSearchBar(context, l10n),
                
                const SizedBox(height: 16),
                
                // Filter Pills
                if (_allLivestock.isNotEmpty)
                  _buildFilterPills(context, l10n),
                
                const SizedBox(height: 16),
                
                // Livestock List
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _allLivestock.isEmpty
                          ? _buildEmptyState(l10n)
                          : _filteredLivestock.isEmpty
                              ? _buildNoSearchResults(l10n)
                              : ListView.builder(
                                  itemCount: _filteredLivestock.length,
                                  itemBuilder: (context, index) {
                                    final livestock = _filteredLivestock[index];
                                    return _buildLivestockCard(context, livestock);
                                  },
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addLivestockFAB', // Unique tag to avoid Hero conflicts
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LivestockFormScreen(), // Empty form (no pre-selection)
            ),
          ).then((result) {
            // Reload livestock if form returned true (saved successfully)
            if (result == true) {
              _fetchLivestockData();
            }
          });
        },
        backgroundColor: Constants.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.addLivestock, // "Add Livestock" (EN) / "Ongeza Mifugo" (SW)
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardWithUnicode({
    required BuildContext context,
    required String title,
    required String value,
    required String unicodeIcon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            unicodeIcon,
            style: TextStyle(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Iconsax.search_normal_outline,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 22,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        onPressed: _onClearSearch,
                      ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Iconsax.sort_outline,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      onSelected: _onSortSelected,
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'A to Z', child: Text('Sort A to Z')),
                        const PopupMenuItem(value: 'Z to A', child: Text('Sort Z to A')),
                        const PopupMenuItem(value: 'Newest First', child: Text('Newest First')),
                        const PopupMenuItem(value: 'Oldest First', child: Text('Oldest First')),
                      ],
                    ),
                  ],
                ),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Constants.primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Constants.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Constants.primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${_allLivestock.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPills(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child:       Row(
        children: [
          _buildFilterPill(context, 'All', 'All'),
          const SizedBox(width: 8),
          _buildFilterPill(context, l10n.male, 'Male'),
          const SizedBox(width: 8),
          _buildFilterPill(context, l10n.female, 'Female'),
        ],
      ),
    );
  }

  Widget _buildFilterPill(BuildContext context, String label, String filterKey) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilter == filterKey;
    
    return GestureDetector(
      onTap: () => _onFilterChanged(filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Constants.primaryColor : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Constants.primaryColor : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Constants.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildLivestockCard(BuildContext context, Livestock livestock) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isMale = _isMaleGender(livestock.gender);
    final genderText = isMale ? l10n.male : l10n.female; // Localized gender
    final age = _calculateAge(livestock.dateOfBirth);
    final farmName = _farmNames[livestock.farmUuid] ?? 'Unknown Farm'; // TODO: Add l10n.unknownFarm
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          onTap: () {
            _showLivestockDetails(context, livestock);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Name and Gender Badge
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            livestock.name.isNotEmpty 
                                ? livestock.name 
                                : '${l10n.livestock} #${livestock.id}', // "Livestock #123"
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Constants.primaryColor,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                FontAwesome.seedling_solid,
                                size: 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  farmName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Gender Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isMale ? Colors.blue.withValues(alpha: 0.1) : Colors.pink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isMale ? Colors.blue : Colors.pink,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isMale ? '♂' : '♀',
                            style: TextStyle(
                              color: isMale ? Colors.blue : Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            genderText,
                            style: TextStyle(
                              color: isMale ? Colors.blue : Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Main Content Row
                Row(
                  children: [
                    // Livestock Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Constants.primaryColor.withValues(alpha: 0.1),
                            Constants.primaryColor.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Iconsax.pet_bold,
                        color: Constants.primaryColor,
                        size: 40,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Details Grid
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  'Age', // TODO: Add l10n.age
                                  age,
                                  Iconsax.cake_outline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  'Weight', // TODO: Add l10n.weight
                                  '${livestock.weightAsOnRegistration.toStringAsFixed(0)}kg',
                                  Iconsax.weight_outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  'Tag ID', // TODO: Add l10n.tagId
                                  livestock.identificationNumber.isNotEmpty
                                      ? livestock.identificationNumber
                                      : livestock.dummyTagId,
                                  Iconsax.tag_outline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  'Status', // TODO: Add l10n.status
                                  livestock.status,
                                  Iconsax.shield_tick_outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      // TODO: Add localization key: tapForMoreDetails
                      'Tap for more details',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Constants.primaryColor,
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

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.loadingData), // "Loading data..."
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.pet_outline,
            size: 64,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noLivestockFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // TODO: Add localization key: addFirstLivestockMessage
            'Add your first livestock to get started',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults(AppLocalizations l10n) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_normal_outline,
            size: 64,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            // TODO: Add localization key: noResultsFound
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // TODO: Add localization key: tryDifferentKeywords
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showLivestockDetails(BuildContext context, Livestock livestock) {
    // TODO: Show livestock details bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Livestock Details: ${livestock.name}')),
    );
  }
}
