import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  return SplashRepository();
});

/// Handles splash-screen-specific data access:
/// waiting for Firebase Auth restoration and exposing current auth/onboarding state.
class SplashRepository {
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

  /// Onboarding completion status.
  /// In a real implementation this would come from a provider/repository.
  /// For now we assume false to route to onboarding for verified users.
  bool get isOnboardingCompleted => false;
}
