import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_singing_coach/features/analysis/domain.dart';

void main() {
  group('Audio Validator Tests', () {
    test('Empty buffer throws', () {
      expect(
        () => validatePcmSamples(Float32List(0), 44100),
        throwsA(isA<PitchAnalysisException>()),
      );
    });

    test('Invalid sample rate throws', () {
      expect(
        () => validatePcmSamples(Float32List(44100), 7000),
        throwsA(isA<PitchAnalysisException>()),
      );
      expect(
        () => validatePcmSamples(Float32List(44100), 200000),
        throwsA(isA<PitchAnalysisException>()),
      );
    });

    test('Too short audio throws', () {
      // 0.05s at 44100 Hz = 2205 samples, min is 0.1s
      expect(
        () => validatePcmSamples(Float32List(2205), 44100),
        throwsA(isA<PitchAnalysisException>()),
      );
    });

    test('Valid input returns warnings only', () {
      final samples = Float32List(8820); // 0.2s at 44100 Hz
      final warnings = validatePcmSamples(samples, 44100);
      expect(warnings, isA<List<String>>());
    });

    test('NaN samples are reported and sanitized', () {
      final samples = Float32List.fromList([0.0, double.nan, 0.5, double.nan]);
      final warnings = validatePcmSamples(
        samples,
        44100,
        minDurationSeconds: 0.0,
      );
      expect(warnings.any((w) => w.contains('NaN')), isTrue);

      final cleaned = sanitizeSamples(samples);
      expect(cleaned[1], 0.0);
      expect(cleaned[3], 0.0);
      expect(cleaned[0], 0.0);
      expect(cleaned[2], 0.5);
    });

    test('Infinite samples are reported and clamped', () {
      final samples = Float32List.fromList([
        0.0,
        double.infinity,
        -double.infinity,
        0.5,
      ]);
      final warnings = validatePcmSamples(
        samples,
        44100,
        minDurationSeconds: 0.0,
      );
      expect(warnings.any((w) => w.contains('infinite')), isTrue);

      final cleaned = sanitizeSamples(samples);
      expect(cleaned[1], 1.0);
      expect(cleaned[2], -1.0);
      expect(cleaned[0], 0.0);
      expect(cleaned[3], 0.5);
    });

    test('Normalize peak scales to 1.0', () {
      final samples = Float32List.fromList([0.2, -0.5, 0.3]);
      final normalized = normalizePeak(samples);
      expect(normalized[1], closeTo(-1.0, 1e-5)); // Peak becomes -1.0
      expect(normalized[0], closeTo(0.4, 1e-5)); // 0.2 / 0.5
      expect(normalized[2], closeTo(0.6, 1e-5)); // 0.3 / 0.5
    });

    test('Already normalized samples unchanged', () {
      final samples = Float32List.fromList([-1.0, 0.5, -0.8]);
      final normalized = normalizePeak(samples);
      expect(normalized, samples);
    });

    test('Silent samples unchanged by normalize', () {
      final samples = Float32List.fromList([0.0, 0.0, 0.0]);
      final normalized = normalizePeak(samples);
      expect(normalized, samples);
    });
  });
}
