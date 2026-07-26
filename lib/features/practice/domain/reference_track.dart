import 'package:flutter/foundation.dart';

/// A web-safe local reference-audio selection.
///
/// - On native platforms [localPath] holds the file-system path.
/// - On Web [bytes] holds the in-memory bytes.
///
/// Neither field is ever transmitted, uploaded, or analysed.
@immutable
class ReferenceTrack {
  /// Display name, e.g. `"My Song"`.
  final String name;

  /// File size in bytes.
  final int sizeBytes;

  /// Lowercase extension, e.g. `"mp3"`, `"wav"`.
  final String extension;

  /// Native filesystem path (Android / iOS / desktop).
  /// Always null on Web.
  final String? localPath;

  /// Raw bytes, populated on Web.
  /// Always null on native platforms.
  final Uint8List? bytes;

  /// Moment the track was picked.
  final DateTime selectionTimestamp;

  const ReferenceTrack({
    required this.name,
    required this.sizeBytes,
    required this.extension,
    this.localPath,
    this.bytes,
    required this.selectionTimestamp,
  });

  /// Creates a copy with optional field overrides.
  ///
  /// Intentionally does *not* deep‑copy [bytes] to avoid
  /// duplicating large audio buffers. Callers that need
  /// a separate copy should slice [bytes] explicitly.
  ReferenceTrack copyWith({
    String? name,
    int? sizeBytes,
    String? extension,
    String? Function()? localPath,
    Uint8List? Function()? bytes,
    DateTime? selectionTimestamp,
  }) {
    return ReferenceTrack(
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      extension: extension ?? this.extension,
      localPath: localPath != null ? localPath() : this.localPath,
      bytes: bytes != null ? bytes() : this.bytes,
      selectionTimestamp: selectionTimestamp ?? this.selectionTimestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceTrack &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          sizeBytes == other.sizeBytes &&
          extension == other.extension &&
          localPath == other.localPath &&
          selectionTimestamp == other.selectionTimestamp;
  // NOTE: bytes is deliberately excluded from equality to
  // avoid expensive deep comparison of large audio data.

  @override
  int get hashCode =>
      Object.hash(name, sizeBytes, extension, localPath, selectionTimestamp);
  // NOTE: bytes is deliberately excluded from hashCode for
  // the same performance reason as above.

  @override
  String toString() =>
      'ReferenceTrack(name: $name, sizeBytes: $sizeBytes, '
      'extension: $extension, localPath: $localPath, '
      'selectionTimestamp: $selectionTimestamp)';
}
