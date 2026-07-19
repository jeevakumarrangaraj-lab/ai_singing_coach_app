import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_controller.dart';
import 'welcome_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (!authState.isLoading) {
      final user = authState.user;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        if (user == null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
          return;
        }

        if (user.emailVerified) {
          Navigator.of(context).pushReplacementNamed('/practice');
        } else {
          Navigator.of(context).pushReplacementNamed('/verify-email');
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: authState.isLoading
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }
}
