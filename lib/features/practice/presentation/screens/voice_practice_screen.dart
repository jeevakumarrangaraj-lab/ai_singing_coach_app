import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';

import '../../../../core/widgets/tuno_dashboard_background.dart';
import '../../../../core/enums/icon_position.dart';
import '../../presentation/voice_recording_controller.dart';
import '../../domain/voice_recording_state.dart';
import '../../presentation/reference_track_controller.dart';
import '../../domain/reference_track_state.dart';
import '../../../auth/presentation/widgets/auth_elevated_button.dart';
import '../../../auth/presentation/widgets/auth_secondary_button.dart';
import '../../../auth/presentation/widgets/auth_destructive_button.dart';
import '../../../../common/widgets/app_back_button.dart';
import '../../../../common/utils/navigation_helpers.dart';
import '../../../../core/theme/app_colors.dart';

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

      // Recording: confirm discard.
      if (currentState.isRecording) {
        if (!mounted) return;
        final cs = Theme.of(context).colorScheme;
        final l10n = AppLocalizations.of(context)!;
        final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: cs.surfaceContainerHighest,
            title: Text(l10n.discardRecordingTitle),
            content: Text(l10n.discardRecordingContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.keepRecording),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: cs.error),
                child: Text(l10n.discardAndGoBack),
              ),
            ],
          ),
        );

        if (!mounted) return;
        if (shouldDiscard == true) {
          await controller.cancelRecording();
          if (!mounted) return;
          await navigateBackSafely(context, fallbackRoute: '/home');
        }
        return;
      }

      // If a saved recording exists: reset its state and go back to dashboard.
      // (No file deletion attempts here.)
      if (currentState.hasRecording) {
        // Saved recording: reset recording state and go back.
        controller.reset();
        if (!mounted) return;
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

  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
    final refTrackState = ref.watch(referenceTrackProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: TunoDashboardBackground(
        animate: true,
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 120,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 44),
                        // ── Title — centered, below back button ──
                        Text(
                          l10n.voicePractice,
                          style: textTheme.headlineLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.voicePracticeSubtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // ── Reference Track Display ──
                        _buildReferenceTrackDisplay(
                          refTrackState,
                          textTheme,
                          cs,
                          l10n,
                        ),
                        const SizedBox(height: 24),
                        _buildRecordingUI(state, controller, textTheme, cs),
                        const SizedBox(height: 48),
                        if (state.isError)
                          _buildErrorCard(state, textTheme, cs, controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Back button — positioned at SafeArea top-left
            Positioned(
              top: 8,
              left: 8,
              child: Tooltip(
                message: l10n.back,
                child: AppBackButton(
                  onPressed: _handleBackPressed,
                  showOnlyIfCanPop: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceTrackDisplay(
    ReferenceTrackState refTrackState,
    TextTheme textTheme,
    ColorScheme cs,
    AppLocalizations l10n,
  ) {
    final track = refTrackState.track;
    if (track == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.3),
            cs.tertiaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.audiotrack_rounded,
              size: 24,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.referenceTrackLabel,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  track.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _RefTrackInfoChip(
                      text: track.extension.toUpperCase(),
                      icon: Icons.description_rounded,
                      cs: cs,
                      textTheme: textTheme,
                    ),
                    const SizedBox(width: 8),
                    _RefTrackInfoChip(
                      text: _formatFileSize(track.sizeBytes),
                      icon: Icons.data_usage_rounded,
                      cs: cs,
                      textTheme: textTheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Actions
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Change Track button
              OutlinedButton.icon(
                onPressed: () => context.push('/practice/library'),
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: Text(l10n.referenceTrackChange),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  side: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  foregroundColor: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              // Clear selection button
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(referenceTrackProvider.notifier).clearSelection(),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(l10n.referenceTrackClear),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  side: BorderSide(color: cs.error, width: 1.5),
                  foregroundColor: cs.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildErrorCard(
    VoiceRecordingState state,
    TextTheme textTheme,
    ColorScheme cs,
    VoiceRecordingController controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final code = state.errorCode;
    return Card(
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
            Icon(Icons.error_outline, color: cs.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                code == null
                    ? l10n.anErrorOccurred
                    : _errorMessage(context, code),
                style: textTheme.bodyMedium?.copyWith(color: cs.error),
              ),
            ),
            TextButton(
              onPressed: () => controller.reset(),
              child: Text(l10n.dismiss),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps [VoiceRecordingErrorCode] to the correct l10n error string.
  String _errorMessage(BuildContext context, VoiceRecordingErrorCode code) {
    final l10n = AppLocalizations.of(context)!;
    return switch (code) {
      VoiceRecordingErrorCode.permissionDenied => l10n.micPermissionRequired,
      VoiceRecordingErrorCode.startFailed => l10n.voiceRecordingStartFailed,
      VoiceRecordingErrorCode.stopFailed => l10n.voiceRecordingStopFailed,
      VoiceRecordingErrorCode.playbackFailed =>
        l10n.voiceRecordingPlaybackFailed,
      VoiceRecordingErrorCode.pauseFailed => l10n.voiceRecordingPauseFailed,
      VoiceRecordingErrorCode.resumeFailed => l10n.voiceRecordingResumeFailed,
      VoiceRecordingErrorCode.seekFailed => l10n.voiceRecordingSeekFailed,
      VoiceRecordingErrorCode.deleteFailed => l10n.failedToDeleteRecording,
      VoiceRecordingErrorCode.audioPathMissing => l10n.unableToLoadAudio,
    };
  }

  Widget _buildRecordingUI(
    VoiceRecordingState state,
    VoiceRecordingController controller,
    TextTheme textTheme,
    ColorScheme cs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isRecording = state.isRecording;
    final isRequestingPermission = state is RequestingPermissionState;
    final isPermissionDenied = state is PermissionDeniedState;
    final hasRecording = state.hasRecording;
    final isDisabled = _isBusy;

    if (isRequestingPermission) {
      return Column(
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: 24),
          Text(
            l10n.requestingMicPermission,
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
            l10n.micPermissionRequired,
            style: textTheme.titleLarge?.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.enableMicInSettings,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          AuthElevatedButton(
            label: l10n.openSettings,
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

    // ── Premium Recording Panel ──
    return Column(
      children: [
        // Recording panel card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppColors.recordingPanelGradient,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.borderBlue.withValues(alpha: 0.85),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.baseNavy.withValues(alpha: 0.50),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Soft cyan inner glow along top edge
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.cyanAccent.withValues(alpha: 0.0),
                        AppColors.cyanAccent.withValues(alpha: 0.25),
                        AppColors.cyanAccent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Microphone emblem with concentric pulse rings ──
                  _buildMicrophoneSection(isRecording, controller, cs),
                  const SizedBox(height: 28),
                  // ── Timer display ──
                  _buildTimerDisplay(state, textTheme, cs),
                  const SizedBox(height: 28),
                  // ── Action buttons ──
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
              ),
            ],
          ),
        ),
        // ── Instruction text below panel ──
        const SizedBox(height: 20),
        Text(
          l10n.orTapMicAbove,
          style: textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MICROPHONE SECTION — Premium gradient circle with gold ring
  // ─────────────────────────────────────────────────────────────

  Widget _buildMicrophoneSection(
    bool isRecording,
    VoiceRecordingController controller,
    ColorScheme cs,
  ) {
    const micDiameter = 180.0;
    const goldRingWidth = 2.5;
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: isRecording
          ? l10n.stopRecordingSemantic
          : l10n.startRecordingSemantic,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _isBusy
              ? null
              : () => _handleMicrophoneTap(controller, isRecording),
          child: SizedBox(
            width: micDiameter,
            height: micDiameter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric cyan pulse rings
                ..._buildConcentricRings(isRecording),

                // Microphone circle with gradient + gold ring
                Container(
                  width: micDiameter,
                  height: micDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF00A6BA),
                        Color(0xFF007F9C),
                        Color(0xFF014065),
                      ],
                      stops: [0.0, 0.55, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyanAccent.withValues(alpha: 0.15),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Metallic-gold outer ring
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GoldRingPainter(
                            strokeWidth: goldRingWidth,
                            radius: micDiameter / 2 - goldRingWidth / 2,
                            center: Offset(micDiameter / 2, micDiameter / 2),
                          ),
                        ),
                      ),
                      // White microphone or stop icon
                      Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isRecording
                              ? Icon(
                                  key: const ValueKey('recording'),
                                  Icons.stop_rounded,
                                  size: 56,
                                  color: Colors.white,
                                )
                              : Icon(
                                  key: const ValueKey('idle'),
                                  Icons.mic_rounded,
                                  size: 56,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build 3 concentric cyan pulse rings around the microphone.
  List<Widget> _buildConcentricRings(bool isRecording) {
    return List.generate(3, (i) {
      final baseRadius = 96.0 + i * 24.0;
      final alpha = isRecording
          ? (0.25 - i * 0.07).clamp(0.06, 0.25)
          : (0.10 - i * 0.025).clamp(0.03, 0.10);

      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseOffset = isRecording
              ? (math.sin(_pulseController.value * math.pi * 2 + i * 2.0) *
                        0.03 *
                        baseRadius)
                    .clamp(0.0, 6.0)
              : 0.0;

          return Container(
            width: (baseRadius + pulseOffset) * 2,
            height: (baseRadius + pulseOffset) * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.cyanAccent.withValues(alpha: alpha),
                width: 1.2,
              ),
            ),
          );
        },
      );
    });
  }

  // ─────────────────────────────────────────────────────────────
  // TIMER DISPLAY
  // ─────────────────────────────────────────────────────────────

  Widget _buildTimerDisplay(
    VoiceRecordingState state,
    TextTheme textTheme,
    ColorScheme cs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final duration = state.duration ?? Duration.zero;
    final statusColor = state.isRecording
        ? AppColors.cyanAccent
        : (state.hasRecording ? cs.onSurface : cs.onSurfaceVariant);

    return Column(
      children: [
        Text(
          _formatDuration(duration),
          style: textTheme.displayMedium?.copyWith(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          state.isRecording
              ? l10n.recording
              : (state.hasRecording ? l10n.recordingSaved : l10n.readyToRecord),
          style: textTheme.bodyLarge?.copyWith(
            color: statusColor,
            fontWeight: state.isRecording || state.hasRecording
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ACTION BUTTONS
  // ─────────────────────────────────────────────────────────────

  Widget _buildActionButtons(
    VoiceRecordingState state,
    VoiceRecordingController controller,
    TextTheme textTheme,
    bool isRecording,
    bool hasRecording,
    bool isDisabled,
    ColorScheme cs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (isRecording) {
      return LayoutBuilder(
        builder: (context, constraints) {
          const minWidthForRow = 600.0;
          final useRowLayout = constraints.maxWidth >= minWidthForRow;

          final cancelButton = AuthSecondaryButton(
            label: l10n.cancel,
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

          final stopButton = _buildPremiumStopButton(isDisabled, controller);

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
                      l10n.recordingSavedDuration(
                        _formatDuration(state.duration ?? Duration.zero),
                      ),
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
                  label: l10n.deleteAndRecordAgain,
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
                  label: l10n.reviewRecording,
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

    // ── Premium Start Recording button ──
    return _buildPremiumStartButton(isDisabled, controller);
  }

  /// Premium Start Recording button with cyan-to-deep-blue gradient
  /// and metallic-gold border.
  Widget _buildPremiumStartButton(
    bool isDisabled,
    VoiceRecordingController controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: isDisabled ? null : () => _handleStartRecording(controller),
          borderRadius: BorderRadius.circular(26),
          splashFactory: InkRipple.splashFactory,
          hoverColor: Colors.white.withValues(alpha: 0.08),
          focusColor: Colors.white.withValues(alpha: 0.12),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? LinearGradient(
                      colors: [
                        AppColors.recBtnStart.withValues(alpha: 0.4),
                        AppColors.recBtnEnd.withValues(alpha: 0.4),
                      ],
                    )
                  : AppColors.recordingButtonGradient,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(
                  alpha: isDisabled ? 0.3 : 0.85,
                ),
                width: 1.5,
              ),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.deepBlueAccent.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fiber_manual_record_rounded,
                  size: 20,
                  color: Colors.white.withValues(alpha: isDisabled ? 0.4 : 1.0),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.startRecording,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(
                      alpha: isDisabled ? 0.4 : 1.0,
                    ),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Premium Stop button with the same styling.
  Widget _buildPremiumStopButton(
    bool isDisabled,
    VoiceRecordingController controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: isDisabled ? null : () => _handleStopRecording(controller),
          borderRadius: BorderRadius.circular(26),
          splashFactory: InkRipple.splashFactory,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.recordingButtonGradient,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.85),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepBlueAccent.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stop_rounded, size: 20, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  l10n.stopRecording,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HANDLERS (preserving all original logic)
  // ─────────────────────────────────────────────────────────────

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
}

// ─────────────────────────────────────────────────────────────
// GOLD RING PAINTER — Metallic-gold sweep gradient ring
// ─────────────────────────────────────────────────────────────

class _GoldRingPainter extends CustomPainter {
  const _GoldRingPainter({
    required this.strokeWidth,
    required this.radius,
    required this.center,
  });

  final double strokeWidth;
  final double radius;
  final Offset center;

  static const SweepGradient _goldSweepGradient = SweepGradient(
    colors: [
      Color(0xFFFFF2A6),
      Color(0xFFE3B94F),
      Color(0xFFA86D16),
      Color(0xFFF4D675),
      Color(0xFFFFF2A6),
    ],
    stops: [0.0, 0.25, 0.50, 0.75, 1.0],
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = _goldSweepGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldRingPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.center != center;
  }
}

/// Info chip for reference track display (extension, file size, etc.)
class _RefTrackInfoChip extends StatelessWidget {
  const _RefTrackInfoChip({
    required this.text,
    required this.icon,
    required this.cs,
    required this.textTheme,
  });

  final String text;
  final IconData icon;
  final ColorScheme cs;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
