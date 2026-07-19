import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/voice_recording_state.dart';
import '../data/voice_recording_repository.dart';

final voiceRecordingRepositoryProvider = Provider<VoiceRecordingRepository>((ref) {
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
  int _recordedSeconds = 0;
  String? _currentRecordingPath;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;

  VoiceRecordingController(this._repository) : super(const IdleState()) {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed && _currentRecordingPath != null) {
        _positionTimer?.cancel();
        state = PausedState(
          audioPath: _currentRecordingPath!,
          position: _audioPlayer.position,
          duration: _audioPlayer.duration,
        );
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (_currentRecordingPath != null) {
        state = PlayingState(
          audioPath: _currentRecordingPath!,
          position: position,
          duration: _audioPlayer.duration,
        );
      }
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

  Future<void> startRecording() async {
    state = const RecordingState(duration: Duration.zero, audioPath: '');

    _recordedSeconds = 0;
    _currentRecordingPath = await _repository.startRecording(
      encoder: AudioEncoder.wav,
      sampleRate: 44100,
    );

    if (_currentRecordingPath == null) {
      state = const ErrorState('Failed to start recording');
      return;
    }

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordedSeconds++;
      state = RecordingState(
        duration: Duration(seconds: _recordedSeconds),
        audioPath: _currentRecordingPath ?? '',
      );
    });
  }

  Future<String?> stopRecording() async {
    _timer?.cancel();

    final path = await _repository.stopRecording();

    if (path != null && path.isNotEmpty) {
      _currentRecordingPath = path;
      state = StoppedState(
        audioPath: path,
        duration: Duration(seconds: _recordedSeconds),
      );
      return path;
    } else if (_currentRecordingPath != null && _currentRecordingPath!.isNotEmpty) {
      state = StoppedState(
        audioPath: _currentRecordingPath!,
        duration: Duration(seconds: _recordedSeconds),
      );
      return _currentRecordingPath;
    }

    state = const ErrorState('Failed to stop recording');
    return null;
  }

  void cancelRecording() {
    _timer?.cancel();
    _repository.stopRecording();
    _currentRecordingPath = null;
    _recordedSeconds = 0;
    state = const IdleState();
  }

  void reset() {
    _timer?.cancel();
    _currentRecordingPath = null;
    _recordedSeconds = 0;
    state = const IdleState();
  }

  Future<void> playAudio(String path) async {
    try {
      _currentRecordingPath = path;
      await _audioPlayer.setSource(DeviceFileSource(path));
      await _audioPlayer.resume();
      state = PlayingState(
        audioPath: path,
        position: Duration.zero,
        duration: _audioPlayer.duration,
      );
    } catch (e) {
      state = ErrorState('Failed to play audio: $e');
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    if (_currentRecordingPath != null) {
      state = PausedState(
        audioPath: _currentRecordingPath!,
        position: _audioPlayer.position,
        duration: _audioPlayer.duration,
      );
    }
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
  }

  Future<void> seekAudio(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _positionTimer?.cancel();
    if (_currentRecordingPath != null) {
      state = StoppedState(
        audioPath: _currentRecordingPath!,
        duration: _audioPlayer.duration,
      );
    }
  }

  Future<void> deleteRecording(String path) async {
    try {
      await stopAudio();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      reset();
    } catch (e) {
      state = ErrorState('Failed to delete recording: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionTimer?.cancel();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    _repository.dispose();
    super.dispose();
  }

  // Public getters for external access
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;
  Duration get duration => _audioPlayer.duration;
  Duration get position => _audioPlayer.position;
  PlayerState get playerState => _audioPlayer.state;
}