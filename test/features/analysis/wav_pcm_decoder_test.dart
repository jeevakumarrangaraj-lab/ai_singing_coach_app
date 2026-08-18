import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_singing_coach/features/analysis/domain.dart';

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

Uint8List buildWavWithTruncatedData({
  required int sampleRate,
  required int channels,
  required int bitsPerSample,
  required List<int> samples,
  required int truncateBytes,
}) {
  final full = buildWav(
    sampleRate: sampleRate,
    channels: channels,
    bitsPerSample: bitsPerSample,
    samples: samples,
  );
  return full.sublist(0, full.length - truncateBytes);
}

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

Uint8List buildMissingFmt() {
  final wav = Uint8List(20);
  final view = ByteData.view(wav.buffer);
  view.setUint32(0, 0x46464952, Endian.little); // RIFF
  view.setUint32(4, 12, Endian.little);
  view.setUint32(8, 0x45564157, Endian.little); // WAVE
  view.setUint32(12, 0x61746164, Endian.little); // data
  view.setUint32(16, 0, Endian.little);
  return wav;
}

Uint8List buildMissingData() {
  // Valid RIFF/WAVE with fmt chunk but NO data chunk
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

Uint8List buildUnsupportedEncoding() {
  return buildWav(
    sampleRate: 44100,
    channels: 1,
    bitsPerSample: 16,
    samples: [0, 100, -100],
    validFormat: false,
  );
}

Uint8List buildEmptyData() {
  return buildWav(
    sampleRate: 44100,
    channels: 1,
    bitsPerSample: 16,
    samples: [],
  );
}

void main() {
  group('WavPcmDecoder', () {
    final decoder = WavPcmDecoder();

    test('decodes valid 44.1 kHz mono 16-bit PCM WAV', () {
      final samples = [0, 1000, -1000, 16384, -16384, 32767, -32768];
      final wav = buildWav(
        sampleRate: 44100,
        channels: 1,
        bitsPerSample: 16,
        samples: samples,
      );
      final result = decoder.decode(wav);

      expect(result.sampleRate, 44100);
      expect(result.channels, 1);
      expect(result.samples.length, samples.length);
      expect(result.samples[0], closeTo(0.0, 1e-6));
      expect(result.samples[1], closeTo(1000 / 32768.0, 1e-6));
      expect(result.samples[2], closeTo(-1000 / 32768.0, 1e-6));
      expect(result.samples[3], closeTo(16384 / 32768.0, 1e-6));
      expect(result.samples[4], closeTo(-16384 / 32768.0, 1e-6));
      expect(result.samples[5], closeTo(32767 / 32768.0, 1e-6));
      expect(result.samples[6], closeTo(-1.0, 1e-6));
    });

    test('decodes valid 48 kHz mono 16-bit PCM WAV', () {
      final samples = [0, 5000, -5000];
      final wav = buildWav(
        sampleRate: 48000,
        channels: 1,
        bitsPerSample: 16,
        samples: samples,
      );
      final result = decoder.decode(wav);

      expect(result.sampleRate, 48000);
      expect(result.channels, 1);
      expect(result.samples.length, 3);
      expect(result.samples[0], closeTo(0.0, 1e-6));
      expect(result.samples[1], closeTo(5000 / 32768.0, 1e-6));
      expect(result.samples[2], closeTo(-5000 / 32768.0, 1e-6));
    });

    test('extracts correct sample rate', () {
      final wav441 = buildWav(
        sampleRate: 44100,
        channels: 1,
        bitsPerSample: 16,
        samples: [0],
      );
      final wav48k = buildWav(
        sampleRate: 48000,
        channels: 1,
        bitsPerSample: 16,
        samples: [0],
      );
      final wav16k = buildWav(
        sampleRate: 16000,
        channels: 1,
        bitsPerSample: 16,
        samples: [0],
      );

      expect(decoder.decode(wav441).sampleRate, 44100);
      expect(decoder.decode(wav48k).sampleRate, 48000);
      expect(decoder.decode(wav16k).sampleRate, 16000);
    });

    test('calculates correct duration', () {
      final frameCount = 44100;
      final samples = List.filled(frameCount, 1000);
      final wav = buildWav(
        sampleRate: 44100,
        channels: 1,
        bitsPerSample: 16,
        samples: samples,
      );
      final result = decoder.decode(wav);

      expect(result.duration.inMicroseconds, closeTo(1_000_000, 1000));
      expect(result.durationSeconds, closeTo(1.0, 0.001));
    });

    test('converts samples to -1.0 to 1.0 range', () {
      final samples = [-32768, -16384, 0, 16384, 32767];
      final wav = buildWav(
        sampleRate: 44100,
        channels: 1,
        bitsPerSample: 16,
        samples: samples,
      );
      final result = decoder.decode(wav);

      expect(result.samples[0], closeTo(-1.0, 1e-6));
      expect(result.samples[1], closeTo(-0.5, 1e-6));
      expect(result.samples[2], closeTo(0.0, 1e-6));
      expect(result.samples[3], closeTo(0.5, 1e-6));
      expect(result.samples[4], closeTo(32767 / 32768.0, 1e-6));
      for (final s in result.samples) {
        expect(s >= -1.0 && s <= 1.0, isTrue);
      }
    });

    test('downmixes stereo to mono', () {
      final left = [1000, -2000, 3000];
      final right = [4000, -5000, 6000];
      final interleaved = <int>[];
      for (var i = 0; i < left.length; i++) {
        interleaved.add(left[i]);
        interleaved.add(right[i]);
      }
      final wav = buildWav(
        sampleRate: 44100,
        channels: 2,
        bitsPerSample: 16,
        samples: interleaved,
      );
      final result = decoder.decode(wav);

      expect(result.channels, 1);
      expect(result.samples.length, 3);
      expect(result.samples[0], closeTo((1000 + 4000) / 2 / 32768.0, 1e-6));
      expect(result.samples[1], closeTo((-2000 + -5000) / 2 / 32768.0, 1e-6));
      expect(result.samples[2], closeTo((3000 + 6000) / 2 / 32768.0, 1e-6));
    });

    test('skips unknown RIFF chunks before data chunk', () {
      final extraChunk = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
      final wav = buildWav(
        sampleRate: 44100,
        channels: 1,
        bitsPerSample: 16,
        samples: [1000, -1000],
        extraChunks: [extraChunk],
      );
      final result = decoder.decode(wav);

      expect(result.sampleRate, 44100);
      expect(result.samples.length, 2);
      expect(result.samples[0], closeTo(1000 / 32768.0, 1e-6));
      expect(result.samples[1], closeTo(-1000 / 32768.0, 1e-6));
    });

    test('throws on invalid RIFF header', () {
      final wav = buildInvalidRiff();
      expect(() => decoder.decode(wav), throwsA(isA<AudioDecodingException>()));
      expect(decoder.canDecode(wav), isFalse);
    });

    test('throws on missing fmt chunk', () {
      final wav = buildMissingFmt();
      expect(() => decoder.decode(wav), throwsA(isA<AudioDecodingException>()));
    });

    test('throws on missing data chunk', () {
      final wav = buildMissingData();
      expect(() => decoder.decode(wav), throwsA(isA<AudioDecodingException>()));
    });

    test('throws on truncated sample data', () {
      final samples = List.filled(100, 1000);
      final wav = buildWavWithTruncatedData(
        sampleRate: 44100,
        channels: 1,
        bitsPerSample: 16,
        samples: samples,
        truncateBytes: 10,
      );
      expect(() => decoder.decode(wav), throwsA(isA<AudioDecodingException>()));
    });

    test('throws on unsupported WAV encoding', () {
      final wav = buildUnsupportedEncoding();
      expect(() => decoder.decode(wav), throwsA(isA<AudioDecodingException>()));
    });

    test('handles empty data chunk', () {
      final wav = buildEmptyData();
      final result = decoder.decode(wav);

      expect(result.samples.length, 0);
      expect(result.sampleRate, 44100);
      expect(result.channels, 1);
      expect(result.duration, Duration.zero);
    });
  });
}
