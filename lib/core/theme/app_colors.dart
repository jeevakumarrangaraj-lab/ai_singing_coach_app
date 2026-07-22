import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Base
  static const Color background = Color(0xFF090B12);
  static const Color surface = Color(0xFF171923);
  static const Color surfaceLight = Color(0xFF232638);

  // Brand - New Sunset/Music Palette
  static const Color primaryCoral = Color(0xFFFF6B45);
  static const Color primaryMagenta = Color(0xFFE83E8C);
  static const Color accentGold = Color(0xFFFFC857);
  static const Color deepPlum = Color(0xFF32133F);
  static const Color lightText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFD8CBDC);
  static const Color disabled = Color(0xFF8B7D91);

  // Legacy primary (deprecated, kept for migration)
  static const Color primary = primaryCoral;
  static const Color primaryDark = primaryMagenta;
  static const Color primaryLight = accentGold;

  // Text
  static const Color textPrimary = lightText;
  static const Color textSecondary = secondaryText;
  static const Color textMuted = disabled;

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = accentGold;
  static const Color error = Color(0xFFEF4444);

  // Borders
  static const Color border = Color(0xFF303344);

  // Gradients
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [primaryCoral, primaryMagenta],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryCoral, primaryMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF070910), Color(0xFF1A1035), Color(0xFF090B12)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Microphone gradients
  static const LinearGradient microphoneIdleGradient = LinearGradient(
    colors: [primaryCoral, primaryMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient microphoneRecordingGradient = LinearGradient(
    colors: [error, Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary button surface
  static const Color secondarySurface = deepPlum;
  static const Color secondaryBorder = Color(
    0x38FFFFFF,
  ); // white with 0.22 alpha
  static const Color secondaryHover = Color(
    0x14FFFFFF,
  ); // white with 0.08 alpha

  // Destructive button surface
  static const Color destructiveSurface = Color(0x1AFF0000); // transparent red
  static const Color destructiveBorder = error;
  static const Color destructiveHover = Color(0x1AFF4444); // slight red hover

  // ─────────────────────────────────────────────────────────────
  // Premium Monochrome Semantic Colors (Phase 3A-1)
  // ─────────────────────────────────────────────────────────────

  // Shared semantic (both themes)
  static const Color rewardGold = Color(0xFFB8965A); // subtle gold for rewards

  // Light theme tokens
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7F7F7);
  static const Color lightElevatedSurface = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF111111);
  static const Color lightSecondaryText = Color(0xFF666666);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color lightPrimaryButton = Color(0xFF111111);
  static const Color lightButtonText = Color(0xFFFFFFFF);

  // Dark theme tokens
  static const Color darkBackground = Color(0xFF090909);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkElevatedSurface = Color(0xFF181818);
  static const Color darkPrimaryText = Color(0xFFF7F7F7);
  static const Color darkSecondaryText = Color(0xFFA5A5A5);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkPrimaryButton = Color(0xFFF7F7F7);
  static const Color darkButtonText = Color(0xFF111111);
}
