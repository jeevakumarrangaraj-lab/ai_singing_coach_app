import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_router.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/onboarding_completion_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/practice/presentation/practice_router.dart';
import '../../features/settings/presentation/screens/account_settings_screen.dart';
import '../../features/settings/presentation/screens/preferences_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/welcome_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
    ref.listen<OnboardingCompletionState>(
      onboardingCompletionProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final _goRouterRefreshNotifierProvider = Provider<_GoRouterRefreshNotifier>((
  ref,
) {
  return _GoRouterRefreshNotifier(ref);
});

GoRouter _buildRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: ref.watch(_goRouterRefreshNotifierProvider),
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
      GoRoute(
        path: '/settings/account',
        name: 'accountSettings',
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/preferences',
        name: 'preferences',
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      ...PracticeRoutes().routes,
      ...const AuthRoutes().routes,
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (location == '/') return null;

      final authState = ref.read(authControllerProvider);
      final user = authState.user;

      if (authState.isLoading) {
        return null;
      }

      final isAuthenticated = user != null;

      const publicRoutes = <String>[
        '/welcome',
        '/login',
        '/signup',
        '/forgot-password',
      ];
      final isPublicRoute = publicRoutes.contains(location);

      if (!isAuthenticated) {
        if (isPublicRoute) return null;
        return '/login';
      }

      final isVerified = user.emailVerified;

      if (!isVerified) {
        if (location != '/verify-email') return '/verify-email';
        return null;
      }

      final onboardingState = ref.read(onboardingCompletionProvider);

      if (onboardingState.isLoading) {
        return null;
      }

      final onboardingCompleted = onboardingState.isCompleted;

      if (!onboardingCompleted) {
        if (location != '/onboarding') return '/onboarding';
        return null;
      }

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
  return _buildRouter(ref);
});
