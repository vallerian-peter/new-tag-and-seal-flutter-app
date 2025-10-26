import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.events,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              // Handle add event
            },
            icon: Icon(
              Iconsax.add_outline,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Events Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Active',
                    value: '3',
                    icon: Iconsax.calendar_tick_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Upcoming',
                    value: '5',
                    icon: Iconsax.calendar_outline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Completed',
                    value: '12',
                    icon: Iconsax.calendar_tick_outline,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Events List
            Text(
              'Recent Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            ...List.generate(5, (index) => _buildEventItem(context, index)),
          ],
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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    
    final eventsData = [
      {
        'title': 'Vaccination Schedule',
        'description': 'Annual vaccination for all cattle',
        'date': 'Today, 2:00 PM',
        'type': 'Health',
        'color': Colors.blue,
        'icon': Iconsax.health_outline,
      },
      {
        'title': 'Feeding Schedule',
        'description': 'Evening feed for pregnant cows',
        'date': 'Today, 5:00 PM',
        'type': 'Feeding',
        'color': Colors.green,
        'icon': Iconsax.bag_tick_2_outline,
      },
      {
        'title': 'Breeding Event',
        'description': 'Artificial insemination for Cow #003',
        'date': 'Tomorrow, 9:00 AM',
        'type': 'Breeding',
        'color': Colors.purple,
        'icon': Iconsax.heart_outline,
      },
      {
        'title': 'Health Checkup',
        'description': 'Monthly health inspection',
        'date': 'Nov 25, 10:00 AM',
        'type': 'Health',
        'color': Colors.blue,
        'icon': Iconsax.health_outline,
      },
      {
        'title': 'Deworming',
        'description': 'Quarterly deworming program',
        'date': 'Nov 30, 8:00 AM',
        'type': 'Health',
        'color': Colors.orange,
        'icon': Iconsax.health_outline,
      },
    ];
    
    final event = eventsData[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (event['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              event['icon'] as IconData,
              color: event['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['description'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Iconsax.clock_outline,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event['date'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Handle event details
            },
            icon: Icon(
              Iconsax.arrow_right_3_outline,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

