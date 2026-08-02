import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/reference_track.dart';
import '../domain/reference_track_state.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final referenceTrackProvider =
    StateNotifierProvider<ReferenceTrackController, ReferenceTrackState>((ref) {
      return ReferenceTrackController();
    });

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

/// Manages the life‑cycle of a local reference‑audio selection.
///
/// * Keeps the file **local** — never uploads or analyses it.
/// * Supports Web (bytes) and native (filesystem path).
/// * Rejects unsupported extensions and files > 50 MB.
class ReferenceTrackController extends StateNotifier<ReferenceTrackState> {
  ReferenceTrackController() : super(const ReferenceTrackIdle());

  /// Allowed audio extensions (lowercase).
  static const _allowedExtensions = {'mp3', 'wav', 'm4a', 'aac'};

  /// Maximum file size: 50 MB.
  static const int _maxSizeBytes = 50 * 1024 * 1024;

  bool _isDisposed = false;
  bool _isPicking = false;

  /// Previously selected track (preserved on cancellation).
  ReferenceTrack? _previousTrack;

  // -----------------------------------------------------------------------
  // Public API
  // -----------------------------------------------------------------------

  /// Opens the system file picker restricted to allowed audio formats.
  ///
  /// If the user cancels:
  ///   - With no previous selection → [ReferenceTrackIdle]
  ///   - With an existing selection → preserves that [ReferenceTrackSelected]
  ///
  /// Duplicate invocations while a picker is already open are silently ignored.
  Future<void> pickReferenceTrack() async {
    // Guard: already picking or disposed.
    if (_isPicking) return;
    if (_isDisposed) return;

    _isPicking = true;

    try {
      // Remember previous selection before overwriting state.
      final previous = state is ReferenceTrackSelected
          ? (state as ReferenceTrackSelected).track
          : null;
      _previousTrack = previous;

      state = const ReferenceTrackPicking();

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions.toList(),
        withData: kIsWeb, // bytes only needed on Web
      );

      // Dispose guard: check after the await.
      if (_isDisposed) {
        _isPicking = false;
        return;
      }

      // Handle cancellation.
      if (result == null || result.files.isEmpty) {
        _handleCancellation();
        return;
      }

      final file = result.files.single;

      // ---- Validate extension ----
      final extension = _normalizeExtension(file);
      if (extension == null || !_allowedExtensions.contains(extension)) {
        state = const ReferenceTrackError(
          ReferenceTrackErrorCode.unsupportedFormat,
        );
        _previousTrack = null;
        return;
      }

      // ---- Validate size ----
      if (file.size > _maxSizeBytes) {
        state = const ReferenceTrackError(ReferenceTrackErrorCode.fileTooLarge);
        _previousTrack = null;
        return;
      }

      // ---- Resolve storage representation ----
      String? localPath;
      Uint8List? bytes;

      if (kIsWeb) {
        bytes = file.bytes;
        if (bytes == null || bytes.isEmpty) {
          state = const ReferenceTrackError(
            ReferenceTrackErrorCode.unreadableFile,
          );
          _previousTrack = null;
          return;
        }
      } else {
        localPath = file.path;
        if (localPath == null || localPath.isEmpty) {
          state = const ReferenceTrackError(
            ReferenceTrackErrorCode.missingPath,
          );
          _previousTrack = null;
          return;
        }
      }

      final track = ReferenceTrack(
        name: file.name,
        sizeBytes: file.size,
        extension: extension,
        localPath: localPath,
        bytes: bytes,
        selectionTimestamp: DateTime.now(),
      );

      state = ReferenceTrackSelected(track);
      _previousTrack = null;
    } catch (e) {
      if (_isDisposed) {
        _isPicking = false;
        return;
      }

      // Emit a typed code — never expose raw exception details to the user.
      debugPrint('ReferenceTrackController.pickReferenceTrack error: $e');
      // Do NOT log file bytes or local paths.

      state = const ReferenceTrackError(
        ReferenceTrackErrorCode.selectionFailed,
      );
      _previousTrack = null;
    } finally {
      _isPicking = false;
    }
  }

  /// Clears the current selection and releases the in‑memory byte buffer.
  void clearSelection() {
    if (_isDisposed) return;

    _previousTrack = null;
    final current = state;
    if (current is ReferenceTrackSelected) {
      // Release the byte reference so it can be garbage‑collected.
      final _ = current.track.bytes; // NOP — just ensuring the reference exists
    }
    state = const ReferenceTrackIdle();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isPicking = false;
    _previousTrack = null;
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Internal helpers
  // -----------------------------------------------------------------------

  /// Returns the user to idle (or preserves previous selection).
  void _handleCancellation() {
    if (_previousTrack != null) {
      state = ReferenceTrackSelected(_previousTrack!);
    } else {
      state = const ReferenceTrackIdle();
    }
    _previousTrack = null;
  }

  /// Safely extracts and normalises the file extension to lowercase.
  String? _normalizeExtension(PlatformFile file) {
    if (file.extension != null) {
      return file.extension!.toLowerCase();
    }
    // Fall back to deriving from the file name.
    final name = file.name;
    final dot = name.lastIndexOf('.');
    if (dot > 0 && dot < name.length - 1) {
      return name.substring(dot + 1).toLowerCase();
    }
    return null;
  }
}
