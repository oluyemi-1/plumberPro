import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class HiddenLeakSimScreen extends StatefulWidget {
  const HiddenLeakSimScreen({super.key});
  @override
  State<HiddenLeakSimScreen> createState() => _HiddenLeakSimScreenState();
}

class _HiddenLeakSimScreenState extends State<HiddenLeakSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Diagnostic state
  bool _meterTested = false;
  bool _acousticTested = false;
  bool _thermalTested = false;
  bool _dyeTested = false;
  bool _pressureTested = false;
  bool _cavityOpen = false;
  bool _repaired = false;
  bool _finalPressureTested = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Patch intensity 0..1
  double get _patchIntensity {
    if (_repaired) return math.max(0.0, 0.7 - (_finalPressureTested ? 0.7 : 0.3));
    double v = 0.4;
    if (_meterTested) v += 0.05;
    if (_acousticTested) v += 0.05;
    if (_thermalTested) v += 0.05;
    if (_dyeTested) v += 0.05;
    if (_pressureTested) v += 0.05;
    if (_cavityOpen) v += 0.1;
    return v.clamp(0.0, 1.0);
  }

  bool get _meterTicking => !_repaired;

  List<SimStep> get _steps => const [
        SimStep(
          title: '1. Symptom — damp patch',
          narration:
              'Customer reports a damp patch on a downstairs ceiling and a noticeably higher water bill. Hidden leaks rarely show themselves directly; you have to triangulate them.',
        ),
        SimStep(
          title: '2. Meter test',
          narration:
              'Turn off every tap and appliance, then watch the water meter dial for 15 minutes. Movement with everything off is proof of a leak somewhere on the supply.',
        ),
        SimStep(
          title: '3. Acoustic listening',
          narration:
              'At a quiet hour use a stethoscope or electronic leak detector at fittings, valves, and along walls. A pressurised leak hisses at a frequency the ear and microphone both pick up.',
        ),
        SimStep(
          title: '4. Thermal pattern',
          narration:
              'Walk a cold floor with bare feet or an infrared camera. A hot pipe leak under the floor warms a clear stripe; a cold pipe leak cools a localised patch.',
        ),
        SimStep(
          title: '5. Dye test on heating',
          narration:
              'On a sealed system, add a high-visibility leak dye to the inhibitor. Coloured staining will reveal at the patch within hours and confirms heating versus mains origin.',
        ),
        SimStep(
          title: '6. Pressure test by section',
          narration:
              'Isolate sections with stop valves and watch the gauge. A drop on one section while others hold steady localises the leak to that branch.',
        ),
        SimStep(
          title: '7. Open the cavity',
          narration:
              'Mark up the wall or ceiling carefully and open the smallest possible inspection panel. Lift floorboards along the joist line to minimise reinstatement work.',
        ),
        SimStep(
          title: '8. Repair the fitting',
          narration:
              'Cut out and replace the failed fitting. Push-fit is fastest in tight spaces; solder where you have access and a clean, dry pipe. Always test before closing up.',
        ),
        SimStep(
          title: '9. Final pressure test',
          narration:
              'Re-pressurise and hold the section for 30 minutes at working pressure. A stable gauge means a sound joint; only then is the cavity safe to close.',
        ),
        SimStep(
          title: '10. Make good',
          narration:
              'Ventilate the cavity to dry timbers, sister any rotten joists, and reinstate plasterboard or boards. Leave the customer with documentation of where the section was repaired.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Diagnose: hidden leak',
      summary:
          'Find a leak you cannot see. Work through meter, acoustic, thermal, dye and pressure tests, then open the cavity, repair and pressure-test before reinstating finishes.',
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        ElevatedButton.icon(
          onPressed: () => setState(() => _meterTested = true),
          icon: const Icon(Icons.speed),
          label: const Text('Meter test'),
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _acousticTested = true),
          icon: const Icon(Icons.hearing),
          label: const Text('Acoustic test'),
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _thermalTested = true),
          icon: const Icon(Icons.thermostat),
          label: const Text('Thermal test'),
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _dyeTested = true),
          icon: const Icon(Icons.water_drop),
          label: const Text('Dye test'),
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _pressureTested = true),
          icon: const Icon(Icons.compress),
          label: const Text('Pressure test (sections)'),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _cavityOpen = true),
          icon: const Icon(Icons.crop_square),
          label: const Text('Open cavity'),
        ),
        ElevatedButton.icon(
          onPressed: _cavityOpen ? () => setState(() => _repaired = true) : null,
          icon: const Icon(Icons.build),
          label: const Text('Repair'),
        ),
        OutlinedButton.icon(
          onPressed: _repaired
              ? () => setState(() => _finalPressureTested = true)
              : null,
          icon: const Icon(Icons.verified),
          label: const Text('Final pressure test'),
        ),
        TextButton.icon(
          onPressed: () => setState(() {
            _meterTested = false;
            _acousticTested = false;
            _thermalTested = false;
            _dyeTested = false;
            _pressureTested = false;
            _cavityOpen = false;
            _repaired = false;
            _finalPressureTested = false;
          }),
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
      ],
      diagramBuilder: (ctx, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _HiddenLeakPainter(
              step: stepIndex,
              t: _ctrl.value,
              patchIntensity: _patchIntensity,
              meterTicking: _meterTicking,
              acousticTested: _acousticTested,
              thermalTested: _thermalTested,
              dyeTested: _dyeTested,
              pressureTested: _pressureTested,
              cavityOpen: _cavityOpen,
              repaired: _repaired,
              finalPressureTested: _finalPressureTested,
            ),
          ),
        );
      },
    );
  }
}

