import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/voice_recording_controller.dart';
import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/tuno_dashboard_background.dart';

class RecordingReviewScreen extends ConsumerStatefulWidget {
  final String audioPath;

  const RecordingReviewScreen({super.key, required this.audioPath});

  @override
  ConsumerState<RecordingReviewScreen> createState() =>
      _RecordingReviewScreenState();
}

class _RecordingReviewScreenState extends ConsumerState<RecordingReviewScreen> {
  bool _isBackInProgress = false;
  bool _isDeleting = false;

  late final VoiceRecordingController _controller;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;

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
      setState(() => _position = p);
    });

    _playerStateSubscription = _controller.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _isPlaying = s == PlayerState.playing);
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
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double _getSliderValue() {
    if (_duration.inMilliseconds <= 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }

  Future<void> _handlePlayPause() async {
    if (_isLoading) return;

    if (_isPlaying) {
      await _controller.pauseAudio();
    } else if (_position >= _duration && _duration.inMilliseconds > 0) {
      await _controller.seekAudio(Duration.zero);
      await _controller.resumeAudio();
    } else {
      await _controller.resumeAudio();
    }
  }

  Future<void> _handleReplay() async {
    if (_isLoading || _duration.inMilliseconds <= 0) return;
    await _controller.seekAudio(Duration.zero);
    if (!_isPlaying) await _controller.resumeAudio();
  }

  Future<void> _handleForward() async {
    if (_isLoading || _duration.inMilliseconds <= 0) return;
    const forwardAmount = Duration(seconds: 10);
    final newPosition = _position + forwardAmount;
    await _controller.seekAudio(
      newPosition > _duration ? _duration : newPosition,
    );
  }

  Future<void> _onSliderChanged(double value) async {
    if (_duration.inMilliseconds <= 0) return;
    final newPosition = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    await _controller.seekAudio(newPosition);
  }

  Future<void> _handleDeleteAndRecordAgain() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    try {
      await _controller.deleteRecording(widget.audioPath);
      if (mounted) context.go('/practice');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to delete recording. Please try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _handleContinueToAnalysis() async {
    if (_isDeleting) return;
    await _controller.stopAudio();
    if (mounted) {
      context.push(
        '/practice/analysis',
        extra: {
          'audioPath': widget.audioPath,
          'duration': _duration,
          'recordedAt': DateTime.now(),
        },
      );
    }
  }

  Future<void> _handleBack() async {
    if (_isBackInProgress) return;
    _isBackInProgress = true;

    await _controller.stopAudio();

    if (mounted) {
      final canPop = GoRouter.of(context).canPop();
      if (canPop) {
        context.pop();
      } else {
        context.go('/practice');
      }
    }
    _isBackInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isErrorState = _duration.inMilliseconds <= 0 && !_isLoading;

    return Scaffold(
      backgroundColor: cs.surface,
      body: TunoDashboardBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Tooltip(
                        message: 'Back',
                        child: Semantics(
                          button: true,
                          label: 'Back',
                          child: AppBackButton(
                            onPressed: _handleBack,
                            showOnlyIfCanPop: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Review Recording',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_duration),
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Player Card
                    Card(
                      color: cs.surfaceContainerHighest,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(color: cs.outlineVariant, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Main Play/Pause button
                            Tooltip(
                              message: _isPlaying ? 'Pause' : 'Play',
                              child: Semantics(
                                button: true,
                                label: _isPlaying ? 'Pause' : 'Play',
                                child: Material(
                                  color: cs.primary,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _isLoading ? null : _handlePlayPause,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        _isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        size: 40,
                                        color: cs.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Progress slider
                            Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: cs.primary,
                                    inactiveTrackColor: cs.outlineVariant
                                        .withValues(alpha: 0.4),
                                    thumbColor: cs.primary,
                                    overlayColor: cs.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    valueIndicatorColor: cs.primary,
                                    valueIndicatorTextStyle: textTheme.bodySmall
                                        ?.copyWith(color: cs.onPrimary),
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    value: _getSliderValue(),
                                    onChanged:
                                        (_duration.inMilliseconds > 0 &&
                                            !_isLoading)
                                        ? _onSliderChanged
                                        : null,
                                    min: 0.0,
                                    max: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_position),
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(_duration),
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Secondary controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Tooltip(
                                  message: 'Replay from beginning',
                                  child: Semantics(
                                    button: true,
                                    label: 'Replay from beginning',
                                    child: IconButton(
                                      onPressed:
                                          (_duration.inMilliseconds > 0 &&
                                              !_isLoading)
                                          ? _handleReplay
                                          : null,
                                      icon: Icon(
                                        Icons.replay_rounded,
                                        color: cs.primary,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Tooltip(
                                  message: 'Forward 10 seconds',
                                  child: Semantics(
                                    button: true,
                                    label: 'Forward 10 seconds',
                                    child: IconButton(
                                      onPressed:
                                          (_duration.inMilliseconds > 0 &&
                                              !_isLoading)
                                          ? _handleForward
                                          : null,
                                      icon: Icon(
                                        Icons.forward_10_rounded,
                                        color: cs.primary,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Error state
                            if (isErrorState) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Unable to load audio file. The recording may be missing or corrupted.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: cs.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: Tooltip(
                            message: 'Continue to Analysis',
                            child: Semantics(
                              button: true,
                              label: 'Continue to Analysis',
                              child: FilledButton(
                                onPressed: _isDeleting || _isLoading
                                    ? null
                                    : _handleContinueToAnalysis,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  'Continue to Analysis',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Tooltip(
                            message: 'Delete and Record Again',
                            child: Semantics(
                              button: true,
                              label: 'Delete and Record Again',
                              child: OutlinedButton(
                                onPressed: _isDeleting || _isLoading
                                    ? null
                                    : _handleDeleteAndRecordAgain,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: cs.error,
                                  side: BorderSide(color: cs.error, width: 1.5),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: _isDeleting
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: cs.error,
                                        ),
                                      )
                                    : Text(
                                        'Delete & Record Again',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
