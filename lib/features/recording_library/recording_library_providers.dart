import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/recording_library_controller.dart';
import 'data/recording_library_repository.dart';
import 'data/recording_library_repository_impl.dart';
import 'domain/recording_library_entry.dart';
import 'domain/recording_library_error_code.dart';
import 'domain/recording_library_state.dart';

/// Provider for the recording library repository.
final recordingLibraryRepositoryProvider = Provider<RecordingLibraryRepository>(
  (ref) {
    final repository = RecordingLibraryRepositoryImpl();
    ref.onDispose(() => repository.dispose());
    return repository;
  },
);

/// Provider for the recording library controller.
final recordingLibraryControllerProvider =
    StateNotifierProvider<RecordingLibraryController, RecordingLibraryState>((
      ref,
    ) {
      final repository = ref.watch(recordingLibraryRepositoryProvider);
      final controller = RecordingLibraryController(repository);
      ref.onDispose(() => controller.dispose());
      return controller;
    });

/// Convenience provider for the current list of recordings.
final recordingLibraryRecordingsProvider =
    Provider<List<RecordingLibraryEntry>>((ref) {
      final state = ref.watch(recordingLibraryControllerProvider);
      return state.whenOrNull(
            loaded: (r) => r,
            saving: (r) => r,
            error: (_, r, _) => r,
          ) ??
          const [];
    });

/// Convenience provider for the loading state.
final recordingLibraryLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(recordingLibraryControllerProvider);
  return state.isLoading;
});

/// Convenience provider for the saving state.
final recordingLibrarySavingProvider = Provider<bool>((ref) {
  final state = ref.watch(recordingLibraryControllerProvider);
  return state.isSaving;
});

/// Convenience provider for the error state.
final recordingLibraryErrorProvider = Provider<RecordingLibraryErrorCode?>((
  ref,
) {
  final state = ref.watch(recordingLibraryControllerProvider);
  return state.whenOrNull(error: (code, _, _) => code);
});
