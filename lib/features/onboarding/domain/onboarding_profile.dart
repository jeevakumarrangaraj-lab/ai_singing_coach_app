import 'package:cloud_firestore/cloud_firestore.dart';

enum OnboardingLanguage {
  english('English', 'en'),
  tamil('Tamil', 'ta');

  const OnboardingLanguage(this.label, this.code);
  final String label;
  final String code;

  static OnboardingLanguage? fromCode(String code) {
    for (final lang in OnboardingLanguage.values) {
      if (lang.code == code) return lang;
    }
    return null;
  }

  static OnboardingLanguage? fromLabel(String label) {
    for (final lang in OnboardingLanguage.values) {
      if (lang.label == label) return lang;
    }
    return null;
  }
}

enum SingingExperience {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  professional('Professional');

  const SingingExperience(this.label);
  final String label;

  static SingingExperience? fromLabel(String label) {
    for (final exp in SingingExperience.values) {
      if (exp.label == label) return exp;
    }
    return null;
  }
}

enum SingingGoal {
  improvePitchAccuracy('Improve pitch accuracy'),
  increaseVocalRange('Increase vocal range'),
  improveBreathControl('Improve breath control'),
  improveRhythmTiming('Improve rhythm and timing'),
  improveVoiceStability('Improve voice stability'),
  buildSingingConfidence('Build singing confidence');

  const SingingGoal(this.label);
  final String label;

  static SingingGoal? fromLabel(String label) {
    for (final goal in SingingGoal.values) {
      if (goal.label == label) return goal;
    }
    return null;
  }
}

class OnboardingProfile {
  const OnboardingProfile({
    this.selectedLanguage,
    this.experienceLevel,
    required this.selectedGoals,
    this.isCompleted = false,
  });

  final OnboardingLanguage? selectedLanguage;
  final SingingExperience? experienceLevel;
  final Set<SingingGoal> selectedGoals;
  final bool isCompleted;

  Map<String, dynamic> toFirestore() {
    return {
      'selectedLanguage': selectedLanguage?.code,
      'experienceLevel': experienceLevel?.name,
      'selectedGoals': selectedGoals.map((g) => g.name).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory OnboardingProfile.fromFirestore(Map<String, dynamic> data) {
    return OnboardingProfile(
      selectedLanguage: data['selectedLanguage'] != null
          ? OnboardingLanguage.fromCode(data['selectedLanguage'])
          : null,
      experienceLevel: data['experienceLevel'] != null
          ? SingingExperience.values.firstWhere(
              (e) => e.name == data['experienceLevel'],
              orElse: () => SingingExperience.beginner,
            )
          : null,
      selectedGoals:
          (data['selectedGoals'] as List<dynamic>?)
              ?.map(
                (g) => SingingGoal.values.firstWhere(
                  (goal) => goal.name == g,
                  orElse: () => SingingGoal.improvePitchAccuracy,
                ),
              )
              .toSet() ??
          {},
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  factory OnboardingProfile.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) return const OnboardingProfile(selectedGoals: {});
    return OnboardingProfile.fromFirestore(data);
  }

  OnboardingProfile copyWith({
    OnboardingLanguage? selectedLanguage,
    SingingExperience? experienceLevel,
    Set<SingingGoal>? selectedGoals,
    bool? isCompleted,
  }) {
    return OnboardingProfile(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
