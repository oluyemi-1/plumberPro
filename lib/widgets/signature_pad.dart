import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Captures signature strokes drawn by the user. Holds the in-progress
/// strokes and a [GlobalKey] that points at the [RepaintBoundary] inside
/// [SignaturePad], so the host can render it to a PNG for embedding in a
/// PDF or sharing.
class SignaturePadController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  final GlobalKey boundaryKey = GlobalKey();

  /// All strokes — each inner list is a continuous pen path.
  List<List<Offset>> get strokes => List.unmodifiable(_strokes);

  bool get isEmpty => _strokes.every((s) => s.isEmpty);
  bool get isNotEmpty => !isEmpty;

  void startStroke(Offset point) {
    _strokes.add([point]);
    notifyListeners();
  }

  void addPoint(Offset point) {
    if (_strokes.isEmpty) {
      _strokes.add([point]);
    } else {
      _strokes.last.add(point);
    }
    notifyListeners();
  }

  void endStroke() {
    if (_strokes.isNotEmpty && _strokes.last.isEmpty) {
      _strokes.removeLast();
    }
    notifyListeners();
  }

  void clear() {
    _strokes.clear();
    notifyListeners();
  }

  /// Render the underlying [RepaintBoundary] to PNG bytes. Returns null if
  /// the widget hasn't been laid out yet.
  Future<Uint8List?> toPngBytes({double pixelRatio = 3.0}) async {
    final ctx = boundaryKey.currentContext;
    if (ctx == null) return null;
    final ro = ctx.findRenderObject();
    if (ro is! RenderRepaintBoundary) return null;
    try {
      final img = await ro.toImage(pixelRatio: pixelRatio);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (e) {
      if (kDebugMode) debugPrint('Signature render failed: $e');
      return null;
    }
  }
}

/// A simple finger / stylus signature canvas. Pen colour and stroke width
/// are fixed for now — keeps the widget tiny and the rendered PNG sharp.
class SignaturePad extends StatelessWidget {
  final SignaturePadController controller;
  final Color penColor;
  final Color background;
  final double strokeWidth;

  const SignaturePad({
    super.key,
    required this.controller,
    this.penColor = const Color(0xFF101820),
    this.background = Colors.white,
    this.strokeWidth = 2.4,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: controller.boundaryKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => controller.startStroke(d.localPosition),
        onPanUpdate: (d) => controller.addPoint(d.localPosition),
        onPanEnd: (_) => controller.endStroke(),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => CustomPaint(
            painter: _SignaturePainter(
              strokes: controller.strokes,
              penColor: penColor,
              background: background,
              strokeWidth: strokeWidth,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color penColor;
  final Color background;
  final double strokeWidth;

  _SignaturePainter({
    required this.strokes,
    required this.penColor,
    required this.background,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = background;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final pen = Paint()
      ..color = penColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        // Lone tap — draw a dot so single-press strokes are visible.
        canvas.drawCircle(stroke.first, strokeWidth / 2, pen..style = PaintingStyle.fill);
        pen.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, pen);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter old) =>
      old.strokes != strokes ||
      old.penColor != penColor ||
      old.background != background ||
      old.strokeWidth != strokeWidth;
}
