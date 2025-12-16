import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/access_code_generator.dart';
import 'package:new_tag_and_seal_flutter_app/core/check-network/network_check.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/data/repository/extension_officer_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/extensionOfficer/presentation/provider/extension_officer_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';

class ExtensionOfficerInviteFormScreen extends StatefulWidget {
  const ExtensionOfficerInviteFormScreen({super.key});

  @override
  State<ExtensionOfficerInviteFormScreen> createState() =>
      _ExtensionOfficerInviteFormScreenState();
}

class _ExtensionOfficerInviteFormScreenState
    extends State<ExtensionOfficerInviteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _accessCodeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  Future<void> _searchOfficer(ExtensionOfficerProvider provider) async {
    if (_emailController.text.isEmpty || !_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    // Check network connectivity
    final networkCheck = NetworkCheck.instance;
    final isConnected = await networkCheck.isConnected;

    if (!isConnected) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.networkError,
        message: l10n.noInternetConnection,
        buttonText: l10n.ok,
      );
      return;
    }

    final officer = await provider.searchByEmailWithDialog(
      context,
      _emailController.text.trim(),
    );

    // Generate and display access code when officer is found
    if (officer != null && mounted) {
      final accessCode = AccessCodeGenerator.generateAccessCode();
      setState(() {
        _accessCodeController.text = accessCode;
      });
    }
  }

  Future<void> _inviteOfficer(ExtensionOfficerProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (provider.foundOfficer == null) {
      final l10n = AppLocalizations.of(context)!;
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.pleaseSearchExtensionOfficerFirst,
        buttonText: l10n.ok,
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    // Check network connectivity
    final networkCheck = NetworkCheck.instance;
    final isConnected = await networkCheck.isConnected;

    if (!isConnected) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.networkError,
        message: l10n.noInternetConnection,
        buttonText: l10n.ok,
      );
      return;
    }

    // Use the access code that was already generated and displayed
    final accessCode = _accessCodeController.text.trim();

    if (accessCode.isEmpty) {
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message:
            'Access code is required. Please search for the extension officer first.',
        buttonText: l10n.ok,
      );
      return;
    }

    final invite = await provider.createInviteWithDialog(
      context,
      _emailController.text.trim(),
      accessCode,
    );

    // Access code is already displayed, no need to update it
    if (invite != null && mounted) {
      // Keep the access code that was already shown
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return ChangeNotifierProvider<ExtensionOfficerProvider>(
      create: (_) => ExtensionOfficerProvider(
        repository: ExtensionOfficerRepository(
          Provider.of<AppDatabase>(context, listen: false),
        ),
      ),
      child: Scaffold(
        backgroundColor: Constants.veryLightGreyColor,
        appBar: AppBar(
          systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CustomBackButton(
            isEnabledBgColor: false,
            iconColor: Theme.of(context).colorScheme.tertiary,
            iconSize: 24,
          ),
          title: Text(
            l10n.addExtensionOfficerText,
            style: TextStyle(
              fontSize: Constants.largeTextSize,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Consumer<ExtensionOfficerProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Constants.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Constants.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.inviteOfficerText,
                                style: TextStyle(
                                  fontSize: Constants.textSize,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        label: l10n.email,
                        hintText: l10n.enterExtensionOfficerEmail,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.emailRequired;
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return l10n.validEmailRequired;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Search Button
                      CustomButton(
                        text: provider.isSearching
                            ? l10n.searching
                            : l10n.search,
                        color: Constants.primaryColor,
                        isLoading: provider.isSearching,
                        onPressed: provider.isSearching
                            ? null
                            : () => _searchOfficer(provider),
                      ),

                      // Found Officer Info
                      if (provider.foundOfficer != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Constants.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Constants.successColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Constants.successColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.extensionOfficerFound,
                                      style: TextStyle(
                                        fontSize: Constants.largeTextSize,
                                        fontWeight: FontWeight.bold,
                                        color: Constants.successColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                l10n.fullNameText,
                                provider.foundOfficer!.fullName,
                              ),
                              if (provider.foundOfficer!.phone != null)
                                _buildInfoRow(
                                  l10n.phone,
                                  provider.foundOfficer!.phone!,
                                ),
                              if (provider.foundOfficer!.specialization != null)
                                _buildInfoRow(
                                  '${l10n.specialization}',
                                  provider.foundOfficer!.specialization!,
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Access Code Field (Read-only) - Shows generated code when officer is found
                        TextFormField(
                          controller: _accessCodeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: l10n.accessCode,
                            hintText: l10n.accessCodeWillBeGenerated,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: _accessCodeController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: _accessCodeController.text,
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.accessCodeCopied),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    tooltip: l10n.copy,
                                  )
                                : null,
                            filled: true,
                            fillColor: theme.brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Invite Button - Only show after officer is found
                        CustomButton(
                          text: provider.isInviting
                              ? l10n.inviting
                              : l10n.invite,
                          color: Constants.successColor,
                          isLoading: provider.isInviting,
                          onPressed: provider.isInviting
                              ? null
                              : () => _inviteOfficer(provider),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: Constants.textSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: Constants.textSize,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
