import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TunoGradientButton extends StatefulWidget {
  const TunoGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.trailingIconColor,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 56,
    this.borderRadius = 20,
    this.semanticLabel,
    this.labelFontSize,
    this.labelFontWeight,
    this.trailingIconSize = 20,
    this.gradient,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final Color? trailingIconColor;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final double borderRadius;
  final String? semanticLabel;
  final double? labelFontSize;
  final FontWeight? labelFontWeight;
  final double trailingIconSize;
  final Gradient? gradient;

  @override
  State<TunoGradientButton> createState() => _TunoGradientButtonState();
}

class _TunoGradientButtonState extends State<TunoGradientButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final cs = Theme.of(context).colorScheme;

    final gradient = widget.gradient ?? AppColors.tunoMainGradient;
    final shadowColor = _hovered || _focused
        ? AppColors.tunoCyan.withValues(alpha: 0.35)
        : AppColors.tunoDeepBlue.withValues(alpha: 0.25);

    final button = Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: Container(
            height: widget.height,
            width: widget.fullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: enabled ? gradient : _disabledGradient(cs),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: _hovered || _focused ? 16 : 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: InkWell(
                onTap: enabled ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: Colors.white.withValues(alpha: 0.18),
                highlightColor: Colors.white.withValues(alpha: 0.10),
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                child: Center(child: _buildContent(enabled)),
              ),
            ),
          ),
        ),
      ),
    );

    return button;
  }

  Widget _buildContent(bool enabled) {
    if (widget.isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final color = enabled ? Colors.white : Colors.white.withValues(alpha: 0.7);

    final labelText = Text(
      widget.label,
      style: TextStyle(
        color: color,
        fontSize: widget.labelFontSize ?? 16,
        fontWeight: widget.labelFontWeight ?? FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );

    // Trailing-icon mode — use Stack with finite constraints.
    if (widget.trailingIcon != null) {
      final effectiveIconColor = (widget.trailingIconColor ?? Colors.white)
          .withValues(alpha: enabled ? 1.0 : 0.7);

      final iconSize = widget.trailingIconSize;
      final endPad = iconSize > 20 ? 36.0 : 28.0;

      return SizedBox(
        width: double.infinity,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(child: labelText),
            PositionedDirectional(
              end: endPad,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  widget.trailingIcon,
                  size: iconSize,
                  color: effectiveIconColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Leading-icon mode (existing behaviour).
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20, color: color),
          const SizedBox(width: 10),
          labelText,
        ],
      );
    }

    return labelText;
  }

  LinearGradient _disabledGradient(ColorScheme cs) {
    return LinearGradient(
      colors: [
        cs.onSurface.withValues(alpha: 0.12),
        cs.onSurface.withValues(alpha: 0.08),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
