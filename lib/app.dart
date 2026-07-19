import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_controller.dart';

class SingingCoachApp extends ConsumerWidget {
  const SingingCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure authStateChanges() is listened to.
    ref.watch(authControllerProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AI Singing Coach',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
