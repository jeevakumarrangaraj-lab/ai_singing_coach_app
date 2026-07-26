import 'package:flutter/foundation.dart';

import 'reference_track.dart';

/// Union type for the reference‑track file‑picker lifecycle.
@immutable
sealed class ReferenceTrackState {
  const ReferenceTrackState();
}

/// No track has been selected and the picker is closed.
class ReferenceTrackIdle extends ReferenceTrackState {
  const ReferenceTrackIdle();
}

/// The file picker is currently open.
class ReferenceTrackPicking extends ReferenceTrackState {
  const ReferenceTrackPicking();
}

/// A track was successfully chosen.
class ReferenceTrackSelected extends ReferenceTrackState {
  final ReferenceTrack track;

  const ReferenceTrackSelected(this.track);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceTrackSelected &&
          runtimeType == other.runtimeType &&
          track == other.track;

  @override
  int get hashCode => track.hashCode;
}

/// An error occurred during picking / validation.
class ReferenceTrackError extends ReferenceTrackState {
  final String message;

  const ReferenceTrackError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceTrackError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

// ---------------------------------------------------------------------------
// Extension helpers
// ---------------------------------------------------------------------------

extension ReferenceTrackStateX on ReferenceTrackState {
  bool get isIdle => this is ReferenceTrackIdle;

  bool get isPicking => this is ReferenceTrackPicking;

  bool get isSelected => this is ReferenceTrackSelected;

  bool get isError => this is ReferenceTrackError;

  /// The selected track, or `null` if not selected.
  ReferenceTrack? get track => (this is ReferenceTrackSelected)
      ? (this as ReferenceTrackSelected).track
      : null;

  /// The error message, or `null` if not in error.
  String? get errorMessage => (this is ReferenceTrackError)
      ? (this as ReferenceTrackError).message
      : null;

  /// Pattern‑match over all variants.
  T when<T>({
    required T Function() idle,
    required T Function() picking,
    required T Function(ReferenceTrack track) selected,
    required T Function(String message) error,
  }) {
    switch (this) {
      case ReferenceTrackIdle():
        return idle();
      case ReferenceTrackPicking():
        return picking();
      case ReferenceTrackSelected(track: final t):
        return selected(t);
      case ReferenceTrackError(message: final m):
        return error(m);
    }
  }

  /// Pattern‑match that returns `null` for unhandled variants.
  T? whenOrNull<T>({
    T Function()? idle,
    T Function()? picking,
    T Function(ReferenceTrack track)? selected,
    T Function(String message)? error,
  }) {
    switch (this) {
      case ReferenceTrackIdle():
        return idle?.call();
      case ReferenceTrackPicking():
        return picking?.call();
      case ReferenceTrackSelected(track: final t):
        return selected?.call(t);
      case ReferenceTrackError(message: final m):
        return error?.call(m);
    }
  }
}
