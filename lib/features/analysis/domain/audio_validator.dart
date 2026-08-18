import 'dart:typed_data';
import 'pitch_analysis_service.dart';

/// Audio input validation for pitch analysis.

/// Validates PCM samples before analysis.
///
/// Returns a list of warnings (empty if no issues).
/// Throws [PitchAnalysisException] for fatal errors.
List<String> validatePcmSamples(
  Float32List samples,
  int sampleRate, {
  int minSampleRate = 8000,
  int maxSampleRate = 192000,
  double minDurationSeconds = 0.1,
  double maxDurationSeconds = 300.0,
}) {
  final warnings = <String>[];

  // Check sample rate
  if (sampleRate < minSampleRate || sampleRate > maxSampleRate) {
    throw PitchAnalysisException(
      'Unsupported sample rate: $sampleRate Hz. Must be between $minSampleRate and $maxSampleRate Hz.',
    );
  }

  // Check for empty input
  if (samples.isEmpty) {
    throw PitchAnalysisException('Empty audio buffer provided.');
  }

  // Check duration
  final durationSeconds = samples.length / sampleRate;
  if (durationSeconds < minDurationSeconds) {
    throw PitchAnalysisException(
      'Audio too short: ${durationSeconds.toStringAsFixed(3)}s. Minimum is ${minDurationSeconds}s.',
    );
  }
  if (durationSeconds > maxDurationSeconds) {
    throw PitchAnalysisException(
      'Audio too long: ${durationSeconds.toStringAsFixed(1)}s. Maximum is ${maxDurationSeconds}s.',
    );
  }

  // Check for NaN or infinite values
  int nanCount = 0;
  int infiniteCount = 0;
  for (final sample in samples) {
    if (sample.isNaN) {
      nanCount++;
    } else if (!sample.isFinite) {
      infiniteCount++;
    }
  }

  if (nanCount > 0) {
    warnings.add(
      'Found $nanCount NaN sample(s); they will be replaced with 0.',
    );
  }
  if (infiniteCount > 0) {
    warnings.add(
      'Found $infiniteCount infinite sample(s); they will be clamped.',
    );
  }

  // Check for DC offset (mean significantly different from 0)
  double sum = 0;
  for (final sample in samples) {
    if (sample.isFinite) sum += sample;
  }
  final mean = sum / samples.length;
  if (mean.abs() > 0.01) {
    warnings.add(
      'DC offset detected (mean: ${mean.toStringAsFixed(4)}); consider high-pass filtering.',
    );
  }

  return warnings;
}

/// Sanitizes PCM samples by replacing NaN/infinite values.
///
/// Returns a new Float32List with cleaned samples.
Float32List sanitizeSamples(Float32List samples) {
  final cleaned = Float32List(samples.length);
  for (int i = 0; i < samples.length; i++) {
    final sample = samples[i];
    if (sample.isNaN) {
      cleaned[i] = 0.0;
    } else if (!sample.isFinite) {
      cleaned[i] = sample.isNegative ? -1.0 : 1.0;
    } else {
      cleaned[i] = sample;
    }
  }
  return cleaned;
}

/// Normalizes samples to peak amplitude of 1.0.
///
/// Returns the same list if already normalized or silent.
/// Does not modify the input list.
Float32List normalizePeak(Float32List samples) {
  double peak = 0.0;
  for (final sample in samples) {
    if (sample.isFinite && sample.abs() > peak) {
      peak = sample.abs();
    }
  }

  if (peak <= 0.0 || peak >= 1.0) {
    return samples; // Already normalized or silent
  }

  final normalized = Float32List(samples.length);
  final scale = 1.0 / peak;
  for (int i = 0; i < samples.length; i++) {
    normalized[i] = samples[i] * scale;
  }
  return normalized;
}
