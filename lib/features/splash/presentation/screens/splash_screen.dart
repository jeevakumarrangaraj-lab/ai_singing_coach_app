import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// TODO: Spotify-style animated Splash (fade/scale entrance + reverse exit)
// is paused for later repair. When resuming:
//   - Restore SingleTickerProviderStateMixin with ONE AnimationController
//   - Use forward() for entrance, reverse() for exit (reverseDuration: 250ms)
//   - Future.wait<dynamic> was already replaced with typed independent futures
//   - Read MediaQuery.disableAnimationsOf(context) before any await
//   - Ensure mounted check guards all async gaps
// See git history for previous implementation.
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
      _navigateToDestination();
    });
  }

  Future<void> _navigateToDestination() async {
    if (_hasNavigated) return;

    try {
      final user = await FirebaseAuth.instance.authStateChanges().first.timeout(
        _authTimeout,
      );

      if (!mounted || _hasNavigated) return;

      final String destination;
      if (user == null) {
        destination = '/welcome';
      } else if (!user.emailVerified) {
        destination = '/verify-email';
      } else {
        destination = '/home';
      }

      _hasNavigated = true;
      debugPrint('TUNO SPLASH NAVIGATING TO: $destination');
      context.go(destination);
    } on TimeoutException catch (error) {
      debugPrint('TUNO SPLASH auth timeout: $error');
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      context.go('/welcome');
    } catch (error) {
      debugPrint('TUNO SPLASH error: $error');
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
    // Static dark splash with centered logo – no animations, no ticker.
    // The logo appears immediately while auth resolves.
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
