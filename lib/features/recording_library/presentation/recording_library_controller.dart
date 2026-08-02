import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/recording_library_entry.dart';
import '../domain/recording_library_error_code.dart';
import '../domain/recording_library_state.dart';
import '../data/recording_library_repository.dart';
import '../data/recording_library_repository_impl.dart';

/// Provider for the recording library repository.
final recordingLibraryRepositoryProvider = Provider<RecordingLibraryRepository>(
  (ref) {
    return RecordingLibraryRepositoryImpl();
  },
);

/// Provider for the recording library controller.
final recordingLibraryControllerProvider =
    StateNotifierProvider<RecordingLibraryController, RecordingLibraryState>((
      ref,
    ) {
      final repository = ref.watch(recordingLibraryRepositoryProvider);
      return RecordingLibraryController(repository);
    });

/// Controller for the recording library using Riverpod StateNotifier pattern.
///
/// Features:
/// - Prevents duplicate concurrent operations
/// - Disposal and stale-request protection
/// - Never updates state after disposal
/// - Returns friendly storage/quota errors
/// - Saving/Error states retain existing recording list
class RecordingLibraryController extends StateNotifier<RecordingLibraryState> {
  final RecordingLibraryRepository _repository;

  bool _isDisposed = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _currentOperation;

  RecordingLibraryController(this._repository)
    : super(const RecordingLibraryInitial()) {
    _loadRecordings();
  }

  /// Loads all recordings from storage.
  Future<void> _loadRecordings() async {
    if (_isDisposed || _isLoading) return;
    _isLoading = true;
    _currentOperation = 'load';

    try {
      state = const RecordingLibraryLoading();
      final recordings = await _repository.loadRecordings();
      _checkDisposedAndThrow();
      state = RecordingLibraryLoaded(recordings);
    } on RecordingLibraryException catch (e) {
      if (_isDisposed) return;
      state = RecordingLibraryError(
        code: e.code,
        currentRecordings: const [],
        failedOperation: _currentOperation,
      );
    } catch (e, stackTrace) {
      if (_isDisposed) return;
      debugPrint('RecordingLibraryController._loadRecordings error: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = RecordingLibraryError(
        code: RecordingLibraryErrorCode.platformError,
        currentRecordings: const [],
        failedOperation: _currentOperation,
      );
    } finally {
      _isLoading = false;
      _currentOperation = null;
    }
  }

  /// Saves a new recording to the library.
  ///
  /// Returns the created entry on success, throws [RecordingLibraryException] on failure.
  Future<RecordingLibraryEntry> saveRecording(
    RecordingLibrarySaveRequest request,
  ) async {
    if (_isDisposed || _isSaving) {
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.cancelled,
        'Save operation already in progress or controller disposed',
      );
    }
    _isSaving = true;
    _currentOperation = 'save';

    final currentRecordings = _getCurrentRecordings();
    state = RecordingLibrarySaving(currentRecordings);

