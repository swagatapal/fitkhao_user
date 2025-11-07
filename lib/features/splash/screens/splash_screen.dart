import 'package:fitkhao_user/core/constants/app_colors.dart';
import 'package:fitkhao_user/core/constants/app_typography.dart';
import 'package:fitkhao_user/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _textController;

  // Animations
  late Animation<double> _backgroundOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    // Background fade animation (0-500ms)
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeIn),
    );

    // Logo animation (500-1500ms)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text animation (1500-2500ms)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
  }

  Future<void> _startAnimationSequence() async {
    // Start background fade
    await _backgroundController.forward();

    // Start logo animation
    await _logoController.forward();

    // Start text animation
    await _textController.forward();

    // Wait a bit before navigating
    await Future.delayed(const Duration(milliseconds: 1000));

    // Navigate to phone auth screen
    if (mounted) {
      context.go(RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFF5D9E40),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _logoController,
          _textController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Animated background with pattern
              Opacity(
                opacity: _backgroundOpacity.value,
                child: Container(
                  width: double.infinity,
                  height: context.responsiveFontSize(
                                381,
                              ),
                  decoration: const BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: [Color(0xFF5D9E40), Color(0xFF4A7D33)],
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    // ),
                  ),
                  child: Image.asset(
                    "assets/images/splash.png",
                    width: size.width,
                    height: context.responsiveFontSize(
                                381,
                              ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Center content with logo and text
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo
                    Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Image.asset(
                          "assets/images/logo_1.png",
                          width: 100,
                          height: 81,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Animated fitkhao text
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: Opacity(
                        opacity: _textOpacity.value,
                        child: RichText(
                          text: TextSpan(
                            text: 'fit',
                            style: context.getResponsiveTextStyle(
                              fontSize: context.responsiveFontSize(
                                40,
                              ),
                              fontWeight: AppTypography.light,
                              color: AppColors.textWhite,
                              decoration: TextDecoration.underline,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Khao',
                                style: context.getResponsiveTextStyle(
                                  fontSize: context.responsiveFontSize(
                                    40,
                                  ),
                                  fontWeight: AppTypography.bold,
                                  color: AppColors.textWhite,
                                  decoration: TextDecoration.none,
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
            ],
          );
        },
      ),
    );
  }
}
