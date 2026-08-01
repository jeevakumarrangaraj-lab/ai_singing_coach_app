import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/onboarding_profile.dart';
import '../onboarding_controller.dart';
import '../onboarding_state.dart' show OnboardingErrorCode;

class ExperienceStep extends ConsumerWidget {
  const ExperienceStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final experiences = SingingExperience.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.whatIsYourExperience,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.experienceSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...experiences.map(
          (experience) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ExperienceCard(
              experience: experience,
              isSelected: state.experienceLevel == experience,
              onTap: () => controller.selectExperience(experience),
              l10n: l10n,
            ),
          ),
        ),
        // Validation error
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

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.experience,
    required this.isSelected,
    required this.onTap,
    required this.l10n,
  });

  final SingingExperience experience;
  final bool isSelected;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  String _getLabel(SingingExperience exp) {
    switch (exp) {
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

  String _getDescription(SingingExperience exp) {
    switch (exp) {
      case SingingExperience.beginner:
        return l10n.beginnerDescription;
      case SingingExperience.intermediate:
        return l10n.intermediateDescription;
      case SingingExperience.advanced:
        return l10n.advancedDescription;
      case SingingExperience.professional:
        return l10n.professionalDescription;
    }
  }

  IconData _getIcon(SingingExperience exp) {
    switch (exp) {
      case SingingExperience.beginner:
        return Icons.emoji_people_rounded;
      case SingingExperience.intermediate:
        return Icons.trending_up_rounded;
      case SingingExperience.advanced:
        return Icons.star_rounded;
      case SingingExperience.professional:
        return Icons.mic_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final description = _getDescription(experience);
    final icon = _getIcon(experience);

    return Semantics(
      selected: isSelected,
      button: true,
      label: l10n.experienceLabel(_getLabel(experience)),
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
                    icon,
                    size: 24,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLabel(experience),
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
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
