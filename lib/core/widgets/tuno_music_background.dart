import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum TunoMusicBackgroundVariant {
  topRight,
  bottomLeft,
  topAndBottom,
  centerRight,
  minimal,
  welcome,
  signup,
  login,
  dashboard,
  home,
}

/// Design canvas size used for the [welcome] variant.
const double _canvasWidth = 1024.0;
const double _canvasHeight = 1536.0;

class TunoMusicBackground extends StatelessWidget {
  const TunoMusicBackground({
    super.key,
    required this.child,
    this.variant = TunoMusicBackgroundVariant.topRight,
    this.showNotes = true,
    this.showWaves = true,
    this.opacity = 1.0,
  });

  final Widget child;
  final TunoMusicBackgroundVariant variant;
  final bool showNotes;
  final bool showWaves;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background art — uninteractive
        IgnorePointer(
          ignoring: true,
          child: CustomPaint(
            painter: _TunoMusicPainter(
              variant: variant,
              isDark: Theme.of(context).brightness == Brightness.dark,
              showNotes: showNotes,
              showWaves: showWaves,
              opacity: opacity,
            ),
          ),
        ),
        // Foreground content — fully interactive
        child,
      ],
    );
  }
}

class _TunoMusicPainter extends CustomPainter {
  _TunoMusicPainter({
    required this.variant,
    required this.isDark,
    required this.showNotes,
    required this.showWaves,
    required this.opacity,
  });

  final TunoMusicBackgroundVariant variant;
  final bool isDark;
  final bool showNotes;
  final bool showWaves;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (variant == TunoMusicBackgroundVariant.welcome) {
      // Scale canvas so all drawing uses fixed 1024×1536 coordinates.
      canvas.save();
      final scaleX = size.width / _canvasWidth;
      final scaleY = size.height / _canvasHeight;
      canvas.scale(scaleX, scaleY);
      _drawWelcomeBackground(canvas);
      canvas.restore();
      return;
    }

    if (variant == TunoMusicBackgroundVariant.signup) {
      // Uniform scale + center so decorations stay within centered composition
      canvas.save();
      final scaleX = size.width / _canvasWidth;
      final scaleY = size.height / _canvasHeight;
      final scale = scaleX < scaleY ? scaleX : scaleY;
      final offsetX = (size.width - _canvasWidth * scale) / 2;
      final offsetY = (size.height - _canvasHeight * scale) / 2;
      canvas.translate(offsetX, offsetY);
      canvas.scale(scale, scale);
      _drawSignupTopWaves(canvas);
      _drawSignupTopNotes(canvas);
      _drawSignupBottomWaves(canvas);
      canvas.restore();
      return;
    }

    if (variant == TunoMusicBackgroundVariant.login) {
      canvas.save();
      final scaleX = size.width / _canvasWidth;
      final scaleY = size.height / _canvasHeight;
      final scale = scaleX < scaleY ? scaleX : scaleY;
      final offsetX = (size.width - _canvasWidth * scale) / 2;
      final offsetY = (size.height - _canvasHeight * scale) / 2;
      canvas.translate(offsetX, offsetY);
      canvas.scale(scale, scale);
      if (showWaves) _drawLoginWaves(canvas);
      if (showNotes) _drawLoginNotes(canvas);
      canvas.restore();
      return;
    }

    if (variant == TunoMusicBackgroundVariant.dashboard) {
      // Dashboard decorations are now handled by the separate
      // DashboardMusicDecorations widget.
      return;
    }

    // ── Non-welcome variants (unchanged behaviour) ──
    final w = size.width;
    final h = size.height;

    final staffPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _staffColor()
      ..strokeCap = StrokeCap.round;

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _waveColor()
      ..strokeCap = StrokeCap.round;

    final notePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _noteFillColor();

    final noteOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _noteOutlineColor()
      ..strokeCap = StrokeCap.round;

    final staffPositions = _getStaffPositions(w, h);

