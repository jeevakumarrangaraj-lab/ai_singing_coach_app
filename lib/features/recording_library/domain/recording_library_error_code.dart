/// Typed error codes for recording library failures.
///
/// Controllers emit these typed codes instead of user-facing strings.
/// Consuming widgets map each code to an l10n getter via AppLocalizations.
enum RecordingLibraryErrorCode {
  /// The storage quota was exceeded (IndexedDB on Web, disk space on native).
  quotaExceeded,

  /// The storage backend is unavailable or corrupted.
  storageUnavailable,

  /// The requested recording was not found.
  notFound,

  /// The operation was cancelled or superseded by a newer request.
  cancelled,

  /// An unexpected platform error occurred.
  platformError,

  /// The provided data is invalid (e.g., empty audio, malformed metadata).
  invalidData,

  /// The operation was rejected because the controller is disposed.
  disposed,

  /// Permission denied while accessing storage (native only).
  permissionDenied,
}
