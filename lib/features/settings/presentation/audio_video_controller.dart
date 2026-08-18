import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/audio_video_preferences.dart';

/// ─────────────────────────────────────────────────────────────
/// AUDIO & VIDEO CONTROLLER
/// ─────────────────────────────────────────────────────────────
///
/// Riverpod [StateNotifier] that manages all user-configurable
/// Audio & Video preferences and persists every value to SharedPreferences.
///
/// Follows the same pattern as [ThemeController] and
/// [PreferencesController]:
///   - Immutable state ([AudioVideoPreferences])
///   - Loads saved values on initialisation
///   - Persists on every change
///   - Disposal-guarded (prevents state-after-dispose errors)
///   - No [BuildContext] usage
///   - No temporary local widget state for persistence
/// ─────────────────────────────────────────────────────────────

class AudioVideoController extends StateNotifier<AudioVideoPreferences> {
  AudioVideoController() : super(const AudioVideoPreferences()) {
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
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;

      state = AudioVideoPreferences(
        defaultRecordingType:
            prefs.getString(AudioVideoPreferences.keyDefaultRecordingType) ??
            RecordingType.defaultValue,
        audioQuality:
            prefs.getString(AudioVideoPreferences.keyAudioQuality) ??
            AudioQuality.defaultValue,
        noiseReduction:
            prefs.getBool(AudioVideoPreferences.keyNoiseReduction) ?? true,
        countdownBeforeRecording:
            prefs.getBool(AudioVideoPreferences.keyCountdownBeforeRecording) ??
            true,
        autoPlayRecording:
            prefs.getBool(AudioVideoPreferences.keyAutoPlayRecording) ?? true,
        headphonesReminder:
            prefs.getBool(AudioVideoPreferences.keyHeadphonesReminder) ?? true,
      );
    } catch (e) {
      if (!_disposed) {
        debugPrint('AudioVideoController._loadPreferences: $e');
      }
    }
  }

  // ── Persistence helpers ──────────────────────────────────────

  Future<void> _persistString(String key, String value) async {
    if (_disposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('AudioVideoController._persistString($key): $e');
    }
  }

  Future<void> _persistBool(String key, bool value) async {
    if (_disposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('AudioVideoController._persistBool($key): $e');
    }
  }

  // ── Public API ──────────────────────────────────────────────

  /// Set the default recording type.
  void setDefaultRecordingType(String type) {
    if (_disposed) return;
    if (!RecordingType.values.contains(type)) return;

    state = state.copyWith(defaultRecordingType: type);
    _persistString(AudioVideoPreferences.keyDefaultRecordingType, type);
  }

  /// Set the audio quality.
  void setAudioQuality(String quality) {
    if (_disposed) return;
    if (!AudioQuality.values.contains(quality)) return;

    state = state.copyWith(audioQuality: quality);
    _persistString(AudioVideoPreferences.keyAudioQuality, quality);
  }

  /// Toggle noise reduction.
  void setNoiseReduction(bool value) {
    if (_disposed) return;
    state = state.copyWith(noiseReduction: value);
    _persistBool(AudioVideoPreferences.keyNoiseReduction, value);
  }

  /// Toggle countdown before recording.
  void setCountdownBeforeRecording(bool value) {
    if (_disposed) return;
    state = state.copyWith(countdownBeforeRecording: value);
    _persistBool(AudioVideoPreferences.keyCountdownBeforeRecording, value);
  }

  /// Toggle auto-play recording after capture.
  void setAutoPlayRecording(bool value) {
    if (_disposed) return;
    state = state.copyWith(autoPlayRecording: value);
    _persistBool(AudioVideoPreferences.keyAutoPlayRecording, value);
  }

  /// Toggle use-headphones reminder.
  void setHeadphonesReminder(bool value) {
    if (_disposed) return;
    state = state.copyWith(headphonesReminder: value);
    _persistBool(AudioVideoPreferences.keyHeadphonesReminder, value);
  }
}

/// ─────────────────────────────────────────────────────────────
/// PROVIDER
/// ─────────────────────────────────────────────────────────────

/// Riverpod provider exposing [AudioVideoController] and its
/// current [AudioVideoPreferences] state.
final audioVideoControllerProvider =
    StateNotifierProvider<AudioVideoController, AudioVideoPreferences>((ref) {
      return AudioVideoController();
    });
