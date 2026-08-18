import 'package:meta/meta.dart';
import 'dart:typed_data';
import 'pitch_analysis_result.dart';

/// Configuration for pitch analysis.
@immutable
class PitchAnalysisConfig {
  /// Sample rate of the input audio in Hz.
  /// This MUST match the actual PCM sample rate of the input samples.
  final int sampleRate;

  /// Frame size in samples.
  /// Typical: 2048 for 44.1kHz/48kHz (~46ms at 44.1kHz, ~43ms at 48kHz).
  final int frameSize;

  /// Hop size in samples (overlap = frameSize - hopSize).
  /// Typical: frameSize / 2 (50% overlap).
  final int hopSize;

  /// Minimum frequency to detect in Hz.
  final double minFrequency;

  /// Maximum frequency to detect in Hz.
  final double maxFrequency;

  /// YIN threshold for voiced/unvoiced decision (typically 0.1 - 0.15).
  /// Lower = stricter, fewer false positives but more false negatives.
  final double yinThreshold;

  /// Minimum RMS level for a frame to be considered voiced (0.0 to 1.0).
  final double voicedRmsThreshold;

  /// Whether to apply parabolic interpolation for better frequency resolution.
  final bool useParabolicInterpolation;

  /// Whether to apply Hann window before YIN (disabled by default for YIN time-domain method).
  final bool useHannWindow;

  /// Whether to apply pre-emphasis filter (disabled by default for YIN).
  /// Pre-emphasis can harm low-frequency accuracy.
  final bool usePreEmphasis;

  /// Pre-emphasis coefficient (alpha) when enabled.
  /// Typical value: 0.97
  final double preEmphasisAlpha;

  const PitchAnalysisConfig({
    required this.sampleRate,
    this.frameSize = 2048,
    this.hopSize = 1024,
    this.minFrequency = 65.0,
    this.maxFrequency = 1100.0,
    this.yinThreshold = 0.12,
    this.voicedRmsThreshold = 0.01,
    this.useParabolicInterpolation = true,
    this.useHannWindow = false,
    this.usePreEmphasis = false,
    this.preEmphasisAlpha = 0.97,
  });

  /// Duration of one frame in seconds.
  double get frameDuration => frameSize / sampleRate;

  /// Duration of one hop in seconds.
  double get hopDuration => hopSize / sampleRate;

  /// Number of frames for a given duration.
  int frameCountForDuration(double duration) {
    if (duration <= 0) return 0;
    return ((duration * sampleRate - frameSize) / hopSize).floor() + 1;
  }

  /// Creates config optimized for the given sample rate.
  factory PitchAnalysisConfig.forSampleRate(int sampleRate) {
    // Use frame sizes that give ~46ms frames at the target sample rate
    final frameSize = (sampleRate * 0.046).round();
    // Ensure power of 2 for efficiency
    final adjustedFrameSize = <int>[
      512,
      1024,
      2048,
      4096,
    ].reduce((a, b) => (b - frameSize).abs() < (a - frameSize).abs() ? b : a);
    return PitchAnalysisConfig(
      sampleRate: sampleRate,
      frameSize: adjustedFrameSize,
      hopSize: adjustedFrameSize ~/ 2,
    );
  }

  PitchAnalysisConfig copyWith({
    int? sampleRate,
    int? frameSize,
    int? hopSize,
    double? minFrequency,
    double? maxFrequency,
    double? yinThreshold,
    double? voicedRmsThreshold,
    bool? useParabolicInterpolation,
    bool? useHannWindow,
    bool? usePreEmphasis,
    double? preEmphasisAlpha,
  }) {
    return PitchAnalysisConfig(
      sampleRate: sampleRate ?? this.sampleRate,
      frameSize: frameSize ?? this.frameSize,
      hopSize: hopSize ?? this.hopSize,
      minFrequency: minFrequency ?? this.minFrequency,
      maxFrequency: maxFrequency ?? this.maxFrequency,
      yinThreshold: yinThreshold ?? this.yinThreshold,
      voicedRmsThreshold: voicedRmsThreshold ?? this.voicedRmsThreshold,
      useParabolicInterpolation:
          useParabolicInterpolation ?? this.useParabolicInterpolation,
      useHannWindow: useHannWindow ?? this.useHannWindow,
      usePreEmphasis: usePreEmphasis ?? this.usePreEmphasis,
      preEmphasisAlpha: preEmphasisAlpha ?? this.preEmphasisAlpha,
    );
  }
}

/// Interface for pitch analysis services.
abstract class PitchAnalysisService {
  /// Analyzes PCM audio samples and returns pitch detection results.
  ///
  /// [samples] - Interleaved PCM samples as Float32List (normalized to -1.0 to 1.0).
  /// [config] - Analysis configuration. If null, uses defaults for the sample rate.
  ///
  /// Returns a [PitchAnalysisResult] containing frame-by-frame pitch data and summary metrics.
  /// Throws [PitchAnalysisException] on invalid input or processing errors.
  PitchAnalysisResult analyzePcm(
    Float32List samples, {
    PitchAnalysisConfig? config,
  });
}

/// Exception for pitch analysis errors.
class PitchAnalysisException implements Exception {
  final String message;
  final Object? originalError;

  const PitchAnalysisException(this.message, [this.originalError]);

  @override
  String toString() => 'PitchAnalysisException: $message';
}
