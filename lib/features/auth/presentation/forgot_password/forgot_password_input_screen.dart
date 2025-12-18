import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/forgot_password/otp_verification_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class ForgotPasswordInputScreen extends StatefulWidget {
  final String recoveryMethod; // 'email' or 'phone'

  const ForgotPasswordInputScreen({
    super.key,
    required this.recoveryMethod,
  });

  @override
  State<ForgotPasswordInputScreen> createState() => _ForgotPasswordInputScreenState();
}

class _ForgotPasswordInputScreenState extends State<ForgotPasswordInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool get _isEmail => widget.recoveryMethod == 'email';

  Future<void> _handleSendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final l10n = AppLocalizations.of(context)!;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.sendOtp(
          email: _isEmail ? _inputController.text.trim() : null,
          phone: !_isEmail ? _inputController.text.trim() : null,
        );

        if (mounted) {
          setState(() => _isLoading = false);

          if (success) {
            // Navigate to OTP verification screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  recoveryMethod: widget.recoveryMethod,
                  identifier: _inputController.text.trim(),
                ),
              ),
            );
          } else {
            AlertDialogs.showError(
              context: context,
              title: l10n.error,
              message: authProvider.errorMessage ?? l10n.failedToSendOtp,
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
        systemOverlayStyle: theme.brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: Icon(Icons.arrow_back_ios_new, color: theme.brightness == Brightness.light ? Colors.black : Colors.white54,)
        ),
        title: Text(
          l10n.forgotPassword,
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
                      _isEmail ? Icons.email_outlined : Icons.phone_outlined,
                      size: 64,
                      color: Constants.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  _isEmail ? l10n.enterYourEmail : l10n.enterYourPhone,
                  style: TextStyle(
                    fontSize: Constants.largeTextSize,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  _isEmail 
                    ? l10n.otpWillBeSentToEmail
                    : l10n.otpWillBeSentToPhone,
                  style: TextStyle(
                    fontSize: Constants.textSize,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Input field
                CustomTextField(
                  controller: _inputController,
                  label: _isEmail ? l10n.emailAddress : l10n.phoneNumber,
                  hintText: _isEmail 
                    ? 'example@email.com'
                    : '+255 712 345 678',
                  prefixIcon: _isEmail ? Icons.email_outlined : Icons.phone_outlined,
                  keyboardType: _isEmail 
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                  inputFormatters: _isEmail 
                    ? null
                    : [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _isEmail 
                        ? l10n.pleaseEnterEmail
                        : l10n.pleaseEnterPhone;
                    }
                    if (_isEmail && !value.contains('@')) {
                      return l10n.pleaseEnterValidEmail;
                    }
                    if (!_isEmail && value.trim().length < 10) {
                      return l10n.pleaseEnterValidPhone;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Send OTP button
                CustomButton(
                  text: l10n.sendOtp,
                  onPressed: _isLoading ? null : _handleSendOtp,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Constants.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Constants.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Constants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.otpExpiresIn10Minutes,
                          style: TextStyle(
                            fontSize: Constants.smallTextSize,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
