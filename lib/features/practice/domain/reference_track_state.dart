import 'package:flutter/foundation.dart';

import 'reference_track.dart';

/// Error codes for reference-track picker / validation failures.
///
/// Controllers emit these typed codes instead of user-facing strings.
/// Consuming widgets map each code to an l10n getter via AppLocalizations.
enum ReferenceTrackErrorCode {
  /// The chosen file has an extension that is not supported.
  unsupportedFormat,

  /// The chosen file exceeds the maximum allowed size.
  fileTooLarge,

  /// The file content could not be read on this platform.
  unreadableFile,

  /// The file location could not be determined on this platform.
  missingPath,

  /// The file picker or platform threw an unexpected error.
  selectionFailed,
}

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
  final ReferenceTrackErrorCode code;

  const ReferenceTrackError(this.code);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceTrackError &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
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

  /// The typed error code, or `null` if not in error.
  ReferenceTrackErrorCode? get errorCode =>
      (this is ReferenceTrackError) ? (this as ReferenceTrackError).code : null;

  /// Pattern‑match over all variants.
  T when<T>({
    required T Function() idle,
    required T Function() picking,
    required T Function(ReferenceTrack track) selected,
    required T Function(ReferenceTrackErrorCode code) error,
  }) {
    switch (this) {
      case ReferenceTrackIdle():
        return idle();
      case ReferenceTrackPicking():
        return picking();
      case ReferenceTrackSelected(track: final t):
        return selected(t);
      case ReferenceTrackError(code: final c):
        return error(c);
    }
  }

  /// Pattern‑match that returns `null` for unhandled variants.
  T? whenOrNull<T>({
    T Function()? idle,
    T Function()? picking,
    T Function(ReferenceTrack track)? selected,
    T Function(ReferenceTrackErrorCode code)? error,
  }) {
    switch (this) {
      case ReferenceTrackIdle():
        return idle?.call();
      case ReferenceTrackPicking():
        return picking?.call();
      case ReferenceTrackSelected(track: final t):
        return selected?.call(t);
      case ReferenceTrackError(code: final c):
        return error?.call(c);
    }
  }
}
