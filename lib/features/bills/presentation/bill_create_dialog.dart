import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/number_formatter.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/data/repository/bills_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/bills/domain/models/bill_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class BillCreateResult {
  final String amount;
  final String? notes;

  BillCreateResult({
    required this.amount,
    this.notes,
  });
}

Future<bool> showBillCreateDialogAndSave(
  BuildContext context, {
  required String farmUuid,
  required String subjectType,
  String? subjectUuid,
  int livestockCount = 1,
}) async {
  final l10n = AppLocalizations.of(context)!;

  // Capture providers BEFORE showing dialog to avoid context issues
  final auth = Provider.of<AuthProvider>(context, listen: false);
  final db = Provider.of<AppDatabase>(context, listen: false);

  final amountController = TextEditingController(text: '0');
  final notesController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final result = await showDialog<BillCreateResult>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final theme = Theme.of(ctx);
          final unitAmount = double.tryParse(amountController.text.trim()) ?? 0;
          final totalAmount = livestockCount * unitAmount;

          return AlertDialog(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Constants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Constants.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.createBill,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.sizeOf(ctx).width / 1.2,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Info card showing pre-filled details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.light ? Colors.grey[300] : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.billDetails,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        ctx,
                        Icons.category_outlined,
                        l10n.subjectType,
                        subjectType,
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        ctx,
                        Icons.inventory_2_outlined,
                        l10n.quantity,
                        livestockCount.toString(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // Amount field - the only editable field
                CustomTextField(
                  controller: amountController,
                  label: l10n.amount,
                  hintText: l10n.enterAmount,
                  prefixIcon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final raw = (v ?? '').trim();
                    if (raw.isEmpty) return null;
                    final amt = double.tryParse(raw);
                    if (amt == null || amt < 0) return l10n.enterValidNumber;
                    return null;
                  },
                ),

                const SizedBox(height: 3,),

                // Helper
                Text(
                  '${livestockCount}x${amountController.text.trim().isEmpty ? '0' : amountController.text.trim()} = ${NumberFormatter.formatCurrency(totalAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.brightness == Brightness.light
                        ? Colors.grey[500]
                        : Colors.grey[300],
                  ),
                ),

                const SizedBox(height: 16),
                
                // Notes field - optional
                CustomTextField(
                  controller: notesController,
                  label: l10n.notes,
                  hintText: l10n.enterNotesOptional,
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 3,
                ),
                
              ],
            ),
          ),
        ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final unitAmount = double.tryParse(amountController.text.trim()) ?? 0;
              final totalAmount = (livestockCount * unitAmount).toStringAsFixed(2);
              final nts = notesController.text.trim();

              Navigator.of(ctx).pop(
                BillCreateResult(
                  amount: totalAmount,
                  notes: nts.isEmpty ? null : nts,
                ),
              );
            },
            child: Text(l10n.save),
          ),
        ],
      );
        },
      );
    },
  );

  if (result == null) return false;

  // Only extension officer can create bills
  if (!auth.isExtensionOfficer) return false;

  final repo = BillsRepository(db);

  // Get extension officer's user ID (not roleId)
  int? eoId;
  final userId = auth.currentUser?['id'];
  if (userId is int) {
    eoId = userId;
  } else if (userId is String) {
    eoId = int.tryParse(userId);
  }
  
  // Get farmerId for extension officer from secure storage
  // Extension officers have the farmerId of the farmer who invited them
  int? farmerId;
  const secureStorage = FlutterSecureStorage();
  final storedFarmerId = await secureStorage.read(key: 'extensionOfficerFarmerId');
  if (storedFarmerId != null && storedFarmerId.isNotEmpty) {
    farmerId = int.tryParse(storedFarmerId);
  }

  final nowIso = DateTime.now().toIso8601String();
  final uuid = 'bill-${DateTime.now().microsecondsSinceEpoch}-${farmUuid.hashCode}-${(subjectUuid ?? '').hashCode}';
  
  // Generate billNo on frontend: BILL-YYYYMMDDHHMMSS-XXX
  final now = DateTime.now();
  final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  final randomSuffix = (now.microsecond % 1000).toString().padLeft(3, '0');
  final billNo = 'BILL-$timestamp-$randomSuffix';

  final model = BillModel(
    uuid: uuid,
    billNo: billNo,
    farmUuid: farmUuid,
    extensionOfficerId: eoId,
    farmerId: farmerId,
    subjectType: subjectType,
    subjectUuid: subjectUuid,
    quantity: livestockCount,
    amount: result.amount,
    status: 'pending',
    notes: result.notes,
    synced: false,
    syncAction: 'create',
    createdAt: nowIso,
    updatedAt: nowIso,
  );

  try {
    await repo.createBill(model);

    // Show success dialog
    final rootCtx = Navigator.of(context, rootNavigator: true).context;
    if (rootCtx.mounted) {
      await AlertDialogs.showSuccess(
        context: rootCtx,
        title: l10n.success,
        message: l10n.billCreatedSuccessfully,
        buttonText: l10n.ok,
      );
    }
    return true;
  } catch (e) {
    // Show error dialog
    final rootCtx = Navigator.of(context, rootNavigator: true).context;
    if (rootCtx.mounted) {
      await AlertDialogs.showError(
        context: rootCtx,
        title: l10n.error,
        message: '${l10n.billCreationFailed}: $e',
        buttonText: l10n.ok,
      );
    }
    return false;
  }
}

Widget _buildInfoRow(
  BuildContext context,
  IconData icon,
  String label,
  String value,
) {
  final theme = Theme.of(context);
  return Row(
    children: [
      Icon(
        icon,
        size: 16,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
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
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.end,
        ),
      ),
    ],
  );
}
