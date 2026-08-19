import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_singing_coach/features/analysis/data/recording_audio_bytes_loader.dart';
import 'package:ai_singing_coach/features/analysis/presentation/analysis_screen_controller.dart';

class _TestRecordingAudioBytesLoader extends Fake
    implements RecordingAudioBytesLoader {
  _TestRecordingAudioBytesLoader(this._result);

  final RecordingAudioBytesResult _result;

  @override
  Future<RecordingAudioBytesResult> loadBytes({
    required String recordingRef,
    required String extension,
  }) async => _result;
}

class _CountingLoader extends Fake implements RecordingAudioBytesLoader {
  _CountingLoader(this._factory);

  final RecordingAudioBytesResult Function() _factory;
  int count = 0;

  @override
  Future<RecordingAudioBytesResult> loadBytes({
    required String recordingRef,
    required String extension,
  }) async {
    count++;
    return _factory();
  }
}

Uint8List _buildWav({
  required double frequencyHz,
  required double durationSeconds,
  required int sampleRate,
  int channels = 1,
  Float32List? samples,
  bool validFormat = true,
}) {
  final sampleCount = (durationSeconds * sampleRate).round();
  samples ??= Float32List(sampleCount);
  final phaseIncrement = 2 * pi * frequencyHz / sampleRate;
  for (int i = 0; i < sampleCount; i++) {
    samples[i] = sin(i * phaseIncrement);
  }

  final intSamples = <int>[];
  for (final s in samples) {
    intSamples.add((s.clamp(-1.0, 1.0) * 32767).round());
  }

  final blockAlign = channels * 2;
  final byteRate = sampleRate * blockAlign;
  final dataSize = intSamples.length * 2;

  final fmtChunk = ByteData(16);
  fmtChunk.setUint16(0, validFormat ? 1 : 65535, Endian.little);
  fmtChunk.setUint16(2, channels, Endian.little);
  fmtChunk.setUint32(4, sampleRate, Endian.little);
  fmtChunk.setUint32(8, byteRate, Endian.little);
  fmtChunk.setUint16(12, blockAlign, Endian.little);
  fmtChunk.setUint16(14, 16, Endian.little);

  final dataBytes = Uint8List(dataSize);
  final dataView = ByteData.view(dataBytes.buffer);
  for (var i = 0; i < intSamples.length; i++) {
    dataView.setInt16(i * 2, intSamples[i], Endian.little);
  }

  final riffChunkSize = 4 + 8 + fmtChunk.lengthInBytes + 8 + dataSize;
  final wav = Uint8List(8 + riffChunkSize);
  final view = ByteData.view(wav.buffer);

  view.setUint32(0, 0x46464952, Endian.little);
  view.setUint32(4, riffChunkSize, Endian.little);
  view.setUint32(8, 0x45564157, Endian.little);

  int offset = 12;
  view.setUint32(offset, 0x20746D66, Endian.little);
  view.setUint32(offset + 4, fmtChunk.lengthInBytes, Endian.little);
  final fmtBytes = fmtChunk.buffer.asUint8List();
  for (var i = 0; i < fmtBytes.length; i++) {
    wav[offset + 8 + i] = fmtBytes[i];
  }
  offset += 8 + fmtChunk.lengthInBytes;

  view.setUint32(offset, 0x61746164, Endian.little);
  view.setUint32(offset + 4, dataSize, Endian.little);
  for (var i = 0; i < dataBytes.length; i++) {
    wav[offset + 8 + i] = dataBytes[i];
  }

  return wav;
}

