import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/errors/auth_failure.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/forgot_password_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/signup_usecase.dart';
import '../data/auth_repository_impl.dart';
import '../data/auth_service.dart';

enum AuthAction { login, signup, forgotPassword, emailVerification }

class AuthState {
  const AuthState({
    required this.user,
    required this.isLoading,
    required this.action,
    required this.errorMessage,
  });

  final User? user;
  final bool isLoading;
  final AuthAction? action;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    AuthAction? action,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      action: action,
      errorMessage: errorMessage,
    );
  }

  factory AuthState.initial() => const AuthState(
    user: null,
    isLoading: false,
    action: null,
    errorMessage: null,
  );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({required this._repository}) : super(AuthState.initial()) {
    _authSubscription = _repository.authStateChanges().listen((user) {
      state = AuthState(
        user: user,
        isLoading: false,
        action: null,
        errorMessage: null,
      );
    });
  }
  final AuthRepository _repository;
  StreamSubscription<User?>? _authSubscription;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      action: AuthAction.login,
      errorMessage: null,
    );

    final usecase = LoginUseCase(repository: _repository);
    final AuthFailure? failure = await usecase.call(
      email: email,
      password: password,
    );

    if (failure != null) {
      state = state.copyWith(
        isLoading: false,
        action: null,
        errorMessage: failure.message,
      );
      return failure.message;
    }

    state = state.copyWith(isLoading: false, action: null, errorMessage: null);
    return null;
  }

  Future<String?> signup({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      action: AuthAction.signup,
      errorMessage: null,
    );

    final usecase = SignupUseCase(repository: _repository);
    final AuthFailure? failure = await usecase.call(
      email: email,
      password: password,
    );

    if (failure != null) {
      state = state.copyWith(
        isLoading: false,
        action: null,
        errorMessage: failure.message,
      );
      return failure.message;
    }

    final verificationFailure = await sendEmailVerification();
    if (verificationFailure != null) {
      state = state.copyWith(
        isLoading: false,
        action: null,
        errorMessage: verificationFailure,
      );
      return verificationFailure;
    }

    state = state.copyWith(isLoading: false, action: null, errorMessage: null);
    return null;
  }

  Future<String?> forgotPassword({required String email}) async {
    state = state.copyWith(
      isLoading: true,
      action: AuthAction.forgotPassword,
      errorMessage: null,
    );

    final usecase = ForgotPasswordUseCase(repository: _repository);
    final AuthFailure? failure = await usecase.call(email: email);

    if (failure != null) {
      state = state.copyWith(
        isLoading: false,
        action: null,
        errorMessage: failure.message,
      );
      return failure.message;
    }

    state = state.copyWith(isLoading: false, action: null, errorMessage: null);
    return null;
  }

  Future<String?> sendEmailVerification() async {
    state = state.copyWith(
      isLoading: true,
      action: AuthAction.emailVerification,
      errorMessage: null,
    );

    final failure = await _repository.sendEmailVerification();

    state = state.copyWith(isLoading: false, action: null, errorMessage: null);

    return failure?.message;
  }

  Future<String?> checkEmailVerification() async {
    state = state.copyWith(
      isLoading: true,
      action: AuthAction.emailVerification,
      errorMessage: null,
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    await currentUser?.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    // Update the complete auth state using the refreshed user.
    state = AuthState(
      user: refreshedUser,
      isLoading: false,
      action: null,
      errorMessage: null,
    );

    // Return null ONLY when the refreshed user is verified.
    // The screen should display its own localized message.
    if (refreshedUser?.emailVerified == true) {
      return null;
    }

    // Non-null return indicates not verified — screen uses localized string.
    return '';
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = AuthService();
  return AuthRepositoryImpl(authService: service);
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repo = ref.watch(authRepositoryProvider);
    return AuthController(repository: repo);
  },
);
