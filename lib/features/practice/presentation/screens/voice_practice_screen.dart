import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/icon_position.dart';
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
        final cs = Theme.of(context).colorScheme;
        final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: cs.surfaceContainerHighest,
            title: const Text('Discard recording?'),
            content: const Text('Your current recording will not be saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Keep Recording'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: cs.error),
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
  bool _isBusy = false;

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
    if (state.isRecording) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceRecordingControllerProvider);
    final controller = ref.read(voiceRecordingControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'Voice Practice',
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Record your singing and get AI-powered feedback on pitch, rhythm, and tone.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildRecordingUI(state, controller, textTheme, cs),
                      const SizedBox(height: 48),
                      if (state.isError)
                        Card(
                          color: cs.surfaceContainerHighest,
                          surfaceTintColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: cs.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: cs.error,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.whenOrNull(error: (msg) => msg) ??
                                        'An error occurred',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: cs.error,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => controller.reset(),
                                  child: Text('Dismiss'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Back button as last Stack child so it is clickable
          Positioned(
            top: 8,
            left: 8,
            child: Tooltip(
              message: 'Back',
              child: AppBackButton(
                onPressed: _handleBackPressed,
                showOnlyIfCanPop: false,
              ),
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
    ColorScheme cs,
  ) {
    final isRecording = state.isRecording;
    final isRequestingPermission = state is RequestingPermissionState;
    final isPermissionDenied = state is PermissionDeniedState;
    final hasRecording = state.hasRecording;
    // Only _isBusy disables buttons – RecordingState must NOT disable Stop.
    final isDisabled = _isBusy;

    if (isRequestingPermission) {
      return Column(
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: 24),
          Text(
            'Requesting microphone permission...',
            style: textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }

    if (isPermissionDenied) {
      return Column(
        children: [
          Icon(Icons.mic_off_rounded, size: 80, color: cs.error),
          const SizedBox(height: 24),
          Text(
            'Microphone Permission Required',
            style: textTheme.titleLarge?.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Please enable microphone access in settings to record your voice.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
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
        _buildMicrophoneButton(isRecording, controller, textTheme, cs),
        const SizedBox(height: 32),
        _buildTimerDisplay(state, textTheme, cs),
        const SizedBox(height: 32),
        _buildActionButtons(
          state,
          controller,
          textTheme,
          isRecording,
          hasRecording,
          isDisabled,
          cs,
        ),
      ],
    );
  }

  // Unified stop handler – called by both microphone tap and Stop button.
  Future<void> _handleStopRecording(VoiceRecordingController controller) async {
    if (!mounted || _isBusy) return;
    _isBusy = true;

    try {
      final path = await controller.stopRecording();
      if (!mounted) return;
      if (path != null && path.isNotEmpty) {
        context.go('/practice/review', extra: path);
      }
    } finally {
      if (mounted) _isBusy = false;
    }
  }

  Future<void> _handleMicrophoneTap(
    VoiceRecordingController controller,
    bool isRecording,
  ) async {
    if (!mounted || _isBusy) return;

    if (isRecording) {
      await _handleStopRecording(controller);
    } else {
      await _handleStartRecording(controller);
    }
  }

  Widget _buildMicrophoneButton(
    bool isRecording,
    VoiceRecordingController controller,
    TextTheme textTheme,
    ColorScheme cs,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse ring when recording
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
                      color: cs.error.withValues(alpha: 0.5),
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        // Microphone circle
        Semantics(
          button: true,
          label: isRecording ? 'Stop recording' : 'Start recording',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Material(
              color: cs.surfaceContainerHighest,
              shape: CircleBorder(
                side: BorderSide(color: cs.outlineVariant, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                mouseCursor: SystemMouseCursors.click,
                hoverColor: cs.onSurface.withValues(alpha: 0.08),
                highlightColor: cs.onSurface.withValues(alpha: 0.14),
                splashColor: cs.onSurface.withValues(alpha: 0.20),
                onTap: _isBusy
                    ? null
                    : () => _handleMicrophoneTap(controller, isRecording),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.outlineVariant, width: 1.5),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isRecording
                          ? Icon(
                              key: const ValueKey('recording'),
                              Icons.stop_rounded,
                              size: 56,
                              color: cs.error,
                            )
                          : Icon(
                              key: const ValueKey('idle'),
                              Icons.mic_rounded,
                              size: 56,
                              color: cs.primary,
                            ),
                    ),
                  ),
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
    if (!mounted || _isBusy) return;
    if (ref.read(voiceRecordingControllerProvider).isRecording) return;

    _isBusy = true;

    try {
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
    } finally {
      if (mounted) _isBusy = false;
    }
  }

  Widget _buildTimerDisplay(
    VoiceRecordingState state,
    TextTheme textTheme,
    ColorScheme cs,
  ) {
    final duration = state.duration ?? Duration.zero;

    return Column(
      children: [
        Text(
          _formatDuration(duration),
          style: textTheme.displayMedium?.copyWith(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
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
                ? cs.secondary
                : (state.hasRecording ? cs.tertiary : cs.onSurfaceVariant),
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
    ColorScheme cs,
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
                    if (_isBusy) return;
                    _isBusy = true;
                    try {
                      await controller.cancelRecording();
                    } finally {
                      if (mounted) _isBusy = false;
                    }
                  },
            icon: Icons.close_rounded,
            iconPosition: IconPosition.start,
          );

          final stopButton = AuthElevatedButton(
            label: 'Stop Recording',
            onPressed: isDisabled
                ? null
                : () => _handleStopRecording(controller),
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
          Card(
            color: cs.surfaceContainerHighest,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: cs.outlineVariant, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: cs.tertiary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Recording saved — ${_formatDuration(state.duration ?? Duration.zero)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
