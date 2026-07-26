import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/tuno_preferences.dart';

/// ─────────────────────────────────────────────────────────────
/// PREFERENCES CONTROLLER
/// ─────────────────────────────────────────────────────────────
///
/// Riverpod [StateNotifier] that manages all user-configurable
/// Tuno preferences and persists every value to SharedPreferences.
///
/// Follows the same pattern as [ThemeController] and
/// [NotificationController]:
///   - Immutable state ([TunoPreferences])
///   - Loads saved values on initialisation
///   - Persists on every change
///   - Disposal-guarded (prevents state-after-dispose errors)
///   - No [BuildContext] usage
///   - No temporary local widget state for persistence
/// ─────────────────────────────────────────────────────────────

class PreferencesController extends StateNotifier<TunoPreferences> {
  PreferencesController() : super(const TunoPreferences()) {
    _loadPreferences();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ── Initialisation ──────────────────────────────────────────

  /// Load all saved preferences from SharedPreferences.
  ///
  /// If a key is missing or the read fails, the safe default from
  /// [TunoPreferences] is kept.
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;

      state = TunoPreferences(
        defaultPracticeMode:
            prefs.getString(TunoPreferences.keyDefaultPracticeMode) ??
            PracticeMode.defaultValue,
        feedbackDetail:
            prefs.getString(TunoPreferences.keyFeedbackDetail) ??
            FeedbackDetail.defaultValue,
        countInBeforeRecording:
            prefs.getBool(TunoPreferences.keyCountIn) ?? true,
        automaticallySaveRecordings:
            prefs.getBool(TunoPreferences.keyAutoSave) ?? true,
        showHeadphoneRecommendation:
            prefs.getBool(TunoPreferences.keyHeadphoneRecommendation) ?? true,
        confirmBeforeDeleting:
            prefs.getBool(TunoPreferences.keyConfirmDelete) ?? true,
        reduceAnimations:
            prefs.getBool(TunoPreferences.keyReduceAnimations) ?? false,
      );
    } catch (e) {
      if (!_disposed) {
        debugPrint('PreferencesController._loadPreferences: $e');
      }
    }
  }

  // ── Persistence helper ──────────────────────────────────────

  /// Persist a single key-value pair to SharedPreferences.
  ///
  /// Failures are non-fatal and only logged in debug builds.
  Future<void> _persistString(String key, String value) async {
    if (_disposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('PreferencesController._persistString($key): $e');
    }
  }

  Future<void> _persistBool(String key, bool value) async {
    if (_disposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('PreferencesController._persistBool($key): $e');
    }
  }

  // ── Public API ──────────────────────────────────────────────

  /// Set the default practice mode.
  void setDefaultPracticeMode(String mode) {
    if (_disposed) return;
    if (!PracticeMode.values.contains(mode)) return;

    state = state.copyWith(defaultPracticeMode: mode);
    _persistString(TunoPreferences.keyDefaultPracticeMode, mode);
  }

  /// Set the feedback detail level.
  void setFeedbackDetail(String detail) {
    if (_disposed) return;
    if (!FeedbackDetail.values.contains(detail)) return;

    state = state.copyWith(feedbackDetail: detail);
    _persistString(TunoPreferences.keyFeedbackDetail, detail);
  }

  /// Toggle count-in before recording.
  void setCountInBeforeRecording(bool value) {
    if (_disposed) return;
    state = state.copyWith(countInBeforeRecording: value);
    _persistBool(TunoPreferences.keyCountIn, value);
  }

  /// Toggle automatically save completed recordings.
  void setAutomaticallySaveRecordings(bool value) {
    if (_disposed) return;
    state = state.copyWith(automaticallySaveRecordings: value);
    _persistBool(TunoPreferences.keyAutoSave, value);
  }

  /// Toggle headphone recommendation.
  void setShowHeadphoneRecommendation(bool value) {
    if (_disposed) return;
    state = state.copyWith(showHeadphoneRecommendation: value);
    _persistBool(TunoPreferences.keyHeadphoneRecommendation, value);
  }

  /// Toggle confirm-before-deleting.
  void setConfirmBeforeDeleting(bool value) {
    if (_disposed) return;
    state = state.copyWith(confirmBeforeDeleting: value);
    _persistBool(TunoPreferences.keyConfirmDelete, value);
  }

  /// Toggle reduce-animations.
  void setReduceAnimations(bool value) {
    if (_disposed) return;
    state = state.copyWith(reduceAnimations: value);
    _persistBool(TunoPreferences.keyReduceAnimations, value);
  }
}

/// ─────────────────────────────────────────────────────────────
/// PROVIDER
/// ─────────────────────────────────────────────────────────────

/// Riverpod provider exposing [PreferencesController] and its
/// current [TunoPreferences] state.
///
/// Usage:
/// ```dart
/// final prefs = ref.watch(preferencesControllerProvider);
/// final practiceMode = prefs.defaultPracticeMode;
/// ```
final preferencesControllerProvider =
    StateNotifierProvider<PreferencesController, TunoPreferences>((ref) {
      return PreferencesController();
    });
