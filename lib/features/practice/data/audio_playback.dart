import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

abstract class AudioPlayback {
  Stream<Duration> get onDurationChanged;
  Stream<Duration> get onPositionChanged;
  Stream<PlayerState> get onPlayerStateChanged;
  Stream<void> get onPlayerComplete;

  Future<void> setSource(Source source);
  Future<void> play();
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<Duration?> getDuration();
  Future<Duration?> getCurrentPosition();
  PlayerState get state;

  Future<void> dispose();
}

class AudioPlayerAdapter implements AudioPlayback {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;

  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<PlayerState> _playerStateController =
      StreamController<PlayerState>.broadcast();
  final StreamController<void> _playerCompleteController =
      StreamController<void>.broadcast();

  AudioPlayerAdapter() {
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      _durationController.add(duration);
    });

    _positionSubscription = _player.onPositionChanged.listen((position) {
      _positionController.add(position);
    });

    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      _playerStateController.add(state);
    });

    _playerCompleteSubscription = _player.onPlayerComplete.listen((_) {
      _playerCompleteController.add(null);
    });
  }

  @override
  Stream<Duration> get onDurationChanged => _durationController.stream;

  @override
  Stream<Duration> get onPositionChanged => _positionController.stream;

  @override
  Stream<PlayerState> get onPlayerStateChanged => _playerStateController.stream;

  @override
  Stream<void> get onPlayerComplete => _playerCompleteController.stream;

  @override
  Future<void> setSource(Source source) async {
    await _player.setSource(source);
  }

  @override
  Future<void> play() async {
    await _player.resume();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> resume() async {
    await _player.resume();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<Duration?> getDuration() async {
    return await _player.getDuration();
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    return await _player.getCurrentPosition();
  }

  @override
  PlayerState get state => _player.state;

  @override
  Future<void> dispose() async {
    await _durationSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _playerCompleteSubscription?.cancel();

    await _durationController.close();
    await _positionController.close();
    await _playerStateController.close();
    await _playerCompleteController.close();

    await _player.dispose();
  }
}

class FakeAudioPlayback implements AudioPlayback {
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<PlayerState> _playerStateController =
      StreamController<PlayerState>.broadcast();
  final StreamController<void> _playerCompleteController =
      StreamController<void>.broadcast();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _state = PlayerState.stopped;

  @override
  Stream<Duration> get onDurationChanged => _durationController.stream;

  @override
  Stream<Duration> get onPositionChanged => _positionController.stream;

  @override
  Stream<PlayerState> get onPlayerStateChanged => _playerStateController.stream;

  @override
  Stream<void> get onPlayerComplete => _playerCompleteController.stream;

  @override
  Future<void> setSource(Source source) async {}

  @override
  Future<void> play() async {
    _state = PlayerState.playing;
    _playerStateController.add(_state);
  }

  @override
  Future<void> pause() async {
    _state = PlayerState.paused;
    _playerStateController.add(_state);
  }

  @override
  Future<void> resume() async {
    _state = PlayerState.playing;
    _playerStateController.add(_state);
  }

  @override
  Future<void> stop() async {
    _state = PlayerState.stopped;
    _position = Duration.zero;
    _playerStateController.add(_state);
    _positionController.add(_position);
  }

  @override
  Future<void> seek(Duration position) async {
    _position = position;
    _positionController.add(_position);
  }

  @override
  Future<Duration?> getDuration() async {
    return _duration;
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    return _position;
  }

  @override
  PlayerState get state => _state;

  @override
  Future<void> dispose() async {
    await _durationController.close();
    await _positionController.close();
    await _playerStateController.close();
    await _playerCompleteController.close();
  }

  void setDuration(Duration duration) {
    _duration = duration;
    _durationController.add(duration);
  }

  void setPosition(Duration position) {
    _position = position;
    _positionController.add(position);
  }

  void setState(PlayerState state) {
    _state = state;
    _playerStateController.add(state);
  }

  void complete() {
    _playerCompleteController.add(null);
  }
}
