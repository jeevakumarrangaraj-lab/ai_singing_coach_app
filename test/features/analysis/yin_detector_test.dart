import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_singing_coach/features/analysis/domain.dart';

// Shared configs
final PitchAnalysisConfig config44k = const PitchAnalysisConfig(
  sampleRate: 44100,
  frameSize: 2048,
  hopSize: 1024,
  minFrequency: 65.0,
  maxFrequency: 1100.0,
  yinThreshold: 0.3,
  voicedRmsThreshold: 0.01,
  useParabolicInterpolation: true,
);

final PitchAnalysisConfig config48k = const PitchAnalysisConfig(
  sampleRate: 48000,
  frameSize: 2048,
  hopSize: 1024,
  minFrequency: 65.0,
  maxFrequency: 1100.0,
  yinThreshold: 0.3,
  voicedRmsThreshold: 0.01,
  useParabolicInterpolation: true,
);

/// Generates a sine wave at the given frequency.
Float32List generateSineWave(
  double frequencyHz,
  double durationSeconds,
  int sampleRate, {
  double amplitude = 1.0,
}) {
  final sampleCount = (durationSeconds * sampleRate).round();
  final samples = Float32List(sampleCount);
  final phaseIncrement = 2 * pi * frequencyHz / sampleRate;
  for (int i = 0; i < sampleCount; i++) {
    samples[i] = amplitude * sin(i * phaseIncrement);
  }
  return samples;
}

/// Generates silence (all zeros).
Float32List generateSilence(double durationSeconds, int sampleRate) {
  final sampleCount = (durationSeconds * sampleRate).round();
  return Float32List(sampleCount);
}

/// Calculates error in cents between detected and expected frequency.
/// errorCents = 1200 * log2(detectedFrequency / expectedFrequency)
double calculateCentsError(double detectedHz, double expectedHz) {
  if (detectedHz <= 0 || expectedHz <= 0) return double.infinity;
  return 1200.0 * log(detectedHz / expectedHz) / ln2;
}

/// Runs a strict pitch accuracy test for a given tone at a sample rate.
void testToneAccuracy({
  required String testName,
  required double frequencyHz,
  required String expectedNoteName,
  required int expectedOctave,
  required PitchAnalysisConfig config,
}) {
  test('$testName at ${config.sampleRate} Hz', () {
    final samples = generateSineWave(frequencyHz, 1.0, config.sampleRate);
    final service = YinPitchAnalysisService();
    final result = service.analyzePcm(samples, config: config);

    expect(
      result.voicedFrames > 0,
      isTrue,
      reason: 'Should detect voiced frames',
    );

    // Median voiced pitch error Γëñ15 cents
    final medianErrorCents = calculateCentsError(
      result.medianFrequency!,
      frequencyHz,
    );
    expect(
      medianErrorCents.abs(),
      lessThanOrEqualTo(15.0),
      reason:
          'Median pitch error should be Γëñ15 cents, got ${medianErrorCents.toStringAsFixed(1)}┬ó',
    );

    // Verify note name and octave for voiced frames (no octave doubling/halving)
    final voicedFrames = result.detectedFrames
        .where((f) => f.isVoiced)
        .toList();
    for (final frame in voicedFrames.take(20)) {
      expect(
        frame.noteName,
        expectedNoteName,
        reason: 'Note name mismatch at frame ${frame.timestamp}',
      );
      expect(
        frame.octave,
        expectedOctave,
        reason:
            'Octave mismatch at frame ${frame.timestamp} (no doubling/halving)',
      );
      // Individual frame cents offset should also be reasonable
      expect(
        frame.centsOffset!.abs(),
        lessThanOrEqualTo(50.0),
        reason: 'Frame cents offset too large: ${frame.centsOffset}┬ó',
      );
    }
  });
}