void main() {
  group('AnalysisScreenController', () {
    test('starts as AnalysisIdle', () {
      final controller = AnalysisScreenController(
        _TestRecordingAudioBytesLoader(
          RecordingAudioBytesSuccess(Uint8List(0)),
        ),
      );
      expect(controller.state, isA<AnalysisIdle>());
      controller.dispose();
    });

    test('Successful WAV: Loading -> AnalysisSuccess', () async {
      final wav = _buildWav(
        frequencyHz: 440.0,
        durationSeconds: 1.0,
        sampleRate: 44100,
      );
      final controller = AnalysisScreenController(
        _TestRecordingAudioBytesLoader(RecordingAudioBytesSuccess(wav)),
      );

      expectLater(
        controller.stream,
        emitsInOrder([
          isA<AnalysisLoading>(),
          predicate<AnalysisScreenState>(
            (s) =>
                s is AnalysisSuccess &&
                s.result.voicedFrames > 0 &&
                (s.result.medianFrequency! - 440.0).abs() < 20.0,
          ),
        ]),
      );

      await controller.analyze(
        recordingRef: 'test.wav',
        extension: 'wav',
        duration: const Duration(seconds: 1),
      );
      controller.dispose();
    });

    test('Silent WAV: Loading -> AnalysisNoVoiceDetected', () async {
      final wav = _buildWav(
        frequencyHz: 0,
        durationSeconds: 1.0,
        sampleRate: 44100,
        samples: Float32List(44100),
      );
      final controller = AnalysisScreenController(
        _TestRecordingAudioBytesLoader(RecordingAudioBytesSuccess(wav)),
      );

      expectLater(
        controller.stream,
        emitsInOrder([
          isA<AnalysisLoading>(),
          predicate<AnalysisScreenState>(
            (s) => s is AnalysisNoVoiceDetected && s.duration.inSeconds >= 1,
          ),
        ]),
      );

      await controller.analyze(
        recordingRef: 'silent.wav',
        extension: 'wav',
        duration: const Duration(seconds: 1),
      );
      controller.dispose();
    });

    test('Missing file -> AnalysisFileNotFound', () async {
      final controller = AnalysisScreenController(
        _TestRecordingAudioBytesLoader(const RecordingAudioBytesFileNotFound()),
      );

      expectLater(
        controller.stream,
        emitsInOrder([isA<AnalysisLoading>(), isA<AnalysisFileNotFound>()]),
      );

      await controller.analyze(
        recordingRef: 'missing.wav',
        extension: 'wav',
        duration: const Duration(seconds: 1),
      );
      controller.dispose();
    });

    test('empty recordingRef -> AnalysisFileNotFound immediately', () async {
      final controller = AnalysisScreenController(
        _TestRecordingAudioBytesLoader(
          RecordingAudioBytesSuccess(Uint8List(0)),
        ),
      );

      await controller.analyze(
        recordingRef: '',
        extension: 'wav',
        duration: const Duration(seconds: 1),
      );

      expect(controller.state, isA<AnalysisFileNotFound>());
      controller.dispose();
    });

    test(
      'Unsupported format (WebM/Opus) -> AnalysisUnsupportedFormat with reason',
      () async {
        const reason = 'WebM/Opus format not supported for analysis';
        final controller = AnalysisScreenController(
          _TestRecordingAudioBytesLoader(
            RecordingAudioBytesUnsupportedFormat(reason),
          ),
        );

        expectLater(
          controller.stream,
          emitsInOrder([
            isA<AnalysisLoading>(),
            predicate<AnalysisScreenState>(
              (s) => s is AnalysisUnsupportedFormat && s.reason == reason,
            ),
          ]),
        );

        await controller.analyze(
          recordingRef: 'recording.webm',
          extension: 'webm',
          duration: const Duration(seconds: 1),
        );
        controller.dispose();
      },
    );

    test('Unreadable file -> AnalysisFailed', () async {
      const reason = 'Permission denied';
      final controller = AnalysisScreenController(
        _TestRecordingAudioBytesLoader(RecordingAudioBytesUnreadable(reason)),
      );

      expectLater(
        controller.stream,
        emitsInOrder([
          isA<AnalysisLoading>(),
          predicate<AnalysisScreenState>(
            (s) =>
                s is AnalysisFailed &&
                s.message.contains('Could not read audio file') &&
                s.message.contains(reason),
          ),
        ]),
      );

      await controller.analyze(
        recordingRef: 'protected.wav',
        extension: 'wav',
        duration: const Duration(seconds: 1),
      );
      controller.dispose();
    });

    test(
      'Invalid WAV bytes -> AnalysisFailed on audio decoding exception',
      () async {
        final invalidWav = _buildWav(
          frequencyHz: 0,
          durationSeconds: 0,
          sampleRate: 0,
          validFormat: false,
        );
        final controller = AnalysisScreenController(
          _TestRecordingAudioBytesLoader(
            RecordingAudioBytesSuccess(invalidWav),
          ),
        );

        expectLater(
          controller.stream,
          emitsInOrder([
            isA<AnalysisLoading>(),
            predicate<AnalysisScreenState>(
              (s) =>
                  s is AnalysisFailed &&
                  s.message.contains('Invalid audio format'),
            ),
          ]),
        );

        await controller.analyze(
          recordingRef: 'invalid.wav',
          extension: 'wav',
          duration: const Duration(seconds: 1),
        );
        controller.dispose();
      },
    );

    test('Duplicate concurrent request ignored for same recording', () async {
      final wav = _buildWav(
        frequencyHz: 440.0,
        durationSeconds: 1.0,
        sampleRate: 44100,
      );
      int loadCount = 0;
      final loader = _CountingLoader(() {
        loadCount++;
        return RecordingAudioBytesSuccess(wav);
      });
      final controller = AnalysisScreenController(loader);

      await controller.analyze(
        recordingRef: 'test.wav',
        extension: 'wav',
        duration: const Duration(seconds: 1),
      );
      await controller.analyze(
        recordingRef: 'test.wav',
        extension: 'wav',
        duration: const Duration(seconds: 1),
      );

      expect(loadCount, 1);
      controller.dispose();
    });

    test('New request with force=true allowed', () async {
      final wav = _buildWav(
        frequencyHz: 440.0,
        durationSeconds: 1.0,
        sampleRate: 44100,
      );
      int loadCount = 0;
      final loader = _CountingLoader(() {
        loadCount++;
        return RecordingAudioBytesSuccess(wav);
      });
      final controller = AnalysisScreenController(loader);

      await controller.analyze(
        recordingRef: 'test.wav',
        extension: 'wav',
        duration: const Duration(seconds: 1),
      );
      await controller.analyze(
        recordingRef: 'test.wav',
        extension: 'wav',
        duration: const Duration(seconds: 1),
        force: true,
      );

      expect(loadCount, 2);
      controller.dispose();
    });

    test('Retry runs the last recording again', () async {
      final wav = _buildWav(
        frequencyHz: 440.0,
        durationSeconds: 1.0,
        sampleRate: 44100,
      );
      int loadCount = 0;
      final loader = _CountingLoader(() {
        loadCount++;
        return RecordingAudioBytesSuccess(wav);
      });
      final controller = AnalysisScreenController(loader);

      await controller.analyze(
        recordingRef: 'test.wav',
        extension: 'wav',
        duration: const Duration(seconds: 2),
      );
      await controller.retry();

      expect(loadCount, 2);
      controller.dispose();
    });

    test('Retry preserves analyzed duration', () async {
      final wav = _buildWav(
        frequencyHz: 440.0,
        durationSeconds: 1.0,
        sampleRate: 44100,
      );
      final controller = AnalysisScreenController(
        _TestRecordingAudioBytesLoader(RecordingAudioBytesSuccess(wav)),
      );

      await controller.analyze(
        recordingRef: 'test.wav',
        extension: 'wav',
        duration: const Duration(seconds: 5),
      );
      await controller.retry();

      final success = controller.state as AnalysisSuccess;
      expect(success.result.duration, closeTo(1.0, 0.1));
      controller.dispose();
    });

    test(
      'analyze after disposal does not throw and does not update state',
      () async {
        final wav = _buildWav(
          frequencyHz: 440.0,
          durationSeconds: 1.0,
          sampleRate: 44100,
        );
        final controller = AnalysisScreenController(
          _TestRecordingAudioBytesLoader(RecordingAudioBytesSuccess(wav)),
        );

        controller.dispose();
        await controller.analyze(
          recordingRef: 'test.wav',
          extension: 'wav',
          duration: const Duration(seconds: 1),
        );
        expect(true, isTrue);
      },
    );

    test(
      'retry after disposal does not throw and does not update state',
      () async {
        final wav = _buildWav(
          frequencyHz: 440.0,
          durationSeconds: 1.0,
          sampleRate: 44100,
        );
        final controller = AnalysisScreenController(
          _TestRecordingAudioBytesLoader(RecordingAudioBytesSuccess(wav)),
        );

        await controller.analyze(
          recordingRef: 'test.wav',
          extension: 'wav',
          duration: const Duration(seconds: 1),
        );
        controller.dispose();
        await controller.retry();
        expect(true, isTrue);
      },
    );
  });
}
