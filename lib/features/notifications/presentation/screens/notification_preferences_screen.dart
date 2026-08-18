import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/dashboard_music_decorations.dart';
import '../notification_preferences_controller.dart';
import '../../domain/notification_preferences.dart';

/// ─────────────────────────────────────────────────────────────
/// NOTIFICATION PREFERENCES SCREEN
/// ─────────────────────────────────────────────────────────────
///
/// Route: `/settings/notifications`
///
/// Displays all notification preference toggles in a single
/// Tuno-styled card, following the same layout pattern as
/// [PreferencesScreen] and [AudioVideoSettingsScreen].
///
/// Persistence is handled entirely by
/// [NotificationPreferencesController] → SharedPreferences.
/// ─────────────────────────────────────────────────────────────

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
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

  // ── Info banner state ──

  bool _showDeliveryInfoBanner = false;

  // ───────────────────────────────────────────────────────────
  //  BUILD
  // ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final prefs = ref.watch(notificationPreferencesControllerProvider);

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
                                label: 'Back to Settings',
                                button: true,
                                child: Tooltip(
                                  message: 'Back',
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
                                  'Notification Preferences',
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
                                  'Choose which updates you want to receive',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Info banner (delivery not implemented) ──
                              if (_showDeliveryInfoBanner)
                                _buildDeliveryInfoBanner(textTheme),

                              // ── Main card ──
                              _buildPreferencesCard(prefs, textTheme),

                              const SizedBox(height: 20),

                              // ── Privacy note ──
                              Center(
                                child: Text(
                                  'You can change these preferences anytime.',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                    color: cs.onSurfaceVariant.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 24),
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
  //  DELIVERY INFO BANNER
  // ───────────────────────────────────────────────────────────

  Widget _buildDeliveryInfoBanner(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0B2B42).withValues(alpha: 0.8)
              : const Color(0xFFE0F7F7).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _accent.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 20, color: _accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Notification delivery is not yet implemented. '
                'Your preferences are saved locally and will '
                'be used once delivery is available.',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Dismiss',
              child: Tooltip(
                message: 'Dismiss',
                child: InkWell(
                  onTap: () => setState(() => _showDeliveryInfoBanner = false),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  PREFERENCES CARD
  // ───────────────────────────────────────────────────────────

  Widget _buildPreferencesCard(
    NotificationPreferences prefs,
    TextTheme textTheme,
  ) {
    final masterOn = prefs.allowNotifications;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        children: [
          // ── Allow Notifications (Master Switch) ──
          _ToggleRow(
            label: 'Allow Notifications',
            value: prefs.allowNotifications,
            onChanged: (v) {
              ref
                  .read(notificationPreferencesControllerProvider.notifier)
                  .setAllowNotifications(v);
              if (v && !_showDeliveryInfoBanner) {
                setState(() => _showDeliveryInfoBanner = true);
              }
            },
            accent: _accent,
          ),

          _sectionDivider(),

          // ── Child toggles ──
          _ToggleRow(
            label: 'Practice Reminders',
            value: prefs.practiceReminders,
            enabled: masterOn,
            onChanged: (v) {
              ref
                  .read(notificationPreferencesControllerProvider.notifier)
                  .setPracticeReminders(v);
            },
            accent: _accent,
          ),

          _sectionDivider(),

          _ToggleRow(
            label: 'AI Analysis Updates',
            value: prefs.aiAnalysisUpdates,
            enabled: masterOn,
            onChanged: (v) {
              ref
                  .read(notificationPreferencesControllerProvider.notifier)
                  .setAiAnalysisUpdates(v);
            },
            accent: _accent,
          ),

          _sectionDivider(),

          _ToggleRow(
            label: 'Streak Reminders',
            value: prefs.streakReminders,
            enabled: masterOn,
            onChanged: (v) {
              ref
                  .read(notificationPreferencesControllerProvider.notifier)
                  .setStreakReminders(v);
            },
            accent: _accent,
          ),

          _sectionDivider(),

          _ToggleRow(
            label: 'Coins & Achievements',
            value: prefs.coinsAchievements,
            enabled: masterOn,
            onChanged: (v) {
              ref
                  .read(notificationPreferencesControllerProvider.notifier)
                  .setCoinsAchievements(v);
            },
            accent: _accent,
          ),

          _sectionDivider(),

          _ToggleRow(
            label: 'Weekly Challenges',
            value: prefs.weeklyChallenges,
            enabled: masterOn,
            onChanged: (v) {
              ref
                  .read(notificationPreferencesControllerProvider.notifier)
                  .setWeeklyChallenges(v);
            },
            accent: _accent,
          ),

          _sectionDivider(),

          _ToggleRow(
            label: 'Product Updates',
            value: prefs.productUpdates,
            enabled: masterOn,
            onChanged: (v) {
              ref
                  .read(notificationPreferencesControllerProvider.notifier)
                  .setProductUpdates(v);
            },
            accent: _accent,
          ),

          _sectionDivider(),

          // ── Reminder Time Row ──
          _buildReminderTimeRow(prefs, textTheme),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  REMINDER TIME ROW
  // ───────────────────────────────────────────────────────────

  Widget _buildReminderTimeRow(
    NotificationPreferences prefs,
    TextTheme textTheme,
  ) {
    final masterOn = prefs.allowNotifications;
    final practiceOn = prefs.practiceReminders;
    final canEdit = masterOn && practiceOn;

    final timeString =
        '${prefs.reminderHour.toString().padLeft(2, '0')}:${prefs.reminderMinute.toString().padLeft(2, '0')}';

    return Semantics(
      label: 'Reminder Time: $timeString',
      button: canEdit,
      child: Tooltip(
        message: canEdit ? 'Tap to change reminder time' : 'Reminder Time',
        child: InkWell(
          onTap: canEdit ? () => _showTimePicker(prefs) : null,
          borderRadius: BorderRadius.circular(12),
          hoverColor: cs.primary.withValues(alpha: 0.04),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 22,
                  color: canEdit
                      ? _accent
                      : cs.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Reminder Time',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      color: canEdit
                          ? cs.onSurface
                          : cs.onSurfaceVariant.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  timeString,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: canEdit
                        ? _accent
                        : cs.onSurfaceVariant.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, size: 20, color: _accent),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTimePicker(NotificationPreferences prefs) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: prefs.reminderHour,
        minute: prefs.reminderMinute,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: _accent),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      ref
          .read(notificationPreferencesControllerProvider.notifier)
          .setReminderTime(hour: picked.hour, minute: picked.minute);
    }
  }

  // ───────────────────────────────────────────────────────────
  //  HELPERS
  // ───────────────────────────────────────────────────────────

  Widget _sectionDivider() {
    return Divider(height: 1, thickness: 1, color: _dividerColor);
  }
}

// ─────────────────────────────────────────────────────────────
// TOGGLE ROW
// ─────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.accent,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveValue = enabled ? value : false;
    final effectiveLabel = !enabled ? '$label (unavailable)' : label;

    return Semantics(
      label: effectiveLabel,
      toggled: enabled && value,
      enabled: enabled,
      child: Tooltip(
        message: enabled ? label : '$label – enable notifications first',
        child: InkWell(
          onTap: enabled ? () => onChanged(!value) : null,
          borderRadius: BorderRadius.circular(12),
          hoverColor: cs.primary.withValues(alpha: 0.04),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      color: enabled
                          ? cs.onSurface
                          : cs.onSurfaceVariant.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  toggled: enabled && value,
                  child: SizedBox(
                    height: 32,
                    child: Switch.adaptive(
                      value: effectiveValue,
                      onChanged: enabled ? onChanged : null,
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
