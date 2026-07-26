import 'package:flutter/material.dart';

class TunoCard extends StatelessWidget {
  const TunoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.selected = false,
    this.goldAccent = false,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool selected;
  final bool goldAccent;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(16);

    final borderColor = _resolveBorderColor(cs, isDark);
    final surfaceColor = _resolveSurfaceColor(cs, isDark);
    final shadowColor = _resolveShadowColor(cs, isDark);

    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: selected ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Semantics(
        button: true,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashFactory: InkRipple.splashFactory,
            child: card,
          ),
        ),
      );
    }

    return card;
  }

  Color _resolveBorderColor(ColorScheme cs, bool isDark) {
    if (goldAccent) {
      return cs.tertiary;
    }
    if (selected) {
      return isDark ? cs.secondary : cs.primary;
    }
    return isDark ? cs.outline.withValues(alpha: 0.4) : cs.outlineVariant;
  }

  Color _resolveSurfaceColor(ColorScheme cs, bool isDark) {
    if (isDark) {
      return cs.surface;
    }
    return cs.surface;
  }

  Color _resolveShadowColor(ColorScheme cs, bool isDark) {
    if (isDark) {
      return cs.shadow.withValues(alpha: 0.15);
    }
    return cs.shadow.withValues(alpha: 0.06);
  }
}
