import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/fixed_back_button.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/widgets/dashboard_music_decorations.dart';

/// Data model for a language option displayed on the screen.
class _LanguageOption {
  final AppLanguage value;
  final String label;
  final String supportingText;

  const _LanguageOption({
    required this.value,
    required this.label,
    required this.supportingText,
  });
}

class LanguagesScreen extends ConsumerWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLanguage = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    // Build options using localized strings.
    // The native language names (English, தமிழ், हिन्दी) are kept recognizable
    // regardless of the current app language by using the ARB values directly
    // for both label and supporting text.
    final options = [
      _LanguageOption(
        value: AppLanguage.system,
        label: l10n.systemDefault,
        supportingText: l10n.useDeviceLanguage,
      ),
      _LanguageOption(
        value: AppLanguage.english,
        label: l10n.english,
        supportingText: l10n.english,
      ),
      _LanguageOption(
        value: AppLanguage.tamil,
        label: l10n.tamil,
        supportingText: l10n.tamil,
      ),
      _LanguageOption(
        value: AppLanguage.hindi,
        label: l10n.hindi,
        supportingText: l10n.hindi,
      ),
    ];

    final cardColor = isDark ? const Color(0xFF061E31) : cs.surface;
    final borderColor = isDark
        ? cs.outline.withValues(alpha: 0.5)
        : cs.outlineVariant.withValues(alpha: 0.7);
    final accentColor = isDark
        ? const Color(0xFF12B5C1)
        : const Color(0xFF0B96A5);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Music background decorations (outside SafeArea, full screen) ──
          Positioned.fill(
            child: const IgnorePointer(
              ignoring: true,
              child: DashboardMusicDecorations(animate: true),
            ),
          ),
          // ── SafeArea wrapping content + fixed back button ──
          SafeArea(
            child: Stack(
              children: [
                // ── Scrollable content ──
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 640),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  // ── Title ──
                                  Center(
                                    child: Text(
                                      l10n.languages,
                                      style: textTheme.headlineMedium?.copyWith(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // ── Subtitle ──
                                  Center(
                                    child: Text(
                                      l10n.chooseAppLanguage,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontSize: 15,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  // ── Language options card ──
                                  Container(
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: borderColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: List.generate(options.length, (
                                        index,
                                      ) {
                                        final option = options[index];
                                        final isSelected =
                                            currentLanguage == option.value;
                                        final showTopBorder = index > 0;

                                        return _LanguageOptionTile(
                                          option: option,
                                          isSelected: isSelected,
                                          accentColor: accentColor,
                                          showTopBorder: showTopBorder,
                                          borderColor: borderColor,
                                          onTap: () {
                                            ref
                                                .read(localeProvider.notifier)
                                                .setLanguage(option.value);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).clearSnackBars();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.languageChanged,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // ── Fixed top-left Back button (last child for hit-test priority) ──
                Positioned(
                  top: 12,
                  left: 16,
                  child: FixedBackButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/settings');
                      }
                    },
                    l10n: l10n,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single language option tile.
class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.option,
    required this.isSelected,
    required this.accentColor,
    required this.showTopBorder,
    required this.borderColor,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool isSelected;
  final Color accentColor;
  final bool showTopBorder;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: option.label,
      selected: isSelected,
      child: Tooltip(
        message: option.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashFactory: InkRipple.splashFactory,
          hoverColor: cs.primary.withValues(alpha: 0.06),
          focusColor: cs.primary.withValues(alpha: 0.10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: showTopBorder
                  ? Border(
                      top: BorderSide(
                        color: borderColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Selection indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? accentColor : cs.outline,
                      width: isSelected ? 2.0 : 1.5,
                    ),
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check_rounded, size: 14, color: accentColor)
                      : null,
                ),
                const SizedBox(width: 16),
                // Label and supporting text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option.label,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          color: cs.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.supportingText,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Selected indicator dot
                if (isSelected)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
                    ),
                  ),
                if (!isSelected)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: cs.outline,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
