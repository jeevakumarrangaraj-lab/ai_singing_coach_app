import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_singing_coach/l10n/app_localizations.dart';

import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/tuno_dashboard_background.dart';
import '../../../../core/widgets/tuno_bottom_navigation.dart';

/// Data model for a practice mode option card.
class _PracticeMode {
  final String title;
  final String description;
  final IconData icon;
  final bool isAvailable;
  final String? route;
  final String snackBarMessage;

  const _PracticeMode({
    required this.title,
    required this.description,
    required this.icon,
    required this.isAvailable,
    this.route,
    required this.snackBarMessage,
  });
}

List<_PracticeMode> _practiceModes(AppLocalizations l10n) => [
  _PracticeMode(
    title: l10n.soloPractice,
    description: l10n.soloPracticeDesc,
    icon: Icons.mic_rounded,
    isAvailable: true,
    route: '/practice',
    snackBarMessage: '',
  ),
  _PracticeMode(
    title: l10n.tunoExercises,
    description: l10n.tunoExercisesDesc,
    icon: Icons.equalizer_rounded,
    isAvailable: false,
    snackBarMessage: l10n.tunoExercisesComingSoon,
  ),
  _PracticeMode(
    title: l10n.uploadSong,
    description: l10n.uploadSongDesc,
    icon: Icons.upload_file_rounded,
    isAvailable: true,
    route: '/practice/upload',
    snackBarMessage: '',
  ),
  _PracticeMode(
    title: l10n.backingTrack,
    description: l10n.backingTrackDesc,
    icon: Icons.music_note_rounded,
    isAvailable: false,
    snackBarMessage: l10n.backingTracksComingSoon,
  ),
];

class PracticeModeScreen extends StatefulWidget {
  const PracticeModeScreen({super.key});

  @override
  State<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  int _currentNavIndex = 1;

  void _onDestinationSelected(int index) {
    if (index == _currentNavIndex) return;
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        // Stay on this screen
        break;
      case 2:
        context.push('/practice');
        break;
      case 3:
        _showComingSoon(l10n.progress);
        break;
      case 4:
        _showComingSoon(l10n.profile);
        break;
    }
    if (index != _currentNavIndex) {
      setState(() => _currentNavIndex = index);
    }
  }

  void _showComingSoon(String feature) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
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
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: TunoDashboardBackground(
        animate: true,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
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
                            Text(
                              l10n.choosePracticeMode,
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.whatWouldYouLikeToDo,
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 28),
                            // ── Practice mode cards ──
                            ..._practiceModes(l10n).map(
                              (mode) => Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: _ModeCard(mode: mode, l10n: l10n),
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
      ),
      bottomNavigationBar: TunoBottomNavigation(
        currentIndex: _currentNavIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRACTICE MODE CARD — Premium dark translucent navy gradient
// ─────────────────────────────────────────────────────────────

class _ModeCard extends StatefulWidget {
  const _ModeCard({required this.mode, required this.l10n});

  final _PracticeMode mode;
  final AppLocalizations l10n;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mode = widget.mode;
    final l10n = widget.l10n;

    // Card: dark translucent navy gradient, border, cyan inner highlight
    final cardGradient = AppColors.practiceCardGradient;
    final borderColor = _isHovered && mode.isAvailable
        ? AppColors.cyanAccent.withValues(alpha: 0.50)
        : AppColors.borderBlue.withValues(alpha: 0.85);
    final borderRadius = BorderRadius.circular(22);

    final scale = _isPressed && mode.isAvailable ? 0.985 : 1.0;

    return Semantics(
      button: true,
      label: mode.isAvailable
          ? l10n.tapToStart(mode.title, mode.description)
          : l10n.modeNotAvailable(mode.title, mode.description),
      enabled: mode.isAvailable,
      child: Tooltip(
        message: mode.isAvailable
            ? mode.title
            : l10n.modeComingSoon(mode.title),
        child: MouseRegion(
          cursor: mode.isAvailable
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) {
            if (mode.isAvailable) setState(() => _isHovered = true);
          },
          onExit: (_) => setState(() {
            _isHovered = false;
            _isPressed = false;
          }),
          child: GestureDetector(
            onTapDown: mode.isAvailable
                ? (_) => setState(() => _isPressed = true)
                : null,
            onTapUp: mode.isAvailable
                ? (_) => setState(() => _isPressed = false)
                : null,
            onTapCancel: mode.isAvailable
                ? () => setState(() => _isPressed = false)
                : null,
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleTap(context),
                  borderRadius: borderRadius,
                  splashFactory: InkRipple.splashFactory,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 56),
                    decoration: BoxDecoration(
                      gradient: cardGradient,
                      borderRadius: borderRadius,
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.baseNavy.withValues(alpha: 0.45),
                          blurRadius: 16,
                          spreadRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Subtle cyan inner highlight along the top edge
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColors.cyanAccent.withValues(alpha: 0.0),
                                  AppColors.cyanAccent.withValues(alpha: 0.30),
                                  AppColors.cyanAccent.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 20,
                          ),
                          child: Row(
                            children: [
                              // ── Icon emblem with metallic gold ring + cyan glow ──
                              _IconEmblem(
                                icon: mode.icon,
                                isHovered: _isHovered,
                              ),
                              const SizedBox(width: 18),
                              // ── Title + description ──
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      mode.title,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: cs.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      mode.description,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontSize: 13,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // ── Forward chevron ──
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 24,
                                color: AppColors.cyanAccent,
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
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    final mode = widget.mode;
    if (mode.isAvailable && mode.route != null) {
      context.push(mode.route!);
    } else if (!mode.isAvailable) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mode.snackBarMessage),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────
// CIRCULAR ICON EMBLEM with teal-to-blue gradient,
// metallic-gold outer ring, and subtle cyan glow behind
// ─────────────────────────────────────────────────────────────

class _IconEmblem extends StatelessWidget {
  const _IconEmblem({required this.icon, this.isHovered = false});

  final IconData icon;
  final bool isHovered;

  static const double _diameter = 54;
  static const double _goldRingWidth = 2.0;

  // Emblem gradient: cyan → teal → deep blue
  static const LinearGradient _emblemGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00A6BA), Color(0xFF007F9C), Color(0xFF014B75)],
  );

  // Metallic-gold sweep gradient for the outer ring
  static const SweepGradient _goldRingGradient = SweepGradient(
    colors: [
      Color(0xFFFFF2A6),
      Color(0xFFE3B94F),
      Color(0xFFA86D16),
      Color(0xFFF4D675),
      Color(0xFFFFF2A6),
    ],
    stops: [0.0, 0.25, 0.50, 0.75, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final radius = _diameter / 2;
    final center = Offset(radius, radius);

    return SizedBox(
      width: _diameter,
      height: _diameter,
      child: Stack(
        children: [
          // ── Subtle cyan glow behind the circle ──
          if (isHovered)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyanAccent.withValues(alpha: 0.20),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          // ── Metallic-gold outer ring ──
          Positioned.fill(
            child: CustomPaint(
              painter: _GoldRingPainter(
                gradient: _goldRingGradient,
                strokeWidth: _goldRingWidth,
                radius: radius - _goldRingWidth / 2,
                center: center,
              ),
            ),
          ),
          // ── Teal-to-blue gradient circle ──
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(_goldRingWidth),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _emblemGradient,
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a thin metallic-gold ring using a SweepGradient.
class _GoldRingPainter extends CustomPainter {
  const _GoldRingPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.radius,
    required this.center,
  });

  final SweepGradient gradient;
  final double strokeWidth;
  final double radius;
  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldRingPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.center != center;
  }
}
