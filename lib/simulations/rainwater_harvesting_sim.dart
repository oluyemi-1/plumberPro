import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class RainwaterHarvestingSimScreen extends StatefulWidget {
  const RainwaterHarvestingSimScreen({super.key});
  @override
  State<RainwaterHarvestingSimScreen> createState() =>
      _RainwaterHarvestingSimScreenState();
}

class _RainwaterHarvestingSimScreenState
    extends State<RainwaterHarvestingSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _rain = true;
  bool _demand = false;
  double _level = 0.5;

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
    final dt = 1 / 60;
    double delta = 0;
    if (_rain) delta += 0.06 * dt;
    if (_demand) delta -= 0.09 * dt;
    if (_level < 0.15 && _demand) delta += 0.04 * dt; // mains top-up
    final next = (_level + delta).clamp(0.0, 1.0);
    if ((next - _level).abs() > 0.0005) {
      setState(() => _level = next);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_tick);
    _ctrl.dispose();
    super.dispose();
  }

  bool get _firstFlushDiverted => _ctrl.value < 0.18 && _rain;
  bool get _topUp => _level < 0.18 && _demand;

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Rainwater Harvesting',
      summary:
          'A domestic harvesting system feeds WCs, washing machine and an outside tap from collected roof water, with a first-flush diverter, calmed inlet, overflow and an air-gap mains top-up.',
      controls: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Rain'),
          Switch.adaptive(
            value: _rain,
            onChanged: (v) => setState(() => _rain = v),
          ),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Tap demand'),
          Switch.adaptive(
            value: _demand,
            onChanged: (v) => setState(() => _demand = v),
          ),
        ]),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Reset tank level'),
          onPressed: () => setState(() => _level = 0.5),
        ),
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tank level (manual): ${(_level * 100).round()}%',
                  style: const TextStyle(fontSize: 12)),
              Slider(
                value: _level,
                min: 0,
                max: 1,
                onChanged: (v) => setState(() => _level = v),
              ),
            ],
          ),
        ),
      ],
      diagramBuilder: (context, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _HarvestingPainter(
              step: stepIndex,
              t: _ctrl.value,
              rain: _rain,
              demand: _demand,
              level: _level,
              firstFlush: _firstFlushDiverted,
              topUp: _topUp,
            ),
            size: Size.infinite,
          ),
        );
      },
      steps: const [
        SimStep(
          title: 'Use case',
          narration:
              'Domestic rainwater harvesting supplies non-potable demands such as flushing, laundry and outside taps. That covers around half of household water demand and reduces mains usage.',
        ),
        SimStep(
          title: 'Catchment area and yield',
          narration:
              'Yield equals roof area times annual rainfall times a runoff coefficient around zero point eight for tiles. The result tells you the practical maximum litres available each year.',
        ),
        SimStep(
          title: 'First-flush diverter',
          narration:
              'A small chamber on the downpipe collects the first dirty rainwater that washes debris off the roof. After it fills, the cleaner flow continues to the storage tank.',
        ),
        SimStep(
          title: 'Tank sizing',
          narration:
              'A typical family installation uses fifteen hundred to five thousand litres. Sizing balances yield, demand and the longest dry period the property usually experiences.',
        ),
        SimStep(
          title: 'Calmed inlet and floating suction',
          narration:
              'A curved diffuser slows the inflow so it does not stir up sediment. A floating suction draws cleaner water from just below the surface, well above the silt layer.',
        ),
        SimStep(
          title: 'Overflow to surface water',
          narration:
              'Excess water leaves through an overflow with a backwater valve to a surface water drain. It must never connect to a foul system or contaminate the wholesome supply.',
        ),
        SimStep(
          title: 'Air-gap top-up',
          narration:
              'When stored water runs low and demand continues, a Type AA air gap drops mains water into a break tank. The unbroken air space prevents any back-flow into the supply.',
        ),
        SimStep(
          title: 'Distribution and labelling',
          narration:
              'All non-potable pipework must be marked clearly and isolation valves fitted at every outlet. This stops cross connections being made by future occupants or trades.',
        ),
        SimStep(
          title: 'Maintenance',
          narration:
              'Annual maintenance includes filter cleaning, pump inspection and verifying the air gap. Tanks need internal inspection every few years to remove accumulated sediment.',
        ),
        SimStep(
          title: 'Regulations',
          narration:
              'Installation must comply with the regulator-approved scheme, including back-flow protection and labelling. Notification to the water undertaker is required in most cases.',
        ),
      ],
    );
  }
}

