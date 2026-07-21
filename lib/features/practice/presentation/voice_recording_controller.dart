import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/voice_recording_state.dart';
import '../data/voice_recording_repository.dart';
import 'voice_recording_delete.dart';

final voiceRecordingRepositoryProvider = Provider<VoiceRecordingRepository>((
  ref,
) {
  return VoiceRecordingRepositoryImpl();
});

final voiceRecordingControllerProvider =
    StateNotifierProvider<VoiceRecordingController, VoiceRecordingState>((ref) {
      final repository = ref.watch(voiceRecordingRepositoryProvider);
      return VoiceRecordingController(repository);
    });

class VoiceRecordingController extends StateNotifier<VoiceRecordingState> {
  final VoiceRecordingRepository _repository;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  Timer? _positionTimer;
  final Stopwatch _recordingStopwatch = Stopwatch();
  String? _currentRecordingPath;

  bool _isStartingRecording = false;
  bool _isStoppingRecording = false;
  bool _isCancelingRecording = false;

  bool _isDisposed = false;

  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;

  VoiceRecordingController(this._repository) : super(const IdleState()) {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Subscribe once and keep latest values for UI.
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      if (_currentRecordingPath != null) {
        final audioPath = _currentRecordingPath!;
        if (_playerState == PlayerState.playing) {
          state = PlayingState(
            audioPath: audioPath,
            position: _currentPosition,
            duration: _totalDuration,
          );
        } else if (_playerState == PlayerState.paused) {
          state = PausedState(
            audioPath: audioPath,
            position: _currentPosition,
            duration: _totalDuration,
          );
        }
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      if (_currentRecordingPath != null) {
        if (_playerState == PlayerState.playing) {
          state = PlayingState(
            audioPath: _currentRecordingPath!,
            position: _currentPosition,
            duration: _totalDuration,
          );
        } else if (_playerState == PlayerState.paused) {
          state = PausedState(
            audioPath: _currentRecordingPath!,
            position: _currentPosition,
            duration: _totalDuration,
          );
        }
      }
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      playerState,
    ) {
      _playerState = playerState;
      if (_currentRecordingPath == null) return;

      if (playerState == PlayerState.playing) {
        state = PlayingState(
          audioPath: _currentRecordingPath!,
          position: _currentPosition,
          duration: _totalDuration,
        );
      } else if (playerState == PlayerState.paused) {
        state = PausedState(
          audioPath: _currentRecordingPath!,
          position: _currentPosition,
          duration: _totalDuration,
        );
      }
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (_currentRecordingPath == null) return;
      _playerState = PlayerState.completed;
      _currentPosition = _totalDuration;
      state = PausedState(
        audioPath: _currentRecordingPath!,
        position: _totalDuration,
        duration: _totalDuration,
      );
    });
  }

  Future<void> requestPermission() async {
    state = const RequestingPermissionState();

    final hasPermission = await _repository.hasPermission();
    if (hasPermission) {
      state = const PermissionGrantedState();
      return;
    }

    final granted = await _repository.requestPermission();
    if (granted) {
      state = const PermissionGrantedState();
    } else {
      state = const PermissionDeniedState();
    }
  }

  Future<bool> hasPermission() async {
    return await _repository.hasPermission();
  }

  Future<void> startRecording() async {
    if (_isStartingRecording) return;
    _isStartingRecording = true;

    try {
      final hasPermission = await _repository.hasPermission();
      if (!hasPermission) {
        state = const ErrorState('Microphone permission not granted');
        return;
      }

      _currentRecordingPath = await _repository.startRecording(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
      );

      if (_currentRecordingPath == null) {
        state = const ErrorState('Failed to start recording');
        return;
      }

      _recordingStopwatch
        ..reset()
        ..start();

      state = RecordingState(
        duration: Duration.zero,
        audioPath: _currentRecordingPath ?? '',
      );

      _startTimer();
    } finally {
      _isStartingRecording = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      if (!state.isRecording && _recordingStopwatch.isRunning == false) {
        // Safety: avoid updating state if recording is not running.
        timer.cancel();
        return;
      }

      final elapsed = _recordingStopwatch.elapsed;
      state = RecordingState(
        duration: elapsed,
        audioPath: _currentRecordingPath ?? '',
      );
    });
  }

  Future<String?> stopRecording() async {
    if (_isStoppingRecording) return null;
    _isStoppingRecording = true;

    _timer?.cancel();
    _recordingStopwatch.stop();
    final elapsed = _recordingStopwatch.elapsed;

    try {
      final path = await _repository.stopRecording();

      if (path != null && path.isNotEmpty) {
        _currentRecordingPath = path;
        state = StoppedState(audioPath: path, duration: elapsed);
        return path;
      } else if (_currentRecordingPath != null &&
          _currentRecordingPath!.isNotEmpty) {
        state = StoppedState(
          audioPath: _currentRecordingPath!,
          duration: elapsed,
        );
        return _currentRecordingPath;
      }

      state = const ErrorState('Failed to stop recording');
      return null;
    } catch (_) {
      state = const ErrorState('Failed to stop recording');
      return null;
    } finally {
      _isStoppingRecording = false;
    }
  }

  Future<void> cancelRecording() async {
    if (_isCancelingRecording) return;
    _isCancelingRecording = true;

    _timer?.cancel();
    _recordingStopwatch
      ..stop()
      ..reset();

    try {
      // Best-effort stop; even if stop fails, we discard.
      await _repository.stopRecording();
    } catch (_) {
      // Ignore cancellation errors; we only discard locally.
    }

    _currentRecordingPath = null;
    state = const IdleState();

    _isCancelingRecording = false;
  }

  void reset() {
    _timer?.cancel();
    _recordingStopwatch
      ..stop()
      ..reset();
    _currentRecordingPath = null;
    state = const IdleState();
  }

  Future<void> playAudio(String path) async {
    if (path.trim().isEmpty) {
      state = const ErrorState('Audio path is missing');
      return;
    }

    try {
      _currentRecordingPath = path;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      _playerState = PlayerState.playing;

      final source = kIsWeb ? UrlSource(path) : DeviceFileSource(path);

      await _audioPlayer.stop();
      await _audioPlayer.setSource(source);
      await _audioPlayer.resume();

      final duration = await _audioPlayer.getDuration();
      if (duration != null) {
        _totalDuration = duration;
      }

      state = PlayingState(
        audioPath: path,
        position: Duration.zero,
        duration: _totalDuration,
      );
    } catch (e) {
      debugPrint('playAudio error: $e');
      state = ErrorState('Failed to start playback');
      rethrow;
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();

      if (_currentRecordingPath != null) {
        _currentPosition =
            await _audioPlayer.getCurrentPosition() ?? Duration.zero;
        _totalDuration = await _audioPlayer.getDuration() ?? Duration.zero;
        state = PausedState(
          audioPath: _currentRecordingPath!,
          position: _currentPosition,
          duration: _totalDuration,
        );
      }
    } catch (e) {
      debugPrint('pauseAudio error: $e');
      state = const ErrorState('Failed to pause playback');
      rethrow;
    }
  }

  Future<void> resumeAudio() async {
    if (_currentRecordingPath == null) return;

    try {
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('resumeAudio error: $e');
      state = const ErrorState('Failed to resume playback');
      rethrow;
    }
  }

  Future<void> seekAudio(Duration position) async {
    if (_currentRecordingPath == null) return;
    try {
      final totalMs = _totalDuration.inMilliseconds;
      final clamped = Duration(
        milliseconds: position.inMilliseconds.clamp(
          0,
          totalMs > 0 ? totalMs : position.inMilliseconds,
        ),
      );
      await _audioPlayer.seek(clamped);
    } catch (e) {
      debugPrint('seekAudio error: $e');
      state = const ErrorState('Failed to seek');
      rethrow;
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
    } finally {
      _positionTimer?.cancel();
      if (_currentRecordingPath != null) {
        final duration = await _audioPlayer.getDuration() ?? Duration.zero;
        _totalDuration = duration;
        _currentPosition = Duration.zero;
        state = StoppedState(
          audioPath: _currentRecordingPath!,
          duration: duration,
        );
      } else {
        state = const IdleState();
      }
    }
  }

  Future<void> deleteRecording(String path) async {
    try {
      await stopAudio();

      await deleteRecordingOnPlatformImpl(path);

      // Always reset state so UI goes back to idle / voice practice.
      reset();
    } catch (_) {
      state = const ErrorState('Failed to delete recording');
      reset();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    _timer?.cancel();
    _positionTimer?.cancel();
    _recordingStopwatch.stop();

    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();

    _audioPlayer.dispose();
    _repository.dispose();
    super.dispose();
  }

  // Public getters for external access
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<PlayerState> get onPlayerStateChanged =>
      _audioPlayer.onPlayerStateChanged;
  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;

  Future<Duration> get duration =>
      _audioPlayer.getDuration().then((d) => d ?? Duration.zero);
  Future<Duration> get position =>
      _audioPlayer.getCurrentPosition().then((p) => p ?? Duration.zero);
  PlayerState get playerState => _audioPlayer.state;

  Duration get currentDuration => _totalDuration;
  Duration get currentPosition => _currentPosition;
  bool get isPlaying => _playerState == PlayerState.playing;
}
