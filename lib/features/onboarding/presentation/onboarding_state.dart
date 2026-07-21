import '../domain/onboarding_profile.dart';

class _ClearErrorMessage {
  const _ClearErrorMessage();
}

const _clearErrorMessage = _ClearErrorMessage();

class OnboardingState {
  const OnboardingState({
    this.currentStep = 0,
    this.selectedLanguage,
    this.experienceLevel,
    this.selectedGoals = const <SingingGoal>{},
    this.errorMessage,
    this.isCompleted = false,
    this.isLoading = false,
  });

  final int currentStep;
  final OnboardingLanguage? selectedLanguage;
  final SingingExperience? experienceLevel;
  final Set<SingingGoal> selectedGoals;
  final String? errorMessage;
  final bool isCompleted;
  final bool isLoading;

  OnboardingState copyWith({
    int? currentStep,
    OnboardingLanguage? selectedLanguage,
    SingingExperience? experienceLevel,
    Set<SingingGoal>? selectedGoals,
    Object? errorMessage = _clearErrorMessage,
    bool? isCompleted,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      errorMessage: identical(errorMessage, _clearErrorMessage)
          ? this.errorMessage
          : errorMessage as String?,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
