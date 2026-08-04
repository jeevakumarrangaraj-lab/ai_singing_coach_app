import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import '../domain/errors/auth_failure.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._authService});

  final AuthService _authService;

  @override
  Stream<User?> authStateChanges() => _authService.authStateChanges();

  @override
  User? get currentUser => _authService.currentUser;

  @override
  bool get currentUserEmailVerified =>
      _authService.currentUser?.emailVerified ?? false;

  @override
  Future<AuthFailure?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signUp(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthFailure(message: _mapFirebaseError(e));
    } catch (_) {
      return const AuthFailure(
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  @override
  Future<AuthFailure?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signIn(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthFailure(message: _mapFirebaseError(e));
    } catch (_) {
      return const AuthFailure(
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  @override
  Future<AuthFailure?> sendPasswordResetEmail({required String email}) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthFailure(message: _mapFirebaseError(e));
    } catch (_) {
      return const AuthFailure(
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  @override
  Future<AuthFailure?> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthFailure(message: _mapFirebaseError(e));
    } catch (_) {
      return const AuthFailure(
        message: 'Failed to send verification email. Please try again.',
      );
    }
  }

  @override
  Future<AuthFailure?> reloadCurrentUser() async {
    try {
      await _authService.reloadCurrentUser();
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthFailure(message: _mapFirebaseError(e));
    } catch (_) {
      return const AuthFailure(
        message: 'Failed to reload your account status. Please try again.',
      );
    }
  }

  @override
  Future<AuthFailure?> updateDisplayName(String displayName) async {
    try {
      await _authService.updateDisplayName(displayName);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthFailure(message: _mapFirebaseError(e));
    } catch (_) {
      return const AuthFailure(
        message: 'Failed to update display name. Please try again.',
      );
    }
  }

  @override
  Future<AuthFailure?> deleteUser() async {
    try {
      await _authService.deleteUser();
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthFailure(message: _mapFirebaseError(e));
    } catch (_) {
      return const AuthFailure(
        message: 'Failed to delete account. Please try again.',
      );
    }
  }

  @override
  Future<void> signOut() => _authService.signOut();

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'requires-recent-login':
        return 'This action requires a recent login. Please log out and log back in, then try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      default:
        return e.message ?? 'Authentication error. Please try again.';
    }
  }
}
