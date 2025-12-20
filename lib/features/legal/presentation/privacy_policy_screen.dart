import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Bootstrap.chevron_left,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.privacyPolicy,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Constants.primaryColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Bootstrap.shield_lock,
                      size: 40,
                      color: Constants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.privacyPolicy,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.privacyPolicyLastUpdated,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Introduction
            _buildSection(
              context: context,
              title: l10n.privacyPolicyIntroduction,
              content: l10n.privacyPolicyIntroductionText,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Information We Collect
            _buildSection(
              context: context,
              title: l10n.privacyPolicyInformationWeCollect,
              content: l10n.privacyPolicyInformationWeCollectText,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // How We Use Information
            _buildSection(
              context: context,
              title: l10n.privacyPolicyHowWeUseInformation,
              content: l10n.privacyPolicyHowWeUseInformationText,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Data Security
            _buildSection(
              context: context,
              title: l10n.privacyPolicyDataSecurity,
              content: l10n.privacyPolicyDataSecurityText,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Your Rights
            _buildSection(
              context: context,
              title: l10n.privacyPolicyYourRights,
              content: l10n.privacyPolicyYourRightsText,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Contact Us
            _buildSection(
              context: context,
              title: l10n.privacyPolicyContactUs,
              content: l10n.privacyPolicyContactUsText,
              isDark: isDark,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black26
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

