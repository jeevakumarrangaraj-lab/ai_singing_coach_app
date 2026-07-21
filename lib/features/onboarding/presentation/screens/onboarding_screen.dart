import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/icon_position.dart';
import '../../../../core/widgets/responsive_page_background.dart';
import '../../../../common/widgets/app_back_button.dart';
import '../../../auth/presentation/widgets/auth_elevated_button.dart';
import '../../../auth/presentation/widgets/auth_secondary_button.dart';
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ResponsivePageBackground(
            imagePath: 'assets/images/signup_bg.png',
            mobileAlignment: Alignment.center,
            wideAlignment: Alignment.bottomCenter,
            mobileOverlayAlpha: 0.30,
            wideOverlayAlpha: 0.30,
            maxContentWidth: 900,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'Set up your Tuno experience',
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Step ${state.currentStep + 1} of 5',
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.85,
                                ),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            LinearProgressIndicator(
                              value: (state.currentStep + 1) / 5,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                              backgroundColor: AppColors.border.withValues(
                                alpha: 0.4,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryCoral,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildCurrentStepContent(
                              context,
                              state,
                              controller,
                            ),
                            const SizedBox(height: 32),
                            // Step 5 (Review) has its own "Complete Setup" button
                            // inside OnboardingReviewStep. Show only Back here.
                            if (state.currentStep < 4)
                              Row(
                                children: [
                                  Expanded(
                                    child: AuthSecondaryButton(
                                      label: 'Back',
                                      onPressed: state.currentStep > 0
                                          ? controller.previousStep
                                          : null,
                                      icon: Icons.arrow_back_ios_new_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AuthElevatedButton(
                                      label: 'Continue',
                                      onPressed: () {
                                        if (controller.validateCurrentStep()) {
                                          controller.nextStep();
                                        }
                                      },
                                      icon: Icons.arrow_forward_ios_rounded,
                                      iconPosition: IconPosition.end,
                                      isLoading: false,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: AuthSecondaryButton(
                                      label: 'Back',
                                      onPressed: () =>
                                          controller.previousStep(),
                                      icon: Icons.arrow_back_ios_new_rounded,
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
                  );
                },
              ),
            ),
          ),
          // Back button on top of everything
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
    );
  }

  Widget _buildStepPlaceholder(
    BuildContext context,
    String stepName,
    String? errorMessage,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStepIcon(stepName), size: 56, color: AppColors.primaryCoral),
          const SizedBox(height: 20),
          Text(
            'Step $stepName',
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Content for $stepName step will be implemented here.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.4),
                ),
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
                      errorMessage,
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
