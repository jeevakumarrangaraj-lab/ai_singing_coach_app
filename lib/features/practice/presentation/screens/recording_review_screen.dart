import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/icon_position.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_page_background.dart';
import '../../../../common/widgets/app_back_button.dart';
import '../../presentation/voice_recording_controller.dart';
import '../../../auth/presentation/widgets/auth_elevated_button.dart'
    show AuthElevatedButton;
import '../../../auth/presentation/widgets/auth_destructive_button.dart'
    show AuthDestructiveButton;

class RecordingReviewScreen extends ConsumerStatefulWidget {
  final String audioPath;

  const RecordingReviewScreen({super.key, required this.audioPath});

  @override
  ConsumerState<RecordingReviewScreen> createState() =>
      _RecordingReviewScreenState();
}

class _RecordingReviewScreenState extends ConsumerState<RecordingReviewScreen> {
  bool _isBackInProgress = false;

  late final VoiceRecordingController _controller;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;

  // Single subscriptions (cancel on dispose)
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(voiceRecordingControllerProvider.notifier);
    _initializePlayer();
    _setupPlayerListeners();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() => _isLoading = true);
      await _controller.playAudio(widget.audioPath);
    } catch (_) {
      // Controller handles user-friendly ErrorState.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setupPlayerListeners() {
    _durationSubscription = _controller.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() {
        _duration = d;
        _isLoading = false;
      });
    });

    _positionSubscription = _controller.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() {
        _position = p;
      });
    });

    _playerStateSubscription = _controller.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() {
        _isPlaying = s == PlayerState.playing;
      });
    });

    _playerCompleteSubscription = _controller.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _position = _duration;
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _controller.stopAudio();
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
          ResponsivePageBackground(
            imagePath: 'assets/images/practice_bg.png',
            mobileAlignment: Alignment.center,
            wideAlignment: Alignment.bottomCenter,
            mobileOverlayAlpha: 0.22,
            wideOverlayAlpha: 0.14,
            maxContentWidth: 900,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 80,
                      color: AppColors.success,
                    ),
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
                    GlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(24),
                      blurSigma: 14,
                      backgroundColor: AppColors.deepPlum.withValues(
                        alpha: 0.28,
                      ),
                      borderColor: Colors.white.withValues(alpha: 0.18),
                      shadowColor: AppColors.primaryMagenta.withValues(
                        alpha: 0.12,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: textTheme.displayMedium?.copyWith(
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
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
                              activeTrackColor: AppColors.accentGold,
                              inactiveTrackColor: Colors.white.withValues(
                                alpha: 0.20,
                              ),
                              thumbColor: AppColors.accentGold,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10,
                              ),
                              overlayColor: AppColors.accentGold.withValues(
                                alpha: 0.2,
                              ),
                              valueIndicatorColor: AppColors.accentGold,
                              valueIndicatorTextStyle: textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            child: Slider(
                              value: _position.inMilliseconds
                                  .toDouble()
                                  .clamp(0, _duration.inMilliseconds)
                                  .toDouble(),
                              max: _duration.inMilliseconds > 0
                                  ? _duration.inMilliseconds.toDouble()
                                  : 1.0,
                              onChanged: _isLoading
                                  ? null
                                  : (value) async {
                                      await _controller.seekAudio(
                                        Duration(milliseconds: value.round()),
                                      );
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
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  _formatDuration(_duration),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
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
                                        await _controller.seekAudio(
                                          Duration.zero,
                                        );
                                        setState(() {
                                          _position = Duration.zero;
                                        });
                                        // Start/resume immediately
                                        await _controller.playAudio(
                                          widget.audioPath,
                                        );
                                      },
                                icon: const Icon(
                                  Icons.replay_rounded,
                                  size: 32,
                                ),
                                color: Colors.white.withValues(alpha: 0.85),
                                tooltip: 'Replay',
                              ),

                              const SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryButtonGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryCoral.withValues(
                                        alpha: 0.5,
                                      ),
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
                                          final s = _controller.playerState;
                                          if (s == PlayerState.playing) {
                                            await _controller.pauseAudio();
                                            return;
                                          }
                                          // stopped/paused/completed -> play/resume
                                          if (s == PlayerState.completed ||
                                              s == PlayerState.stopped) {
                                            setState(() {
                                              _position = Duration.zero;
                                            });
                                            await _controller.playAudio(
                                              widget.audioPath,
                                            );
                                          } else {
                                            await _controller.resumeAudio();
                                          }
                                        },
                                  icon: Icon(
                                    _isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
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
                                        final current = _position;
                                        final next =
                                            current +
                                            const Duration(seconds: 10);
                                        final clamped = Duration(
                                          milliseconds: next.inMilliseconds
                                              .clamp(
                                                0,
                                                _duration.inMilliseconds,
                                              ),
                                        );
                                        await _controller.seekAudio(clamped);
                                      },
                                icon: const Icon(
                                  Icons.forward_10_rounded,
                                  size: 32,
                                ),
                                color: Colors.white.withValues(alpha: 0.85),
                                tooltip: 'Forward 10s',
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
                          child: AuthDestructiveButton(
                            label: 'Delete & Record Again',
                            onPressed: () async {
                              if (_isBackInProgress) return;
                              await ref
                                  .read(
                                    voiceRecordingControllerProvider.notifier,
                                  )
                                  .deleteRecording(widget.audioPath);
                              if (context.mounted) {
                                context.go('/practice');
                              }
                            },
                            icon: Icons.delete_rounded,
                            iconPosition: IconPosition.start,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AuthElevatedButton(
                            label: 'Continue to Analysis',
                            onPressed: () async {
                              final controller = ref.read(
                                voiceRecordingControllerProvider.notifier,
                              );
                              final duration = await controller.duration;
                              context.go(
                                '/practice/analysis',
                                extra: {
                                  'audioPath': widget.audioPath,
                                  'duration': duration,
                                  'recordedAt': DateTime.now(),
                                },
                              );
                            },
                            isLoading: false,
                            icon: Icons.analytics_rounded,
                            iconPosition: IconPosition.start,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Back button on top of everything
          Positioned(
            top: 8,
            left: 8,
            child: AppBackButton(
              onPressed: () async {
                if (_isBackInProgress) return;
                _isBackInProgress = true;

                try {
                  // Stop playback before leaving.
                  await _controller.stopAudio();
                  if (!context.mounted) return;

                  // Preserve saved recording and return to Voice Practice.
                  context.go('/practice');
                } finally {
                  _isBackInProgress = false;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
