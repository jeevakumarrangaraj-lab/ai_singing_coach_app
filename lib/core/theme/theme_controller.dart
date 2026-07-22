import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent, reactive theme mode controller.
///
/// Saves the user's choice (system / light / dark) to SharedPreferences
/// under the key `tuno_theme_mode` and restores it on every app start.
///
/// - Default value: [ThemeMode.system]
/// - Stored values: `'system'`, `'light'`, `'dark'`
/// - Invalid or missing stored values fall back to [ThemeMode.system]
/// - Storage failures are debug-printed and do **not** crash the app
/// - No [BuildContext] is used anywhere
/// - All state mutations are guarded by a disposal flag
class ThemeController extends StateNotifier<ThemeMode> {
  /// Storage key used to persist the theme mode.
  static const String _storageKey = 'tuno_theme_mode';

  ThemeController() : super(ThemeMode.system) {
    _loadSavedMode();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ── Initialisation ──────────────────────────────────────────

  /// Load the persisted [ThemeMode] from SharedPreferences.
  ///
  /// Runs asynchronously after construction. If the stored value is absent,
  /// invalid or the read fails, the default [ThemeMode.system] is kept.
  Future<void> _loadSavedMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (_disposed) return;

      final mode = _parseStoredValue(raw);
      if (mode != null) {
        state = mode;
      }
      // `null` means invalid/missing → keep default state (ThemeMode.system)
    } catch (e) {
      // Storage failure – keep current default, log in debug builds only.
      if (!_disposed) {
        debugPrint('ThemeController._loadSavedMode: $e');
      }
    }
  }

  // ── Public API ──────────────────────────────────────────────

  /// Set the theme mode and persist the choice.
  ///
  /// The UI state is updated immediately. The value is saved asynchronously.
  /// If persistence fails the selected mode *is still retained* for the
  /// current session; only the stored preference may be lost.
  void setThemeMode(ThemeMode mode) {
    if (_disposed) return;

    state = mode;
    _persistMode(mode);
  }

  // ── Internals ───────────────────────────────────────────────

  /// Persist [mode] to SharedPreferences. Failures are non-fatal.
  Future<void> _persistMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, _modeToStoredValue(mode));
    } catch (e) {
      // Log only in debug builds – the in-memory state is kept either way.
      debugPrint('ThemeController._persistMode: $e');
    }
  }

  /// Convert a stored string to a [ThemeMode].
  ///
  /// Returns `null` when the value is absent or unrecognised so callers
  /// can fall back to the default ([ThemeMode.system]).
  static ThemeMode? _parseStoredValue(String? raw) {
    if (raw == null) return null;

    switch (raw) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return null; // invalid stored value
    }
  }

  /// Convert a [ThemeMode] to the stored string representation.
  static String _modeToStoredValue(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}

/// Provider that exposes the [ThemeController] and its current [ThemeMode].
///
/// Used by the UI to read the theme mode and by [SingingCoachApp] to set the
/// active theme on [MaterialApp].
final themeModeProvider = StateNotifierProvider<ThemeController, ThemeMode>((
  ref,
) {
  return ThemeController();
});
