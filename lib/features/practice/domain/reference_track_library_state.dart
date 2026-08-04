import 'package:flutter/foundation.dart';
import 'reference_track.dart';

/// Union type for the reference track library lifecycle.
@immutable
sealed class ReferenceTrackLibraryState {
  const ReferenceTrackLibraryState();
}

/// No tracks have been loaded yet.
class ReferenceTrackLibraryInitial extends ReferenceTrackLibraryState {
  const ReferenceTrackLibraryInitial();
}

/// Tracks are being loaded.
class ReferenceTrackLibraryLoading extends ReferenceTrackLibraryState {
  const ReferenceTrackLibraryLoading();
}

/// Tracks loaded successfully.
class ReferenceTrackLibraryLoaded extends ReferenceTrackLibraryState {
  final List<ReferenceTrack> tracks;
  final ReferenceTrack? selectedTrack;

  const ReferenceTrackLibraryLoaded({required this.tracks, this.selectedTrack});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceTrackLibraryLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(tracks, other.tracks) &&
          selectedTrack == other.selectedTrack;

  @override
  int get hashCode => Object.hash(Object.hashAll(tracks), selectedTrack);
}

/// An operation (add/remove/select) is in progress.
class ReferenceTrackLibrarySaving extends ReferenceTrackLibraryState {
  final List<ReferenceTrack> tracks;
  final ReferenceTrack? selectedTrack;

  const ReferenceTrackLibrarySaving({required this.tracks, this.selectedTrack});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceTrackLibrarySaving &&
          runtimeType == other.runtimeType &&
          listEquals(tracks, other.tracks) &&
          selectedTrack == other.selectedTrack;

  @override
  int get hashCode => Object.hash(Object.hashAll(tracks), selectedTrack);
}

/// An error occurred during an operation.
class ReferenceTrackLibraryError extends ReferenceTrackLibraryState {
  final String message;
  final List<ReferenceTrack> tracks;
  final ReferenceTrack? selectedTrack;

  const ReferenceTrackLibraryError({
    required this.message,
    required this.tracks,
    this.selectedTrack,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceTrackLibraryError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          listEquals(tracks, other.tracks) &&
          selectedTrack == other.selectedTrack;

  @override
  int get hashCode =>
      Object.hash(message, Object.hashAll(tracks), selectedTrack);
}

// ---------------------------------------------------------------------------
// Extension helpers
// ---------------------------------------------------------------------------

extension ReferenceTrackLibraryStateX on ReferenceTrackLibraryState {
  bool get isInitial => this is ReferenceTrackLibraryInitial;
  bool get isLoading => this is ReferenceTrackLibraryLoading;
  bool get isLoaded => this is ReferenceTrackLibraryLoaded;
  bool get isSaving => this is ReferenceTrackLibrarySaving;
  bool get isError => this is ReferenceTrackLibraryError;

  List<ReferenceTrack> get tracks =>
      whenOrNull(
        loaded: (t, _) => t,
        saving: (t, _) => t,
        error: (_, t, _) => t,
      ) ??
      const [];

  ReferenceTrack? get selectedTrack => whenOrNull<ReferenceTrack?>(
    loaded: (_, ReferenceTrack? s) => s,
    saving: (_, ReferenceTrack? s) => s,
    error: (_, _, ReferenceTrack? s) => s,
  );

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(
      List<ReferenceTrack> tracks,
      ReferenceTrack? selectedTrack,
    )
    loaded,
    required T Function(
      List<ReferenceTrack> tracks,
      ReferenceTrack? selectedTrack,
    )
    saving,
    required T Function(
      String message,
      List<ReferenceTrack> tracks,
      ReferenceTrack? selectedTrack,
    )
    error,
  }) {
    switch (this) {
      case ReferenceTrackLibraryInitial():
        return initial();
      case ReferenceTrackLibraryLoading():
        return loading();
      case ReferenceTrackLibraryLoaded(tracks: final t, selectedTrack: final s):
        return loaded(t, s);
      case ReferenceTrackLibrarySaving(tracks: final t, selectedTrack: final s):
        return saving(t, s);
      case ReferenceTrackLibraryError(
        message: final m,
        tracks: final t,
        selectedTrack: final s,
      ):
        return error(m, t, s);
    }
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<ReferenceTrack> tracks, ReferenceTrack? selectedTrack)?
    loaded,
    T Function(List<ReferenceTrack> tracks, ReferenceTrack? selectedTrack)?
    saving,
    T Function(
      String message,
      List<ReferenceTrack> tracks,
      ReferenceTrack? selectedTrack,
    )?
    error,
  }) {
    switch (this) {
      case ReferenceTrackLibraryInitial():
        return initial?.call();
      case ReferenceTrackLibraryLoading():
        return loading?.call();
      case ReferenceTrackLibraryLoaded(tracks: final t, selectedTrack: final s):
        return loaded?.call(t, s);
      case ReferenceTrackLibrarySaving(tracks: final t, selectedTrack: final s):
        return saving?.call(t, s);
      case ReferenceTrackLibraryError(
        message: final m,
        tracks: final t,
        selectedTrack: final s,
      ):
        return error?.call(m, t, s);
    }
  }
}
