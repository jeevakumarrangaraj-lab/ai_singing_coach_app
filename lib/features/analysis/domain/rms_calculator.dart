import 'dart:math';
import 'dart:typed_data';

/// RMS (Root Mean Square) energy calculation.

/// Calculates the RMS level of a frame.
///
/// Returns a value between 0.0 and 1.0 for normalized input.
double calculateRms(Float32List frame) {
  if (frame.isEmpty) return 0.0;

  double sumSquares = 0.0;
  int validCount = 0;
  for (final sample in frame) {
    if (sample.isFinite) {
      sumSquares += sample * sample;
      validCount++;
    }
  }

  if (validCount == 0) return 0.0;
  return sqrt(sumSquares / validCount);
}

/// Calculates RMS for multiple frames efficiently.
List<double> calculateRmsFrames(
  Float32List samples,
  int frameSize,
  int hopSize,
) {
  final frameCount = ((samples.length - frameSize) / hopSize).floor() + 1;
  if (frameCount <= 0) return [];

  final rmsValues = List<double>.filled(frameCount, 0.0);
  for (int i = 0; i < frameCount; i++) {
    final start = i * hopSize;
    final end = start + frameSize;
    if (end <= samples.length) {
      // Calculate RMS directly without creating a sublist
      double sumSquares = 0.0;
      int validCount = 0;
      for (int j = start; j < end; j++) {
        final sample = samples[j];
        if (sample.isFinite) {
          sumSquares += sample * sample;
          validCount++;
        }
      }
      rmsValues[i] = validCount > 0 ? sqrt(sumSquares / validCount) : 0.0;
    }
  }
  return rmsValues;
}
