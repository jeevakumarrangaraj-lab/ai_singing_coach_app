import 'dart:math';
import 'dart:typed_data';

import 'pitch_analysis_service.dart';
import 'pitch_analysis_result.dart';
import 'pitch_frame.dart';
import 'note_converter.dart';
import 'audio_preprocessing.dart';

/// YIN pitch detection algorithm implementation.
///
/// Based on: "YIN, a fundamental frequency estimator for speech and music"
/// by de Cheveigné and Kawahara (2002).
///
/// Key implementation notes:
/// - Uses the cumulative mean normalized difference function (CMND)
/// - Searches for the first minimum below yinThreshold
/// - Parabolic interpolation for sub-sample period estimation
/// - Confidence derived from CMND depth
/// - No pre-emphasis by default (can cause low-frequency errors)
/// - Hann window optional (disabled by default for YIN time-domain method)
class YinDetector {
  final PitchAnalysisConfig _config;
  final Float32List _differenceBuffer;
  final Float32List _cmndBuffer;

  YinDetector(PitchAnalysisConfig config)
    : _config = config,
      _differenceBuffer = Float32List(config.frameSize ~/ 2),
      _cmndBuffer = Float32List(config.frameSize ~/ 2);

  /// Detects pitch in a single frame.
  ///
  /// Returns (frequencyHz, confidence) or (null, 0.0) if unvoiced.
  (double?, double) detectPitch(Float32List frame) {
    // Step 1: Difference function
    _computeDifferenceFunction(frame);

    // Step 2: Cumulative Mean Normalized Difference (CMND)
    _computeCmnd();

    // Step 3: Find the first minimum below threshold
    final tau = _findTau();
    if (tau == null) {
      return (null, 0.0); // Unvoiced
    }

    // Step 4: Parabolic interpolation for better resolution
    double refinedTau = tau.toDouble();
    if (_config.useParabolicInterpolation) {
      refinedTau = _parabolicInterpolation(tau);
    }

    // Step 5: Calculate frequency
    final frequency = _config.sampleRate / refinedTau;

    // Step 6: Validate frequency range
    if (frequency < _config.minFrequency || frequency > _config.maxFrequency) {
      return (null, 0.0);
    }

    // Step 7: Calculate confidence from CMND value
    final confidence = _calculateConfidence(tau);

    return (frequency, confidence);
  }

  /// Computes the difference function.
  ///
  /// d(τ) = Σ (x[n] - x[n+τ])² for n = 0 to N-τ-1
  void _computeDifferenceFunction(Float32List frame) {
    final halfSize = _differenceBuffer.length;
    for (int tau = 0; tau < halfSize; tau++) {
      double sum = 0.0;
      int validCount = 0;
      for (int i = 0; i < frame.length - tau; i++) {
        final diff = frame[i] - frame[i + tau];
        if (diff.isFinite) {
          sum += diff * diff;
          validCount++;
        }
      }
      _differenceBuffer[tau] = validCount > 0
          ? sum / validCount
          : double.infinity;
    }
    // d(0) = 0 by definition
    _differenceBuffer[0] = 0.0;
  }

  /// Computes Cumulative Mean Normalized Difference.
  ///
  /// cmnd(τ) = d(τ) / ((1/τ) * Σ d(j)) for j = 1 to τ
  void _computeCmnd() {
    double runningSum = 0.0;
    for (int tau = 1; tau < _cmndBuffer.length; tau++) {
      runningSum += _differenceBuffer[tau];
      final mean = runningSum / tau;
      if (mean > 0) {
        _cmndBuffer[tau] = _differenceBuffer[tau] / mean;
      } else {
        _cmndBuffer[tau] = 1.0; // Avoid division by zero
      }
    }
    _cmndBuffer[0] = 1.0;
  }

