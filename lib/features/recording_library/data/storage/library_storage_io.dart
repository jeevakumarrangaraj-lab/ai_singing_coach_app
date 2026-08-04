import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import '../../domain/recording_library_entry.dart';
import '../../domain/recording_library_error_code.dart';
import '../recording_library_repository.dart';
import 'library_storage.dart';

/// Native (Android/iOS/Desktop) storage implementation.
///
/// Audio files are copied to the app's documents directory under a 'recordings' subfolder.
/// Metadata is stored in an atomic JSON index file (recordings_index.json) in the same directory.
class LibraryStorageIO implements LibraryStorage {
  static const String _recordingsDirName = 'recordings';
  static const String _indexFileName = 'recordings_index.json';
  static const String _tempDirName = 'temp';

  Directory? _recordingsDir;
  File? _indexFile;
  Directory? _tempDir;

  /// Initializes the storage directories and index file.
  @override
  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _recordingsDir = Directory('${appDir.path}/$_recordingsDirName');
    _indexFile = File('${_recordingsDir!.path}/$_indexFileName');
    _tempDir = Directory('${appDir.path}/$_tempDirName');

    await _recordingsDir!.create(recursive: true);
    await _tempDir!.create(recursive: true);

    if (!await _indexFile!.exists()) {
      await _writeIndexAtomically(<Map<String, dynamic>>[]);
    }
  }

  /// Reads the current metadata index.
  @override
  Future<List<RecordingLibraryEntry>> loadIndex() async {
    if (_indexFile == null) await initialize();

    try {
      final content = await _indexFile!.readAsString();
      if (content.trim().isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(content);
      final entries = <RecordingLibraryEntry>[];
      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;
        try {
          entries.add(RecordingLibraryEntry.fromJson(item));
        } catch (e) {
          debugPrint(
            'LibraryStorageIO.loadIndex: skipping corrupted entry: $e',
          );
          // Skip corrupted entries gracefully
        }
      }
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (e) {
      debugPrint('LibraryStorageIO.loadIndex error: $e');
      // Corrupted index - return empty and let caller decide
      return [];
    }
  }

  /// Atomically writes the metadata index.
  ///
  /// Uses a temporary file + rename for atomicity on POSIX systems.
  Future<void> _writeIndexAtomically(List<Map<String, dynamic>> entries) async {
    if (_indexFile == null) await initialize();

    final tempFile = File('${_indexFile!.path}.tmp');
    try {
      await tempFile.writeAsString(jsonEncode(entries));
      await tempFile.rename(_indexFile!.path);
    } catch (e) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      rethrow;
    }
  }

  /// Saves a new recording: copies audio to recordings dir, updates index atomically.
  ///
  /// Returns the created entry with metadataKey set.
  @override
  Future<RecordingLibraryEntry> saveRecording(
    RecordingLibrarySaveRequest request,
  ) async {
    await initialize();

    if (!request.isValid) {
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.invalidData,
        'Invalid save request for current platform',
      );
    }

    // Duplicate protection: the same source audio must not be stored twice.
    final sourceKey =
        request.sourceKey ??
        request.temporaryPath; // fallback: use the temp path as identity
    if (sourceKey != null && sourceKey.isNotEmpty) {
      final existing = await loadIndex();
      for (final e in existing) {
        if (e.sourceKey != null && e.sourceKey == sourceKey) {
          // Already stored — return the existing entry instead of duplicating.
          return e;
        }
      }
    }

    final id = _generateId();
    final metadataKey = 'rec_$id';
    final timestamp = DateTime.now();
    final fileName = '$metadataKey.${request.extension}';
    final destPath = '${_recordingsDir!.path}/$fileName';

    // Step 1: Copy audio file to recordings directory
    try {
      if (request.temporaryPath != null) {
        final sourceFile = File(request.temporaryPath!);
        if (!await sourceFile.exists()) {
          throw RecordingLibraryException(
            RecordingLibraryErrorCode.notFound,
            'Temporary audio file not found',
          );
        }
        await sourceFile.copy(destPath);
      }
      // Web path handled by web implementation
    } catch (e) {
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to copy audio file',
        e,
      );
    }

    // Step 2: Verify the copied file exists and get actual size
    final destFile = File(destPath);
    if (!await destFile.exists()) {
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Audio file not found after copy',
      );
    }
    final actualSize = await destFile.length();

    // Step 3: Create entry and update index atomically
    final entry = RecordingLibraryEntry(
      id: id,
      title: request.title,
      createdAt: timestamp,
      duration: request.duration,
      sizeBytes: actualSize,
      extension: request.extension,
      localPath: destPath,
      webStorageKey: null,
      metadataKey: metadataKey,
      sourceKey: sourceKey,
      referenceTrackName: request.referenceTrackName,
    );

    try {
      final currentIndex = await loadIndex();
      currentIndex.add(entry);
      await _writeIndexAtomically(currentIndex.map((e) => e.toJson()).toList());
    } catch (e) {
      // Rollback: delete the copied audio file on metadata failure
      try {
        await destFile.delete();
      } catch (_) {}
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.storageUnavailable,
        'Failed to persist metadata index',
        e,
      );
    }

    return entry;
  }

  /// Updates a single entry in the index atomically.
  @override
  Future<void> updateEntry(RecordingLibraryEntry updatedEntry) async {
    final currentIndex = await loadIndex();
    final index = currentIndex.indexWhere((e) => e.id == updatedEntry.id);
    if (index == -1) {
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.notFound,
        'Recording not found',
      );
    }
    currentIndex[index] = updatedEntry;
    await _writeIndexAtomically(currentIndex.map((e) => e.toJson()).toList());
  }

  /// Renames a recording.
  @override
  Future<void> renameRecording(String id, String newTitle) async {
    final entry = (await loadIndex()).firstWhere(
      (e) => e.id == id,
      orElse: () => throw RecordingLibraryException(
        RecordingLibraryErrorCode.notFound,
        'Recording not found',
      ),
    );
    await updateEntry(entry.copyWith(title: newTitle));
  }

  /// Toggles favorite status.
  @override
  Future<void> toggleFavorite(String id) async {
    final entry = (await loadIndex()).firstWhere(
      (e) => e.id == id,
      orElse: () => throw RecordingLibraryException(
        RecordingLibraryErrorCode.notFound,
        'Recording not found',
      ),
    );
    await updateEntry(entry.copyWith(isFavorite: !entry.isFavorite));
  }

  /// Deletes a recording (audio file + metadata).
  @override
  Future<void> deleteRecording(String id) async {
    final entries = await loadIndex();
    final entry = entries.firstWhere(
      (e) => e.id == id,
      orElse: () => throw RecordingLibraryException(
        RecordingLibraryErrorCode.notFound,
        'Recording not found',
      ),
    );

    // Delete audio file
    if (entry.localPath != null) {
      final audioFile = File(entry.localPath!);
      if (await audioFile.exists()) {
        await audioFile.delete();
      }
    }

    // Update index
    entries.removeWhere((e) => e.id == id);
    await _writeIndexAtomically(entries.map((e) => e.toJson()).toList());
  }

  /// Loads audio bytes for playback.
  @override
  Future<Uint8List?> loadRecordingBytes(String id) async {
    final entries = await loadIndex();
    for (final entry in entries) {
      if (entry.id == id) {
        if (entry.localPath == null) return null;
        final file = File(entry.localPath!);
        if (!await file.exists()) return null;
        return await file.readAsBytes();
      }
    }
    return null;
  }

  /// Loads audio file path for playback.
  @override
  Future<String?> loadRecordingPath(String id) async {
    final entries = await loadIndex();
    for (final entry in entries) {
      if (entry.id == id) {
        if (entry.localPath == null) return null;
        final file = File(entry.localPath!);
        if (!await file.exists()) return null;
        return entry.localPath;
      }
    }
    return null;
  }

  /// Disposes resources (no-op for native).
  @override
  Future<void> dispose() async {
    // No persistent connections to close
  }

  /// Clears all recordings from the library (audio + metadata).
  @override
  Future<void> clearLibrary() async {
    await initialize();

    // Delete all audio files
    final entries = await loadIndex();
    for (final entry in entries) {
      if (entry.localPath != null) {
        final audioFile = File(entry.localPath!);
        if (await audioFile.exists()) {
          await audioFile.delete();
        }
      }
    }

    // Clear the index
    await _writeIndexAtomically(<Map<String, dynamic>>[]);
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    return List.generate(
      length,
      (i) => chars[(random + i * 7) % chars.length],
    ).join();
  }
}

/// Creates the platform-appropriate [LibraryStorage] implementation for native platforms.
LibraryStorage createLibraryStorage() => LibraryStorageIO();
