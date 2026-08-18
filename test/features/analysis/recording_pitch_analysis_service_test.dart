import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_singing_coach/features/analysis/domain.dart';

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

/// Builds a WAV file from PCM samples.
Uint8List buildWav({
  required int sampleRate,
  required int channels,
  required int bitsPerSample,
  required List<int> samples,
  List<Uint8List> extraChunks = const [],
  bool validFormat = true,
}) {
  final blockAlign = channels * (bitsPerSample ~/ 8);
  final byteRate = sampleRate * blockAlign;
  final dataSize = samples.length * (bitsPerSample ~/ 8);

  // PCM fmt chunk is 16 bytes (no cbSize for format tag 1)
  final fmtChunk = ByteData(16);
  fmtChunk.setUint16(0, validFormat ? 1 : 65535, Endian.little); // audioFormat
  fmtChunk.setUint16(2, channels, Endian.little);
  fmtChunk.setUint32(4, sampleRate, Endian.little);
  fmtChunk.setUint32(8, byteRate, Endian.little);
  fmtChunk.setUint16(12, blockAlign, Endian.little);
  fmtChunk.setUint16(14, bitsPerSample, Endian.little);

  final dataBytes = Uint8List(dataSize);
  final dataView = ByteData.view(dataBytes.buffer);
  for (var i = 0; i < samples.length; i++) {
    dataView.setInt16(i * 2, samples[i], Endian.little);
  }

  int extraSize = 0;
  for (final chunk in extraChunks) {
    extraSize += 8 + ((chunk.length + 1) & ~1);
  }

  // RIFF size = 4 (WAVE) + fmt chunk (8 + 16) + data chunk (8 + dataSize) + extra chunks
  final riffChunkSize =
      4 + 8 + fmtChunk.lengthInBytes + 8 + dataSize + extraSize;
  final wav = Uint8List(8 + riffChunkSize);
  final view = ByteData.view(wav.buffer);

  view.setUint32(0, 0x46464952, Endian.little); // RIFF
  view.setUint32(4, riffChunkSize, Endian.little);
  view.setUint32(8, 0x45564157, Endian.little); // WAVE

  int offset = 12;
  view.setUint32(offset, 0x20746D66, Endian.little); // fmt
  view.setUint32(offset + 4, fmtChunk.lengthInBytes, Endian.little);
  final fmtBytes = fmtChunk.buffer.asUint8List();
  for (var i = 0; i < fmtBytes.length; i++) {
    wav[offset + 8 + i] = fmtBytes[i];
  }
  offset += 8 + fmtChunk.lengthInBytes;

  for (final chunk in extraChunks) {
    view.setUint32(offset, 0x6C697374, Endian.little); // dummy chunk ID 'list'
    view.setUint32(offset + 4, chunk.length, Endian.little);
    for (var i = 0; i < chunk.length; i++) {
      wav[offset + 8 + i] = chunk[i];
    }
    offset += 8 + ((chunk.length + 1) & ~1);
  }

  view.setUint32(offset, 0x61746164, Endian.little); // data
  view.setUint32(offset + 4, dataSize, Endian.little);
  for (var i = 0; i < dataBytes.length; i++) {
    wav[offset + 8 + i] = dataBytes[i];
  }

  return wav;
}

/// Builds a WAV file from Float32List samples (-1.0 to 1.0).
Uint8List buildWavFromFloatSamples({
  required int sampleRate,
  required int channels,
  required Float32List samples,
  bool validFormat = true,
}) {
  final intSamples = <int>[];
  for (final s in samples) {
    final clamped = s.clamp(-1.0, 1.0);
    intSamples.add((clamped * 32767).round());
  }
  return buildWav(
    sampleRate: sampleRate,
    channels: channels,
    bitsPerSample: 16,
    samples: intSamples,
    validFormat: validFormat,
  );
}

/// Builds an invalid RIFF header WAV.
Uint8List buildInvalidRiff() {
  return Uint8List.fromList([
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ]);
}

/// Builds a WAV with valid RIFF/WAVE and fmt but NO data chunk.
Uint8List buildMissingDataChunk() {
  final wav = Uint8List(36);
  final view = ByteData.view(wav.buffer);
  view.setUint32(0, 0x46464952, Endian.little); // RIFF
  view.setUint32(4, 28, Endian.little); // file size - 8
  view.setUint32(8, 0x45564157, Endian.little); // WAVE
  view.setUint32(12, 0x20746D66, Endian.little); // fmt
  view.setUint32(16, 16, Endian.little); // fmt chunk size
  view.setUint16(20, 1, Endian.little); // audioFormat = PCM
  view.setUint16(22, 1, Endian.little); // channels = 1
  view.setUint32(24, 44100, Endian.little); // sampleRate
  view.setUint32(28, 88200, Endian.little); // byteRate
  view.setUint16(32, 2, Endian.little); // blockAlign
  view.setUint16(34, 16, Endian.little); // bitsPerSample
  return wav;
}