class _HiddenLeakPainter extends CustomPainter {
  final int step;
  final double t;
  final double patchIntensity;
  final bool meterTicking;
  final bool acousticTested;
  final bool thermalTested;
  final bool dyeTested;
  final bool pressureTested;
  final bool cavityOpen;
  final bool repaired;
  final bool finalPressureTested;

  _HiddenLeakPainter({
    required this.step,
    required this.t,
    required this.patchIntensity,
    required this.meterTicking,
    required this.acousticTested,
    required this.thermalTested,
    required this.dyeTested,
    required this.pressureTested,
    required this.cavityOpen,
    required this.repaired,
    required this.finalPressureTested,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background — split-level house section
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h),
        Paint()..color = const Color(0xFFEFF3F8));

    // Floor line between upstairs and downstairs
    final floorY = h * 0.50;
    canvas.drawRect(
      Rect.fromLTRB(0, floorY, w, floorY + 18),
      Paint()..color = const Color(0xFFCFA77B),
    );
    canvas.drawLine(Offset(0, floorY), Offset(w, floorY),
        Paint()..color = Colors.black54..strokeWidth = 1.2);
    canvas.drawLine(Offset(0, floorY + 18), Offset(w, floorY + 18),
        Paint()..color = Colors.black54..strokeWidth = 1.2);

    // Upstairs ceiling area title
    PipePainterHelpers.drawLabel(canvas, Offset(8, 6), 'Upstairs floor cavity',
        background: AppColors.primary, textColor: Colors.white);
    PipePainterHelpers.drawLabel(canvas, Offset(8, floorY + 26),
        'Downstairs ceiling',
        background: AppColors.primary, textColor: Colors.white);

    // Stop cock at entry
    final stopcock = Offset(w * 0.10, floorY + 80);
    PipePainterHelpers.drawValve(canvas, stopcock, open: true);
    PipePainterHelpers.drawLabel(
        canvas, Offset(stopcock.dx - 18, stopcock.dy + 18), 'Stop cock');

    // Water meter near entry
    final meter = Offset(w * 0.18, floorY + 80);
    _drawMeter(canvas, meter, ticking: meterTicking);
    PipePainterHelpers.drawLabel(
        canvas, Offset(meter.dx - 18, meter.dy + 22), 'Water meter');

    // Pipe from meter rising up into floor cavity
    final riserBot = Offset(w * 0.30, floorY + 80);
    final riserTop = Offset(w * 0.30, floorY - 6);
    PipePainterHelpers.drawPipe(
      canvas, a: meter, b: riserBot,
      color: AppColors.coldWater, width: 9);
    PipePainterHelpers.drawPipe(
      canvas, a: riserBot, b: riserTop,
      color: AppColors.coldWater, width: 9);

    // Pipe under upstairs floorboards (translucent overlay)
    final hiddenStart = Offset(w * 0.30, floorY + 6);
    final leakPoint = Offset(w * 0.55, floorY + 6);
    final hiddenEnd = Offset(w * 0.85, floorY + 6);
    // floorboard overlay
    final overlayRect = Rect.fromLTRB(w * 0.28, floorY, w * 0.90, floorY + 18);
    canvas.drawRect(
      overlayRect,
      Paint()..color = const Color(0xFFCFA77B).withValues(alpha: 0.55),
    );
    PipePainterHelpers.drawPipe(
      canvas, a: hiddenStart, b: hiddenEnd,
      color: AppColors.coldWater, width: 9);
    // Joist marks
    for (int i = 0; i < 5; i++) {
      final x = w * 0.32 + i * (w * 0.13);
      canvas.drawLine(Offset(x, floorY), Offset(x, floorY + 18),
          Paint()..color = Colors.black54..strokeWidth = 1);
    }
    PipePainterHelpers.drawLabel(
        canvas, Offset(w * 0.30, floorY - 22), 'Hidden pipe under floor');

