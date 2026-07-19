import 'package:flutter/foundation.dart';

@immutable
abstract class VoiceRecordingState {
  const VoiceRecordingState();
}

class IdleState extends VoiceRecordingState {
  const IdleState();
}

class RequestingPermissionState extends VoiceRecordingState {
  const RequestingPermissionState();
}

class RecordingState extends VoiceRecordingState {
  final Duration duration;
  final String audioPath;

  const RecordingState({
    required this.duration,
    required this.audioPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingState &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          audioPath == other.audioPath;

  @override
  int get hashCode => duration.hashCode ^ audioPath.hashCode;
}

class StoppedState extends VoiceRecordingState {
  final String audioPath;
  final Duration duration;

  const StoppedState({
    required this.audioPath,
    required this.duration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoppedState &&
          runtimeType == other.runtimeType &&
          audioPath == other.audioPath &&
          duration == other.duration;

  @override
  int get hashCode => audioPath.hashCode ^ duration.hashCode;
}

class PlayingState extends VoiceRecordingState {
  final String audioPath;
  final Duration position;
  final Duration duration;

  const PlayingState({
    required this.audioPath,
    required this.position,
    required this.duration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingState &&
          runtimeType == other.runtimeType &&
          audioPath == other.audioPath &&
          position == other.position &&
          duration == other.duration;

  @override
  int get hashCode => audioPath.hashCode ^ position.hashCode ^ duration.hashCode;
}

class PausedState extends VoiceRecordingState {
  final String audioPath;
  final Duration position;
  final Duration duration;

  const PausedState({
    required this.audioPath,
    required this.position,
    required this.duration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PausedState &&
          runtimeType == other.runtimeType &&
          audioPath == other.audioPath &&
          position == other.position &&
          duration == other.duration;

  @override
  int get hashCode => audioPath.hashCode ^ position.hashCode ^ duration.hashCode;
}

class ErrorState extends VoiceRecordingState {
  final String message;

  const ErrorState(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorState && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class PermissionGrantedState extends VoiceRecordingState {
  const PermissionGrantedState();
}

class PermissionDeniedState extends VoiceRecordingState {
  const PermissionDeniedState();
}

extension VoiceRecordingStateX on VoiceRecordingState {
  bool get isRecording => this is RecordingState;

  bool get isPlaying => this is PlayingState;

  bool get isPaused => this is PausedState;

  bool get isIdle => this is IdleState;

  bool get isError => this is ErrorState;

  bool get hasRecording => whenOrNull(
        stopped: (audioPath, _) => audioPath.isNotEmpty,
        playing: (audioPath, _, _) => audioPath.isNotEmpty,
        paused: (audioPath, _, _) => audioPath.isNotEmpty,
      ) ??
      false;

  String? get audioPath => whenOrNull(
        stopped: (audioPath, _) => audioPath,
        playing: (audioPath, _, _) => audioPath,
        paused: (audioPath, _, _) => audioPath,
      );

  Duration? get duration => whenOrNull(
        recording: (duration, _) => duration,
        stopped: (_, duration) => duration,
        playing: (_, __, duration) => duration,
        paused: (_, __, duration) => duration,
      );

  Duration? get position => whenOrNull(
        recording: (duration, _) => duration,
        playing: (_, position, _) => position,
        paused: (_, position, _) => position,
      );

  T? whenOrNull<T>({
    T Function()? idle,
    T Function()? requestingPermission,
    T Function()? permissionGranted,
    T Function()? permissionDenied,
    T Function(Duration duration, String audioPath)? recording,
    T Function(String audioPath, Duration duration)? stopped,
    T Function(String audioPath, Duration position, Duration duration)? playing,
    T Function(String audioPath, Duration position, Duration duration)? paused,
    T Function(String message)? error,
  }) {
    switch (this) {
      case IdleState():
        return idle?.call();
      case RequestingPermissionState():
        return requestingPermission?.call();
      case PermissionGrantedState():
        return permissionGranted?.call();
      case PermissionDeniedState():
        return permissionDenied?.call();
      case RecordingState(duration: final d, audioPath: final p):
        return recording?.call(d, p);
      case StoppedState(audioPath: final p, duration: final d):
        return stopped?.call(p, d);
      case PlayingState(audioPath: final p, position: final pos, duration: final d):
        return playing?.call(p, pos, d);
      case PausedState(audioPath: final p, position: final pos, duration: final d):
        return paused?.call(p, pos, d);
      case ErrorState(message: final m):
        return error?.call(m);
    }
  }
}