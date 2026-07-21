import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:flutter/foundation.dart';

import 'recording_path.dart';

abstract class VoiceRecordingRepository {
  Future<bool> hasPermission();

  Future<bool> requestPermission();

  Future<String?> startRecording({
    required AudioEncoder encoder,
    required int sampleRate,
  });

  Future<String?> stopRecording();

  Future<void> dispose();

  Future<bool> isRecording();

  Future<int> getAmplitude();
}

class VoiceRecordingRepositoryImpl implements VoiceRecordingRepository {
  final AudioRecorder _recorder = AudioRecorder();

  @override
  Future<bool> hasPermission() async {
    // Prefer record's browser-compatible permission check.
    try {
      return await _recorder.hasPermission();
    } catch (_) {
      final status = await Permission.microphone.status;
      return status.isGranted;
    }
  }

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<String?> startRecording({
    required AudioEncoder encoder,
    required int sampleRate,
  }) async {
    try {
      final permissionGranted = await hasPermission();
      if (!permissionGranted) {
        return null;
      }

      final selectedEncoder = await _selectSupportedEncoder(encoder);
      final path = await createRecordingPath();

      await _recorder.start(
        RecordConfig(
          encoder: selectedEncoder,
          sampleRate: sampleRate,
          numChannels: 1,
        ),
        path: path,
      );

      final started = await _recorder.isRecording();
      if (!started) return null;

      return path;
    } catch (error, stackTrace) {
      debugPrint('Recording start failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<AudioEncoder> _selectSupportedEncoder(AudioEncoder requested) async {
    final wavSupported = await _recorder.isEncoderSupported(AudioEncoder.wav);
    if (requested == AudioEncoder.wav) {
      if (wavSupported) return AudioEncoder.wav;
      // Web often doesn't support wav; fall back to opus.
      return AudioEncoder.opus;
    }

    // If the caller asked for opus, keep it (and only fall back if unsupported).
    final opusSupported = await _recorder.isEncoderSupported(AudioEncoder.opus);
    if (requested == AudioEncoder.opus) {
      return opusSupported
          ? AudioEncoder.opus
          : (wavSupported ? AudioEncoder.wav : AudioEncoder.opus);
    }

    return requested;
  }

  @override
  Future<String?> stopRecording() async {
    try {
      return await _recorder.stop();
    } catch (error, stackTrace) {
      debugPrint('Recording stop failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    await _recorder.dispose();
  }

  @override
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  @override
  Future<int> getAmplitude() async {
    try {
      final amplitude = await _recorder.getAmplitude();
      return amplitude.current.toInt();
    } catch (e) {
      return 0;
    }
  }
}
