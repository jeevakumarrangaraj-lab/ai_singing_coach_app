import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_router.dart';
import '../../features/practice/presentation/practice_router.dart';
import '../../screens/home_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/welcome_screen.dart';

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
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      ...PracticeRoutes().routes,
      ...const AuthRoutes().routes,
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final user = authState.user;

      if (authState.isLoading) return null;

      final isAuthenticated = user != null;
      final isVerified = user?.emailVerified ?? false;
      final location = state.matchedLocation;

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
        return '/practice';
      }

      return null;
    },
  );

  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    final previousAuthenticated = previous?.user != null;
    final nextAuthenticated = next.user != null;

    final previousVerified = previous?.user?.emailVerified ?? false;
    final nextVerified = next.user?.emailVerified ?? false;

    if (previousAuthenticated != nextAuthenticated ||
        previousVerified != nextVerified) {
      router.refresh();
    }
  });

  ref.onDispose(router.dispose);

  return router;
});
