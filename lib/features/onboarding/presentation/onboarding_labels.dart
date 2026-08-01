import '../../../l10n/app_localizations.dart';
import '../domain/onboarding_profile.dart';

/// Localized display name for a [SingingExperience] value.
String experienceLabelText(AppLocalizations l10n, SingingExperience e) {
  switch (e) {
    case SingingExperience.beginner:
      return l10n.beginner;
    case SingingExperience.intermediate:
      return l10n.intermediate;
    case SingingExperience.advanced:
      return l10n.advanced;
    case SingingExperience.professional:
      return l10n.professional;
  }
}

/// Localized display name for an [OnboardingLanguage] value.
String languageLabelText(AppLocalizations l10n, OnboardingLanguage l) {
  switch (l) {
    case OnboardingLanguage.english:
      return l10n.english;
    case OnboardingLanguage.tamil:
      return l10n.tamil;
    case OnboardingLanguage.hindi:
      return l10n.hindi;
  }
}

/// Localized display name for a [SingingGoal] value.
String goalLabelText(AppLocalizations l10n, SingingGoal g) {
  switch (g) {
    case SingingGoal.improvePitchAccuracy:
      return l10n.improvePitchAccuracy;
    case SingingGoal.increaseVocalRange:
      return l10n.increaseVocalRange;
    case SingingGoal.improveBreathControl:
      return l10n.improveBreathControl;
    case SingingGoal.improveRhythmTiming:
      return l10n.improveRhythmTiming;
    case SingingGoal.improveVoiceStability:
      return l10n.improveVoiceStability;
    case SingingGoal.buildSingingConfidence:
      return l10n.buildSingingConfidence;
  }
}
