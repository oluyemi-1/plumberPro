import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

/// Animated solar PV simulation showing array, inverter, diverter, battery
/// and grid export.
class SolarPvSimScreen extends StatefulWidget {
  const SolarPvSimScreen({super.key});

  @override
  State<SolarPvSimScreen> createState() => _SolarPvSimScreenState();
}

class _SolarPvSimScreenState extends State<SolarPvSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _sunlight = 70; // 0..100
  bool _diverterToImmersion = true;

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

  static const _steps = <SimStep>[
    SimStep(
      title: 'Photovoltaic principle',
      narration:
          'A photon striking the silicon cell knocks an electron across a junction. Multiply that by billions and you have a usable direct current at roughly 30 to 40 volts per panel.',
    ),
    SimStep(
      title: 'Strings and array',
      narration:
          'Panels are wired in series to make a string, raising voltage. Strings are then paralleled to add current. Voltage and current together set the inverter input window.',
    ),
    SimStep(
      title: 'DC isolator',
      narration:
          'Building Regs Part P requires a DC isolator on the roof side of the inverter. Open it before any work downstream so the live DC from the panels is broken safely.',
    ),
    SimStep(
      title: 'The inverter',
      narration:
          'The inverter converts DC into clean AC at 230 volts and 50 hertz to match the grid. It has anti-islanding protection, so it disconnects within milliseconds if the supply fails.',
    ),
    SimStep(
      title: 'Diversion options',
      narration:
          'Surplus AC can be diverted to the immersion in the cylinder, charged into a battery or exported. The PV diverter modulates power so nothing is wasted to the grid.',
    ),
    SimStep(
      title: 'Generation meter and MCS',
      narration:
          'A separate generation meter records all kilowatt hours produced. MCS commissioning paperwork is uploaded within ten working days so the customer can claim Smart Export.',
    ),
    SimStep(
      title: 'Smart meter and SEG',
      narration:
          'The Smart Export Guarantee, SEG, only pays for energy actually exported. A smart meter is essential because it measures import and export separately, half hour by half hour.',
    ),
    SimStep(
      title: 'Maintenance',
      narration:
          'PV is largely maintenance free. A visual inspection annually, check connectors, look for shading from new growth and clean the panels only if soiling is severe.',
    ),
  ];

  double get _powerW => 4000 * (_sunlight / 100);

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Solar PV with diverter',
      summary:
          'Adjust the sun and the diverter routing. Watch DC current run from the array through the DC isolator into the inverter, and then AC distribute to house loads, the immersion or battery, and grid export.',
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sunlight: ${_sunlight.round()}%'),
              Slider(
                value: _sunlight,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (v) => setState(() => _sunlight = v),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Divert to immersion'),
            Switch.adaptive(
              value: _diverterToImmersion,
              onChanged: (v) => setState(() => _diverterToImmersion = v),
            ),
          ],
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _PvPainter(
            step: i,
            t: _ctrl.value,
            sun: _sunlight,
            diverterToImmersion: _diverterToImmersion,
            powerW: _powerW,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _PvPainter extends CustomPainter {
  final int step;
  final double t;
  final double sun;
  final bool diverterToImmersion;
  final double powerW;

  _PvPainter({
    required this.step,
    required this.t,
    required this.sun,
    required this.diverterToImmersion,
    required this.powerW,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sunNorm = (sun / 100).clamp(0.0, 1.0);
    final on = sunNorm > 0.05;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEFF4F8),
    );
    // Sky tint
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.4),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB7DAF0), Color(0xFFEFF4F8)],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.4)),
    );

    // ----- Sun -----
    final sunC = Offset(w * 0.08, h * 0.08);
    canvas.drawCircle(
      sunC,
      22 + 8 * sunNorm,
      Paint()
        ..color = AppColors.gas.withValues(alpha: 0.35 * sunNorm)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawCircle(
      sunC,
      16,
      Paint()..color = AppColors.gas.withValues(alpha: 0.95),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(sunC.dx + 22, sunC.dy - 6),
      'Sunlight ${sun.round()}%',
    );

    // ----- Roof + 2x4 PV array -----
    final roofTopL = Offset(w * 0.22, h * 0.08);
    final roofTopR = Offset(w * 0.62, h * 0.02);
    final roofBotL = Offset(w * 0.26, h * 0.34);
    final roofBotR = Offset(w * 0.66, h * 0.28);
    final roofPath = Path()
      ..moveTo(roofTopL.dx, roofTopL.dy)
      ..lineTo(roofTopR.dx, roofTopR.dy)
      ..lineTo(roofBotR.dx, roofBotR.dy)
      ..lineTo(roofBotL.dx, roofBotL.dy)
      ..close();
    canvas.drawPath(
      roofPath,
      Paint()..color = const Color(0xFF8C5A3A),
    );
    canvas.drawPath(
      roofPath,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // 4 wide x 2 high panels
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 4; col++) {
        final tl = Offset.lerp(
          Offset.lerp(roofTopL, roofTopR, col / 4)!,
          Offset.lerp(roofBotL, roofBotR, col / 4)!,
          row / 2,
        )!;
        final tr = Offset.lerp(
          Offset.lerp(roofTopL, roofTopR, (col + 1) / 4)!,
          Offset.lerp(roofBotL, roofBotR, (col + 1) / 4)!,
          row / 2,
        )!;
        final bl = Offset.lerp(
          Offset.lerp(roofTopL, roofTopR, col / 4)!,
          Offset.lerp(roofBotL, roofBotR, col / 4)!,
          (row + 1) / 2,
        )!;
        final br = Offset.lerp(
          Offset.lerp(roofTopL, roofTopR, (col + 1) / 4)!,
          Offset.lerp(roofBotL, roofBotR, (col + 1) / 4)!,
          (row + 1) / 2,
        )!;
        final p = Path()
          ..moveTo(tl.dx + 2, tl.dy + 2)
          ..lineTo(tr.dx - 2, tr.dy + 2)
          ..lineTo(br.dx - 2, br.dy - 2)
          ..lineTo(bl.dx + 2, bl.dy - 2)
          ..close();
        canvas.drawPath(
          p,
          Paint()
            ..color = Color.lerp(
              const Color(0xFF1A2E45),
              const Color(0xFF3A6BA1),
              0.3 * sunNorm,
            )!,
        );
        canvas.drawPath(
          p,
          Paint()
            ..color = Colors.black87
            ..style = PaintingStyle.stroke,
        );
        // grid lines (cells)
        for (int gx = 1; gx < 4; gx++) {
          final aP = Offset.lerp(tl, tr, gx / 4)!;
          final bP = Offset.lerp(bl, br, gx / 4)!;
          canvas.drawLine(
            aP,
            bP,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.25)
              ..strokeWidth = 0.6,
          );
        }
      }
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(roofTopL.dx, roofTopL.dy - 18),
      'PV array (2x4)',
    );

    // Sun rays striking panels
    if (on) {
      final rayPaint = Paint()
        ..color = AppColors.gas.withValues(alpha: 0.55 * sunNorm)
        ..strokeWidth = 2;
      for (int i = 0; i < 6; i++) {
        final tt = ((t + i / 6) % 1.0);
        final start = Offset.lerp(sunC, roofTopL, 0.1 + 0.2 * tt)!;
        final end = Offset.lerp(start, roofTopL, 0.7)!;
        canvas.drawLine(start, end, rayPaint);
      }
    }

    // ----- DC down from array -----
    final dcA = Offset(roofBotR.dx - 30, roofBotR.dy);
    final dcIso = Offset(w * 0.50, h * 0.42);
    final invIn = Offset(w * 0.50, h * 0.50);
    PipePainterHelpers.drawPipe(
      canvas, a: dcA, b: Offset(dcIso.dx, dcA.dy),
      color: AppColors.copper, width: 6,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: Offset(dcIso.dx, dcA.dy), b: dcIso,
      color: AppColors.copper, width: 6,
    );
    _drawIsolator(canvas, dcIso, label: 'DC iso');
    PipePainterHelpers.drawPipe(
      canvas, a: dcIso, b: invIn, color: AppColors.copper, width: 6,
    );
    PipePainterHelpers.drawLabel(
      canvas, Offset(dcIso.dx + 18, dcIso.dy - 6), 'DC isolator',
    );

    // ----- Inverter -----
    final invRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.58),
      width: 120,
      height: 60,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(invRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF233646),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(invRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke,
    );
    // LEDs
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(invRect.left + 14 + i * 14, invRect.top + 12),
        4,
        Paint()
          ..color = (i == 1 && on)
              ? Colors.greenAccent
              : Colors.greenAccent.withValues(alpha: 0.3),
      );
    }
    // Display
    final disp = Rect.fromLTWH(
      invRect.left + 12, invRect.center.dy - 2, invRect.width - 24, 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(disp, const Radius.circular(3)),
      Paint()..color = const Color(0xFF0E1B24),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '${powerW.round()} W',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.greenAccent,
          fontFeatures: [FontFeature.tabularFigures()],
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: disp.width);
    tp.paint(canvas, Offset(disp.left + 8, disp.top + 2));
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(invRect.left, invRect.top - 18),
      'Inverter (DC -> AC)',
    );

    // ----- AC isolator below inverter -----
    final acIso = Offset(w * 0.50, h * 0.70);
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(invRect.center.dx, invRect.bottom),
      b: acIso,
      color: AppColors.brass,
      width: 6,
    );
    _drawIsolator(canvas, acIso, label: 'AC iso');
    PipePainterHelpers.drawLabel(
      canvas, Offset(acIso.dx + 18, acIso.dy - 6), 'AC isolator',
    );

    // ----- Consumer unit -----
    final cuRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.82),
      width: 180,
      height: 38,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cuRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFE6E9EE),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cuRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    // Breakers
    for (int i = 0; i < 6; i++) {
      final bx = cuRect.left + 10 + i * 26;
      canvas.drawRect(
        Rect.fromLTWH(bx, cuRect.top + 6, 18, cuRect.height - 12),
        Paint()..color = const Color(0xFF334155),
      );
    }
    PipePainterHelpers.drawLabel(
      canvas, Offset(cuRect.left, cuRect.top - 18), 'Consumer unit',
    );
    PipePainterHelpers.drawPipe(
      canvas, a: acIso, b: Offset(acIso.dx, cuRect.top),
      color: AppColors.brass, width: 6,
    );

    // ----- Branches from consumer unit -----
    // 1) House loads (left)
    final hl1 = Offset(cuRect.left + 10, cuRect.bottom);
    final hl2 = Offset(w * 0.10, cuRect.bottom + 20);
    PipePainterHelpers.drawPipe(
      canvas, a: hl1, b: Offset(hl1.dx, hl2.dy),
      color: AppColors.brass, width: 5,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: Offset(hl1.dx, hl2.dy), b: hl2,
      color: AppColors.brass, width: 5,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(hl2.dx - 12, hl2.dy + 12),
          width: 28, height: 22),
      Paint()..color = const Color(0xFFD6DCE4),
    );
    PipePainterHelpers.drawLabel(
      canvas, Offset(hl2.dx - 26, hl2.dy + 24), 'House loads',
    );

    // 2) PV diverter -> immersion -> cylinder
    final di1 = Offset(cuRect.left + 36, cuRect.bottom);
    final di2 = Offset(w * 0.30, cuRect.bottom + 18);
    final divCenter = Offset(w * 0.30, cuRect.bottom + 30);
    PipePainterHelpers.drawPipe(
      canvas, a: di1, b: Offset(di1.dx, di2.dy),
      color: AppColors.brass, width: 5,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: Offset(di1.dx, di2.dy), b: di2,
      color: AppColors.brass, width: 5,
    );
    final divRect = Rect.fromCenter(
      center: divCenter, width: 50, height: 22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(divRect, const Radius.circular(4)),
      Paint()..color = AppColors.accent.withValues(alpha: 0.85),
    );
    PipePainterHelpers.drawLabel(
      canvas, Offset(divRect.left - 6, divRect.bottom + 4), 'PV diverter',
    );
    // Cylinder (small) below diverter
    final cylRect =
        Rect.fromLTWH(w * 0.12, divRect.bottom + 22, 60, 70);
    PipePainterHelpers.drawTank(
      canvas, rect: cylRect, level: 0.85,
      waterColor: AppColors.hotWater, open: false, label: 'Cylinder',
    );
    // Immersion symbol
    canvas.drawCircle(
      Offset(cylRect.center.dx, cylRect.center.dy),
      6,
      Paint()..color = AppColors.gas,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cylRect.right + 4, cylRect.center.dy - 6),
      'Immersion',
    );
    PipePainterHelpers.drawPipe(
      canvas, a: divCenter, b: Offset(cylRect.center.dx, cylRect.top),
      color: AppColors.accent, width: 4,
    );

    // 3) Battery
    final bat1 = Offset(cuRect.right - 36, cuRect.bottom);
    final bat2 = Offset(w * 0.70, cuRect.bottom + 18);
    PipePainterHelpers.drawPipe(
      canvas, a: bat1, b: Offset(bat1.dx, bat2.dy),
      color: AppColors.brass, width: 5,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: Offset(bat1.dx, bat2.dy), b: bat2,
      color: AppColors.brass, width: 5,
    );
    final batRect = Rect.fromCenter(
      center: Offset(bat2.dx, bat2.dy + 18), width: 56, height: 30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(batRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawRect(
      Rect.fromLTWH(batRect.right - 4, batRect.top + 8, 4, 14),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawRect(
      Rect.fromLTWH(batRect.left + 4, batRect.top + 4,
          (batRect.width - 8) * 0.7, batRect.height - 8),
      Paint()..color = Colors.greenAccent.withValues(alpha: 0.7),
    );
    PipePainterHelpers.drawLabel(
      canvas, Offset(batRect.left, batRect.bottom + 4), 'Battery',
    );

    // 4) Export meter -> grid
    final ex1 = Offset(cuRect.right - 10, cuRect.bottom);
    final ex2 = Offset(w * 0.92, cuRect.bottom + 20);
    PipePainterHelpers.drawPipe(
      canvas, a: ex1, b: Offset(ex1.dx, ex2.dy),
      color: AppColors.brass, width: 5,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: Offset(ex1.dx, ex2.dy), b: ex2,
      color: AppColors.brass, width: 5,
    );
    final meterRect = Rect.fromCenter(
      center: Offset(ex2.dx - 6, ex2.dy + 14), width: 36, height: 26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(meterRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFFFF6CC),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(meterRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    PipePainterHelpers.drawLabel(
      canvas, Offset(meterRect.left - 4, meterRect.bottom + 4), 'Export meter',
    );
    // Grid pylon glyph
    final pyl = Offset(meterRect.center.dx, meterRect.bottom + 26);
    canvas.drawLine(
      Offset(pyl.dx - 8, pyl.dy + 14),
      Offset(pyl.dx, pyl.dy - 12),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 1.6,
    );
    canvas.drawLine(
      Offset(pyl.dx + 8, pyl.dy + 14),
      Offset(pyl.dx, pyl.dy - 12),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 1.6,
    );
    canvas.drawLine(
      Offset(pyl.dx - 6, pyl.dy),
      Offset(pyl.dx + 6, pyl.dy),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 1.6,
    );
    PipePainterHelpers.drawLabel(
      canvas, Offset(pyl.dx - 8, pyl.dy + 18), 'Grid',
    );

    // ----- DC and AC particles only when on -----
    if (on) {
      // DC route: array drop -> dc iso -> inverter
      PipePainterHelpers.drawFlowParticles(
        canvas, a: dcA, b: Offset(dcIso.dx, dcA.dy),
        progress: t, color: AppColors.copper, count: 3,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas, a: Offset(dcIso.dx, dcA.dy), b: dcIso,
        progress: t, color: AppColors.copper, count: 2,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas, a: dcIso, b: invIn, progress: t,
        color: AppColors.copper, count: 2,
      );
      // AC route: inverter -> AC iso -> consumer unit
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(invRect.center.dx, invRect.bottom),
        b: acIso,
        progress: t,
        color: AppColors.gas,
        count: 2,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas, a: acIso, b: Offset(acIso.dx, cuRect.top),
        progress: t, color: AppColors.gas, count: 2,
      );
      // House loads always uses some
      PipePainterHelpers.drawFlowParticles(
        canvas, a: hl1, b: Offset(hl1.dx, hl2.dy),
        progress: t, color: AppColors.gas, count: 2,
      );
      // Diverter route lit if surplus to immersion
      if (diverterToImmersion && sun > 30) {
        PipePainterHelpers.drawFlowParticles(
          canvas, a: di1, b: di2, progress: t,
          color: AppColors.accent, count: 3,
        );
        PipePainterHelpers.drawFlowParticles(
          canvas, a: divCenter,
          b: Offset(cylRect.center.dx, cylRect.top),
          progress: t, color: AppColors.accent, count: 2,
        );
      } else if (sun > 30) {
        // Export route
        PipePainterHelpers.drawFlowParticles(
          canvas, a: ex1, b: Offset(ex1.dx, ex2.dy),
          progress: t, color: AppColors.gas, count: 3,
        );
        PipePainterHelpers.drawFlowParticles(
          canvas, a: Offset(ex1.dx, ex2.dy), b: ex2,
          progress: t, color: AppColors.gas, count: 2,
        );
      }
      // Battery trickle if sun > 50
      if (sun > 50) {
        PipePainterHelpers.drawFlowParticles(
          canvas, a: bat1, b: bat2, progress: t,
          color: Colors.greenAccent, count: 2,
        );
      }
    }

    // Joints
    PipePainterHelpers.drawJoint(canvas, Offset(dcIso.dx, dcA.dy));
    PipePainterHelpers.drawJoint(canvas, Offset(acIso.dx, cuRect.top));
    PipePainterHelpers.drawJoint(canvas, Offset(hl1.dx, hl2.dy));

    // Status badges
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, h - 60),
      'Generation: ${powerW.round()} W',
      background: AppColors.gas.withValues(alpha: 0.2),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, h - 40),
      diverterToImmersion ? 'Surplus -> Immersion' : 'Surplus -> Grid export',
      background: diverterToImmersion
          ? AppColors.accent.withValues(alpha: 0.2)
          : AppColors.coldWater.withValues(alpha: 0.2),
    );
    PipePainterHelpers.drawLabel(
      canvas, Offset(12, h - 20), 'Step ${step + 1}',
      background: AppColors.primary.withValues(alpha: 0.18),
    );
  }

  void _drawIsolator(Canvas canvas, Offset c, {required String label}) {
    final r = Rect.fromCenter(center: c, width: 30, height: 14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()..color = const Color(0xFFD8DEE5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(c.dx + 4, c.dy),
      3,
      Paint()..color = AppColors.accent,
    );
    // tiny lever
    canvas.drawLine(
      Offset(c.dx + 4, c.dy),
      Offset(c.dx + 12, c.dy - 4),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.6,
    );
    // suppress unused param warning by referencing
    if (label.isEmpty) {
      // no-op
      math.pi;
    }
  }

  @override
  bool shouldRepaint(_PvPainter o) =>
      o.step != step ||
      o.t != t ||
      o.sun != sun ||
      o.diverterToImmersion != diverterToImmersion ||
      o.powerW != powerW;
}