  /// Finds the tau using the YIN algorithm.
  ///
  /// Searches within frequency bounds [minFrequency, maxFrequency].
  /// 1. First, finds the first local minimum where CMND dips below yinThreshold.
  /// 2. If none found, returns the global minimum tau in the search range.
  int? _findTau() {
    // Search range based on frequency limits
    final minTau = (_config.sampleRate / _config.maxFrequency).floor();
    final maxTau = (_config.sampleRate / _config.minFrequency).ceil();
    final searchMax = min(
      maxTau,
      _cmndBuffer.length - 2,
    ); // Need tau+1 for interpolation
    final searchMin = max(minTau, 2); // Start from 2 to avoid d(0) and d(1)

    // Step 1: Find first local minimum below threshold
    for (int tau = searchMin; tau <= searchMax; tau++) {
      final cmnd = _cmndBuffer[tau];
      if (!cmnd.isFinite) continue;

      // Check if it's a local minimum (lower than neighbors)
      final prevCmnd = _cmndBuffer[tau - 1];
      final nextCmnd = _cmndBuffer[tau + 1];
      if (!prevCmnd.isFinite || !nextCmnd.isFinite) continue;

      final isLocalMin = cmnd <= prevCmnd && cmnd <= nextCmnd;
      if (isLocalMin && cmnd < _config.yinThreshold) {
        return tau; // First minimum below threshold
      }
    }

    // Step 2: No minimum below threshold found; return global minimum in range
    int? bestTau;
    double bestCmnd = double.infinity;

    for (int tau = searchMin; tau <= searchMax; tau++) {
      final cmnd = _cmndBuffer[tau];
      if (cmnd.isFinite && cmnd < bestCmnd) {
        bestCmnd = cmnd;
        bestTau = tau;
      }
    }

    return bestTau;
  }

  /// Parabolic interpolation for sub-sample period estimation.
  ///
  /// Fits a parabola through (tau-1, cmnd[tau-1]), (tau, cmnd[tau]), (tau+1, cmnd[tau+1])
  /// and finds the minimum.
  double _parabolicInterpolation(int tau) {
    if (tau <= 0 || tau >= _cmndBuffer.length - 1) return tau.toDouble();

    final y1 = _cmndBuffer[tau - 1];
    final y2 = _cmndBuffer[tau];
    final y3 = _cmndBuffer[tau + 1];

    if (!y1.isFinite || !y2.isFinite || !y3.isFinite) return tau.toDouble();

    // Parabolic interpolation formula
    final denominator = 2 * (y1 - 2 * y2 + y3);
    if (denominator == 0) return tau.toDouble();

    final delta = (y1 - y3) / denominator;
    // Clamp to reasonable range
    final clampedDelta = delta.clamp(-0.5, 0.5);

    return tau + clampedDelta;
  }

  /// Calculates confidence from CMND value.
  ///
  /// Lower CMND = higher confidence.
  /// Maps CMND in [0, threshold] to confidence in [1.0, 0.3].
  double _calculateConfidence(int tau) {
    final cmnd = _cmndBuffer[tau];
    if (!cmnd.isFinite) return 0.0;

    // Linear mapping: CMND 0 -> 1.0, CMND threshold -> 0.3
    final confidence = 1.0 - 0.7 * (cmnd / _config.yinThreshold);
    return confidence.clamp(0.0, 1.0);
  }
}

/// High-level pitch analysis using YIN detector.
class YinPitchAnalyzer {
  final YinDetector _detector;
  final PitchAnalysisConfig _config;

  YinPitchAnalyzer(PitchAnalysisConfig config)
    : _config = config,
      _detector = YinDetector(config);

