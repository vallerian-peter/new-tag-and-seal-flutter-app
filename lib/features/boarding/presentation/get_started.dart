import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/signup/register_screen.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/floating_tag.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/features/boarding/presentation/how_it_works.dart';
import 'package:new_tag_and_seal_flutter_app/theme/theme_provider.dart';
import 'package:new_tag_and_seal_flutter_app/main.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/login/login_screen.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/home/presentation/home_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen ({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}


class _GetStartedScreenState extends State<GetStartedScreen> {
  bool _isCheckingAutoLogin = true;
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  /// Check if user can auto-login and navigate accordingly
  /// 
  /// Flow:
  /// 1. Check if credentials + user data + token exist
  /// 2. If ALL available → Check token validity
  /// 3. If token valid → Skip login → Navigate directly to HomeScreen
  /// 4. If token expired → Auto-login → Get new token → Navigate to HomeScreen
  /// 5. If any data missing → Show GetStartedScreen
  /// 
  /// Note: Errors are handled silently - no error dialogs shown during auto-login
  Future<void> _checkAutoLogin() async {
    try {
      // Get stored credentials
      final email = await _secureStorage.read(key: 'email');
      final password = await _secureStorage.read(key: 'password');
      final token = await _secureStorage.read(key: 'accessToken');
      
      // Get essential user data
      final userId = await _secureStorage.read(key: 'userId');
      final username = await _secureStorage.read(key: 'username');
      final role = await _secureStorage.read(key: 'role');
      
      // Check if we have ALL required data (credentials + user data + token)
      final hasAllData = email != null && 
                        password != null && 
                        token != null &&
                        userId != null &&
                        username != null &&
                        role != null;
      
      if (hasAllData) {
        // Check token validity
        final isTokenValid = _isTokenValid(token);
        
        if (isTokenValid) {
          // Token valid AND all data available - Skip login, go directly to HomeScreen
          try {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final autoLoginSuccess = await authProvider.tryAutoLogin();
            
            if (autoLoginSuccess && mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
              return;
            }
          } catch (e) {
            // Silent fail - show get-started screen
            print('Auto-login failed (valid token): $e');
          }
        } else {
          // Token expired - re-authenticate silently (slow path)
          try {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            
            // Use silent login to avoid showing error dialogs
            final success = await authProvider.silentLogin(
              username: email,
              password: password,
            );
            
            if (success && mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
              return;
            }
          } catch (e) {
            // Silent fail - show get-started screen
            print('Auto-login failed (expired token): $e');
          }
        }
      }
      
      // No credentials or auto-login failed - show get-started screen
      if (mounted) {
        setState(() {
          _isCheckingAutoLogin = false;
        });
      }
    } catch (e) {
      // Auto-login failed - show get-started screen
      print('Auto-login error: $e');
      if (mounted) {
        setState(() {
          _isCheckingAutoLogin = false;
        });
      }
    }
  }

