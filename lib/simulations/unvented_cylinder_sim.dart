import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

enum _UvMode { normal, heating, overPressure, overTemperature }

class UnventedCylinderSimScreen extends StatefulWidget {
  const UnventedCylinderSimScreen({super.key});
  @override
  State<UnventedCylinderSimScreen> createState() =>
      _UnventedCylinderSimScreenState();
}

class _UnventedCylinderSimScreenState extends State<UnventedCylinderSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  _UvMode _mode = _UvMode.normal;

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
      title: 'Why an unvented system',
      narration:
          'Unvented cylinders deliver full mains pressure to every outlet, so showers and taps run at the same pressure as the cold supply. There is no header tank in the loft, which saves space and keeps the water cleaner.',
    ),
    SimStep(
      title: 'Pressure reducing valve',
      narration:
          'The PRV sets the working pressure, typically to 3 bar, protecting the cylinder and downstream fittings. It also balances hot and cold pressures at mixer outlets.',
    ),
    SimStep(
      title: 'Single check valve',
      narration:
          'A single check valve stops heated, expanded water from flowing back into the cold mains. This protects the wholesomeness of the public water supply.',
    ),
    SimStep(
      title: 'Expansion vessel',
      narration:
          'As stored water heats from 10 to 60 degrees it expands by about 4 percent. The expansion vessel diaphragm flexes to absorb that volume; pre-charge should match the PRV setting, around 3 bar.',
    ),
    SimStep(
      title: 'Expansion relief valve',
      narration:
          'The expansion relief valve is the first level of over-pressure protection, set to lift around 6 bar. It discharges through the tundish if the expansion vessel fails or its charge is lost.',
    ),
    SimStep(
      title: 'Tundish air gap',
      narration:
          'The tundish provides a visible air break between the safety valves and the drain. It must be vertical, within 500 mm of the valve, and never blocked or hidden behind cladding.',
    ),
    SimStep(
      title: 'Temperature and pressure relief',
      narration:
          'The combined T&P relief valve is the second safety level, lifting at 90 degrees Celsius or 7 bar, whichever happens first. Its discharge also passes through the tundish to a safe termination.',
    ),
    SimStep(
      title: 'Energy cut-out',
      narration:
          'The energy cut-out is the third safety level, isolating the heat source if the control thermostat sticks. It must be manually reset, prompting the engineer to investigate the cause.',
    ),
    SimStep(
      title: 'Discharge pipe routing',
      narration:
          'D1 runs from the relief valves to the tundish, and D2 falls from the tundish to a safe visible termination. D2 must be one size larger than D1 and laid to a continuous fall.',
    ),
    SimStep(
      title: 'Notifiable installation',
      narration:
          'Unvented systems over 15 litres are notifiable under Building Regulations G3. Only a competent person scheme installer may fit them, and a benchmark certificate must be issued.',
    ),
  ];

  Widget _modeButton(String label, _UvMode m) {
    final selected = _mode == m;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _mode = m),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Unvented hot water cylinder',
      summary:
          'Explore the safety devices that protect an unvented hot water cylinder, from the inlet group to the temperature and pressure relief, with realistic pressure and temperature settings.',
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        _modeButton('Normal', _UvMode.normal),
        _modeButton('Heating up', _UvMode.heating),
        _modeButton('Over pressure', _UvMode.overPressure),
        _modeButton('Over temperature', _UvMode.overTemperature),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _UnventedPainter(step: i, t: _ctrl.value, mode: _mode),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _UnventedPainter extends CustomPainter {
  final int step;
  final double t;
  final _UvMode mode;
  _UnventedPainter({required this.step, required this.t, required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEFF4F8),
    );

    // ----- Cylinder body -----
    final cylRect = Rect.fromLTWH(w * 0.55, h * 0.18, w * 0.22, h * 0.6);
    _drawCylinder(canvas, cylRect);

    // Stratification gradient inside cylinder (top hot, bottom cold)
    final heatLevel = switch (mode) {
      _UvMode.normal => 0.35,
      _UvMode.heating => 0.7 + 0.2 * (0.5 + 0.5 * _wave(t)),
      _UvMode.overPressure => 0.7,
      _UvMode.overTemperature => 0.95,
    };

    // ----- Cold mains entry, bottom-left of inlet stack -----
    final stackX = w * 0.18;
    final coldIn = Offset(w * 0.05, h * 0.85);
    final strainerP = Offset(stackX, h * 0.85);
    final prvP = Offset(stackX, h * 0.74);
    final checkP = Offset(stackX, h * 0.62);
    final evBranch = Offset(stackX, h * 0.52);
    final ervP = Offset(stackX, h * 0.42);
    final inletElbow = Offset(stackX, h * 0.3);
    final cylColdIn = Offset(cylRect.left, cylRect.bottom - 18);

    // Draw inlet stack pipes
    PipePainterHelpers.drawPipe(
      canvas,
      a: coldIn,
      b: strainerP,
      color: AppColors.coldWater,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: strainerP,
      b: prvP,
      color: AppColors.coldWater,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: prvP,
      b: checkP,
      color: AppColors.coldWater,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: checkP,
      b: evBranch,
      color: AppColors.coldWater,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: evBranch,
      b: ervP,
      color: AppColors.coldWater,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: ervP,
      b: inletElbow,
      color: AppColors.coldWater,
      width: 10,
    );
    // Run across into cylinder bottom
    PipePainterHelpers.drawPipe(
      canvas,
      a: inletElbow,
      b: Offset(cylRect.left - 6, cylRect.bottom - 18),
      color: AppColors.coldWater,
      width: 10,
    );

    // Active flow on cold inlet
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: coldIn,
      b: strainerP,
      progress: t,
      color: Colors.white,
      count: 4,
      radius: 2.2,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: ervP,
      b: inletElbow,
      progress: t,
      color: Colors.white,
      count: 4,
      radius: 2.2,
    );

    // Draw safety/inlet components on the stack
    // Strainer (small ribbed box)
    _drawBoxComponent(canvas, strainerP, 'Strainer');
    // PRV
    PipePainterHelpers.drawValve(canvas, prvP, open: true);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(prvP.dx - 80, prvP.dy + 14),
      'PRV 3 bar',
    );
    // Single check valve
    _drawCheckValve(canvas, checkP);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(checkP.dx - 110, checkP.dy + 10),
      'Single check valve',
    );

    // Expansion vessel branch
    final evCenter = Offset(evBranch.dx - 40, evBranch.dy + 24);
    PipePainterHelpers.drawPipe(
      canvas,
      a: evBranch,
      b: Offset(evCenter.dx + 10, evBranch.dy),
      color: AppColors.coldWater,
      width: 6,
    );
    _drawExpansionVessel(canvas, evCenter, heatLevel);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(evCenter.dx - 60, evCenter.dy + 38),
      'Expansion vessel (3 bar)',
    );

    // Expansion relief valve
    _drawReliefValve(
      canvas,
      ervP,
      lifting: mode == _UvMode.overPressure,
      label: 'ERV 6 bar',
    );

    // Tundish (collects discharge)
    final tundishTop = Offset(w * 0.08, h * 0.35);
    final tundishBot = Offset(w * 0.08, h * 0.5);
    _drawTundish(canvas, tundishTop, tundishBot);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tundishTop.dx - 30, tundishTop.dy - 22),
      'Tundish (air gap)',
    );

    // ERV discharge pipe to tundish
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(ervP.dx - 20, ervP.dy - 14),
      b: Offset(tundishTop.dx, ervP.dy - 14),
      color: AppColors.waste,
      width: 6,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(tundishTop.dx, ervP.dy - 14),
      b: Offset(tundishTop.dx, tundishTop.dy - 6),
      color: AppColors.waste,
      width: 6,
    );

    // T&P relief valve on cylinder top-side
    final tprP = Offset(cylRect.right + 16, cylRect.top + 26);
    _drawReliefValve(
      canvas,
      tprP,
      lifting: mode == _UvMode.overTemperature,
      label: 'T&P 90C / 7 bar',
    );
    // T&P discharge to tundish (long horizontal then drop)
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(tprP.dx + 10, tprP.dy - 18),
      b: Offset(tprP.dx + 10, h * 0.1),
      color: AppColors.waste,
      width: 6,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(tprP.dx + 10, h * 0.1),
      b: Offset(tundishTop.dx, h * 0.1),
      color: AppColors.waste,
      width: 6,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(tundishTop.dx, h * 0.1),
      b: Offset(tundishTop.dx, tundishTop.dy - 6),
      color: AppColors.waste,
      width: 6,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tprP.dx - 16, tprP.dy - 36),
      'D1',
    );

    // D2 from tundish down to drain
    PipePainterHelpers.drawPipe(
      canvas,
      a: tundishBot,
      b: Offset(tundishBot.dx, h * 0.92),
      color: AppColors.waste,
      width: 8,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tundishBot.dx + 12, h * 0.78),
      'D2 to drain',
    );

    // Droplets on discharge events
    final discharging =
        mode == _UvMode.overPressure || mode == _UvMode.overTemperature;
    if (discharging) {
      _drawDroplets(canvas, tundishTop, tundishBot, t);
      _drawDroplets(
        canvas,
        Offset(tundishBot.dx, tundishBot.dy + 8),
        Offset(tundishBot.dx, h * 0.9),
        t,
      );
    }

    // Hot draw-off from cylinder top to bath/shower
    final hotTop = Offset(cylRect.center.dx, cylRect.top - 6);
    final hotElbow = Offset(cylRect.center.dx, h * 0.06);
    final hotEnd = Offset(w * 0.95, h * 0.06);
    PipePainterHelpers.drawPipe(
      canvas,
      a: hotTop,
      b: hotElbow,
      color: AppColors.hotWater,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: hotElbow,
      b: hotEnd,
      color: AppColors.hotWater,
      width: 10,
    );
    PipePainterHelpers.drawFlowParticles(
      canvas,
      a: hotElbow,
      b: hotEnd,
      progress: t,
      color: Colors.white,
      count: 5,
      radius: 2.4,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(hotEnd.dx - 70, hotEnd.dy + 14),
      'Hot to outlets',
    );

    // Energy cut-out, thermistor, immersion (on cylinder)
    PipePainterHelpers.drawJoint(canvas, cylColdIn);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cylRect.left - 80, cylRect.bottom - 26),
      'Cold inlet',
    );

    final ecoP = Offset(cylRect.right - 12, cylRect.center.dy - 30);
    canvas.drawCircle(ecoP, 7, Paint()..color = AppColors.accent);
    canvas.drawCircle(
      ecoP,
      7,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ecoP.dx + 12, ecoP.dy - 6),
      'Energy cut-out',
    );

    final thP = Offset(cylRect.right - 12, cylRect.center.dy + 10);
    canvas.drawCircle(thP, 5, Paint()..color = AppColors.brass);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(thP.dx + 12, thP.dy - 6),
      'Thermistor',
    );

    // Immersion heater
    final immP = Offset(cylRect.right - 4, cylRect.center.dy + 50);
    canvas.drawRect(
      Rect.fromLTWH(immP.dx, immP.dy - 6, 22, 12),
      Paint()..color = AppColors.copper,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(immP.dx + 24, immP.dy - 6),
      'Immersion heater',
    );

    // Primary coil from boiler
    final boilerP = Offset(w * 0.92, h * 0.55);
    final boilerOut = Offset(cylRect.right + 6, h * 0.55);
    final boilerRet = Offset(cylRect.right + 6, h * 0.7);
    final boilerRetEnd = Offset(w * 0.92, h * 0.7);
    PipePainterHelpers.drawPipe(
      canvas,
      a: boilerP,
      b: boilerOut,
      color: AppColors.hotWater,
      width: 7,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: boilerRet,
      b: boilerRetEnd,
      color: AppColors.coldWater,
      width: 7,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boilerP.dx - 40, boilerP.dy - 18),
      'From boiler',
    );

    // Coil inside cylinder
    _drawCoil(canvas, cylRect, t);

    // Stratification overlay
    _drawStratification(canvas, cylRect, heatLevel);

    // Cylinder label
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cylRect.left, cylRect.top - 18),
      'Unvented cylinder',
    );

    // Mains label
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(coldIn.dx - 4, coldIn.dy + 10),
      'Cold mains',
    );

    // Step highlight box
    _drawStepBadge(canvas, size);
  }

  void _drawStepBadge(Canvas canvas, Size size) {
    final txt = 'Step ${step + 1} active';
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 12),
      txt,
      background: AppColors.primary.withValues(alpha: 0.15),
    );
  }

  double _wave(double v) {
    final x = (v * 2 * 3.1415926);
    return (1 - 2 * (v - v.floorToDouble())).abs() == 0
        ? 0
        : (x.remainder(6.2831853) / 6.2831853);
  }

  void _drawCylinder(Canvas canvas, Rect rect) {
    final body = Paint()..color = const Color(0xFFD8DDE3);
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(14));
    canvas.drawRRect(r, body);
    canvas.drawRRect(r, stroke);
    // Top dome
    final dome = Rect.fromLTWH(rect.left, rect.top - 10, rect.width, 22);
    canvas.drawArc(
      dome,
      3.1415926,
      3.1415926,
      false,
      Paint()
        ..color = const Color(0xFFD8DDE3)
        ..style = PaintingStyle.fill,
    );
    canvas.drawArc(
      dome,
      3.1415926,
      3.1415926,
      false,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _drawStratification(Canvas canvas, Rect rect, double heat) {
    // Vertical gradient: top warm, bottom cool
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.hotWater.withValues(alpha: 0.55 * heat),
        AppColors.hotWater.withValues(alpha: 0.25 * heat),
        AppColors.coldWater.withValues(alpha: 0.35),
      ],
    ).createShader(rect);
    final paint = Paint()..shader = shader;
    final inner = rect.deflate(4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(10)),
      paint,
    );
  }

  void _drawCoil(Canvas canvas, Rect rect, double t) {
    final coilPaint = Paint()
      ..color = AppColors.copper
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final cx = rect.center.dx + 8;
    final top = rect.top + rect.height * 0.35;
    final bottom = rect.bottom - 12;
    final loops = 6;
    final dy = (bottom - top) / loops;
    for (int i = 0; i < loops; i++) {
      final y = top + i * dy;
      canvas.drawArc(
        Rect.fromLTWH(cx - 18, y, 36, dy),
        0,
        3.14159,
        false,
        coilPaint,
      );
    }
  }

  void _drawBoxComponent(Canvas canvas, Offset p, String label) {
    final r = Rect.fromCenter(center: p, width: 22, height: 16);
    canvas.drawRect(r, Paint()..color = AppColors.pipeMetal);
    canvas.drawRect(
      r,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    PipePainterHelpers.drawLabel(canvas, Offset(p.dx + 18, p.dy - 6), label);
  }

  void _drawCheckValve(Canvas canvas, Offset p) {
    final r = Rect.fromCenter(center: p, width: 26, height: 16);
    canvas.drawRect(r, Paint()..color = AppColors.brass);
    canvas.drawRect(
      r,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    final path = Path()
      ..moveTo(p.dx - 6, p.dy - 5)
      ..lineTo(p.dx + 6, p.dy)
      ..lineTo(p.dx - 6, p.dy + 5)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  void _drawExpansionVessel(Canvas canvas, Offset p, double heat) {
    final body = Rect.fromCenter(center: p, width: 32, height: 50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(8)),
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    // Diaphragm flexing
    final flex = 0.5 + 0.4 * heat;
    final diaY = body.top + body.height * (0.7 - 0.2 * flex);
    final waterRect = Rect.fromLTRB(
      body.left + 3,
      diaY,
      body.right - 3,
      body.bottom - 3,
    );
    canvas.drawRect(
      waterRect,
      Paint()..color = AppColors.coldWater.withValues(alpha: 0.7),
    );
    // Air above
    canvas.drawRect(
      Rect.fromLTRB(body.left + 3, body.top + 3, body.right - 3, diaY),
      Paint()..color = const Color(0xFFE6F2F8).withValues(alpha: 0.7),
    );
    canvas.drawLine(
      Offset(body.left + 3, diaY),
      Offset(body.right - 3, diaY),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.5,
    );
  }

  void _drawReliefValve(
    Canvas canvas,
    Offset p, {
    required bool lifting,
    required String label,
  }) {
    final r = Rect.fromCenter(center: p, width: 24, height: 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()..color = lifting ? AppColors.accent : AppColors.brass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    // Spring
    canvas.drawLine(
      Offset(p.dx, p.dy - 10),
      Offset(p.dx, p.dy - 22),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      Offset(p.dx, p.dy - 24),
      3,
      Paint()..color = Colors.black54,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(p.dx + 16, p.dy + 6),
      label,
    );
  }

  void _drawTundish(Canvas canvas, Offset top, Offset bot) {
    // Funnel shape
    final path = Path()
      ..moveTo(top.dx - 14, top.dy - 4)
      ..lineTo(top.dx + 14, top.dy - 4)
      ..lineTo(bot.dx + 4, bot.dy)
      ..lineTo(bot.dx - 4, bot.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFCFD6DC));
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Inlet pipe stub above funnel
    canvas.drawLine(
      Offset(top.dx, top.dy - 18),
      Offset(top.dx, top.dy - 6),
      Paint()
        ..color = AppColors.waste
        ..strokeWidth = 6,
    );
  }

  void _drawDroplets(Canvas canvas, Offset top, Offset bot, double t) {
    final paint = Paint()..color = AppColors.coldWater;
    for (int i = 0; i < 5; i++) {
      final p = ((t + i / 5) % 1.0);
      final pos = Offset.lerp(top, bot, p)!;
      canvas.drawCircle(pos, 2.4, paint);
    }
  }

  @override
  bool shouldRepaint(_UnventedPainter o) =>
      o.step != step || o.t != t || o.mode != mode;
}
