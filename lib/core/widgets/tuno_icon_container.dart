import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TunoIconContainer extends StatelessWidget {
  const TunoIconContainer({
    super.key,
    required this.icon,
    this.size = 56,
    this.iconSize = 28,
    this.useGradient = false,
    this.goldAccent = false,
    this.iconColor,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final bool useGradient;
  final bool goldAccent;
  final Color? iconColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Container container = Container(
      width: size,
      height: size,
      decoration: _buildDecoration(cs, isDark),
      child: Center(
        child: Icon(icon, size: iconSize, color: _resolveIconColor(cs, isDark)),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(label: semanticLabel!, child: container);
    }

    return container;
  }

  BoxDecoration _buildDecoration(ColorScheme cs, bool isDark) {
    if (useGradient) {
      return BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF16BFC0), Color(0xFF0073AE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    if (goldAccent) {
      final bgColor = isDark
          ? AppColors.tunoGold.withValues(alpha: 0.12)
          : AppColors.tunoGold.withValues(alpha: 0.10);
      final borderColor = isDark
          ? AppColors.tunoGold.withValues(alpha: 0.35)
          : AppColors.tunoGold.withValues(alpha: 0.40);
      return BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
      );
    }

    final surfaceColor = isDark
        ? AppColors.tunoDarkIconSurface
        : AppColors.tunoLightSurface;
    final borderColor = isDark
        ? AppColors.tunoDarkBorder.withValues(alpha: 0.5)
        : AppColors.tunoLightBorder;

    return BoxDecoration(
      shape: BoxShape.circle,
      color: surfaceColor,
      border: Border.all(color: borderColor, width: 1),
    );
  }

  Color _resolveIconColor(ColorScheme cs, bool isDark) {
    if (iconColor != null) return iconColor!;
    if (useGradient) return Colors.white;
    if (goldAccent) return AppColors.tunoGold;
    return isDark ? AppColors.tunoCyan : AppColors.tunoTeal;
  }
}
