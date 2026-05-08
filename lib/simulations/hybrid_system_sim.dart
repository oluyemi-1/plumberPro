import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/paint_helpers.dart';
import '../widgets/sim_scaffold.dart';

enum HybridStrategy { parallel, alternate, costOptimised }

/// A narrated simulation showing how an air-source heat pump and a gas
/// boiler share heating duty in a hybrid system, switching around a user
/// configurable bivalent point.
class HybridSystemSimScreen extends StatefulWidget {
  const HybridSystemSimScreen({super.key});

  @override
  State<HybridSystemSimScreen> createState() => _HybridSystemSimScreenState();
}

class _HybridSystemSimScreenState extends State<HybridSystemSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  double _outsideTemp = 6;
  double _bivalent = 0;
  HybridStrategy _strategy = HybridStrategy.parallel;
  bool _autoOat = false;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _effectiveOat() {
    if (!_autoOat) return _outsideTemp;
    final s = math.sin(_ctrl.value * 2 * math.pi);
    return 2.5 + s * 8.5; // sweeps -6 .. +11
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Hybrid heat pump + gas boiler',
      summary:
          'Visualise how a hybrid system blends an air-source heat pump with '
          'a gas boiler. Drag the outside temperature and bivalent point to '
          'see which heat source takes the load.',
      onStepChanged: (_) => setState(() {}),
      controls: [
        SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Outside temp: '
                  '${_effectiveOat().toStringAsFixed(1)} °C',
                  style: const TextStyle(fontSize: 12)),
              Slider(
                value: _outsideTemp,
                min: -10,
                max: 15,
                divisions: 50,
                label: '${_outsideTemp.toStringAsFixed(1)} °C',
                onChanged: _autoOat
                    ? null
                    : (v) => setState(() => _outsideTemp = v),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bivalent point: '
                  '${_bivalent.toStringAsFixed(1)} °C',
                  style: const TextStyle(fontSize: 12)),
              Slider(
                value: _bivalent,
                min: -5,
                max: 5,
                divisions: 20,
                label: '${_bivalent.toStringAsFixed(1)} °C',
                onChanged: (v) => setState(() => _bivalent = v),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Bivalent-parallel'),
              selected: _strategy == HybridStrategy.parallel,
              onSelected: (_) =>
                  setState(() => _strategy = HybridStrategy.parallel),
            ),
            ChoiceChip(
              label: const Text('Bivalent-alternate'),
              selected: _strategy == HybridStrategy.alternate,
              onSelected: (_) =>
                  setState(() => _strategy = HybridStrategy.alternate),
            ),
            ChoiceChip(
              label: const Text('Cost-optimised'),
              selected: _strategy == HybridStrategy.costOptimised,
              onSelected: (_) =>
                  setState(() => _strategy = HybridStrategy.costOptimised),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Auto outside temp', style: TextStyle(fontSize: 12)),
            Switch.adaptive(
              value: _autoOat,
              onChanged: (v) => setState(() => _autoOat = v),
            ),
          ],
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _HybridPainter(
            step: i,
            t: _ctrl.value,
            oat: _effectiveOat(),
            bivalent: _bivalent,
            strategy: _strategy,
          ),
          size: Size.infinite,
        ),
      ),
      steps: const [
        SimStep(
          title: 'What a hybrid system is',
          narration:
              'A hybrid system pairs an air-source heat pump with a gas '
              'boiler on a common heating loop. A controller decides which '
              'unit is best placed to meet demand at any moment.',
        ),
        SimStep(
          title: 'Why hybrids exist',
          narration:
              'Hybrids exploit the high efficiency of the heat pump in mild '
              'weather while keeping the boiler as a high-output backstop '
              'during cold snaps. That keeps running costs low without '
              'oversizing the heat pump.',
        ),
        SimStep(
          title: 'The bivalent point',
          narration:
              'The bivalent point is the outside air temperature below which '
              'the boiler is allowed to take over. Above it, the heat pump '
              'has enough capacity to meet the design load on its own.',
        ),
        SimStep(
          title: 'Bivalent-parallel mode',
          narration:
              'In parallel mode the heat pump keeps running below the '
              'bivalent point and the boiler tops up the shortfall. Both '
              'units contribute heat at the same time on cold days.',
        ),
        SimStep(
          title: 'Bivalent-alternate mode',
          narration:
              'In alternate mode only one source runs at any moment. Above '
              'the bivalent point the heat pump owns the load; below it the '
              'boiler takes over and the heat pump is parked.',
        ),
        SimStep(
          title: 'Cost-optimised control',
          narration:
              'A cost-optimised controller swaps sources based on the live '
              'unit price of gas and electricity. If electricity is cheap '
              'overnight, the heat pump runs even on colder days.',
        ),
        SimStep(
          title: 'Hydraulic arrangement',
          narration:
              'The two heat sources tie into the system through a low-loss '
              'header or a sequential return. The arrangement keeps each '
              'unit at its preferred flow rate without short-cycling.',
        ),
        SimStep(
          title: 'Controls',
          narration:
              'A modulating call passes from the controller to each heat '
              'source over OpenTherm or volt-free contacts. Domestic hot '
              'water is often handed solely to the boiler for fast '
              'reheats.',
        ),
        SimStep(
          title: 'Maintenance',
          narration:
              'Service both heat sources annually, clean the magnetic '
              'filter every twelve months and check the heat pump '
              'refrigerant pressures and air flow as part of the routine.',
        ),
      ],
    );
  }
}

