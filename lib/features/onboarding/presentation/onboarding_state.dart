import '../domain/onboarding_profile.dart';

/// Error codes for onboarding validation and save failures.
///
/// These codes are mapped to l10n strings by the consuming widgets,
/// avoiding the need for a BuildContext inside StateNotifiers.
enum OnboardingErrorCode {
  /// User did not select a coaching language.
  languageRequired,

  /// User did not select an experience level.
  experienceRequired,

  /// User did not select at least one singing goal.
  goalRequired,

  /// Firestore save of the onboarding profile failed.
  saveFailed,

  /// Firestore check of onboarding completion status failed.
  checkFailed,
}

class OnboardingState {
  const OnboardingState({
    this.currentStep = 0,
    this.selectedLanguage,
    this.experienceLevel,
    this.selectedGoals = const <SingingGoal>{},
    this.errorCode,
    this.isCompleted = false,
    this.isLoading = false,
  });

  final int currentStep;
  final OnboardingLanguage? selectedLanguage;
  final SingingExperience? experienceLevel;
  final Set<SingingGoal> selectedGoals;

  /// Error code that consuming widgets map to an l10n getter.
  final OnboardingErrorCode? errorCode;

  final bool isCompleted;
  final bool isLoading;

  OnboardingState copyWith({
    int? currentStep,
    OnboardingLanguage? selectedLanguage,
    SingingExperience? experienceLevel,
    Set<SingingGoal>? selectedGoals,
    Object? errorCode = _clearErrorCode,
    bool? isCompleted,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      errorCode: identical(errorCode, _clearErrorCode)
          ? this.errorCode
          : errorCode as OnboardingErrorCode?,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

const _clearErrorCode = Object();
