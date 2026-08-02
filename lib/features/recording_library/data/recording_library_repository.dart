import 'package:flutter/foundation.dart';

import '../domain/recording_library_entry.dart';
import '../domain/recording_library_error_code.dart';

/// Abstract repository for the recording library.
///
/// Platform-specific implementations handle:
/// - Web: IndexedDB via idb_shim
/// - Native: Filesystem + JSON metadata index
abstract class RecordingLibraryRepository {
  /// Loads all recordings from persistent storage.
  ///
  /// Returns a list sorted by createdAt descending (newest first).
  /// Throws [RecordingLibraryException] on failure.
  Future<List<RecordingLibraryEntry>> loadRecordings();

  /// Saves a new recording to the library.
  ///
  /// Performs atomic save: audio first, then metadata.
  /// If metadata persistence fails, the copied audio is removed.
  ///
  /// Returns the created entry with assigned ID and storage keys.
  /// Throws [RecordingLibraryException] on failure (quota, unavailable, etc.).
  Future<RecordingLibraryEntry> saveRecording(
    RecordingLibrarySaveRequest request,
  );

  /// Renames a recording.
  ///
  /// Throws [RecordingLibraryException] with [RecordingLibraryErrorCode.notFound]
  /// if the recording doesn't exist.
  Future<void> renameRecording(String id, String newTitle);

  /// Toggles the favorite status of a recording.
  ///
  /// Throws [RecordingLibraryException] with [RecordingLibraryErrorCode.notFound]
  /// if the recording doesn't exist.
  Future<void> toggleFavorite(String id);

  /// Deletes a recording (audio + metadata).
  ///
  /// Throws [RecordingLibraryException] with [RecordingLibraryErrorCode.notFound]
  /// if the recording doesn't exist.
  Future<void> deleteRecording(String id);

  /// Loads the audio asset for playback.
  ///
  /// On native: returns a file path or file URI.
  /// On Web: returns a blob URL or the bytes directly.
  /// Returns null if not found.
  Future<Uint8List?> loadRecordingBytes(String id);

  /// Loads the audio file path for playback (native only).
  ///
  /// Returns the local filesystem path, or null if not found / on Web.
  Future<String?> loadRecordingPath(String id);

  /// Disposes any resources (IndexedDB connections, etc.).
  Future<void> dispose();

  /// Clears all recordings from the library (audio + metadata).
  ///
  /// This is a destructive operation. Use with caution.
  /// Throws [RecordingLibraryException] on failure.
  Future<void> clearLibrary();
}

/// Typed exception for repository failures.
class RecordingLibraryException implements Exception {
  final RecordingLibraryErrorCode code;
  final String message;
  final Object? originalError;

  const RecordingLibraryException(
    this.code,
    this.message, [
    this.originalError,
  ]);

  @override
  String toString() => 'RecordingLibraryException($code): $message';
}