    for (final pos in staffPositions) {
      final staffX = pos.dx;
      final staffY = pos.dy;
      final staffWidth = _getStaffWidth(w);

      if (showWaves) {
        _drawFlowingWaves(canvas, staffX, staffY, staffWidth, wavePaint);
      }

      // Draw staff lines
      for (int line = 0; line < 5; line++) {
        final y = staffY + line * 10.0;
        canvas.drawLine(
          Offset(staffX, y),
          Offset(staffX + staffWidth, y),
          staffPaint,
        );
      }

      if (showNotes) {
        _drawNotesOnStaff(
          canvas,
          staffX,
          staffY,
          staffWidth,
          notePaint,
          noteOutlinePaint,
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  WELCOME VARIANT – fixed 1024×1536 coordinate space
  // ─────────────────────────────────────────────────────────────

  void _drawWelcomeBackground(Canvas canvas) {
    // 1. Three bottom curves (starting around y=1040 per spec)
    _drawWelcomeBottomCurves(canvas);

    // 2. Seven smooth parallel flowing waves behind microphone (y=225 to y=535)
    if (showWaves) {
      _drawWelcomeWaves(canvas);
    }

    // 3. Four hand-drawn musical notes at reference positions (scaled ×1.35)
    if (showNotes) {
      _drawWelcomeNotes(canvas);
    }

    // 4. Two gold four-point sparkles at reference positions
    _drawWelcomeSparkles(canvas);
  }

  void _drawWelcomeWaves(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;

    final waveAlpha = isDark ? 0.32 : 0.22;
    final baseColor = _welcomeWaveColor();

    const waveCount = 7;
    const waveStartY = 225.0;
    const waveSpacing = 22.0;

    for (int i = 0; i < waveCount; i++) {
      paint.color = baseColor.withValues(alpha: waveAlpha * opacity);

      final baseY = waveStartY + i * waveSpacing;
      final path = Path()
        ..moveTo(-40, baseY)
        ..cubicTo(120, baseY - 90, 200, baseY + 100, 340, baseY + 15)
        ..cubicTo(465, baseY - 70, 565, baseY - 115, 690, baseY + 5)
        ..cubicTo(805, baseY + 105, 900, baseY - 65, 1065, baseY - 20);

      canvas.drawPath(path, paint);
    }
  }

  void _drawWelcomeNotes(Canvas canvas) {
    // Note positions with explicit bounding sizes (from reference spec)
    const noteData = <(double, double, double, double, double)>[
      // (x, y, width, height, rotation)
      (790, 145, 72, 90, 0.15),
      (190, 240, 70, 100, -0.10),
      (100, 525, 80, 105, 0.08),
      (845, 525, 105, 125, -0.12),
    ];

    // Use note gradient: dark cyan/blue.
    // Light theme bakes a subtle premium opacity directly into the gradient
    // stops so the notes remain clearly visible without competing with content.
    final noteGradientColors = isDark
        ? [AppColors.tunoNoteStart, AppColors.tunoNoteEnd]
        : [
            AppColors.tunoNoteStart.withValues(alpha: 0.38),
            AppColors.tunoNoteEnd.withValues(alpha: 0.38),
          ];

    for (final (cx, cy, w, h, rotation) in noteData) {
      final noteFill = Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx - w / 2, cy - h / 2),
          Offset(cx + w / 2, cy + h / 2),
          noteGradientColors,
          [0.0, 1.0],
        );
      final noteOutline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..color = AppColors.tunoNoteStart.withValues(alpha: 0.80);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation);

      _drawLargeMusicNote(
        canvas,
        0,
        0,
        w,
        h,
        noteFill,
        noteOutline,
        isDark ? 1.0 : 0.38,
        isDark ? 0.80 : 0.50,
      );
      canvas.restore();
    }
  }

  void _drawLargeMusicNote(
    Canvas canvas,
    double cx,
    double cy,
    double width,
    double height,
    Paint fillPaint,
    Paint outlinePaint,
    double fillAlpha,
    double outlineAlpha,
  ) {
    // Scale factors based on bounding box
    final headWidth = width * 0.50;
    final headHeight = height * 0.30;
    final stemWidth = math.max(3.0, width * 0.06);
    final stemHeight = height * 0.55;
    final flagWidth = width * 0.40;
    final flagHeight = height * 0.25;

    // Adjust paint alpha.  Dark theme keeps the original rendering exactly;
    // light theme draws the note colour at a subtle premium opacity.  When the
    // fill is a gradient (welcome variant) the alpha is baked into its stops by
    // the caller, so here we simply preserve the supplied shader.
    if (isDark) {
      fillPaint = Paint()..shader = fillPaint.shader;
    } else {
      fillPaint = Paint()
        ..shader = fillPaint.shader
        ..color = fillPaint.color.withValues(alpha: fillAlpha);
    }
    outlinePaint.color = outlinePaint.color.withValues(alpha: outlineAlpha);

    // Note head (ellipse) - positioned slightly left and down
    final headRect = Rect.fromCenter(
      center: Offset(-width * 0.08, height * 0.15),
      width: headWidth,
      height: headHeight,
    );
    final headPath = Path()..addOval(headRect);
    canvas.drawPath(headPath, fillPaint);
    canvas.drawPath(headPath, outlinePaint);

    // Stem - rising from right side of head
    final stemX = headRect.right * 0.85;
    final stemTop = -stemHeight * 0.70;
    final stemBottom = headRect.center.dy + headHeight * 0.30;
    final stemPath = Path()
      ..moveTo(stemX - stemWidth / 2, stemBottom)
      ..lineTo(stemX - stemWidth / 2, stemTop)
      ..lineTo(stemX + stemWidth / 2, stemTop)
      ..lineTo(stemX + stemWidth / 2, stemBottom)
      ..close();
    canvas.drawPath(stemPath, fillPaint);
    canvas.drawPath(stemPath, outlinePaint);

    // Flag (eighth note curve) - elegant curve from stem top
    final flagPath = Path()
      ..moveTo(stemX, stemTop)
      ..cubicTo(
        stemX + flagWidth * 0.7,
        stemTop + flagHeight * 0.2,
        stemX + flagWidth * 0.9,
        stemTop + flagHeight * 0.7,
        stemX + flagWidth * 0.5,
        stemTop + flagHeight,
      )
      ..cubicTo(
        stemX + flagWidth * 0.3,
        stemTop + flagHeight * 0.7,
        stemX + flagWidth * 0.2,
        stemTop + flagHeight * 0.3,
        stemX.toDouble(),
        stemTop + flagHeight * 0.15,
      )
      ..close();
    canvas.drawPath(flagPath, fillPaint);
    canvas.drawPath(flagPath, outlinePaint);
  }

  void _drawWelcomeSparkles(Canvas canvas) {
    // Two four-point sparkles at reference positions with explicit sizes
    const sparkleData = <(double, double, double)>[
      (740, 273, 42.0), // main sparkle
      (250, 565, 32.0), // secondary sparkle
    ];

    for (final (cx, cy, size) in sparkleData) {
      _drawFourPointSparkle(canvas, Offset(cx, cy), size);
    }
  }

