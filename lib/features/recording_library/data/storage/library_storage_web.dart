import 'dart:async';
import 'package:idb_shim/idb_shim.dart';
import 'package:flutter/foundation.dart';

import '../../domain/recording_library_entry.dart';
import '../../domain/recording_library_error_code.dart';
import '../recording_library_repository.dart';
import 'library_storage.dart';

/// Web storage implementation using IndexedDB via idb_shim.
///
/// Schema versioning:
/// v1: Initial schema with 'recordings' object store (keyPath: 'metadataKey')
///     and 'audio' object store (keyPath: 'key') for audio bytes.
class LibraryStorageWeb implements LibraryStorage {
  static const String _dbName = 'tuno_recording_library';
  static const int _schemaVersion = 1;
  static const String _recordingsStore = 'recordings';
  static const String _audioStore = 'audio';

  Database? _db;
  bool _initialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  /// Initializes the IndexedDB connection and creates/upgrades schema.
  @override
  Future<void> initialize() async {
    if (_initialized) return _initCompleter.future;
    if (_initCompleter.isCompleted) return _initCompleter.future;

    try {
      _db = await idbFactoryWeb.open(
        _dbName,
        version: _schemaVersion,
        onUpgradeNeeded: (VersionChangeEvent event) {
          final db = event.database;
          // Create recordings store (metadata)
          if (!db.objectStoreNames.contains(_recordingsStore)) {
            db.createObjectStore(_recordingsStore, keyPath: 'metadataKey');
          }
          // Create audio store (bytes)
          if (!db.objectStoreNames.contains(_audioStore)) {
            db.createObjectStore(_audioStore, keyPath: 'key');
          }
        },
      );
      _initialized = true;
      _initCompleter.complete();
    } catch (e, stackTrace) {
      debugPrint('LibraryStorageWeb.initialize error: $e');
      debugPrintStack(stackTrace: stackTrace);
      _initCompleter.completeError(
        RecordingLibraryException(
          RecordingLibraryErrorCode.storageUnavailable,
          'Failed to open IndexedDB',
          e,
        ),
      );
    }
    return _initCompleter.future;
  }

