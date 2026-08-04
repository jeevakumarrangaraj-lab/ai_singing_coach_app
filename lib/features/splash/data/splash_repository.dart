import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/data/onboarding_providers.dart';
import '../../onboarding/data/onboarding_repository.dart';

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  final onboardingRepository = ref.watch(onboardingRepositoryProvider);
  return SplashRepository(onboardingRepository: onboardingRepository);
});

/// Handles splash-screen-specific data access:
/// waiting for Firebase Auth restoration and exposing current auth/onboarding state.
class SplashRepository {
  SplashRepository({required this._onboardingRepository});

  final OnboardingRepository _onboardingRepository;

  /// Returns a future that completes when the initial Firebase Auth state
  /// restoration has produced its first event.
  ///
  /// Uses [authStateChanges] which emits immediately with the restored user
  /// (or null) on app start, then again on any subsequent auth change.
  /// A timeout prevents indefinite blocking if the stream stalls.
  Future<void> waitForAuthRestoration({required Duration timeout}) async {
    final completer = Completer<void>();

    late final StreamSubscription<User?> sub;
    sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      sub.cancel();
    });

    try {
      await completer.future.timeout(timeout);
    } on TimeoutException {
      // Timeout is acceptable; we'll navigate with whatever state we have.
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  /// Current signed-in user (may be null if signed out or auth not yet restored).
  User? get currentUser => FirebaseAuth.instance.currentUser;

  /// Checks Firestore for the real onboarding completion status of [userId].
  ///
  /// Bounded by a short timeout so a slow/stalled Firestore call can never
  /// block splash navigation past the screen's own hard timeout. Any error
  /// or timeout is treated as "not completed" — this only ever costs the
  /// user a redundant trip through onboarding, never data loss, and it keeps
  /// behaviour aligned with [onboardingCompletionProvider]'s own failure mode.
  Future<bool> isOnboardingCompleted(String userId) async {
    if (userId.isEmpty) return false;

    try {
      return await _onboardingRepository
          .hasCompletedOnboarding(userId)
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      return false;
    }
  }
}
