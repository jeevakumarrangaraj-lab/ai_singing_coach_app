import 'package:flutter/foundation.dart';

/// Typed error codes for voice-recording failures.
///
/// Controllers emit these typed codes instead of user-facing strings.
/// Consuming widgets map each code to an l10n getter via AppLocalizations.
enum VoiceRecordingErrorCode {
  /// Microphone permission was denied when starting a recording.
  permissionDenied,

  /// The recording could not be started.
  startFailed,

  /// The recording could not be stopped.
  stopFailed,

  /// Audio playback could not be started.
  playbackFailed,

  /// Audio playback could not be paused.
  pauseFailed,

  /// Audio playback could not be resumed.
  resumeFailed,

  /// The playback position could not be changed.
  seekFailed,

  /// The recording could not be deleted.
  deleteFailed,

  /// The recording audio path is missing or empty.
  audioPathMissing,
}

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

  const RecordingState({required this.duration, required this.audioPath});

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

  const StoppedState({required this.audioPath, required this.duration});

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
  int get hashCode =>
      audioPath.hashCode ^ position.hashCode ^ duration.hashCode;
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
  int get hashCode =>
      audioPath.hashCode ^ position.hashCode ^ duration.hashCode;
}

class ErrorState extends VoiceRecordingState {
  final VoiceRecordingErrorCode code;

  const ErrorState(this.code);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorState &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
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

  /// The typed error code, or `null` if not in an error state.
  VoiceRecordingErrorCode? get errorCode =>
      (this is ErrorState) ? (this as ErrorState).code : null;

  bool get hasRecording =>
      whenOrNull(
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
    playing: (_, _, duration) => duration,
    paused: (_, _, duration) => duration,
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
    T Function(VoiceRecordingErrorCode code)? error,
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
      case PlayingState(
        audioPath: final p,
        position: final pos,
        duration: final d,
      ):
        return playing?.call(p, pos, d);
      case PausedState(
        audioPath: final p,
        position: final pos,
        duration: final d,
      ):
        return paused?.call(p, pos, d);
      case ErrorState(code: final c):
        return error?.call(c);
    }
    return null;
  }
}
