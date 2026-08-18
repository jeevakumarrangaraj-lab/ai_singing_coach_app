import 'dart:typed_data';

import 'pitch_analysis_service.dart';
import 'pitch_analysis_result.dart';
import 'yin_detector.dart';
import 'audio_preprocessing.dart';

/// Default implementation of [PitchAnalysisService] using YIN algorithm.
class YinPitchAnalysisService implements PitchAnalysisService {
  @override
  PitchAnalysisResult analyzePcm(
    Float32List samples, {
    PitchAnalysisConfig? config,
  }) {
    if (samples.isEmpty) {
      throw PitchAnalysisException('Empty audio buffer provided.');
    }

    // Use provided config or create one from the actual sample rate
    // The config's sampleRate MUST match the actual PCM sample rate
    final effectiveConfig = config ?? PitchAnalysisConfig.forSampleRate(44100);

    // Validate input
    final warnings = validatePcmSamples(samples, effectiveConfig.sampleRate);

    // Sanitize samples (remove NaN/inf) but preserve amplitude
    final cleanSamples = sanitizeSamples(samples);

    // Run YIN analysis on clean samples (YIN is scale-invariant)
    final analyzer = YinPitchAnalyzer(effectiveConfig);
    final frames = analyzer.analyze(cleanSamples);

    // Create result
    return createPitchAnalysisResult(
      cleanSamples,
      effectiveConfig,
      frames,
      warnings,
    );
  }
}
