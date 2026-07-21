import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/icon_position.dart';
import '../../../../core/widgets/responsive_page_background.dart';
import '../../presentation/voice_recording_controller.dart';
import '../../domain/voice_recording_state.dart';
import '../../../auth/presentation/widgets/auth_elevated_button.dart';
import '../../../auth/presentation/widgets/auth_secondary_button.dart';
import '../../../auth/presentation/widgets/auth_destructive_button.dart';
import '../../../../common/widgets/app_back_button.dart';
import '../../../../common/utils/navigation_helpers.dart';

class VoicePracticeScreen extends ConsumerStatefulWidget {
  const VoicePracticeScreen({super.key});

  @override
  ConsumerState<VoicePracticeScreen> createState() =>
      _VoicePracticeScreenState();
}

class _VoicePracticeScreenState extends ConsumerState<VoicePracticeScreen>
    with SingleTickerProviderStateMixin {
  bool _isBackInProgress = false;

  Future<void> _handleBackPressed() async {
    if (_isBackInProgress) return;
    _isBackInProgress = true;

    try {
      final currentState = ref.read(voiceRecordingControllerProvider);
      final controller = ref.read(voiceRecordingControllerProvider.notifier);

      if (!context.mounted) return;

      // Recording: confirm discard.
      if (currentState.isRecording) {
        final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Discard recording?'),
            content: const Text('Your current recording will not be saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Keep Recording'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Discard and Go Back'),
              ),
            ],
          ),
        );

        if (!context.mounted) return;
        if (shouldDiscard == true) {
          await controller.cancelRecording();
          if (!context.mounted) return;
          await navigateBackSafely(context, fallbackRoute: '/home');
        }
        return;
      }

      // If a saved recording exists: reset its state and go back to dashboard.
      // (No file deletion attempts here.)
      if (currentState.hasRecording) {
        // Saved recording: reset recording state and go back.
        controller.reset();
        if (!context.mounted) return;
        await navigateBackSafely(context, fallbackRoute: '/home');
        return;
      }

      // Analysis pending route should use controller state to decide.
      // In this screen we only have recording state; if a valid recording exists
      // return to practice/review, otherwise go to dashboard.
      // No recording in-memory: just go back to dashboard.
      await navigateBackSafely(context, fallbackRoute: '/home');
    } finally {
      _isBackInProgress = false;
    }
  }

  late final AnimationController _pulseController;

  late final Animation<double> _pulseScale;
  bool _isStartupInProgress = false;

  bool _isMicrophoneBusy = false;
  bool _isMicrophonePressed = false;
  bool _lastIsRecording = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(voiceRecordingControllerProvider.notifier).requestPermission();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final state = ref.read(voiceRecordingControllerProvider);
    final shouldBeRecordingMode = state.isRecording;

    if (shouldBeRecordingMode) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_lastIsRecording) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    _lastIsRecording = shouldBeRecordingMode;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceRecordingControllerProvider);
    final controller = ref.read(voiceRecordingControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ResponsivePageBackground(
            imagePath: 'assets/images/practice_bg.png',
            mobileAlignment: Alignment.center,
            wideAlignment: Alignment.bottomCenter,
            mobileOverlayAlpha: 0.22,
            wideOverlayAlpha: 0.14,
            maxContentWidth: 900,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        48,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 56),
                      Text(
                        'Voice Practice',
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Record your singing and get AI-powered feedback on pitch, rhythm, and tone.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildRecordingUI(state, controller, textTheme),
                      const SizedBox(height: 48),
                      if (state.isError)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  state.whenOrNull(error: (msg) => msg) ??
                                      'An error occurred',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => controller.reset(),
                                child: const Text('Dismiss'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Back button on top of everything
          Positioned(
            top: 8,
            left: 8,
            child: AppBackButton(
              onPressed: () {
                debugPrint('VOICE PRACTICE BACK PRESSED');
                _handleBackPressed();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingUI(
    VoiceRecordingState state,
    VoiceRecordingController controller,
    TextTheme textTheme,
  ) {
    final isRecording = state.isRecording;
    final isRequestingPermission = state is RequestingPermissionState;
    final isPermissionDenied = state is PermissionDeniedState;
    final hasRecording = state.hasRecording;
    final isDisabled = isRecording || _isStartupInProgress;

    if (isRequestingPermission) {
      return Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primaryCoral),
          const SizedBox(height: 24),
          Text(
            'Requesting microphone permission...',
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    if (isPermissionDenied) {
      return Column(
        children: [
          const Icon(Icons.mic_off_rounded, size: 80, color: AppColors.error),
          const SizedBox(height: 24),
          Text(
            'Microphone Permission Required',
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Please enable microphone access in settings to record your voice.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          AuthElevatedButton(
            label: 'Open Settings',
            onPressed: () async {
              await controller.requestPermission();
            },
            isLoading: false,
            icon: Icons.settings_rounded,
            iconPosition: IconPosition.start,
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildMicrophoneButton(isRecording, controller, textTheme),
        const SizedBox(height: 32),
        _buildTimerDisplay(state, textTheme),
        const SizedBox(height: 32),
        _buildActionButtons(
          state,
          controller,
          textTheme,
          isRecording,
          hasRecording,
          isDisabled,
        ),
      ],
    );
  }

  Future<void> _handleMicrophoneTap(
    VoiceRecordingController controller,
    bool isRecording,
  ) async {
    if (!mounted) return;

    if (_isMicrophoneBusy) return;

    _isMicrophoneBusy = true;

    try {
      if (isRecording) {
        await controller.stopRecording();
      } else {
        await _handleStartRecording(controller);
      }
    } finally {
      _isMicrophoneBusy = false;
    }
  }

  Widget _buildMicrophoneButton(
    bool isRecording,
    VoiceRecordingController controller,
    TextTheme textTheme,
  ) {
    final isBusy = _isMicrophoneBusy || _isStartupInProgress;

    final microphoneCircle = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isRecording
            ? AppColors.microphoneRecordingGradient
            : AppColors.microphoneIdleGradient,
        boxShadow: [
          BoxShadow(
            color: (isRecording ? AppColors.error : AppColors.primaryCoral)
                .withValues(alpha: 0.5),
            blurRadius: isRecording ? 40 : 30,
            spreadRadius: isRecording ? 10 : 5,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isRecording
              ? Container(
                  key: const ValueKey('recording'),
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stop_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                )
              : Container(
                  key: const ValueKey('idle'),
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    size: 45,
                    color: AppColors.primaryMagenta,
                  ),
                ),
        ),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse ring
        if (isRecording)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseScale.value,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.6),
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        // Wrapped clickable circle (full control ripple + pressed animation)
        Semantics(
          button: true,
          label: isRecording ? 'Stop recording' : 'Start recording',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                mouseCursor: SystemMouseCursors.click,
                hoverColor: Colors.white.withValues(alpha: 0.10),
                highlightColor: Colors.white.withValues(alpha: 0.20),
                splashColor: Colors.white.withValues(alpha: 0.30),
                onTap: isBusy
                    ? null
                    : () => _handleMicrophoneTap(controller, isRecording),
                onHighlightChanged: (isPressed) {
                  setState(() {
                    _isMicrophonePressed = isPressed;
                  });
                },
                child: AnimatedScale(
                  scale: _isMicrophonePressed ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  child: microphoneCircle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleStartRecording(
    VoiceRecordingController controller,
  ) async {
    if (!mounted) return;
    if (_isStartupInProgress ||
        ref.read(voiceRecordingControllerProvider).isRecording) {
      return;
    }

    final hasPermission = await controller.hasPermission();
    if (!mounted) return;

    if (!hasPermission) {
      await controller.requestPermission();
      if (!mounted) return;

      final currentState = ref.read(voiceRecordingControllerProvider);
      if (currentState is PermissionDeniedState) return;
    }

    if (!mounted) return;
    await controller.startRecording();
  }

  Widget _buildTimerDisplay(VoiceRecordingState state, TextTheme textTheme) {
    final duration = state.duration ?? Duration.zero;

    return Column(
      children: [
        Text(
          _formatDuration(duration),
          style: textTheme.displayMedium?.copyWith(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.isRecording
              ? 'Recording...'
              : (state.hasRecording ? 'Recording saved' : 'Ready to record'),
          style: textTheme.bodyLarge?.copyWith(
            color: state.isRecording
                ? AppColors.warning
                : (state.hasRecording
                      ? AppColors.success
                      : AppColors.textSecondary),
            fontWeight: state.isRecording || state.hasRecording
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    VoiceRecordingState state,
    VoiceRecordingController controller,
    TextTheme textTheme,
    bool isRecording,
    bool hasRecording,
    bool isDisabled,
  ) {
    if (isRecording) {
      return LayoutBuilder(
        builder: (context, constraints) {
          const minWidthForRow = 600.0;
          final useRowLayout = constraints.maxWidth >= minWidthForRow;

          final cancelButton = AuthSecondaryButton(
            label: 'Cancel',
            onPressed: isDisabled
                ? null
                : () async {
                    if (_isMicrophoneBusy) return;
                    _isMicrophoneBusy = true;
                    try {
                      await controller.cancelRecording();
                      if (!context.mounted) return;
                      // stay on screen; state will go Idle
                    } finally {
                      _isMicrophoneBusy = false;
                    }
                  },
            icon: Icons.close_rounded,
            iconPosition: IconPosition.start,
          );

          final stopButton = AuthElevatedButton(
            label: 'Stop Recording',
            onPressed: isDisabled
                ? null
                : () async {
                    if (_isMicrophoneBusy) return;
                    _isMicrophoneBusy = true;
                    try {
                      await controller.stopRecording();
                    } finally {
                      _isMicrophoneBusy = false;
                    }
                  },
            isLoading: false,
            icon: Icons.stop_rounded,
            iconPosition: IconPosition.start,
          );

          if (useRowLayout) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: cancelButton),
                const SizedBox(width: 12),
                Expanded(child: stopButton),
              ],
            );
          }

          return Column(
            children: [
              SizedBox(width: double.infinity, child: cancelButton),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: stopButton),
            ],
          );
        },
      );
    }

    if (hasRecording) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recording saved — ${_formatDuration(state.duration ?? Duration.zero)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AuthDestructiveButton(
                  label: 'Delete & Record Again',
                  onPressed: () {
                    final path = state.audioPath;
                    if (path != null) {
                      controller.deleteRecording(path);
                    }
                  },
                  icon: Icons.delete_rounded,
                  iconPosition: IconPosition.start,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AuthElevatedButton(
                  label: 'Review Recording',
                  onPressed: () {
                    final path = state.audioPath;
                    if (path != null) {
                      context.go('/practice/review', extra: path);
                    }
                  },
                  isLoading: false,
                  icon: Icons.play_arrow_rounded,
                  iconPosition: IconPosition.start,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        AuthElevatedButton(
          label: 'Start Recording',
          onPressed: isDisabled
              ? null
              : () => _handleStartRecording(controller),
          isLoading: false,
          icon: Icons.fiber_manual_record_rounded,
          iconPosition: IconPosition.start,
        ),
        const SizedBox(height: 16),
        Text(
          'Or tap the microphone above',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
