import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLocationButton extends StatelessWidget {
  final VoidCallback onTap;

  const MapLocationButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color: Colors.blue.withValues(alpha: 0.1),
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          // border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.map_outlined, color: Colors.green, size: 24),
            // const Icon(Icons.map_outlined, color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chooseOnMap,
                    style: const TextStyle(
                      fontSize: Constants.textSize,
                      fontWeight: FontWeight.bold,
                      // color: Colors.blue,
                      color: Color(0x923E9341),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.tapMapToChooseLocation,
                    style: TextStyle(
                      fontSize: Constants.smallTextSize,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.green),
            // const Icon(Icons.chevron_right, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

class MapLocationSelection {
  final double latitude;
  final double longitude;

  const MapLocationSelection({required this.latitude, required this.longitude});
}

class MapLocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapLocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  static const _tanzaniaCenter = LatLng(-6.3690, 34.8888);
  static const _minimumZoom = 3.0;
  static const _maximumZoom = 19.0;

  final _mapController = MapController();
  late final LatLng _initialCenter;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();

    final latitude = widget.initialLatitude;
    final longitude = widget.initialLongitude;
    if (latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180) {
      _selectedLocation = LatLng(latitude, longitude);
      _initialCenter = _selectedLocation!;
    } else {
      _initialCenter = _tanzaniaCenter;
    }
  }

  void _selectLocation(LatLng location) {
    setState(() => _selectedLocation = location);
  }

  void _changeZoom(double change) {
    final camera = _mapController.camera;
    final zoom = (camera.zoom + change)
        .clamp(_minimumZoom, _maximumZoom)
        .toDouble();
    _mapController.move(camera.center, zoom);
  }

  void _confirmSelection() {
    final selectedLocation = _selectedLocation;
    if (selectedLocation == null) return;

    Navigator.of(context).pop(
      MapLocationSelection(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chooseFarmLocation)),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: _selectedLocation == null ? 5.5 : 16,
                    minZoom: _minimumZoom,
                    maxZoom: _maximumZoom,
                    cameraConstraint: CameraConstraint.containLatitude(),
                    onTap: (_, location) => _selectLocation(location),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.new_tag_and_seal_flutter_app',
                    ),
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation!,
                            width: 54,
                            height: 54,
                            alignment: Alignment.bottomCenter,
                            child: const Icon(
                              Icons.location_pin,
                              color: Constants.dangerColor,
                              size: 52,
                              shadows: [
                                Shadow(color: Colors.black38, blurRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => launchUrl(
                            Uri.parse('https://openstreetmap.org/copyright'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: IgnorePointer(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.touch_app_outlined,
                              color: Constants.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(l10n.tapMapToChooseLocation)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  right: 12,
                  bottom: -550,
                  child: Center(
                    child: Material(
                      color: theme.colorScheme.surface,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _changeZoom(1),
                            tooltip: l10n.zoomIn,
                            icon: const Icon(Icons.add),
                          ),
                          SizedBox(
                            width: 32,
                            child: Divider(
                              height: 1,
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _changeZoom(-1),
                            tooltip: l10n.zoomOut,
                            icon: const Icon(Icons.remove),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.selectedCoordinates,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _selectedLocation == null
                        ? l10n.tapMapToChooseLocation
                        : '${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                              '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _selectedLocation == null
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _selectedLocation == null
                          ? null
                          : _confirmSelection,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(l10n.useSelectedLocation),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
