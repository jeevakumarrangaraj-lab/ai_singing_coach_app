import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/notification_preferences.dart';

/// ─────────────────────────────────────────────────────────────
/// NOTIFICATION PREFERENCES CONTROLLER
/// ─────────────────────────────────────────────────────────────
///
/// Riverpod [StateNotifier] that manages all notification preference
/// values and persists every value to SharedPreferences.
///
/// Follows the same pattern as [PreferencesController] and
/// [AudioVideoController]:
///   - Immutable state ([NotificationPreferences])
///   - Loads saved values on initialisation
///   - Persists on every change
///   - Disposal-guarded (prevents state-after-dispose errors)
///   - No [BuildContext] usage
///   - No temporary local widget state for persistence
/// ─────────────────────────────────────────────────────────────

class NotificationPreferencesController
    extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesController() : super(const NotificationPreferences()) {
    _loadPreferences();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ── Initialisation ──────────────────────────────────────────

  /// Load all saved notification preferences from SharedPreferences.
  ///
  /// If a key is missing or the read fails, the safe default from
  /// [NotificationPreferences] is kept.
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;

      state = NotificationPreferences(
        allowNotifications:
            prefs.getBool(NotificationPreferences.keyAllowNotifications) ??
            false,
        practiceReminders:
            prefs.getBool(NotificationPreferences.keyPracticeReminders) ?? true,
        aiAnalysisUpdates:
            prefs.getBool(NotificationPreferences.keyAiAnalysisUpdates) ?? true,
        streakReminders:
            prefs.getBool(NotificationPreferences.keyStreakReminders) ?? true,
        coinsAchievements:
            prefs.getBool(NotificationPreferences.keyCoinsAchievements) ?? true,
        weeklyChallenges:
            prefs.getBool(NotificationPreferences.keyWeeklyChallenges) ?? true,
        productUpdates:
            prefs.getBool(NotificationPreferences.keyProductUpdates) ?? false,
        reminderHour:
            prefs.getInt(NotificationPreferences.keyReminderTimeHour) ?? 10,
        reminderMinute:
            prefs.getInt(NotificationPreferences.keyReminderTimeMinute) ?? 0,
      );
    } catch (e) {
      if (!_disposed) {
        debugPrint('NotificationPreferencesController._loadPreferences: $e');
      }
    }
  }

  // ── Persistence helpers ──────────────────────────────────────

  Future<void> _persistBool(String key, bool value) async {
    if (_disposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('NotificationPreferencesController._persistBool($key): $e');
    }
  }

  Future<void> _persistInt(String key, int value) async {
    if (_disposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } catch (e) {
      debugPrint('NotificationPreferencesController._persistInt($key): $e');
    }
  }

  // ── Public API ──────────────────────────────────────────────

  /// Set the master "Allow Notifications" toggle.
  ///
  /// When turning ON, and no delivery infrastructure exists,
  /// the UI should show an informational banner (handled in the screen).
  void setAllowNotifications(bool value) {
    if (_disposed) return;
    state = state.copyWith(allowNotifications: value);
    _persistBool(NotificationPreferences.keyAllowNotifications, value);
  }

  /// Toggle practice reminders.
  void setPracticeReminders(bool value) {
    if (_disposed) return;
    state = state.copyWith(practiceReminders: value);
    _persistBool(NotificationPreferences.keyPracticeReminders, value);
  }

  /// Toggle AI analysis updates.
  void setAiAnalysisUpdates(bool value) {
    if (_disposed) return;
    state = state.copyWith(aiAnalysisUpdates: value);
    _persistBool(NotificationPreferences.keyAiAnalysisUpdates, value);
  }

  /// Toggle streak reminders.
  void setStreakReminders(bool value) {
    if (_disposed) return;
    state = state.copyWith(streakReminders: value);
    _persistBool(NotificationPreferences.keyStreakReminders, value);
  }

  /// Toggle coins & achievements.
  void setCoinsAchievements(bool value) {
    if (_disposed) return;
    state = state.copyWith(coinsAchievements: value);
    _persistBool(NotificationPreferences.keyCoinsAchievements, value);
  }

  /// Toggle weekly challenges.
  void setWeeklyChallenges(bool value) {
    if (_disposed) return;
    state = state.copyWith(weeklyChallenges: value);
    _persistBool(NotificationPreferences.keyWeeklyChallenges, value);
  }

  /// Toggle product updates.
  void setProductUpdates(bool value) {
    if (_disposed) return;
    state = state.copyWith(productUpdates: value);
    _persistBool(NotificationPreferences.keyProductUpdates, value);
  }

  /// Set the reminder time.
  void setReminderTime({required int hour, required int minute}) {
    if (_disposed) return;
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    _persistInt(NotificationPreferences.keyReminderTimeHour, hour);
    _persistInt(NotificationPreferences.keyReminderTimeMinute, minute);
  }
}

/// ─────────────────────────────────────────────────────────────
/// PROVIDER
/// ─────────────────────────────────────────────────────────────

/// Riverpod provider exposing [NotificationPreferencesController]
/// and its current [NotificationPreferences] state.
///
/// Usage:
/// ```dart
/// final prefs = ref.watch(notificationPreferencesControllerProvider);
/// final allow = prefs.allowNotifications;
/// ```
final notificationPreferencesControllerProvider =
    StateNotifierProvider<
      NotificationPreferencesController,
      NotificationPreferences
    >((ref) {
      return NotificationPreferencesController();
    });
