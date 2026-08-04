import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/onboarding_providers.dart';
import '../data/onboarding_repository.dart';
import 'onboarding_state.dart' show OnboardingErrorCode;

/// State representing the completion status of onboarding.
class OnboardingCompletionState {
  const OnboardingCompletionState({
    required this.isLoading,
    required this.isCompleted,
    this.errorCode,
  });

  /// True while a Firestore call is in-flight.
  final bool isLoading;

  /// True only when the authenticated user has completed onboarding.
  final bool isCompleted;

  /// Error code that consuming widgets map to an l10n getter.
  final OnboardingErrorCode? errorCode;

  OnboardingCompletionState copyWith({
    bool? isLoading,
    bool? isCompleted,
    Object? errorCode = _shouldClearCode,
  }) {
    return OnboardingCompletionState(
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      errorCode: identical(errorCode, _shouldClearCode)
          ? this.errorCode
          : errorCode as OnboardingErrorCode?,
    );
  }

  /// Initial state before any check has run.
  factory OnboardingCompletionState.unknown() =>
      const OnboardingCompletionState(
        isLoading: true,
        isCompleted: false,
        errorCode: null,
      );

  /// Safe default when there is no authenticated user.
  factory OnboardingCompletionState.signedOut() =>
      const OnboardingCompletionState(
        isLoading: false,
        isCompleted: false,
        errorCode: null,
      );
}

const _shouldClearCode = Object();

class OnboardingCompletionController
    extends StateNotifier<OnboardingCompletionState> {
  OnboardingCompletionController({
    required this._onboardingRepository,
    String? userId,
  }) : _currentUserId = userId,
       super(OnboardingCompletionState.unknown()) {
    if (userId == null || userId.isEmpty) {
      state = OnboardingCompletionState.signedOut();
      return;
    }
    _loadCompletion(userId);
  }

  final OnboardingRepository _onboardingRepository;

  /// The last known user ID used for Firestore queries.
  String? _currentUserId;

  /// Monotonically increasing counter to discard stale async results.
  int _requestId = 0;

  /// Whether the controller has been disposed to prevent state updates.
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Synchronously marks onboarding as completed without a Firestore call.
  ///
  /// Sets [isLoading] to false, [isCompleted] to true, and clears any error.
  /// Call this after a successful Firestore save to instantly update the
  /// router-aware completion state.
  void markCompleted() {
    if (_disposed) return;
    state = const OnboardingCompletionState(
      isLoading: false,
      isCompleted: true,
      errorCode: null,
    );
  }

  /// Refreshes the completion status by re-fetching from Firestore.
  ///
  /// Sets [isLoading] to true immediately. On success, updates [isCompleted]
  /// to the value returned by the repository. On failure, sets an error and
  /// keeps [isCompleted] as false. The caller should check the state after
  /// awaiting this method.
  Future<void> refresh() async {
    if (_disposed) return;

    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      state = OnboardingCompletionState.signedOut();
      return;
    }

    state = state.copyWith(isLoading: true, errorCode: null);
    await _loadCompletion(userId);
  }

  /// Called when the authenticated user changes.
  void updateUserId(String? userId) {
    // Cancel any in-flight request by bumping the counter.
    _requestId++;

    _currentUserId = userId;

    if (userId == null || userId.isEmpty) {
      state = OnboardingCompletionState.signedOut();
      return;
    }

    state = OnboardingCompletionState.unknown();
    _loadCompletion(userId);
  }

  Future<void> _loadCompletion(String userId) async {
    final capturedRequestId = ++_requestId;

    try {
      final completed = await _onboardingRepository.hasCompletedOnboarding(
        userId,
      );

      // Discard if a newer request has been issued or the controller
      // has been disposed.
      if (capturedRequestId != _requestId || _disposed) return;

      state = OnboardingCompletionState(
        isLoading: false,
        isCompleted: completed,
        errorCode: null,
      );
    } catch (error, stackTrace) {
      debugPrint('Onboarding completion check failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      // Discard if a newer request has been issued or the controller
      // has been disposed.
      if (capturedRequestId != _requestId || _disposed) return;

      state = OnboardingCompletionState(
        isLoading: false,
        isCompleted: false,
        errorCode: OnboardingErrorCode.checkFailed,
      );
    }
  }
}

final onboardingCompletionProvider =
    StateNotifierProvider<
      OnboardingCompletionController,
      OnboardingCompletionState
    >((ref) {
      final onboardingRepository = ref.watch(onboardingRepositoryProvider);

      // Watch only the authenticated user's ID — no second FirebaseAuth listener.
      final userId = ref.watch(
        authControllerProvider.select((state) => state.user?.uid),
      );

      final controller = OnboardingCompletionController(
        onboardingRepository: onboardingRepository,
        userId: userId,
      );

      // React to future user changes without creating a second listener.
      ref.listen<String?>(
        authControllerProvider.select((state) => state.user?.uid),
        (previous, next) {
          controller.updateUserId(next);
        },
      );

      return controller;
    });
