import 'dart:io';

/// IO/Android implementation.
Future<void> deleteRecordingOnPlatformImpl(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}
