import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_back_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/error_helper.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/home/presentation/home_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/widgets/forgot_password_bottom_sheet.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/forgot_password/forgot_password_input_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class ExtensionOfficerLoginScreen extends StatefulWidget {
  const ExtensionOfficerLoginScreen({super.key});

  @override
  State<ExtensionOfficerLoginScreen> createState() => _ExtensionOfficerLoginScreenState();
}

class _ExtensionOfficerLoginScreenState extends State<ExtensionOfficerLoginScreen> {
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
        
        // Call auth provider login method
        // Note: This will need to be updated to handle Extension Officer login
        // with farmer access number in the backend
        final success = await authProvider.login(
          context: context,
          username: _emailController.text,
          password: _passwordController.text,
        );
        
        if (success && mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Navigate to home screen
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
          
          // Show user-friendly error dialog
          final errorMessage = ErrorHelper.formatErrorMessage(e.toString(), l10n);
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
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/welcome/tag-green-farm-animals .jpg',
              fit: BoxFit.cover,
              height: size.height * 0.35,
            ),
          ),
          
          // Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
        
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Back Button
                  CustomBackButton(
                    isEnabledBgColor: true,
                    iconColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  
                  // Logo
                  Hero(
                    tag: 'app-logo',
                    child: Image.asset(
                      'assets/images/editorial/cow-emblem-white.png',
                      width: size.width * 0.18,
                      height: size.height * 0.08,
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  Text(
                    l10n.extensionOfficerLogin,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Constants.defaultSize,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      l10n.extensionOfficerLoginSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: Constants.textSize,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Login Form Card
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: size.height * 0.55,
                    ),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(17),
                        topRight: Radius.circular(17),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Login Title
                            Text(
                              l10n.extensionOfficerLogin,
                              style: TextStyle(
                                fontSize: Constants.extraLargeTextSize,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            
                            const SizedBox(height: 6),
                            
                            Text(
                              l10n.extensionOfficerLoginSubtitle,
                              style: TextStyle(
                                fontSize: Constants.textSize,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
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
                            
                            const SizedBox(height: 16),
                            
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
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return l10n.pleaseEnterValidEmail;
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
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
                            
                            const SizedBox(height: 8),
                            
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () async {
                                  final recoveryMethod = await ForgotPasswordBottomSheet.show(context);
                                  if (recoveryMethod != null && mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ForgotPasswordInputScreen(
                                          recoveryMethod: recoveryMethod,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: TextStyle(
                                      color: Constants.primaryColor,
                                      fontSize: Constants.textSize,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: _isLoading ? l10n.loading : l10n.login,
                                color: Constants.primaryColor,
                                isLoading: _isLoading,
                                onPressed: _isLoading ? null : _handleLogin,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}






