import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../presentation/voice_recording_controller.dart';
import '../../domain/voice_recording_state.dart';
import 'recording_review_screen.dart';

class VoicePracticeScreen extends ConsumerStatefulWidget {
  const VoicePracticeScreen({super.key});

  @override
  ConsumerState<VoicePracticeScreen> createState() => _VoicePracticeScreenState();
}

class _VoicePracticeScreenState extends ConsumerState<VoicePracticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceRecordingControllerProvider.notifier).requestPermission();
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showSnackBar(String message, {bool isError = false, VoidCallback? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primaryDark,
        action: action != null
            ? SnackBarAction(
                label: 'Open Settings',
                textColor: Colors.white,
                onPressed: action,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
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
          Positioned.fill(
            child: Image.asset(
              'assets/images/practice_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.30),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
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
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.whenOrNull(error: (msg) => msg) ?? 'An error occurred',
                                style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
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
    final isPermissionState = state is RequestingPermissionState ||
        state is PermissionGrantedState ||
        state is PermissionDeniedState;
    final hasRecording = state.hasRecording;

    if (isPermissionState) {
      return _buildPermissionUI(state, controller, textTheme);
    }

    return Column(
      children: [
        _buildMicrophoneButton(isRecording, textTheme),
        const SizedBox(height: 32),
        _buildTimerDisplay(state, textTheme),
        const SizedBox(height: 32),
        _buildActionButtons(state, controller, textTheme, isRecording, hasRecording),
      ],
    );
  }

  Widget _buildPermissionUI(
    VoiceRecordingState state,
    VoiceRecordingController controller,
    TextTheme textTheme,
  ) {
    if (state is RequestingPermissionState) {
      return Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Requesting microphone permission...',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    }

    if (state is PermissionGrantedState) {
      return Column(
        children: [
          const Icon(Icons.mic_none_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Microphone permission granted',
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the microphone button to start recording',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    }

    if (state is PermissionDeniedState) {
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
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await controller.requestPermission();
            },
            icon: const Icon(Icons.settings_rounded),
            label: const Text('Open Settings'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMicrophoneButton(bool isRecording, TextTheme textTheme) {
    return GestureDetector(
      onTap: isRecording ? null : () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isRecording
              ? const LinearGradient(
                  colors: [AppColors.error, Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: (isRecording ? AppColors.error : AppColors.primary).withValues(alpha: 0.5),
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
                      color: AppColors.error,
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
                      color: AppColors.primaryDark,
                    ),
                  ),
          ),
        ),
      ),
    );
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
          state.isRecording ? 'Recording...' : 'Ready to Record',
          style: textTheme.bodyLarge?.copyWith(
            color: state.isRecording ? AppColors.warning : AppColors.textSecondary,
            fontWeight: state.isRecording ? FontWeight.w600 : FontWeight.normal,
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
  ) {
    if (isRecording) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.cancelRecording(),
              icon: const Icon(Icons.close_rounded, size: 24),
              label: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                final path = await controller.stopRecording();
                if (path != null && context.mounted) {
                  context.go('/practice/review', extra: path);
                }
              },
              icon: const Icon(Icons.stop_rounded, size: 24),
              label: const Text(
                'Stop Recording',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      );
    }

    if (hasRecording) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                final path = state.audioPath;
                if (path != null) {
                  controller.deleteRecording(path);
                }
              },
              icon: const Icon(Icons.delete_rounded, size: 24),
              label: const Text(
                'Delete & Record Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.7)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                final path = state.audioPath;
                if (path != null) {
                  context.go('/practice/review', extra: path);
                }
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: const Text(
                'Review Recording',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      );
    }

    return FilledButton.icon(
      onPressed: () async {
        await controller.startRecording();
      },
      icon: const Icon(Icons.fiber_manual_record_rounded, size: 24),
      label: const Text(
        'Start Recording',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}