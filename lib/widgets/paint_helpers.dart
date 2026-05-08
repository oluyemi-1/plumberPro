import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';

/// Shared painting utilities for simulation canvases.
class PipePainterHelpers {
  /// Draws a straight pipe between [a] and [b] as a thick rounded line with
  /// an outer highlight, used for both water and waste pipes.
  static void drawPipe(
    Canvas canvas, {
    required Offset a,
    required Offset b,
    required Color color,
    double width = 14,
    bool highlighted = false,
  }) {
    final outer = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width + 6
      ..style = PaintingStyle.stroke;
    final inner = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width * 0.35
      ..style = PaintingStyle.stroke;
    canvas.drawLine(a, b, outer);
    canvas.drawLine(a, b, inner);
    final dir = (b - a);
    final len = dir.distance;
    if (len > 0) {
      final n = Offset(-dir.dy / len, dir.dx / len);
      final off = n * (width * 0.18);
      canvas.drawLine(a + off, b + off, highlight);
    }
    if (highlighted) {
      final glow = Paint()
        ..color = Colors.yellowAccent.withValues(alpha: 0.6)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width + 10
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawLine(a, b, glow);
    }
  }

  /// Draws flowing particles along a straight pipe segment, used to suggest
  /// water moving through. [progress] drives animation [0..1].
  static void drawFlowParticles(
    Canvas canvas, {
    required Offset a,
    required Offset b,
    required double progress,
    required Color color,
    int count = 6,
    double radius = 3.5,
  }) {
    final dir = (b - a);
    final paint = Paint()..color = color;
    for (int i = 0; i < count; i++) {
      final t = ((progress + i / count) % 1.0);
      final p = a + dir * t;
      canvas.drawCircle(p, radius, paint);
    }
  }

  /// Draws a joint/elbow marker (a small circle) at position [p].
  static void drawJoint(Canvas canvas, Offset p, {Color? color}) {
    final bg = Paint()..color = color ?? AppColors.pipeMetal;
    final rim = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(p, 9, bg);
    canvas.drawCircle(p, 9, rim);
  }

  /// Draws a valve symbol (two triangles meeting at a point). Red when open,
  /// grey when closed.
  static void drawValve(Canvas canvas, Offset p, {required bool open, double size = 16}) {
    final c = open ? AppColors.accent : Colors.grey.shade500;
    final paint = Paint()..color = c;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final path = Path()
      ..moveTo(p.dx - size, p.dy - size * 0.6)
      ..lineTo(p.dx, p.dy)
      ..lineTo(p.dx - size, p.dy + size * 0.6)
      ..close()
      ..moveTo(p.dx + size, p.dy - size * 0.6)
      ..lineTo(p.dx, p.dy)
      ..lineTo(p.dx + size, p.dy + size * 0.6)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);
    canvas.drawCircle(Offset(p.dx, p.dy - size - 6), 3.5, Paint()..color = Colors.black54);
    canvas.drawLine(Offset(p.dx, p.dy - size - 2), Offset(p.dx, p.dy),
        Paint()..color = Colors.black54..strokeWidth = 1.5);
  }

  /// Draws a label box at [p] anchored to the top-left.
  static void drawLabel(
    Canvas canvas,
    Offset p,
    String text, {
    Color background = Colors.white,
    Color textColor = AppColors.text,
    double fontSize = 11,
    bool bold = true,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromLTWH(
      p.dx - 4,
      p.dy - 3,
      tp.width + 8,
      tp.height + 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = background.withValues(alpha: 0.94),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    tp.paint(canvas, p);
  }

  /// Simple radiator glyph (slotted metal rectangle).
  static void drawRadiator(
    Canvas canvas, {
    required Rect rect,
    double warmth = 0.0, // 0 = cold, 1 = hot
  }) {
    final body = Color.lerp(
      const Color(0xFFBFC9D1),
      AppColors.hotWater,
      warmth.clamp(0.0, 1.0),
    )!;
    final p = Paint()..color = body;
    final stroke = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(r, p);
    canvas.drawRRect(r, stroke);
    final slotPaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final n = (rect.width / 7).floor();
    for (int i = 1; i < n; i++) {
      final x = rect.left + i * (rect.width / n);
      canvas.drawLine(Offset(x, rect.top + 4), Offset(x, rect.bottom - 4), slotPaint);
    }
    if (warmth > 0.05) {
      final heat = Paint()
        ..color = Colors.redAccent.withValues(alpha: 0.3 * warmth)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(r, heat);
    }
  }

  /// Draws a cistern / cold water tank with water level.
  static void drawTank(
    Canvas canvas, {
    required Rect rect,
    required double level, // 0..1
    Color waterColor = AppColors.coldWater,
    bool open = true,
    String? label,
  }) {
    final body = Paint()..color = const Color(0xFFE1E6EC);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      body,
    );
    final waterLevel = level.clamp(0.0, 1.0);
    final waterH = rect.height * waterLevel;
    final waterRect = Rect.fromLTWH(
      rect.left + 3,
      rect.bottom - waterH,
      rect.width - 6,
      waterH,
    );
    canvas.drawRect(
      waterRect,
      Paint()..color = waterColor.withValues(alpha: 0.75),
    );
    // Ripple
    final rippleY = waterRect.top + 2;
    final ripple = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(waterRect.left, rippleY);
    for (double x = waterRect.left; x <= waterRect.right; x += 6) {
      path.relativeLineTo(3, -1.2);
      path.relativeLineTo(3, 1.2);
    }
    canvas.drawPath(path, ripple);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      stroke,
    );
    if (!open) {
      // lid
      canvas.drawLine(
        Offset(rect.left - 3, rect.top),
        Offset(rect.right + 3, rect.top),
        Paint()
          ..color = Colors.black54
          ..strokeWidth = 3,
      );
    }
    if (label != null) {
      drawLabel(canvas, Offset(rect.left, rect.top - 18), label);
    }
  }

  /// Rotate a point [p] around origin [c] by [angle] radians.
  static Offset rotate(Offset p, Offset c, double angle) {
    final s = math.sin(angle);
    final co = math.cos(angle);
    final dx = p.dx - c.dx;
    final dy = p.dy - c.dy;
    return Offset(c.dx + dx * co - dy * s, c.dy + dx * s + dy * co);
  }
}
