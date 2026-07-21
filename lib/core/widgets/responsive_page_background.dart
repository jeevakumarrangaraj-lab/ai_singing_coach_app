import 'package:flutter/material.dart';

class ResponsivePageBackground extends StatelessWidget {
  const ResponsivePageBackground({
    super.key,
    required this.imagePath,
    required this.child,
    this.mobileAlignment = Alignment.center,
    this.wideAlignment = Alignment.bottomCenter,
    this.mobileOverlayAlpha = 0.25,
    this.wideOverlayAlpha = 0.16,
    this.useSafeArea = true,
    this.maxContentWidth,
  });

  final String imagePath;
  final Widget child;
  final Alignment mobileAlignment;
  final Alignment wideAlignment;
  final double mobileOverlayAlpha;
  final double wideOverlayAlpha;
  final bool useSafeArea;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: isWide ? wideAlignment : mobileAlignment,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(
                  alpha: isWide ? wideOverlayAlpha : mobileOverlayAlpha,
                ),
              ),
            ),
            _ContentLayer(
              useSafeArea: useSafeArea,
              maxContentWidth: maxContentWidth,
              child: child,
            ),
          ],
        );
      },
    );
  }
}

class _ContentLayer extends StatelessWidget {
  const _ContentLayer({
    required this.useSafeArea,
    required this.maxContentWidth,
    required this.child,
  });

  final bool useSafeArea;
  final double? maxContentWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    if (maxContentWidth != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth!),
          child: content,
        ),
      );
    }

    return content;
  }
}