  /// Check if JWT token is valid (not expired)
  /// 
  /// Returns true if token is valid, false if expired or invalid
  bool _isTokenValid(String token) {
    try {
      // Split JWT token (format: header.payload.signature)
      final parts = token.split('.');
      if (parts.length != 3) return false;

      // Decode payload (base64)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // Check expiration time
      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final now = DateTime.now();
        
        // Token is valid if expiry date is in the future
        return expiryDate.isAfter(now);
      }

      // If no expiry, consider token valid
      return true;
    } catch (e) {
      // If any error in parsing, consider token invalid
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking auto-login
    if (_isCheckingAutoLogin) {
      return Scaffold(
        backgroundColor: Constants.primaryColor,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    var mediaQuery = MediaQuery.of(context);
    var size = mediaQuery.size;
    final l10n = AppLocalizations.of(context)!;

    var welcomeTitle = l10n.welcomeTitle;
    var welcomeSubTitle = l10n.welcomeSubtitle;
    var loginText = l10n.login;
    var registerText = l10n.register;
    var howItWorksText = l10n.howItWorks;

    var title1 = l10n.tagYourLivestock;
    var title2 = l10n.keepTrackFarms;
    var title3 = l10n.inviteUsers;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      // backgroundColor: primaryColour,
      body: Stack(
        children: [

         Image.asset(
          'assets/images/welcome/bg-image-new.jpg',
          fit: BoxFit.cover,
          height: size.height,
         ),

         Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                 Color.fromARGB(15, 0, 0, 0),
                 Color.fromARGB(15, 0, 0, 0),
                 Color.fromARGB(15, 0, 0, 0),
                 Color.fromARGB(196, 37, 37, 37),
                 Color.fromARGB(174, 20, 20, 20),
              ],
            ),
          ),
        ), 

        // Theme and Language Toggles
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Theme Toggle (Left)
              _buildThemeToggle(),
              
              // Language Toggle (Right)
              _buildLanguageToggle(),
            ],
          ),
        ),

        // Floating Tags
        FloatingTag(
          text: title1,
          left: size.width * 0.4,
          top: size.height * 0.15,
          animationDuration: const Duration(milliseconds: 1500),
          bounceHeight: 8.0,
        ),
        
        FloatingTag(
          text: title3,
          left: size.width * 0.15,
          top: size.height * 0.3,
          animationDuration: const Duration(milliseconds: 1800),
          bounceHeight: 10.0,
        ),
        
        FloatingTag(
          text: title2,
          left: size.width * 0.3,
          top: size.height * 0.45,
          animationDuration: const Duration(milliseconds: 2200),
          bounceHeight: 9.0,
        ),
        

          Padding(
            padding: const EdgeInsets.all(Constants.defaultSize),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                      
                // Hero(
                //   tag: 'welcome-image-tag',
                //   child: Image(
                //     image: const AssetImage(
                //       cowEmblemWhite
                //     ),
                //     width: size.width / 1.8,
                //     height: size.height / 3,
                //   )
                // ),

                Column(
                  children: [
                      
                    Text(
                      welcomeTitle, 
                      // style: Theme.of(context).textTheme.displayMedium,
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                      
                    const SizedBox(height: 20,),
                      
                    Text(
                      welcomeSubTitle, 
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 13,
                        color: Colors.grey.shade400
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 24,),

                Row(
                  children: [
                   
                    Expanded(
                      child: CustomOutlinedButton(
                        text: loginText.toUpperCase(),
                        width: size.width * 0.4,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()))
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: CustomButton(
                        text: registerText.toUpperCase(),
                        width: size.width * 0.4,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())) ,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 24,),
            
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        color: const Color.fromARGB(255, 204, 116, 1),
                        text: howItWorksText.toUpperCase(),
                        width: size.width * 0.4,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HowItWorks()),
                          );
                        },
                      ),
                    ),
                    
                  ],
                ),
            
                SizedBox(height: size.height * 0.07,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: _showThemeDialog,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    final currentLocale = Localizations.localeOf(context);
    final currentLang = currentLocale.languageCode;
    
    return GestureDetector(
      onTap: _showLanguageDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLang == 'en' ? '🇬🇧' : '🇹🇿',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              currentLang.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.theme),
          backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                icon: Icons.light_mode,
                title: l10n.lightMode,
                isSelected: !themeProvider.isDarkMode,
                onTap: () {
                  themeProvider.setTheme(false);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                icon: Icons.dark_mode,
                title: l10n.darkMode,
                isSelected: themeProvider.isDarkMode,
                onTap: () {
                  themeProvider.setTheme(true);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentLocale = Localizations.localeOf(context);
    final currentLang = currentLocale.languageCode;
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.language),
          backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                flag: '🇬🇧',
                title: l10n.english,
                isSelected: currentLang == 'en',
                onTap: () {
                  MyApp.setLocale(context, const Locale('en'));
                  Navigator.pop(dialogContext);
                },
              ),
              const SizedBox(height: 8),
              _buildLanguageOption(
                flag: '🇹🇿',
                title: l10n.kiswahili,
                isSelected: currentLang == 'sw',
                onTap: () {
                  MyApp.setLocale(context, const Locale('sw'));
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Constants.primaryColor.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Constants.primaryColor : null),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Constants.primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Constants.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Constants.primaryColor.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Constants.primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Constants.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
