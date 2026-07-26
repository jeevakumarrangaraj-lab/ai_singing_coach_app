import 'package:flutter/material.dart';

/// A fully native Flutter microphone emblem built with [CustomPainter] for
/// the layered circular decoration and a real [Icon] widget for the mic glyph.
///
/// The [diameter] is in the 1024×1536 design space (typically 360 on welcome).
/// Set [compact] to true for small header emblems (~64–72px).
class TunoMicrophoneEmblem extends StatelessWidget {
  const TunoMicrophoneEmblem({
    super.key,
    required this.diameter,
    this.compact = false,
  });

  /// Outer diameter in the 1024×1536 design canvas.
  final double diameter;

  /// Compact mode for small header emblems (~64–72px).
  /// Draws a single centered microphone with minimal waveform pills.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tuno microphone',
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          children: [
            // All circular art via CustomPainter
            CustomPaint(
              painter: _MicrophoneEmblemPainter(
                diameter: diameter,
                compact: compact,
              ),
              size: Size(diameter, diameter),
            ),
            // Real Icon widget for clean scaling (hidden in compact mode since
            // the mic is painted by CustomPainter for proper scaling/clipping)
            if (!compact)
              Center(
                child: Icon(
                  Icons.mic_rounded,
                  size: diameter * 0.43,
                  color: const Color(0xFFF7F7F7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MicrophoneEmblemPainter extends CustomPainter {
  _MicrophoneEmblemPainter({required this.diameter, this.compact = false});

  final double diameter;
  final bool compact;

  double get _r => diameter / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = _r;

    // ───────────────────────────────────────────────────────────
    // 1. External gold glow — stroke-only, drawn BEFORE the fill
    // ───────────────────────────────────────────────────────────
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = diameter * 0.025
      ..color = const Color(0xFFD9A62E).withValues(alpha: 0.32)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, diameter * 0.035);
    canvas.drawCircle(center, r + 2, glowPaint);

    // ───────────────────────────────────────────────────────────
    // 2. Opaque dark base — prevents glow bleed into interior
    // ───────────────────────────────────────────────────────────
    canvas.drawCircle(center, r - 3, Paint()..color = const Color(0xFF014065));

    // ───────────────────────────────────────────────────────────
    // 3. Cyan-to-navy emblem gradient (exact spec colors — no green/mint)
    // ───────────────────────────────────────────────────────────
    const emblemGradient = LinearGradient(
      begin: Alignment(-0.75, -0.85),
      end: Alignment(0.80, 0.90),
      colors: [Color(0xFF00A6BA), Color(0xFF007F9C), Color(0xFF014065)],
      stops: [0.0, 0.55, 1.0],
    );

    final emblemRect = Rect.fromCircle(center: center, radius: r - 5);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = emblemGradient.createShader(emblemRect);

    canvas.drawCircle(center, r - 5, fillPaint);

    // ───────────────────────────────────────────────────────────
    // 4. White radial highlight (neutral white only)
    // ───────────────────────────────────────────────────────────
    const highlightGradient = RadialGradient(
      center: Alignment(-0.45, -0.55),
      radius: 0.85,
      colors: [Color(0x1FFFFFFF), Color(0x08FFFFFF), Color(0x00FFFFFF)],
      stops: [0.0, 0.48, 1.0],
    );

    final highlightPaint = Paint()
      ..shader = highlightGradient.createShader(emblemRect);

    canvas.drawCircle(center, r - 5, highlightPaint);

    // ───────────────────────────────────────────────────────────
    // 5. Cyan inner rim (2px stroke)
    // ───────────────────────────────────────────────────────────
    final cyanInnerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFF21C9D3);
    canvas.drawCircle(center, r - 5.0, cyanInnerPaint);

    // ───────────────────────────────────────────────────────────
    // 6. Metallic-gold outer ring (SweepGradient, stroke only)
    // ───────────────────────────────────────────────────────────
    const goldSweepGradient = SweepGradient(
      colors: [
        Color(0xFFFFF2A6),
        Color(0xFFE3B94F),
        Color(0xFFA86D16),
        Color(0xFFF4D675),
        Color(0xFFFFF2A6),
      ],
    );

    final goldRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..shader = goldSweepGradient.createShader(
        Rect.fromCircle(center: center, radius: r - 1.5),
      );
    canvas.drawCircle(center, r - 1.5, goldRingPaint);

    if (compact) {
      _drawCompactMicrophone(canvas, center, r);
      _drawCompactWaveformPills(canvas, center, r);
    } else {
      // ───────────────────────────────────────────────────────────
      // 7. White waveform pills (pure white) - full size
      // ───────────────────────────────────────────────────────────
      _drawWaveformDots(canvas, center, r);
    }
  }

  void _drawCompactMicrophone(Canvas canvas, Offset center, double r) {
    // Microphone body: centered, ~42-45% of diameter
    final micWidth = r * 0.42;
    final micHeight = r * 0.85;
    final micLeft = center.dx - micWidth / 2;
    final micTop = center.dy - micHeight / 2;
    final micRect = Rect.fromLTWH(micLeft, micTop, micWidth, micHeight);

    // Microphone body - rounded rectangle
    final micPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFF7F7F7);

    final micRRect = RRect.fromRectAndRadius(
      micRect,
      Radius.circular(micWidth / 2),
    );
    canvas.drawRRect(micRRect, micPaint);

    // Microphone stand - small base
    final standWidth = micWidth * 0.35;
    final standHeight = micHeight * 0.18;
    final standLeft = center.dx - standWidth / 2;
    final standTop = micRect.bottom - standHeight * 0.5;
    final standRect = Rect.fromLTWH(
      standLeft,
      standTop,
      standWidth,
      standHeight,
    );

    final standRRect = RRect.fromRectAndRadius(
      standRect,
      Radius.circular(standWidth / 2),
    );
    canvas.drawRRect(standRRect, micPaint);

    // Microphone cord - small arc at bottom
    final cordPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFF7F7F7)
      ..strokeCap = StrokeCap.round;

    final cordRect = Rect.fromCircle(
      center: Offset(center.dx, standRect.bottom + standHeight * 0.3),
      radius: standWidth * 0.7,
    );
    canvas.drawArc(cordRect, 3.14 * 0.2, 3.14 * 0.6, false, cordPaint);
  }

