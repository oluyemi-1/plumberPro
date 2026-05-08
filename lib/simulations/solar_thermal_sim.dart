import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class SolarThermalSimScreen extends StatefulWidget {
  const SolarThermalSimScreen({super.key});
  @override
  State<SolarThermalSimScreen> createState() => _SolarThermalSimScreenState();
}

class _SolarThermalSimScreenState extends State<SolarThermalSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _sun = 70;
  bool _backup = true;

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
      title: 'System principle',
      narration:
          'Solar thermal pre-heats stored water using the sun, and a boiler tops it up only when needed. On a sunny day a properly sized system can deliver 50 to 70 percent of annual hot water demand.',
    ),
    SimStep(
      title: 'Collector types',
      narration:
          'Flat-plate panels are robust and cheaper, while evacuated tubes suffer less heat loss in cold weather and so perform better in winter. Both raise the primary fluid to between 60 and 95 degrees Celsius in good sun.',
    ),
    SimStep(
      title: 'Solar primary fluid',
      narration:
          'A propylene glycol and water mix circulates through the collector to resist freezing down to about minus 25 degrees. Plain water is never used because of frost and corrosion risk.',
    ),
    SimStep(
      title: 'Differential controller',
      narration:
          'The controller compares collector temperature with cylinder bottom temperature. When the collector is roughly 6 to 8 degrees hotter, it starts the pump; below about 3 degrees difference it stops it.',
    ),
    SimStep(
      title: 'Twin-coil cylinder',
      narration:
          'The bottom coil takes solar heat first, since the lower water is coolest and pulls the most energy from the panel. The upper coil is reserved for the boiler so it only heats the top portion when needed.',
    ),
    SimStep(
      title: 'Stagnation',
      narration:
          'On a hot day with no draw-off, collector temperature can exceed 150 degrees and produce steam. Pressurised systems use an expansion vessel and high-temperature glycol; drain-back systems empty into a reservoir.',
    ),
    SimStep(
      title: 'Backup heating logic',
      narration:
          'The boiler is locked out from heating the lower half of the cylinder so it cannot waste fuel that the sun would supply later. It tops only the upper third to a comfortable 50 to 60 degrees Celsius.',
    ),
    SimStep(
      title: 'Anti-Legionella cycle',
      narration:
          'Once a week the boiler raises the whole cylinder to 60 degrees Celsius and holds for at least an hour. This pasteurises any stratified cooler zones that may have harboured bacteria.',
    ),
    SimStep(
      title: 'Annual service',
      narration:
          'Each year check the glycol pH and freezing point, the system pressure at around 2 bar, and the expansion vessel pre-charge. Replace fluid roughly every 5 years or after any stagnation event.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Solar thermal hot water',
      summary:
          'Watch a flat-plate collector pre-heat a twin-coil cylinder, with a boiler topping up the upper coil. Adjust the sun and toggle the backup to see how the differential controller decides when to run the solar pump.',
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sun: ${_sun.round()}%'),
              Slider(
                value: _sun,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (v) => setState(() => _sun = v),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Boiler backup'),
            Switch.adaptive(
              value: _backup,
              onChanged: (v) => setState(() => _backup = v),
            ),
          ],
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _SolarPainter(
            step: i,
            t: _ctrl.value,
            sun: _sun,
            backup: _backup,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SolarPainter extends CustomPainter {
  final int step;
  final double t;
  final double sun;
  final bool backup;
  static const Color solarFluidColor = Color(0xFFE69500);

  _SolarPainter({
    required this.step,
    required this.t,
    required this.sun,
    required this.backup,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky background gradient
    final sky = Rect.fromLTWH(0, 0, w, h * 0.5);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEFF4F8),
    );
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB7DAF0), Color(0xFFEFF4F8)],
        ).createShader(sky),
    );

    final sunNorm = (sun / 100).clamp(0.0, 1.0);
    final pulse = 0.5 + 0.5 * math.sin(t * 6.2831853);
    final sunIntensity = sunNorm * (0.7 + 0.3 * pulse);

    // ----- Sun -----
    final sunC = Offset(w * 0.78, h * 0.12);
    canvas.drawCircle(
      sunC,
      26 + 6 * pulse * sunNorm,
      Paint()
        ..color = AppColors.gas.withValues(alpha: 0.35 * sunNorm)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawCircle(
      sunC,
      18,
      Paint()..color = AppColors.gas.withValues(alpha: 0.95),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(sunC.dx + 26, sunC.dy - 6),
      'Sun ${sun.round()}%',
    );

    // ----- Collector (angled rectangle) -----
    final collTopL = Offset(w * 0.6, h * 0.18);
    final collTopR = Offset(w * 0.92, h * 0.06);
    final collBotL = Offset(w * 0.62, h * 0.32);
    final collBotR = Offset(w * 0.94, h * 0.2);
    final path = Path()
      ..moveTo(collTopL.dx, collTopL.dy)
      ..lineTo(collTopR.dx, collTopR.dy)
      ..lineTo(collBotR.dx, collBotR.dy)
      ..lineTo(collBotL.dx, collBotL.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF1B1F26),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Absorber lines
    final absorberPaint = Paint()
      ..color = solarFluidColor.withValues(alpha: 0.85)
      ..strokeWidth = 2;
    for (int i = 1; i < 6; i++) {
      final tl = Offset.lerp(collTopL, collTopR, i / 6)!;
      final bl = Offset.lerp(collBotL, collBotR, i / 6)!;
      canvas.drawLine(tl, bl, absorberPaint);
    }
    // Glow for warmth
    if (sunIntensity > 0.05) {
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.gas.withValues(alpha: 0.4 * sunIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(collTopL.dx, collTopL.dy - 18),
      'Flat-plate collector',
    );

    // Sun rays
    if (sunNorm > 0.05) {
      final rayPaint = Paint()
        ..color = AppColors.gas.withValues(alpha: 0.55 * sunNorm)
        ..strokeWidth = 2;
      for (int i = 0; i < 6; i++) {
        final rt = ((t + i / 6) % 1.0);
        final start = Offset.lerp(sunC, collTopL, 0.15 + 0.1 * rt)!;
        final end = Offset.lerp(start, collTopL, 0.7)!;
        canvas.drawLine(start, end, rayPaint);
      }
    }

    // ----- Twin-coil cylinder -----
    final cylRect = Rect.fromLTWH(w * 0.08, h * 0.3, w * 0.18, h * 0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cylRect, const Radius.circular(14)),
      Paint()..color = const Color(0xFFD8DDE3),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cylRect, const Radius.circular(14)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cylRect.left, cylRect.top - 18),
      'Twin-coil cylinder',
    );

    // Stratification: bottom by solar heat, top by boiler
    final bottomHeat = sunNorm * 0.9;
    final topHeat = backup ? 0.85 : 0.3 + bottomHeat * 0.4;
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.hotWater.withValues(alpha: 0.65 * topHeat),
        AppColors.hotWater.withValues(alpha: 0.3 * topHeat),
        AppColors.hotWater.withValues(alpha: 0.4 * bottomHeat),
        AppColors.coldWater.withValues(alpha: 0.4),
      ],
    ).createShader(cylRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cylRect.deflate(4), const Radius.circular(10)),
      Paint()..shader = shader,
    );

    // ----- Coils inside cylinder -----
    _drawCoil(canvas, cylRect, true); // bottom solar coil (orange)
    _drawCoil(canvas, cylRect, false); // top boiler coil (copper/red)

    // Coil entry points on cylinder right side
    final solarCylTop = Offset(cylRect.right - 4, cylRect.bottom - 24);
    final solarCylBot = Offset(cylRect.right - 4, cylRect.bottom - 8);
    final boilerCylTop = Offset(cylRect.right - 4, cylRect.top + 50);
    final boilerCylBot = Offset(cylRect.right - 4, cylRect.top + 80);

    // ----- Solar primary loop -----
    final pumpStation = Offset(w * 0.42, h * 0.5);
    final airSep = Offset(w * 0.42, h * 0.36);
    final expVess = Offset(w * 0.36, h * 0.62);
    final ctrlBox = Offset(w * 0.36, h * 0.5);

    // Collector top connection (flow out hot)
    final collOut = Offset(collTopR.dx - 6, collTopR.dy + 4);
    final collIn = Offset(collBotL.dx + 6, collBotL.dy - 2);

    // Hot leg from collector out, along top, down to bottom coil
    final hotLeg1 = Offset(collOut.dx, h * 0.04);
    final hotLeg2 = Offset(w * 0.48, h * 0.04);
    final hotLeg3 = Offset(w * 0.48, h * 0.4);
    final hotLeg4 = Offset(solarCylTop.dx, h * 0.4);

    // Cold return: from solar coil bottom up to pump station, then up to collector inlet
    PipePainterHelpers.drawPipe(
      canvas,
      a: collOut,
      b: hotLeg1,
      color: solarFluidColor,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: hotLeg1,
      b: hotLeg2,
      color: solarFluidColor,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: hotLeg2,
      b: hotLeg3,
      color: solarFluidColor,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: hotLeg3,
      b: hotLeg4,
      color: solarFluidColor,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: hotLeg4,
      b: solarCylTop,
      color: solarFluidColor,
      width: 8,
    );

    // Cool side (return to collector through pump)
    final retA = solarCylBot;
    final retB = Offset(pumpStation.dx, solarCylBot.dy);
    final retC = pumpStation;
    final retD = airSep;
    final retE = Offset(airSep.dx, h * 0.04 - 4);
    final retF = Offset(collIn.dx, retE.dy);

    PipePainterHelpers.drawPipe(
      canvas,
      a: retA,
      b: retB,
      color: solarFluidColor.withValues(alpha: 0.7),
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: retB,
      b: retC,
      color: solarFluidColor.withValues(alpha: 0.7),
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: retC,
      b: retD,
      color: solarFluidColor.withValues(alpha: 0.7),
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: retD,
      b: retE,
      color: solarFluidColor.withValues(alpha: 0.7),
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: retE,
      b: retF,
      color: solarFluidColor.withValues(alpha: 0.7),
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: retF,
      b: collIn,
      color: solarFluidColor.withValues(alpha: 0.7),
      width: 8,
    );

    // Pump station
    _drawPumpStation(canvas, pumpStation);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pumpStation.dx + 14, pumpStation.dy - 6),
      'Pump station',
    );

    // Air separator
    canvas.drawCircle(
      airSep,
      8,
      Paint()..color = AppColors.brass,
    );
    canvas.drawCircle(
      airSep,
      8,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(airSep.dx + 14, airSep.dy - 6),
      'Air separator',
    );

    // Expansion vessel (small)
    final ev = Rect.fromCenter(center: expVess, width: 20, height: 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(ev, const Radius.circular(6)),
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(ev, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      pumpStation,
      Offset(pumpStation.dx, expVess.dy),
      Paint()
        ..color = solarFluidColor.withValues(alpha: 0.6)
        ..strokeWidth = 5,
    );
    canvas.drawLine(
      Offset(pumpStation.dx, expVess.dy),
      Offset(expVess.dx, expVess.dy),
      Paint()
        ..color = solarFluidColor.withValues(alpha: 0.6)
        ..strokeWidth = 5,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(expVess.dx - 36, expVess.dy + 22),
      'Expansion vessel',
    );

    // Differential controller
    _drawCtrl(canvas, ctrlBox);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(ctrlBox.dx - 30, ctrlBox.dy - 26),
      'Diff. controller',
    );

    // Decide if solar pump runs: sun >= 30 and bottom is cool (bottomHeat<0.85)
    final solarPumpOn = sunNorm >= 0.3 && bottomHeat < 0.85;

    if (solarPumpOn) {
      // Animate solar fluid through hot leg
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: collOut,
        b: hotLeg1,
        progress: t,
        color: Colors.white,
        count: 3,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: hotLeg1,
        b: hotLeg2,
        progress: t,
        color: Colors.white,
        count: 4,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: hotLeg2,
        b: hotLeg3,
        progress: t,
        color: Colors.white,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: hotLeg3,
        b: hotLeg4,
        progress: t,
        color: Colors.white,
        count: 3,
      );
      // Return path
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: retA,
        b: retB,
        progress: t,
        color: Colors.white,
        count: 3,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: retC,
        b: retE,
        progress: t,
        color: Colors.white,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: retE,
        b: collIn,
        progress: t,
        color: Colors.white,
        count: 4,
      );
    }

    // ----- Boiler primary loop -----
    final boilerCenter = Offset(w * 0.92, h * 0.62);
    _drawBoiler(canvas, boilerCenter);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boilerCenter.dx - 18, boilerCenter.dy + 30),
      'Boiler',
    );

    // Boiler flow to upper coil top
    final bFlowA = Offset(boilerCenter.dx, boilerCenter.dy - 24);
    final bFlowB = Offset(boilerCenter.dx, h * 0.38);
    final bFlowC = Offset(boilerCylTop.dx, h * 0.38);
    PipePainterHelpers.drawPipe(
      canvas,
      a: bFlowA,
      b: bFlowB,
      color: AppColors.hotWater,
      width: 7,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: bFlowB,
      b: bFlowC,
      color: AppColors.hotWater,
      width: 7,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: bFlowC,
      b: boilerCylTop,
      color: AppColors.hotWater,
      width: 7,
    );

    // Return from upper coil bottom to boiler
    final bRetA = boilerCylBot;
    final bRetB = Offset(boilerCenter.dx + 14, boilerCylBot.dy);
    final bRetC = Offset(boilerCenter.dx + 14, boilerCenter.dy - 18);
    PipePainterHelpers.drawPipe(
      canvas,
      a: bRetA,
      b: bRetB,
      color: AppColors.coldWater,
      width: 7,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: bRetB,
      b: bRetC,
      color: AppColors.coldWater,
      width: 7,
    );

    // Boiler runs only when backup on AND top sensor below set-point (topHeat<0.85)
    final boilerRunning = backup && topHeat < 0.85;
    if (boilerRunning) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: bFlowA,
        b: bFlowB,
        progress: t,
        color: Colors.white,
        count: 3,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: bFlowB,
        b: bFlowC,
        progress: t,
        color: Colors.white,
        count: 4,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: bRetA,
        b: bRetB,
        progress: t,
        color: Colors.white,
        count: 3,
      );
    }

    // Cold mains in to cylinder bottom
    final coldIn = Offset(w * 0.02, cylRect.bottom - 12);
    final coldElbow = Offset(cylRect.left - 4, cylRect.bottom - 12);
    PipePainterHelpers.drawPipe(
      canvas,
      a: coldIn,
      b: coldElbow,
      color: AppColors.coldWater,
      width: 8,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(coldIn.dx, coldIn.dy + 12),
      'Cold mains',
    );

    // Hot draw-off top
    final hotTop = Offset(cylRect.center.dx, cylRect.top - 4);
    final hotEnd = Offset(cylRect.center.dx, h * 0.18);
    final hotEnd2 = Offset(w * 0.32, h * 0.18);
    PipePainterHelpers.drawPipe(
      canvas,
      a: hotTop,
      b: hotEnd,
      color: AppColors.hotWater,
      width: 9,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: hotEnd,
      b: hotEnd2,
      color: AppColors.hotWater,
      width: 9,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(hotEnd2.dx + 4, hotEnd2.dy - 6),
      'Hot draw-off',
    );

    // Status badges
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 12),
      'Step ${step + 1}',
      background: AppColors.primary.withValues(alpha: 0.15),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 32),
      'Solar pump: ${solarPumpOn ? "ON" : "OFF"}',
      background: solarPumpOn
          ? Colors.green.withValues(alpha: 0.2)
          : Colors.grey.withValues(alpha: 0.2),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(12, 52),
      'Boiler: ${boilerRunning ? "TOPPING UP" : "OFF"}',
      background: boilerRunning
          ? AppColors.hotWater.withValues(alpha: 0.25)
          : Colors.grey.withValues(alpha: 0.2),
    );
  }

  void _drawCoil(Canvas canvas, Rect rect, bool isSolar) {
    final color = isSolar ? solarFluidColor : AppColors.copper;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final cx = rect.center.dx + 6;
    final top = isSolar
        ? rect.top + rect.height * 0.65
        : rect.top + rect.height * 0.18;
    final bottom = isSolar
        ? rect.bottom - 14
        : rect.top + rect.height * 0.45;
    final loops = 4;
    final dy = (bottom - top) / loops;
    for (int i = 0; i < loops; i++) {
      final y = top + i * dy;
      canvas.drawArc(
        Rect.fromLTWH(cx - 16, y, 32, dy),
        0,
        3.14159,
        false,
        paint,
      );
    }
  }

  void _drawPumpStation(Canvas canvas, Offset p) {
    final r = Rect.fromCenter(center: p, width: 36, height: 26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(5)),
      Paint()..color = const Color(0xFF2A4F73),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(5)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(p, 6, Paint()..color = Colors.white);
  }

  void _drawCtrl(Canvas canvas, Offset p) {
    final r = Rect.fromCenter(center: p, width: 38, height: 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()..color = const Color(0xFF233646),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRect(
      Rect.fromCenter(center: p, width: 26, height: 12),
      Paint()..color = AppColors.gas.withValues(alpha: 0.85),
    );
  }

  void _drawBoiler(Canvas canvas, Offset c) {
    final r = Rect.fromCenter(center: c, width: 50, height: 50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(8)),
      Paint()..color = const Color(0xFFE6E9EE),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // burner symbol
    canvas.drawCircle(
      Offset(c.dx, c.dy + 6),
      6,
      Paint()..color = AppColors.accent,
    );
  }

  @override
  bool shouldRepaint(_SolarPainter o) =>
      o.step != step || o.t != t || o.sun != sun || o.backup != backup;
}
