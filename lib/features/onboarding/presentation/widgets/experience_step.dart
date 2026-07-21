import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/onboarding_profile.dart';
import '../onboarding_controller.dart';

class ExperienceStep extends ConsumerWidget {
  const ExperienceStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    final experiences = SingingExperience.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What is your singing experience?',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us personalize your practice sessions.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.85),
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
            ),
          ),
        ),
      ],
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.experience,
    required this.isSelected,
    required this.onTap,
  });

  final SingingExperience experience;
  final bool isSelected;
  final VoidCallback onTap;

  String _getDescription(SingingExperience exp) {
    switch (exp) {
      case SingingExperience.beginner:
        return 'I am starting my singing journey.';
      case SingingExperience.intermediate:
        return 'I understand basic pitch and rhythm.';
      case SingingExperience.advanced:
        return 'I practise regularly and want detailed improvement.';
      case SingingExperience.professional:
        return 'I perform, teach or record professionally.';
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
    final textTheme = Theme.of(context).textTheme;
    final description = _getDescription(experience);
    final icon = _getIcon(experience);

    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.primaryCoral.withValues(alpha: 0.12),
        highlightColor: AppColors.primaryCoral.withValues(alpha: 0.06),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          borderRadius: 18,
          borderWidth: isSelected ? 2 : 1,
          borderColor: isSelected
              ? AppColors.primaryCoral
              : AppColors.border.withValues(alpha: 0.6),
          backgroundColor: isSelected
              ? AppColors.primaryCoral.withValues(alpha: 0.12)
              : AppColors.surface.withValues(alpha: 0.85),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryCoral.withValues(alpha: 0.2)
                      : AppColors.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryCoral
                        : AppColors.border.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? AppColors.primaryCoral
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.label,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.primaryCoral
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
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
                    color: AppColors.primaryCoral,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
