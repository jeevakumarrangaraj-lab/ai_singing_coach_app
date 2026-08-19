import 'dart:typed_data';

import 'audio_decoding_service.dart';
import 'pitch_analysis_service.dart'
    show PitchAnalysisConfig, PitchAnalysisException, PitchAnalysisService;
import 'pitch_analysis_result.dart';
import 'wav_pcm_decoder.dart';
import 'yin_pitch_analysis_service.dart';

/// End-to-end service for analyzing pitch from recorded WAV audio.
///
/// Combines WAV decoding with pitch analysis to provide a complete pipeline
/// from raw WAV bytes to pitch detection results.
class RecordingPitchAnalysisService {
  final AudioDecodingService _decoder;
  final PitchAnalysisService _pitchAnalyzer;

  /// Creates a new recording pitch analysis service.
  ///
  /// [decoder] - WAV decoder (defaults to [WavPcmDecoder]).
  /// [pitchAnalyzer] - Pitch analysis service (defaults to [YinPitchAnalysisService]).
  RecordingPitchAnalysisService({
    AudioDecodingService? decoder,
    PitchAnalysisService? pitchAnalyzer,
  }) : _decoder = decoder ?? WavPcmDecoder(),
       _pitchAnalyzer = pitchAnalyzer ?? YinPitchAnalysisService();

  /// Analyzes pitch from WAV audio data.
  ///
  /// [wavBytes] - Raw WAV file bytes.
  /// [config] - Optional pitch analysis configuration. If provided, its sampleRate
  ///            must match the decoded audio's sample rate. If not provided, a config
  ///            is automatically created for the decoded sample rate.
  ///
  /// Returns a [PitchAnalysisResult] with frame-by-frame pitch data.
  ///
  /// Throws [AudioDecodingException] if the WAV data is invalid or unsupported.
  /// Throws [PitchAnalysisException] if pitch analysis fails.
  PitchAnalysisResult analyzeWav(
    Uint8List wavBytes, {
    PitchAnalysisConfig? config,
  }) {
    // Decode WAV to PCM samples
    final decoded = _decoder.decode(wavBytes);

    // Create config for the actual decoded sample rate if not provided
    final effectiveConfig =
        config ?? PitchAnalysisConfig.forSampleRate(decoded.sampleRate);

    // Validate config sample rate matches decoded audio
    if (effectiveConfig.sampleRate != decoded.sampleRate) {
      throw PitchAnalysisException(
        'Config sample rate (${effectiveConfig.sampleRate}) does not match '
        'decoded audio sample rate (${decoded.sampleRate})',
      );
    }

    // Analyze pitch using the decoded mono samples
    return _pitchAnalyzer.analyzePcm(decoded.samples, config: effectiveConfig);
  }

  /// Checks if the decoder can handle the given WAV bytes.
  ///
  /// Performs a quick header check without full decoding.
  bool canAnalyze(Uint8List wavBytes) {
    return _decoder.canDecode(wavBytes);
  }
}
