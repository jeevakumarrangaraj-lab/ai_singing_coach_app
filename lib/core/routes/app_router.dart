import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_router.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/practice/presentation/practice_router.dart';
import '../../screens/home_screen.dart';
import '../../screens/welcome_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      ...PracticeRoutes().routes,
      ...const AuthRoutes().routes,
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final destination = location;

      debugPrint('Splash destination: $destination');

      // IMPORTANT: Allow the Splash route to always build.
      // Splash itself will navigate after auth restoration + min duration.
      if (location == '/') return null;

      final authState = ref.read(authControllerProvider);
      final user = authState.user;

      if (authState.isLoading) return null;

      final isAuthenticated = user != null;
      final isVerified = user?.emailVerified ?? false;

      final bool isAuthPage =
          location == '/login' ||
          location == '/signup' ||
          location == '/welcome';

      if (!isAuthenticated) {
        if (location == '/practice' || location == '/verify-email') {
          return '/welcome';
        }
        return null;
      }

      if (!isVerified) {
        if (location != '/verify-email') {
          return '/verify-email';
        }
        return null;
      }

      if (isVerified && (location == '/verify-email' || isAuthPage)) {
        return '/home';
      }

      return null;
    },
  );

  ref.onDispose(router.dispose);

  return router;
});
