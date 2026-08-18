import 'package:meta/meta.dart';

/// A single frame of pitch analysis.
@immutable
class PitchFrame {
  /// Timestamp of this frame relative to the start of the audio, in seconds.
  final double timestamp;

  /// Detected fundamental frequency in Hz. Null for unvoiced frames.
  final double? frequencyHz;

  /// MIDI note number (69 = A4). Null for unvoiced frames.
  final int? midiNote;

  /// Note name (e.g., 'A', 'A#', 'B', 'C'). Null for unvoiced frames.
  final String? noteName;

  /// Octave number (e.g., 4 for A4). Null for unvoiced frames.
  final int? octave;

  /// Cents offset from the nearest semitone.
  /// Negative = flat, positive = sharp. Null for unvoiced frames.
  final double? centsOffset;

  /// Confidence of the pitch detection (0.0 to 1.0).
  /// 0.0 for unvoiced frames.
  final double confidence;

  /// RMS energy level of this frame (0.0 to 1.0).
  final double rmsLevel;

  /// Whether this frame is considered voiced (has detectable pitch).
  final bool isVoiced;

  const PitchFrame({
    required this.timestamp,
    this.frequencyHz,
    this.midiNote,
    this.noteName,
    this.octave,
    this.centsOffset,
    required this.confidence,
    required this.rmsLevel,
    required this.isVoiced,
  });

  /// Creates an unvoiced frame.
  factory PitchFrame.unvoiced({
    required double timestamp,
    required double rmsLevel,
  }) {
    return PitchFrame(
      timestamp: timestamp,
      frequencyHz: null,
      midiNote: null,
      noteName: null,
      octave: null,
      centsOffset: null,
      confidence: 0.0,
      rmsLevel: rmsLevel,
      isVoiced: false,
    );
  }

  /// Creates a voiced frame.
  factory PitchFrame.voiced({
    required double timestamp,
    required double frequencyHz,
    required int midiNote,
    required String noteName,
    required int octave,
    required double centsOffset,
    required double confidence,
    required double rmsLevel,
  }) {
    return PitchFrame(
      timestamp: timestamp,
      frequencyHz: frequencyHz,
      midiNote: midiNote,
      noteName: noteName,
      octave: octave,
      centsOffset: centsOffset,
      confidence: confidence,
      rmsLevel: rmsLevel,
      isVoiced: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PitchFrame &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          frequencyHz == other.frequencyHz &&
          midiNote == other.midiNote &&
          noteName == other.noteName &&
          octave == other.octave &&
          centsOffset == other.centsOffset &&
          confidence == other.confidence &&
          rmsLevel == other.rmsLevel &&
          isVoiced == other.isVoiced;

  @override
  int get hashCode => Object.hash(
    timestamp,
    frequencyHz,
    midiNote,
    noteName,
    octave,
    centsOffset,
    confidence,
    rmsLevel,
    isVoiced,
  );

  @override
  String toString() =>
      'PitchFrame(timestamp: ${timestamp.toStringAsFixed(3)}s, '
      'frequencyHz: ${frequencyHz?.toStringAsFixed(1) ?? "unvoiced"}, '
      'note: ${noteName ?? "-"}#$octave, '
      'cents: ${centsOffset?.toStringAsFixed(1) ?? "-"}, '
      'confidence: ${confidence.toStringAsFixed(2)}, '
      'rms: ${rmsLevel.toStringAsFixed(3)}, '
      'voiced: $isVoiced)';
}
