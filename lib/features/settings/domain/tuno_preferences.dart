/// ─────────────────────────────────────────────────────────────
/// TUNO PREFERENCES – IMMUTABLE STATE MODEL
/// ─────────────────────────────────────────────────────────────
///
/// Holds all user-configurable preference values for the Tuno app.
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

/// Sealed set of valid practice mode strings.
///
/// These values map to what is stored/loaded from SharedPreferences.
class PracticeMode {
  static const String soloPractice = 'solo_practice';
  static const String tunoExercises = 'tuno_exercises';
  static const String uploadSong = 'upload_song';
  static const String backingTrack = 'backing_track';

  /// All valid options.
  static const List<String> values = [
    soloPractice,
    tunoExercises,
    uploadSong,
    backingTrack,
  ];

  /// Default practice mode.
  static const String defaultValue = soloPractice;
}

/// Sealed set of valid feedback-detail strings.
class FeedbackDetail {
  static const String simple = 'simple';
  static const String detailed = 'detailed';

  static const List<String> values = [simple, detailed];

  static const String defaultValue = simple;
}

/// ─────────────────────────────────────────────────────────────
/// IMMUTABLE PREFERENCES STATE
/// ─────────────────────────────────────────────────────────────

class TunoPreferences {
  // ── SharedPreferences keys ──────────────────────────────────

  static const String keyDefaultPracticeMode = 'tuno_pref_practice_mode';
  static const String keyFeedbackDetail = 'tuno_pref_feedback_detail';
  static const String keyCountIn = 'tuno_pref_count_in';
  static const String keyAutoSave = 'tuno_pref_auto_save';
  static const String keyHeadphoneRecommendation =
      'tuno_pref_headphone_recommendation';
  static const String keyConfirmDelete = 'tuno_pref_confirm_delete';
  static const String keyReduceAnimations = 'tuno_pref_reduce_animations';

  // ── Fields ──────────────────────────────────────────────────

  /// Default practice mode (one of [PracticeMode.values]).
  final String defaultPracticeMode;

  /// Level of coaching feedback detail.
  final String feedbackDetail;

  /// Whether to play a count-in before recording starts.
  final bool countInBeforeRecording;

  /// Whether to automatically save completed recordings.
  final bool automaticallySaveRecordings;

  /// Whether to show a headphone recommendation reminder.
  final bool showHeadphoneRecommendation;

  /// Whether to show a confirmation dialog before deleting a recording.
  final bool confirmBeforeDeleting;

  /// Whether to reduce UI animation intensity.
  final bool reduceAnimations;

  /// ── Constructor with safe defaults ─────────────────────────

  const TunoPreferences({
    this.defaultPracticeMode = PracticeMode.defaultValue,
    this.feedbackDetail = FeedbackDetail.defaultValue,
    this.countInBeforeRecording = true,
    this.automaticallySaveRecordings = true,
    this.showHeadphoneRecommendation = true,
    this.confirmBeforeDeleting = true,
    this.reduceAnimations = false,
  });

  /// ── copyWith ───────────────────────────────────────────────

  TunoPreferences copyWith({
    String? defaultPracticeMode,
    String? feedbackDetail,
    bool? countInBeforeRecording,
    bool? automaticallySaveRecordings,
    bool? showHeadphoneRecommendation,
    bool? confirmBeforeDeleting,
    bool? reduceAnimations,
  }) {
    return TunoPreferences(
      defaultPracticeMode: defaultPracticeMode ?? this.defaultPracticeMode,
      feedbackDetail: feedbackDetail ?? this.feedbackDetail,
      countInBeforeRecording:
          countInBeforeRecording ?? this.countInBeforeRecording,
      automaticallySaveRecordings:
          automaticallySaveRecordings ?? this.automaticallySaveRecordings,
      showHeadphoneRecommendation:
          showHeadphoneRecommendation ?? this.showHeadphoneRecommendation,
      confirmBeforeDeleting:
          confirmBeforeDeleting ?? this.confirmBeforeDeleting,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
    );
  }

  /// ── JSON/Map (for debugging) ───────────────────────────────

  Map<String, dynamic> toMap() => {
    keyDefaultPracticeMode: defaultPracticeMode,
    keyFeedbackDetail: feedbackDetail,
    keyCountIn: countInBeforeRecording,
    keyAutoSave: automaticallySaveRecordings,
    keyHeadphoneRecommendation: showHeadphoneRecommendation,
    keyConfirmDelete: confirmBeforeDeleting,
    keyReduceAnimations: reduceAnimations,
  };

  @override
  String toString() => 'TunoPreferences${toMap()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TunoPreferences &&
          runtimeType == other.runtimeType &&
          defaultPracticeMode == other.defaultPracticeMode &&
          feedbackDetail == other.feedbackDetail &&
          countInBeforeRecording == other.countInBeforeRecording &&
          automaticallySaveRecordings == other.automaticallySaveRecordings &&
          showHeadphoneRecommendation == other.showHeadphoneRecommendation &&
          confirmBeforeDeleting == other.confirmBeforeDeleting &&
          reduceAnimations == other.reduceAnimations;

  @override
  int get hashCode => Object.hash(
    defaultPracticeMode,
    feedbackDetail,
    countInBeforeRecording,
    automaticallySaveRecordings,
    showHeadphoneRecommendation,
    confirmBeforeDeleting,
    reduceAnimations,
  );
}
