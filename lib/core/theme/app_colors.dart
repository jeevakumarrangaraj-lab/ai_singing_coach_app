import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // ─────────────────────────────────────────────────────────────
  // LEGACY (kept for backward compatibility)
  // ─────────────────────────────────────────────────────────────

  // Base (old dark)
  static const Color background = Color(0xFF090B12);
  static const Color surface = Color(0xFF171923);
  static const Color surfaceLight = Color(0xFF232638);

  // Brand - Old Sunset/Music Palette
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

  // Gradients (legacy)
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
  static const Color secondaryBorder = Color(0x38FFFFFF);
  static const Color secondaryHover = Color(0x14FFFFFF);

  // Destructive button surface
  static const Color destructiveSurface = Color(0x1AFF0000);
  static const Color destructiveBorder = error;
  static const Color destructiveHover = Color(0x1AFF4444);

  // ─────────────────────────────────────────────────────────────
  // PHASE 3A-1 PREMIUM MONOCHROME (kept for reference)
  // ─────────────────────────────────────────────────────────────

  static const Color rewardGold = Color(0xFFB8965A);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7F7F7);
  static const Color lightElevatedSurface = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF111111);
  static const Color lightSecondaryText = Color(0xFF666666);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color lightPrimaryButton = Color(0xFF111111);
  static const Color lightButtonText = Color(0xFFFFFFFF);

  static const Color darkBackground = Color(0xFF090909);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkElevatedSurface = Color(0xFF181818);
  static const Color darkPrimaryText = Color(0xFFF7F7F7);
  static const Color darkSecondaryText = Color(0xFFA5A5A5);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkPrimaryButton = Color(0xFFF7F7F7);
  static const Color darkButtonText = Color(0xFF111111);

  // ─────────────────────────────────────────────────────────────
  // TUNA FINAL PALETTES (Phase 1A)
  // ─────────────────────────────────────────────────────────────

  // Light theme
  static const Color tunoLightBackground = Color(0xFFF7FBFE);
  static const Color tunoLightSurface = Color(0xFFFFFFFF);
  static const Color tunoLightPrimaryText = Color(0xFF062A5E);
  static const Color tunoLightSecondaryText = Color(0xFF536984);
  static const Color tunoLightBorder = Color(0xFFD8E7F1);

  // Dark theme
  static const Color tunoDarkBackground = Color(0xFF030D1B);
  static const Color tunoDarkSurface = Color(0xFF061E31);
  static const Color tunoDarkElevatedSurface = Color(0xFF09273D);
  static const Color tunoDarkPrimaryText = Color(0xFFF7F9FC);
  static const Color tunoDarkSecondaryText = Color(0xFFA9B8C9);
  static const Color tunoDarkMutedText = Color(0xFF7890A8);
  static const Color tunoDarkBorder = Color(0xFF17445B);
  static const Color tunoDarkDivider = Color(0xFF15394D);
  static const Color tunoDarkIconSurface = Color(0xFF0B2B42);

  // Shared brand colors
  static const Color tunoTeal = Color(0xFF10B8B8);
  static const Color tunoCyan = Color(0xFF20CED0);
  static const Color tunoDeepBlue = Color(0xFF0069A0);
  static const Color tunoGold = Color(0xFFF4B323);

  // Emblem cyan-to-navy gradient colors
  static const Color tunoEmblemStart = Color(0xFF00A6BA);
  static const Color tunoEmblemMid = Color(0xFF007F9C);
  static const Color tunoEmblemEnd = Color(0xFF014065);

  // Premium gold palette
  static const Color tunoGoldChampagne = Color(0xFFFFF2A6);
  static const Color tunoGoldPrimary = Color(0xFFE3B94F);
  static const Color tunoGoldDeep = Color(0xFFA86D16);
  static const Color tunoGoldSoftHighlight = Color(0xFFF4D675);
  static const Color tunoGoldGlow = Color(0xFFD9A62E);

  // Button gradient colors (darker reference)
  static const Color tunoButtonStart = Color(0xFF008BA6);
  static const Color tunoButtonMid = Color(0xFF006D98);
  static const Color tunoButtonEnd = Color(0xFF014B75);

  // Note gradient colors
  static const Color tunoNoteStart = Color(0xFF087D91);
  static const Color tunoNoteEnd = Color(0xFF07506C);

  // Misc
  static const Color tunoBackArrow = Color(0xFF12B5C1);
  static const Color tunoLoginBorder = Color(0xFF41647D);
  static const Color tunoButtonLabel = Color(0xFFF7F7F7);

  // ─────────────────────────────────────────────────────────────
  // PREMIUM PRACTICE PALETTE
  // ─────────────────────────────────────────────────────────────

  // Dark background layers
  static const Color baseNavy = Color(0xFF030D1B);
  static const Color elevatedNavy = Color(0xFF061B2B);
  static const Color cardNavy = Color(0xFF082438);
  static const Color borderBlue = Color(0xFF17435A);
  static const Color cyanAccent = Color(0xFF12B5C1);
  static const Color tealAccent = Color(0xFF008BA6);
  static const Color midBlue = Color(0xFF007F9C);
  static const Color deepBlueAccent = Color(0xFF014B75);

  // Background gradient stops
  static const Color bgGradientTop = Color(0xFF020B17);
  static const Color bgGradientMid = Color(0xFF030D1B);
  static const Color bgGradientBottom = Color(0xFF061726);

  // Card gradient stops
  static const Color cardGradientStart = Color(0xFF0A2A3F);
  static const Color cardGradientEnd = Color(0xFF061B2B);

  // Recording panel gradient stops
  static const Color panelGradientStart = Color(0xFF082438);
  static const Color panelGradientEnd = Color(0xFF041421);

  // Wave gradient colors
  static const Color waveCyan = Color(0xFF12B5C1);
  static const Color waveDeepBlue = Color(0xFF014B75);

  // Note gradient colors (enhanced)
  static const Color noteGradientCyan = Color(0xFF087D91);
  static const Color noteGradientBlue = Color(0xFF014B75);

  // Gold palette (enhanced)
  static const Color goldChampagne = Color(0xFFFFF2A6);
  static const Color goldPrimary = Color(0xFFE3B94F);
  static const Color goldDeep = Color(0xFFA86D16);
  static const Color goldGlow = Color(0xFFD9A62E);
  static const Color goldHighlight = Color(0xFFF4D675);

  // Recording button gradient
  static const Color recBtnStart = Color(0xFF00A6BA);
  static const Color recBtnMid = Color(0xFF007F9C);
  static const Color recBtnEnd = Color(0xFF014B75);

  // Gradients
  static const LinearGradient practiceCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cardGradientStart, cardGradientEnd],
    stops: [0.92, 1.0],
  );

  static const LinearGradient recordingPanelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [panelGradientStart, panelGradientEnd],
    stops: [0.88, 0.95],
  );

  static const LinearGradient recordingButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [recBtnStart, recBtnMid, recBtnEnd],
  );

  // Welcome screen – semantic tokens (varies by theme, resolved in screen)
  static const Color tunoWelcomeSurfaceDark = Color(0x00000000); // transparent
  static const Color tunoWelcomeSurfaceLight = Color(0xFFFFFFFF); // white
  static const Color tunoWelcomeOutlineDark = Color(
    0xFF41647D,
  ); // muted blue-grey
  static const Color tunoWelcomeOutlineLight = Color(
    0xFFB8CCDC,
  ); // pale blue-grey
  static const Color tunoWelcomeButtonLabelDark = Color(
    0xFFF7F7F7,
  ); // light text
  static const Color tunoWelcomeButtonLabelLight = Color(
    0xFF062A5E,
  ); // navy text

  // Gradients
  static const LinearGradient tunoMainGradient = LinearGradient(
    colors: [tunoCyan, tunoDeepBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light theme semantic aliases
  static const Color lightPrimary = tunoDeepBlue;
  static const Color lightPrimaryContainer = tunoCyan;
  static const Color lightSecondary = tunoTeal;
  static const Color lightSecondaryContainer = Color(0xFFE0F7F7);
  static const Color lightTertiary = tunoGold;
  static const Color lightError = Color(0xFFDC2626);
  static const Color lightSurfaceContainerHighest = Color(0xFFE8F1F8);

  // Dark theme semantic aliases
  static const Color darkPrimary = tunoCyan;
  static const Color darkPrimaryContainer = tunoDeepBlue;
  static const Color darkSecondary = tunoTeal;
  static const Color darkSecondaryContainer = Color(0xFF0A3D4D);
  static const Color darkTertiary = tunoGold;
  static const Color darkError = Color(0xFFF87171);
  static const Color darkSurfaceContainerHighest = tunoDarkElevatedSurface;
}