  void _drawFourPointSparkle(Canvas canvas, Offset center, double size) {
    final halfSize = size / 2;
    final innerRadius = size * 0.15;

    // Glow behind sparkle
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.tunoGoldGlow.withValues(
        alpha: (isDark ? 0.20 : 0.16) * opacity,
      );
    canvas.drawCircle(center, halfSize * 0.6, glowPaint);

    // Four arms of the sparkle
    final armPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.tunoGoldPrimary.withValues(
        alpha: (isDark ? 0.70 : 0.50) * opacity,
      );

    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2; // 0, 90, 180, 270 degrees
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);

      // Diamond shape for each arm
      final armPath = Path()
        ..moveTo(
          center.dx + cosA * innerRadius - sinA * innerRadius * 0.4,
          center.dy + sinA * innerRadius + cosA * innerRadius * 0.4,
        )
        ..lineTo(center.dx + cosA * halfSize, center.dy + sinA * halfSize)
        ..lineTo(
          center.dx + cosA * innerRadius + sinA * innerRadius * 0.4,
          center.dy + sinA * innerRadius - cosA * innerRadius * 0.4,
        )
        ..lineTo(
          center.dx - cosA * innerRadius * 0.2,
          center.dy - sinA * innerRadius * 0.2,
        )
        ..close();
      canvas.drawPath(armPath, armPaint);
    }

    // Bright champagne center dot
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.tunoGoldChampagne.withValues(
        alpha: (isDark ? 0.85 : 0.60) * opacity,
      );
    canvas.drawCircle(center, innerRadius * 0.5, centerPaint);
  }

  void _drawWelcomeBottomCurves(Canvas canvas) {
    const curveCount = 3;
    const baseY = 1040.0;

    for (int i = 0; i < curveCount; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.0 + i * 0.5;

      if (isDark) {
        paint.color = AppColors.tunoTeal.withValues(
          alpha: (0.06 + i * 0.03) * opacity,
        );
      } else {
        paint.color = const Color(
          0xFF0B7185,
        ).withValues(alpha: (0.10 + i * 0.03) * opacity);
      }

      final yOffset = i * 50.0;
      final path = Path();
      path.moveTo(0, baseY + yOffset);

      const cp1x = 256.0;
      final cp1y = baseY + yOffset - 40.0;
      const cp2x = 768.0;
      final cp2y = baseY + yOffset + 28.0;
      path.cubicTo(
        cp1x,
        cp1y,
        cp2x,
        cp2y,
        _canvasWidth,
        baseY + yOffset - 14.0,
      );

      canvas.drawPath(path, paint);
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  SIGNUP VARIANT – fixed 1024×1536 coordinate space
  // ─────────────────────────────────────────────────────────────

  /// Seven thin, parallel, full-width wave paths spanning the entire
  /// 1024px canonical canvas (x=-80 to x=1100).  All paths share the
  /// same cubic Bézier control-point structure, offset vertically by 15px.
  void _drawSignupTopWaves(Canvas canvas) {
    if (!showWaves) return;

    final waveColor = _signupWaveColor();

    const waveCount = 7;
    const waveStartY = 90.0;
    const spacing = 15.0;

    for (int i = 0; i < waveCount; i++) {
      final alpha = isDark ? (0.10 + i * 0.028) : (0.14 + i * 0.012);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 1.1
        ..color = waveColor.withValues(
          alpha: alpha.clamp(0.02, 0.45) * opacity,
        );

      final baseY = waveStartY + i * spacing;

      // Identical control-point deltas for every path → strictly parallel.
      final path = Path()
        ..moveTo(-80, baseY)
        ..cubicTo(100, baseY - 35, 210, baseY + 45, 350, baseY + 10)
        ..cubicTo(500, baseY - 45, 610, baseY - 55, 730, baseY + 20)
        ..cubicTo(850, baseY + 85, 970, baseY - 25, 1100, baseY + 5);

      canvas.drawPath(path, paint);
    }
  }

  /// Two large music notes positioned above/among the top waves.
  void _drawSignupTopNotes(Canvas canvas) {
    if (!showNotes) return;

    final noteColor = _signupNoteColor();

    // Note 1: upper-right area above the wave cluster (waves start at y=90)
    final noteAlpha = isDark ? 0.20 * opacity : 0.32 * opacity;
    final noteStrokeAlpha = isDark ? 0.45 * opacity : 0.50 * opacity;

    final note1Fill = Paint()
      ..color = noteColor.withValues(alpha: noteAlpha)
      ..style = PaintingStyle.fill;
    final note1Outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = noteColor.withValues(alpha: noteStrokeAlpha);

    // Note 1: left side, above/among the wave cluster
    canvas.save();
    canvas.translate(185, 80);
    canvas.rotate(0.12);
    _drawLargeMusicNote(
      canvas,
      0,
      0,
      48,
      64,
      note1Fill,
      note1Outline,
      isDark ? 1.0 : 0.36,
      isDark ? 0.80 : 0.50,
    );
    canvas.restore();

    // Note 2: right side, nestled among the waves
    final note2Fill = Paint()
      ..color = noteColor.withValues(alpha: noteAlpha)
      ..style = PaintingStyle.fill;
    final note2Outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = noteColor.withValues(alpha: noteStrokeAlpha);

    canvas.save();
    canvas.translate(790, 105);
    canvas.rotate(-0.08);
    _drawLargeMusicNote(
      canvas,
      0,
      0,
      44,
      58,
      note2Fill,
      note2Outline,
      isDark ? 1.0 : 0.32,
      isDark ? 0.75 : 0.45,
    );
    canvas.restore();
  }

  /// 7 smooth parallel curves spanning the full canvas width,
  /// positioned close to the bottom edge (y ≈ 1430–1480) so they
  /// stay behind the "Already have an account? Login" footer.
  void _drawSignupBottomWaves(Canvas canvas) {
    if (!showWaves) return;

    final waveColor = _signupWaveColor();

    const curveCount = 7;
    const startY = 1430.0;
    const ySpacing = 8.5;

    for (int i = 0; i < curveCount; i++) {
      final alpha = isDark
          ? (0.10 - i * 0.010).clamp(0.01, 0.35)
          : (0.16 - i * 0.008).clamp(0.10, 0.22);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.2
        ..color = waveColor.withValues(alpha: alpha * opacity);

      final baseY = startY + i * ySpacing;

      final path = Path()
        ..moveTo(-80, baseY - 10)
        // Gentle rising curve from left edge
        ..cubicTo(60, baseY + 4, 140, baseY - 8, 240, baseY - 16)
        // Slight dip
        ..cubicTo(340, baseY - 22, 420, baseY - 4, 500, baseY + 2)
        // Rise a little
        ..cubicTo(580, baseY + 8, 640, baseY - 6, 740, baseY - 14)
        // Flow to right edge and beyond
        ..cubicTo(840, baseY - 22, 960, baseY + 6, 1080, baseY - 8);

      canvas.drawPath(path, paint);
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  COLOUR HELPERS  (welcome + signup variant)
  // ─────────────────────────────────────────────────────────────

  Color _welcomeWaveColor() {
    if (isDark) {
      return AppColors.tunoTeal; // muted teal
    } else {
      return const Color(0xFF0B7185); // deeper teal for light theme
    }
  }

  /// Wave color for the signup variant – theme-aware.
  Color _signupWaveColor() {
    if (isDark) {
      return AppColors.tunoTeal; // muted teal/cyan
    } else {
      return const Color(0xFF0B7185); // deeper teal for light theme
    }
  }

  /// Note color for the signup variant – theme-aware.
  Color _signupNoteColor() {
    if (isDark) {
      return AppColors.tunoTeal; // muted teal/cyan
    } else {
      return const Color(0xFF168FA0); // deeper cyan for light theme
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  LOGIN VARIANT – fixed 1024×1536 coordinate space
  // ─────────────────────────────────────────────────────────────

  /// 7 smooth, parallel, non-intersecting waves starting at ~40% width,
  /// flowing toward the upper-right corner and continuing beyond the right edge.
  /// All paths share identical cubic Bézier control-point deltas.
  void _drawLoginWaves(Canvas canvas) {
    if (!showWaves) return;

    const waveCount = 7;
    // Start waves at roughly 40% of the canvas width (x ≈ 410) with vertical
    // placement in the upper portion (y ≈ 80–190).
    const startX = -40.0;
    const startY = 55.0;
    const spacing = 16.0;

    for (int i = 0; i < waveCount; i++) {
      final alpha = isDark
          ? (0.28 - i * 0.025).clamp(0.04, 0.35)
          : (0.22 - i * 0.010).clamp(0.14, 0.22);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 1.2
        ..color = _loginWaveColor().withValues(alpha: alpha * opacity);

      final baseY = startY + i * spacing;

      // Identical Bézier control-point deltas for strictly parallel curves.
      // Waves begin left of center (x=-40), flow upward/downward in upper-right,
      // and continue beyond the right edge (x=1100).
      final path = Path()
        ..moveTo(startX, baseY + 15)
        ..cubicTo(60, baseY - 12, 140, baseY + 28, 240, baseY + 6)
        ..cubicTo(330, baseY - 18, 420, baseY - 38, 530, baseY + 8)
        ..cubicTo(650, baseY + 48, 770, baseY - 22, 900, baseY + 10)
        ..cubicTo(1000, baseY + 32, 1060, baseY - 8, 1120, baseY + 4);

      canvas.drawPath(path, paint);
    }
  }

  /// Two music notes placed above/inside the wave area without overlapping
  /// the Tuno logo area (which would be near the top-left/center of the screen).
  void _drawLoginNotes(Canvas canvas) {
    if (!showNotes) return;

    final noteColor = _loginNoteColor();

    final noteAlpha = isDark ? 0.22 * opacity : 0.34 * opacity;
    final noteStrokeAlpha = isDark ? 0.50 * opacity : 0.52 * opacity;

    // Note 1: upper-right, nestled among/above the waves
    final note1Fill = Paint()
      ..color = noteColor.withValues(alpha: noteAlpha)
      ..style = PaintingStyle.fill;
    final note1Outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = noteColor.withValues(alpha: noteStrokeAlpha);

    canvas.save();
    canvas.translate(760, 38);
    canvas.rotate(0.15);
    _drawLargeMusicNote(
      canvas,
      0,
      0,
      52,
      68,
      note1Fill,
      note1Outline,
      isDark ? 1.0 : 0.36,
      isDark ? 0.80 : 0.50,
    );
    canvas.restore();

    // Note 2: slightly lower, also in the wave cluster on the right
    final note2Fill = Paint()
      ..color = noteColor.withValues(alpha: noteAlpha)
      ..style = PaintingStyle.fill;
    final note2Outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = noteColor.withValues(alpha: noteStrokeAlpha);

    canvas.save();
    canvas.translate(850, 110);
    canvas.rotate(-0.10);
    _drawLargeMusicNote(
      canvas,
      0,
      0,
      44,
      56,
      note2Fill,
      note2Outline,
      isDark ? 1.0 : 0.32,
      isDark ? 0.75 : 0.45,
    );
    canvas.restore();
  }

  /// Wave colour for the login variant – theme-aware.
  Color _loginWaveColor() {
    if (isDark) {
      return AppColors.tunoTeal; // muted teal/cyan
    }
    return const Color(0xFF0B7185); // deeper teal for light theme
  }

  /// Note colour for the login variant – theme-aware.
  Color _loginNoteColor() {
    if (isDark) {
      return AppColors.tunoTeal; // muted teal/cyan
    }
    return const Color(0xFF168FA0); // deeper cyan for light theme
  }

  // ─────────────────────────────────────────────────────────────
  //  NON-WELCOME VARIANT HELPERS (unchanged)
  // ─────────────────────────────────────────────────────────────

  Color _staffColor() {
    if (isDark) {
      return AppColors.tunoCyan.withValues(alpha: 0.08 * opacity);
    } else {
      return const Color(0xFF0B7185).withValues(alpha: 0.12 * opacity);
    }
  }

  Color _waveColor() {
    if (isDark) {
      return AppColors.tunoTeal.withValues(alpha: 0.12 * opacity);
    } else {
      return const Color(0xFF0B7185).withValues(alpha: 0.18 * opacity);
    }
  }

  Color _noteFillColor() {
    if (isDark) {
      return AppColors.tunoCyan.withValues(alpha: 0.25 * opacity);
    } else {
      return const Color(0xFF168FA0).withValues(alpha: 0.32 * opacity);
    }
  }

  Color _noteOutlineColor() {
    if (isDark) {
      return AppColors.tunoTeal.withValues(alpha: 0.4 * opacity);
    } else {
      return const Color(0xFF0B7185).withValues(alpha: 0.42 * opacity);
    }
  }

  void _drawFlowingWaves(
    Canvas canvas,
    double staffX,
    double staffY,
    double staffWidth,
    Paint paint,
  ) {
    final path = Path();
    final centerY = staffY + 20;
    final amplitude = 8.0;
    final wavelength = 60.0;
    final points = (staffWidth / 4).round();

    path.moveTo(staffX, centerY);
    for (int i = 1; i <= points; i++) {
      final x = staffX + i * 4.0;
      final y =
          centerY + amplitude * math.sin((i * 4.0) / wavelength * 2 * math.pi);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // Second wave, offset
    final path2 = Path();
    path2.moveTo(staffX, centerY + 15);
    for (int i = 1; i <= points; i++) {
      final x = staffX + i * 4.0;
      final y =
          centerY +
          15 +
          amplitude *
              0.7 *
              math.sin((i * 4.0) / wavelength * 2 * math.pi + 1.5);
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, paint);
  }

  void _drawNotesOnStaff(
    Canvas canvas,
    double staffX,
    double staffY,
    double staffWidth,
    Paint notePaint,
    Paint noteOutlinePaint,
  ) {
    final notePositions = _getNotePositions(staffWidth);
    final noteRadius = 5.5;
    final stemHeight = 28.0;

    for (final relX in notePositions) {
      final x = staffX + relX * staffWidth;
      final lineIndex = (relX * 9) % 9;
      final y = staffY + 40 - lineIndex * 5.0;

      canvas.drawCircle(Offset(x, y), noteRadius, notePaint);
      canvas.drawCircle(Offset(x, y), noteRadius, noteOutlinePaint);

      final stemX = x + noteRadius;
      final stemTop = y - stemHeight;
      canvas.drawLine(
        Offset(stemX, y - noteRadius),
        Offset(stemX, stemTop),
        noteOutlinePaint,
      );

      if ((relX * 10).round() % 2 == 0) {
        final flagPath = Path()
          ..moveTo(stemX, stemTop)
          ..quadraticBezierTo(stemX + 10, stemTop + 3, stemX + 7, stemTop + 10)
          ..lineTo(stemX, stemTop + 10)
          ..close();
        canvas.drawPath(flagPath, notePaint);
      }
    }
  }

  List<Offset> _getStaffPositions(double w, double h) {
    final positions = <Offset>[];
    final staffWidth = _getStaffWidth(w);

    switch (variant) {
      case TunoMusicBackgroundVariant.topRight:
        positions.add(Offset(w - staffWidth - 24, 40));
        break;
      case TunoMusicBackgroundVariant.bottomLeft:
        positions.add(Offset(24, h - 140));
        break;
      case TunoMusicBackgroundVariant.topAndBottom:
        positions.add(Offset(w - staffWidth - 24, 40));
        positions.add(Offset(24, h - 140));
        break;
      case TunoMusicBackgroundVariant.centerRight:
        positions.add(Offset(w - staffWidth - 24, h / 2 - 50));
        break;
      case TunoMusicBackgroundVariant.minimal:
        positions.add(Offset(w / 2 - staffWidth / 2, h / 2 - 50));
        break;
      case TunoMusicBackgroundVariant.welcome:
      case TunoMusicBackgroundVariant.signup:
      case TunoMusicBackgroundVariant.login:
      case TunoMusicBackgroundVariant.dashboard:
      case TunoMusicBackgroundVariant.home:
        break;
    }
    return positions;
  }

  double _getStaffWidth(double w) {
    switch (variant) {
      case TunoMusicBackgroundVariant.minimal:
        return w * 0.6;
      case TunoMusicBackgroundVariant.centerRight:
        return w * 0.35;
      case TunoMusicBackgroundVariant.welcome:
      case TunoMusicBackgroundVariant.signup:
      case TunoMusicBackgroundVariant.login:
      case TunoMusicBackgroundVariant.dashboard:
      case TunoMusicBackgroundVariant.home:
        return 0;
      default:
        return w * 0.28;
    }
  }

  List<double> _getNotePositions(double staffWidth) {
    switch (variant) {
      case TunoMusicBackgroundVariant.minimal:
        return [0.2, 0.45, 0.7, 0.9];
      case TunoMusicBackgroundVariant.centerRight:
        return [0.15, 0.4, 0.65, 0.85];
      case TunoMusicBackgroundVariant.welcome:
      case TunoMusicBackgroundVariant.signup:
      case TunoMusicBackgroundVariant.login:
      case TunoMusicBackgroundVariant.dashboard:
      case TunoMusicBackgroundVariant.home:
        return [];
      default:
        return [0.18, 0.42, 0.68, 0.88];
    }
  }

  @override
  bool shouldRepaint(covariant _TunoMusicPainter oldDelegate) {
    return oldDelegate.variant != variant ||
        oldDelegate.isDark != isDark ||
        oldDelegate.showNotes != showNotes ||
        oldDelegate.showWaves != showWaves ||
        oldDelegate.opacity != opacity;
  }
}

// ─────────────────────────────────────────────────────────────
//  HOME VARIANT – Premium musical background painter
//  Paints inside a bounded 1000px-wide canvas with proportional
//  scaling so decorations never stretch on wide screens.
// ─────────────────────────────────────────────────────────────

/// Canonical design width for the home background decorations.
/// Maximum decorative canvas width is ~1000px.
const double _homeCanvasWidth = 1000.0;

/// Public [CustomPainter] that draws premium musical decorations
/// for the Home screen background.
///
/// Paints:
/// - 7 scattered musical notes (mix single + beamed pairs)
/// - 4 metallic-gold four-point sparkles
/// - 8 tiny cyan glow dots
/// - 2 equalizer bar groups
/// - 1 subtle waveform decoration
///
/// Use with [IgnorePointer] wrapping [CustomPaint] so taps pass through.
class HomeMusicBackgroundPainter extends CustomPainter {
  HomeMusicBackgroundPainter({required this.isDark, this.opacity = 1.0});

  final bool isDark;
  final double opacity;

  // ── Colour helpers ──

  Color get _noteColorStart => isDark
      ? const Color(0xFF087D91)
      : const Color(0xFF168FA0).withValues(alpha: 0.50);

  Color get _noteColorEnd => isDark
      ? const Color(0xFF07506C)
      : const Color(0xFF0B7185).withValues(alpha: 0.40);

  Color get _glowDotColor => isDark
      ? const Color(0xFF12B5C1).withValues(alpha: 0.35 * opacity)
      : const Color(0xFF0B7185).withValues(alpha: 0.40 * opacity);

  Color get _eqBarColor => isDark
      ? const Color(0xFF12B5C1).withValues(alpha: 0.18 * opacity)
      : const Color(0xFF168FA0).withValues(alpha: 0.20 * opacity);

  Color get _waveformColor => isDark
      ? const Color(0xFF12B5C1).withValues(alpha: 0.14 * opacity)
      : const Color(0xFF0B7185).withValues(alpha: 0.16 * opacity);

  @override
  void paint(Canvas canvas, Size size) {
    // Scale everything proportionally from canonical 1000px-wide canvas.
    final scaleX = size.width / _homeCanvasWidth;
    final scaleY = size.height / _homeCanvasWidth;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final offsetX = (size.width - _homeCanvasWidth * scale) / 2;
    final offsetY = (size.height - _homeCanvasWidth * scale) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);

    // Draw all decorations in canonical 1000px-wide coordinate space.
    final effectiveH = size.height / scale;

    // ── 1. Scattered musical notes (7 total) ──
    _drawAllNotes(canvas, effectiveH);

    // ── 2. Metallic-gold four-point sparkles (4 total) ──
    _drawAllSparkles(canvas, effectiveH);

    // ── 3. Tiny cyan glow dots (8 total) ──
    _drawGlowDots(canvas, effectiveH);

    // ── 4. Equalizer bar groups (2 groups) ──
    _drawEqualizerGroups(canvas, effectiveH);

    // ── 5. Subtle waveform decoration ──
    _drawWaveformDecoration(canvas, effectiveH);

    canvas.restore();
  }

  // ─────────────────────────────────────────────────────────────
  //  NOTE DRAWING
  // ─────────────────────────────────────────────────────────────

  /// Positions for 7 notes: (x, y, sizeScale, rotation, isPaired).
  /// Coordinates in canonical 1000px-wide space.
  /// Placed around empty areas – not behind headings or cards.
  static const _notePositions = <(double, double, double, double, bool)>[
    // 5 single notes
    (50, 80, 1.0, -0.12, false), // top-left area
    (870, 40, 1.15, 0.08, false), // top-right area
    (80, 520, 0.90, 0.10, false), // mid-left (beside practice card)
    (790, 700, 1.05, -0.06, false), // mid-right (beside progress cards)
    (50, 1050, 0.85, 0.14, false), // bottom-left
    // 2 beam-connected pairs
    (730, 180, 1.10, 0.04, true), // upper-right area
    (160, 790, 0.95, -0.09, true), // mid-left area
  ];

  void _drawAllNotes(Canvas canvas, double canvasH) {
    for (final (x, y, scale, rotation, isPaired) in _notePositions) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final noteSize = 42.0 * scale;
      if (isPaired) {
        _drawBeamedNotePair(canvas, noteSize);
      } else {
        _drawSingleNote(canvas, noteSize);
      }
      canvas.restore();
    }
  }

  /// Draws a single eighth-note (head + stem + flag).
  void _drawSingleNote(Canvas canvas, double size) {
    final headW = size * 0.50;
    final headH = size * 0.32;
    final stemH = size * 0.55;
    final flagW = size * 0.40;
    final flagH = size * 0.30;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = _noteColorStart.withValues(
        alpha: isDark ? 0.45 * opacity : 0.34 * opacity,
      );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = _noteColorEnd.withValues(
        alpha: isDark ? 0.55 * opacity : 0.40 * opacity,
      );

    // Note head (tilted ellipse)
    final headRect = Rect.fromCenter(
      center: Offset(-size * 0.06, size * 0.16),
      width: headW,
      height: headH,
    );
    final headPath = Path()..addOval(headRect);
    canvas.drawPath(headPath, fill);
    canvas.drawPath(headPath, stroke);

    // Stem
    final stemX = headRect.right * 0.82;
    final stemTop = -stemH * 0.65;
    final stemBottom = headRect.center.dy + headH * 0.30;
    canvas.drawLine(Offset(stemX, stemBottom), Offset(stemX, stemTop), stroke);

    // Flag (eighth-note curve)
    final flagPath = Path()
      ..moveTo(stemX, stemTop)
      ..cubicTo(
        stemX + flagW * 0.7,
        stemTop + flagH * 0.2,
        stemX + flagW * 0.95,
        stemTop + flagH * 0.7,
        stemX + flagW * 0.5,
        stemTop + flagH,
      )
      ..cubicTo(
        stemX + flagW * 0.25,
        stemTop + flagH * 0.7,
        stemX + flagW * 0.18,
        stemTop + flagH * 0.25,
        stemX.toDouble(),
        stemTop + flagH * 0.12,
      )
      ..close();
    canvas.drawPath(flagPath, fill);
    canvas.drawPath(flagPath, stroke);
  }

  /// Draws two notes connected by a horizontal beam (sixteenth-note pair).
  void _drawBeamedNotePair(Canvas canvas, double size) {
    final spacing = size * 0.70;
    final headW = size * 0.45;
    final headH = size * 0.28;
    final stemH = size * 0.55;
    final beamH = size * 0.06;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = _noteColorStart.withValues(
        alpha: isDark ? 0.40 * opacity : 0.30 * opacity,
      );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = _noteColorEnd.withValues(
        alpha: isDark ? 0.50 * opacity : 0.36 * opacity,
      );

    for (int i = 0; i < 2; i++) {
      final cx = i * spacing;
      final headRect = Rect.fromCenter(
        center: Offset(cx - size * 0.04, size * 0.14),
        width: headW,
        height: headH,
      );
      final headPath = Path()..addOval(headRect);
      canvas.drawPath(headPath, fill);
      canvas.drawPath(headPath, stroke);

      // Stem
      final sX = headRect.right * 0.78;
      final sTop = -stemH * 0.60;
      final sBottom = headRect.center.dy + headH * 0.30;
      canvas.drawLine(Offset(sX, sBottom), Offset(sX, sTop), stroke);
    }

    // Beam connecting the two stems
    final leftStemX = 0.0; // first note stem x approx
    final rightStemX = spacing;
    final beamTop = -stemH * 0.60;
    final beamBottom = beamTop + beamH;
    final beamPath = Path()
      ..moveTo(leftStemX, beamTop)
      ..lineTo(rightStemX, beamTop)
      ..lineTo(rightStemX, beamBottom)
      ..lineTo(leftStemX, beamBottom)
      ..close();
    canvas.drawPath(beamPath, fill);
    canvas.drawPath(beamPath, stroke);
  }

  // ─────────────────────────────────────────────────────────────
  //  SPARKLE DRAWING
  // ─────────────────────────────────────────────────────────────

  /// Positions for 4 sparkles: (x, y, size).
  static const _sparklePositions = <(double, double, double)>[
    (160, 140, 36.0),
    (740, 480, 42.0),
    (100, 920, 30.0),
    (840, 1040, 38.0),
  ];

  void _drawAllSparkles(Canvas canvas, double canvasH) {
    for (final (x, y, sz) in _sparklePositions) {
      _drawFourPointSparkle(canvas, Offset(x, y), sz);
    }
  }

  /// Draws a layered metallic-gold four-point sparkle with glow.
  void _drawFourPointSparkle(Canvas canvas, Offset center, double size) {
    final halfSize = size / 2;
    final innerRadius = size * 0.15;

    // Subtle gold glow circle behind sparkle
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(
        0xFFD9A62E,
      ).withValues(alpha: (isDark ? 0.18 : 0.14) * opacity);
    canvas.drawCircle(center, halfSize * 0.55, glowPaint);

    // Four diamond-shaped arms with layered gold
    // Primary gold colour
    final armPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(
        0xFFE3B94F,
      ).withValues(alpha: (isDark ? 0.65 : 0.50) * opacity);

    // Champagne highlight overlay
    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(
        0xFFFFF2A6,
      ).withValues(alpha: (isDark ? 0.50 : 0.42) * opacity);

    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);

      // Outer arm diamond
      final armPath = Path()
        ..moveTo(
          center.dx + cosA * innerRadius - sinA * innerRadius * 0.35,
          center.dy + sinA * innerRadius + cosA * innerRadius * 0.35,
        )
        ..lineTo(center.dx + cosA * halfSize, center.dy + sinA * halfSize)
        ..lineTo(
          center.dx + cosA * innerRadius + sinA * innerRadius * 0.35,
          center.dy + sinA * innerRadius - cosA * innerRadius * 0.35,
        )
        ..close();
      canvas.drawPath(armPath, armPaint);

      // Inner highlight (smaller, champagne)
      final hlPath = Path()
        ..moveTo(
          center.dx + cosA * innerRadius * 1.2 - sinA * innerRadius * 0.2,
          center.dy + sinA * innerRadius * 1.2 + cosA * innerRadius * 0.2,
        )
        ..lineTo(
          center.dx + cosA * halfSize * 0.6,
          center.dy + sinA * halfSize * 0.6,
        )
        ..lineTo(
          center.dx + cosA * innerRadius * 1.2 + sinA * innerRadius * 0.2,
          center.dy + sinA * innerRadius * 1.2 - cosA * innerRadius * 0.2,
        )
        ..close();
      canvas.drawPath(hlPath, highlightPaint);
    }

    // Deep gold accent at center
    final deepGoldPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(
        0xFFA86D16,
      ).withValues(alpha: (isDark ? 0.55 : 0.42) * opacity);
    canvas.drawCircle(center, innerRadius * 0.4, deepGoldPaint);

    // Bright champagne center dot
    final centerDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(
        0xFFFFF2A6,
      ).withValues(alpha: (isDark ? 0.80 : 0.55) * opacity);
    canvas.drawCircle(center, innerRadius * 0.25, centerDotPaint);
  }

  // ─────────────────────────────────────────────────────────────
  //  GLOW DOTS
  // ─────────────────────────────────────────────────────────────

  /// Positions for 8 tiny cyan glow dots: (x, y, radius).
  static const _glowDotPositions = <(double, double, double)>[
    (300, 50, 3.0),
    (680, 260, 2.5),
    (180, 420, 3.5),
    (880, 600, 2.0),
    (60, 700, 2.8),
    (760, 860, 3.2),
    (260, 980, 2.2),
    (920, 380, 2.6),
  ];

  void _drawGlowDots(Canvas canvas, double canvasH) {
    for (final (x, y, r) in _glowDotPositions) {
      canvas.drawCircle(Offset(x, y), r, Paint()..color = _glowDotColor);
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  EQUALIZER BAR GROUPS
  // ─────────────────────────────────────────────────────────────

  /// Two equalizer groups: (x, y, barCount, barWidth, maxHeight, spacing).
  static const _eqGroups = <(double, double, int, double, double, double)>[
    (260, 260, 4, 6.0, 28.0, 3.0),
    (740, 780, 3, 5.0, 22.0, 3.0),
  ];

  void _drawEqualizerGroups(Canvas canvas, double canvasH) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = _eqBarColor;

    for (final (x, y, count, barW, maxH, spacing) in _eqGroups) {
      // Heights vary per bar to look like an EQ
      const heights = <double>[0.45, 0.85, 0.60, 1.0];
      for (int i = 0; i < count; i++) {
        final h = maxH * (i < heights.length ? heights[i] : 0.5);
        final barX = x + i * (barW + spacing);
        final barY = y - h;
        final rRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barW, h),
          const Radius.circular(2),
        );
        canvas.drawRRect(rRect, paint);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  WAVEFORM DECORATION
  // ─────────────────────────────────────────────────────────────

  /// Draws a subtle sine-wave decoration in the empty area between
  /// the progress cards and the bottom of the content area.
  void _drawWaveformDecoration(Canvas canvas, double canvasH) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = _waveformColor;

    // Position: roughly around the empty area below/right of progress cards
    final startX = 480.0;
    final startY = 660.0;
    final w = 240.0;
    final amplitude = 14.0;
    final cycles = 3.5;

    final path = Path();
    path.moveTo(startX, startY);
    for (double x = 0; x <= w; x += 2) {
      final y = startY + amplitude * math.sin((x / w) * cycles * 2 * math.pi);
      path.lineTo(startX + x, y);
    }
    canvas.drawPath(path, paint);

    // Second wave slightly offset (thicker, more subtle)
    final paint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..color = _waveformColor.withValues(
        alpha: isDark ? 0.10 * opacity : 0.12 * opacity,
      );

    final path2 = Path();
    path2.moveTo(startX + 20, startY + 8);
    for (double x = 0; x <= w - 40; x += 2) {
      final y =
          startY +
          8 +
          amplitude *
              0.7 *
              math.sin(((x + 10) / w) * cycles * 2 * math.pi + 1.2);
      path2.lineTo(startX + 20 + x, y);
    }
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant HomeMusicBackgroundPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.opacity != opacity;
  }
}
