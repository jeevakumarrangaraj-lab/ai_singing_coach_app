import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/tuno_music_background.dart';
import '../widgets/experience_step.dart';
import '../widgets/goals_step.dart';
import '../widgets/language_step.dart';
import '../widgets/onboarding_review_step.dart';
import '../widgets/permission_education_step.dart';
import '../onboarding_controller.dart';
import '../onboarding_state.dart';
import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.tunoDarkBackground,
      body: TunoMusicBackground(
        variant: TunoMusicBackgroundVariant.login,
        showWaves: true,
        showNotes: true,
        opacity: 0.6,
        child: SafeArea(
          child: Stack(
            children: [
              // Scrollable content
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
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
                            l10n.setupTunoExperience,
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.stepOf(state.currentStep + 1, 5),
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
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
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
                                  child: _OutlinedBackButton(
                                    onPressed:
                                        state.currentStep > 0 &&
                                            !state.isLoading
                                        ? controller.previousStep
                                        : null,
                                    l10n: l10n,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _GradientContinueButton(
                                    onPressed: state.isLoading
                                        ? null
                                        : () {
                                            if (controller
                                                .validateCurrentStep()) {
                                              controller.nextStep();
                                            }
                                          },
                                    l10n: l10n,
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: _OutlinedBackButton(
                                    onPressed: !state.isLoading
                                        ? controller.previousStep
                                        : null,
                                    l10n: l10n,
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
          'Review',
          state.errorCode == null
              ? null
              : AppLocalizations.of(context)!.setupSaveFailed,
        );
    }
  }
}

/// Outlined back button matching the login screen style.
class _OutlinedBackButton extends StatelessWidget {
  const _OutlinedBackButton({required this.onPressed, required this.l10n});

  final VoidCallback? onPressed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.tunoDarkBorder.withValues(alpha: 0.7)
        : AppColors.tunoLightBorder.withValues(alpha: 0.6);

    return Semantics(
      button: true,
      label: l10n.back,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        label: Text(l10n.back),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Gradient continue button with metallic-gold border matching login screen.
class _GradientContinueButton extends StatefulWidget {
  const _GradientContinueButton({required this.onPressed, required this.l10n});

  final VoidCallback? onPressed;
  final AppLocalizations l10n;

  @override
  State<_GradientContinueButton> createState() =>
      _GradientContinueButtonState();
}

class _GradientContinueButtonState extends State<_GradientContinueButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final cs = Theme.of(context).colorScheme;

    // Cyan-to-deep-blue gradient (same as login button)
    const gradient = LinearGradient(
      colors: [Color(0xFF008BA6), Color(0xFF006D98), Color(0xFF014B75)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: [0.0, 0.52, 1.0],
    );

    // Metallic-gold border gradient
    const goldBorderGradient = LinearGradient(
      colors: [
        Color(0xFFFFF2A6),
        Color(0xFFE3B94F),
        Color(0xFFA86D16),
        Color(0xFFF4D675),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final shadowColor = _hovered || _focused
        ? AppColors.tunoCyan.withValues(alpha: 0.35)
        : AppColors.tunoDeepBlue.withValues(alpha: 0.25);

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.l10n.continueAction,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: enabled ? gradient : _disabledGradient(cs),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: _hovered || _focused ? 16 : 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                // Gold border layer
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: goldBorderGradient,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: enabled ? gradient : _disabledGradient(cs),
                        ),
                      ),
                    ),
                  ),
                ),
                // Button content
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: enabled ? widget.onPressed : null,
                    borderRadius: BorderRadius.circular(20),
                    splashColor: Colors.white.withValues(alpha: 0.18),
                    highlightColor: Colors.white.withValues(alpha: 0.10),
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.l10n.continueAction,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _disabledGradient(ColorScheme cs) {
    return LinearGradient(
      colors: [
        cs.onSurface.withValues(alpha: 0.12),
        cs.onSurface.withValues(alpha: 0.08),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
