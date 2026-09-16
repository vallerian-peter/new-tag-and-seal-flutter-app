import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
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
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  static const int _initialCountdownSeconds = 300; // 5 minutes
  int _secondsRemaining = _initialCountdownSeconds;
  Timer? _countdownTimer;

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = _initialCountdownSeconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedCountdown {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleResetOtp() {
    _pinController.clear();
    _pinFocusNode.requestFocus();
    setState(() {});
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  String get _otp => _pinController.text.trim();

  bool get _isEmail => widget.recoveryMethod == 'email';

  Future<void> _handleVerifyOtp() async {
    final l10n = AppLocalizations.of(context)!;

    if (_otp.length != 6) {
      AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.pleaseEnterCompleteOtp,
        buttonText: l10n.ok,
      );
      return;
    }

    if (_secondsRemaining <= 0) {
      AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.otpExpired,
        buttonText: l10n.ok,
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.verifyOtp(
        email: _isEmail ? widget.identifier : null,
        phone: !_isEmail ? widget.identifier : null,
        otp: _otp,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          // Navigate to reset password screen with verified OTP
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
        } else {
          AlertDialogs.showError(
            context: context,
            title: l10n.error,
            message: authProvider.errorMessage ?? l10n.failedToVerifyOtp,
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
          message: e.toString().replaceAll('Exception: ', ''),
          buttonText: l10n.ok,
        );
      }
    }
  }

  Future<void> _handleResendOtp() async {
    if (_secondsRemaining > 0 || _isResending) return;

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
          // Clear OTP field and reset countdown
          _handleResetOtp();
          _startCountdown();
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
          message: e.toString().replaceAll('Exception: ', ''),
          buttonText: l10n.ok,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: Icon(
            Icons.arrow_back_ios_new, 
            color: isDark ? Colors.white70 : Colors.black87,
          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Constants.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Constants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 28),

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
                _isEmail
                    ? '${l10n.otpSentTo} ${widget.identifier}'
                    : l10n.otpSendToPhone(widget.identifier),
                style: TextStyle(
                  fontSize: Constants.textSize,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // 5-Minute Countdown & Expiry Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _secondsRemaining > 0
                      ? Constants.primaryColor.withValues(alpha: 0.08)
                      : Constants.dangerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _secondsRemaining > 0
                        ? Constants.primaryColor.withValues(alpha: 0.25)
                        : Constants.dangerColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _secondsRemaining > 0 ? Icons.timer_outlined : Icons.warning_amber_rounded,
                      size: 18,
                      color: _secondsRemaining > 0 ? Constants.primaryColor : Constants.dangerColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _secondsRemaining > 0
                          ? '${l10n.otpExpiresIn5Minutes} (${_formattedCountdown})'
                          : l10n.otpExpired,
                      style: TextStyle(
                        fontSize: Constants.smallTextSize,
                        fontWeight: FontWeight.w600,
                        color: _secondsRemaining > 0 ? Constants.primaryColor : Constants.dangerColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Responsive & Professional OTP Input Box using Pinput
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    // Compute adaptive width for 6 boxes with 5 gaps of 8px
                    final boxWidth = ((availableWidth - 40) / 6).clamp(38.0, 48.0);
                    final boxHeight = (boxWidth * 1.18).clamp(46.0, 58.0);

                    final defaultPinTheme = PinTheme(
                      width: boxWidth,
                      height: boxHeight,
                      textStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F1F1F) : Constants.veryLightGreyColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? theme.colorScheme.outline.withValues(alpha: 0.3)
                              : Constants.primaryColor.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                    );

                    final focusedPinTheme = defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: isDark ? const Color(0xFF262626) : Colors.white,
                        border: Border.all(
                          color: Constants.primaryColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Constants.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    );

                    final submittedPinTheme = defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: isDark ? const Color(0xFF1F1F1F) : Constants.veryLightGreyColor,
                        border: Border.all(
                          color: Constants.primaryColor.withValues(alpha: 0.65),
                          width: 1.5,
                        ),
                      ),
                    );

                    final errorPinTheme = defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(
                          color: Constants.dangerColor,
                          width: 1.5,
                        ),
                      ),
                    );

                    return Pinput(
                      length: 6,
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      autofocus: true,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      errorPinTheme: errorPinTheme,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      cursor: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 9),
                            width: 20,
                            height: 2,
                            color: Constants.primaryColor,
                          ),
                        ],
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      onCompleted: (pin) {
                        _handleVerifyOtp();
                      },
                    );
                  },
                ),
              ),

              // Reset Code Button
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _pinController.text.isNotEmpty ? _handleResetOtp : null,
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: _pinController.text.isNotEmpty
                            ? Constants.primaryColor
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      label: Text(
                        l10n.resetCode,
                        style: TextStyle(
                          fontSize: Constants.smallTextSize,
                          fontWeight: FontWeight.w600,
                          color: _pinController.text.isNotEmpty
                              ? Constants.primaryColor
                              : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Verify button
              CustomButton(
                text: l10n.verify,
                onPressed: (_isLoading || _otp.length != 6) ? null : _handleVerifyOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),

              // Resend OTP / Countdown
              Center(
                child: _isResending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Constants.primaryColor,
                        ),
                      ),
                    )
                  : _secondsRemaining > 0
                      ? Text(
                          '${l10n.resendCodeIn} $_formattedCountdown',
                          style: TextStyle(
                            fontSize: Constants.textSize,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        )
                      : TextButton(
                          onPressed: _handleResendOtp,
                          child: Text(
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
}
