import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/forgot_password/reset_password_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String recoveryMethod; // 'email' or 'phone'
  final String identifier; // email or phone value

  const OtpVerificationScreen({
    super.key,
    required this.recoveryMethod,
    required this.identifier,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  bool get _isEmail => widget.recoveryMethod == 'email';

  Future<void> _handleVerifyOtp() async {
    if (_otp.length != 6) {
      final l10n = AppLocalizations.of(context)!;
      AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.pleaseEnterCompleteOtp,
        buttonText: l10n.ok,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Navigate to reset password screen with OTP
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            recoveryMethod: widget.recoveryMethod,
            identifier: widget.identifier,
            otp: _otp,
          ),
        ),
      );
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isResending = true);

    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.sendOtp(
        email: _isEmail ? widget.identifier : null,
        phone: !_isEmail ? widget.identifier : null,
      );

      if (mounted) {
        setState(() => _isResending = false);

        if (success) {
          AlertDialogs.showSuccess(
            context: context,
            title: l10n.success,
            message: l10n.otpResentSuccessfully,
            buttonText: l10n.ok,
          );
          // Clear OTP fields
          for (var controller in _otpControllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        } else {
          AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message: authProvider.errorMessage ?? l10n.failedToResendOtp,
            buttonText: l10n.ok,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResending = false);
        AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: e.toString(),
          buttonText: l10n.ok,
        );
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
          icon: Icon(
            Icons.arrow_back_ios_new, 
            color: theme.brightness == Brightness.light ? Colors.black : Colors.white54,)
        ),
        title: Text(
          l10n.verifyOtp,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                    Icons.lock_outline,
                    size: 64,
                    color: Constants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                l10n.enterOtpCode,
                style: TextStyle(
                  fontSize: Constants.largeTextSize,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                '${l10n.otpSentTo} ${widget.identifier}',
                style: TextStyle(
                  fontSize: Constants.textSize,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => _buildOtpBox(index),
                ),
              ),
              const SizedBox(height: 32),

              // Verify button
              CustomButton(
                text: l10n.verify,
                onPressed: _isLoading ? null : _handleVerifyOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Center(
                child: TextButton(
                  onPressed: _isResending ? null : _handleResendOtp,
                  child: _isResending
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Constants.primaryColor,
                          ),
                        ),
                      )
                    : Text(
                        l10n.resendOtp,
                        style: TextStyle(
                          fontSize: Constants.textSize,
                          fontWeight: FontWeight.w600,
                          color: Constants.primaryColor,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: Constants.veryLightGreyColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
            ? Constants.primaryColor
            : Constants.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }
}
