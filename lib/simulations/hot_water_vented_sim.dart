import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class HotWaterVentedSimScreen extends StatefulWidget {
  const HotWaterVentedSimScreen({super.key});

  @override
  State<HotWaterVentedSimScreen> createState() =>
      _HotWaterVentedSimScreenState();
}

class _HotWaterVentedSimScreenState extends State<HotWaterVentedSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _immersion = false;

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
      title: 'Cold feed by gravity',
      narration:
          'In a vented system the hot water cylinder is fed from a cold water storage cistern in the loft. Water flows down to the base of the cylinder by gravity, so the height difference sets the pressure at every tap.',
    ),
    SimStep(
      title: 'Water entering the cylinder',
      narration:
          'Cold water enters at the bottom of the cylinder through the cold feed connection. The cylinder always stays full because as hot water is drawn off the top, cold replaces it from below.',
    ),
    SimStep(
      title: 'Primary coil heats the stored water',
      narration:
          'A coil inside the cylinder carries hot primary water from the boiler. Heat transfers through the coil wall into the stored water — the primary water itself never mixes with the domestic supply.',
    ),
    SimStep(
      title: 'Stratification',
      narration:
          'Hot water is less dense so it rises and sits at the top of the cylinder, while cooler water settles at the bottom. That is why the draw-off is taken from the top dome and the cold feed enters at the base.',
    ),
    SimStep(
      title: 'Draw-off to hot taps',
      narration:
          'Open a hot tap and the weight of the cold feed pushes hot water up from the top of the cylinder and out to the taps. Notice the flow direction — you never draw water directly through the vent pipe.',
    ),
    SimStep(
      title: 'The vent pipe',
      narration:
          'The open vent rises from the top of the cylinder and discharges over the feed cistern. It provides a safe release for any expansion or steam, keeping the cylinder at atmospheric pressure at all times.',
    ),
    SimStep(
      title: 'Immersion heater backup',
      narration:
          'An electric immersion heater near the top of the cylinder lets the user heat water without the boiler — useful in summer or if the boiler fails. It only heats water above its element, which is why it is fitted near the top.',
    ),
    SimStep(
      title: 'Scalding risk and blending',
      narration:
          'Stored water above 60 degrees can scald. Fit a thermostatic mixing valve on baths and basins used by vulnerable people so the outlet is blended down to around 43 degrees before it reaches the tap.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Vented Hot Water Cylinder',
      summary:
          'Understand how a traditional vented hot water cylinder stores, heats and delivers domestic hot water, and why it needs an open vent and a feed cistern.',
      steps: _steps,
      controls: [
        FilterChip(
          label: const Text('Immersion on'),
          selected: _immersion,
          onSelected: (v) => setState(() => _immersion = v),
          selectedColor: AppColors.accent.withValues(alpha: 0.25),
        ),
      ],
      onStepChanged: (_) {},
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _HotVentedPainter(
            step: i,
            t: _ctrl.value,
            immersion: _immersion,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _HotVentedPainter extends CustomPainter {
  final int step;
  final double t;
  final bool immersion;

  _HotVentedPainter({
    required this.step,
    required this.t,
    required this.immersion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFF5F8FC),
    );

    // --- Coordinates ---
    final cisternRect = Rect.fromLTWH(w * 0.04, h * 0.08, w * 0.30, h * 0.16);
    final cylinderRect = Rect.fromLTWH(w * 0.54, h * 0.34, w * 0.20, h * 0.50);

    final coldFeedStart = Offset(cisternRect.left + 8, cisternRect.bottom);
    final coldFeedBend1 = Offset(cisternRect.left + 8, h * 0.92);
    final coldFeedBend2 = Offset(cylinderRect.left + cylinderRect.width * 0.3, h * 0.92);
    final coldInlet =
        Offset(cylinderRect.left + cylinderRect.width * 0.3, cylinderRect.bottom);

    final hotOutTop = Offset(cylinderRect.right - cylinderRect.width * 0.35,
        cylinderRect.top);
    final hotBend = Offset(hotOutTop.dx, h * 0.22);
    final hotMainRight = Offset(w * 0.92, h * 0.22);

    // Vent pipe — rises from near top of cylinder, arcs over cistern.
    final ventStart = Offset(cylinderRect.left + cylinderRect.width * 0.75,
        cylinderRect.top);
    final ventPeak = Offset(ventStart.dx, h * 0.04);
    final ventOver = Offset(cisternRect.center.dx, h * 0.04);
    final ventDischarge =
        Offset(cisternRect.center.dx, cisternRect.top - 4);

    // Boiler connections — primary flow/return from left of screen.
    final boilerFlow = Offset(w * 0.32, h * 0.70);
    final boilerReturn = Offset(w * 0.32, h * 0.78);
    final coilInTop = Offset(cylinderRect.left, h * 0.50);
    final coilInBot = Offset(cylinderRect.left, h * 0.72);

    // Taps.
    final bathTap = Offset(w * 0.88, h * 0.40);
    final basinTap = Offset(w * 0.76, h * 0.24);

    // --- Draw cistern ---
    PipePainterHelpers.drawTank(
      canvas,
      rect: cisternRect,
      level: 0.5,
      label: 'Cold feed & expansion cistern',
    );

    // --- Draw cold feed ---
    final cold = AppColors.coldWater;
    PipePainterHelpers.drawPipe(canvas, a: coldFeedStart, b: coldFeedBend1, color: cold);
    PipePainterHelpers.drawPipe(canvas, a: coldFeedBend1, b: coldFeedBend2, color: cold);
    PipePainterHelpers.drawPipe(canvas, a: coldFeedBend2, b: coldInlet, color: cold);
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: coldFeedStart,
      b: coldFeedBend1,
      progress: t,
      color: Colors.white,
      count: 6,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: coldFeedBend1,
      b: coldFeedBend2,
      progress: t,
      color: Colors.white,
      count: 5,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: coldFeedBend2,
      b: coldInlet,
      progress: -t,
      color: Colors.white,
      count: 4,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(coldFeedBend1.dx + 8, h * 0.85),
      'Cold feed',
    );

    // --- Draw cylinder body with stratified water ---
    _drawCylinder(canvas, cylinderRect);

    // --- Primary coil (dashed rectangle inside cylinder) ---
    final coilRect = Rect.fromLTWH(
      cylinderRect.left + cylinderRect.width * 0.18,
      cylinderRect.top + cylinderRect.height * 0.22,
      cylinderRect.width * 0.64,
      cylinderRect.height * 0.52,
    );
    _drawDashedRect(canvas, coilRect,
        Paint()
          ..color = AppColors.hotWater.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2);
    // Arrows showing circulation inside coil.
    _drawCoilArrows(canvas, coilRect, t);

    // Primary flow & return from boiler side.
    PipePainterHelpers.drawPipe(
      canvas,
      a: boilerFlow,
      b: coilInTop,
      color: AppColors.hotWater,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: coilInBot,
      b: boilerReturn,
      color: AppColors.hotWater.withValues(alpha: 0.7),
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: boilerFlow,
      b: coilInTop,
      progress: t,
      color: Colors.white,
      count: 5,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: coilInBot,
      b: boilerReturn,
      progress: t,
      color: Colors.white,
      count: 5,
    );
    // Boiler block at left-bottom.
    final boilerRect = Rect.fromLTWH(w * 0.16, h * 0.66, w * 0.16, h * 0.16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boilerRect, const Radius.circular(6)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boilerRect, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boilerRect.left + 6, boilerRect.top + 6),
      'Boiler',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cylinderRect.left - 38, h * 0.48),
      'Primary flow',
      background: AppColors.hotWater,
      textColor: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cylinderRect.left - 42, h * 0.74),
      'Primary return',
    );

    // --- Hot draw-off ---
    PipePainterHelpers.drawPipe(canvas, a: hotOutTop, b: hotBend, color: AppColors.hotWater);
    PipePainterHelpers.drawPipe(canvas, a: hotBend, b: hotMainRight, color: AppColors.hotWater);
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: hotOutTop,
      b: hotBend,
      progress: -t,
      color: Colors.white,
      count: 5,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: hotBend,
      b: hotMainRight,
      progress: t,
      color: Colors.white,
      count: 7,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(hotBend.dx + 10, hotBend.dy - 14),
      'Hot draw-off',
      background: AppColors.hotWater,
      textColor: Colors.white,
    );

    // Branches to bath and basin.
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(bathTap.dx, h * 0.22),
      b: bathTap,
      color: AppColors.hotWater,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(basinTap.dx, h * 0.22),
      b: basinTap,
      color: AppColors.hotWater,
    );
    _drawTap(canvas, bathTap, 'Bath hot');
    _drawTap(canvas, basinTap, 'Basin hot');

    // --- Vent pipe ---
    PipePainterHelpers.drawPipe(canvas, a: ventStart, b: ventPeak, color: cold, width: 10);
    PipePainterHelpers.drawPipe(canvas, a: ventPeak, b: ventOver, color: cold, width: 10);
    PipePainterHelpers.drawPipe(canvas, a: ventOver, b: ventDischarge, color: cold, width: 10);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ventPeak.dx - 40, ventPeak.dy - 14),
      'Open vent pipe',
    );

    // --- Immersion heater top-right of cylinder ---
    final immPos = Offset(cylinderRect.right - 14, cylinderRect.top + 18);
    _drawImmersion(canvas, immPos, active: immersion);

    // --- Labels for cold inlet, hot outlet ---
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(coldInlet.dx - 40, coldInlet.dy + 6),
      'Cold inlet',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(hotOutTop.dx - 14, hotOutTop.dy - 20),
      'Hot outlet',
      background: AppColors.hotWater,
      textColor: Colors.white,
    );

    // --- Step highlights ---
    _stepHighlight(canvas, size, cylinderRect, ventPeak, boilerFlow);

    // Stratification legend during step 3.
    if (step == 3) {
      _drawLegend(canvas, cylinderRect);
    }

    // Blending valve overlay step 7.
    if (step == 7) {
      _drawBlendingValve(canvas, Offset(w * 0.83, h * 0.28));
    }
  }

  void _drawCylinder(Canvas canvas, Rect r) {
    final body = Paint()..color = const Color(0xFFD8DCE3);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(12));
    canvas.drawRRect(rr, body);
    // Stratified water inside — top deep red, bottom lighter, transition mid.
    final waterRect = r.deflate(4);
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFE63946),
        const Color(0xFFEF8A7B),
        const Color(0xFFFBD7C6),
        AppColors.coldWater.withValues(alpha: 0.6),
      ],
      stops: const [0.0, 0.35, 0.65, 1.0],
    ).createShader(waterRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(waterRect, const Radius.circular(10)),
      Paint()..shader = shader,
    );
    canvas.drawRRect(rr, stroke);

    // Dome top visual hint.
    final dome = Path()
      ..moveTo(r.left, r.top + 6)
      ..quadraticBezierTo(r.center.dx, r.top - 8, r.right, r.top + 6);
    canvas.drawPath(
      dome,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(r.left, r.top - 18),
      'Hot water cylinder',
    );
  }

  void _drawDashedRect(Canvas canvas, Rect r, Paint p) {
    const dash = 6.0;
    const gap = 4.0;
    double drawDashed(Offset a, Offset b) {
      final dir = b - a;
      final len = dir.distance;
      final n = Offset(dir.dx / len, dir.dy / len);
      double pos = 0;
      while (pos < len) {
        final s = a + n * pos;
        final e = a + n * (pos + dash).clamp(0, len);
        canvas.drawLine(s, e, p);
        pos += dash + gap;
      }
      return len;
    }

    drawDashed(r.topLeft, r.topRight);
    drawDashed(r.topRight, r.bottomRight);
    drawDashed(r.bottomRight, r.bottomLeft);
    drawDashed(r.bottomLeft, r.topLeft);
  }

  void _drawCoilArrows(Canvas canvas, Rect r, double t) {
    final paint = Paint()..color = AppColors.hotWater;
    // Two arrows along left (down) and right (up) inside coil rect.
    final offset = (t * r.height) % r.height;
    final leftArrow = Offset(r.left + 10, r.top + offset);
    final rightArrow = Offset(r.right - 10, r.bottom - offset);
    _drawArrow(canvas, leftArrow, const Offset(0, 1), paint);
    _drawArrow(canvas, rightArrow, const Offset(0, -1), paint);
  }

  void _drawArrow(Canvas canvas, Offset pos, Offset dir, Paint p) {
    final d = dir / dir.distance;
    final perp = Offset(-d.dy, d.dx);
    final tip = pos + d * 6;
    final left = pos - perp * 4;
    final right = pos + perp * 4;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawTap(Canvas canvas, Offset p, String label) {
    final body = Paint()..color = AppColors.brass;
    final rect = Rect.fromCenter(center: p, width: 20, height: 12);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)), body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      p,
      Offset(p.dx + 10, p.dy + 10),
      Paint()
        ..color = AppColors.brass
        ..strokeWidth = 4,
    );
    PipePainterHelpers.drawLabel(canvas, Offset(p.dx + 14, p.dy - 4), label);
  }

  void _drawImmersion(Canvas canvas, Offset p, {required bool active}) {
    final body = Paint()..color = active ? AppColors.accent : AppColors.muted;
    final rect = Rect.fromCenter(center: p, width: 22, height: 14);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)), body);
    // Bolt going into cylinder — small rectangle to left.
    canvas.drawRect(
      Rect.fromLTWH(p.dx - 14, p.dy - 4, 8, 8),
      Paint()..color = AppColors.pipeMetal,
    );
    // Pulse glow when active.
    if (active) {
      canvas.drawCircle(
        p,
        18 + math.sin(t * math.pi * 2) * 3,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(p.dx - 20, p.dy - 20),
      'Immersion',
    );
  }

  void _drawLegend(Canvas canvas, Rect r) {
    final legendX = r.right + 10;
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(legendX, r.top + 4),
      'Hottest',
      background: AppColors.hotWater,
      textColor: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(legendX, r.top + r.height * 0.45),
      'Warm',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(legendX, r.bottom - 18),
      'Coolest',
      background: AppColors.coldWater,
      textColor: Colors.white,
    );
  }

  void _drawBlendingValve(Canvas canvas, Offset p) {
    final rect = Rect.fromCenter(center: p, width: 28, height: 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(p.dx - 10, p.dy - 20),
      'TMV',
    );
  }

  void _stepHighlight(
      Canvas canvas, Size size, Rect cyl, Offset vent, Offset boilerFlow) {
    Paint g(Color c) => Paint()
      ..color = c.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    switch (step) {
      case 0:
        canvas.drawCircle(
            Offset(size.width * 0.2, size.height * 0.16), 50, g(AppColors.coldWater));
        break;
      case 1:
        canvas.drawCircle(
            Offset(cyl.left + cyl.width * 0.3, cyl.bottom), 36, g(AppColors.coldWater));
        break;
      case 2:
        canvas.drawRect(
          Rect.fromLTWH(cyl.left - 10, cyl.top + cyl.height * 0.2,
              cyl.width + 20, cyl.height * 0.55),
          g(AppColors.hotWater),
        );
        break;
      case 4:
        canvas.drawCircle(
            Offset(size.width * 0.88, size.height * 0.28), 50, g(AppColors.hotWater));
        break;
      case 5:
        canvas.drawCircle(vent, 50, g(AppColors.primary));
        break;
      case 6:
        canvas.drawCircle(Offset(cyl.right - 14, cyl.top + 18), 36,
            g(AppColors.accent));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _HotVentedPainter old) => true;
}