  Future<Database> get _database async {
    await initialize();
    if (_db == null) {
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.storageUnavailable,
        'Database not initialized',
      );
    }
    return _db!;
  }

  /// Loads all recordings from the metadata store.
  @override
  Future<List<RecordingLibraryEntry>> loadIndex() async {
    final db = await _database;
    try {
      final txn = db.transaction(_recordingsStore, 'readonly');
      final store = txn.objectStore(_recordingsStore);
      final entries = <RecordingLibraryEntry>[];

      // Use getAll() for simplicity, or cursor for large datasets
      final allRecords = await store.getAll();
      for (final record in allRecords) {
        if (record is Map) {
          try {
            entries.add(
              RecordingLibraryEntry.fromJson(
                record.map((k, v) => MapEntry(k.toString(), v)),
              ),
            );
          } catch (e) {
            debugPrint(
              'LibraryStorageWeb.loadIndex: skipping corrupted entry: $e',
            );
            // Skip corrupted entries gracefully
          }
        }
      }

      await txn.completed;
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (e) {
      debugPrint('LibraryStorageWeb.loadIndex error: $e');
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.storageUnavailable,
        'Failed to load recordings index',
        e,
      );
    }
  }

  /// Saves a new recording: stores audio bytes, then metadata atomically.
  @override
  Future<RecordingLibraryEntry> saveRecording(
    RecordingLibrarySaveRequest request,
  ) async {
    final db = await _database;

    if (!request.isValid) {
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.invalidData,
        'Invalid save request for Web: missing audio bytes',
      );
    }

    // Duplicate protection: the same source audio must not be stored twice.
    final sourceKey = request.sourceKey ?? _hashBytes(request.audioBytes!);
    if (sourceKey.isNotEmpty) {
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
    final audioKey = 'audio_$id';
    final timestamp = DateTime.now();

    // Step 1: Store audio bytes in audio store
    try {
      final audioTxn = db.transaction(_audioStore, 'readwrite');
      final audioStore = audioTxn.objectStore(_audioStore);
      await audioStore.put({'key': audioKey, 'bytes': request.audioBytes!});
      await audioTxn.completed;
    } catch (e) {
      // Check for quota exceeded
      if (_isQuotaError(e)) {
        throw RecordingLibraryException(
          RecordingLibraryErrorCode.quotaExceeded,
          'Storage quota exceeded. Please delete some recordings.',
          e,
        );
      }
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.storageUnavailable,
        'Failed to store audio bytes',
        e,
      );
    }

    // Step 2: Store metadata in recordings store
    final entry = RecordingLibraryEntry(
      id: id,
      title: request.title,
      createdAt: timestamp,
      duration: request.duration,
      sizeBytes: request.audioBytes!.lengthInBytes,
      extension: request.extension,
      localPath: null,
      webStorageKey: audioKey,
      metadataKey: metadataKey,
      sourceKey: sourceKey,
      referenceTrackName: request.referenceTrackName,
    );

    try {
      final metaTxn = db.transaction(_recordingsStore, 'readwrite');
      final metaStore = metaTxn.objectStore(_recordingsStore);
      await metaStore.put(entry.toJson());
      await metaTxn.completed;
    } catch (e) {
      // Rollback: delete audio bytes on metadata failure
      try {
        final rollbackTxn = db.transaction(_audioStore, 'readwrite');
        await rollbackTxn.objectStore(_audioStore).delete(audioKey);
        await rollbackTxn.completed;
      } catch (_) {}
      if (_isQuotaError(e)) {
        throw RecordingLibraryException(
          RecordingLibraryErrorCode.quotaExceeded,
          'Storage quota exceeded. Please delete some recordings.',
          e,
        );
      }
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.storageUnavailable,
        'Failed to persist metadata',
        e,
      );
    }

    return entry;
  }

  /// Updates a single entry in the metadata store.
  @override
  Future<void> updateEntry(RecordingLibraryEntry updatedEntry) async {
    final db = await _database;
    try {
      final txn = db.transaction(_recordingsStore, 'readwrite');
      final store = txn.objectStore(_recordingsStore);
      final existing = await store.getObject(updatedEntry.metadataKey);
      if (existing == null) {
        throw RecordingLibraryException(
          RecordingLibraryErrorCode.notFound,
          'Recording not found',
        );
      }
      await store.put(updatedEntry.toJson());
      await txn.completed;
    } catch (e) {
      if (e is RecordingLibraryException) rethrow;
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.storageUnavailable,
        'Failed to update recording',
        e,
      );
    }
  }

  /// Renames a recording.
  @override
  Future<void> renameRecording(String id, String newTitle) async {
    final entries = await loadIndex();
    final entry = entries.firstWhere(
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
    final entries = await loadIndex();
    final entry = entries.firstWhere(
      (e) => e.id == id,
      orElse: () => throw RecordingLibraryException(
        RecordingLibraryErrorCode.notFound,
        'Recording not found',
      ),
    );
    await updateEntry(entry.copyWith(isFavorite: !entry.isFavorite));
  }

  /// Deletes a recording (audio bytes + metadata).
  @override
  Future<void> deleteRecording(String id) async {
    final db = await _database;
    final entries = await loadIndex();
    final entry = entries.firstWhere(
      (e) => e.id == id,
      orElse: () => throw RecordingLibraryException(
        RecordingLibraryErrorCode.notFound,
        'Recording not found',
      ),
    );

    // Delete audio bytes
    if (entry.webStorageKey != null) {
      try {
        final audioTxn = db.transaction(_audioStore, 'readwrite');
        await audioTxn.objectStore(_audioStore).delete(entry.webStorageKey!);
        await audioTxn.completed;
      } catch (e) {
        debugPrint('LibraryStorageWeb.deleteRecording audio delete error: $e');
        // Continue with metadata deletion even if audio delete fails
      }
    }

    // Delete metadata
    try {
      final metaTxn = db.transaction(_recordingsStore, 'readwrite');
      await metaTxn.objectStore(_recordingsStore).delete(entry.metadataKey);
      await metaTxn.completed;
    } catch (e) {
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.storageUnavailable,
        'Failed to delete recording metadata',
        e,
      );
    }
  }

  /// Loads audio bytes for playback.
  @override
  Future<Uint8List?> loadRecordingBytes(String id) async {
    final db = await _database;
    final entries = await loadIndex();
    RecordingLibraryEntry? entry;
    for (final e in entries) {
      if (e.id == id) {
        entry = e;
        break;
      }
    }
    if (entry?.webStorageKey == null) return null;

    try {
      final txn = db.transaction(_audioStore, 'readonly');
      final store = txn.objectStore(_audioStore);
      final result = await store.getObject(entry!.webStorageKey!);
      await txn.completed;
      if (result is Map && result['bytes'] is Uint8List) {
        return result['bytes'] as Uint8List;
      }
      return null;
    } catch (e) {
      debugPrint('LibraryStorageWeb.loadRecordingBytes error: $e');
      return null;
    }
  }

  /// Loads audio file path (not applicable on Web, returns null).
  @override
  Future<String?> loadRecordingPath(String id) async => null;

  /// Disposes the database connection.
  @override
  Future<void> dispose() async {
    if (_db != null) {
      _db!.close();
      _db = null;
      _initialized = false;
    }
  }

  /// Clears all recordings from the library (audio + metadata).
  @override
  Future<void> clearLibrary() async {
    final db = await _database;

    // Delete all audio bytes
    try {
      final audioTxn = db.transaction(_audioStore, 'readwrite');
      await audioTxn.objectStore(_audioStore).clear();
      await audioTxn.completed;
    } catch (e) {
      debugPrint('LibraryStorageWeb.clearLibrary audio clear error: $e');
    }

    // Delete all metadata
    try {
      final metaTxn = db.transaction(_recordingsStore, 'readwrite');
      await metaTxn.objectStore(_recordingsStore).clear();
      await metaTxn.completed;
    } catch (e) {
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.storageUnavailable,
        'Failed to clear library metadata',
        e,
      );
    }
  }

  bool _isQuotaError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('quota') ||
        errorString.contains('quotaexceedederror') ||
        (errorString.contains('storage') && errorString.contains('exceed'));
  }

  /// Computes a stable, content-derived identity for the audio bytes.
  ///
  /// Used for duplicate protection. This is NOT a security hash; it is only
  /// a cheap deterministic fingerprint (FNV-1a 64-bit) of the recorded blob.
  String _hashBytes(Uint8List bytes) {
    var hash = 0xcbf29ce484222325;
    for (final b in bytes) {
      hash ^= b;
      hash *= 0x100000001b3;
    }
    return 'fnv1a_${hash.toUnsigned(64).toRadixString(16)}';
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

/// Creates the platform-appropriate [LibraryStorage] implementation for web.
LibraryStorage createLibraryStorage() => LibraryStorageWeb();
