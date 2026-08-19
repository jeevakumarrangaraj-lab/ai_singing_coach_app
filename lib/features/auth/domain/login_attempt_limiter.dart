import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginAttemptLimiter {
  static const String _keyAttempts = 'login_failed_attempts';
  static const String _keyLockoutExpiry = 'login_lockout_expiry';

  final SharedPreferences _prefs;
  final DateTime Function() _now;

  final int maxAttempts;
  final Duration lockoutDuration;

  LoginAttemptLimiter(
    this._prefs, {
    DateTime Function()? now,
    this.maxAttempts = 3,
    this.lockoutDuration = const Duration(seconds: 30),
  }) : _now = now ?? DateTime.now;

  int get _attempts => _prefs.getInt(_keyAttempts) ?? 0;

  DateTime? get _lockoutExpiry {
    final millis = _prefs.getInt(_keyLockoutExpiry);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  int get remainingAttempts {
    if (isLocked) return 0;
    return maxAttempts - _attempts;
  }

  DateTime? get lockoutExpiry => _lockoutExpiry;

  bool get isLocked {
    final expiry = _lockoutExpiry;
    if (expiry == null) return false;
    return _now().isBefore(expiry);
  }

  Duration? get remainingLockout {
    final expiry = _lockoutExpiry;
    if (expiry == null) return null;
    final now = _now();
    if (now.isAfter(expiry)) return null;
    return expiry.difference(now);
  }

  Future<void> recordFailure() async {
    if (isLocked) return;

    final newAttempts = _attempts + 1;
    await _prefs.setInt(_keyAttempts, newAttempts);

    if (newAttempts >= maxAttempts) {
      final expiry = _now().add(lockoutDuration);
      await _prefs.setInt(_keyLockoutExpiry, expiry.millisecondsSinceEpoch);
    }
  }

  Future<void> reset() async {
    await _prefs.remove(_keyAttempts);
    await _prefs.remove(_keyLockoutExpiry);
  }

  Future<void> clearExpiredLockout() async {
    final expiry = _lockoutExpiry;
    if (expiry != null && _now().isAfter(expiry)) {
      await _prefs.remove(_keyLockoutExpiry);
      await _prefs.remove(_keyAttempts);
    }
  }
}

enum LoginAttemptResult {
  allowed,
  locked,
  credentialFailure,
  networkFailure,
  userDisabled,
  tooManyRequests,
  other,
}

class LoginAttemptClassifier {
  static LoginAttemptResult classify(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
        case 'user-not-found':
          return LoginAttemptResult.credentialFailure;
        case 'user-disabled':
          return LoginAttemptResult.userDisabled;
        case 'too-many-requests':
          return LoginAttemptResult.tooManyRequests;
        case 'network-request-failed':
          return LoginAttemptResult.networkFailure;
        default:
          return LoginAttemptResult.other;
      }
    }
    return LoginAttemptResult.other;
  }
}
