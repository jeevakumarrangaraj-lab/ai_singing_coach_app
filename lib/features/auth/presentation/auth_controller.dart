import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/errors/auth_failure.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/forgot_password_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/signup_usecase.dart';
import '../domain/login_attempt_limiter.dart';
import '../data/auth_repository_impl.dart';
import '../data/auth_service.dart';

enum AuthAction { login, signup, forgotPassword, emailVerification }

class AuthState {
  const AuthState({
    required this.user,
    required this.isLoading,
    required this.action,
    required this.errorMessage,
    this.loginLockoutExpiry,
    this.remainingLoginAttempts,
  });

  final User? user;
  final bool isLoading;
  final AuthAction? action;
  final String? errorMessage;
  final DateTime? loginLockoutExpiry;
  final int? remainingLoginAttempts;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    AuthAction? action,
    String? errorMessage,
    DateTime? loginLockoutExpiry,
    int? remainingLoginAttempts,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      action: action,
      errorMessage: errorMessage,
      loginLockoutExpiry: loginLockoutExpiry,
      remainingLoginAttempts: remainingLoginAttempts,
    );
  }

  factory AuthState.initial() => const AuthState(
    user: null,
    isLoading: false,
    action: null,
    errorMessage: null,
    loginLockoutExpiry: null,
    remainingLoginAttempts: null,
  );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, this._loginAttemptLimiter)
    : super(AuthState.initial()) {
    _authSubscription = _repository.authStateChanges().listen((user) {
      state = AuthState(
        user: user,
        isLoading: false,
        action: null,
        errorMessage: null,
      );
    });
    _initLimiter();
  }

  final AuthRepository _repository;
  final LoginAttemptLimiter _loginAttemptLimiter;
  StreamSubscription<User?>? _authSubscription;
  Timer? _lockoutTimer;

  Future<void> _initLimiter() async {
    await _loginAttemptLimiter.clearExpiredLockout();
    _updateLimiterState();
    if (_loginAttemptLimiter.isLocked) {
      _startLockoutTimer();
    }
  }

  void _updateLimiterState() {
    state = state.copyWith(
      loginLockoutExpiry: _loginAttemptLimiter.lockoutExpiry,
      remainingLoginAttempts: _loginAttemptLimiter.remainingAttempts,
    );
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _lockoutTimer?.cancel();
        return;
      }
      _updateLimiterState();
      if (!_loginAttemptLimiter.isLocked) {
        _lockoutTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    // Check if locked before attempting login
    if (_loginAttemptLimiter.isLocked) {
      final remaining = _loginAttemptLimiter.remainingLockout;
      final seconds = remaining?.inSeconds ?? 30;
      return 'Too many failed attempts. Try again in $seconds seconds.';
    }

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
      // Classify the failure to determine if it should count as a credential failure
      final classifier = LoginAttemptClassifier.classify(
        FirebaseAuthException(
          code: _extractErrorCode(failure.message),
          message: failure.message,
        ),
      );

      if (classifier == LoginAttemptResult.credentialFailure) {
        await _loginAttemptLimiter.recordFailure();
        _updateLimiterState();
        if (_loginAttemptLimiter.isLocked) {
          _startLockoutTimer();
        }
      }

      state = state.copyWith(
        isLoading: false,
        action: null,
        errorMessage: failure.message,
      );
      return failure.message;
    }

    // Successful login - reset the limiter
    await _loginAttemptLimiter.reset();
    _updateLimiterState();
    _lockoutTimer?.cancel();

    state = state.copyWith(isLoading: false, action: null, errorMessage: null);
    return null;
  }

  String _extractErrorCode(String message) {
    // Map localized messages back to error codes for classification
    if (message.contains('Incorrect email or password') ||
        message.contains('email or password is incorrect')) {
      return 'invalid-credential';
    }
    if (message.contains('Too many attempts') ||
        message.contains('too many requests')) {
      return 'too-many-requests';
    }
    if (message.contains('Check your internet') ||
        message.contains('network')) {
      return 'network-request-failed';
    }
    if (message.contains('disabled') || message.contains('banned')) {
      return 'user-disabled';
    }
    return 'other';
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

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in tests');
});

final loginAttemptLimiterProvider = Provider<LoginAttemptLimiter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LoginAttemptLimiter(prefs);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = AuthService();
  return AuthRepositoryImpl(authService: service);
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repo = ref.watch(authRepositoryProvider);
    final limiter = ref.watch(loginAttemptLimiterProvider);
    return AuthController(repo, limiter);
  },
);
