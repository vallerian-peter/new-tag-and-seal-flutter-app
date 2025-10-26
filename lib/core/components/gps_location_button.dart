import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/services/location/location_service.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

/// GPS Location Button Component
/// 
/// A tappable card that fetches current GPS coordinates when tapped.
/// Shows loading state and handles errors gracefully.
class GpsLocationButton extends StatefulWidget {
  final void Function(double latitude, double longitude) onLocationFetched;
  
  const GpsLocationButton({
    super.key,
    required this.onLocationFetched,
  });

  @override
  State<GpsLocationButton> createState() => _GpsLocationButtonState();
}

class _GpsLocationButtonState extends State<GpsLocationButton> {
  bool _isLoading = false;
  
  Future<void> _fetchCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() => _isLoading = true);
    
    try {
      // Get current location
      final position = await LocationService.getCurrentLocation();
      
      // Pass coordinates to parent widget
      widget.onLocationFetched(position.latitude, position.longitude);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.gpsCoordinatesRetrieved, style: TextStyle(color: Colors.white)),
            backgroundColor: Constants.successColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      // Show error message
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: TextStyle(color: Colors.white)),
            backgroundColor: Constants.dangerColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: l10n.settings,
              textColor: Colors.white,
              onPressed: () {
                // Open location settings
                LocationService.openLocationSettings();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return InkWell(
      onTap: _isLoading ? null : _fetchCurrentLocation,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : const Icon(
                    Icons.gps_fixed,
                    color: Colors.blue,
                    size: 24,
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.getCurrentLocation,
                    style: TextStyle(
                      fontSize: Constants.textSize,
                      fontWeight: FontWeight.bold,
                      color: _isLoading ? Colors.blue.withOpacity(0.6) : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isLoading ? l10n.fetchingGpsCoordinates : l10n.useGpsAutoFill,
                    style: TextStyle(
                      fontSize: Constants.smallTextSize,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _isLoading ? Icons.hourglass_empty : Icons.chevron_right,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

