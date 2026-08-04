import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';

import 'core/localization/locale_controller.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/auth_controller.dart';

class SingingCoachApp extends ConsumerWidget {
  const SingingCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure authStateChanges() is listened to.
    ref.watch(authControllerProvider);

    final router = ref.watch(appRouterProvider);

    final themeMode = ref.watch(themeModeProvider);
    final appLanguage = ref.watch(localeProvider);

    // Listen for auth state changes to refresh the router.
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tuno',

      locale: appLanguage.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
