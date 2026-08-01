import 'package:ai_singing_coach/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/dashboard_music_decorations.dart';
import '../../domain/tuno_preferences.dart';
import '../preferences_controller.dart';

/// ─────────────────────────────────────────────────────────────
/// PREFERENCES SCREEN
/// ─────────────────────────────────────────────────────────────
///
/// Displays all user-configurable Tuno preferences in four
/// logically grouped sections, each in a dedicated card.
///
/// Sections:
///   1. Practice Preferences  (default mode picker)
///   2. Coaching Feedback     (simple / detailed)
///   3. Recording Preferences (three toggles)
///   4. General Behaviour     (two toggles)
///
/// Every change is persisted immediately via
/// [PreferencesController] → SharedPreferences.
/// ─────────────────────────────────────────────────────────────

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  // ── Theme helpers ───────────────────────────────────────────

  Color get _accent =>
      isDark ? const Color(0xFF12B5C1) : const Color(0xFF0B96A5);

  Color get _cardColor => isDark ? const Color(0xFF061E31) : cs.surface;

  Color get _borderColor => isDark
      ? cs.outline.withValues(alpha: 0.5)
      : cs.outlineVariant.withValues(alpha: 0.7);

  Color get _dividerColor => isDark
      ? cs.outline.withValues(alpha: 0.2)
      : cs.outlineVariant.withValues(alpha: 0.4);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  ColorScheme get cs => Theme.of(context).colorScheme;

  // ───────────────────────────────────────────────────────────
  //  BUILD
  // ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final preferences = ref.watch(preferencesControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Background decorations ──
          Positioned.fill(
            child: const IgnorePointer(
              ignoring: true,
              child: DashboardMusicDecorations(animate: true),
            ),
          ),

          // ── Scrollable content ──
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // ── Back button ──
                              Semantics(
                                label: l10n.backToSettings,
                                button: true,
                                child: Tooltip(
                                  message: l10n.back,
                                  child: AppBackButton(
                                    onPressed: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/settings');
                                      }
                                    },
                                    showOnlyIfCanPop: false,
                                    iconColor: _accent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Title ──
                              Center(
                                child: Text(
                                  l10n.preferences,
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Section 1: Practice Preferences ──
                              _buildSectionCard(
                                title: l10n.practicePreferences,
                                child: _buildPracticeModeRow(preferences),
                              ),
                              const SizedBox(height: 16),

                              // ── Section 2: Coaching Feedback ──
                              _buildSectionCard(
                                title: l10n.coachingFeedback,
                                child: _buildFeedbackDetailRow(preferences),
                              ),
                              const SizedBox(height: 16),

                              // ── Section 3: Recording Preferences ──
                              _buildSectionCard(
                                title: l10n.recordingPreferences,
                                child: Column(
                                  children: [
                                    _ToggleRow(
                                      label: l10n.countInBeforeRecording,
                                      value: preferences.countInBeforeRecording,
                                      onChanged: (v) {
                                        ref
                                            .read(
                                              preferencesControllerProvider
                                                  .notifier,
                                            )
                                            .setCountInBeforeRecording(v);
                                        _showSnackBar(
                                          v
                                              ? l10n.countInEnabled
                                              : l10n.countInDisabled,
                                        );
                                      },
                                      accent: _accent,
                                    ),
                                    _sectionDivider(),
                                    _ToggleRow(
                                      label: l10n.autoSaveCompletedRecordings,
                                      value: preferences
                                          .automaticallySaveRecordings,
                                      onChanged: (v) {
                                        ref
                                            .read(
                                              preferencesControllerProvider
                                                  .notifier,
                                            )
                                            .setAutomaticallySaveRecordings(v);
                                        _showSnackBar(
                                          v
                                              ? l10n.autoSaveEnabled
                                              : l10n.autoSaveDisabled,
                                        );
                                      },
                                      accent: _accent,
                                    ),
                                    _sectionDivider(),
                                    _ToggleRow(
                                      label: l10n.showHeadphoneRecommendation,
                                      value: preferences
                                          .showHeadphoneRecommendation,
                                      onChanged: (v) {
                                        ref
                                            .read(
                                              preferencesControllerProvider
                                                  .notifier,
                                            )
                                            .setShowHeadphoneRecommendation(v);
                                        _showSnackBar(
                                          v
                                              ? l10n.headphoneReminderEnabled
                                              : l10n.headphoneReminderDisabled,
                                        );
                                      },
                                      accent: _accent,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Section 4: General Behaviour ──
                              _buildSectionCard(
                                title: l10n.generalBehaviour,
                                child: Column(
                                  children: [
                                    _ToggleRow(
                                      label: l10n.confirmBeforeDeleting,
                                      value: preferences.confirmBeforeDeleting,
                                      onChanged: (v) {
                                        ref
                                            .read(
                                              preferencesControllerProvider
                                                  .notifier,
                                            )
                                            .setConfirmBeforeDeleting(v);
                                        _showSnackBar(
                                          v
                                              ? l10n.deleteConfirmationEnabled
                                              : l10n.deleteConfirmationDisabled,
                                        );
                                      },
                                      accent: _accent,
                                    ),
                                    _sectionDivider(),
                                    _ToggleRow(
                                      label: l10n.reduceAnimations,
                                      value: preferences.reduceAnimations,
                                      onChanged: (v) {
                                        ref
                                            .read(
                                              preferencesControllerProvider
                                                  .notifier,
                                            )
                                            .setReduceAnimations(v);
                                        _showSnackBar(
                                          v
                                              ? l10n.reducedAnimations
                                              : l10n.animationsRestored,
                                        );
                                      },
                                      accent: _accent,
                                    ),
                                  ],
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
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  SECTION CARD
  // ───────────────────────────────────────────────────────────

  Widget _buildSectionCard({required String title, required Widget child}) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  PRACTICE MODE ROW
  // ───────────────────────────────────────────────────────────

  String _practiceModeLabel(AppLocalizations l10n, String mode) {
    switch (mode) {
      case PracticeMode.soloPractice:
        return l10n.soloPractice;
      case PracticeMode.tunoExercises:
        return l10n.tunoExercises;
      case PracticeMode.uploadSong:
        return l10n.uploadSong;
      case PracticeMode.backingTrack:
        return l10n.backingTrack;
      default:
        return l10n.soloPractice;
    }
  }

  Widget _buildPracticeModeRow(TunoPreferences preferences) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.defaultModeLabel(
        _practiceModeLabel(l10n, preferences.defaultPracticeMode),
      ),
      child: InkWell(
        onTap: () => _showPracticeModeSheet(preferences),
        borderRadius: BorderRadius.circular(14),
        hoverColor: cs.primary.withValues(alpha: 0.06),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.defaultPracticeMode,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _practiceModeLabel(l10n, preferences.defaultPracticeMode),
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: _accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 22, color: _accent),
            ],
          ),
        ),
      ),
    );
  }

  void _showPracticeModeSheet(TunoPreferences current) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.defaultPracticeMode,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ...PracticeMode.values.map((mode) {
                  final selected = current.defaultPracticeMode == mode;
                  return _SelectionOption(
                    label: _practiceModeLabel(l10n, mode),
                    selected: selected,
                    onTap: () {
                      ref
                          .read(preferencesControllerProvider.notifier)
                          .setDefaultPracticeMode(mode);
                      Navigator.of(ctx).pop();
                      _showSnackBar(
                        l10n.defaultModeLabel(_practiceModeLabel(l10n, mode)),
                      );
                    },
                    accent: _accent,
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────
  //  FEEDBACK DETAIL ROW
  // ───────────────────────────────────────────────────────────

  Widget _buildFeedbackDetailRow(TunoPreferences preferences) {
    final detail = preferences.feedbackDetail;
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      container: true,
      label: l10n.coachingFeedback,
      explicitChildNodes: true,
      child: Row(
        children: [
          // Simple segment
          Expanded(
            child: _SegmentedOption(
              label: l10n.simple,
              selected: detail == FeedbackDetail.simple,
              onTap: () {
                ref
                    .read(preferencesControllerProvider.notifier)
                    .setFeedbackDetail(FeedbackDetail.simple);
              },
              accent: _accent,
              isLeft: true,
            ),
          ),
          const SizedBox(width: 8),
          // Detailed segment
          Expanded(
            child: _SegmentedOption(
              label: l10n.detailed,
              selected: detail == FeedbackDetail.detailed,
              onTap: () {
                ref
                    .read(preferencesControllerProvider.notifier)
                    .setFeedbackDetail(FeedbackDetail.detailed);
              },
              accent: _accent,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  HELPERS
  // ───────────────────────────────────────────────────────────

  Widget _sectionDivider() {
    return Divider(height: 1, thickness: 1, color: _dividerColor);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────
//  TOGGLE ROW
// ─────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.accent,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      label: label,
      toggled: value,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          hoverColor: cs.primary.withValues(alpha: 0.04),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  toggled: value,
                  child: SizedBox(
                    height: 32,
                    child: Switch.adaptive(
                      value: value,
                      onChanged: onChanged,
                      activeTrackColor: accent.withValues(alpha: 0.4),
                      activeThumbColor: accent,
                      inactiveThumbColor: cs.onSurfaceVariant,
                      inactiveTrackColor: cs.outlineVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────
//  SELECTION OPTION (bottom sheet)
// ─────────────────────────────────────────────────────────────

class _SelectionOption extends StatelessWidget {
  const _SelectionOption({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: cs.primary.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: selected ? accent : cs.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const Spacer(),
              if (selected) Icon(Icons.check_rounded, size: 22, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SEGMENTED OPTION
// ─────────────────────────────────────────────────────────────

class _SegmentedOption extends StatelessWidget {
  const _SegmentedOption({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accent,
    required this.isLeft,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      selected: selected,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: cs.primary.withValues(alpha: 0.04),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? accent : cs.outline.withValues(alpha: 0.5),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? accent : cs.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