    // Cavity opened?
    if (cavityOpen) {
      final cavityRect = Rect.fromCenter(
          center: leakPoint, width: 80, height: 22);
      canvas.drawRect(cavityRect,
          Paint()..color = Colors.white.withValues(alpha: 0.95));
      canvas.drawRect(
        cavityRect,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      PipePainterHelpers.drawLabel(
          canvas, Offset(cavityRect.left, cavityRect.top - 16),
          'Inspection cut',
          background: AppColors.accent, textColor: Colors.white);
    }

    // Leak point: drip if not repaired
    if (!repaired) {
      // wet halo
      canvas.drawCircle(
        leakPoint,
        14,
        Paint()
          ..color = AppColors.coldWater.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // drips falling
      for (int i = 0; i < 3; i++) {
        final dy = ((t + i / 3) % 1.0) * (h * 0.22);
        canvas.drawCircle(
          Offset(leakPoint.dx, leakPoint.dy + 14 + dy),
          2.6,
          Paint()
            ..color = dyeTested
                ? const Color(0xFF34C759)
                : AppColors.coldWater,
        );
      }
    } else {
      // repaired joint marker
      PipePainterHelpers.drawJoint(canvas, leakPoint, color: AppColors.copper);
      PipePainterHelpers.drawLabel(
          canvas, Offset(leakPoint.dx + 10, leakPoint.dy - 16), 'Repaired',
          background: Colors.green.shade600, textColor: Colors.white);
    }

    // Damp patch on downstairs ceiling
    final patchCenter = Offset(leakPoint.dx, floorY + 60);
    final patchRadius = 18 + patchIntensity * 28;
    canvas.drawCircle(
      patchCenter,
      patchRadius,
      Paint()
        ..color = (dyeTested
                ? const Color(0xFF34C759)
                : const Color(0xFF8C5A3C))
            .withValues(alpha: 0.25 + patchIntensity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      patchCenter,
      patchRadius * 0.6,
      Paint()
        ..color = (dyeTested
                ? const Color(0xFF34C759)
                : const Color(0xFF6B3F26))
            .withValues(alpha: 0.4 + patchIntensity * 0.4),
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(patchCenter.dx - 30, patchCenter.dy + patchRadius + 4),
        'Damp patch');

    // Acoustic test indicator
    if (acousticTested && !repaired) {
      for (int i = 1; i <= 3; i++) {
        canvas.drawCircle(
          leakPoint,
          14 + i * 8 + (math.sin(t * 2 * math.pi) * 2),
          Paint()
            ..color = AppColors.accent.withValues(alpha: 0.25 / i)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
      PipePainterHelpers.drawLabel(
          canvas, Offset(leakPoint.dx + 18, leakPoint.dy - 28),
          'Acoustic hit',
          background: AppColors.accent, textColor: Colors.white);
    }

    // Thermal test heat stripe along pipe
    if (thermalTested && !repaired) {
      final stripe = Rect.fromLTRB(hiddenStart.dx, floorY + 2,
          hiddenEnd.dx, floorY + 16);
      canvas.drawRect(
        stripe,
        Paint()
          ..color = AppColors.hotWater.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      PipePainterHelpers.drawLabel(
          canvas, Offset(hiddenStart.dx, floorY - 38), 'Thermal anomaly',
          background: AppColors.hotWater, textColor: Colors.white);
    }

    // Pressure gauge if pressureTested
    if (pressureTested) {
      final gaugeC = Offset(w * 0.12, floorY + 130);
      _drawGauge(canvas, gaugeC,
          value: finalPressureTested ? 1.0 : 0.7,
          stable: repaired && finalPressureTested);
      PipePainterHelpers.drawLabel(
          canvas, Offset(gaugeC.dx - 22, gaugeC.dy + 30), 'Pressure gauge');
    }

    // Section isolators downstream
    PipePainterHelpers.drawValve(
        canvas, Offset(w * 0.42, floorY + 6), open: !pressureTested);
    PipePainterHelpers.drawValve(
        canvas, Offset(w * 0.72, floorY + 6), open: !pressureTested);

    // Title
    PipePainterHelpers.drawLabel(canvas, Offset(w - 160, 6),
        'Hidden leak diagnostic',
        background: AppColors.primaryDark, textColor: Colors.white);
  }

  void _drawMeter(Canvas canvas, Offset c, {required bool ticking}) {
    final r = 18.0;
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    // ticking dial
    final angle = ticking
        ? (t * 2 * math.pi)
        : 0.6 * math.pi;
    final p = c + Offset(math.cos(angle) * (r - 4), math.sin(angle) * (r - 4));
    canvas.drawLine(c, p,
        Paint()..color = AppColors.accent..strokeWidth = 2);
    canvas.drawCircle(c, 2, Paint()..color = Colors.black87);
    // digits below
    final tp = TextPainter(
      text: const TextSpan(
        text: '0 0 1 4 7',
        style: TextStyle(
          fontSize: 9, color: AppColors.text, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy + r - 4));
  }

  void _drawGauge(Canvas canvas, Offset c,
      {required double value, required bool stable}) {
    final r = 22.0;
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    // arc
    final arc = Rect.fromCircle(center: c, radius: r - 4);
    canvas.drawArc(arc, math.pi, math.pi, false,
        Paint()
          ..color = Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    final needleAngle = math.pi + value * math.pi;
    final p = c +
        Offset(math.cos(needleAngle) * (r - 6),
            math.sin(needleAngle) * (r - 6));
    canvas.drawLine(c, p,
        Paint()..color = stable ? Colors.green.shade700 : AppColors.accent
          ..strokeWidth = 2.4);
    canvas.drawCircle(c, 2, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(_HiddenLeakPainter o) => true;
}