class _HybridPainter extends CustomPainter {
  final int step;
  final double t;
  final double oat;
  final double bivalent;
  final HybridStrategy strategy;

  _HybridPainter({
    required this.step,
    required this.t,
    required this.oat,
    required this.bivalent,
    required this.strategy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background sky / wall split
    final wallPaint = Paint()..color = const Color(0xFFEFF3F8);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), wallPaint);
    final outsidePaint = Paint()..color = const Color(0xFFE0ECF7);
    canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.32, h), outsidePaint);
    // Wall line
    final wallStroke = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.32, 0), Offset(w * 0.32, h), wallStroke);

    PipePainterHelpers.drawLabel(canvas, Offset(8, 8), 'OUTSIDE');
    PipePainterHelpers.drawLabel(canvas, Offset(w * 0.34, 8), 'INDOOR');

    // Heat sources
    final hpRect = Rect.fromLTWH(w * 0.05, h * 0.55, w * 0.20, h * 0.18);
    _drawHeatPump(canvas, hpRect);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(hpRect.left, hpRect.top - 18),
      'Air-source heat pump',
    );

    final boilerRect = Rect.fromLTWH(w * 0.36, h * 0.20, w * 0.13, h * 0.20);
    _drawBoiler(canvas, boilerRect);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boilerRect.left, boilerRect.top - 18),
      'Gas boiler',
    );

    // Controller box
    final ctrlRect = Rect.fromLTWH(w * 0.50, h * 0.50, w * 0.14, h * 0.14);
    _drawController(canvas, ctrlRect);

    // Three radiators on the right
    final radW = w * 0.16;
    final radH = h * 0.10;
    final radX = w * 0.78;
    final List<Rect> rads = [
      Rect.fromLTWH(radX, h * 0.18, radW, radH),
      Rect.fromLTWH(radX, h * 0.42, radW, radH),
      Rect.fromLTWH(radX, h * 0.66, radW, radH),
    ];
    final shares = _heatShares();
    final totalWarmth = (shares.hp + shares.boiler).clamp(0.0, 1.0);
    for (final r in rads) {
      PipePainterHelpers.drawRadiator(canvas, rect: r, warmth: totalWarmth);
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(rads[0].left, rads[0].top - 16),
      'Radiators',
    );

    // Common header / LLH
    final headerLeft = Offset(w * 0.66, h * 0.20);
    final headerRight = Offset(w * 0.66, h * 0.80);
    PipePainterHelpers.drawPipe(
      canvas,
      a: headerLeft,
      b: headerRight,
      color: AppColors.pipeMetal,
      width: 18,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(headerLeft.dx - 32, headerLeft.dy - 18),
      'LLH / header',
    );

    // Flow / return colours
    const flowColor = AppColors.hotWater;
    const returnColor = AppColors.coldWater;

    // Boiler flow + return -> header
    final boilerOut = Offset(boilerRect.right, boilerRect.top + 18);
    final boilerIn = Offset(boilerRect.right, boilerRect.bottom - 18);
    final headerTop = Offset(headerLeft.dx, h * 0.28);
    final headerBot = Offset(headerLeft.dx, h * 0.72);
    PipePainterHelpers.drawPipe(
      canvas,
      a: boilerOut,
      b: headerTop,
      color: flowColor,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: boilerIn,
      b: headerBot,
      color: returnColor,
    );

    // HP flow + return -> header (long sweep through wall)
    final hpOut = Offset(hpRect.right, hpRect.top + 18);
    final hpIn = Offset(hpRect.right, hpRect.bottom - 14);
    final hpFlowMid = Offset(w * 0.55, hpOut.dy);
    final hpRetMid = Offset(w * 0.55, hpIn.dy);
    PipePainterHelpers.drawPipe(
      canvas,
      a: hpOut,
      b: hpFlowMid,
      color: flowColor,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: hpFlowMid,
      b: Offset(hpFlowMid.dx, h * 0.30),
      color: flowColor,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(hpFlowMid.dx, h * 0.30),
      b: Offset(headerLeft.dx, h * 0.30),
      color: flowColor,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: hpIn,
      b: hpRetMid,
      color: returnColor,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: hpRetMid,
      b: Offset(hpRetMid.dx, h * 0.74),
      color: returnColor,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(hpRetMid.dx, h * 0.74),
      b: Offset(headerLeft.dx, h * 0.74),
      color: returnColor,
    );

    // Header to radiator manifold flow / return
    for (int i = 0; i < rads.length; i++) {
      final r = rads[i];
      final flowIn = Offset(r.left, r.top + r.height * 0.3);
      final retOut = Offset(r.left, r.top + r.height * 0.7);
      final headerFlowTap = Offset(headerLeft.dx, flowIn.dy);
      final headerRetTap = Offset(headerLeft.dx, retOut.dy);
      PipePainterHelpers.drawPipe(
        canvas,
        a: headerFlowTap,
        b: flowIn,
        color: flowColor,
        width: 10,
      );
      PipePainterHelpers.drawPipe(
        canvas,
        a: headerRetTap,
        b: retOut,
        color: returnColor,
        width: 10,
      );
    }

    // Particle flows
    if (shares.hp > 0.02) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: hpOut,
        b: hpFlowMid,
        progress: t,
        color: AppColors.hotWater,
        count: 6,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(hpFlowMid.dx, h * 0.30),
        b: Offset(headerLeft.dx, h * 0.30),
        progress: t,
        color: AppColors.hotWater,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(headerLeft.dx, h * 0.74),
        b: Offset(hpRetMid.dx, h * 0.74),
        progress: t,
        color: AppColors.coldWater,
        count: 5,
      );
    }
    if (shares.boiler > 0.02) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: boilerOut,
        b: headerTop,
        progress: t,
        color: AppColors.hotWater,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: headerBot,
        b: boilerIn,
        progress: t,
        color: AppColors.coldWater,
        count: 5,
      );
    }

    // Radiator circuit particles
    for (int i = 0; i < rads.length; i++) {
      if (totalWarmth < 0.05) continue;
      final r = rads[i];
      final flowIn = Offset(r.left, r.top + r.height * 0.3);
      final retOut = Offset(r.left, r.top + r.height * 0.7);
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: Offset(headerLeft.dx, flowIn.dy),
        b: flowIn,
        progress: t,
        color: AppColors.hotWater,
        count: 3,
        radius: 2.6,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: retOut,
        b: Offset(headerLeft.dx, retOut.dy),
        progress: t,
        color: AppColors.coldWater,
        count: 3,
        radius: 2.6,
      );
    }

    // Gas supply to boiler
    final gasIn = Offset(boilerRect.left, boilerRect.bottom - 6);
    final gasSrc = Offset(boilerRect.left - w * 0.04, boilerRect.bottom - 6);
    PipePainterHelpers.drawPipe(
      canvas,
      a: gasSrc,
      b: gasIn,
      color: AppColors.gas,
      width: 8,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gasSrc.dx - 6, gasSrc.dy + 6),
      'Gas',
      background: AppColors.gas,
      textColor: Colors.white,
    );

    // Controller status
    String status;
    if (shares.hp > 0.05 && shares.boiler > 0.05) {
      status = 'BOTH';
    } else if (shares.hp > 0.05) {
      status = 'HP';
    } else if (shares.boiler > 0.05) {
      status = 'BOILER';
    } else {
      status = 'IDLE';
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ctrlRect.left + 6, ctrlRect.top + 8),
      'Controller',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ctrlRect.left + 6, ctrlRect.top + 30),
      'Active: $status',
      background: status == 'BOTH'
          ? AppColors.accent
          : status == 'HP'
              ? AppColors.coldWater
              : status == 'BOILER'
                  ? AppColors.hotWater
                  : AppColors.muted,
      textColor: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ctrlRect.left + 6, ctrlRect.top + 52),
      'Strategy: ${_strategyLabel()}',
      fontSize: 10,
    );

    // Bivalent chart top-right of controller
    _drawBivalentChart(
      canvas,
      Rect.fromLTWH(ctrlRect.right + 6, ctrlRect.top - 6,
          w * 0.18, ctrlRect.height + 12),
    );

    // Outside temp readout
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(8, h - 26),
      'OAT: ${oat.toStringAsFixed(1)} °C   '
          'Bivalent: ${bivalent.toStringAsFixed(1)} °C',
      background: const Color(0xFF1B2A36),
      textColor: Colors.white,
    );

    // Step-specific overlay highlight
    _drawStepOverlay(canvas, size, hpRect, boilerRect, ctrlRect);
  }

  void _drawHeatPump(Canvas canvas, Rect rect) {
    final body = Paint()..color = const Color(0xFFCDD7DF);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(r, body);
    canvas.drawRRect(r, stroke);
    // Fan
    final c = Offset(rect.center.dx, rect.center.dy);
    final fanR = math.min(rect.width, rect.height) * 0.32;
    canvas.drawCircle(c, fanR, Paint()..color = Colors.black87);
    final blade = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final ang = t * 2 * math.pi * 4;
    for (int i = 0; i < 3; i++) {
      final a = ang + i * (2 * math.pi / 3);
      canvas.drawLine(
          c, c + Offset(math.cos(a), math.sin(a)) * fanR * 0.9, blade);
    }
    canvas.drawCircle(c, 3, Paint()..color = Colors.white);
  }

  void _drawBoiler(Canvas canvas, Rect rect) {
    final body = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(r, body);
    canvas.drawRRect(r, stroke);
    // Display window
    final disp = Rect.fromLTWH(
      rect.left + 8,
      rect.top + 10,
      rect.width - 16,
      rect.height * 0.20,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(disp, const Radius.circular(4)),
      Paint()..color = const Color(0xFF1B2A36),
    );
    // Flame indicator
    final shares = _heatShares();
    if (shares.boiler > 0.05) {
      final flame = Paint()..color = AppColors.gas;
      final fc = Offset(rect.center.dx, rect.bottom - 14);
      final path = Path()
        ..moveTo(fc.dx, fc.dy - 14)
        ..quadraticBezierTo(fc.dx + 8, fc.dy - 4, fc.dx, fc.dy + 4)
        ..quadraticBezierTo(fc.dx - 8, fc.dy - 4, fc.dx, fc.dy - 14)
        ..close();
      canvas.drawPath(path, flame);
    }
  }

  void _drawController(Canvas canvas, Rect rect) {
    final body = Paint()..color = const Color(0xFF1B2A36);
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(r, body);
    final accent = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(r, accent);
  }

  void _drawBivalentChart(Canvas canvas, Rect rect) {
    final bg = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      bg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      stroke,
    );
    // Axis from -10..15
    double x(double tC) {
      final f = (tC + 10) / 25;
      return rect.left + 4 + f * (rect.width - 8);
    }

    // Bivalent marker line
    final bx = x(bivalent);
    canvas.drawLine(
      Offset(bx, rect.top + 4),
      Offset(bx, rect.bottom - 4),
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2,
    );
    // OAT marker dot
    final ox = x(oat);
    canvas.drawCircle(
      Offset(ox, rect.center.dy),
      4,
      Paint()..color = AppColors.primary,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(rect.left + 4, rect.top - 14),
      'Bivalent point',
      fontSize: 9,
    );
  }

  void _drawStepOverlay(Canvas canvas, Size size, Rect hp, Rect boiler,
      Rect ctrlRect) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    Rect? target;
    switch (step) {
      case 0:
        target = Rect.fromLTRB(0, 0, size.width, size.height);
        break;
      case 1:
      case 4:
        target = hp;
        break;
      case 5:
        target = ctrlRect;
        break;
      case 2:
      case 3:
        target = ctrlRect.inflate(8);
        break;
      case 6:
        target = Rect.fromLTWH(
          size.width * 0.62,
          size.height * 0.18,
          size.width * 0.10,
          size.height * 0.62,
        );
        break;
      case 7:
        target = ctrlRect.inflate(14);
        break;
      case 8:
        target = boiler;
        break;
    }
    if (target != null && step != 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(target, const Radius.circular(10)),
        paint,
      );
    }
  }

  String _strategyLabel() {
    switch (strategy) {
      case HybridStrategy.parallel:
        return 'Parallel';
      case HybridStrategy.alternate:
        return 'Alternate';
      case HybridStrategy.costOptimised:
        return 'Cost-opt.';
    }
  }

  _Shares _heatShares() {
    // demand fraction: 1 at -10, 0 at 17
    final demand = ((17 - oat) / 27).clamp(0.0, 1.0);
    final transition = 1.0; // K window for simultaneous switchover
    final delta = oat - bivalent; // >0 above bivalent
    double hp;
    double boiler;
    switch (strategy) {
      case HybridStrategy.parallel:
        if (delta >= transition) {
          hp = demand;
          boiler = 0;
        } else if (delta <= -transition) {
          // HP runs at capped capacity, boiler tops up
          hp = 0.45 * demand;
          boiler = demand - hp;
        } else {
          // transition zone -> blend
          final f = (delta + transition) / (2 * transition);
          hp = (0.45 + 0.55 * f) * demand;
          boiler = demand - hp;
          if (boiler < 0) boiler = 0;
        }
        break;
      case HybridStrategy.alternate:
        if (delta >= transition) {
          hp = demand;
          boiler = 0;
        } else if (delta <= -transition) {
          hp = 0;
          boiler = demand;
        } else {
          // momentary overlap during switchover
          hp = demand * 0.6;
          boiler = demand * 0.6;
        }
        break;
      case HybridStrategy.costOptimised:
        // Pretend electricity is cheap during half the cycle (using t)
        final cheapElec = math.sin(t * 2 * math.pi) > 0;
        if (cheapElec) {
          // bias to HP even below bivalent
          hp = demand * (delta >= -2 ? 1.0 : 0.6);
          boiler = demand - hp;
          if (boiler < 0) boiler = 0;
        } else {
          // bias to boiler
          if (delta >= 3) {
            hp = demand;
            boiler = 0;
          } else {
            hp = demand * 0.2;
            boiler = demand - hp;
          }
        }
        break;
    }
    return _Shares(hp: hp.clamp(0.0, 1.0), boiler: boiler.clamp(0.0, 1.0));
  }

  @override
  bool shouldRepaint(covariant _HybridPainter old) =>
      old.step != step ||
      old.t != t ||
      old.oat != oat ||
      old.bivalent != bivalent ||
      old.strategy != strategy;
}

class _Shares {
  final double hp;
  final double boiler;
  _Shares({required this.hp, required this.boiler});
}
