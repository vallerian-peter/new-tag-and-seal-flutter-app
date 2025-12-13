import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/livestock_helper.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class BulkLivestockSelectorPage extends StatefulWidget {
  final String farmUuid;
  final List<Livestock> preselectedLivestock;
  final String? genderFilter;
  final bool lockGenderFilter;

  const BulkLivestockSelectorPage({
    super.key,
    required this.farmUuid,
    this.preselectedLivestock = const [],
    this.genderFilter,
    this.lockGenderFilter = false,
  });

  @override
  State<BulkLivestockSelectorPage> createState() => _BulkLivestockSelectorPageState();
}

class _BulkLivestockSelectorPageState extends State<BulkLivestockSelectorPage> {
  late final AppDatabase _database;
  bool _isLoading = true;
  List<Livestock> _allLivestock = [];
  Set<String> _selectedLivestockUuids = {};
  String _searchQuery = '';
  String? _genderFilter;
  _SortOption _sortOption = _SortOption.ascending;
  Map<String, String> _farmNames = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _database = Provider.of<AppDatabase>(context, listen: false);
      _loadLivestock();
    });
    _genderFilter = widget.genderFilter?.toLowerCase();
  }

  Future<void> _loadLivestock() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all livestock including notActive ones
      final livestock = await _database.livestockDao.getLivestockByFarmUuid(
        widget.farmUuid,
      );
      final farms = await _database.farmDao.getAllActiveFarms();
      final farmNames = <String, String>{
        for (final farm in farms) farm.uuid: farm.name,
      };

      setState(() {
        _allLivestock = livestock;
        // Only preselect active livestock (filter out notActive)
        _selectedLivestockUuids = widget.preselectedLivestock
            .where((item) => !LivestockHelper.isNotActive(item))
            .map((item) => item.uuid)
            .toSet();
        _farmNames = farmNames;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load livestock for farm ${widget.farmUuid}: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Livestock> get _filteredLivestock {
    Iterable<Livestock> filtered = _allLivestock;

    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((livestock) {
        final nameMatches = livestock.name.toLowerCase().contains(lowerQuery);
        final identifierMatches =
            _resolveIdentifier(livestock).toLowerCase().contains(lowerQuery);
        final uuidMatches = livestock.uuid.toLowerCase().contains(lowerQuery);
        return nameMatches || identifierMatches || uuidMatches;
      });
    }

    if (_genderFilter != null && _genderFilter!.isNotEmpty) {
      filtered = filtered.where(
        (livestock) => livestock.gender.toLowerCase() == _genderFilter,
      );
    }

    final list = filtered.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (_sortOption == _SortOption.descending) {
      return list.reversed.toList();
    }
    return list;
  }

  void _toggleSelection(Livestock livestock) {
    // Prevent selection of notActive livestock
    if (LivestockHelper.isNotActive(livestock)) {
      return;
    }
    
    setState(() {
      if (_selectedLivestockUuids.contains(livestock.uuid)) {
        _selectedLivestockUuids.remove(livestock.uuid);
      } else {
        _selectedLivestockUuids.add(livestock.uuid);
      }
    });
  }
  
  List<Livestock> get _activeLivestock {
    return _filteredLivestock.where((l) => !LivestockHelper.isNotActive(l)).toList();
  }

  String _resolveIdentifier(Livestock livestock) {
    final candidates = <String?>[
      livestock.identificationNumber,
      livestock.barcodeTagId,
      livestock.rfidTagId,
      livestock.dummyTagId,
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate;
      }
    }
    return '';
  }

  String _formatAge(String dob) {
    final birthDate = DateTime.tryParse(dob);
    if (birthDate == null) return '';
    final now = DateTime.now();
    if (birthDate.isAfter(now)) return '';

    final diff = now.difference(birthDate);
    final years = diff.inDays ~/ 365;
    final months = (diff.inDays % 365) ~/ 30;

    final parts = <String>[];
    if (years > 0) parts.add('${years}y');
    if (months > 0) parts.add('${months}m');
    if (parts.isEmpty) parts.add('<1m');
    return parts.join(' ');
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  void _onConfirm() {
    final selected = _allLivestock
        .where((livestock) => _selectedLivestockUuids.contains(livestock.uuid))
        .toList();
    Navigator.of(context).pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final genderLockedToFemale =
        widget.lockGenderFilter && widget.genderFilter?.toLowerCase() == 'female';
    final genderSelectionLocked = widget.lockGenderFilter && widget.genderFilter != null;

    void setGenderFilter(String? value) {
      if (genderSelectionLocked) return;
      setState(() => _genderFilter = value);
    }

    void setSortOption(_SortOption option) {
      setState(() => _sortOption = option);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLivestock),
        actions: [
          TextButton(
            onPressed: _selectedLivestockUuids.isEmpty ? null : _onConfirm,
            child: Text(
              '${l10n.ok} (${_selectedLivestockUuids.length})',
              style: TextStyle(
                color: _selectedLivestockUuids.isEmpty
                    ? theme.disabledColor
                    : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.searchText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CheckboxListTile(
                    value: _activeLivestock.isNotEmpty &&
                        _selectedLivestockUuids.length == _activeLivestock.length,
                    onChanged: _activeLivestock.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              if (value == true) {
                                // Only select active livestock
                                _selectedLivestockUuids =
                                    _activeLivestock.map((e) => e.uuid).toSet();
                              } else {
                                _selectedLivestockUuids.clear();
                              }
                            });
                          },
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      l10n.select,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _FilterChip(
                        label: l10n.allText,
                        selected: _genderFilter == null,
                        onSelected: (_) => setGenderFilter(null),
                        enabled: !genderSelectionLocked,
                      ),
                      _FilterChip(
                        label: l10n.male,
                        selected: _genderFilter == 'male',
                        onSelected: (_) => setGenderFilter('male'),
                        enabled: !genderLockedToFemale && !genderSelectionLocked,
                      ),
                      _FilterChip(
                        label: l10n.female,
                        selected: _genderFilter == 'female',
                        onSelected: (_) => setGenderFilter('female'),
                        enabled: !genderSelectionLocked,
                      ),
                      _FilterChip(
                        label: 'A-Z',
                        selected: _sortOption == _SortOption.ascending,
                        onSelected: (_) => setSortOption(_SortOption.ascending),
                      ),
                      _FilterChip(
                        label: 'Z-A',
                        selected: _sortOption == _SortOption.descending,
                        onSelected: (_) => setSortOption(_SortOption.descending),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredLivestock.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noLivestockFound,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredLivestock.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final livestock = _filteredLivestock[index];
                            final isNotActive = LivestockHelper.isNotActive(livestock);
                            final isSelected =
                                _selectedLivestockUuids.contains(livestock.uuid);
                            final identifier = _resolveIdentifier(livestock);
                            final farmName = _farmNames[livestock.farmUuid] ?? '';
                            final age = _formatAge(livestock.dateOfBirth);
                            final subtitleParts = [
                              if (farmName.isNotEmpty) farmName,
                              if (age.isNotEmpty) age,
                              _capitalize(livestock.gender),
                              if (identifier.isNotEmpty) identifier,
                            ];

                            return Opacity(
                              opacity: isNotActive ? 0.6 : 1.0,
                              child: ListTile(
                                onTap: isNotActive ? null : () => _toggleSelection(livestock),
                                enabled: !isNotActive,
                                leading: Checkbox(
                                  value: isSelected,
                                  onChanged: isNotActive ? null : (_) => _toggleSelection(livestock),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        livestock.name.isNotEmpty
                                            ? livestock.name
                                            : '${l10n.livestock} #${livestock.id}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: isNotActive
                                              ? Colors.grey[500]
                                              : theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    // Not Active Badge
                                    if (isNotActive) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.cancel_outlined,
                                              size: 10,
                                              color: Colors.red[700],
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              l10n.notActive,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: subtitleParts.isEmpty
                                    ? null
                                    : Text(subtitleParts.join(' • '), 
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: isNotActive
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: theme.colorScheme.primary,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedLivestockUuids.isEmpty ? null : _onConfirm,
        label: Text(l10n.ok),
        icon: const Icon(Icons.check),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final bool enabled;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedBorder = theme.colorScheme.outline.withOpacity(0.45);
    final disabledColor = Colors.transparent;
    final chipTheme = ChipTheme.of(context).copyWith(
      backgroundColor: Colors.transparent,
      disabledColor: Colors.transparent,
      selectedColor: selectedColor,
      surfaceTintColor: Colors.transparent,
    );

    return Theme(
      data: theme.copyWith(chipTheme: chipTheme),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: enabled ? onSelected : null,
        selectedColor: selectedColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        disabledColor: disabledColor,
        surfaceTintColor: Colors.transparent,
        showCheckmark: selected,
        checkmarkColor: Colors.white,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: selected
              ? Colors.white
              : theme.colorScheme.onSurface.withOpacity(enabled ? 0.75 : 0.4),
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? Colors.transparent : unselectedBorder,
          ),
        ),
      ),
    );
  }
}

enum _SortOption { ascending, descending }
