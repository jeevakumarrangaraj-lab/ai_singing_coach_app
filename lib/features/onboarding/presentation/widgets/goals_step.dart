import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/onboarding_profile.dart';
import '../onboarding_controller.dart';
import '../onboarding_state.dart';

class GoalsStep extends ConsumerWidget {
  const GoalsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    final goals = SingingGoal.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What are your singing goals?',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply. You can change these later.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.85),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            if (isWide) {
              return _buildTwoColumnGrid(context, goals, state, controller);
            }
            return _buildSingleColumn(context, goals, state, controller);
          },
        ),
      ],
    );
  }

  Widget _buildSingleColumn(
    BuildContext context,
    List<SingingGoal> goals,
    OnboardingState state,
    OnboardingController controller,
  ) {
    return Column(
      children: goals
          .map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GoalCard(
                goal: goal,
                isSelected: state.selectedGoals.contains(goal),
                onTap: () => controller.toggleGoal(goal),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTwoColumnGrid(
    BuildContext context,
    List<SingingGoal> goals,
    OnboardingState state,
    OnboardingController controller,
  ) {
    return Column(
      children: [
        for (var i = 0; i < goals.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _GoalCard(
                    goal: goals[i],
                    isSelected: state.selectedGoals.contains(goals[i]),
                    onTap: () => controller.toggleGoal(goals[i]),
                  ),
                ),
                if (i + 1 < goals.length) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GoalCard(
                      goal: goals[i + 1],
                      isSelected: state.selectedGoals.contains(goals[i + 1]),
                      onTap: () => controller.toggleGoal(goals[i + 1]),
                    ),
                  ),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  final SingingGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryCoral
                        : AppColors.border.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  color: isSelected
                      ? AppColors.primaryCoral
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  goal.label,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryCoral
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
