import 'dart:math';
import 'dart:typed_data';

/// Window functions for frame-based audio analysis.

/// Applies a Hann window to the given frame in-place.
///
/// The Hann window reduces spectral leakage.
/// w[n] = 0.5 * (1 - cos(2π * n / (N - 1)))
void applyHannWindow(Float32List frame) {
  final n = frame.length;
  if (n <= 1) return;
  final factor = 2 * pi / (n - 1);
  for (int i = 0; i < n; i++) {
    final window = 0.5 * (1 - cos(factor * i));
    frame[i] *= window;
  }
}

/// Returns a new Hann window of the given size.
Float32List createHannWindow(int size) {
  final window = Float32List(size);
  if (size <= 1) {
    if (size == 1) window[0] = 1.0;
    return window;
  }
  final factor = 2 * pi / (size - 1);
  for (int i = 0; i < size; i++) {
    window[i] = 0.5 * (1 - cos(factor * i));
  }
  return window;
}

/// Applies a pre-emphasis filter to the frame in-place.
///
/// y[n] = x[n] - α * x[n-1]
/// This boosts high frequencies which helps with pitch detection.
void applyPreEmphasis(Float32List frame, {double alpha = 0.97}) {
  if (frame.length <= 1) return;
  double prev = frame[0];
  for (int i = 1; i < frame.length; i++) {
    final current = frame[i];
    frame[i] = current - alpha * prev;
    prev = current;
  }
}
