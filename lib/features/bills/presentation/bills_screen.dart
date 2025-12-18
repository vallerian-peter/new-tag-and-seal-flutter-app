import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/data/repository/bills_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/domain/models/bill_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/number_formatter.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  bool _loading = true;
  List<BillModel> _bills = const [];

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    final auth = context.read<AuthProvider>();
    final db = Provider.of<AppDatabase>(context, listen: false);
    final repo = BillsRepository(db);

    int? filterExtensionOfficerId;
    if (auth.isExtensionOfficer) {
      // Use user ID (not roleId) to filter bills
      final userId = auth.currentUser?['id'];
      if (userId is int) filterExtensionOfficerId = userId;
      if (userId is String) {
        filterExtensionOfficerId = int.tryParse(userId);
      }
    }

    final items = await repo.getBills(
      extensionOfficerId: filterExtensionOfficerId,
    );
    if (!mounted) return;
    setState(() {
      _bills = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${l10n.bills} (${_bills.length})'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBills,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 2,
              child: _bills.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noBillsFound,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (ctx, idx) {
                        final b = _bills[idx];
                        return _BillCard(bill: b);
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _bills.length,
                    ),
            ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final BillModel bill;

  const _BillCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDark = theme.brightness == Brightness.dark;

    final createdDate = bill.createdAt != null
        ? DateTime.tryParse(bill.createdAt!)
        : null;
    final formattedDate = createdDate != null
        ? DateFormat.yMMMd().format(createdDate)
        : null;

    return Card(
      elevation: 0,
      color: theme.brightness == Brightness.light ? Colors.grey[50]! : Colors.grey[800]!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Constants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Constants.primaryColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (bill.billNo ?? '').isNotEmpty
                            ? l10n.billNumber(bill.billNo!)
                            : bill.uuid.substring(0, 8).toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 5,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                             if (formattedDate != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  formattedDate,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            
                            const SizedBox(width: 5,),

                           if ((bill.status ?? '').isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(bill.status!).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(bill.status!).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  bill.status!.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _getStatusColor(bill.status!),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
              
                        ],
                      ),
                     
                    ],
                  ),
                ),

                // Icon Change to status = Paid
                if(authProvider.isFarmer) IconButton(
                  onPressed: () => _showMarkAsPaidDialog(context, bill),
                  icon: Icon(
                    Iconsax.arrow_swap_bold,
                    color: theme.colorScheme.primary,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light ? Colors.grey[200] : Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    Icons.attach_money,
                    l10n.amount,
                    NumberFormatter.formatCurrency(double.tryParse(bill.amount) ?? 0),
                    isHighlight: true,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.inventory_2_outlined,
                    l10n.quantity,
                    bill.quantity.toString(),
                  ),
                  if ((bill.subjectType ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Icons.category_outlined,
                      l10n.subjectType,
                      bill.subjectType!,
                    ),
                  ],
                ],
              ),
            ),

            if ((bill.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bill.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlight
              ? Constants.primaryColor
              : theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight
                  ? Constants.primaryColor
                  : theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Constants.primaryColor;
    }
  }

  Future<void> _showMarkAsPaidDialog(BuildContext context, BillModel bill) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.confirmPayment,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.markBillAsPaidConfirmation,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.billNumber(bill.billNo ?? bill.uuid.substring(0, 8).toUpperCase())}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.amount}: ${NumberFormatter.formatCurrency(double.tryParse(bill.amount) ?? 0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.check),
            label: Text(l10n.markAsPaid),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _updateBillStatus(context, bill);
    }
  }

  Future<void> _updateBillStatus(BuildContext context, BillModel bill) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      final repo = BillsRepository(db);

      final updatedBill = bill.copyWith(
        status: 'paid',
        updatedAt: DateTime.now().toIso8601String(),
        syncAction: bill.syncAction == 'create' ? 'create' : 'update',
      );

      await repo.updateBill(updatedBill);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.billMarkedAsPaid),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Refresh the bills list
        final state = context.findAncestorStateOfType<_BillsScreenState>();
        state?._loadBills();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
