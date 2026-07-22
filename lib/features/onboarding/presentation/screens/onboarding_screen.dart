import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/app_back_button.dart';
import '../widgets/experience_step.dart';
import '../widgets/goals_step.dart';
import '../widgets/language_step.dart';
import '../widgets/onboarding_review_step.dart';
import '../widgets/permission_education_step.dart';
import '../onboarding_controller.dart';
import '../onboarding_state.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 68, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Set up your Tuno experience',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Step ${state.currentStep + 1} of 5',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: (state.currentStep + 1) / 5,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildCurrentStepContent(context, state, controller),
                        const SizedBox(height: 32),
                        // Step 5 (Review) has its own "Complete Setup" button
                        // inside OnboardingReviewStep. Show only Back here.
                        if (state.currentStep < 4)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      state.currentStep > 0 && !state.isLoading
                                      ? controller.previousStep
                                      : null,
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Back'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          if (controller
                                              .validateCurrentStep()) {
                                            controller.nextStep();
                                          }
                                        },
                                  icon: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Continue'),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: !state.isLoading
                                      ? controller.previousStep
                                      : null,
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Back'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Back button on top of everything (last child for hit-test)
            Positioned(
              top: 8,
              left: 8,
              child: AppBackButton(
                onPressed: () {
                  if (state.currentStep > 0) {
                    controller.previousStep();
                  } else {
                    context.go('/home');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPlaceholder(
    BuildContext context,
    String stepName,
    String? errorMessage,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStepIcon(stepName), size: 56, color: colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            'Step $stepName',
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Content for $stepName step will be implemented here.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
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
                      errorMessage,
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
      ),
    );
  }

  IconData _getStepIcon(String stepName) {
    switch (stepName) {
      case 'Language':
        return Icons.language_rounded;
      case 'Experience':
        return Icons.trending_up_rounded;
      case 'Goals':
        return Icons.flag_rounded;
      case 'Microphone':
        return Icons.mic_rounded;
      case 'Review':
        return Icons.checklist_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _buildCurrentStepContent(
    BuildContext context,
    OnboardingState state,
    OnboardingController controller,
  ) {
    const stepLabels = [
      'Language',
      'Experience',
      'Goals',
      'Microphone',
      'Review',
    ];

    switch (state.currentStep) {
      case 0:
        return const LanguageStep();
      case 1:
        return const ExperienceStep();
      case 2:
        return const GoalsStep();
      case 3:
        return const PermissionEducationStep();
      case 4:
        return const OnboardingReviewStep();
      default:
        return _buildStepPlaceholder(
          context,
          stepLabels[state.currentStep],
          state.errorMessage,
        );
    }
  }
}
