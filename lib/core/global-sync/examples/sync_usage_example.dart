import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/provider/sync-provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/widgets/sync_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/loading_indicator.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';

/// Example screen showing how to use SyncProvider
class SyncUsageExample extends StatelessWidget {
  final AppDatabase database;

  const SyncUsageExample({
    super.key,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ChangeNotifierProvider(
      create: (context) => SyncProvider(database: database),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.syncData),
          actions: [
            // Sync button in app bar
            Consumer<SyncProvider>(
              builder: (context, syncProvider, child) {
                return IconButton(
                  onPressed: syncProvider.isSyncing
                      ? null
                      : () => syncProvider.splashSyncWithDialog(context),
                  icon: syncProvider.isSyncing
                      ? const LoadingIndicator(size: 20, strokeWidth: 2)
                      : const Icon(Icons.sync),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Sync status indicator
            const SyncStatusIndicator(),
            
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      l10n.syncData,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Keep your data synchronized with the server. This will download the latest information for your farms and livestock.',
                    ),
                    const SizedBox(height: 24),
                    
                    // Sync button using existing CustomButton
                    Consumer<SyncProvider>(
                      builder: (context, syncProvider, child) {
                        return CustomButton(
                          text: syncProvider.isSyncing 
                              ? l10n.syncing 
                              : l10n.syncData,
                          onPressed: syncProvider.isSyncing 
                              ? null 
                              : () => syncProvider.splashSyncWithDialog(context),
                          isLoading: syncProvider.isSyncing,
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Alternative sync button with custom styling
                    Consumer<SyncProvider>(
                      builder: (context, syncProvider, child) {
                        return CustomButton(
                          text: syncProvider.isSyncing 
                              ? l10n.syncing 
                              : 'Force Sync',
                          onPressed: syncProvider.isSyncing 
                              ? null 
                              : () => syncProvider.splashSyncWithDialog(context),
                          isLoading: syncProvider.isSyncing,
                          color: Colors.orange,
                          textColor: Colors.white,
                          width: 200,
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sync info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'What gets synced:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('• Farm locations and details'),
                            const Text('• Livestock information'),
                            const Text('• Reference data (species, breeds, etc.)'),
                            const Text('• User preferences'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of how to integrate SyncProvider in your app
class AppWithSync extends StatelessWidget {
  final AppDatabase database;

  const AppWithSync({
    super.key,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add SyncProvider to your existing providers
        ChangeNotifierProvider(
          create: (context) => SyncProvider(database: database),
        ),
        // ... your other providers
      ],
      child: MaterialApp(
        title: 'Tag and Seal App',
        home: SyncUsageExample(database: database),
      ),
    );
  }
}
