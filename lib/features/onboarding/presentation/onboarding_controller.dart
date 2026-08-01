import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/onboarding_profile.dart';
import '../data/onboarding_repository.dart';
import '../data/onboarding_providers.dart';
import 'onboarding_state.dart' show OnboardingErrorCode, OnboardingState;

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController({required OnboardingRepository repository})
    : _repository = repository,
      super(const OnboardingState());

  final OnboardingRepository _repository;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void selectLanguage(OnboardingLanguage language) {
    state = state.copyWith(selectedLanguage: language, errorCode: null);
  }

  void selectExperience(SingingExperience experience) {
    state = state.copyWith(experienceLevel: experience, errorCode: null);
  }

  void toggleGoal(SingingGoal goal) {
    final newGoals = Set<SingingGoal>.from(state.selectedGoals);
    if (newGoals.contains(goal)) {
      newGoals.remove(goal);
    } else {
      newGoals.add(goal);
    }
    state = state.copyWith(selectedGoals: newGoals, errorCode: null);
  }

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        errorCode: null,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        errorCode: null,
      );
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step, errorCode: null);
    }
  }

  void resetOnboarding() {
    state = const OnboardingState();
  }

  Future<bool> completeOnboarding({required String userId}) async {
    if (_disposed) return false;
    if (state.isLoading) return false;

    if (userId.isEmpty) {
      state = state.copyWith(errorCode: OnboardingErrorCode.saveFailed);
      return false;
    }

    if (state.selectedLanguage == null) {
      state = state.copyWith(errorCode: OnboardingErrorCode.languageRequired);
      return false;
    }

    if (state.experienceLevel == null) {
      state = state.copyWith(errorCode: OnboardingErrorCode.experienceRequired);
      return false;
    }

    if (state.selectedGoals.isEmpty) {
      state = state.copyWith(errorCode: OnboardingErrorCode.goalRequired);
      return false;
    }

    state = state.copyWith(isLoading: true, errorCode: null);

    try {
      final profile = OnboardingProfile(
        selectedLanguage: state.selectedLanguage,
        experienceLevel: state.experienceLevel,
        selectedGoals: Set<SingingGoal>.from(state.selectedGoals),
        isCompleted: true,
      );

      await _repository.saveProfile(userId, profile);

      if (_disposed) return false;

      state = state.copyWith(isCompleted: true, isLoading: false);
      return true;
    } on OnboardingRepositoryException {
      if (_disposed) return false;
      state = state.copyWith(
        isLoading: false,
        errorCode: OnboardingErrorCode.saveFailed,
      );
      return false;
    } catch (error, stackTrace) {
      debugPrint('Onboarding complete failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (_disposed) return false;
      state = state.copyWith(
        isLoading: false,
        errorCode: OnboardingErrorCode.saveFailed,
      );
      return false;
    }
  }

  bool validateCurrentStep() {
    switch (state.currentStep) {
      case 0:
        if (state.selectedLanguage == null) {
          state = state.copyWith(
            errorCode: OnboardingErrorCode.languageRequired,
          );
          return false;
        }
        break;
      case 1:
        if (state.experienceLevel == null) {
          state = state.copyWith(
            errorCode: OnboardingErrorCode.experienceRequired,
          );
          return false;
        }
        break;
      case 2:
        if (state.selectedGoals.isEmpty) {
          state = state.copyWith(errorCode: OnboardingErrorCode.goalRequired);
          return false;
        }
        break;
      case 3:
      case 4:
        break;
    }
    state = state.copyWith(errorCode: null);
    return true;
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
      final repository = ref.watch(onboardingRepositoryProvider);
      return OnboardingController(repository: repository);
    });
