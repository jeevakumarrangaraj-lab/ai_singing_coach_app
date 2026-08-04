import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/widgets/app_back_button.dart';
import '../core/theme/theme_controller.dart';
import '../core/widgets/dashboard_music_decorations.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../l10n/app_localizations.dart';

/// Identifier used internally for routing, not displayed to the user.
enum _SettingsRowId {
  account,
  practicePreferences,
  audioAndRecording,
  notificationPreferences,
  privacyAndSecurity,
  languages,
  helpAndSupport,
  aboutTuno,
}

/// Data model for a settings row.
class _SettingsRow {
  final _SettingsRowId id;
  final IconData icon;

  const _SettingsRow({required this.id, required this.icon});
}

const _settingsRows = <_SettingsRow>[
  _SettingsRow(id: _SettingsRowId.account, icon: Icons.person_rounded),
  _SettingsRow(
    id: _SettingsRowId.practicePreferences,
    icon: Icons.tune_rounded,
  ),
  _SettingsRow(id: _SettingsRowId.audioAndRecording, icon: Icons.mic_rounded),
  _SettingsRow(
    id: _SettingsRowId.notificationPreferences,
    icon: Icons.notifications_rounded,
  ),
  _SettingsRow(
    id: _SettingsRowId.privacyAndSecurity,
    icon: Icons.shield_rounded,
  ),
  _SettingsRow(id: _SettingsRowId.languages, icon: Icons.language_rounded),
  _SettingsRow(
    id: _SettingsRowId.helpAndSupport,
    icon: Icons.headset_mic_rounded,
  ),
  _SettingsRow(id: _SettingsRowId.aboutTuno, icon: Icons.info_outline_rounded),
];

/// Resolve the localized label for a settings row.
String _settingsRowLabel(_SettingsRowId id, AppLocalizations l10n) {
  switch (id) {
    case _SettingsRowId.account:
      return l10n.account;
    case _SettingsRowId.practicePreferences:
      return l10n.practicePreferences;
    case _SettingsRowId.audioAndRecording:
      return l10n.audioAndRecording;
    case _SettingsRowId.notificationPreferences:
      return l10n.notificationPreferences;
    case _SettingsRowId.privacyAndSecurity:
      return l10n.privacyAndSecurity;
    case _SettingsRowId.languages:
      return l10n.languages;
    case _SettingsRowId.helpAndSupport:
      return l10n.helpAndSupport;
    case _SettingsRowId.aboutTuno:
      return l10n.aboutTuno;
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoggingOut = false;

  void _showComingSoon(String label) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.featureComingSoon(label)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  void _showAppearanceSheet() {
    final l10n = AppLocalizations.of(context)!;
    final currentMode = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
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
                  l10n.appearance,
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _ThemeOption(
                  icon: Icons.settings_suggest_rounded,
                  label: l10n.systemDefault,
                  selected: currentMode == ThemeMode.system,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system);
                    Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: 4),
                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  label: l10n.light,
                  selected: currentMode == ThemeMode.light,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light);
                    Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: 4),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  label: l10n.dark,
                  selected: currentMode == ThemeMode.dark,
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark);
                    Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.system:
        return l10n.systemDefault;
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMode = ref.watch(themeModeProvider);

    final cardColor = isDark ? const Color(0xFF061E31) : cs.surface;
    final borderColor = isDark
        ? cs.outline.withValues(alpha: 0.5)
        : cs.outlineVariant.withValues(alpha: 0.7);
    final dividerColor = isDark
        ? cs.outline.withValues(alpha: 0.2)
        : cs.outlineVariant.withValues(alpha: 0.4);
    final accentColor = isDark
        ? const Color(0xFF12B5C1)
        : const Color(0xFF0B96A5);
    final iconColor = accentColor;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Shared Dashboard music background ──
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
                              Tooltip(
                                message: l10n.back,
                                child: Semantics(
                                  button: true,
                                  label: l10n.back,
                                  child: AppBackButton(
                                    onPressed: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/home');
                                      }
                                    },
                                    showOnlyIfCanPop: false,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // ── Title ──
                              Center(
                                child: Text(
                                  l10n.settings,
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Main Settings Card ──
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
                                  children: _buildSettingsRows(
                                    l10n: l10n,
                                    context: context,
                                    iconColor: iconColor,
                                    dividerColor: dividerColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Appearance Card ──
                              _buildAppearanceCard(
                                context,
                                l10n: l10n,
                                cardColor: cardColor,
                                borderColor: borderColor,
                                accentColor: accentColor,
                                currentModeLabel: _themeModeLabel(currentMode),
                                iconColor: iconColor,
                              ),
                              const SizedBox(height: 24),

                              // ── Logout button ──
                              _buildLogoutButton(
                                context,
                                l10n: l10n,
                                accentColor: accentColor,
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

  List<Widget> _buildSettingsRows({
    required AppLocalizations l10n,
    required BuildContext context,
    required Color iconColor,
    required Color dividerColor,
  }) {
    final rows = <Widget>[];
    for (int i = 0; i < _settingsRows.length; i++) {
      final row = _settingsRows[i];
      final label = _settingsRowLabel(row.id, l10n);
      rows.add(
        _SettingsRowWidget(
          icon: row.icon,
          label: label,
          iconColor: iconColor,
          onTap: () {
            switch (row.id) {
              case _SettingsRowId.account:
                context.push('/settings/account');
                break;
              case _SettingsRowId.practicePreferences:
                context.push('/settings/preferences');
                break;
              case _SettingsRowId.audioAndRecording:
                context.push('/settings/audio-video');
                break;
              case _SettingsRowId.notificationPreferences:
                context.push('/settings/notifications');
                break;
              case _SettingsRowId.privacyAndSecurity:
                context.push('/settings/privacy-security');
                break;
              case _SettingsRowId.languages:
                context.push('/settings/languages');
                break;
              case _SettingsRowId.helpAndSupport:
              case _SettingsRowId.aboutTuno:
                _showComingSoon(label);
                break;
            }
          },
        ),
      );
      if (i < _settingsRows.length - 1) {
        rows.add(
          Divider(height: 1, thickness: 1, indent: 60, color: dividerColor),
        );
      }
    }
    return rows;
  }

  Widget _buildAppearanceCard(
    BuildContext context, {
    required AppLocalizations l10n,
    required Color cardColor,
    required Color borderColor,
    required Color accentColor,
    required String currentModeLabel,
    required Color iconColor,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: _SettingsRowWidget(
        icon: Icons.light_mode_rounded,
        label: l10n.appearance,
        iconColor: iconColor,
        trailing: Text(
          currentModeLabel,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: accentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: _showAppearanceSheet,
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context, {
    required AppLocalizations l10n,
    required Color accentColor,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Semantics(
        button: true,
        label: l10n.logout,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: OutlinedButton(
            onPressed: _isLoggingOut ? null : _handleLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: _isLoggingOut
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: accentColor,
                    ),
                  )
                : Text(l10n.logout),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SETTINGS ROW WIDGET
// ─────────────────────────────────────────────────────────────

class _SettingsRowWidget extends StatelessWidget {
  const _SettingsRowWidget({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashFactory: InkRipple.splashFactory,
          hoverColor: cs.primary.withValues(alpha: 0.06),
          focusColor: cs.primary.withValues(alpha: 0.10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 24, color: iconColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
                Icon(Icons.chevron_right_rounded, size: 24, color: iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// THEME OPTION FOR BOTTOM SHEET
// ─────────────────────────────────────────────────────────────

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: selected ? cs.primary : cs.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const Spacer(),
              if (selected)
                Icon(Icons.check_rounded, size: 22, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }
}
