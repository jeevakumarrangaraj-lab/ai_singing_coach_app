import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/dashboard_music_decorations.dart';
import '../core/widgets/metallic_gold_border.dart';
import '../core/widgets/tuno_bottom_navigation.dart';
import '../core/widgets/tuno_microphone_emblem.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/notifications/presentation/notification_controller.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentNavIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        break;
      case 1:
        context.push('/practice/modes');
        break;
      case 2:
        context.push('/practice');
        break;
      case 3:
        _showComingSoon(l10n.progress, l10n);
        break;
      case 4:
        _showComingSoon(l10n.profile, l10n);
        break;
    }
    if (index != _currentNavIndex) {
      setState(() => _currentNavIndex = index);
    }
  }

  void _showComingSoon(String feature, AppLocalizations l10n) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.featureComingSoonSimple(feature)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : l10n.tunoSinger;
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = ref.watch(
      notificationControllerProvider.select((s) => s.unreadCount),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Stack(
                children: [
                  // ── Background musical decorations ──
                  // Paints across the full scrollable content.
                  // Wrapped with IgnorePointer so taps pass through.
                  Positioned.fill(
                    child: const IgnorePointer(
                      ignoring: true,
                      child: DashboardMusicDecorations(animate: true),
                    ),
                  ),
                  // ── Foreground content ──
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header (Tuno logo + icons) ──
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 8, 0, 8),
                              child: Row(
                                children: [
                                  Text(
                                    l10n.tuno,
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  _NotificationBellButton(
                                    unreadCount: unreadCount,
                                    onPressed: () =>
                                        context.push('/notifications'),
                                    l10n: l10n,
                                  ),
                                  const SizedBox(width: 8),
                                  _HeaderIconButton(
                                    icon: Icons.settings_rounded,
                                    tooltip: l10n.settings,
                                    onPressed: () => context.push('/settings'),
                                  ),
                                ],
                              ),
                            ),
                            // ── Greeting ──
                            const SizedBox(height: 30),
                            Text(
                              l10n.helloUser(displayName),
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.readyToImprove,
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                color: cs.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // ── Main Practice Card ──
                            _MainPracticeCard(
                              onTap: () => context.push('/practice/modes'),
                              l10n: l10n,
                            ),
                            const SizedBox(height: 32),

                            // ── Progress Section ──
                            Text(
                              l10n.yourProgress,
                              style: textTheme.headlineSmall?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final useRow = constraints.maxWidth >= 400;
                                if (useRow) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _PracticeProgressCard(
                                          isDark: isDark,
                                          l10n: l10n,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _StreakProgressCard(
                                          isDark: isDark,
                                          l10n: l10n,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _PracticeProgressCard(
                                      isDark: isDark,
                                      l10n: l10n,
                                    ),
                                    const SizedBox(height: 14),
                                    _StreakProgressCard(
                                      isDark: isDark,
                                      l10n: l10n,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 32),

                            // ── Recording Library Card ──
                            _RecordingLibraryCard(
                              onTap: () => context.push('/recording-library'),
                              l10n: l10n,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: TunoBottomNavigation(
        currentIndex: _currentNavIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}

/// Notification bell header button with unread badge.
///
/// Shows a small cyan badge when [unreadCount] > 0.
/// Badge displays the exact number up to 99, then "99+".
class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton({
    required this.unreadCount,
    required this.onPressed,
    required this.l10n,
  });

  final int unreadCount;
  final VoidCallback onPressed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showBadge = unreadCount > 0;

    final semanticsLabel = showBadge
        ? l10n.unreadCountSemantic(unreadCount)
        : l10n.notifications;

    return Tooltip(
      message: l10n.notifications,
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            hoverColor: cs.onSurface.withValues(alpha: 0.06),
            focusColor: cs.onSurface.withValues(alpha: 0.10),
            splashColor: cs.onSurface.withValues(alpha: 0.12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 24,
                      color: cs.onSurface,
                    ),
                    if (showBadge)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF12B5C1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Header icon button with tooltip, semantics, and 48px touch target.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            hoverColor: cs.onSurface.withValues(alpha: 0.06),
            focusColor: cs.onSurface.withValues(alpha: 0.10),
            splashColor: cs.onSurface.withValues(alpha: 0.12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, size: 24, color: cs.onSurface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Main Practice Card with TunoMicrophoneEmblem and gradient CTA.
/// Reference bounds: x=52, y=405, width=918, height=553, radius ~34.
class _MainPracticeCard extends StatelessWidget {
  const _MainPracticeCard({required this.onTap, required this.l10n});

  final VoidCallback onTap;
  final AppLocalizations l10n;

  // CTA gradient: cyan-to-deep-blue
  static const _ctaGradient = LinearGradient(
    colors: [Color(0xFF008BA6), Color(0xFF006D98), Color(0xFF014B75)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.52, 1.0],
  );

  // Metallic-gold border gradient (thin highlight)
  static const _goldBorderGradient = LinearGradient(
    colors: [
      Color(0xFFFFF2A6),
      Color(0xFFE3B94F),
      Color(0xFFA86D16),
      Color(0xFFF4D675),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MetallicGoldBorder(
      borderRadius: BorderRadius.circular(34),
      padding: 1.5,
      boxShadow: const [
        BoxShadow(color: Color(0x1AD9A62E), blurRadius: 5, spreadRadius: 0),
      ],
      child: Card(
        color: cs.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.7),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              // Microphone Emblem — reference size (~128 design px)
              TunoMicrophoneEmblem(diameter: 128, compact: false),
              // Gap after microphone
              const SizedBox(height: 24),
              Text(
                l10n.startVoicePractice,
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.recordAndGetFeedback,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Gradient CTA with thin metallic-gold highlight border
              Semantics(
                button: true,
                label: l10n.startPractice,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: _GradientCTAButton(
                    gradient: _ctaGradient,
                    goldBorderGradient: _goldBorderGradient,
                    onPressed: onTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.startPractice,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient CTA button with thin metallic-gold border layer.
class _GradientCTAButton extends StatefulWidget {
  const _GradientCTAButton({
    required this.gradient,
    required this.goldBorderGradient,
    required this.onPressed,
    required this.child,
  });

  final LinearGradient gradient;
  final LinearGradient goldBorderGradient;
  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_GradientCTAButton> createState() => _GradientCTAButtonState();
}

class _GradientCTAButtonState extends State<_GradientCTAButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final shadowColor = _hovered || _focused
        ? const Color(0xFF12B5C1).withValues(alpha: 0.35)
        : const Color(0xFF0069A0).withValues(alpha: 0.25);

    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: widget.gradient,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: _hovered || _focused ? 16 : 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Thin metallic-gold border layer (1px padding for thin highlight)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: widget.goldBorderGradient,
                    ),
                    padding: const EdgeInsets.all(1),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        gradient: widget.gradient,
                      ),
                    ),
                  ),
                ),
              ),
              // Button content
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.white.withValues(alpha: 0.18),
                  highlightColor: Colors.white.withValues(alpha: 0.10),
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  child: Center(child: widget.child),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Base progress card with shared styling.
class _ProgressCardBase extends StatelessWidget {
  const _ProgressCardBase({
    required this.child,
    required this.isDark,
    this.backgroundColor,
  });

  final Widget child;
  final bool isDark;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color:
          backgroundColor ??
          (isDark
              ? cs.surfaceContainerHighest.withValues(alpha: 0.8)
              : cs.surface),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      child: child,
    );
  }
}

/// Practice progress card with cyan accent.
/// Reference: left card ~x=52, width=440, height=265, ratio ~1.66.
class _PracticeProgressCard extends StatelessWidget {
  const _PracticeProgressCard({required this.isDark, required this.l10n});

  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cyan = isDark ? const Color(0xFF12B5C1) : const Color(0xFF008BA6);

    return AspectRatio(
      aspectRatio: 1.68,
      child: MetallicGoldBorder(
        borderRadius: BorderRadius.circular(19),
        padding: 1.0,
        boxShadow: const [],
        gradientOpacity: 0.6,
        child: _ProgressCardBase(
          isDark: isDark,
          backgroundColor: isDark
              ? const Color(0xFF061E31)
              : const Color(0xFFF3FAFF),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // White circular badge with stopwatch icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.timer_outlined, size: 22, color: cyan),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.zeroMin,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF062A5E),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.practiceLabel,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFA9B8C9)
                        : const Color(0xFF7890A8),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Streak progress card with metallic-gold accent.
/// Reference: right card ~x=530, width=440, height=265, ratio ~1.66.
class _StreakProgressCard extends StatelessWidget {
  const _StreakProgressCard({required this.isDark, required this.l10n});

  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final gold = isDark ? const Color(0xFFE3B94F) : const Color(0xFFB8860B);

    return AspectRatio(
      aspectRatio: 1.68,
      child: MetallicGoldBorder(
        borderRadius: BorderRadius.circular(19),
        padding: 1.0,
        boxShadow: const [],
        gradientOpacity: 0.6,
        child: _ProgressCardBase(
          isDark: isDark,
          backgroundColor: isDark
              ? const Color(0xFF061E31)
              : const Color(0xFFFFF8EA),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // White circular badge with flame icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    size: 22,
                    color: gold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.zeroDays,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF062A5E),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.streak,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFA9B8C9)
                        : const Color(0xFF7890A8),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Recording Library card with library/music-folder icon.
/// Navigates to /recording-library.
class _RecordingLibraryCard extends StatelessWidget {
  const _RecordingLibraryCard({
    required this.onTap,
    required this.l10n,
    required this.isDark,
  });

  final VoidCallback onTap;
  final AppLocalizations l10n;
  final bool isDark;

  static const _ctaGradient = LinearGradient(
    colors: [Color(0xFF008BA6), Color(0xFF006D98), Color(0xFF014B75)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.52, 1.0],
  );

  static const _goldBorderGradient = LinearGradient(
    colors: [
      Color(0xFFFFF2A6),
      Color(0xFFE3B94F),
      Color(0xFFA86D16),
      Color(0xFFF4D675),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MetallicGoldBorder(
      borderRadius: BorderRadius.circular(19),
      padding: 1.0,
      gradientOpacity: 0.6,
      boxShadow: const [
        BoxShadow(color: Color(0x1AD9A62E), blurRadius: 5, spreadRadius: 0),
      ],
      child: Card(
        color: isDark ? const Color(0xFF061E31) : const Color(0xFFF3FAFF),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Semantics(
          button: true,
          label: l10n.recordingLibrary,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: _GradientCTAButton(
              gradient: _ctaGradient,
              goldBorderGradient: _goldBorderGradient,
              onPressed: onTap,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.library_music_rounded,
                        size: 28,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.recordingLibrary,
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.yourSavedPracticeRecordings,
                            style: textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 28,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
