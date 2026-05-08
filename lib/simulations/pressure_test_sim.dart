import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class PressureTestSimScreen extends StatefulWidget {
  const PressureTestSimScreen({super.key});
  @override
  State<PressureTestSimScreen> createState() => _PressureTestSimScreenState();
}

class _PressureTestSimScreenState extends State<PressureTestSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _pressure = 0; // bar
  double _targetPressure = 0;
  bool _leak = false;
  bool _venting = false;

  static const double _testPressure = 12; // bar
  static const double _maxGauge = 16;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _ctrl.addListener(_tick);
  }

  void _tick() {
    // Smoothly approach target
    final dt = 1 / 60.0;
    setState(() {
      // Approach target pressure
      final delta = _targetPressure - _pressure;
      _pressure += delta * 0.06;
      // Leak slowly bleeds pressure
      if (_leak && _pressure > 0.05) {
        _pressure -= 0.04 * dt * 4; // gentle decay
        _targetPressure = math.max(0, _targetPressure - 0.04 * dt * 4);
      }
      if (_venting && _pressure > 0.01) {
        _pressure -= 0.6 * dt * 4;
        if (_pressure < 0) _pressure = 0;
      } else {
        _venting = false;
      }
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_tick);
    _ctrl.dispose();
    super.dispose();
  }

  void _pump() {
    setState(() {
      _targetPressure = math.min(_maxGauge, _targetPressure + 1);
    });
  }

  void _openVent() {
    setState(() {
      _venting = true;
      _targetPressure = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final steps = const [
      SimStep(
        title: 'Why pressure test',
        narration:
            'A hydrostatic pressure test confirms the integrity of newly installed pipework before commissioning. It catches weeping joints and weak fittings while the system is still empty and accessible.',
      ),
      SimStep(
        title: 'Test medium',
        narration:
            'Always use water as the test medium for water systems. Compressed gas stores enormous energy and a sudden failure can become a dangerous projectile, so it is not used for routine site testing.',
      ),
      SimStep(
        title: 'Equipment',
        narration:
            'A manual hand pump or an electric pump is connected via a hose to a calibrated pressure gauge. The gauge should read at least one and a half times the expected test pressure for accuracy in the working range.',
      ),
      SimStep(
        title: 'Cap, isolate, fill',
        narration:
            'Cap every open outlet and isolate the section under test. Fill the system fully and purge all air; trapped air compresses and masks small leaks, giving false readings.',
      ),
      SimStep(
        title: 'Pressurise to test pressure',
        narration:
            'Pump up to the test pressure, typically one and a half times working pressure. For a four bar mains supply that is around six bar minimum; many sites test to ten or twelve bar and hold for at least thirty minutes.',
      ),
      SimStep(
        title: 'Reading',
        narration:
            'Allow a few minutes for the water temperature and pipework to stabilise. Thermal expansion or contraction can shift the needle by itself, so always wait before judging the pressure drop.',
      ),
      SimStep(
        title: 'Acceptable drop',
        narration:
            'Rigid copper and steel systems should hold pressure with no measurable drop. Plastic pipework is allowed a small loss because the material relaxes under sustained pressure.',
      ),
      SimStep(
        title: 'Locate a leak',
        narration:
            'If the gauge falls, walk the run and inspect every joint. Listen for hissing, brush soap solution onto the fittings, and use a leak dye in the water if needed.',
      ),
      SimStep(
        title: 'After test',
        narration:
            'Open the vent valve to depressurise safely, drain to a bucket, then re-inspect and document the result on a Benchmark or commissioning sheet for the customer record.',
      ),
    ];

    return SimScaffold(
      title: 'Pressure Test',
      summary:
          'A hand pump pressurises a capped pipe section. Watch the gauge climb, hold under leak-free conditions, then drop slowly when a leak is introduced.',
      steps: steps,
      diagramBuilder: (ctx, step) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _PressurePainter(
              step: step,
              t: _ctrl.value,
              pressure: _pressure,
              testPressure: _testPressure,
              maxGauge: _maxGauge,
              leak: _leak,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
      controls: [
        ElevatedButton.icon(
          onPressed: _pump,
          icon: const Icon(Icons.arrow_upward),
          label: const Text('Pump'),
        ),
        OutlinedButton.icon(
          onPressed: _openVent,
          icon: const Icon(Icons.air),
          label: const Text('Open vent'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Introduce leak', style: TextStyle(fontSize: 12)),
            Switch.adaptive(
              value: _leak,
              onChanged: (v) => setState(() => _leak = v),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_pressure.toStringAsFixed(1)} bar',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _PressurePainter extends CustomPainter {
  final int step;
  final double t;
  final double pressure;
  final double testPressure;
  final double maxGauge;
  final bool leak;

  _PressurePainter({
    required this.step,
    required this.t,
    required this.pressure,
    required this.testPressure,
    required this.maxGauge,
    required this.leak,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.cardBg,
    );

    // Pipework (horizontal run with two elbows and a vertical cap)
    final yMain = h * 0.55;
    final pipeColor = AppColors.copper;
    final pumpHose = Offset(w * 0.06, yMain);
    final tIn = Offset(w * 0.22, yMain);
    final j1 = Offset(w * 0.40, yMain);
    final j2 = Offset(w * 0.58, yMain);
    final j3 = Offset(w * 0.72, yMain);
    final endRight = Offset(w * 0.88, yMain);
    // Vertical capped branch off j2
    final cap1 = Offset(j2.dx, yMain - h * 0.22);
    // Drop-down capped at j3
    final cap2 = Offset(j3.dx, yMain + h * 0.18);

    PipePainterHelpers.drawPipe(
      canvas,
      a: tIn,
      b: endRight,
      color: pipeColor,
      width: 12,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: j2,
      b: cap1,
      color: pipeColor,
      width: 12,
      highlighted: leak && t < 0.5,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: j3,
      b: cap2,
      color: pipeColor,
      width: 12,
    );

    // Joints
    for (final p in [tIn, j1, j2, j3, endRight]) {
      PipePainterHelpers.drawJoint(canvas, p);
    }

    // Caps (small disks)
    _drawCap(canvas, cap1, vertical: true);
    _drawCap(canvas, cap2, vertical: true);
    _drawCap(canvas, endRight, vertical: false);

    // Isolating valve between tIn and j1
    final isoValve = Offset((tIn.dx + j1.dx) / 2, yMain);
    PipePainterHelpers.drawValve(canvas, isoValve, open: pressure > 0.1);

    // Vent valve at top of cap1
    final ventP = Offset(cap1.dx, cap1.dy - 4);
    _drawSmallValve(canvas, ventP, open: false);

    // Hose from pump to tIn
    PipePainterHelpers.drawPipe(
      canvas,
      a: pumpHose,
      b: tIn,
      color: AppColors.waste,
      width: 8,
    );

    // Pump body
    _drawPump(canvas, Offset(pumpHose.dx, pumpHose.dy), pressure: pressure);

    // Drain bucket bottom right
    _drawBucket(canvas, Rect.fromLTWH(w * 0.82, h * 0.78, w * 0.13, h * 0.16));

    // Pressure gauge (top right)
    final gaugeC = Offset(w * 0.86, h * 0.18);
    final gaugeR = math.min(w, h) * 0.11;
    _drawGauge(canvas, gaugeC, gaugeR);

    // Leak drip animation at j2 / cap1 elbow if leaking
    if (leak && pressure > 0.5) {
      _drawDrip(canvas, Offset(j2.dx + 6, j2.dy + 6));
    }

    // Labels
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pumpHose.dx - 18, pumpHose.dy + 38),
      'Hand pump',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset((pumpHose.dx + tIn.dx) / 2 - 12, yMain - 28),
      'Hose',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(isoValve.dx - 30, yMain + 18),
      'Isolating valve',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ventP.dx + 8, ventP.dy - 10),
      'Vent valve',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cap1.dx - 28, cap1.dy - 24),
      'Capped outlet',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(j3.dx - 20, yMain - 22),
      'Joint to test',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(endRight.dx - 28, endRight.dy + 18),
      'End cap',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.82, h * 0.95 - 8),
      'Drain bucket',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gaugeC.dx - gaugeR, gaugeC.dy + gaugeR + 8),
      'Pressure gauge',
    );

    // Step hint
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 10),
      'Step ${step + 1}: Target ${testPressure.toStringAsFixed(0)} bar',
      background: AppColors.primary,
      textColor: Colors.white,
    );
  }

  void _drawPump(Canvas canvas, Offset base, {required double pressure}) {
    // Body
    final bodyRect = Rect.fromLTWH(base.dx - 18, base.dy - 60, 36, 80);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Stroke offset based on animation t (only when actively pumping ~ recently)
    final stroke = math.sin(t * 2 * math.pi) * 12;
    final handleY = base.dy - 70 + stroke;
    // Plunger rod
    canvas.drawLine(
      Offset(base.dx, base.dy - 60),
      Offset(base.dx, handleY),
      Paint()
        ..color = AppColors.pipeMetal
        ..strokeWidth = 5,
    );
    // Handle
    canvas.drawLine(
      Offset(base.dx - 22, handleY),
      Offset(base.dx + 22, handleY),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    // Foot
    final foot = Rect.fromLTWH(base.dx - 26, base.dy + 10, 52, 8);
    canvas.drawRect(foot, Paint()..color = Colors.black54);
  }

  void _drawCap(Canvas canvas, Offset p, {required bool vertical}) {
    final paint = Paint()..color = AppColors.brass;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rect = vertical
        ? Rect.fromCenter(center: p, width: 22, height: 12)
        : Rect.fromCenter(center: p, width: 12, height: 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      stroke,
    );
  }

  void _drawSmallValve(Canvas canvas, Offset p, {required bool open}) {
    final color = open ? AppColors.accent : Colors.grey.shade500;
    canvas.drawCircle(p, 5, Paint()..color = color);
    canvas.drawCircle(
      p,
      5,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Tap handle
    canvas.drawLine(
      Offset(p.dx - 6, p.dy - 8),
      Offset(p.dx + 6, p.dy - 8),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2,
    );
  }

  void _drawBucket(Canvas canvas, Rect r) {
    final paint = Paint()..color = AppColors.pipeMetal;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..moveTo(r.left, r.top)
      ..lineTo(r.right, r.top)
      ..lineTo(r.right - 6, r.bottom)
      ..lineTo(r.left + 6, r.bottom)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);
    // Handle
    canvas.drawArc(
      Rect.fromCenter(center: Offset(r.center.dx, r.top), width: r.width * 0.7, height: 10),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawDrip(Canvas canvas, Offset origin) {
    final dripT = (t * 2) % 1.0;
    final p = Offset(origin.dx, origin.dy + dripT * 30);
    final paint = Paint()..color = AppColors.coldWater.withValues(alpha: 1 - dripT * 0.5);
    final path = Path()
      ..moveTo(p.dx, p.dy - 6)
      ..quadraticBezierTo(p.dx - 4, p.dy, p.dx, p.dy + 4)
      ..quadraticBezierTo(p.dx + 4, p.dy, p.dx, p.dy - 6)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawGauge(Canvas canvas, Offset c, double r) {
    // Dial face
    final face = Paint()..color = Colors.white;
    canvas.drawCircle(c, r, face);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    // Bezel
    canvas.drawCircle(
      c,
      r * 1.08,
      Paint()
        ..color = AppColors.brass
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    // Tick marks
    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.5;
    for (int i = 0; i <= 8; i++) {
      final a = math.pi * 0.75 + (i / 8) * math.pi * 1.5;
      final p1 = Offset(c.dx + math.cos(a) * (r - 4), c.dy + math.sin(a) * (r - 4));
      final p2 = Offset(c.dx + math.cos(a) * (r - 12), c.dy + math.sin(a) * (r - 12));
      canvas.drawLine(p1, p2, tickPaint);
      // Number labels every 2 ticks
      if (i % 2 == 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: (i * (maxGauge / 8)).toStringAsFixed(0),
            style: const TextStyle(fontSize: 9, color: Colors.black87),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final lp = Offset(
          c.dx + math.cos(a) * (r - 22) - tp.width / 2,
          c.dy + math.sin(a) * (r - 22) - tp.height / 2,
        );
        tp.paint(canvas, lp);
      }
    }
    // Red zone
    final dangerStart = math.pi * 0.75 + (testPressure / maxGauge) * math.pi * 1.5;
    final dangerEnd = math.pi * 0.75 + math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - 2),
      dangerStart,
      dangerEnd - dangerStart,
      false,
      Paint()
        ..color = AppColors.hotWater
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    // Needle
    final needleAngle =
        math.pi * 0.75 + (pressure.clamp(0.0, maxGauge) / maxGauge) * math.pi * 1.5;
    final tip = Offset(
      c.dx + math.cos(needleAngle) * (r - 8),
      c.dy + math.sin(needleAngle) * (r - 8),
    );
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 4, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant _PressurePainter o) => true;
}