  /// Analyzes PCM samples and returns pitch frames.
  List<PitchFrame> analyze(Float32List samples) {
    // Extract frames
    final frames = extractFrames(samples, _config.frameSize, _config.hopSize);

    final pitchFrames = <PitchFrame>[];
    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final timestamp = frameTimestamp(i, _config.hopSize, _config.sampleRate);

      // Calculate RMS before windowing (on raw samples)
      final rms = calculateRms(frame);

      // Check if frame has enough energy
      if (rms < _config.voicedRmsThreshold) {
        pitchFrames.add(
          PitchFrame.unvoiced(timestamp: timestamp, rmsLevel: rms),
        );
        continue;
      }

      // Apply Hann window if enabled (disabled by default for YIN)
      if (_config.useHannWindow) {
        applyHannWindow(frame);
      }

      // Apply pre-emphasis if enabled (disabled by default)
      if (_config.usePreEmphasis) {
        applyPreEmphasis(frame, alpha: _config.preEmphasisAlpha);
      }

      // Detect pitch
      final (frequency, confidence) = _detector.detectPitch(frame);

      if (frequency == null) {
        pitchFrames.add(
          PitchFrame.unvoiced(timestamp: timestamp, rmsLevel: rms),
        );
        continue;
      }

      // Convert to musical note
      final noteInfo = NoteConverter.frequencyToNote(frequency);
      if (noteInfo == null) {
        pitchFrames.add(
          PitchFrame.unvoiced(timestamp: timestamp, rmsLevel: rms),
        );
        continue;
      }

      pitchFrames.add(
        PitchFrame.voiced(
          timestamp: timestamp,
          frequencyHz: frequency,
          midiNote: noteInfo.midiNote,
          noteName: noteInfo.noteName,
          octave: noteInfo.octave,
          centsOffset: noteInfo.centsOffset,
          confidence: confidence,
          rmsLevel: rms,
        ),
      );
    }

    return pitchFrames;
  }
}

/// Creates a complete pitch analysis result from frames.
PitchAnalysisResult createPitchAnalysisResult(
  Float32List samples,
  PitchAnalysisConfig config,
  List<PitchFrame> frames,
  List<String> warnings,
) {
  if (frames.isEmpty) {
    return PitchAnalysisResult.empty(
      duration: samples.length / config.sampleRate,
      sampleRate: config.sampleRate,
      warnings: warnings,
    );
  }

  final voicedFrames = frames.where((f) => f.isVoiced).toList();
  final totalFrames = frames.length;
  final voicedCount = voicedFrames.length;
  final voicedRatio = voicedCount / totalFrames;

  // Calculate frequency statistics from voiced frames (excluding boundary frames)
  double? minFreq;
  double? maxFreq;
  double? medianFreq;
  double avgConfidence = 0.0;

  if (voicedCount > 0) {
    final frequencies = voicedFrames.map((f) => f.frequencyHz!).toList()
      ..sort();
    minFreq = frequencies.first;
    maxFreq = frequencies.last;
    medianFreq = frequencies[frequencies.length ~/ 2];
    avgConfidence =
        voicedFrames.map((f) => f.confidence).reduce((a, b) => a + b) /
        voicedCount;
  }

  // Calculate pitch stability (inverse of normalized standard deviation)
  double pitchStability = 0.0;
  if (voicedCount > 1) {
    final frequencies = voicedFrames.map((f) => f.frequencyHz!).toList();
    final mean = frequencies.reduce((a, b) => a + b) / voicedCount;
    final variance =
        frequencies
            .map((f) => (f - mean) * (f - mean))
            .reduce((a, b) => a + b) /
        voicedCount;
    final stdDev = sqrt(variance);
    if (mean > 0) {
      // Stability = 1 - (coefficient of variation), clamped
      pitchStability = (1.0 - (stdDev / mean)).clamp(0.0, 1.0);
    }
  }

  return PitchAnalysisResult(
    duration: samples.length / config.sampleRate,
    sampleRate: config.sampleRate,
    totalFrames: totalFrames,
    voicedFrames: voicedCount,
    voicedRatio: voicedRatio,
    detectedFrames: frames,
    minimumFrequency: minFreq,
    maximumFrequency: maxFreq,
    medianFrequency: medianFreq,
    pitchStability: pitchStability,
    averageConfidence: avgConfidence,
    warnings: warnings,
  );
}
