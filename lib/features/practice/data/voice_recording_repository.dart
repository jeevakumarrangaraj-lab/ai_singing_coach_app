import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

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
    final status = await Permission.microphone.status;
    return status.isGranted;
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
      if (await hasPermission()) {
        final path = await _getRecordingPath();
        await _recorder.start(
          RecordConfig(
            encoder: encoder,
            sampleRate: sampleRate,
            numChannels: 1,
          ),
          path: path,
        );
        return path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> stopRecording() async {
    try {
      return await _recorder.stop();
    } catch (e) {
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

  Future<String> _getRecordingPath() async {
    final directory = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/recording_$timestamp.wav';
  }
}