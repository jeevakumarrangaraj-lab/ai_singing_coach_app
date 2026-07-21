/// Web implementation.
///
/// Web cannot delete local filesystem recordings via dart:io.
/// This is intentionally a no-op.
Future<void> deleteRecordingOnPlatformImpl(String path) async {
  // No filesystem deletion on web.
}
