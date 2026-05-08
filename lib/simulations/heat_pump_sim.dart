import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

/// Animated air-source heat pump refrigerant cycle simulation.
class HeatPumpSimScreen extends StatefulWidget {
  const HeatPumpSimScreen({super.key});

  @override
  State<HeatPumpSimScreen> createState() => _HeatPumpSimScreenState();
}

class _HeatPumpSimScreenState extends State<HeatPumpSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _outsideTemp = 7; // degrees C, slider value

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
      title: 'Four key components',
      narration:
          'A heat pump has four core parts. Evaporator, compressor, condenser and expansion valve. Together they form a sealed loop that moves heat from outside the house to inside.',
    ),
    SimStep(
      title: 'Evaporator absorbs heat',
      narration:
          'Outside air is drawn across the evaporator coil by the fan. Liquid refrigerant inside boils to a low pressure vapour, taking heat from the air even when the air feels cold.',
    ),
    SimStep(
      title: 'Compression raises temperature',
      narration:
          'The compressor squeezes the cool vapour into a smaller volume. Pressure climbs and so does temperature, pushing the refrigerant well above the heating water it is about to heat.',
    ),
    SimStep(
      title: 'Condenser delivers heat',
      narration:
          'Hot refrigerant gives up its heat to the heating water in the indoor condenser, condensing back to a warm liquid. The water leaves at a flow temperature of around 35 to 50 degrees.',
    ),
    SimStep(
      title: 'Expansion valve drops pressure',
      narration:
          'The expansion valve releases pressure on the warm liquid, which cools rapidly and is ready to absorb heat again at the evaporator. The cycle is now closed.',
    ),
    SimStep(
      title: 'The cycle just moves heat',
      narration:
          'A heat pump never creates heat, it moves it. That is why one kilowatt of electricity can deliver three or four kilowatts of useful heat output to the property.',
    ),
    SimStep(
      title: 'COP and SCOP',
      narration:
          'COP is heat out divided by electricity in at one operating point. SCOP averages performance across the heating season, and is the figure quoted on MCS designs and BUS grant paperwork.',
    ),
    SimStep(
      title: 'Why low flow temperature matters',
      narration:
          'The lower the flow temperature, the higher the SCOP. That is why we upsize radiators and prefer underfloor heating, so the design temperature can be 35 to 45 degrees rather than 70.',
    ),
  ];

  // For show: COP increases as outside air rises and falls below 0.
  double get _cop {
    final delta = 35.0 - _outsideTemp; // sink temp minus source
    final v = 4.5 - 0.06 * delta;
    return v.clamp(1.6, 5.5);
  }

  @override
  Widget build(BuildContext context) {
    // Slow at -10, faster at +20. Map to seconds 6.0..2.0.
    final tNorm = ((_outsideTemp + 10) / 30).clamp(0.0, 1.0);
    final dur = 6.0 - tNorm * 4.0;
    if ((_ctrl.duration!.inMilliseconds / 1000.0 - dur).abs() > 0.05) {
      final wasAnimating = _ctrl.isAnimating;
      _ctrl.duration = Duration(milliseconds: (dur * 1000).round());
      if (wasAnimating) _ctrl.repeat();
    }

    return SimScaffold(
      title: 'Air-source heat pump cycle',
      summary:
          'Watch refrigerant flow round an ASHP loop. The fan drags air through the evaporator, the compressor heats the vapour, the indoor condenser hands heat to the underfloor circuit and the expansion valve resets pressure.',
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Outside air: ${_outsideTemp.toStringAsFixed(0)} °C'),
              Slider(
                value: _outsideTemp,
                min: -10,
                max: 20,
                divisions: 30,
                onChanged: (v) => setState(() => _outsideTemp = v),
              ),
              Text(
                'COP ≈ ${_cop.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _HeatPumpPainter(
            step: i,
            t: _ctrl.value,
            outsideTemp: _outsideTemp,
            cop: _cop,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _HeatPumpPainter extends CustomPainter {
  final int step;
  final double t;
  final double outsideTemp;
  final double cop;

  _HeatPumpPainter({
    required this.step,
    required this.t,
    required this.outsideTemp,
    required this.cop,
  });

  static const Color suctionCool = Color(0xFF4DA8DA);
  static const Color dischargeHot = Color(0xFFE94E1B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEFF4F8),
    );

    // Outdoor / indoor wall divider
    final wallX = w * 0.5;
    canvas.drawLine(
      Offset(wallX, 0),
      Offset(wallX, h * 0.78),
      Paint()
        ..color = Colors.black26
        ..strokeWidth = 2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(wallX - 60, 6),
      'OUTDOOR',
      background: AppColors.coldWater.withValues(alpha: 0.18),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(wallX + 8, 6),
      'INDOOR',
      background: AppColors.hotWater.withValues(alpha: 0.18),
    );

    // ----- Outdoor unit casing -----
    final outdoorRect =
        Rect.fromLTWH(w * 0.05, h * 0.18, w * 0.38, h * 0.42);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outdoorRect, const Radius.circular(10)),
      Paint()..color = const Color(0xFFD8DEE5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(outdoorRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(outdoorRect.left, outdoorRect.top - 18),
      'Outdoor unit',
    );

    // Evaporator coil (vertical zig-zag)
    final evapRect =
        Rect.fromLTWH(outdoorRect.left + 12, outdoorRect.top + 14, 20,
            outdoorRect.height - 28);
    _drawCoilZig(canvas, evapRect, suctionCool);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(evapRect.left - 4, evapRect.bottom + 4),
      'Evaporator',
    );

    // Fan (rotating)
    final fanCenter = Offset(outdoorRect.right - 60, outdoorRect.center.dy);
    _drawFan(canvas, fanCenter, t);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(fanCenter.dx - 12, outdoorRect.top + 6),
      'Fan',
    );

    // Compressor (cylinder, pulses)
    final compCenter =
        Offset(outdoorRect.right - 30, outdoorRect.bottom - 38);
    final pulse = 0.5 + 0.5 * math.sin(t * 6.2831853 * 2);
    _drawCompressor(canvas, compCenter, pulse);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(compCenter.dx - 28, compCenter.dy + 22),
      'Compressor',
    );

    // Expansion valve in outdoor unit
    final expValve =
        Offset(outdoorRect.left + 50, outdoorRect.bottom - 18);
    _drawExpansionValve(canvas, expValve);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(expValve.dx - 28, expValve.dy + 16),
      'Expansion valve',
    );

    // ----- Indoor unit casing -----
    final indoorRect =
        Rect.fromLTWH(w * 0.56, h * 0.18, w * 0.18, h * 0.32);
    canvas.drawRRect(
      RRect.fromRectAndRadius(indoorRect, const Radius.circular(10)),
      Paint()..color = const Color(0xFFE6E9EE),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(indoorRect, const Radius.circular(10)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(indoorRect.left, indoorRect.top - 18),
      'Indoor unit',
    );
    final condRect = Rect.fromLTWH(
      indoorRect.left + 14,
      indoorRect.top + 14,
      indoorRect.width - 28,
      indoorRect.height - 28,
    );
    _drawCoilZig(canvas, condRect, dischargeHot);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(condRect.left, condRect.bottom + 4),
      'Condenser',
    );

    // ----- Buffer tank -----
    final bufferRect =
        Rect.fromLTWH(w * 0.78, h * 0.20, w * 0.12, h * 0.38);
    PipePainterHelpers.drawTank(
      canvas,
      rect: bufferRect,
      level: 0.85,
      waterColor: AppColors.hotWater,
      open: false,
      label: 'Buffer tank',
    );

    // Indoor unit -> buffer tank pipes (flow & return)
    final puFlow = Offset(indoorRect.right, indoorRect.top + 24);
    final bufFlow = Offset(bufferRect.left, bufferRect.top + 26);
    final puRet = Offset(indoorRect.right, indoorRect.bottom - 24);
    final bufRet = Offset(bufferRect.left, bufferRect.bottom - 28);
    _drawElbow(canvas, puFlow, bufFlow, AppColors.hotWater);
    _drawElbow(canvas, bufRet, puRet, AppColors.coldWater);

    // ----- Underfloor heating loop -----
    final ufBaseY = h * 0.86;
    canvas.drawRect(
      Rect.fromLTWH(0, ufBaseY - 4, w, 6),
      Paint()..color = const Color(0xFF8B5A2B),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.04, ufBaseY + 6),
      'Underfloor heating',
    );

    // Buffer flow down to UFH
    final bDown1 = Offset(bufferRect.center.dx, bufferRect.bottom);
    final bDown2 = Offset(bufferRect.center.dx, ufBaseY - 14);
    PipePainterHelpers.drawPipe(
      canvas,
      a: bDown1,
      b: bDown2,
      color: AppColors.hotWater,
      width: 7,
    );

    // UFH serpentine
    final ufLeft = w * 0.08;
    final ufRight = w * 0.74;
    final loopY1 = ufBaseY - 14;
    final loopY2 = ufBaseY - 6;
    // top run from buffer down across to far left, then snake
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(bDown2.dx, loopY1),
      b: Offset(ufLeft, loopY1),
      color: AppColors.hotWater,
      width: 6,
    );
    // Serpentine: a few short verticals
    var rowsLeft = ufLeft;
    for (int i = 0; i < 4; i++) {
      final x1 = rowsLeft + i * 30;
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(x1, loopY1),
        b: Offset(x1, loopY2),
        color: AppColors.hotWater.withValues(alpha: 0.85),
        width: 5,
      );
    }
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(ufLeft, loopY2),
      b: Offset(ufRight, loopY2),
      color: AppColors.coldWater.withValues(alpha: 0.85),
      width: 6,
    );
    // Cool return from UFH up to buffer base right side
    final retU1 = Offset(ufRight, loopY2);
    final retU2 = Offset(ufRight, h * 0.66);
    final retU3 = Offset(bufferRect.right - 8, h * 0.66);
    final retU4 = Offset(bufferRect.right - 8, bufferRect.bottom);
    PipePainterHelpers.drawPipe(
      canvas,
      a: retU1,
      b: retU2,
      color: AppColors.coldWater,
      width: 6,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: retU2,
      b: retU3,
      color: AppColors.coldWater,
      width: 6,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: retU3,
      b: retU4,
      color: AppColors.coldWater,
      width: 6,
    );

    // ----- Refrigerant loop wiring inside outdoor + across to indoor -----
    // Evaporator bottom -> compressor (suction, cool blue)
    final evapBot = Offset(evapRect.center.dx, evapRect.bottom + 4);
    final sucA = evapBot;
    final sucB = Offset(compCenter.dx - 14, evapBot.dy);
    final sucC = Offset(compCenter.dx - 14, compCenter.dy);
    PipePainterHelpers.drawPipe(
      canvas, a: sucA, b: sucB, color: suctionCool, width: 6,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: sucB, b: sucC, color: suctionCool, width: 6,
    );

    // Compressor -> indoor condenser top (discharge, hot orange)
    final disA = Offset(compCenter.dx + 14, compCenter.dy);
    final disB = Offset(compCenter.dx + 14, outdoorRect.top + 8);
    final disC = Offset(condRect.center.dx, outdoorRect.top + 8);
    final disD = Offset(condRect.center.dx, condRect.top - 4);
    PipePainterHelpers.drawPipe(
      canvas, a: disA, b: disB, color: dischargeHot, width: 6,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: disB, b: disC, color: dischargeHot, width: 6,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: disC, b: disD, color: dischargeHot, width: 6,
    );

    // Condenser bottom -> expansion valve (warm liquid, dimmer hot)
    final liqA = Offset(condRect.center.dx, condRect.bottom + 4);
    final liqB = Offset(condRect.center.dx, outdoorRect.bottom - 10);
    final liqC = Offset(expValve.dx + 12, outdoorRect.bottom - 10);
    final liqD = Offset(expValve.dx + 12, expValve.dy);
    PipePainterHelpers.drawPipe(
      canvas, a: liqA, b: liqB, color: dischargeHot.withValues(alpha: 0.6),
      width: 5,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: liqB, b: liqC, color: dischargeHot.withValues(alpha: 0.6),
      width: 5,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: liqC, b: liqD, color: dischargeHot.withValues(alpha: 0.6),
      width: 5,
    );

    // Expansion valve -> evaporator top (cold liquid)
    final coldA = Offset(expValve.dx - 12, expValve.dy);
    final coldB = Offset(evapRect.center.dx, expValve.dy);
    final coldC = Offset(evapRect.center.dx, evapRect.top - 4);
    PipePainterHelpers.drawPipe(
      canvas, a: coldA, b: coldB, color: suctionCool.withValues(alpha: 0.85),
      width: 5,
    );
    PipePainterHelpers.drawPipe(
      canvas, a: coldB, b: coldC, color: suctionCool.withValues(alpha: 0.85),
      width: 5,
    );

    // ----- Refrigerant particles -----
    final particleColor = AppColors.accent;
    PipePainterHelpers.drawFlowParticles(
      canvas, a: sucA, b: sucB, progress: t, color: suctionCool, count: 3,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: sucB, b: sucC, progress: t, color: suctionCool, count: 2,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: disA, b: disB, progress: t, color: particleColor, count: 3,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: disB, b: disC, progress: t, color: particleColor, count: 4,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: disC, b: disD, progress: t, color: particleColor, count: 2,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: liqA, b: liqB, progress: t, color: particleColor, count: 3,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: liqC, b: liqD, progress: t, color: particleColor, count: 2,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: coldA, b: coldB, progress: t, color: suctionCool, count: 3,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: coldB, b: coldC, progress: t, color: suctionCool, count: 2,
    );

    // Heating water particles (UFH loop)
    PipePainterHelpers.drawFlowParticles(
      canvas, a: bDown1, b: bDown2, progress: t,
      color: Colors.white, count: 3,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: Offset(bDown2.dx, loopY1),
      b: Offset(ufLeft, loopY1),
      progress: t,
      color: Colors.white,
      count: 4,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: Offset(ufLeft, loopY2),
      b: Offset(ufRight, loopY2),
      progress: t,
      color: Colors.white,
      count: 4,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas, a: retU2, b: retU3, progress: t,
      color: Colors.white, count: 3,
    );

    // Joints
    PipePainterHelpers.drawJoint(canvas, Offset(sucB.dx, sucB.dy));
    PipePainterHelpers.drawJoint(canvas, Offset(disB.dx, disB.dy));
    PipePainterHelpers.drawJoint(canvas, Offset(disC.dx, disC.dy));

    // Status badges
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, h - 60),
      'Outside ${outsideTemp.toStringAsFixed(0)} °C',
      background: AppColors.coldWater.withValues(alpha: 0.2),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, h - 40),
      'COP ≈ ${cop.toStringAsFixed(2)}',
      background: AppColors.accent.withValues(alpha: 0.2),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, h - 20),
      'Step ${step + 1}',
      background: AppColors.primary.withValues(alpha: 0.18),
    );
  }

  void _drawCoilZig(Canvas canvas, Rect rect, Color color) {
    final body = Paint()..color = const Color(0xFF1B1F26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      body,
    );
    final coil = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    final loops = (rect.height / 14).floor().clamp(3, 12);
    final dy = rect.height / loops;
    for (int i = 0; i < loops; i++) {
      final y = rect.top + (i + 0.5) * dy;
      canvas.drawArc(
        Rect.fromLTWH(rect.left + 1, y - dy / 2, rect.width - 2, dy),
        0,
        math.pi,
        false,
        coil,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawFan(Canvas canvas, Offset c, double rot) {
    canvas.drawCircle(
      c, 24, Paint()..color = const Color(0xFF334155),
    );
    canvas.drawCircle(
      c,
      24,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final blade = Paint()..color = const Color(0xFFB7C2CC);
    for (int i = 0; i < 3; i++) {
      final a = rot * 6.2831853 + i * (math.pi * 2 / 3);
      final tip = Offset(
        c.dx + 20 * math.cos(a),
        c.dy + 20 * math.sin(a),
      );
      final p = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(
          c.dx + 6 * math.cos(a + 0.6),
          c.dy + 6 * math.sin(a + 0.6),
        )
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(
          c.dx + 6 * math.cos(a - 0.6),
          c.dy + 6 * math.sin(a - 0.6),
        )
        ..close();
      canvas.drawPath(p, blade);
    }
    canvas.drawCircle(c, 4, Paint()..color = Colors.black);
  }

  void _drawCompressor(Canvas canvas, Offset c, double pulse) {
    final r = Rect.fromCenter(center: c, width: 36, height: 50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()..color = const Color(0xFF233646),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Pulsing inner indicator
    canvas.drawCircle(
      c,
      6 + 3 * pulse,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.4 + 0.5 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(c, 5, Paint()..color = AppColors.accent);
  }

  void _drawExpansionValve(Canvas canvas, Offset c) {
    final r = Rect.fromCenter(center: c, width: 26, height: 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    // Tiny needle
    canvas.drawLine(
      Offset(c.dx, c.dy - 12),
      Offset(c.dx, c.dy + 12),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 1.4,
    );
  }

  void _drawElbow(Canvas canvas, Offset a, Offset b, Color color) {
    final mid = Offset(b.dx, a.dy);
    PipePainterHelpers.drawPipe(canvas, a: a, b: mid, color: color, width: 7);
    PipePainterHelpers.drawPipe(canvas, a: mid, b: b, color: color, width: 7);
    PipePainterHelpers.drawJoint(canvas, mid);
  }

  @override
  bool shouldRepaint(_HeatPumpPainter o) =>
      o.step != step ||
      o.t != t ||
      o.outsideTemp != outsideTemp ||
      o.cop != cop;
}