  void _drawCompactWaveformPills(Canvas canvas, Offset center, double r) {
    // Three very small waveform pills on each side
    const columnCount = 3;
    final colStartY = center.dy - r * 0.4;
    final colEndY = center.dy + r * 0.4;
    final colSpacing = (colEndY - colStartY) / (columnCount - 1);

    final micRightX = center.dx + r * 0.21; // Right edge of microphone
    final micLeftX = center.dx - r * 0.21; // Left edge of microphone

    // Pills placed further out to avoid overlapping mic
    final leftStartX = micLeftX - r * 0.18;
    final rightStartX = micRightX + r * 0.18;

    for (int col = 0; col < columnCount; col++) {
      // Very small pill size for compact mode
      final pillWidth = r * 0.055;
      final pillHeight = pillWidth * 2.2;
      final y = colStartY + col * colSpacing;

      // Opacity: brighter in center
      final dotAlpha = 0.7 - (col - 1).abs() * 0.15;

      final dotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFF7F7F7).withValues(alpha: dotAlpha);

      // Left side pills
      final leftRect = Rect.fromCenter(
        center: Offset(leftStartX - col * r * 0.025, y),
        width: pillWidth,
        height: pillHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(leftRect, Radius.circular(pillWidth / 2)),
        dotPaint,
      );

      // Right side mirror
      final rightRect = Rect.fromCenter(
        center: Offset(rightStartX + col * r * 0.025, y),
        width: pillWidth,
        height: pillHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rightRect, Radius.circular(pillWidth / 2)),
        dotPaint,
      );
    }
  }

  void _drawWaveformDots(Canvas canvas, Offset center, double r) {
    // Microphone icon occupies ~43% of diameter → radius ~0.215 * diameter = r * 0.43
    // Pills must stay outside this zone. We place them starting at mic edge + padding.
    const columnCount = 5;
    final colStartY = center.dy - r * 0.48;
    final colEndY = center.dy + r * 0.48;
    final colSpacing = (colEndY - colStartY) / (columnCount - 1);

    // Mic half-width in radius units: Icon size = diameter * 0.43 → half = r * 0.43
    final micHalfWidth = r * 0.43;
    // Padding between mic edge and first pill
    const micPadding = 4.0;
    // Base X distance from center where leftmost/rightmost pills start
    final leftBaseX = center.dx - (micHalfWidth + micPadding);
    final rightBaseX = center.dx + (micHalfWidth + micPadding);

    // Draw 5 symmetric pills per side, spacing them outward from the mic
    for (int col = 0; col < columnCount; col++) {
      // Pills get slightly larger toward the mic, smaller outward
      final pillWidth = (5 - col) * 1.2 + 2.0;
      final pillHeight = pillWidth * 2.8;
      final y = colStartY + col * colSpacing;

      // Opacity: brighter near center
      final dotAlpha = 0.70 - (col * 0.08).clamp(0.0, 0.30);

      final dotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFF7F7F7).withValues(alpha: dotAlpha);

      // Left side: place pills from mic edge outward (col 0 = nearest mic)
      final leftX = leftBaseX - col * (pillWidth * 1.4);
      final leftRect = Rect.fromCenter(
        center: Offset(leftX, y),
        width: pillWidth,
        height: pillHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(leftRect, Radius.circular(pillWidth / 2)),
        dotPaint,
      );

      // Right side: mirror
      final rightX = rightBaseX + col * (pillWidth * 1.4);
      final rightRect = Rect.fromCenter(
        center: Offset(rightX, y),
        width: pillWidth,
        height: pillHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rightRect, Radius.circular(pillWidth / 2)),
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MicrophoneEmblemPainter oldDelegate) {
    return oldDelegate.diameter != diameter || oldDelegate.compact != compact;
  }
}
