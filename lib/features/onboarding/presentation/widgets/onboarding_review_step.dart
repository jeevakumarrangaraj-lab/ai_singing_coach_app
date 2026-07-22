import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../features/auth/presentation/auth_controller.dart';
import '../../domain/onboarding_profile.dart';
import '../onboarding_controller.dart';
import '../onboarding_completion_provider.dart';

class OnboardingReviewStep extends ConsumerStatefulWidget {
  const OnboardingReviewStep({super.key});

  @override
  ConsumerState<OnboardingReviewStep> createState() =>
      _OnboardingReviewStepState();
}

class _OnboardingReviewStepState extends ConsumerState<OnboardingReviewStep> {
  /// Guards against duplicate submissions while the Firestore save is in-flight
  /// and prevents a second navigation after a successful save.
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Review your setup',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Check your selections and edit if needed.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Language card
        _ReviewCard(
          title: 'Language',
          value: state.selectedLanguage?.label ?? 'Not selected',
          icon: Icons.language_rounded,
          onEdit: () => controller.goToStep(0),
        ),
        const SizedBox(height: 12),

        // Experience card
        _ReviewCard(
          title: 'Experience Level',
          value: state.experienceLevel?.label ?? 'Not selected',
          icon: Icons.trending_up_rounded,
          onEdit: () => controller.goToStep(1),
        ),
        const SizedBox(height: 12),

        // Goals card
        _GoalsReviewCard(
          goals: state.selectedGoals,
          onEdit: () => controller.goToStep(2),
        ),
        const SizedBox(height: 12),

        // Microphone permission card
        const _MicrophonePermissionCard(),
        const SizedBox(height: 24),

        // Complete Setup button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: (state.isLoading || _isSubmitting)
                ? null
                : _handleCompleteSetup,
            icon: (state.isLoading || _isSubmitting)
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 22),
            label: const Text(
              'Complete Setup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCompleteSetup() async {
    // Guard: prevent duplicate submission and navigation.
    if (_isSubmitting) return;
    _isSubmitting = true;

    try {
      final onboardingController = ref.read(
        onboardingControllerProvider.notifier,
      );

      // Validate current step (review step always passes validation, but
      // we call it for consistency).
      if (!onboardingController.validateCurrentStep()) {
        _isSubmitting = false;
        return;
      }

      // Read auth state before awaiting any async work.
      final authState = ref.read(authControllerProvider);
      final userId = authState.user?.uid;

      if (userId == null || userId.isEmpty) {
        _isSubmitting = false;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please sign in again to complete your setup.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      // Persist onboarding data to Firestore.
      final success = await onboardingController.completeOnboarding(
        userId: userId,
      );

      if (!mounted) return;

      if (success) {
        // Synchronously mark onboarding as completed so GoRouter redirect
        // sees the latest state immediately.
        ref.read(onboardingCompletionProvider.notifier).markCompleted();

        if (!mounted) return;

        // Navigate to /home exactly once. GoRouter's redirect will confirm
        // the destination, but we drive the final navigation here.
        context.go('/home');
        // _isSubmitting intentionally left true — component is no longer
        // rendered after navigation.
      } else {
        // Save failed: re-enable the button and show the error SnackBar.
        _isSubmitting = false;
        if (!mounted) return;
        final currentState = ref.read(onboardingControllerProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentState.errorMessage ??
                  'We couldn\'t save your setup. Please try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (error) {
      _isSubmitting = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onEdit,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalsReviewCard extends StatelessWidget {
  const _GoalsReviewCard({required this.goals, required this.onEdit});

  final Set<SingingGoal> goals;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    size: 22,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Singing Goals',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goals.isEmpty
                            ? 'No goals selected'
                            : '${goals.length} goal(s) selected',
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            if (goals.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: goals.map((goal) {
                  return Chip(
                    label: Text(
                      goal.label,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    backgroundColor: colorScheme.surfaceContainerHigh,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    shape: const StadiumBorder(),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MicrophonePermissionCard extends ConsumerWidget {
  const _MicrophonePermissionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<bool>(
      future: _checkMicrophonePermission(),
      builder: (context, snapshot) {
        final hasPermission = snapshot.data ?? false;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Card(
          color: colorScheme.surfaceContainerHighest,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        (hasPermission
                                ? colorScheme.primary
                                : colorScheme.error)
                            .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          ),
                        )
                      : Icon(
                          hasPermission
                              ? Icons.mic_rounded
                              : Icons.mic_off_rounded,
                          size: 22,
                          color: hasPermission
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Microphone Access',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLoading
                            ? 'Checking permission...'
                            : hasPermission
                            ? 'Permission granted'
                            : 'Permission not granted (required for recording)',
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: hasPermission
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _requestPermission(context),
                  icon: const Icon(Icons.settings_rounded, size: 16),
                  label: const Text('Change'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<void> _requestPermission(BuildContext context) async {
    try {
      final status = await Permission.microphone.request();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status.isGranted
                  ? 'Microphone permission granted.'
                  : 'Microphone permission denied.',
            ),
            backgroundColor: status.isGranted
                ? null
                : Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not request permission.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
