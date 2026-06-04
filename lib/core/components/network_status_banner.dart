import 'dart:async';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/check-network/network_check.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class NetworkStatusBanner extends StatefulWidget {
  const NetworkStatusBanner({super.key});

  @override
  State<NetworkStatusBanner> createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner> {
  StreamSubscription<bool>? _connectivitySubscription;
  bool? _isConnected;

  @override
  void initState() {
    super.initState();
    _listenForNetworkChanges();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _listenForNetworkChanges() {
    final networkCheck = NetworkCheck.instance;

    _connectivitySubscription = networkCheck.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    _refreshConnectionStatus();
  }

  Future<void> _refreshConnectionStatus() async {
    final networkCheck = NetworkCheck.instance;

    await networkCheck.initialize();
    final isConnected = await networkCheck.isConnected;

    if (!mounted) return;
    _updateConnectionStatus(isConnected);
  }

  void _updateConnectionStatus(bool isConnected) {
    if (!mounted || _isConnected == isConnected) return;

    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOffline = _isConnected == false;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: isOffline
          ? Container(
              key: const ValueKey('offline-network-banner'),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Constants.orangeColorTranslucent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Constants.orangeColor.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Constants.orangeColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.noInternetConnection,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: Constants.textSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.checkInternetConnection,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: Constants.smallTextSize,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('online-network-banner')),
    );
  }
}
