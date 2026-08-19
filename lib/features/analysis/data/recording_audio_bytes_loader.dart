import 'dart:typed_data';

/// Result of loading audio bytes from a recording reference.
///
/// Wraps success or typed failure without throwing.
sealed class RecordingAudioBytesResult {
  const RecordingAudioBytesResult();
}

/// Successfully loaded audio bytes.
class RecordingAudioBytesSuccess extends RecordingAudioBytesResult {
  final Uint8List bytes;

  const RecordingAudioBytesSuccess(this.bytes);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingAudioBytesSuccess &&
          runtimeType == other.runtimeType &&
          bytes.length == other.bytes.length;

  @override
  int get hashCode => bytes.length.hashCode;

  @override
  String toString() =>
      'RecordingAudioBytesSuccess(bytes: ${bytes.length} bytes)';
}

/// File not found or empty.
class RecordingAudioBytesFileNotFound extends RecordingAudioBytesResult {
  const RecordingAudioBytesFileNotFound();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingAudioBytesFileNotFound &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'RecordingAudioBytesFileNotFound()';
}

/// File exists but could not be read (permissions, I/O error).
class RecordingAudioBytesUnreadable extends RecordingAudioBytesResult {
  final String reason;

  const RecordingAudioBytesUnreadable(this.reason);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingAudioBytesUnreadable &&
          runtimeType == other.runtimeType &&
          reason == other.reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'RecordingAudioBytesUnreadable(reason: $reason)';
}

/// Format/platform not supported for analysis (e.g., WebM/Opus on web).
class RecordingAudioBytesUnsupportedFormat extends RecordingAudioBytesResult {
  final String reason;

  const RecordingAudioBytesUnsupportedFormat(this.reason);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingAudioBytesUnsupportedFormat &&
          runtimeType == other.runtimeType &&
          reason == other.reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'RecordingAudioBytesUnsupportedFormat(reason: $reason)';
}

/// Platform-agnostic interface for loading recorded audio bytes.
abstract class RecordingAudioBytesLoader {
  /// Loads audio bytes from the given recording reference.
  ///
  /// [recordingRef] - Platform-specific reference (file path on native, blob URL on web).
  /// [extension] - File extension if known (used for format detection).
  Future<RecordingAudioBytesResult> loadBytes({
    required String recordingRef,
    required String extension,
  });
}
