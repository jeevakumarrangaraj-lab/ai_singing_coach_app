import 'package:flutter/foundation.dart';

import 'recording_library_entry.dart';
import 'recording_library_error_code.dart';

/// Union type for the recording library lifecycle.
@immutable
sealed class RecordingLibraryState {
  const RecordingLibraryState();
}

/// Initial state before any load operation.
class RecordingLibraryInitial extends RecordingLibraryState {
  const RecordingLibraryInitial();
}

/// Loading recordings from storage.
class RecordingLibraryLoading extends RecordingLibraryState {
  const RecordingLibraryLoading();
}

/// Recordings loaded successfully.
///
/// [recordings] is sorted by createdAt descending (newest first).
class RecordingLibraryLoaded extends RecordingLibraryState {
  final List<RecordingLibraryEntry> recordings;

  const RecordingLibraryLoaded(this.recordings);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingLibraryLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(recordings, other.recordings);

  @override
  int get hashCode => Object.hashAll(recordings);
}

/// A save/rename/favorite/delete operation is in progress.
///
/// [currentRecordings] retains the last known list so the UI doesn't disappear.
class RecordingLibrarySaving extends RecordingLibraryState {
  final List<RecordingLibraryEntry> currentRecordings;

  const RecordingLibrarySaving(this.currentRecordings);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingLibrarySaving &&
          runtimeType == other.runtimeType &&
          listEquals(currentRecordings, other.currentRecordings);

  @override
  int get hashCode => Object.hashAll(currentRecordings);
}

/// An error occurred during an operation.
///
/// [currentRecordings] retains the last known list so the UI doesn't disappear.
/// [failedOperation] describes what was being attempted for debugging/logging.
class RecordingLibraryError extends RecordingLibraryState {
  final RecordingLibraryErrorCode code;
  final List<RecordingLibraryEntry> currentRecordings;
  final String? failedOperation;

  const RecordingLibraryError({
    required this.code,
    required this.currentRecordings,
    this.failedOperation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingLibraryError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          listEquals(currentRecordings, other.currentRecordings) &&
          failedOperation == other.failedOperation;

  @override
  int get hashCode =>
      Object.hash(code, Object.hashAll(currentRecordings), failedOperation);
}

// ---------------------------------------------------------------------------
// Extension helpers
// ---------------------------------------------------------------------------

extension RecordingLibraryStateX on RecordingLibraryState {
  bool get isInitial => this is RecordingLibraryInitial;
  bool get isLoading => this is RecordingLibraryLoading;
  bool get isLoaded => this is RecordingLibraryLoaded;
  bool get isSaving => this is RecordingLibrarySaving;
  bool get isError => this is RecordingLibraryError;

  /// The current list of recordings, or empty if not loaded yet.
  List<RecordingLibraryEntry> get recordings =>
      whenOrNull(loaded: (r) => r, saving: (r) => r, error: (_, r, _) => r) ??
      const [];

  /// Pattern‑match over all variants.
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<RecordingLibraryEntry> recordings) loaded,
    required T Function(List<RecordingLibraryEntry> currentRecordings) saving,
    required T Function(
      RecordingLibraryErrorCode code,
      List<RecordingLibraryEntry> currentRecordings,
      String? failedOperation,
    )
    error,
  }) {
    switch (this) {
      case RecordingLibraryInitial():
        return initial();
      case RecordingLibraryLoading():
        return loading();
      case RecordingLibraryLoaded(recordings: final r):
        return loaded(r);
      case RecordingLibrarySaving(currentRecordings: final r):
        return saving(r);
      case RecordingLibraryError(
        code: final c,
        currentRecordings: final r,
        failedOperation: final op,
      ):
        return error(c, r, op);
    }
  }

  /// Pattern‑match that returns `null` for unhandled variants.
  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<RecordingLibraryEntry> recordings)? loaded,
    T Function(List<RecordingLibraryEntry> currentRecordings)? saving,
    T Function(
      RecordingLibraryErrorCode code,
      List<RecordingLibraryEntry> currentRecordings,
      String? failedOperation,
    )?
    error,
  }) {
    switch (this) {
      case RecordingLibraryInitial():
        return initial?.call();
      case RecordingLibraryLoading():
        return loading?.call();
      case RecordingLibraryLoaded(recordings: final r):
        return loaded?.call(r);
      case RecordingLibrarySaving(currentRecordings: final r):
        return saving?.call(r);
      case RecordingLibraryError(
        code: final c,
        currentRecordings: final r,
        failedOperation: final op,
      ):
        return error?.call(c, r, op);
    }
  }
}
