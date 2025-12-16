import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/error_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/home/presentation/home_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class ExtensionOfficerLoginFormScreen extends StatefulWidget {
  const ExtensionOfficerLoginFormScreen({super.key});

  @override
  State<ExtensionOfficerLoginFormScreen> createState() =>
      _ExtensionOfficerLoginFormScreenState();
}

class _ExtensionOfficerLoginFormScreenState
    extends State<ExtensionOfficerLoginFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = const FlutterSecureStorage();

  final _farmerAccessNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillCredentials();
  }

  @override
  void dispose() {
    _farmerAccessNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Pre-fill credentials if available in secure storage
  Future<void> _prefillCredentials() async {
    try {
      final email = await _secureStorage.read(key: 'email');
      final password = await _secureStorage.read(key: 'password');

      if (mounted) {
        setState(() {
          if (email != null && email.isNotEmpty) {
            _emailController.text = email;
          }
          if (password != null && password.isNotEmpty) {
            _passwordController.text = password;
          }
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Handle Extension Officer login
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final l10n = AppLocalizations.of(context)!;

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Store farmer access number (used by backend to attach extension officer to farm context)
        final accessNumber = _farmerAccessNumberController.text.trim();
        if (accessNumber.isNotEmpty) {
          await authProvider.storeExtensionOfficerAccessNumber(accessNumber);
        }

        // Call auth provider login method
        final success = await authProvider.login(
          context: context,
          username: _emailController.text,
          password: _passwordController.text,
        );

        if (success && mounted) {
          setState(() {
            _isLoading = false;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          final errorMessage = ErrorHelper.formatErrorMessage(
            e.toString(),
            l10n,
          );
          final errorTitle = ErrorHelper.getErrorTitle(e.toString(), l10n);

          await AlertDialogs.showError(
            context: context,
            title: errorTitle,
            message: errorMessage,
            buttonText: l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Section with Icon and Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 2, 24, 16),
                child: Column(
                  children: [
                    // Back Button
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Extension Officer Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Constants.primaryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.business_center_rounded,
                        size: 50,
                        color: Constants.primaryColor,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      l10n.extensionOfficerLogin,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      l10n.extensionOfficerLoginSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Form Card
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[800]
                        : theme.colorScheme.surface.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Farmer Access Number Field
                          CustomTextField(
                            label: l10n.farmerAccessNumber,
                            hintText: l10n.enterFarmerAccessNumber,
                            prefixIcon: Icons.business_outlined,
                            controller: _farmerAccessNumberController,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterFarmerAccessNumber;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Email Field
                          CustomTextField(
                            label: l10n.email,
                            hintText: l10n.emailHint,
                            prefixIcon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterEmail;
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return l10n.pleaseEnterValidEmail;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          CustomTextField(
                            label: l10n.password,
                            hintText: l10n.passwordHint,
                            prefixIcon: Icons.lock_outline,
                            controller: _passwordController,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterPassword;
                              }
                              if (value.length < 6) {
                                return l10n.passwordMinLength;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.forgotPassword),
                                    backgroundColor: Constants.primaryColor,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              child: Text(
                                l10n.forgotPassword,
                                style: TextStyle(
                                  color: Constants.primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login Button
                          CustomButton(
                            text: _isLoading ? l10n.loading : l10n.login,
                            color: Constants.primaryColor,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _handleLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Info Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Constants.primaryColor.withValues(alpha: 0.2),
                          width: 1,
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
                              l10n.extensionOfficerLoginSubtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
