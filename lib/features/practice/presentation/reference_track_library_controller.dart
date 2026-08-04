import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/reference_track.dart';
import '../domain/reference_track_library_state.dart';

/// Provider for the reference track library controller.
final referenceTrackLibraryProvider =
    StateNotifierProvider<
      ReferenceTrackLibraryController,
      ReferenceTrackLibraryState
    >((ref) {
      return ReferenceTrackLibraryController();
    });

/// Controller for the reference track library.
///
/// Manages a list of [ReferenceTrack] objects with support for:
/// - Adding tracks (with duplicate prevention)
/// - Removing tracks
/// - Selecting/deselecting tracks
/// - Clearing the entire library
///
/// Uses Riverpod StateNotifier pattern with disposed/stale-operation protection.
class ReferenceTrackLibraryController
    extends StateNotifier<ReferenceTrackLibraryState> {
  bool _isDisposed = false;
  bool _isSaving = false;

  ReferenceTrackLibraryController()
    : super(const ReferenceTrackLibraryInitial()) {
    _loadLibrary();
  }

  /// Initializes the library (empty by default for current-session persistence).
  Future<void> _loadLibrary() async {
    if (_isDisposed) return;
    // For Phase 4A-2B, we start with an empty library.
    // Future phases may add persistence here.
    state = const ReferenceTrackLibraryLoaded(tracks: []);
  }

  /// Adds a track to the library.
  ///
  /// Prevents duplicates by checking name + sizeBytes + extension.
  /// If a duplicate is found, the existing track is selected instead.
  Future<void> addTrack(ReferenceTrack track) async {
    if (_isDisposed || _isSaving) return;
    _isSaving = true;

    final currentTracks = _getCurrentTracks();
    final currentSelected = _getCurrentSelectedTrack();

    // Check for duplicate: same name + sizeBytes + extension
    final isDuplicate = currentTracks.any(
      (t) =>
          t.name == track.name &&
          t.sizeBytes == track.sizeBytes &&
          t.extension == track.extension,
    );

    List<ReferenceTrack> updatedTracks;
    ReferenceTrack newSelectedTrack;

    if (isDuplicate) {
      // Select the existing track instead of adding a duplicate
      updatedTracks = currentTracks;
      newSelectedTrack = currentTracks.firstWhere(
        (t) =>
            t.name == track.name &&
            t.sizeBytes == track.sizeBytes &&
            t.extension == track.extension,
      );
    } else {
      // Add new track to the front (most recent first)
      updatedTracks = [track, ...currentTracks];
      newSelectedTrack = track;
    }

    try {
      state = ReferenceTrackLibrarySaving(
        tracks: updatedTracks,
        selectedTrack: newSelectedTrack,
      );
      if (_isDisposed) return;
      state = ReferenceTrackLibraryLoaded(
        tracks: updatedTracks,
        selectedTrack: newSelectedTrack,
      );
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('ReferenceTrackLibraryController.addTrack error: $e');
      state = ReferenceTrackLibraryError(
        message: 'Failed to add track',
        tracks: currentTracks,
        selectedTrack: currentSelected,
      );
      rethrow;
    } finally {
      _isSaving = false;
    }
  }

  /// Removes a track from the library.
  Future<void> removeTrack(ReferenceTrack track) async {
    if (_isDisposed || _isSaving) return;
    _isSaving = true;

    final currentTracks = _getCurrentTracks();
    final currentSelected = _getCurrentSelectedTrack();

    final updatedTracks = currentTracks.where((t) => t != track).toList();
    final newSelected = currentSelected == track ? null : currentSelected;

    try {
      state = ReferenceTrackLibrarySaving(
        tracks: updatedTracks,
        selectedTrack: newSelected,
      );
      if (_isDisposed) return;
      state = ReferenceTrackLibraryLoaded(
        tracks: updatedTracks,
        selectedTrack: newSelected,
      );
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('ReferenceTrackLibraryController.removeTrack error: $e');
      state = ReferenceTrackLibraryError(
        message: 'Failed to remove track',
        tracks: currentTracks,
        selectedTrack: currentSelected,
      );
      rethrow;
    } finally {
      _isSaving = false;
    }
  }

  /// Selects or deselects a track.
  Future<void> selectTrack(ReferenceTrack? track) async {
    if (_isDisposed) return;

    final currentTracks = _getCurrentTracks();
    final currentSelected = _getCurrentSelectedTrack();

    // If selecting the same track, deselect it
    final newSelected = currentSelected == track ? null : track;

    try {
      state = ReferenceTrackLibraryLoaded(
        tracks: currentTracks,
        selectedTrack: newSelected,
      );
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('ReferenceTrackLibraryController.selectTrack error: $e');
      state = ReferenceTrackLibraryError(
        message: 'Failed to select track',
        tracks: currentTracks,
        selectedTrack: currentSelected,
      );
      rethrow;
    }
  }

  /// Clears the selected track.
  Future<void> clearSelectedTrack() async {
    if (_isDisposed) return;
    await selectTrack(null);
  }

  /// Clears the entire library.
  Future<void> clearLibrary() async {
    if (_isDisposed || _isSaving) return;
    _isSaving = true;

    final currentTracks = _getCurrentTracks();
    final currentSelected = _getCurrentSelectedTrack();

    try {
      state = const ReferenceTrackLibrarySaving(
        tracks: [],
        selectedTrack: null,
      );
      if (_isDisposed) return;
      state = const ReferenceTrackLibraryLoaded(tracks: []);
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('ReferenceTrackLibraryController.clearLibrary error: $e');
      state = ReferenceTrackLibraryError(
        message: 'Failed to clear library',
        tracks: currentTracks,
        selectedTrack: currentSelected,
      );
      rethrow;
    } finally {
      _isSaving = false;
    }
  }

  List<ReferenceTrack> _getCurrentTracks() {
    return state.whenOrNull(
          loaded: (t, _) => t,
          saving: (t, _) => t,
          error: (_, t, _) => t,
        ) ??
        const [];
  }

  ReferenceTrack? _getCurrentSelectedTrack() {
    return state.whenOrNull<ReferenceTrack?>(
      loaded: (_, ReferenceTrack? s) => s,
      saving: (_, ReferenceTrack? s) => s,
      error: (_, _, ReferenceTrack? s) => s,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
