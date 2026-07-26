import 'package:flutter/material.dart';

/// A thin metallic-gold gradient border wrapper.
///
/// Place this around any card or container to give it a subtle metallic-gold
/// outline. The border is rendered by wrapping the child in a parent
/// [Container] with a [LinearGradient] decoration, then using a small
/// [padding] of 1.3 to let the gradient show through as a thin border.
///
/// Usage:
/// ```dart
/// MetallicGoldBorder(
///   borderRadius: BorderRadius.circular(34),
///   child: existingCard,
/// )
/// ```
class MetallicGoldBorder extends StatelessWidget {
  const MetallicGoldBorder({
    super.key,
    required this.child,
    required this.borderRadius,
    this.padding = 1.3,
    this.muted = false,
    this.margin,
    this.clipBehavior = Clip.hardEdge,
    this.innerBackgroundColor,
    this.boxShadow,
    this.gradientOpacity = 1.0,
  });

  /// The widget to wrap with a metallic-gold border.
  final Widget child;

  /// The border radius — must match the inner widget's radius.
  final BorderRadius borderRadius;

  /// The gap used to produce the border thickness (default 1.3).
  final double padding;

  /// If true, use a muted gold palette (for disabled buttons, etc.).
  final bool muted;

  /// Optional margin around the outer container.
  final EdgeInsetsGeometry? margin;

  /// Clip behavior for the inner child wrapper.
  /// Defaults to [Clip.hardEdge] but set to [Clip.none] if the child
  /// needs to overflow (e.g. a raised button).
  final Clip clipBehavior;

  /// Optional background color for the inner content area.
  /// If null, the child is placed directly (child's own background is used).
  final Color? innerBackgroundColor;

  /// Optional list of box shadows. If null, defaults to [goldGlow].
  /// Pass an empty list `[]` to remove glow entirely.
  /// Pass a custom list to override the glow.
  final List<BoxShadow>? boxShadow;

  /// Opacity multiplier for the gold gradient (0.0 – 1.0).
  /// Use a lower value like 0.6 to reduce gold accent strength.
  final double gradientOpacity;

  /// Standard metallic-gold gradient.
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF2A6), // Champagne highlight
      Color(0xFFE3B94F), // Primary gold
      Color(0xFFA86D16), // Deep gold
      Color(0xFFF4D675), // Soft highlight
    ],
    stops: [0.0, 0.35, 0.72, 1.0],
  );

  /// Muted gold gradient for disabled states.
  static const LinearGradient mutedGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8D89F),
      Color(0xFFC4A34A),
      Color(0xFF8E5E14),
      Color(0xFFD4B56A),
    ],
    stops: [0.0, 0.35, 0.72, 1.0],
  );

  /// Subtle gold glow shadow.
  static const BoxShadow goldGlow = BoxShadow(
    color: Color(0x1AD9A62E),
    blurRadius: 8,
    spreadRadius: 0,
  );

  @override
  Widget build(BuildContext context) {
    final gradient = muted ? mutedGoldGradient : goldGradient;
    final effectiveGradient = gradientOpacity < 1.0
        ? LinearGradient(
            begin: gradient.begin,
            end: gradient.end,
            colors: gradient.colors
                .map((c) => c.withValues(alpha: gradientOpacity))
                .toList(),
            stops: gradient.stops,
          )
        : gradient;

    final effectiveBoxShadow = boxShadow ?? const [goldGlow];

    // Compute the inner radius so the child's corners align with the
    // border's inner edge.  We assume a uniform radius for simplicity.
    final outerRadius = borderRadius.resolve(TextDirection.ltr).topLeft.x;
    final innerRadius = (outerRadius - padding).clamp(0.0, outerRadius);

    return Container(
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: borderRadius,
        boxShadow: effectiveBoxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(innerRadius)),
        child: child,
      ),
    );
  }
}
