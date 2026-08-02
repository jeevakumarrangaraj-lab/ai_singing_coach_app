import 'package:flutter/foundation.dart';

import 'storage/library_storage.dart' hide createLibraryStorage;
import 'storage/library_storage_impl.dart';
import '../domain/recording_library_entry.dart';
import '../domain/recording_library_error_code.dart';
import 'recording_library_repository.dart';

/// Repository implementation that delegates to platform-specific storage.
class RecordingLibraryRepositoryImpl implements RecordingLibraryRepository {
  final LibraryStorage _storage;

  RecordingLibraryRepositoryImpl() : _storage = createLibraryStorage();

  @override
  Future<List<RecordingLibraryEntry>> loadRecordings() async {
    try {
      return await _storage.loadIndex();
    } on RecordingLibraryException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('RecordingLibraryRepositoryImpl.loadRecordings error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.storageUnavailable,
        'Failed to load recordings',
        e,
      );
    }
  }

  @override
  Future<RecordingLibraryEntry> saveRecording(
    RecordingLibrarySaveRequest request,
  ) async {
    try {
      return await _storage.saveRecording(request);
    } on RecordingLibraryException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('RecordingLibraryRepositoryImpl.saveRecording error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to save recording',
        e,
      );
    }
  }

  @override
  Future<void> renameRecording(String id, String newTitle) async {
    try {
      return await _storage.renameRecording(id, newTitle);
    } on RecordingLibraryException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('RecordingLibraryRepositoryImpl.renameRecording error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to rename recording',
        e,
      );
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    try {
      return await _storage.toggleFavorite(id);
    } on RecordingLibraryException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('RecordingLibraryRepositoryImpl.toggleFavorite error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to toggle favorite',
        e,
      );
    }
  }

  @override
  Future<void> deleteRecording(String id) async {
    try {
      return await _storage.deleteRecording(id);
    } on RecordingLibraryException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('RecordingLibraryRepositoryImpl.deleteRecording error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to delete recording',
        e,
      );
    }
  }

  @override
  Future<Uint8List?> loadRecordingBytes(String id) async {
    try {
      return await _storage.loadRecordingBytes(id);
    } catch (e, stackTrace) {
      debugPrint('RecordingLibraryRepositoryImpl.loadRecordingBytes error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<String?> loadRecordingPath(String id) async {
    try {
      return await _storage.loadRecordingPath(id);
    } catch (e, stackTrace) {
      debugPrint('RecordingLibraryRepositoryImpl.loadRecordingPath error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    await _storage.dispose();
  }

  @override
  Future<void> clearLibrary() async {
    try {
      return await _storage.clearLibrary();
    } on RecordingLibraryException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('RecordingLibraryRepositoryImpl.clearLibrary error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to clear library',
        e,
      );
    }
  }
}
