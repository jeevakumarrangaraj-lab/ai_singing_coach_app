import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/splash_repository.dart';

/// Splash screen shown only on cold start / browser refresh.
///
/// Waits concurrently for:
///   1. Firebase Auth state restoration (first event from authStateChanges)
///   2. Minimum visible duration of 2500 ms
/// Then navigates exactly once to the correct destination:
///   - no user                → /welcome
///   - unverified user        → /verify-email
///   - verified, onboarding incomplete → /onboarding
///   - verified, onboarding done     → /home
/// A hard timeout of 10 s guarantees progress even if auth hangs.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;
  bool _dependenciesInitialized = false;
  late final Timer _hardTimeout;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  static const Duration _minVisibleDuration = Duration(milliseconds: 1800);
  static const Duration _hardTimeoutDuration = Duration(seconds: 10);
  static const Duration _entranceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _hardTimeout = Timer(_hardTimeoutDuration, () {
      if (!_hasNavigated && mounted) {
        _hasNavigated = true;
        _navigateBasedOnAuth(ref.read(splashRepositoryProvider));
      }
    });

    // Start both the auth wait and the minimum-duration timer concurrently.
    unawaited(_waitAndNavigate());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_dependenciesInitialized) return;
    _dependenciesInitialized = true;

    // Respect reduced motion accessibility setting.
    if (!MediaQuery.disableAnimationsOf(context)) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  Future<void> _waitAndNavigate() async {
    final repo = ref.read(splashRepositoryProvider);
    final minDuration = Future.delayed(_minVisibleDuration);

    // Wait for the first auth state change (restoration) with a generous timeout.
    final authFuture = repo.waitForAuthRestoration(
      timeout: const Duration(seconds: 8),
    );

    await Future.wait([authFuture, minDuration]);

    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      _navigateBasedOnAuth(repo);
    }
  }

  void _navigateBasedOnAuth(SplashRepository repo) {
    if (!mounted) return;

    final user = repo.currentUser;

    String destination;
    if (user == null) {
      destination = '/welcome';
    } else if (!user.emailVerified) {
      destination = '/verify-email';
    } else if (!repo.isOnboardingCompleted) {
      destination = '/onboarding';
    } else {
      destination = '/home';
    }

    context.go(destination);
  }

  @override
  void dispose() {
    _hardTimeout.cancel();
    _animationController.dispose();
    _hasNavigated = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final double logoSize = isMobile ? 130.0 : 170.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Semantics(
          label: 'Tuno logo',
          image: true,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/images/tuno_logo.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
