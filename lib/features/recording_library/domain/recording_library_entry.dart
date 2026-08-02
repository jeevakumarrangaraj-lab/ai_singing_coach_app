import 'package:flutter/foundation.dart';

/// Analysis status of a recording.
enum AnalysisStatus {
  /// Not yet analysed.
  none,

  /// Analysis in progress.
  pending,

  /// Analysis completed successfully.
  completed,

  /// Analysis failed.
  failed,
}

/// A web-safe local recording library entry.
///
/// - On native platforms [localPath] holds the file-system path to the audio file.
/// - On Web [webStorageKey] holds the IndexedDB key for the audio bytes.
/// - [metadataKey] is the key used in the metadata index (shared across platforms).
///
/// Neither audio bytes nor paths are ever transmitted, uploaded, or analysed externally.
@immutable
class RecordingLibraryEntry {
  /// Unique identifier for this recording.
  final String id;

  /// User-visible title (editable).
  final String title;

  /// When the recording was created.
  final DateTime createdAt;

  /// Duration of the audio.
  final Duration duration;

  /// Size of the audio file in bytes.
  final int sizeBytes;

  /// File extension, e.g., 'wav', 'mp3', 'opus'.
  final String extension;

  /// Native filesystem path (Android / iOS / desktop). Always null on Web.
  final String? localPath;

  /// IndexedDB key for audio bytes (Web only). Always null on native.
  final String? webStorageKey;

  /// Key used in the metadata index (both platforms).
  final String metadataKey;

  /// Whether the user has marked this as a favorite.
  final bool isFavorite;

  /// Current analysis status.
  final AnalysisStatus analysisStatus;

  /// Optional analysis score (0.0 - 100.0) when [analysisStatus] is completed.
  final double? analysisScore;

  /// Optional reference track name used during practice.
  final String? referenceTrackName;

  const RecordingLibraryEntry({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.duration,
    required this.sizeBytes,
    required this.extension,
    this.localPath,
    this.webStorageKey,
    required this.metadataKey,
    this.isFavorite = false,
    this.analysisStatus = AnalysisStatus.none,
    this.analysisScore,
    this.referenceTrackName,
  });

  /// Creates a copy with optional field overrides.
  RecordingLibraryEntry copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    Duration? duration,
    int? sizeBytes,
    String? extension,
    String? Function()? localPath,
    String? Function()? webStorageKey,
    String? metadataKey,
    bool? isFavorite,
    AnalysisStatus? analysisStatus,
    double? Function()? analysisScore,
    String? Function()? referenceTrackName,
  }) {
    return RecordingLibraryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      extension: extension ?? this.extension,
      localPath: localPath != null ? localPath() : this.localPath,
      webStorageKey: webStorageKey != null
          ? webStorageKey()
          : this.webStorageKey,
      metadataKey: metadataKey ?? this.metadataKey,
      isFavorite: isFavorite ?? this.isFavorite,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      analysisScore: analysisScore != null
          ? analysisScore()
          : this.analysisScore,
      referenceTrackName: referenceTrackName != null
          ? referenceTrackName()
          : this.referenceTrackName,
    );
  }

  /// Creates a map suitable for JSON serialization (metadata index).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'durationMs': duration.inMilliseconds,
      'sizeBytes': sizeBytes,
      'extension': extension,
      'localPath': localPath,
      'webStorageKey': webStorageKey,
      'metadataKey': metadataKey,
      'isFavorite': isFavorite,
      'analysisStatus': analysisStatus.index,
      'analysisScore': analysisScore,
      'referenceTrackName': referenceTrackName,
    };
  }

  /// Creates an entry from a JSON map (metadata index).
  factory RecordingLibraryEntry.fromJson(Map<String, dynamic> json) {
    return RecordingLibraryEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      duration: Duration(milliseconds: json['durationMs'] as int),
      sizeBytes: json['sizeBytes'] as int,
      extension: json['extension'] as String,
      localPath: json['localPath'] as String?,
      webStorageKey: json['webStorageKey'] as String?,
      metadataKey: json['metadataKey'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      analysisStatus:
          AnalysisStatus.values[json['analysisStatus'] as int? ?? 0],
      analysisScore: (json['analysisScore'] as num?)?.toDouble(),
      referenceTrackName: json['referenceTrackName'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingLibraryEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          createdAt == other.createdAt &&
          duration == other.duration &&
          sizeBytes == other.sizeBytes &&
          extension == other.extension &&
          localPath == other.localPath &&
          webStorageKey == other.webStorageKey &&
          metadataKey == other.metadataKey &&
          isFavorite == other.isFavorite &&
          analysisStatus == other.analysisStatus &&
          analysisScore == other.analysisScore &&
          referenceTrackName == other.referenceTrackName;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    createdAt,
    duration,
    sizeBytes,
    extension,
    localPath,
    webStorageKey,
    metadataKey,
    isFavorite,
    analysisStatus,
    analysisScore,
    referenceTrackName,
  );

  @override
  String toString() =>
      'RecordingLibraryEntry(id: $id, title: $title, createdAt: $createdAt, '
      'duration: $duration, sizeBytes: $sizeBytes, extension: $extension, '
      'localPath: $localPath, webStorageKey: $webStorageKey, '
      'isFavorite: $isFavorite, analysisStatus: $analysisStatus)';
}

/// Request object for saving a new recording to the library.
///
/// Contains the temporary audio source (path on native, bytes on Web)
/// and the metadata needed to create the library entry.
@immutable
class RecordingLibrarySaveRequest {
  /// Temporary filesystem path to the recorded audio (native only).
  final String? temporaryPath;

  /// Audio bytes (Web only).
  final Uint8List? audioBytes;

  /// User-provided title.
  final String title;

  /// Duration of the recording.
  final Duration duration;

  /// Size in bytes.
  final int sizeBytes;

  /// File extension (e.g., 'wav', 'opus').
  final String extension;

  /// Optional reference track name used during practice.
  final String? referenceTrackName;

  const RecordingLibrarySaveRequest({
    this.temporaryPath,
    this.audioBytes,
    required this.title,
    required this.duration,
    required this.sizeBytes,
    required this.extension,
    this.referenceTrackName,
  });

  /// Validates that the request has the required data for the current platform.
  bool get isValid {
    if (kIsWeb) {
      return audioBytes != null && audioBytes!.isNotEmpty;
    }
    return temporaryPath != null && temporaryPath!.isNotEmpty;
  }
}
