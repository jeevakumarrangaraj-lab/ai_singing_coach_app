import 'package:flutter/material.dart';
import 'dart:ui';

import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.borderWidth = 1,
    this.blurSigma = 12,
    this.borderColor,
    this.backgroundColor,
    this.shadowColor,
    this.shadowBlurRadius = 24,
    this.shadowSpreadRadius = 1,
    this.shadowOffset = const Offset(0, 8),
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double borderWidth;
  final double blurSigma;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        borderColor ?? Colors.white.withValues(alpha: 0.18);
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.deepPlum.withValues(alpha: 0.30);
    final effectiveShadowColor =
        shadowColor ?? AppColors.primaryMagenta.withValues(alpha: 0.14);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: effectiveBorderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: effectiveShadowColor,
                blurRadius: shadowBlurRadius,
                spreadRadius: shadowSpreadRadius,
                offset: shadowOffset,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
