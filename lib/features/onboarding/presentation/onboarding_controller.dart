import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/onboarding_profile.dart';
import '../data/onboarding_repository.dart';
import '../data/onboarding_providers.dart';
import 'onboarding_state.dart';

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
    state = state.copyWith(selectedLanguage: language, errorMessage: null);
  }

  void selectExperience(SingingExperience experience) {
    state = state.copyWith(experienceLevel: experience, errorMessage: null);
  }

  void toggleGoal(SingingGoal goal) {
    final newGoals = Set<SingingGoal>.from(state.selectedGoals);
    if (newGoals.contains(goal)) {
      newGoals.remove(goal);
    } else {
      newGoals.add(goal);
    }
    state = state.copyWith(selectedGoals: newGoals, errorMessage: null);
  }

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        errorMessage: null,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        errorMessage: null,
      );
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step, errorMessage: null);
    }
  }

  void resetOnboarding() {
    state = const OnboardingState();
  }

  Future<bool> completeOnboarding({required String userId}) async {
    if (_disposed) return false;
    if (state.isLoading) return false;

    if (userId.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Unable to save your Tuno setup. Please try again.',
      );
      return false;
    }

    if (state.selectedLanguage == null) {
      state = state.copyWith(
        errorMessage: 'Please select a language to continue.',
      );
      return false;
    }

    if (state.experienceLevel == null) {
      state = state.copyWith(
        errorMessage: 'Please select your experience level to continue.',
      );
      return false;
    }

    if (state.selectedGoals.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please select at least one goal to continue.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

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
        errorMessage: 'We couldn\'t save your setup. Please try again.',
      );
      return false;
    } catch (error, stackTrace) {
      debugPrint('Onboarding complete failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (_disposed) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to save your Tuno setup. Please try again.',
      );
      return false;
    }
  }

  bool validateCurrentStep() {
    switch (state.currentStep) {
      case 0:
        if (state.selectedLanguage == null) {
          state = state.copyWith(
            errorMessage: 'Please select a language to continue.',
          );
          return false;
        }
        break;
      case 1:
        if (state.experienceLevel == null) {
          state = state.copyWith(
            errorMessage: 'Please select your experience level to continue.',
          );
          return false;
        }
        break;
      case 2:
        if (state.selectedGoals.isEmpty) {
          state = state.copyWith(
            errorMessage: 'Please select at least one goal to continue.',
          );
          return false;
        }
        break;
      case 3:
      case 4:
        break;
    }
    state = state.copyWith(errorMessage: null);
    return true;
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
      final repository = ref.watch(onboardingRepositoryProvider);
      return OnboardingController(repository: repository);
    });
