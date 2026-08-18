import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_singing_coach/features/analysis/domain.dart';

void main() {
  group('NoteConverter Tests', () {
    test('A4 (440 Hz) maps to MIDI 69, A4, 0 cents', () {
      final note = NoteConverter.frequencyToNote(440.0);
      expect(note, isNotNull);
      expect(note!.midiNote, 69);
      expect(note.noteName, 'A');
      expect(note.octave, 4);
      expect(note.centsOffset.abs() < 1.0, isTrue);
    });

    test('A3 (220 Hz) maps to MIDI 57, A3, 0 cents', () {
      final note = NoteConverter.frequencyToNote(220.0);
      expect(note, isNotNull);
      expect(note!.midiNote, 57);
      expect(note.noteName, 'A');
      expect(note.octave, 3);
      expect(note.centsOffset.abs() < 1.0, isTrue);
    });

    test('A2 (110 Hz) maps to MIDI 45, A2, 0 cents', () {
      final note = NoteConverter.frequencyToNote(110.0);
      expect(note, isNotNull);
      expect(note!.midiNote, 45);
      expect(note.noteName, 'A');
      expect(note.octave, 2);
      expect(note.centsOffset.abs() < 1.0, isTrue);
    });

    test('C4 (261.63 Hz) maps to MIDI 60, C4, ~0 cents', () {
      final note = NoteConverter.frequencyToNote(261.63);
      expect(note, isNotNull);
      expect(note!.midiNote, 60);
      expect(note.noteName, 'C');
      expect(note.octave, 4);
      expect(note.centsOffset.abs() < 5.0, isTrue);
    });

    test('C5 (523.25 Hz) maps to MIDI 72, C5, ~0 cents', () {
      final note = NoteConverter.frequencyToNote(523.25);
      expect(note, isNotNull);
      expect(note!.midiNote, 72);
      expect(note.noteName, 'C');
      expect(note.octave, 5);
      expect(note.centsOffset.abs() < 5.0, isTrue);
    });

    test('Sharp frequency produces positive cents', () {
      // 440 * 2^(10/1200) ≈ 442.54 Hz (10 cents sharp)
      final sharpFreq = 440.0 * pow(2.0, 10.0 / 1200.0);
      final note = NoteConverter.frequencyToNote(sharpFreq);
      expect(note, isNotNull);
      expect(note!.centsOffset > 0, isTrue);
      expect((note.centsOffset - 10.0).abs() < 2.0, isTrue);
    });

    test('Flat frequency produces negative cents', () {
      // 440 * 2^(-10/1200) ≈ 437.48 Hz (10 cents flat)
      final flatFreq = 440.0 * pow(2.0, -10.0 / 1200.0);
      final note = NoteConverter.frequencyToNote(flatFreq);
      expect(note, isNotNull);
      expect(note!.centsOffset < 0, isTrue);
      expect((note.centsOffset + 10.0).abs() < 2.0, isTrue);
    });

    test('Invalid frequency returns null', () {
      expect(NoteConverter.frequencyToNote(0), isNull);
      expect(NoteConverter.frequencyToNote(-100), isNull);
      expect(NoteConverter.frequencyToNote(double.nan), isNull);
      expect(NoteConverter.frequencyToNote(double.infinity), isNull);
    });

    test('Note and octave conversion works across boundaries', () {
      // B3 (246.94 Hz) -> MIDI 59
      final b3 = NoteConverter.frequencyToNote(246.94);
      expect(b3!.noteName, 'B');
      expect(b3.octave, 3);

      // C4 (261.63 Hz) -> MIDI 60
      final c4 = NoteConverter.frequencyToNote(261.63);
      expect(c4!.noteName, 'C');
      expect(c4.octave, 4);

      // B4 (493.88 Hz) -> MIDI 71
      final b4 = NoteConverter.frequencyToNote(493.88);
      expect(b4!.noteName, 'B');
      expect(b4.octave, 4);

      // C5 (523.25 Hz) -> MIDI 72
      final c5 = NoteConverter.frequencyToNote(523.25);
      expect(c5!.noteName, 'C');
      expect(c5.octave, 5);
    });

    test('All 12 chromatic notes are supported', () {
      final notes = [
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
      for (int i = 0; i < 12; i++) {
        final midiNote = 60 + i; // C4 to B4
        final freq = NoteConverter.midiNoteToFrequency(midiNote);
        final note = NoteConverter.frequencyToNote(freq);
        expect(note, isNotNull, reason: 'Failed for ${notes[i]}');
        expect(note!.noteName, notes[i]);
        expect(note.midiNote, midiNote);
      }
    });

    test('MIDI to frequency round-trip', () {
      for (int midi = 21; midi <= 108; midi++) {
        final freq = NoteConverter.midiNoteToFrequency(midi);
        final note = NoteConverter.frequencyToNote(freq);
        expect(note, isNotNull);
        expect(note!.midiNote, midi);
      }
    });
  });
}
