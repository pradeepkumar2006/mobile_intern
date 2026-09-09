import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/trylo_logo.dart';
import 'onboarding_welcome_screen.dart';

/// 1st Screen: Discovery / Splash Screen (Sample Image)
/// Features the centered Trylo brand logo on a clean minimalist background
/// with smooth entrance animation, auto-navigating to OnboardingWelcomeScreen.
class SplashScreen extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    this.onAnimationComplete,
    this.autoNavigate = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();

      if (widget.autoNavigate && mounted) {
        _timer = Timer(const Duration(milliseconds: 800), _navigateToOnboarding);
      }
    });
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingWelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFFAFAFC),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _timer?.cancel();
          _navigateToOnboarding();
        },
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const TryloLogo(
                  iconSize: 58.0,
                  fontSize: 42.0,
                  spacing: 14.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
