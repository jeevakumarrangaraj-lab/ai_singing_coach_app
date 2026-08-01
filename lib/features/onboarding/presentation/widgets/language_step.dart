import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/onboarding_profile.dart';
import '../onboarding_controller.dart';
import '../onboarding_state.dart' show OnboardingErrorCode;

class LanguageStep extends ConsumerWidget {
  const LanguageStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final languages = OnboardingLanguage.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Heading
        Text(
          l10n.chooseCoachingLanguage,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF7F7F7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          l10n.coachingLanguageSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFFAAB8C8),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Language cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final spacing = 12.0;
            final childWidth = isWide
                ? (constraints.maxWidth - spacing) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: languages.map((language) {
                return SizedBox(
                  width: childWidth,
                  child: _LanguageCard(
                    language: language,
                    isSelected: state.selectedLanguage == language,
                    onTap: () => controller.selectLanguage(language),
                    isDark: isDark,
                    l10n: l10n,
                  ),
                );
              }).toList(),
            );
          },
        ),
        // Validation error
        if (state.errorCode != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage(context, state.errorCode!),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Maps [OnboardingErrorCode] to the correct l10n error string.
  String _errorMessage(BuildContext context, OnboardingErrorCode code) {
    final l10n = AppLocalizations.of(context)!;
    return switch (code) {
      OnboardingErrorCode.languageRequired => l10n.onboardingLanguageRequired,
      OnboardingErrorCode.experienceRequired =>
        l10n.onboardingExperienceRequired,
      OnboardingErrorCode.goalRequired => l10n.onboardingGoalRequired,
      OnboardingErrorCode.saveFailed => l10n.setupSaveFailed,
      OnboardingErrorCode.checkFailed => l10n.onboardingCheckFailed,
    };
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.l10n,
  });

  final OnboardingLanguage language;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final AppLocalizations l10n;

  String _localizedName(OnboardingLanguage lang) {
    switch (lang) {
      case OnboardingLanguage.english:
        return l10n.english;
      case OnboardingLanguage.tamil:
        return l10n.tamil;
      case OnboardingLanguage.hindi:
        return l10n.hindi;
    }
  }

  // Color constants matching the design spec
  static const Color _cardSurface = Color(0xFF061E31); // tunoDarkSurface
  static const Color _cardBorder = Color(0xFF41647D); // tunoLoginBorder
  static const Color _selectedBgStart = Color(0xFF008BA6);
  static const Color _selectedBgMid = Color(0xFF006D98);
  static const Color _selectedBgEnd = Color(0xFF014B75);
  static const Color _cyanInnerOutline = Color(0xFF12B5C1); // tunoBackArrow
  static const Color _textWhite = Color(0xFFF7F7F7);
  static const Color _iconCyan = Color(0xFF12B5C1);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      label: l10n.languageLabel(_localizedName(language)),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 72, // Minimum 48px interaction target
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              // Base surface
              color: isSelected
                  ? null // gradient below
                  : _cardSurface,
              // Gradient for selected state
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        _selectedBgStart,
                        _selectedBgMid,
                        _selectedBgEnd,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              // Borders: inner cyan + outer metallic gold when selected
              border: isSelected
                  ? null // handled by Stack below
                  : Border.all(color: _cardBorder, width: 1.2),
            ),
            child: Stack(
              children: [
                // Inner cyan outline for selected state
                if (isSelected)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: _cyanInnerOutline.withValues(alpha: 0.85),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Outer metallic-gold highlight for selected state
                if (isSelected)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFF2A6),
                              Color(0xFFE3B94F),
                              Color(0xFFA86D16),
                              Color(0xFFF4D675),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            gradient: const LinearGradient(
                              colors: [
                                _selectedBgStart,
                                _selectedBgMid,
                                _selectedBgEnd,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Card content
                Center(
                  child: Row(
                    children: [
                      // Cyan globe icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _iconCyan.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.language_rounded,
                          size: 22,
                          color: _iconCyan,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Language name
                      Expanded(
                        child: Text(
                          _localizedName(language),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _textWhite,
                            letterSpacing: 0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Check indicator for selected
                      if (isSelected)
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _cyanInnerOutline,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
