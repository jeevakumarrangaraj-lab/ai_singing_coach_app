import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash screen that restores auth state then navigates to /welcome.
///
/// Navigation to /welcome lets GoRouter's redirect logic choose the final
/// destination based on the verified state and onboarding completion:
///   - unverified         → /verify-email
///   - verified, not done → /onboarding
///   - verified, done     → /home
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  static const Duration _authTimeout = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();

    // Navigate after the first frame is rendered so the router is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToWelcome();
    });
  }

  Future<void> _navigateToWelcome() async {
    if (_hasNavigated) return;

    try {
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        _authTimeout,
      );

      if (!mounted || _hasNavigated) return;

      _hasNavigated = true;
      // Always go to /welcome. GoRouter redirect handles the rest
      // (verify-email, onboarding, home).
      context.go('/welcome');
    } on TimeoutException {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      context.go('/welcome');
    } catch (error) {
      debugPrint('Splash error: $error');
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _hasNavigated = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final double logoSize = isMobile ? 130.0 : 165.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0810),
      body: Center(
        child: Semantics(
          label: 'Tuno logo',
          image: true,
          child: Image.asset(
            'assets/images/tuno_logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
