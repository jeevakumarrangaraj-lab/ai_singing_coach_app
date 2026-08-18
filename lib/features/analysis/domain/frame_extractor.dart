import 'dart:typed_data';
import 'pitch_analysis_service.dart';

/// Frame extraction utilities for pitch analysis.

/// Extracts overlapping frames from PCM samples.
///
/// Returns a list of frames, each as a Float32List.
/// Frames are copied (not views) to allow independent windowing.
List<Float32List> extractFrames(
  Float32List samples,
  int frameSize,
  int hopSize,
) {
  if (frameSize <= 0 || hopSize <= 0) {
    throw PitchAnalysisException('Frame size and hop size must be positive.');
  }
  if (frameSize > samples.length) {
    throw PitchAnalysisException(
      'Frame size ($frameSize) exceeds sample count (${samples.length}).',
    );
  }

  final frameCount = ((samples.length - frameSize) / hopSize).floor() + 1;
  if (frameCount <= 0) return [];

  final frames = <Float32List>[];
  for (int i = 0; i < frameCount; i++) {
    final start = i * hopSize;
    final frame = Float32List(frameSize);
    frame.setRange(0, frameSize, samples, start);
    frames.add(frame);
  }
  return frames;
}

/// Timestamp for a given frame index.
double frameTimestamp(int frameIndex, int hopSize, int sampleRate) {
  return (frameIndex * hopSize) / sampleRate;
}
