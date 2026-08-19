import 'dart:typed_data';
import 'decoded_audio.dart';

/// Interface for audio decoding services.
///
/// Decodes encoded audio formats (e.g., WAV) into raw PCM samples
/// suitable for pitch analysis.
abstract class AudioDecodingService {
  /// Decodes audio data from bytes into [DecodedAudio].
  ///
  /// [bytes] - Raw audio file bytes (e.g., WAV file contents).
  ///
  /// Returns a [DecodedAudio] containing mono Float32List samples
  /// normalized to [-1.0, 1.0] with metadata.
  ///
  /// Throws [AudioDecodingException] for unsupported formats,
  /// malformed files, or decoding errors.
  DecodedAudio decode(Uint8List bytes);

  /// Checks if the decoder can handle the given bytes.
  ///
  /// Performs a quick header check without full decoding.
  /// Returns true if the format appears supported.
  bool canDecode(Uint8List bytes);
}

/// Exception for audio decoding errors.
class AudioDecodingException implements Exception {
  final String message;
  final Object? originalError;

  const AudioDecodingException(this.message, [this.originalError]);

  @override
  String toString() => 'AudioDecodingException: $message';
}
