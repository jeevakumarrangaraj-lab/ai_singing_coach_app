import 'package:flutter/material.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import 'metallic_gold_border.dart';

/// Tuno themed bottom navigation bar with five destinations.
///
/// Displays Home, Practice, Record, Progress, and Profile destinations.
/// The center Record button is visually distinct — larger, circular, with a
/// gradient fill and gold border, slightly raised above the navigation bar.
///
/// Features:
/// - InkWell ripple, hover, and focus states for web/keyboard support
/// - Semantics and tooltips on every interactive element
/// - Minimum 48px touch targets
/// - Responsive between mobile and tablet widths
/// - No hardcoded routes — navigation delegated via [onDestinationSelected]
///
/// ## Parameters
/// - [currentIndex] — the index of the currently selected destination (0–4)
/// - [onDestinationSelected] — callback invoked when a destination is tapped
class TunoBottomNavigation extends StatelessWidget {
  const TunoBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// Index of the currently selected destination (0–4).
  final int currentIndex;

  /// Called when a destination is tapped.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final l10n = AppLocalizations.of(context)!;

    final navLabels = [
      l10n.home,
      l10n.practice,
      l10n.record,
      l10n.progress,
      l10n.profile,
    ];

    return MetallicGoldBorder(
      borderRadius: BorderRadius.circular(22),
      padding: 1.0,
      boxShadow: const [],
      clipBehavior: Clip.none,
      margin: EdgeInsets.fromLTRB(
        isTablet ? 48 : 12,
        0,
        isTablet ? 48 : 12,
        isTablet ? 12 : 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20.7),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        clipBehavior: Clip.none,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 24 : 8,
              20,
              isTablet ? 24 : 8,
              4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int i = 0; i < 5; i++)
                  if (i == 2)
                    _RecordButton(
                      selected: currentIndex == i,
                      onTap: () => onDestinationSelected(i),
                      isTablet: isTablet,
                      label: navLabels[i],
                    )
                  else
                    _NavItem(
                      icon: _navIcons[i],
                      label: navLabels[i],
                      selected: currentIndex == i,
                      onTap: () => onDestinationSelected(i),
                      isTablet: isTablet,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _navIcons = [
  Icons.home_rounded,
  Icons.mic_none_rounded,
  Icons.mic_rounded,
  Icons.bar_chart_rounded,
  Icons.person_outline_rounded,
];

// ─────────────────────────────────────────────────────────────
// Regular navigation item (indices 0, 1, 3, 4)
// ─────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isTablet,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashFactory: InkRipple.splashFactory,
          hoverColor: cs.primary.withValues(alpha: 0.08),
          focusColor: cs.primary.withValues(alpha: 0.12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 10 : 6,
                vertical: 4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: isTablet ? 26 : 24, color: color),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Center Record button (index 2)
// ─────────────────────────────────────────────────────────────

class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.selected,
    required this.onTap,
    required this.isTablet,
    required this.label,
  });

  final bool selected;
  final VoidCallback onTap;
  final bool isTablet;
  final String label;

  @override
  Widget build(BuildContext context) {
    final size = isTablet ? 64.0 : 56.0;
    final iconSize = isTablet ? 30.0 : 26.0;
    final goldCenter = Offset(size / 2, size / 2);
    final goldRadius = size / 2 - 1.0;

    // Metallic-gold sweep gradient for the ring
    const goldSweepGradient = SweepGradient(
      colors: [
        Color(0xFFFFF2A6),
        Color(0xFFE3B94F),
        Color(0xFFA86D16),
        Color(0xFFF4D675),
        Color(0xFFFFF2A6),
      ],
    );

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          splashFactory: InkRipple.splashFactory,
          child: Transform.translate(
            offset: const Offset(0, -12),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.tunoMainGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tunoDeepBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Metallic-gold ring via CustomPaint
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _GoldRingPainter(
                          gradient: goldSweepGradient,
                          strokeWidth: 2.5,
                          radius: goldRadius,
                          center: goldCenter,
                        ),
                      ),
                    ),
                  ),
                  // Microphone icon
                  Center(
                    child: Icon(
                      Icons.mic_rounded,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
