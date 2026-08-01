import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';

import '../../presentation/voice_recording_controller.dart';
import '../../../../common/widgets/app_back_button.dart';

import '../../../../core/widgets/metallic_gold_border.dart';
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToDeleteRecording),
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

  Widget _buildPlayPauseButton(ColorScheme cs) {
    final l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: _isPlaying ? l10n.pause : l10n.play,
      child: Semantics(
        button: true,
        label: _isPlaying ? l10n.pause : l10n.play,
        child: Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF2A6),
                Color(0xFFE3B94F),
                Color(0xFFA86D16),
                Color(0xFFF4D675),
              ],
              stops: [0.0, 0.35, 0.72, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1AD9A62E),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: Material(
              color: cs.primary,
              child: InkWell(
                onTap: _isLoading ? null : _handlePlayPause,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 40,
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSection(ColorScheme cs, TextTheme textTheme) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: cs.primary,
            inactiveTrackColor: cs.outlineVariant.withValues(alpha: 0.4),
            thumbColor: cs.primary,
            overlayColor: cs.primary.withValues(alpha: 0.2),
            valueIndicatorColor: cs.primary,
            valueIndicatorTextStyle: textTheme.bodySmall?.copyWith(
              color: cs.onPrimary,
            ),
            trackHeight: 4,
          ),
          child: Slider(
            value: _getSliderValue(),
            onChanged: (_duration.inMilliseconds > 0 && !_isLoading)
                ? _onSliderChanged
                : null,
            min: 0.0,
            max: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(ColorScheme cs) {
    final l10n = AppLocalizations.of(context)!;
    final bool controlsDisabled = _duration.inMilliseconds <= 0 || _isLoading;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: l10n.replayFromBeginning,
          child: Semantics(
            button: true,
            label: l10n.replayFromBeginning,
            child: IconButton(
              onPressed: controlsDisabled ? null : _handleReplay,
              icon: Icon(Icons.replay_rounded, color: cs.primary, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Tooltip(
          message: l10n.forwardTenSeconds,
          child: Semantics(
            button: true,
            label: l10n.forwardTenSeconds,
            child: IconButton(
              onPressed: controlsDisabled ? null : _handleForward,
              icon: Icon(Icons.forward_10_rounded, color: cs.primary, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme cs, TextTheme textTheme) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: l10n.continueToAnalysis,
            child: Semantics(
              button: true,
              label: l10n.continueToAnalysis,
              child: FilledButton(
                onPressed: _isDeleting || _isLoading
                    ? null
                    : _handleContinueToAnalysis,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  l10n.continueToAnalysis,
                  style: const TextStyle(
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
            message: l10n.deleteAndRecordAgain,
            child: Semantics(
              button: true,
              label: l10n.deleteAndRecordAgain,
              child: OutlinedButton(
                onPressed: _isDeleting || _isLoading
                    ? null
                    : _handleDeleteAndRecordAgain,
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        l10n.deleteAndRecordAgain,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final isErrorState = _duration.inMilliseconds <= 0 && !_isLoading;

    return Scaffold(
      backgroundColor: cs.surface,
      body: TunoDashboardBackground(
        animate: true,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button — top-left of SafeArea
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 20),
                child: Tooltip(
                  message: l10n.back,
                  child: Semantics(
                    button: true,
                    label: l10n.back,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: AppBackButton(
                          onPressed: _handleBack,
                          showOnlyIfCanPop: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Scrollable content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            l10n.reviewRecordingTitle,
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
                          // Player card with metallic-gold border
                          MetallicGoldBorder(
                            borderRadius: BorderRadius.circular(22),
                            padding: 1.5,
                            child: Card(
                              color: cs.surfaceContainerHighest,
                              surfaceTintColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    // Play/pause button
                                    _buildPlayPauseButton(cs),
                                    const SizedBox(height: 24),
                                    // Slider with timers
                                    _buildSliderSection(cs, textTheme),
                                    const SizedBox(height: 20),
                                    // Replay/Forward controls
                                    _buildControlButtons(cs),
                                    // Error state
                                    if (isErrorState)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Text(
                                          l10n.unableToLoadAudio,
                                          textAlign: TextAlign.center,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: cs.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Action buttons
                          _buildActionButtons(cs, textTheme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
