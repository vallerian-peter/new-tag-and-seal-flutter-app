import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class BulkLivestockIdentificationCard extends StatelessWidget {
  const BulkLivestockIdentificationCard({
    super.key,
    required this.isIdentified,
    required this.stageName,
    required this.onChanged,
  });

  final bool isIdentified;
  final String? stageName;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final status = isIdentified ? l10n.identified : l10n.notIdentified;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: SwitchListTile.adaptive(
        value: isIdentified,
        activeThumbColor: theme.colorScheme.primary,
        title: Text(
          l10n.pigletBulkIdentificationSwitchTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${l10n.stage}: ${stageName ?? '—'} · $status'),
        secondary: const Icon(Icons.verified_outlined),
        onChanged: onChanged,
      ),
    );
  }
}

class BulkLivestockAnimalIdentificationFields extends StatelessWidget {
  const BulkLivestockAnimalIdentificationFields({
    super.key,
    required this.officialIdController,
    required this.dummyTagIdController,
    required this.barcodeTagIdController,
    required this.rfidTagIdController,
  });

  final TextEditingController officialIdController;
  final TextEditingController dummyTagIdController;
  final TextEditingController barcodeTagIdController;
  final TextEditingController rfidTagIdController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        CustomTextField(
          controller: officialIdController,
          label: '${l10n.identificationNumber} *',
          hintText: l10n.enterIdentificationNumber,
          prefixIcon: Icons.numbers_outlined,
          validator: (value) => value == null || value.trim().isEmpty
              ? l10n.identificationNumberRequired
              : null,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: dummyTagIdController,
          label: l10n.dummyTagId,
          hintText: l10n.enterDummyTagId,
          prefixIcon: Icons.sell_outlined,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: barcodeTagIdController,
          label: l10n.barcodeTagId,
          hintText: l10n.enterBarcodeTagId,
          prefixIcon: Icons.qr_code_outlined,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: rfidTagIdController,
          label: l10n.rfidTagId,
          hintText: l10n.enterRfidTagId,
          prefixIcon: Icons.nfc_outlined,
        ),
      ],
    );
  }
}
