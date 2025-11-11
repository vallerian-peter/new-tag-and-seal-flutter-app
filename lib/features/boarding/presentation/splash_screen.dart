import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/features/boarding/presentation/get_started.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {

  bool _isSyncing = false;
  bool _syncCompleted = false;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _startAnimationSequence();
    _performSyncAndNavigate();
  }

  void _initializeAnimations() {
    // Fade animation for logo
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Slide animation for tagline
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimationSequence() {
    // Start logo animations immediately
    _fadeController.forward();
    _scaleController.forward();
    
    // Start tagline animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _slideController.forward();
    });
  }

  void _performSyncAndNavigate() {
    // Perform sync and navigate to next screen
    // TODO: Implement actual sync logic from backend
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedScreen()),
      );
    });
  } 

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final appName = Constants.appName;
    final tagline = l10n.tagline;

    return Scaffold(
      backgroundColor: theme.brightness != Brightness.dark ? Constants.primaryColor : Colors.grey[880],
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.grey[900]!,
                      Colors.grey[800]!,
                      Colors.grey[900]!,
                    ]
                  : [
                      Constants.primaryColor,
                      Constants.primaryColor.withOpacity(0.8),
                      Constants.primaryColor.withOpacity(0.6),
                    ],
            ),
          ),
          child: Stack(
            children: [
              
              // Animated background particles (optional)
              ...List.generate(6, (index) => _buildFloatingParticle(index)),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // Logo with animations
                    AnimatedBuilder(
                      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              width: screenWidth * 0.6,
                              height: screenWidth * 0.6,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Image(
                                image: AssetImage('assets/images/logos/my-ngombe-logo-2.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Animated tagline
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            tagline,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Loading text with sync status
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            l10n.loadingData,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (_isSyncing && !_syncCompleted) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.syncingData,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Loading indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),

              // Copyright text at bottom
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    '© ${DateTime.now().year} $appName. All Rights Reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
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

  Widget _buildFloatingParticle(int index) {
    
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Positioned(
          left: (index * 60.0 + 20) % MediaQuery.of(context).size.width,
          top: (index * 80.0 + 50) % MediaQuery.of(context).size.height,
          child: Opacity(
            opacity: _fadeAnimation.value * 0.3,
            child: Container(
              width: 4 + (index % 3) * 2,
              height: 4 + (index % 3) * 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }
}