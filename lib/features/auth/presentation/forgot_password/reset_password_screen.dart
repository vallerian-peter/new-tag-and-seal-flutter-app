import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String recoveryMethod; // 'email' or 'phone'
  final String identifier; // email or phone value
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.recoveryMethod,
    required this.identifier,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isEmail => widget.recoveryMethod == 'email';

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final l10n = AppLocalizations.of(context)!;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.resetPassword(
          email: _isEmail ? widget.identifier : null,
          phone: !_isEmail ? widget.identifier : null,
          otp: widget.otp,
          newPassword: _newPasswordController.text,
        );

        if (mounted) {
          setState(() => _isLoading = false);

          if (success) {
            // Show success dialog and navigate back to login
            await AlertDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: l10n.passwordResetSuccessfully,
              buttonText: l10n.ok,
            );

            if (mounted) {
              // Pop all forgot password screens and return to login
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          } else {
            AlertDialogs.showError(
              context: context,
              title: l10n.error,
              message: authProvider.errorMessage ?? l10n.failedToResetPassword,
              buttonText: l10n.ok,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message: e.toString(),
            buttonText: l10n.ok,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        systemOverlayStyle: theme.brightness == Brightness.light 
            ? SystemUiOverlayStyle.dark 
            : SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: Icon(
            Icons.arrow_back_ios_new, 
            color: theme.brightness == Brightness.light ? Colors.black : Colors.white54,)
        ),
        title: Text(
          l10n.resetPassword,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Constants.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 64,
                      color: Constants.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  l10n.createNewPassword,
                  style: TextStyle(
                    fontSize: Constants.largeTextSize,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  l10n.passwordMinLength8,
                  style: TextStyle(
                    fontSize: Constants.textSize,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // New Password field
                CustomTextField(
                  controller: _newPasswordController,
                  label: l10n.newPassword,
                  hintText: l10n.enterNewPassword,
                  prefixIcon: Icons.lock_outline,
                  isPassword: _obscureNewPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterNewPassword;
                    }
                    if (value.length < 8) {
                      return l10n.passwordMinLength8;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: l10n.confirmPassword,
                  hintText: l10n.enterConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  isPassword: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseConfirmPassword;
                    }
                    if (value != _newPasswordController.text) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Reset Password button
                CustomButton(
                  text: l10n.resetPassword,
                  onPressed: _isLoading ? null : _handleResetPassword,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
