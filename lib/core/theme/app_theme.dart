import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    const fallbackFontFamily = 'Arial';

    final textTheme = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontFamily: fallbackFontFamily,
      ),
      displayMedium: base.textTheme.displayMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontFamily: fallbackFontFamily,
      ),
      displaySmall: base.textTheme.displaySmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: fallbackFontFamily,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontFamily: fallbackFontFamily,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontFamily: fallbackFontFamily,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: fallbackFontFamily,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontFamily: fallbackFontFamily,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: fallbackFontFamily,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: fallbackFontFamily,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        fontFamily: fallbackFontFamily,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        fontFamily: fallbackFontFamily,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        color: AppColors.textMuted,
        fontFamily: fallbackFontFamily,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: fallbackFontFamily,
      ),
      labelMedium: base.textTheme.labelMedium?.copyWith(
        color: AppColors.textSecondary,
        fontFamily: fallbackFontFamily,
      ),
      labelSmall: base.textTheme.labelSmall?.copyWith(
        color: AppColors.textMuted,
        fontFamily: fallbackFontFamily,
      ),
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryCoral,
      brightness: Brightness.dark,
      surface: AppColors.surface,
      primary: AppColors.primaryCoral,
      secondary: AppColors.accentGold,
      error: AppColors.error,
    );

    return ThemeData.from(
      colorScheme: colorScheme,
      textTheme: textTheme,
    ).copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      highlightColor: const Color(0x00000000),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: textTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentGold,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.7),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primaryCoral,
            width: 1.5,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.7),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border.withValues(alpha: 0.6),
        thickness: 1,
        space: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryCoral,
        linearTrackColor: AppColors.border.withValues(alpha: 0.4),
        circularTrackColor: AppColors.border.withValues(alpha: 0.4),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: AppColors.accentGold,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.20),
        thumbColor: AppColors.accentGold,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayColor: AppColors.accentGold.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.accentGold,
        valueIndicatorTextStyle: textTheme.bodySmall?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
