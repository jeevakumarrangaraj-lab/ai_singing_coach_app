import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/recording_audio_bytes_loader.dart';
import '../data/recording_audio_bytes_loader_impl.dart';
import '../domain/audio_decoding_service.dart';
import '../domain/pitch_analysis_result.dart';
import '../domain/pitch_analysis_service.dart';
import '../domain/recording_pitch_analysis_service.dart';

/// State for the pitch analysis screen.
sealed class AnalysisScreenState {
  const AnalysisScreenState();
}

/// Analysis has not started.
class AnalysisIdle extends AnalysisScreenState {
  const AnalysisIdle();
}

/// Analysis is currently running.
class AnalysisLoading extends AnalysisScreenState {
  const AnalysisLoading();
}

/// Analysis completed successfully.
class AnalysisSuccess extends AnalysisScreenState {
  final PitchAnalysisResult result;

  const AnalysisSuccess(this.result);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisSuccess && result == other.result;

  @override
  int get hashCode => result.hashCode;
}

/// No clear voice was detected.
class AnalysisNoVoiceDetected extends AnalysisScreenState {
  final Duration duration;

  const AnalysisNoVoiceDetected(this.duration);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisNoVoiceDetected && duration == other.duration;

  @override
  int get hashCode => duration.hashCode;
}

/// The recording format cannot currently be analyzed.
class AnalysisUnsupportedFormat extends AnalysisScreenState {
  final String reason;

  const AnalysisUnsupportedFormat(this.reason);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisUnsupportedFormat && reason == other.reason;

  @override
  int get hashCode => reason.hashCode;
}

/// The recording file could not be found.
class AnalysisFileNotFound extends AnalysisScreenState {
  const AnalysisFileNotFound();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AnalysisFileNotFound;

  @override
  int get hashCode => 0;
}

/// Pitch analysis failed.
class AnalysisFailed extends AnalysisScreenState {
  final String message;

  const AnalysisFailed(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisFailed && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Controls pitch analysis for the Analysis Result screen.
class AnalysisScreenController extends StateNotifier<AnalysisScreenState> {
  final RecordingAudioBytesLoader _bytesLoader;

  bool _isDisposed = false;
  bool _isAnalyzing = false;

  String? _currentRecordingRef;
  String? _currentExtension;
  Duration? _currentDuration;

  AnalysisScreenController(this._bytesLoader) : super(const AnalysisIdle());

  /// Starts analysis for the supplied recording.
  ///
  /// Duplicate concurrent requests are ignored. Set [force] to true when the
  /// user explicitly requests a retry.
  Future<void> analyze({
    required String recordingRef,
    required String extension,
    required Duration duration,
    bool force = false,
  }) async {
    if (_isDisposed || _isAnalyzing) {
      return;
    }

    if (recordingRef.trim().isEmpty) {
      state = const AnalysisFileNotFound();
      return;
    }

    final isSameRecording =
        _currentRecordingRef == recordingRef && _currentExtension == extension;

    final alreadyCompleted =
        state is AnalysisSuccess || state is AnalysisNoVoiceDetected;

    if (!force && isSameRecording && alreadyCompleted) {
      return;
    }

    _isAnalyzing = true;
    _currentRecordingRef = recordingRef;
    _currentExtension = extension;
    _currentDuration = duration;

    state = const AnalysisLoading();

    try {
      final loadResult = await _bytesLoader.loadBytes(
        recordingRef: recordingRef,
        extension: extension,
      );

      if (_isDisposed) {
        return;
      }

      switch (loadResult) {
        case RecordingAudioBytesFileNotFound():
          state = const AnalysisFileNotFound();
          return;

        case RecordingAudioBytesUnreadable(:final reason):
          state = AnalysisFailed('Could not read audio file: $reason');
          return;

        case RecordingAudioBytesUnsupportedFormat(:final reason):
          state = AnalysisUnsupportedFormat(reason);
          return;

        case RecordingAudioBytesSuccess(:final bytes):
          final result = await compute(_analyzeWavInBackground, bytes);

          if (_isDisposed) {
            return;
          }

          _handleAnalysisResult(result, duration);
          return;
      }
    } on AudioDecodingException catch (error) {
      if (_isDisposed) {
        return;
      }

      state = AnalysisFailed('Invalid audio format: ${error.message}');
    } on PitchAnalysisException catch (error) {
      if (_isDisposed) {
        return;
      }

      state = AnalysisFailed('Analysis failed: ${error.message}');
    } catch (error, stackTrace) {
      if (_isDisposed) {
        return;
      }

      debugPrint('AnalysisScreenController error: $error');
      debugPrintStack(stackTrace: stackTrace);

      state = const AnalysisFailed('Unexpected error during analysis');
    } finally {
      _isAnalyzing = false;
    }
  }

  /// Retries analysis for the most recently supplied recording.
  Future<void> retry() async {
    final recordingRef = _currentRecordingRef;
    final extension = _currentExtension;
    final duration = _currentDuration;

    if (recordingRef == null || extension == null || duration == null) {
      return;
    }

    await analyze(
      recordingRef: recordingRef,
      extension: extension,
      duration: duration,
      force: true,
    );
  }

  void _handleAnalysisResult(
    PitchAnalysisResult result,
    Duration fallbackDuration,
  ) {
    if (_isDisposed) {
      return;
    }

    if (result.voicedFrames == 0) {
      final analyzedDuration = result.duration > 0
          ? Duration(milliseconds: (result.duration * 1000).round())
          : fallbackDuration;

      state = AnalysisNoVoiceDetected(analyzedDuration);
      return;
    }

    state = AnalysisSuccess(result);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

/// Runs WAV decoding and pitch detection outside the UI isolate.
PitchAnalysisResult _analyzeWavInBackground(Uint8List wavBytes) {
  final service = RecordingPitchAnalysisService();
  return service.analyzeWav(wavBytes);
}

/// Platform-specific recording byte loader.
final recordingAudioBytesLoaderProvider = Provider<RecordingAudioBytesLoader>((
  ref,
) {
  return RecordingAudioBytesLoaderImpl();
});

/// Pitch-analysis state controller.
final analysisScreenControllerProvider =
    StateNotifierProvider<AnalysisScreenController, AnalysisScreenState>((ref) {
      final bytesLoader = ref.watch(recordingAudioBytesLoaderProvider);
      return AnalysisScreenController(bytesLoader);
    });