void main() {
  group('YIN Pitch Analysis Tests', () {
    test('Silence returns no voiced pitch', () {
      final samples = generateSilence(1.0, config44k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(result.totalFrames > 0, isTrue);
      expect(result.voicedFrames, 0);
      expect(result.voicedRatio, 0.0);
      expect(result.minimumFrequency, isNull);
      expect(result.maximumFrequency, isNull);
      expect(result.pitchStability, 0.0);
    });

    test('Reduced amplitude tones work above threshold', () {
      final samples = generateSineWave(
        440.0,
        1.0,
        config44k.sampleRate,
        amplitude: 0.1,
      );
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(result.voicedFrames > 0, isTrue);
      expect(result.medianFrequency, closeTo(440.0, 20.0));
    });

    test('Very low amplitude tones are treated as silence', () {
      final samples = generateSineWave(
        440.0,
        1.0,
        config44k.sampleRate,
        amplitude: 0.001,
      );
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      // Should be below voicedRmsThreshold (0.01)
      expect(result.voicedFrames, 0);
      expect(result.voicedRatio, 0.0);
    });

    test('Short input is handled safely', () {
      final samples = generateSineWave(
        440.0,
        0.15,
        config44k.sampleRate,
      ); // Just above minimum
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(result.totalFrames > 0, isTrue);
      expect(result.duration, closeTo(0.15, 0.05));
    });

    test('Invalid sample rate is rejected', () {
      final samples = generateSineWave(440.0, 1.0, 44100);
      final service = YinPitchAnalysisService();
      final badConfig = config44k.copyWith(sampleRate: 7000);

      expect(
        () => service.analyzePcm(samples, config: badConfig),
        throwsA(isA<PitchAnalysisException>()),
      );
    });

    test('NaN samples do not crash analysis', () {
      final samples = generateSineWave(440.0, 1.0, config44k.sampleRate);
      samples[100] = double.nan;
      samples[200] = double.infinity;
      samples[300] = double.negativeInfinity;

      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(result.voicedFrames > 0, isTrue);
      expect(result.medianFrequency, closeTo(440.0, 20.0));
      expect(result.warnings.any((w) => w.contains('NaN')), isTrue);
      expect(result.warnings.any((w) => w.contains('infinite')), isTrue);
    });

    test('Sharp frequency produces higher detected frequency', () {
      // 440 Hz + 50 cents
      final sharpFreq = 440.0 * pow(2.0, 50.0 / 1200.0);
      final samples = generateSineWave(sharpFreq, 1.0, config44k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(result.voicedFrames > 0, isTrue);
      // Sharp frequency should be detected as higher than 440 Hz
      expect(result.medianFrequency!, greaterThan(440.0));
      // And higher than the base 440 Hz detection
      final baseSamples = generateSineWave(440.0, 1.0, config44k.sampleRate);
      final baseResult = service.analyzePcm(baseSamples, config: config44k);
      expect(result.medianFrequency!, greaterThan(baseResult.medianFrequency!));
    });

    test('Flat frequency produces lower detected frequency', () {
      // 440 Hz - 50 cents
      final flatFreq = 440.0 * pow(2.0, -50.0 / 1200.0);
      final samples = generateSineWave(flatFreq, 1.0, config44k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(result.voicedFrames > 0, isTrue);
      // Flat frequency should be detected as lower than 440 Hz
      expect(result.medianFrequency!, lessThan(440.0));
      // And lower than the base 440 Hz detection
      final baseSamples = generateSineWave(440.0, 1.0, config44k.sampleRate);
      final baseResult = service.analyzePcm(baseSamples, config: config44k);
      expect(result.medianFrequency!, lessThan(baseResult.medianFrequency!));
    });

    test('Mixed silence and tone produces correct voiced ratio', () {
      final tone = generateSineWave(440.0, 0.5, config44k.sampleRate);
      final silence = generateSilence(0.5, config44k.sampleRate);
      final samples = Float32List(tone.length + silence.length);
      samples.setRange(0, tone.length, tone);
      samples.setRange(tone.length, samples.length, silence);

      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      // Approximately 50% voiced (depending on frame boundaries)
      expect(result.voicedRatio, closeTo(0.5, 0.2));
    });

    test('Pitch stability is high for stable tone', () {
      final samples = generateSineWave(440.0, 1.0, config44k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(
        result.pitchStability > 0.8,
        isTrue,
        reason: 'Pure sine should have high stability',
      );
    });

    test('Confidence is reasonable for clean tone', () {
      final samples = generateSineWave(440.0, 1.0, config44k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(result.averageConfidence > 0.5, isTrue);
      expect(result.averageConfidence <= 1.0, isTrue);
    });
  });

  group('Strict Pitch Accuracy Tests (44.1 kHz)', () {
    // Test all required tones at 44.1 kHz
    testToneAccuracy(
      testName: '110 Hz (A2) strict accuracy',
      frequencyHz: 110.0,
      expectedNoteName: 'A',
      expectedOctave: 2,
      config: config44k,
    );

    testToneAccuracy(
      testName: '220 Hz (A3) strict accuracy',
      frequencyHz: 220.0,
      expectedNoteName: 'A',
      expectedOctave: 3,
      config: config44k,
    );

    testToneAccuracy(
      testName: '261.63 Hz (C4) strict accuracy',
      frequencyHz: 261.63,
      expectedNoteName: 'C',
      expectedOctave: 4,
      config: config44k,
    );

    testToneAccuracy(
      testName: '440 Hz (A4) strict accuracy',
      frequencyHz: 440.0,
      expectedNoteName: 'A',
      expectedOctave: 4,
      config: config44k,
    );

    testToneAccuracy(
      testName: '523.25 Hz (C5) strict accuracy',
      frequencyHz: 523.25,
      expectedNoteName: 'C',
      expectedOctave: 5,
      config: config44k,
    );

    testToneAccuracy(
      testName: '880 Hz (A5) strict accuracy',
      frequencyHz: 880.0,
      expectedNoteName: 'A',
      expectedOctave: 5,
      config: config44k,
    );

    // Strict cents tests at 44.1 kHz
    test('440 Hz (A4) ΓåÆ approximately 0 cents', () {
      final samples = generateSineWave(440.0, 1.0, config44k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(result.voicedFrames > 0, isTrue);
      final medianErrorCents = calculateCentsError(
        result.medianFrequency!,
        440.0,
      );
      expect(
        medianErrorCents.abs(),
        lessThanOrEqualTo(15.0),
        reason:
            '440 Hz should be ~0 cents error, got ${medianErrorCents.toStringAsFixed(1)}┬ó',
      );
    });

    test('A4 +49 cents ΓåÆ approximately +49 cents', () {
      // Use 49┬ó to avoid rounding boundary at exactly 50┬ó
      final sharpFreq = 440.0 * pow(2.0, 49.0 / 1200.0);
      final samples = generateSineWave(sharpFreq, 1.0, config44k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(result.voicedFrames > 0, isTrue);
      final medianErrorCents = calculateCentsError(
        result.medianFrequency!,
        sharpFreq,
      );
      expect(
        medianErrorCents.abs(),
        lessThanOrEqualTo(10.0),
        reason:
            'A4+49┬ó should detect within ┬▒10┬ó, got ${medianErrorCents.toStringAsFixed(1)}┬ó error',
      );
      // Also verify the detected cents offset from A4 is ~+49┬ó
      final voicedFrames = result.detectedFrames
          .where((f) => f.isVoiced)
          .toList();
      final avgCentsOffset =
          voicedFrames.map((f) => f.centsOffset!).reduce((a, b) => a + b) /
          voicedFrames.length;
      expect(
        (avgCentsOffset - 49.0).abs(),
        lessThanOrEqualTo(15.0),
        reason:
            'Average cents offset from A4 should be ~+49┬ó, got ${avgCentsOffset.toStringAsFixed(1)}┬ó',
      );
    });

    test('A4 -49 cents ΓåÆ approximately -49 cents', () {
      // Use 49┬ó to avoid rounding boundary at exactly 50┬ó
      final flatFreq = 440.0 * pow(2.0, -49.0 / 1200.0);
      final samples = generateSineWave(flatFreq, 1.0, config44k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config44k);

      expect(result.voicedFrames > 0, isTrue);
      final medianErrorCents = calculateCentsError(
        result.medianFrequency!,
        flatFreq,
      );
      expect(
        medianErrorCents.abs(),
        lessThanOrEqualTo(10.0),
        reason:
            'A4-49┬ó should detect within ┬▒10┬ó, got ${medianErrorCents.toStringAsFixed(1)}┬ó error',
      );
      // Also verify the detected cents offset from A4 is ~-49┬ó
      final voicedFrames = result.detectedFrames
          .where((f) => f.isVoiced)
          .toList();
      final avgCentsOffset =
          voicedFrames.map((f) => f.centsOffset!).reduce((a, b) => a + b) /
          voicedFrames.length;
      expect(
        (avgCentsOffset - (-49.0)).abs(),
        lessThanOrEqualTo(15.0),
        reason:
            'Average cents offset from A4 should be ~-49┬ó, got ${avgCentsOffset.toStringAsFixed(1)}┬ó',
      );
    });
  });

  group('Strict Pitch Accuracy Tests (48 kHz)', () {
    // Test all required tones at 48 kHz
    testToneAccuracy(
      testName: '110 Hz (A2) strict accuracy',
      frequencyHz: 110.0,
      expectedNoteName: 'A',
      expectedOctave: 2,
      config: config48k,
    );

    testToneAccuracy(
      testName: '220 Hz (A3) strict accuracy',
      frequencyHz: 220.0,
      expectedNoteName: 'A',
      expectedOctave: 3,
      config: config48k,
    );

    testToneAccuracy(
      testName: '261.63 Hz (C4) strict accuracy',
      frequencyHz: 261.63,
      expectedNoteName: 'C',
      expectedOctave: 4,
      config: config48k,
    );

    testToneAccuracy(
      testName: '440 Hz (A4) strict accuracy',
      frequencyHz: 440.0,
      expectedNoteName: 'A',
      expectedOctave: 4,
      config: config48k,
    );

    testToneAccuracy(
      testName: '523.25 Hz (C5) strict accuracy',
      frequencyHz: 523.25,
      expectedNoteName: 'C',
      expectedOctave: 5,
      config: config48k,
    );

    testToneAccuracy(
      testName: '880 Hz (A5) strict accuracy',
      frequencyHz: 880.0,
      expectedNoteName: 'A',
      expectedOctave: 5,
      config: config48k,
    );

    // Strict cents tests at 48 kHz
    test('440 Hz (A4) ΓåÆ approximately 0 cents', () {
      final samples = generateSineWave(440.0, 1.0, config48k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config48k);

      expect(result.voicedFrames > 0, isTrue);
      final medianErrorCents = calculateCentsError(
        result.medianFrequency!,
        440.0,
      );
      expect(
        medianErrorCents.abs(),
        lessThanOrEqualTo(15.0),
        reason:
            '440 Hz should be ~0 cents error, got ${medianErrorCents.toStringAsFixed(1)}┬ó',
      );
    });

    test('A4 +49 cents ΓåÆ approximately +49 cents', () {
      // Use 49┬ó to avoid rounding boundary at exactly 50┬ó
      final sharpFreq = 440.0 * pow(2.0, 49.0 / 1200.0);
      final samples = generateSineWave(sharpFreq, 1.0, config48k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config48k);

      expect(result.voicedFrames > 0, isTrue);
      final medianErrorCents = calculateCentsError(
        result.medianFrequency!,
        sharpFreq,
      );
      expect(
        medianErrorCents.abs(),
        lessThanOrEqualTo(10.0),
        reason:
            'A4+49┬ó should detect within ┬▒10┬ó, got ${medianErrorCents.toStringAsFixed(1)}┬ó error',
      );
      final voicedFrames = result.detectedFrames
          .where((f) => f.isVoiced)
          .toList();
      final avgCentsOffset =
          voicedFrames.map((f) => f.centsOffset!).reduce((a, b) => a + b) /
          voicedFrames.length;
      expect(
        (avgCentsOffset - 49.0).abs(),
        lessThanOrEqualTo(15.0),
        reason:
            'Average cents offset from A4 should be ~+49┬ó, got ${avgCentsOffset.toStringAsFixed(1)}┬ó',
      );
    });

    test('A4 -49 cents ΓåÆ approximately -49 cents', () {
      // Use 49┬ó to avoid rounding boundary at exactly 50┬ó
      final flatFreq = 440.0 * pow(2.0, -49.0 / 1200.0);
      final samples = generateSineWave(flatFreq, 1.0, config48k.sampleRate);
      final service = YinPitchAnalysisService();
      final result = service.analyzePcm(samples, config: config48k);

      expect(result.voicedFrames > 0, isTrue);
      final medianErrorCents = calculateCentsError(
        result.medianFrequency!,
        flatFreq,
      );
      expect(
        medianErrorCents.abs(),
        lessThanOrEqualTo(10.0),
        reason:
            'A4-49┬ó should detect within ┬▒10┬ó, got ${medianErrorCents.toStringAsFixed(1)}┬ó error',
      );
      final voicedFrames = result.detectedFrames
          .where((f) => f.isVoiced)
          .toList();
      final avgCentsOffset =
          voicedFrames.map((f) => f.centsOffset!).reduce((a, b) => a + b) /
          voicedFrames.length;
      expect(
        (avgCentsOffset - (-49.0)).abs(),
        lessThanOrEqualTo(15.0),
        reason:
            'Average cents offset from A4 should be ~-49┬ó, got ${avgCentsOffset.toStringAsFixed(1)}┬ó',
      );
    });
  });
}
