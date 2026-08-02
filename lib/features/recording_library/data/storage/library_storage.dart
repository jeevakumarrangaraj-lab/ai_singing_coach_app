import 'package:flutter/foundation.dart';
import '../../domain/recording_library_entry.dart';

/// Abstract platform-specific storage interface.
abstract class LibraryStorage {
  /// Initializes the storage (creates directories, opens DB, etc.).
  Future<void> initialize();

  /// Loads all recordings from the metadata index.
  Future<List<RecordingLibraryEntry>> loadIndex();

  /// Saves a new recording atomically (audio first, then metadata).
  Future<RecordingLibraryEntry> saveRecording(
    RecordingLibrarySaveRequest request,
  );

  /// Updates a single entry in the metadata index.
  Future<void> updateEntry(RecordingLibraryEntry updatedEntry);

  /// Renames a recording.
  Future<void> renameRecording(String id, String newTitle);

  /// Toggles favorite status.
  Future<void> toggleFavorite(String id);

  /// Deletes a recording (audio + metadata).
  Future<void> deleteRecording(String id);

  /// Loads audio bytes for playback.
  Future<Uint8List?> loadRecordingBytes(String id);

  /// Loads audio file path for playback (native only, returns null on Web).
  Future<String?> loadRecordingPath(String id);

  /// Clears all recordings from the library (audio + metadata).
  Future<void> clearLibrary();

  /// Disposes resources.
  Future<void> dispose();
}

/// Creates the platform-appropriate [LibraryStorage] implementation.
LibraryStorage createLibraryStorage() {
  // This will be overridden by platform-specific implementations
  // via conditional import in library_storage_impl.dart
  throw UnsupportedError(
    'createLibraryStorage not implemented for this platform',
  );
}
