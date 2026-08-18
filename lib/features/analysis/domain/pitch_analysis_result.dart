import 'package:meta/meta.dart';
import 'pitch_frame.dart';

/// Result of a complete pitch analysis.
@immutable
class PitchAnalysisResult {
  /// Total duration of the analyzed audio in seconds.
  final double duration;

  /// Sample rate of the analyzed audio in Hz.
  final int sampleRate;

  /// Total number of frames analyzed.
  final int totalFrames;

  /// Number of frames detected as voiced.
  final int voicedFrames;

  /// Ratio of voiced frames to total frames (0.0 to 1.0).
  final double voicedRatio;

  /// All pitch frames from the analysis.
  final List<PitchFrame> detectedFrames;

  /// Minimum detected frequency in Hz (voiced frames only).
  final double? minimumFrequency;

  /// Maximum detected frequency in Hz (voiced frames only).
  final double? maximumFrequency;

  /// Median detected frequency in Hz (voiced frames only).
  final double? medianFrequency;

  /// Pitch stability metric (0.0 to 1.0, higher = more stable).
  final double pitchStability;

  /// Summary confidence (average of voiced frame confidences).
  final double averageConfidence;

  /// Warnings encountered during analysis.
  final List<String> warnings;

  const PitchAnalysisResult({
    required this.duration,
    required this.sampleRate,
    required this.totalFrames,
    required this.voicedFrames,
    required this.voicedRatio,
    required this.detectedFrames,
    this.minimumFrequency,
    this.maximumFrequency,
    this.medianFrequency,
    required this.pitchStability,
    required this.averageConfidence,
    required this.warnings,
  });

  /// Creates an empty result for invalid/empty input.
  factory PitchAnalysisResult.empty({
    required double duration,
    required int sampleRate,
    List<String> warnings = const [],
  }) {
    return PitchAnalysisResult(
      duration: duration,
      sampleRate: sampleRate,
      totalFrames: 0,
      voicedFrames: 0,
      voicedRatio: 0.0,
      detectedFrames: const [],
      minimumFrequency: null,
      maximumFrequency: null,
      medianFrequency: null,
      pitchStability: 0.0,
      averageConfidence: 0.0,
      warnings: warnings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PitchAnalysisResult &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          sampleRate == other.sampleRate &&
          totalFrames == other.totalFrames &&
          voicedFrames == other.voicedFrames &&
          voicedRatio == other.voicedRatio &&
          minimumFrequency == other.minimumFrequency &&
          maximumFrequency == other.maximumFrequency &&
          medianFrequency == other.medianFrequency &&
          pitchStability == other.pitchStability &&
          averageConfidence == other.averageConfidence &&
          warnings == other.warnings;

  @override
  int get hashCode => Object.hash(
    duration,
    sampleRate,
    totalFrames,
    voicedFrames,
    voicedRatio,
    minimumFrequency,
    maximumFrequency,
    medianFrequency,
    pitchStability,
    averageConfidence,
    warnings,
  );

  @override
  String toString() =>
      'PitchAnalysisResult(duration: ${duration.toStringAsFixed(2)}s, '
      'sampleRate: $sampleRate, '
      'frames: $totalFrames ($voicedFrames voiced, ${(voicedRatio * 100).toStringAsFixed(1)}%), '
      'freq: ${minimumFrequency?.toStringAsFixed(1) ?? "-"} - ${maximumFrequency?.toStringAsFixed(1) ?? "-"} Hz, '
      'median: ${medianFrequency?.toStringAsFixed(1) ?? "-"} Hz, '
      'stability: ${pitchStability.toStringAsFixed(3)}, '
      'confidence: ${averageConfidence.toStringAsFixed(3)}, '
      'warnings: ${warnings.length})';
}