void main() {
  group('RecordingPitchAnalysisService', () {
    final service = RecordingPitchAnalysisService();

    test('440 Hz mono WAV at 44.1 kHz produces voiced A4 frames', () {
      const frequencyHz = 440.0;
      const duration = 1.0;
      const sampleRate = 44100;

      final samples = generateSineWave(frequencyHz, duration, sampleRate);
      final wav = buildWavFromFloatSamples(
        sampleRate: sampleRate,
        channels: 1,
        samples: samples,
      );

      final result = service.analyzeWav(wav);

      expect(result.sampleRate, sampleRate);
      expect(result.totalFrames > 0, isTrue);
      expect(result.voicedFrames > 0, isTrue);
      expect(result.voicedRatio > 0.5, isTrue);
      expect(result.medianFrequency, isNotNull);
      expect(
        calculateCentsError(result.medianFrequency!, frequencyHz).abs(),
        lessThanOrEqualTo(15.0),
      );

      // Verify note name and octave for voiced frames (no octave doubling/halving)
      final voicedFrames = result.detectedFrames
          .where((f) => f.isVoiced)
          .toList();
      for (final frame in voicedFrames.take(20)) {
        expect(
          frame.noteName,
          'A',
          reason: 'Note name mismatch at frame ${frame.timestamp}',
        );
        expect(
          frame.octave,
          4,
          reason:
              'Octave mismatch at frame ${frame.timestamp} (no doubling/halving)',
        );
        expect(
          frame.centsOffset!.abs(),
          lessThanOrEqualTo(50.0),
          reason: 'Frame cents offset too large: ${frame.centsOffset}¢',
        );
      }
    });

    test('440 Hz mono WAV at 48 kHz produces voiced A4 frames', () {
      const frequencyHz = 440.0;
      const duration = 1.0;
      const sampleRate = 48000;

      final samples = generateSineWave(frequencyHz, duration, sampleRate);
      final wav = buildWavFromFloatSamples(
        sampleRate: sampleRate,
        channels: 1,
        samples: samples,
      );

      final result = service.analyzeWav(wav);

      expect(result.sampleRate, sampleRate);
      expect(result.totalFrames > 0, isTrue);
      expect(result.voicedFrames > 0, isTrue);
      expect(result.voicedRatio > 0.5, isTrue);
      expect(result.medianFrequency, isNotNull);
      expect(
        calculateCentsError(result.medianFrequency!, frequencyHz).abs(),
        lessThanOrEqualTo(15.0),
      );

      // Verify note name and octave for voiced frames (no octave doubling/halving)
      final voicedFrames = result.detectedFrames
          .where((f) => f.isVoiced)
          .toList();
      for (final frame in voicedFrames.take(20)) {
        expect(
          frame.noteName,
          'A',
          reason: 'Note name mismatch at frame ${frame.timestamp}',
        );
        expect(
          frame.octave,
          4,
          reason:
              'Octave mismatch at frame ${frame.timestamp} (no doubling/halving)',
        );
        expect(
          frame.centsOffset!.abs(),
          lessThanOrEqualTo(50.0),
          reason: 'Frame cents offset too large: ${frame.centsOffset}¢',
        );
      }
    });

    test('Silence WAV produces zero voiced frames', () {
      const duration = 1.0;
      const sampleRate = 44100;

      final samples = generateSilence(duration, sampleRate);
      final wav = buildWavFromFloatSamples(
        sampleRate: sampleRate,
        channels: 1,
        samples: samples,
      );

      final result = service.analyzeWav(wav);

      expect(result.sampleRate, sampleRate);
      expect(result.totalFrames > 0, isTrue);
      expect(result.voicedFrames, 0);
      expect(result.voicedRatio, 0.0);
      expect(result.minimumFrequency, isNull);
      expect(result.maximumFrequency, isNull);
      expect(result.medianFrequency, isNull);
      expect(result.pitchStability, 0.0);
    });

    test('Short valid WAV is handled safely', () {
      const duration = 0.15; // Just above minimum
      const sampleRate = 44100;

      final samples = generateSineWave(440.0, duration, sampleRate);
      final wav = buildWavFromFloatSamples(
        sampleRate: sampleRate,
        channels: 1,
        samples: samples,
      );

      final result = service.analyzeWav(wav);

      expect(result.totalFrames > 0, isTrue);
      expect(result.duration, closeTo(duration, 0.05));
    });

    test('Stereo WAV is downmixed and analyzed', () {
      const frequencyHz = 440.0;
      const duration = 1.0;
      const sampleRate = 44100;

      // Generate stereo: left channel at 440 Hz, right channel at 440 Hz (same)
      final leftSamples = generateSineWave(frequencyHz, duration, sampleRate);
      final rightSamples = generateSineWave(frequencyHz, duration, sampleRate);
      final stereoSamples = Float32List(leftSamples.length * 2);
      for (var i = 0; i < leftSamples.length; i++) {
        stereoSamples[i * 2] = leftSamples[i];
        stereoSamples[i * 2 + 1] = rightSamples[i];
      }
      final wav = buildWavFromFloatSamples(
        sampleRate: sampleRate,
        channels: 2,
        samples: stereoSamples,
      );

      final result = service.analyzeWav(wav);

      expect(result.sampleRate, sampleRate);
      expect(result.totalFrames > 0, isTrue);
      expect(result.voicedFrames > 0, isTrue);
      expect(result.medianFrequency, isNotNull);
      expect(
        calculateCentsError(result.medianFrequency!, frequencyHz).abs(),
        lessThanOrEqualTo(15.0),
      );
    });

    test('Invalid WAV throws the existing decoder exception', () {
      final wav = buildInvalidRiff();

      expect(
        () => service.analyzeWav(wav),
        throwsA(isA<AudioDecodingException>()),
      );
      expect(service.canAnalyze(wav), isFalse);
    });

    test('Empty WAV data is handled through the existing typed error', () {
      final wav = buildMissingDataChunk();

      expect(
        () => service.analyzeWav(wav),
        throwsA(isA<AudioDecodingException>()),
      );
    });

    test('Actual decoded sample rate is used by pitch analysis', () {
      // Test that config sample rate matches decoded sample rate
      const sampleRate = 48000;
      const duration = 0.5;

      final samples = generateSineWave(440.0, duration, sampleRate);
      final wav = buildWavFromFloatSamples(
        sampleRate: sampleRate,
        channels: 1,
        samples: samples,
      );

      // Provide a config with WRONG sample rate - should throw
      final wrongConfig = PitchAnalysisConfig.forSampleRate(44100);
      expect(
        () => service.analyzeWav(wav, config: wrongConfig),
        throwsA(isA<PitchAnalysisException>()),
      );

      // Provide correct config - should work
      final correctConfig = PitchAnalysisConfig.forSampleRate(sampleRate);
      final result = service.analyzeWav(wav, config: correctConfig);
      expect(result.sampleRate, sampleRate);
    });

    test('No octave doubling or halving for A4', () {
      const frequencyHz = 440.0;
      const duration = 1.0;
      const sampleRate = 44100;

      final samples = generateSineWave(frequencyHz, duration, sampleRate);
      final wav = buildWavFromFloatSamples(
        sampleRate: sampleRate,
        channels: 1,
        samples: samples,
      );

      final result = service.analyzeWav(wav);

      expect(result.medianFrequency, isNotNull);
      // Verify the detected frequency is close to 440 Hz, not 220 Hz or 880 Hz
      expect(result.medianFrequency!, closeTo(440.0, 20.0));

      // Check cents offset from A4 is near 0
      final voicedFrames = result.detectedFrames
          .where((f) => f.isVoiced)
          .toList();
      final avgCentsOffset =
          voicedFrames.map((f) => f.centsOffset!).reduce((a, b) => a + b) /
          voicedFrames.length;
      expect(
        avgCentsOffset.abs(),
        lessThanOrEqualTo(15.0),
        reason:
            'Average cents offset from A4 should be ~0¢, got ${avgCentsOffset.toStringAsFixed(1)}¢',
      );
    });

    test('canAnalyze returns true for valid WAV', () {
      final samples = generateSineWave(440.0, 1.0, 44100);
      final wav = buildWavFromFloatSamples(
        sampleRate: 44100,
        channels: 1,
        samples: samples,
      );

      expect(service.canAnalyze(wav), isTrue);
    });

    test('canAnalyze returns false for invalid WAV', () {
      final wav = buildInvalidRiff();
      expect(service.canAnalyze(wav), isFalse);
    });
  });
}
