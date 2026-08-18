import 'package:flutter/material.dart';

/// Supported application languages.
///
/// - [system]: Use the device / browser language (locale: null)
/// - [english]: English (en)
/// - [tamil]: Tamil (ta)
/// - [hindi]: Hindi (hi)
enum AppLanguage {
  system,
  english,
  tamil,
  hindi;

  /// The [Locale] associated with this language.
  ///
  /// Returns `null` for [AppLanguage.system] so that Flutter uses the
  /// device / browser language automatically.
  Locale? get locale {
    switch (this) {
      case AppLanguage.system:
        return null;
      case AppLanguage.english:
        return const Locale('en');
      case AppLanguage.tamil:
        return const Locale('ta');
      case AppLanguage.hindi:
        return const Locale('hi');
    }
  }

  /// The string value stored in SharedPreferences.
  ///
  /// - `'system'` for [AppLanguage.system]
  /// - `'en'` for [AppLanguage.english]
  /// - `'ta'` for [AppLanguage.tamil]
  /// - `'hi'` for [AppLanguage.hindi]
  String get storedValue {
    switch (this) {
      case AppLanguage.system:
        return 'system';
      case AppLanguage.english:
        return 'en';
      case AppLanguage.tamil:
        return 'ta';
      case AppLanguage.hindi:
        return 'hi';
    }
  }

  /// Parse a stored string back to an [AppLanguage].
  ///
  /// Returns `null` when the value is absent or unrecognised so callers
  /// can fall back to the default ([AppLanguage.system]).
  static AppLanguage? fromStoredValue(String? raw) {
    if (raw == null) return null;
    switch (raw) {
      case 'system':
        return AppLanguage.system;
      case 'en':
        return AppLanguage.english;
      case 'ta':
        return AppLanguage.tamil;
      case 'hi':
        return AppLanguage.hindi;
      default:
        return null;
    }
  }
}
