import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../presentation/voice_recording_controller.dart';

class RecordingReviewScreen extends ConsumerStatefulWidget {
  final String audioPath;

  const RecordingReviewScreen({super.key, required this.audioPath});

  @override
  ConsumerState<RecordingReviewScreen> createState() => _RecordingReviewScreenState();
}

class _RecordingReviewScreenState extends ConsumerState<RecordingReviewScreen> {
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final controller = ref.read(voiceRecordingControllerProvider.notifier);
    await controller.playAudio(widget.audioPath);
    _listenToPlayer();
  }

  void _listenToPlayer() {
    final controller = ref.read(voiceRecordingControllerProvider.notifier);
    controller.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
          _isLoading = false;
        });
      }
    });
    controller.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
          _isPlaying = controller.playerState == PlayerState.playing;
        });
      }
    });
    controller.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    ref.read(voiceRecordingControllerProvider.notifier).stopAudio();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fileName = widget.audioPath.split('/').last;

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
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.30)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.check_circle_rounded, size: 80, color: AppColors.success),
                  const SizedBox(height: 24),
                  Text(
                    'Recording Complete',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fileName,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.65),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatDuration(_duration),
                          style: textTheme.displayMedium?.copyWith(
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Duration',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.border.withValues(alpha: 0.5),
                            thumbColor: AppColors.primary,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                            overlayColor: AppColors.primary.withValues(alpha: 0.2),
                            valueIndicatorColor: AppColors.primary,
                            valueIndicatorTextStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
                          ),
                          child: Slider(
                            value: _isLoading ? 0 : _position.inMilliseconds.toDouble(),
                            max: _isLoading ? 1 : _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                            onChanged: _isLoading
                                ? null
                                : (value) async {
                                    await ref
                                        .read(voiceRecordingControllerProvider.notifier)
                                        .seekAudio(Duration(milliseconds: value.round()));
                                  },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      await ref.read(voiceRecordingControllerProvider.notifier).seekAudio(
                                            Duration.zero,
                                          );
                                      await ref.read(voiceRecordingControllerProvider.notifier).playAudio(widget.audioPath);
                                    },
                              icon: const Icon(Icons.replay_rounded, size: 32),
                              color: AppColors.textSecondary,
                              tooltip: 'Replay',
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (_isPlaying) {
                                          await ref.read(voiceRecordingControllerProvider.notifier).pauseAudio();
                                        } else {
                                          await ref.read(voiceRecordingControllerProvider.notifier).resumeAudio();
                                        }
                                      },
                                icon: Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                tooltip: _isPlaying ? 'Pause' : 'Play',
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      await ref.read(voiceRecordingControllerProvider.notifier).seekAudio(
                                            _duration,
                                          );
                                    },
                              icon: const Icon(Icons.fast_forward_rounded, size: 32),
                              color: AppColors.textSecondary,
                              tooltip: 'Skip to end',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref
                                .read(voiceRecordingControllerProvider.notifier)
                                .deleteRecording(widget.audioPath);
                            if (context.mounted) {
                              context.go('/practice');
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
                            final duration = ref.read(voiceRecordingControllerProvider).duration ?? Duration.zero;
                            context.go(
                              '/practice/analysis',
                              extra: {'audioPath': widget.audioPath, 'duration': duration},
                            );
                          },
                          icon: const Icon(Icons.analytics_rounded, size: 24),
                          label: const Text(
                            'Continue to Analysis',
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}