    try {
      final entry = await _repository.saveRecording(request);
      _checkDisposedAndThrow();

      // Append new entry to the front (newest first)
      final updatedRecordings = [entry, ...currentRecordings];
      state = RecordingLibraryLoaded(updatedRecordings);
      return entry;
    } on RecordingLibraryException catch (e) {
      if (_isDisposed) throw RecordingLibraryException(RecordingLibraryErrorCode.disposed, 'Controller has been disposed');
      state = RecordingLibraryError(
        code: e.code,
        currentRecordings: currentRecordings,
        failedOperation: _currentOperation,
      );
      rethrow;
    } catch (e, stackTrace) {
      if (_isDisposed) throw RecordingLibraryException(RecordingLibraryErrorCode.disposed, 'Controller has been disposed');
      debugPrint('RecordingLibraryController.saveRecording error: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = RecordingLibraryError(
        code: RecordingLibraryErrorCode.platformError,
        currentRecordings: currentRecordings,
        failedOperation: _currentOperation,
      );
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to save recording',
        e,
      );
    } finally {
      _isSaving = false;
      _currentOperation = null;
    }
  }

  /// Renames a recording.
  Future<void> renameRecording(String id, String newTitle) async {
    if (_isDisposed || _isSaving) return;
    _isSaving = true;
    _currentOperation = 'rename';

    final currentRecordings = _getCurrentRecordings();
    state = RecordingLibrarySaving(currentRecordings);

    try {
      await _repository.renameRecording(id, newTitle);
      _checkDisposedAndThrow();

      final updatedRecordings = currentRecordings.map((e) {
        if (e.id == id) return e.copyWith(title: newTitle);
        return e;
      }).toList();
      state = RecordingLibraryLoaded(updatedRecordings);
    } on RecordingLibraryException catch (e) {
      if (_isDisposed) return;
      state = RecordingLibraryError(
        code: e.code,
        currentRecordings: currentRecordings,
        failedOperation: _currentOperation,
      );
      rethrow;
    } catch (e, stackTrace) {
      if (_isDisposed) return;
      debugPrint('RecordingLibraryController.renameRecording error: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = RecordingLibraryError(
        code: RecordingLibraryErrorCode.platformError,
        currentRecordings: currentRecordings,
        failedOperation: _currentOperation,
      );
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to rename recording',
        e,
      );
    } finally {
      _isSaving = false;
      _currentOperation = null;
    }
  }

  /// Toggles the favorite status of a recording.
  Future<void> toggleFavorite(String id) async {
    if (_isDisposed || _isSaving) return;
    _isSaving = true;
    _currentOperation = 'toggleFavorite';

    final currentRecordings = _getCurrentRecordings();
    state = RecordingLibrarySaving(currentRecordings);

    try {
      await _repository.toggleFavorite(id);
      _checkDisposedAndThrow();

      final updatedRecordings = currentRecordings.map((e) {
        if (e.id == id) return e.copyWith(isFavorite: !e.isFavorite);
        return e;
      }).toList();
      state = RecordingLibraryLoaded(updatedRecordings);
    } on RecordingLibraryException catch (e) {
      if (_isDisposed) return;
      state = RecordingLibraryError(
        code: e.code,
        currentRecordings: currentRecordings,
        failedOperation: _currentOperation,
      );
      rethrow;
    } catch (e, stackTrace) {
      if (_isDisposed) return;
      debugPrint('RecordingLibraryController.toggleFavorite error: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = RecordingLibraryError(
        code: RecordingLibraryErrorCode.platformError,
        currentRecordings: currentRecordings,
        failedOperation: _currentOperation,
      );
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to toggle favorite',
        e,
      );
    } finally {
      _isSaving = false;
      _currentOperation = null;
    }
  }

  /// Deletes a recording.
  Future<void> deleteRecording(String id) async {
    if (_isDisposed || _isSaving) return;
    _isSaving = true;
    _currentOperation = 'delete';

    final currentRecordings = _getCurrentRecordings();
    state = RecordingLibrarySaving(currentRecordings);

    try {
      await _repository.deleteRecording(id);
      _checkDisposedAndThrow();

      final updatedRecordings = currentRecordings
          .where((e) => e.id != id)
          .toList();
      state = RecordingLibraryLoaded(updatedRecordings);
    } on RecordingLibraryException catch (e) {
      if (_isDisposed) return;
      state = RecordingLibraryError(
        code: e.code,
        currentRecordings: currentRecordings,
        failedOperation: _currentOperation,
      );
      rethrow;
    } catch (e, stackTrace) {
      if (_isDisposed) return;
      debugPrint('RecordingLibraryController.deleteRecording error: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = RecordingLibraryError(
        code: RecordingLibraryErrorCode.platformError,
        currentRecordings: currentRecordings,
        failedOperation: _currentOperation,
      );
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to delete recording',
        e,
      );
    } finally {
      _isSaving = false;
      _currentOperation = null;
    }
  }

  /// Loads audio bytes for playback.
  Future<Uint8List?> loadRecordingBytes(String id) async {
    if (_isDisposed) return null;
    return await _repository.loadRecordingBytes(id);
  }

  /// Loads audio file path for playback (native only).
  Future<String?> loadRecordingPath(String id) async {
    if (_isDisposed) return null;
    return await _repository.loadRecordingPath(id);
  }

  /// Refreshes the library by reloading from storage.
  Future<void> refresh() async {
    await _loadRecordings();
  }

  /// Clears the entire library (all recordings).
  Future<void> clearLibrary() async {
    if (_isDisposed || _isSaving) return;
    _isSaving = true;
    _currentOperation = 'clearLibrary';

    final currentRecordings = _getCurrentRecordings();
    state = RecordingLibrarySaving(currentRecordings);

    try {
      await _repository.clearLibrary();
      _checkDisposedAndThrow();
      state = const RecordingLibraryLoaded([]);
    } on RecordingLibraryException catch (e) {
      if (_isDisposed) return;
      state = RecordingLibraryError(
        code: e.code,
        currentRecordings: currentRecordings,
        failedOperation: _currentOperation,
      );
      rethrow;
    } catch (e, stackTrace) {
      if (_isDisposed) return;
      debugPrint('RecordingLibraryController.clearLibrary error: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = RecordingLibraryError(
        code: RecordingLibraryErrorCode.platformError,
        currentRecordings: currentRecordings,
        failedOperation: _currentOperation,
      );
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.platformError,
        'Failed to clear library',
        e,
      );
    } finally {
      _isSaving = false;
      _currentOperation = null;
    }
  }

  List<RecordingLibraryEntry> _getCurrentRecordings() {
    return state.whenOrNull(
          loaded: (r) => r,
          saving: (r) => r,
          error: (_, r, _) => r,
        ) ??
        const [];
  }

  void _checkDisposedAndThrow() {
    if (_isDisposed) {
      throw RecordingLibraryException(
        RecordingLibraryErrorCode.disposed,
        'Controller has been disposed',
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _repository.dispose();
    super.dispose();
  }
}
