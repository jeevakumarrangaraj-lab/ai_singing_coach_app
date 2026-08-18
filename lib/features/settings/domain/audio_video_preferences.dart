/// ─────────────────────────────────────────────────────────────
/// AUDIO & VIDEO PREFERENCES – IMMUTABLE STATE MODEL
/// ─────────────────────────────────────────────────────────────
///
/// Holds all user-configurable audio/video settings for the Tuno app.
/// Each field has a corresponding SharedPreferences key used for
/// persistence.
///
/// Safe defaults are used when no stored value exists.
///
/// Design:
///   - Fully immutable (copyWith pattern)
///   - All fields non-nullable
///   - Persistence keys are static constants
///   - No BuildContext, no widget dependencies
/// ─────────────────────────────────────────────────────────────
library;

/// Sealed set of valid audio quality strings.
class AudioQuality {
  static const String standard = 'standard';
  static const String high = 'high';

  static const List<String> values = [standard, high];

  static String label(String quality) {
    switch (quality) {
      case standard:
        return 'Standard';
      case high:
        return 'High';
      default:
        return quality;
    }
  }

  static const String defaultValue = standard;
}

/// Sealed set of valid recording type strings.
class RecordingType {
  static const String audio = 'audio';
  static const String video = 'video';

  static const List<String> values = [audio, video];

  static String label(String type) {
    switch (type) {
      case audio:
        return 'Audio';
      case video:
        return 'Video';
      default:
        return type;
    }
  }

  static const String defaultValue = audio;
}

/// ─────────────────────────────────────────────────────────────
/// IMMUTABLE AUDIO/VIDEO PREFERENCES STATE
/// ─────────────────────────────────────────────────────────────

class AudioVideoPreferences {
  // ── SharedPreferences keys ──────────────────────────────────

  static const String keyDefaultRecordingType = 'tuno_pref_recording_type';
  static const String keyAudioQuality = 'tuno_pref_audio_quality';
  static const String keyNoiseReduction = 'tuno_pref_noise_reduction';
  static const String keyCountdownBeforeRecording =
      'tuno_pref_countdown_before_recording';
  static const String keyAutoPlayRecording = 'tuno_pref_auto_play_recording';
  static const String keyHeadphonesReminder = 'tuno_pref_headphones_reminder';

  // ── Fields ──────────────────────────────────────────────────

  /// Default recording type (audio or video).
  final String defaultRecordingType;

  /// Audio quality level.
  final String audioQuality;

  /// Whether noise reduction is enabled.
  final bool noiseReduction;

  /// Whether to show a countdown before recording starts.
  final bool countdownBeforeRecording;

  /// Whether to auto-play recording after capture.
  final bool autoPlayRecording;

  /// Whether to show a use-headphones reminder.
  final bool headphonesReminder;

  /// ── Constructor with safe defaults ─────────────────────────

  const AudioVideoPreferences({
    this.defaultRecordingType = RecordingType.defaultValue,
    this.audioQuality = AudioQuality.defaultValue,
    this.noiseReduction = true,
    this.countdownBeforeRecording = true,
    this.autoPlayRecording = true,
    this.headphonesReminder = true,
  });

  /// ── copyWith ───────────────────────────────────────────────

  AudioVideoPreferences copyWith({
    String? defaultRecordingType,
    String? audioQuality,
    bool? noiseReduction,
    bool? countdownBeforeRecording,
    bool? autoPlayRecording,
    bool? headphonesReminder,
  }) {
    return AudioVideoPreferences(
      defaultRecordingType: defaultRecordingType ?? this.defaultRecordingType,
      audioQuality: audioQuality ?? this.audioQuality,
      noiseReduction: noiseReduction ?? this.noiseReduction,
      countdownBeforeRecording:
          countdownBeforeRecording ?? this.countdownBeforeRecording,
      autoPlayRecording: autoPlayRecording ?? this.autoPlayRecording,
      headphonesReminder: headphonesReminder ?? this.headphonesReminder,
    );
  }

  /// ── JSON/Map (for debugging) ───────────────────────────────

  Map<String, dynamic> toMap() => {
    keyDefaultRecordingType: defaultRecordingType,
    keyAudioQuality: audioQuality,
    keyNoiseReduction: noiseReduction,
    keyCountdownBeforeRecording: countdownBeforeRecording,
    keyAutoPlayRecording: autoPlayRecording,
    keyHeadphonesReminder: headphonesReminder,
  };

  @override
  String toString() => 'AudioVideoPreferences${toMap()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioVideoPreferences &&
          runtimeType == other.runtimeType &&
          defaultRecordingType == other.defaultRecordingType &&
          audioQuality == other.audioQuality &&
          noiseReduction == other.noiseReduction &&
          countdownBeforeRecording == other.countdownBeforeRecording &&
          autoPlayRecording == other.autoPlayRecording &&
          headphonesReminder == other.headphonesReminder;

  @override
  int get hashCode => Object.hash(
    defaultRecordingType,
    audioQuality,
    noiseReduction,
    countdownBeforeRecording,
    autoPlayRecording,
    headphonesReminder,
  );
}
