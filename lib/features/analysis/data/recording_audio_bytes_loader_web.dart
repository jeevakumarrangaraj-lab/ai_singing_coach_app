import 'package:flutter/foundation.dart';

import 'recording_audio_bytes_loader.dart';

/// Web implementation - does not support WebM/Opus format for WAV decoding.
class RecordingAudioBytesLoaderImpl implements RecordingAudioBytesLoader {
  @override
  Future<RecordingAudioBytesResult> loadBytes({
    required String recordingRef,
    required String extension,
  }) async {
    // On web, recordings are WebM/Opus (blob URLs) which WavPcmDecoder cannot decode.
    // We return an unsupported format result so the UI can show an honest state.
    if (kIsWeb) {
      // Check if it's a blob URL or webm/opus format
      final isBlobUrl = recordingRef.startsWith('blob:');
      final isUnsupportedFormat =
          extension.toLowerCase() == 'webm' ||
          extension.toLowerCase() == 'opus' ||
          extension.toLowerCase() == 'ogg';

      if (isBlobUrl || isUnsupportedFormat) {
        return const RecordingAudioBytesUnsupportedFormat(
          'WebM/Opus recordings not supported for pitch analysis on web. '
          'Native WAV recordings are required for detailed analysis.',
        );
      }

      // If it's some other format (unlikely), we could try to fetch bytes
      // but for now we treat all web recordings as unsupported for analysis
      return const RecordingAudioBytesUnsupportedFormat(
        'Detailed pitch analysis requires WAV format. '
        'Web recordings use WebM/Opus which cannot be analyzed.',
      );
    }

    // Should never reach here if used correctly with conditional import
    return const RecordingAudioBytesUnsupportedFormat(
      'Web implementation called on non-web platform',
    );
  }
}
