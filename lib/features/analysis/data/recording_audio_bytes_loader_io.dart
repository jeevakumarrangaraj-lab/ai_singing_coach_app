import 'dart:io';

import 'recording_audio_bytes_loader.dart';

/// Native implementation using dart:io to read file from filesystem.
class RecordingAudioBytesLoaderImpl implements RecordingAudioBytesLoader {
  @override
  Future<RecordingAudioBytesResult> loadBytes({
    required String recordingRef,
    required String extension,
  }) async {
    try {
      final file = File(recordingRef);

      if (!await file.exists()) {
        return const RecordingAudioBytesFileNotFound();
      }

      final length = await file.length();
      if (length == 0) {
        return const RecordingAudioBytesFileNotFound();
      }

      final bytes = await file.readAsBytes();

      // Let the WAV decoder validate the RIFF/WAVE contents
      return RecordingAudioBytesSuccess(bytes);
    } on FileSystemException catch (e) {
      return RecordingAudioBytesUnreadable(e.message);
    } catch (e) {
      return RecordingAudioBytesUnreadable(e.toString());
    }
  }
}
