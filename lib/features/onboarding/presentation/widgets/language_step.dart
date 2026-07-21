import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/onboarding_profile.dart';
import '../onboarding_controller.dart';

class LanguageStep extends ConsumerWidget {
  const LanguageStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    final languages = OnboardingLanguage.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What language do you sing in?',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us tailor your practice recommendations.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.85),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...languages.map(
          (language) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _LanguageCard(
              language: language,
              isSelected: state.selectedLanguage == language,
              onTap: () => controller.selectLanguage(language),
            ),
          ),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
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
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final OnboardingLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  String _getDescription(OnboardingLanguage lang) {
    switch (lang) {
      case OnboardingLanguage.english:
        return 'Practice with English songs and exercises.';
      case OnboardingLanguage.tamil:
        return 'Practice with Tamil songs and exercises.';
      case OnboardingLanguage.hindi:
        return 'Practice with Hindi songs and exercises.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final description = _getDescription(language);

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
                child: const Icon(
                  Icons.language_rounded,
                  size: 24,
                  color: AppColors.primaryCoral,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.label,
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
