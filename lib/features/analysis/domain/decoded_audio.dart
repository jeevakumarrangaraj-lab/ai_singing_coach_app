import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Represents decoded PCM audio data with metadata.
///
/// Used as the intermediate format between audio file decoders and pitch analysis.
@immutable
class DecodedAudio {
  /// PCM samples normalized to the range [-1.0, 1.0].
  /// Always mono (single channel).
  final Float32List samples;

  /// Sample rate in Hz (e.g., 44100, 48000).
  final int sampleRate;

  /// Number of channels in the decoded audio (always 1 for mono output).
  final int channels;

  /// Duration of the audio in seconds.
  final Duration duration;

  const DecodedAudio({
    required this.samples,
    required this.sampleRate,
    required this.channels,
    required this.duration,
  });

  /// Number of samples in the buffer.
  int get sampleCount => samples.length;

  /// Duration in seconds as a double.
  double get durationSeconds => duration.inMicroseconds / 1_000_000.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecodedAudio &&
          runtimeType == other.runtimeType &&
          samples.length == other.samples.length &&
          sampleRate == other.sampleRate &&
          channels == other.channels &&
          duration == other.duration;

  @override
  int get hashCode =>
      samples.length.hashCode ^
      sampleRate.hashCode ^
      channels.hashCode ^
      duration.hashCode;

  @override
  String toString() =>
      'DecodedAudio(samples: ${samples.length}, sampleRate: $sampleRate Hz, '
      'channels: $channels, duration: ${duration.inMilliseconds}ms)';
}
