import 'package:firebase_auth/firebase_auth.dart';

import '../errors/auth_failure.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();

  User? get currentUser;

  Future<AuthFailure?> signUp({
    required String email,
    required String password,
  });

  Future<AuthFailure?> signIn({
    required String email,
    required String password,
  });

  Future<AuthFailure?> sendPasswordResetEmail({required String email});

  Future<AuthFailure?> sendEmailVerification();

  Future<AuthFailure?> reloadCurrentUser();

  Future<AuthFailure?> updateDisplayName(String displayName);

  Future<AuthFailure?> deleteUser();

  bool get currentUserEmailVerified;

  Future<void> signOut();
}
