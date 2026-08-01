import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/onboarding_profile.dart';
import '../onboarding_controller.dart';
import '../onboarding_state.dart' show OnboardingErrorCode;

class GoalsStep extends ConsumerWidget {
  const GoalsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final goals = SingingGoal.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.whatAreYourGoals,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.goalsSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final spacing = 12.0;
            final childWidth = isWide
                ? (constraints.maxWidth - spacing) / 2
                : constraints.maxWidth;

            return Column(
              children: [
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: goals.map((goal) {
                    return SizedBox(
                      width: childWidth,
                      child: _GoalCard(
                        goal: goal,
                        isSelected: state.selectedGoals.contains(goal),
                        onTap: () => controller.toggleGoal(goal),
                        l10n: l10n,
                      ),
                    );
                  }).toList(),
                ),
                if (state.errorCode != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage(context, state.errorCode!),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  /// Maps [OnboardingErrorCode] to the correct l10n error string.
  String _errorMessage(BuildContext context, OnboardingErrorCode code) {
    final l10n = AppLocalizations.of(context)!;
    return switch (code) {
      OnboardingErrorCode.languageRequired => l10n.onboardingLanguageRequired,
      OnboardingErrorCode.experienceRequired =>
        l10n.onboardingExperienceRequired,
      OnboardingErrorCode.goalRequired => l10n.onboardingGoalRequired,
      OnboardingErrorCode.saveFailed => l10n.setupSaveFailed,
      OnboardingErrorCode.checkFailed => l10n.onboardingCheckFailed,
    };
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
    required this.l10n,
  });

  final SingingGoal goal;
  final bool isSelected;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  String _getLabel(SingingGoal goal) {
    switch (goal) {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      selected: isSelected,
      button: true,
      label: l10n.goalLabel(_getLabel(goal)),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    size: 24,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _getLabel(goal),
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
