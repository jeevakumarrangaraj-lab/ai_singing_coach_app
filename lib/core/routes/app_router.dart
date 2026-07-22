import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_router.dart';
import '../../features/onboarding/presentation/onboarding_completion_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/practice/presentation/practice_router.dart';
import '../../screens/home_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/welcome_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

/// Reads the latest [authControllerProvider] and [onboardingCompletionProvider]
/// state at the moment the redirect closure is invoked.
///
/// Because the GoRouter provider itself is rebuilt whenever either
/// watched provider emits a new state, the `ref` passed into this
/// function always points to the current [Ref] with fresh data.
GoRouter _buildRouter(Ref ref) {
  return GoRouter(
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
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      ...PracticeRoutes().routes,
      ...const AuthRoutes().routes,
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Always allow the Splash route to build.
      // Splash itself navigates after auth restoration + min duration.
      if (location == '/') return null;

      // Read the latest state every time redirect is called.
      final authState = ref.read(authControllerProvider);
      final user = authState.user;

      // Don't redirect while auth restoration is in progress.
      if (authState.isLoading) return null;

      final isAuthenticated = user != null;

      // Routes that a signed-out user may access freely.
      const publicRoutes = <String>[
        '/welcome',
        '/login',
        '/signup',
        '/forgot-password',
      ];
      final isPublicRoute = publicRoutes.contains(location);

      // ── Signed-out users ──────────────────────────────────────────────
      if (!isAuthenticated) {
        // Allow access to public authentication routes.
        if (isPublicRoute) return null;
        // Everything else → welcome page.
        return '/welcome';
      }

      // ── Signed-in users ───────────────────────────────────────────────
      final isVerified = user.emailVerified;

      // Unverified email → verification screen.
      if (!isVerified) {
        if (location != '/verify-email') return '/verify-email';
        return null;
      }

      // ── Verified users — check onboarding completion ─────────────────
      final onboardingState = ref.read(onboardingCompletionProvider);

      // While onboarding status is loading, protect post-auth routes from
      // showing Dashboard content before we know the completion status.
      // Never redirect splash, public auth routes, verify-email, or
      // onboarding itself during this loading window.
      if (onboardingState.isLoading) {
        const protectedDuringLoading = <String>['/home'];
        if (protectedDuringLoading.contains(location)) {
          return '/onboarding';
        }
        return null;
      }

      final onboardingCompleted = onboardingState.isCompleted;

      if (!onboardingCompleted) {
        // Incomplete onboarding → onboarding flow.
        if (location != '/onboarding') return '/onboarding';
        return null;
      }

      // ── Verified & onboarding completed ──────────────────────────────
      // Redirect away from auth-related pages and onboarding to home.
      if (location == '/verify-email' ||
          location == '/onboarding' ||
          isPublicRoute) {
        return '/home';
      }

      return null;
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch both providers so the router rebuilds (and redirect re-evaluates)
  // when either auth state or onboarding-completion state changes.
  ref.watch(authControllerProvider);
  ref.watch(onboardingCompletionProvider);

  final router = _buildRouter(ref);

  ref.onDispose(router.dispose);

  return router;
});
