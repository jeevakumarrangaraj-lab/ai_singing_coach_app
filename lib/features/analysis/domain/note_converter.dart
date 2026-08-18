import 'dart:math';
import 'package:meta/meta.dart';

/// Musical note conversion utilities.
///
/// Uses A4 = 440 Hz as the reference pitch.
class NoteConverter {
  static const double _a4Frequency = 440.0;
  static const int _a4MidiNote = 69;

  static const List<String> _noteNames = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  /// Converts frequency in Hz to MIDI note number.
  ///
  /// Returns null if frequency is not positive.
  static int? frequencyToMidiNote(double frequency) {
    if (frequency <= 0 || !frequency.isFinite) return null;
    return (_a4MidiNote + 12 * (log(frequency / _a4Frequency) / ln2)).round();
  }

  /// Converts frequency in Hz to cents offset from the nearest semitone.
  ///
  /// Returns null if frequency is not positive.
  /// Negative = flat, positive = sharp.
  static double? frequencyToCents(double frequency) {
    if (frequency <= 0 || !frequency.isFinite) return null;
    final exactMidi = _a4MidiNote + 12 * (log(frequency / _a4Frequency) / ln2);
    final nearestMidi = exactMidi.round();
    return (exactMidi - nearestMidi) * 100.0;
  }

  /// Converts MIDI note number to frequency in Hz.
  static double midiNoteToFrequency(int midiNote) {
    return _a4Frequency * pow(2.0, (midiNote - _a4MidiNote) / 12.0);
  }

  /// Gets the note name (e.g., 'C', 'C#', 'D') from a MIDI note number.
  static String noteNameFromMidi(int midiNote) {
    final noteIndex = ((midiNote % 12) + 12) % 12;
    return _noteNames[noteIndex];
  }

  /// Gets the octave number from a MIDI note number.
  ///
  /// MIDI note 60 (C4) = octave 4.
  static int octaveFromMidi(int midiNote) {
    return (midiNote / 12).floor() - 1;
  }

  /// Converts frequency to a complete note representation.
  ///
  /// Returns null if frequency is not positive.
  static NoteInfo? frequencyToNote(double frequency) {
    if (frequency <= 0 || !frequency.isFinite) return null;

    final midiNote = frequencyToMidiNote(frequency)!;
    final centsOffset = frequencyToCents(frequency)!;
    final noteName = noteNameFromMidi(midiNote);
    final octave = octaveFromMidi(midiNote);

    return NoteInfo(
      frequencyHz: frequency,
      midiNote: midiNote,
      noteName: noteName,
      octave: octave,
      centsOffset: centsOffset,
    );
  }
}

/// Complete note information derived from frequency.
@immutable
class NoteInfo {
  final double frequencyHz;
  final int midiNote;
  final String noteName;
  final int octave;
  final double centsOffset;

  const NoteInfo({
    required this.frequencyHz,
    required this.midiNote,
    required this.noteName,
    required this.octave,
    required this.centsOffset,
  });

  /// Display name like "A4" or "C#5".
  String get displayName => '$noteName$octave';

  /// Whether the note is sharp (positive cents) or flat (negative cents).
  String get intonationDescription {
    if (centsOffset.abs() < 5) return 'in tune';
    if (centsOffset > 0) return '${centsOffset.toStringAsFixed(1)}¢ sharp';
    return '${centsOffset.abs().toStringAsFixed(1)}¢ flat';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteInfo &&
          runtimeType == other.runtimeType &&
          frequencyHz == other.frequencyHz &&
          midiNote == other.midiNote &&
          noteName == other.noteName &&
          octave == other.octave &&
          centsOffset == other.centsOffset;

  @override
  int get hashCode =>
      Object.hash(frequencyHz, midiNote, noteName, octave, centsOffset);

  @override
  String toString() =>
      'NoteInfo($displayName, ${frequencyHz.toStringAsFixed(1)}Hz, ${centsOffset.toStringAsFixed(1)}¢)';
}
