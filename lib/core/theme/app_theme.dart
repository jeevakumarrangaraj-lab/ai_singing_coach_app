import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  // ─────────────────────────────────────────────────────────────
  // Shared helpers
  // ─────────────────────────────────────────────────────────────

  /// Build a text theme using the given [primary] and [secondary] text colours.
  /// Uses the platform/system font (no Google Fonts at runtime).
  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color muted,
  }) {
    return TextTheme(
      displayLarge: TextStyle(color: primary, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(color: primary, fontWeight: FontWeight.w700),
      displaySmall: TextStyle(color: primary, fontWeight: FontWeight.w600),
      headlineLarge: TextStyle(color: primary, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(color: primary, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(color: primary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: primary, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: primary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: primary, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(color: secondary),
      bodySmall: TextStyle(color: muted),
      labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: secondary),
      labelSmall: TextStyle(color: muted),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Dark theme  –  Tuno
  // ─────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    const bg = AppColors.tunoDarkBackground;
    const surface = AppColors.tunoDarkSurface;
    const elevated = AppColors.tunoDarkElevatedSurface;
    const primaryText = AppColors.tunoDarkPrimaryText;
    const secondaryText = AppColors.tunoDarkSecondaryText;
    const mutedText = AppColors.tunoDarkMutedText;
    const border = AppColors.tunoDarkBorder;
    const divider = AppColors.tunoDarkDivider;
    const primaryBtn = AppColors.tunoCyan;
    const btnText = AppColors.tunoDarkBackground;
    const error = AppColors.darkError;
    const gold = AppColors.tunoGold;

    final textTheme = _buildTextTheme(
      primary: primaryText,
      secondary: secondaryText,
      muted: mutedText,
    );

    final colorScheme = ColorScheme.dark(
      surface: surface,
      onSurface: primaryText,
      surfaceContainerHighest: elevated,
      primary: primaryBtn,
      onPrimary: btnText,
      primaryContainer: AppColors.tunoDeepBlue,
      secondary: AppColors.tunoTeal,
      onSecondary: bg,
      secondaryContainer: Color(0xFF0A3D4D),
      tertiary: gold,
      onTertiary: bg,
      error: error,
      onError: Colors.white,
      outline: border,
      outlineVariant: divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      highlightColor: const Color(0x00000000),

      textTheme: textTheme,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: elevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: primaryText,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Dialogs ──
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: primaryText,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
      ),

      // ── Buttons ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBtn,
          foregroundColor: btnText,
          disabledBackgroundColor: border.withValues(alpha: 0.5),
          disabledForegroundColor: secondaryText.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          side: BorderSide(color: border, width: 1),
          disabledForegroundColor: secondaryText.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          disabledForegroundColor: secondaryText.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Inputs ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: secondaryText.withValues(alpha: 0.6),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: error,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryBtn, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: error, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border.withValues(alpha: 0.7)),
        ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: elevated,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: border.withValues(alpha: 0.6)),
        ),
      ),

      // ── Dividers ──
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 0),

      // ── Progress ──
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryBtn,
        linearTrackColor: border.withValues(alpha: 0.4),
        circularTrackColor: border.withValues(alpha: 0.4),
      ),

      // ── Slider ──
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: gold,
        inactiveTrackColor: primaryText.withValues(alpha: 0.20),
        thumbColor: gold,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayColor: gold.withValues(alpha: 0.2),
        valueIndicatorColor: gold,
        valueIndicatorTextStyle: textTheme.bodySmall?.copyWith(color: bg),
      ),

      // ── Navigation bar (bottom) ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: border.withValues(alpha: 0.4),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(color: secondaryText);
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBtn, size: 24);
          }
          return IconThemeData(color: secondaryText, size: 24);
        }),
      ),

      // ── Bottom navigation (legacy) ──
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryBtn,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Light theme  –  Tuno
  // ─────────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    const bg = AppColors.tunoLightBackground;
    const surface = AppColors.tunoLightSurface;
    const primaryText = AppColors.tunoLightPrimaryText;
    const secondaryText = AppColors.tunoLightSecondaryText;
    const border = AppColors.tunoLightBorder;
    const primaryBtn = AppColors.tunoDeepBlue;
    const btnText = Colors.white;
    const error = AppColors.lightError;
    const gold = AppColors.tunoGold;

    final textTheme = _buildTextTheme(
      primary: primaryText,
      secondary: secondaryText,
      muted: secondaryText.withValues(alpha: 0.65),
    );

    final colorScheme = ColorScheme.light(
      surface: surface,
      onSurface: primaryText,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
      primary: primaryBtn,
      onPrimary: btnText,
      primaryContainer: AppColors.tunoCyan,
      secondary: AppColors.tunoTeal,
      onSecondary: bg,
      secondaryContainer: Color(0xFFE0F7F7),
      tertiary: gold,
      onTertiary: primaryText,
      error: error,
      onError: Colors.white,
      outline: border,
      outlineVariant: border.withValues(alpha: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      highlightColor: const Color(0x00000000),

      textTheme: textTheme,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: primaryText.withValues(alpha: 0.9),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Dialogs ──
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: primaryText,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
      ),

      // ── Buttons ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBtn,
          foregroundColor: btnText,
          disabledBackgroundColor: border.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          side: BorderSide(color: border, width: 1),
          disabledForegroundColor: secondaryText.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          disabledForegroundColor: secondaryText.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Inputs ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: secondaryText.withValues(alpha: 0.6),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: error,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryBtn, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: error, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border.withValues(alpha: 0.7)),
        ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: border.withValues(alpha: 0.6)),
        ),
      ),

      // ── Dividers ──
      dividerTheme: DividerThemeData(
        color: border.withValues(alpha: 0.5),
        thickness: 1,
        space: 0,
      ),

      // ── Progress ──
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryBtn,
        linearTrackColor: border.withValues(alpha: 0.4),
        circularTrackColor: border.withValues(alpha: 0.4),
      ),

      // ── Slider ──
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: gold,
        inactiveTrackColor: primaryText.withValues(alpha: 0.20),
        thumbColor: gold,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayColor: gold.withValues(alpha: 0.2),
        valueIndicatorColor: gold,
        valueIndicatorTextStyle: textTheme.bodySmall?.copyWith(
          color: Colors.white,
        ),
      ),

      // ── Navigation bar (bottom) ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: border.withValues(alpha: 0.4),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(color: secondaryText);
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBtn, size: 24);
          }
          return IconThemeData(color: secondaryText, size: 24);
        }),
      ),

      // ── Bottom navigation (legacy) ──
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryBtn,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
    );
  }
}
