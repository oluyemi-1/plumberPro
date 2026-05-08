import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum BendTool { spring, machine }

class PipeBendingSimScreen extends StatefulWidget {
  const PipeBendingSimScreen({super.key});
  @override
  State<PipeBendingSimScreen> createState() => _PipeBendingSimScreenState();
}

class _PipeBendingSimScreenState extends State<PipeBendingSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _step = 0;
  BendTool _tool = BendTool.machine;
  double _angle = 0; // 0..120 deg
  static const double tubeOD = 15; // mm shown as label

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Driven angle considers step progression (auto demos) + slider
  double _effectiveAngle() {
    // Steps 4..6 progressively show a 0->90 bend driven by t
    if (_step == 4) {
      return _angle * (_ctrl.value);
    }
    if (_step == 5) {
      // Spring back: bend to angle, then release back ~5 deg
      final e = _ctrl.value;
      if (e < 0.6) return _angle * (e / 0.6);
      // hold then snap back
      final back = (e - 0.6) / 0.4;
      return _angle - 5 * back;
    }
    return _angle;
  }

  @override
  Widget build(BuildContext context) {
    final steps = const [
      SimStep(
        title: 'Why bend rather than join',
        narration:
            'A clean bend gives a smoother bore than two elbows. Fewer fittings means less risk of leakage and a tidier finished installation.',
      ),
      SimStep(
        title: 'Tube preparation',
        narration:
            'Measure the developed length carefully and mark the centre of the bend. Square clean cuts and de-burred ends are essential before any bending takes place.',
      ),
      SimStep(
        title: 'Set-back',
        narration:
            'Set-back is the distance from a feature, such as a wall or fitting, to the centre of the bend. Allowing for it correctly is what makes bends land on the right marks.',
      ),
      SimStep(
        title: 'Loading the tube',
        narration:
            'Place the tube into the former groove and bring the back guide across so the tube is captured. Slide it past the back guide to your set-back mark before you start.',
      ),
      SimStep(
        title: 'Bend gently and progressively',
        narration:
            'Pull the lever in a smooth, even motion. Watch the degree marks on the former and approach the desired angle slowly to avoid overshooting.',
      ),
      SimStep(
        title: 'Spring-back',
        narration:
            'When the lever is released, copper relaxes and the bend opens by a few degrees. Over-bend a touch so it settles to the angle you actually want.',
      ),
      SimStep(
        title: 'Spring bender',
        narration:
            'For soft, annealed copper or microbore, an internal spring bender supports the bore as you bend over a knee. The spring is twisted slightly and withdrawn afterwards.',
      ),
      SimStep(
        title: 'Common faults',
        narration:
            'Look out for flattening across the bend, corrugation on the inside radius, and bends that are not square. Excessive force or the wrong size former all cause these defects.',
      ),
      SimStep(
        title: 'Inspection',
        narration:
            'A good bend has a round bore with no flats, no pinholing on the outer face, and ends that are square for a clean fit into the next fitting.',
      ),
    ];

    return SimScaffold(
      title: 'Pipe Bending',
      summary:
          'Bend 15 mm copper tube using either a hand-held spring bender or a lever machine bender. Slide the angle to drive the visual bend; later steps animate spring-back.',
      steps: steps,
      onStepChanged: (i) => setState(() => _step = i),
      diagramBuilder: (ctx, step) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _BendPainter(
            step: step,
            t: _ctrl.value,
            angleDeg: _effectiveAngle(),
            tool: _tool,
            tubeOD: tubeOD,
          ),
          child: const SizedBox.expand(),
        ),
      ),
      controls: [
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Spring'),
              selected: _tool == BendTool.spring,
              onSelected: (_) => setState(() => _tool = BendTool.spring),
            ),
            ChoiceChip(
              label: const Text('Machine'),
              selected: _tool == BendTool.machine,
              onSelected: (_) => setState(() => _tool = BendTool.machine),
            ),
          ],
        ),
        SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bend angle: ${_angle.toStringAsFixed(0)}°',
                  style: const TextStyle(fontSize: 12)),
              Slider(
                min: 0,
                max: 120,
                value: _angle,
                onChanged: (v) => setState(() => _angle = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BendPainter extends CustomPainter {
  final int step;
  final double t;
  final double angleDeg;
  final BendTool tool;
  final double tubeOD;

  _BendPainter({
    required this.step,
    required this.t,
    required this.angleDeg,
    required this.tool,
    required this.tubeOD,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.cardBg,
    );

    if (tool == BendTool.machine) {
      _paintMachine(canvas, w, h);
    } else {
      _paintSpring(canvas, w, h);
    }

    // Step hint
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 10),
      'Step ${step + 1}: ${tool == BendTool.machine ? "Machine bender" : "Spring bender"}',
      background: AppColors.primary,
      textColor: Colors.white,
    );
  }

  void _paintMachine(Canvas canvas, double w, double h) {
    // Former centre
    final centre = Offset(w * 0.45, h * 0.55);
    final formerR = math.min(w, h) * 0.18;

    // Former (grooved disc)
    canvas.drawCircle(
      centre,
      formerR,
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawCircle(
      centre,
      formerR,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Inner groove
    canvas.drawCircle(
      centre,
      formerR - 6,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Pivot pin
    canvas.drawCircle(centre, 6, Paint()..color = Colors.black87);

    // Degree marks on former
    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.4;
    for (int d = 0; d <= 120; d += 15) {
      final a = -math.pi / 2 + d * math.pi / 180;
      final p1 = Offset(
        centre.dx + math.cos(a) * (formerR - 2),
        centre.dy + math.sin(a) * (formerR - 2),
      );
      final p2 = Offset(
        centre.dx + math.cos(a) * (formerR + 4),
        centre.dy + math.sin(a) * (formerR + 4),
      );
      canvas.drawLine(p1, p2, tickPaint);
      if (d % 30 == 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: '$d°',
            style: const TextStyle(fontSize: 9, color: Colors.black87),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(
            centre.dx + math.cos(a) * (formerR + 12) - tp.width / 2,
            centre.dy + math.sin(a) * (formerR + 12) - tp.height / 2,
          ),
        );
      }
    }

    // Straight portion of tube before bend
    // Tube enters from the right, straight along the former tangent, then bends around former.
    final ang = angleDeg.clamp(0.0, 150.0) * math.pi / 180.0;

    // Entry tangent (horizontal to the right, approaching from right side of former)
    final entryStart = Offset(w * 0.95, centre.dy + formerR);
    final entryEnd = Offset(centre.dx, centre.dy + formerR);
    PipePainterHelpers.drawPipe(
      canvas,
      a: entryStart,
      b: entryEnd,
      color: AppColors.copper,
      width: 12,
    );

    // Bent arc around the former (radius = formerR + tube radius)
    final bendR = formerR + 6;
    final arcRect = Rect.fromCircle(center: centre, radius: bendR);
    // Outer outline + inner colour
    canvas.drawArc(
      arcRect,
      math.pi / 2,
      -ang,
      false,
      Paint()
        ..color = AppColors.copper.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      arcRect,
      math.pi / 2,
      -ang,
      false,
      Paint()
        ..color = AppColors.copper
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );

    // Tail of tube after the bend (continues from end of arc)
    final tailA = Offset(
      centre.dx + bendR * math.cos(math.pi / 2 - ang),
      centre.dy + bendR * math.sin(math.pi / 2 - ang),
    );
    // Direction tangent at that arc end:
    // Tangent on outside of circle perpendicular to radius. Radius dir:
    final radDir = Offset(math.cos(math.pi / 2 - ang), math.sin(math.pi / 2 - ang));
    final tan = Offset(-radDir.dy, radDir.dx); // perpendicular CCW
    final tailB = tailA + tan * (w * 0.18);
    PipePainterHelpers.drawPipe(
      canvas,
      a: tailA,
      b: tailB,
      color: AppColors.copper,
      width: 12,
    );

    // Back guide (slides along entry tube)
    final guideRect = Rect.fromCenter(
      center: Offset(entryEnd.dx + (entryStart.dx - entryEnd.dx) * 0.35, entryEnd.dy + 2),
      width: w * 0.18,
      height: 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(guideRect, const Radius.circular(3)),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(guideRect, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Lever handles — one fixed (vertical down), one rotates with bend angle
    // Fixed lever (down):
    final fixedHandle = Offset(centre.dx, centre.dy + formerR + 100);
    canvas.drawLine(
      Offset(centre.dx, centre.dy + formerR),
      fixedHandle,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 6,
    );
    canvas.drawCircle(fixedHandle, 8, Paint()..color = Colors.black87);

    // Moving lever (carries back guide / former roller around)
    final movHandleStart = Offset(
      centre.dx + (formerR + 8) * math.cos(math.pi / 2 - ang),
      centre.dy + (formerR + 8) * math.sin(math.pi / 2 - ang),
    );
    final movHandleEnd = movHandleStart + tan * (h * 0.35);
    canvas.drawLine(
      movHandleStart,
      movHandleEnd,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 6,
    );
    canvas.drawCircle(movHandleEnd, 8, Paint()..color = Colors.black87);

    // Tube clamp/stop
    final clampP = Offset(entryStart.dx - 14, entryStart.dy);
    canvas.drawRect(
      Rect.fromCenter(center: clampP, width: 14, height: 22),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRect(
      Rect.fromCenter(center: clampP, width: 14, height: 22),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Numerical labels: developed length, bending allowance
    final dl = 250 + (angleDeg * tubeOD * math.pi / 180.0);
    final ba = (angleDeg * (tubeOD + 6) * math.pi / 180.0);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 36),
      'Tube OD: ${tubeOD.toStringAsFixed(0)} mm',
      background: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 56),
      'Developed length: ${dl.toStringAsFixed(0)} mm',
      background: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 76),
      'Bend allowance: ${ba.toStringAsFixed(0)} mm',
      background: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 96),
      'Set-back: ${(tubeOD + 4).toStringAsFixed(0)} mm',
      background: Colors.white,
    );

    // Component labels
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(centre.dx - 28, centre.dy - formerR - 22),
      'Former',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(guideRect.center.dx - 30, guideRect.bottom + 6),
      'Back guide',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(clampP.dx - 14, clampP.dy + 18),
      'Stop',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(fixedHandle.dx + 10, fixedHandle.dy - 8),
      'Fixed lever',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(movHandleEnd.dx + 8, movHandleEnd.dy - 4),
      'Moving lever',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(centre.dx + formerR + 16, centre.dy - formerR + 4),
      'Degree marks',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tailB.dx - 24, tailB.dy + 12),
      'Bent tail',
    );
  }

  void _paintSpring(Canvas canvas, double w, double h) {
    // Tube laid horizontally with a bend partway along
    final start = Offset(w * 0.08, h * 0.55);
    final pivot = Offset(w * 0.55, h * 0.55);
    final ang = angleDeg.clamp(0.0, 150.0) * math.pi / 180.0;
    final tailLen = w * 0.30;

    // Straight portion
    PipePainterHelpers.drawPipe(
      canvas,
      a: start,
      b: pivot,
      color: AppColors.copper,
      width: 14,
    );

    // Bent portion (up and to the right depending on angle)
    final tail = Offset(
      pivot.dx + tailLen * math.cos(-ang),
      pivot.dy + tailLen * math.sin(-ang),
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: pivot,
      b: tail,
      color: AppColors.copper,
      width: 14,
    );

    // Knee block (round-ended pad)
    canvas.drawCircle(
      pivot,
      18,
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawCircle(
      pivot,
      18,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Spring shown peeking out of the start end (helical)
    final springStart = Offset(start.dx - 16, start.dy);
    final springEnd = Offset(start.dx + 50, start.dy);
    final springPaint = Paint()
      ..color = AppColors.pipeMetal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final segs = 16;
    final path = Path();
    for (int i = 0; i <= segs; i++) {
      final f = i / segs;
      final x = springStart.dx + (springEnd.dx - springStart.dx) * f;
      final y = springStart.dy + math.sin(f * math.pi * 8) * 5;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, springPaint);

    // Pull cord eyelet on spring
    canvas.drawCircle(springStart, 5, Paint()..color = AppColors.brass);

    // Hand sketch (simple oval representing grip on tail)
    canvas.drawOval(
      Rect.fromCenter(center: tail, width: 30, height: 18),
      Paint()..color = const Color(0xFFEFC9A8),
    );
    canvas.drawOval(
      Rect.fromCenter(center: tail, width: 30, height: 18),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    // Numerical
    final dl = 250 + (angleDeg * tubeOD * math.pi / 180.0);
    PipePainterHelpers.drawLabel(canvas, const Offset(12, 36), 'Tube: 15 mm soft copper');
    PipePainterHelpers.drawLabel(canvas, const Offset(12, 56),
        'Bend angle: ${0}°'.replaceFirst('0', angleDeg.toStringAsFixed(0)));
    PipePainterHelpers.drawLabel(
        canvas, Offset(12, 76), 'Developed length: ${dl.toStringAsFixed(0)} mm');
    PipePainterHelpers.drawLabel(canvas, const Offset(12, 96), 'Set-back: 19 mm');

    // Labels
    PipePainterHelpers.drawLabel(
        canvas, Offset(springEnd.dx + 6, start.dy - 26), 'Internal spring');
    PipePainterHelpers.drawLabel(
        canvas, Offset(springStart.dx - 30, springStart.dy + 12), 'Eyelet');
    PipePainterHelpers.drawLabel(
        canvas, Offset(pivot.dx - 18, pivot.dy + 24), 'Knee / former');
    PipePainterHelpers.drawLabel(
        canvas, Offset(start.dx + 20, start.dy + 18), 'Soft copper tube');
    PipePainterHelpers.drawLabel(
        canvas, Offset(tail.dx - 22, tail.dy - 28), 'Hand grip');
    PipePainterHelpers.drawLabel(
        canvas, Offset((start.dx + pivot.dx) / 2 - 30, start.dy - 28),
        'Set-back to bend centre');
  }

  @override
  bool shouldRepaint(covariant _BendPainter o) => true;
}