class _HarvestingPainter extends CustomPainter {
  final int step;
  final double t;
  final bool rain;
  final bool demand;
  final double level;
  final bool firstFlush;
  final bool topUp;
  _HarvestingPainter({
    required this.step,
    required this.t,
    required this.rain,
    required this.demand,
    required this.level,
    required this.firstFlush,
    required this.topUp,
  });

  static const Color soil = Color(0xFF6B4226);
  static const Color grass = Color(0xFF4F8B3B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky / ground / underground
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.55),
      Paint()..color = const Color(0xFFCFE3F2).withValues(alpha: 0.5),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.55, w, h * 0.05),
      Paint()..color = grass,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.6, w, h * 0.4),
      Paint()..color = soil.withValues(alpha: 0.65),
    );

    // House on left
    final wallLeft = w * 0.05;
    final wallRight = w * 0.32;
    final wallTop = h * 0.32;
    final wallBottom = h * 0.55;
    canvas.drawRect(
      Rect.fromLTRB(wallLeft, wallTop, wallRight, wallBottom),
      Paint()..color = const Color(0xFFE8D9B0),
    );
    final ridge = Offset((wallLeft + wallRight) / 2, h * 0.14);
    final eaveL = Offset(wallLeft - 6, wallTop);
    final eaveR = Offset(wallRight + 6, wallTop);
    final roofPath = Path()
      ..moveTo(eaveL.dx, eaveL.dy)
      ..lineTo(ridge.dx, ridge.dy)
      ..lineTo(eaveR.dx, eaveR.dy)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFF7A2A1A));
    canvas.drawPath(
      roofPath,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Gutter and downpipe on right side of house
    final gutterRect = Rect.fromLTWH(eaveL.dx - 4, wallTop + 4,
        (eaveR.dx + 4) - (eaveL.dx - 4), 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(gutterRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF333A40),
    );
    final dpTop = Offset(gutterRect.right - 6, gutterRect.bottom);
    final diverterTop = Offset(dpTop.dx, h * 0.45);
    PipePainterHelpers.drawPipe(
      canvas,
      a: dpTop,
      b: diverterTop,
      color: const Color(0xFF333A40),
      width: 8,
    );

    // First-flush diverter chamber
    final ffRect = Rect.fromLTWH(diverterTop.dx - 18, diverterTop.dy, 36, 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(ffRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF555E68),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(ffRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // first flush ball
    final ballY = ffRect.bottom - 4 - (firstFlush ? 0 : 12);
    canvas.drawCircle(
      Offset(ffRect.center.dx, ballY),
      4,
      Paint()..color = AppColors.accent,
    );

    // Pipe to ground from diverter
    final groundIn = Offset(ffRect.center.dx, h * 0.6);
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(ffRect.center.dx, ffRect.bottom),
      b: groundIn,
      color: const Color(0xFF333A40),
      width: 8,
    );

    // Underground tank
    final tankRect = Rect.fromLTWH(w * 0.27, h * 0.66, w * 0.28, h * 0.28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tankRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFD7DCE3),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tankRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // water in tank
    final waterTop = tankRect.bottom - tankRect.height * level;
    canvas.drawRect(
      Rect.fromLTRB(
        tankRect.left + 4,
        waterTop,
        tankRect.right - 4,
        tankRect.bottom - 3,
      ),
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.65),
    );
    // ripple
    canvas.drawLine(
      Offset(tankRect.left + 6, waterTop + 1),
      Offset(tankRect.right - 6, waterTop + 1),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 1.2,
    );

    // Calmed inlet (curved diffuser) — connects from the down pipe at top of tank
    final inletEntry = Offset(tankRect.left + 24, tankRect.top + 6);
    PipePainterHelpers.drawPipe(
      canvas,
      a: groundIn,
      b: Offset(tankRect.left, tankRect.top + 14),
      color: const Color(0xFF333A40),
      width: 8,
    );
    final calmPath = Path()
      ..moveTo(tankRect.left, tankRect.top + 14)
      ..quadraticBezierTo(tankRect.left + 12, tankRect.top + 30, inletEntry.dx,
          tankRect.top + 50);
    canvas.drawPath(
      calmPath,
      Paint()
        ..color = const Color(0xFF333A40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // Floating suction (line down from top of water to suction header)
    final floatY = waterTop + 4;
    canvas.drawCircle(
      Offset(tankRect.center.dx + 14, floatY),
      6,
      Paint()..color = const Color(0xFFFFD24A),
    );
    canvas.drawLine(
      Offset(tankRect.center.dx + 14, floatY + 4),
      Offset(tankRect.right - 8, tankRect.bottom - 10),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.2,
    );

    // Submerged pump
    final pumpPos = Offset(tankRect.right - 12, tankRect.bottom - 14);
    canvas.drawRect(
      Rect.fromCenter(center: pumpPos, width: 16, height: 14),
      Paint()..color = const Color(0xFF2C3E50),
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(pumpPos.dx + 12, pumpPos.dy - 6), 'Pump');

    // Overflow with backwater valve to surface water drain on left of tank
    final ofA = Offset(tankRect.left, tankRect.top + 18);
    final ofB = Offset(tankRect.left - 22, tankRect.top + 18);
    final ofC = Offset(ofB.dx, h * 0.93);
    PipePainterHelpers.drawPipe(
        canvas, a: ofA, b: ofB, color: AppColors.coldWater, width: 7);
    PipePainterHelpers.drawPipe(
        canvas, a: ofB, b: ofC, color: AppColors.coldWater, width: 7);
    PipePainterHelpers.drawValve(canvas, Offset(ofB.dx, ofA.dy + 24),
        open: level > 0.95, size: 10);

    // Outlet pipe rising from pump to a manifold above ground
    final manifoldY = h * 0.62;
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(pumpPos.dx + 8, pumpPos.dy),
      b: Offset(pumpPos.dx + 8, manifoldY),
      color: AppColors.coldWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(pumpPos.dx + 8, manifoldY),
      b: Offset(w * 0.98, manifoldY),
      color: AppColors.coldWater,
      width: 8,
    );

    // Mains top-up via air-gap break tank (left, above ground)
    final breakRect = Rect.fromLTWH(w * 0.05, h * 0.62, 60, 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(breakRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFE1E6EC),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(breakRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // mains pipe approaching
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(breakRect.left - 22, breakRect.top + 6),
      b: Offset(breakRect.left + 8, breakRect.top + 6),
      color: AppColors.coldWater,
      width: 6,
    );
    // air gap
    canvas.drawRect(
      Rect.fromLTWH(breakRect.left + 6, breakRect.top + 4, 6, 12),
      Paint()..color = Colors.transparent,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(breakRect.left, breakRect.top - 16),
      'Air-gap break tank',
    );
    // top-up pipe down from break tank to main tank
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(breakRect.center.dx, breakRect.bottom),
      b: Offset(breakRect.center.dx, h * 0.74),
      color: AppColors.coldWater,
      width: 6,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(breakRect.center.dx, h * 0.74),
      b: Offset(tankRect.left + 14, tankRect.top + 4),
      color: AppColors.coldWater,
      width: 6,
    );

    // Outlets on right (icons): WC, Washing machine, Outside tap
    final wcCenter = Offset(w * 0.78, manifoldY - 24);
    _drawWc(canvas, wcCenter);
    final wmCenter = Offset(w * 0.86, manifoldY - 22);
    _drawWashingMachine(canvas, wmCenter);
    final tapCenter = Offset(w * 0.94, manifoldY - 18);
    _drawOutsideTap(canvas, tapCenter);

    // Riser branches
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(wcCenter.dx, manifoldY),
        b: Offset(wcCenter.dx, wcCenter.dy + 6),
        color: AppColors.coldWater,
        width: 5);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(wmCenter.dx, manifoldY),
        b: Offset(wmCenter.dx, wmCenter.dy + 6),
        color: AppColors.coldWater,
        width: 5);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(tapCenter.dx, manifoldY),
        b: Offset(tapCenter.dx, tapCenter.dy + 4),
        color: AppColors.coldWater,
        width: 5);

    // Rain and flow particles
    if (rain) {
      for (int i = 0; i < 18; i++) {
        final x = 30 + (i * 31 + (t * 60).round()) % (w - 60);
        final phase = (t + i * 0.07) % 1.0;
        final y = phase * h * 0.32;
        canvas.drawLine(
          Offset(x, y),
          Offset(x - 1.5, y + 5),
          Paint()
            ..color = AppColors.coldWater.withValues(alpha: 0.6)
            ..strokeWidth = 1.2,
        );
      }
      // Roof to gutter sloped flow
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: ridge,
        b: eaveR,
        progress: t,
        color: AppColors.coldWater,
        count: 5,
        radius: 2.4,
      );
      // gutter to diverter
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: dpTop,
        b: diverterTop,
        progress: t,
        color: Colors.white,
        count: 4,
        radius: 2.4,
      );
      // Diverter to tank (only when first flush has filled)
      if (!firstFlush) {
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: Offset(ffRect.center.dx, ffRect.bottom),
          b: groundIn,
          progress: t,
          color: Colors.white,
          count: 5,
          radius: 2.4,
        );
        PipePainterHelpers.drawFlowParticles(
          canvas,
          a: groundIn,
          b: inletEntry,
          progress: t,
          color: Colors.white,
          count: 4,
          radius: 2.2,
        );
      }
    }
    // Demand flow
    if (demand) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(pumpPos.dx + 8, manifoldY),
        b: Offset(w * 0.96, manifoldY),
        progress: t,
        color: Colors.white,
        count: 7,
        radius: 2.4,
      );
    }
    // Top-up flow
    if (topUp) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(breakRect.center.dx, breakRect.bottom),
        b: Offset(tankRect.left + 14, tankRect.top + 4),
        progress: t,
        color: Colors.white,
        count: 4,
        radius: 2.2,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(breakRect.center.dx - 30, breakRect.bottom + 6),
        'Mains topping up',
        background: AppColors.accent,
        textColor: Colors.white,
      );
    }
    // Overflow when full
    if (level > 0.97) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: ofB,
        b: ofC,
        progress: t,
        color: Colors.white,
        count: 6,
        radius: 2.4,
      );
    }

    // Labels
    PipePainterHelpers.drawLabel(
        canvas, Offset(eaveL.dx - 6, gutterRect.top - 16), 'Roof + gutter');
    PipePainterHelpers.drawLabel(
        canvas, Offset(ffRect.right + 6, ffRect.top - 4),
        'First-flush diverter');
    PipePainterHelpers.drawLabel(
        canvas, Offset(tankRect.left + 4, tankRect.top - 18),
        'Buried storage tank');
    PipePainterHelpers.drawLabel(canvas,
        Offset(inletEntry.dx + 10, inletEntry.dy + 6), 'Calmed inlet');
    PipePainterHelpers.drawLabel(
        canvas, Offset(ofB.dx - 80, ofB.dy - 16), 'Overflow + backwater valve');
    PipePainterHelpers.drawLabel(
        canvas, Offset(wcCenter.dx - 14, wcCenter.dy - 30), 'WC');
    PipePainterHelpers.drawLabel(
        canvas, Offset(wmCenter.dx - 18, wmCenter.dy - 30), 'Washer');
    PipePainterHelpers.drawLabel(
        canvas, Offset(tapCenter.dx - 18, tapCenter.dy - 30), 'Outside tap');
    PipePainterHelpers.drawLabel(canvas,
        Offset(tankRect.center.dx + 16, floatY - 14), 'Floating suction');

    // Step highlight ring
    final boxes = <int, Rect>{
      2: ffRect.inflate(8),
      3: tankRect.inflate(6),
      4: Rect.fromLTRB(tankRect.left, tankRect.top + 30, tankRect.right - 12,
          tankRect.bottom - 10),
      5: Rect.fromLTRB(ofB.dx - 14, ofA.dy - 6, ofB.dx + 14, ofC.dy),
      6: breakRect.inflate(6),
      7: Rect.fromLTRB(pumpPos.dx, manifoldY - 30, w * 0.98, manifoldY + 6),
    };
    final hb = boxes[step];
    if (hb != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(hb, const Radius.circular(8)),
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  void _drawWc(Canvas canvas, Offset c) {
    final r = Rect.fromCenter(center: c, width: 26, height: 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(c.dx, c.dy + 12), width: 22, height: 16),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  void _drawWashingMachine(Canvas canvas, Offset c) {
    final r = Rect.fromCenter(center: c, width: 22, height: 22);
    canvas.drawRect(r, Paint()..color = Colors.white);
    canvas.drawRect(
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      Offset(c.dx, c.dy + 2),
      6,
      Paint()
        ..color = AppColors.coldWater.withValues(alpha: 0.6),
    );
  }

  void _drawOutsideTap(Canvas canvas, Offset c) {
    canvas.drawRect(
      Rect.fromLTWH(c.dx - 5, c.dy - 6, 10, 6),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRect(
      Rect.fromLTWH(c.dx - 8, c.dy - 12, 16, 4),
      Paint()..color = AppColors.brass,
    );
  }

  @override
  bool shouldRepaint(covariant _HarvestingPainter o) => true;
}
