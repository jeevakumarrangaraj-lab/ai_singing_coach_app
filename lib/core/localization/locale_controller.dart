import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

/// Persistent, reactive application language controller.
///
/// Saves the user's language choice to SharedPreferences under the key
/// `tuno_app_locale` and restores it on every app start.
///
/// - Default value: [AppLanguage.system]
/// - Stored values: `'system'`, `'en'`, `'ta'`, `'hi'`
/// - Invalid or missing stored values fall back to [AppLanguage.system]
/// - Storage failures are debug-printed and do **not** crash the app
/// - No [BuildContext] is used anywhere
/// - All state mutations are guarded by a disposal flag
class LocaleController extends StateNotifier<AppLanguage> {
  /// Storage key used to persist the language selection.
  static const String _storageKey = 'tuno_app_locale';

  LocaleController() : super(AppLanguage.system) {
    _loadSavedLanguage();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ── Initialisation ──────────────────────────────────────────

  /// Load the persisted [AppLanguage] from SharedPreferences.
  ///
  /// Runs asynchronously after construction. If the stored value is absent,
  /// invalid or the read fails, the default [AppLanguage.system] is kept.
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (_disposed) return;

      final language = AppLanguage.fromStoredValue(raw);
      if (language != null) {
        state = language;
      }
      // `null` means invalid/missing → keep default state (AppLanguage.system)
    } catch (e) {
      // Storage failure – keep current default, log in debug builds only.
      if (!_disposed) {
        debugPrint('LocaleController._loadSavedLanguage: $e');
      }
    }
  }

  // ── Public API ──────────────────────────────────────────────

  /// Set the app language and persist the choice.
  ///
  /// The UI state is updated immediately. The value is saved asynchronously.
  /// If persistence fails the selected language *is still retained* for the
  /// current session; only the stored preference may be lost.
  void setLanguage(AppLanguage language) {
    if (_disposed) return;

    state = language;
    _persistLanguage(language);
  }

  // ── Internals ───────────────────────────────────────────────

  /// Persist [language] to SharedPreferences. Failures are non-fatal.
  Future<void> _persistLanguage(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, language.storedValue);
    } catch (e) {
      // Log only in debug builds – the in-memory state is kept either way.
      debugPrint('LocaleController._persistLanguage: $e');
    }
  }
}

/// Provider that exposes the [LocaleController] and its current [AppLanguage].
///
/// Used by the UI to read the language and by [SingingCoachApp] to set the
/// active locale on [MaterialApp].
final localeProvider = StateNotifierProvider<LocaleController, AppLanguage>((
  ref,
) {
  return LocaleController();
});
