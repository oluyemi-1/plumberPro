import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class BoilerCycleSimScreen extends StatefulWidget {
  const BoilerCycleSimScreen({super.key});
  @override
  State<BoilerCycleSimScreen> createState() => _BoilerCycleSimScreenState();
}

class _BoilerCycleSimScreenState extends State<BoilerCycleSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _step = 0;
  bool _demandOn = true;

  static const _condensate = Color(0xFF8FD4E8);

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

  final List<SimStep> _steps = const [
    SimStep(
      title: '1. Call for heat',
      narration:
          'The room thermostat or programmer asks for heat. The boiler PCB wakes up and begins its safety checks before anything else is allowed to move.',
    ),
    SimStep(
      title: '2. Pre-purge',
      narration:
          'The fan runs up to speed with the gas valve shut. This flushes any leftover combustion products out of the chamber and flue so ignition is safe.',
    ),
    SimStep(
      title: '3. Gas valve and spark',
      narration:
          'The solenoid gas valve opens and the spark electrode strikes in the burner. Fuel and air mix and catch light at the jets.',
    ),
    SimStep(
      title: '4. Flame sensed',
      narration:
          'The flame rectification probe detects ionised gas and tells the PCB the burner is alight. If no flame is seen within a few seconds the valve slams shut.',
    ),
    SimStep(
      title: '5. Burner modulates',
      narration:
          'The PCB varies the gas and fan speed to match demand. Modulating keeps the boiler running steadily instead of cycling on and off, which is far more efficient.',
    ),
    SimStep(
      title: '6. Primary heat transfer',
      narration:
          'Hot combustion gases pass over the primary heat exchanger. The system water picks up most of the heat here and leaves as the flow to the heating circuit.',
    ),
    SimStep(
      title: '7. Secondary condensing',
      narration:
          'Cooler return water runs through the secondary section. It drops the flue gas below its dew point, latent heat is released and condensate forms.',
    ),
    SimStep(
      title: '8. Post-purge',
      narration:
          'Once demand is satisfied the gas valve closes but the fan runs on for a few seconds. That clears residual flue gases and cools the heat exchanger.',
    ),
    SimStep(
      title: '9. Standby',
      narration:
          'The boiler rests and watches for the next call. Pumps may overrun briefly to move heat away from the exchanger and protect it from thermal shock.',
    ),
  ];

  // Visibility flags derived from step & demand
  bool get _fanSpinning =>
      _demandOn && (_step >= 1 && _step <= 7);
  bool get _flameOn => _demandOn && (_step >= 2 && _step <= 6);
  bool get _gasValveOpen => _demandOn && (_step >= 2 && _step <= 6);
  bool get _waterFlow => _demandOn && (_step >= 5 && _step <= 7);
  bool get _condensing => _demandOn && (_step == 6 || _step == 7);

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      ElevatedButton.icon(
        onPressed: () => setState(() => _demandOn = true),
        icon: const Icon(Icons.power_settings_new),
        label: const Text('Demand On'),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _demandOn ? AppColors.accent : AppColors.primary,
        ),
      ),
      OutlinedButton.icon(
        onPressed: () => setState(() => _demandOn = false),
        icon: const Icon(Icons.stop_circle_outlined),
        label: const Text('Demand Off'),
      ),
    ];

    return SimScaffold(
      title: 'Condensing boiler combustion cycle',
      summary:
          'A modern sealed system condensing boiler burns gas with a fan-driven premix burner and squeezes every last joule of energy out of the flue gas by condensing water vapour on a stainless secondary exchanger. Follow the nine stages from call for heat to standby.',
      steps: _steps,
      controls: controls,
      onStepChanged: (i) => setState(() => _step = i),
      diagramBuilder: (context, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _BoilerPainter(
              step: stepIndex,
              t: _ctrl.value,
              demandOn: _demandOn,
              fanSpinning: _fanSpinning,
              flameOn: _flameOn,
              gasValveOpen: _gasValveOpen,
              waterFlow: _waterFlow,
              condensing: _condensing,
              condensateColor: _condensate,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _BoilerPainter extends CustomPainter {
  final int step;
  final double t;
  final bool demandOn;
  final bool fanSpinning;
  final bool flameOn;
  final bool gasValveOpen;
  final bool waterFlow;
  final bool condensing;
  final Color condensateColor;
  _BoilerPainter({
    required this.step,
    required this.t,
    required this.demandOn,
    required this.fanSpinning,
    required this.flameOn,
    required this.gasValveOpen,
    required this.waterFlow,
    required this.condensing,
    required this.condensateColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.cardBg;
    canvas.drawRect(Offset.zero & size, bg);

    final w = size.width;
    final h = size.height;

    // Boiler casing
    final casing = Rect.fromLTWH(
      w * 0.18,
      h * 0.08,
      w * 0.58,
      h * 0.82,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(casing, const Radius.circular(12)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(casing, const Radius.circular(12)),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Flue outlet on top
    final flueRect = Rect.fromLTWH(
      casing.center.dx - 18,
      casing.top - 38,
      36,
      42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(flueRect, const Radius.circular(4)),
      Paint()..color = AppColors.pipeMetal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(flueRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(flueRect.right + 6, flueRect.top + 6),
      'Flue outlet',
    );

    // Interior sections --------------------------------------------------
    // Fan (upper left inside)
    final fanCentre = Offset(casing.left + 70, casing.top + 80);
    _drawFan(canvas, fanCentre, fanSpinning);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(fanCentre.dx - 12, fanCentre.dy + 32),
      'Fan',
    );

    // Gas valve + regulator (bottom left inside)
    final gasValveC = Offset(casing.left + 70, casing.bottom - 100);
    _drawGasValve(canvas, gasValveC, gasValveOpen);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gasValveC.dx - 10, gasValveC.dy + 28),
      'Gas valve',
    );

    // Gas inlet + iso valve (bottom outside left)
    final gasInletA = Offset(w * 0.02, casing.bottom - 40);
    final gasInletJoin = Offset(casing.left + 20, casing.bottom - 40);
    PipePainterHelpers.drawPipe(
      canvas,
      a: gasInletA,
      b: gasInletJoin,
      color: AppColors.gas,
      width: 10,
    );
    PipePainterHelpers.drawValve(
      canvas,
      Offset(w * 0.10, casing.bottom - 40),
      open: demandOn,
    );
    // up to the gas valve inside
    PipePainterHelpers.drawPipe(
      canvas,
      a: gasInletJoin,
      b: Offset(gasValveC.dx, casing.bottom - 40),
      color: AppColors.gas,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(gasValveC.dx, casing.bottom - 40),
      b: Offset(gasValveC.dx, gasValveC.dy + 14),
      color: AppColors.gas,
      width: 10,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.02, casing.bottom - 58),
      'Gas inlet',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(w * 0.095, casing.bottom - 62),
      'Iso valve',
    );

    // Burner (horizontal row of jets, middle-left)
    final burnerRect = Rect.fromLTWH(
      casing.left + 40,
      casing.top + 180,
      140,
      16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(burnerRect, const Radius.circular(4)),
      Paint()..color = Colors.black87,
    );
    // Jets
    for (int i = 0; i < 7; i++) {
      final jx = burnerRect.left + 10 + i * 20.0;
      canvas.drawCircle(
        Offset(jx, burnerRect.top - 2),
        2.2,
        Paint()..color = Colors.grey.shade600,
      );
      if (flameOn) {
        _drawSmallFlame(canvas, Offset(jx, burnerRect.top - 2), t + i * 0.1);
      }
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(burnerRect.left, burnerRect.bottom + 6),
      'Burner jets',
    );

    // Spark electrode
    final sparkP = Offset(burnerRect.right + 14, burnerRect.top - 18);
    canvas.drawLine(
      sparkP,
      Offset(sparkP.dx - 6, burnerRect.top - 2),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.6,
    );
    if (step == 2 && demandOn) {
      final flicker = (math.sin(t * math.pi * 20) + 1) / 2;
      final sparkPaint = Paint()
        ..color = Colors.yellowAccent.withValues(alpha: flicker);
      canvas.drawCircle(sparkP, 4 + flicker * 2, sparkPaint);
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(sparkP.dx + 6, sparkP.dy - 10),
      'Spark electrode',
    );

    // Primary heat exchanger (coil above burner)
    final pheRect = Rect.fromLTWH(
      burnerRect.left - 10,
      burnerRect.top - 90,
      burnerRect.width + 20,
      60,
    );
    _drawPrimaryCoil(canvas, pheRect);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pheRect.left, pheRect.top - 16),
      'Primary heat exchanger',
    );

    // Secondary condensing section (above primary)
    final secRect = Rect.fromLTWH(
      pheRect.left - 4,
      pheRect.top - 70,
      pheRect.width + 8,
      50,
    );
    _drawSecondarySection(canvas, secRect);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(secRect.left, secRect.top - 16),
      'Secondary condensing',
    );

    // Combustion products rising into flue
    if (flameOn || step == 1 || step == 7) {
      final particles = 8;
      final laneX = secRect.center.dx;
      for (int i = 0; i < particles; i++) {
        final p = ((t + i / particles) % 1.0);
        final y = burnerRect.top - 20 - p * (burnerRect.top - flueRect.top - 10);
        final alpha = (1 - p) * 0.5;
        canvas.drawCircle(
          Offset(laneX + (math.sin(p * 6) * 4), y),
          3,
          Paint()..color = Colors.grey.withValues(alpha: alpha),
        );
      }
    }

    // Condensate droplets forming on secondary
    if (condensing) {
      for (int i = 0; i < 4; i++) {
        final p = ((t + i / 4) % 1.0);
        final x = secRect.left + 8 + i * (secRect.width / 4);
        final y = secRect.bottom + p * 40;
        canvas.drawCircle(
          Offset(x, y),
          3 - p * 1.5,
          Paint()..color = condensateColor.withValues(alpha: 1 - p),
        );
      }
    }

    // Condensate trap + drain
    final trapTop = Offset(secRect.center.dx + 40, casing.bottom - 50);
    final trapBottom = Offset(trapTop.dx, casing.bottom - 10);
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(secRect.center.dx + 40, secRect.bottom + 10),
      b: trapTop,
      color: condensateColor,
      width: 8,
    );
    // U-bend trap
    final trapPath = Path()
      ..moveTo(trapTop.dx - 10, trapTop.dy)
      ..lineTo(trapTop.dx - 10, trapBottom.dy)
      ..arcToPoint(
        Offset(trapTop.dx + 10, trapBottom.dy),
        radius: const Radius.circular(10),
        clockwise: false,
      )
      ..lineTo(trapTop.dx + 10, trapTop.dy);
    canvas.drawPath(
      trapPath,
      Paint()
        ..color = condensateColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
    // Condensate pipe out to drain
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(trapTop.dx + 10, trapTop.dy),
      b: Offset(casing.right + 40, trapTop.dy),
      color: condensateColor,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(casing.right + 40, trapTop.dy),
      b: Offset(casing.right + 40, trapTop.dy + 80),
      color: condensateColor,
      width: 8,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(trapTop.dx - 14, trapTop.dy - 16),
      'Condensate trap',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(casing.right + 8, trapTop.dy + 80),
      'To drain',
    );

    // Primary water flow and return
    // Flow out (hot) from top-right of exchanger
    final flowA = Offset(pheRect.right - 10, pheRect.top + 10);
    final flowB = Offset(casing.right + 40, pheRect.top + 10);
    final flowC = Offset(casing.right + 40, casing.top - 10);
    PipePainterHelpers.drawPipe(
      canvas,
      a: flowA,
      b: flowB,
      color: AppColors.hotWater,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: flowB,
      b: flowC,
      color: AppColors.hotWater,
      width: 10,
    );
    if (waterFlow) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: flowA,
        b: flowB,
        progress: t,
        color: Colors.white,
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(flowC.dx - 12, flowC.dy - 18),
      'Primary flow',
    );

    // Return (cold) into lower-right of secondary section
    final retA = Offset(casing.right + 58, casing.top - 10);
    final retB = Offset(casing.right + 58, secRect.bottom - 10);
    final retC = Offset(secRect.right - 6, secRect.bottom - 10);
    PipePainterHelpers.drawPipe(
      canvas,
      a: retA,
      b: retB,
      color: AppColors.coldWater,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: retB,
      b: retC,
      color: AppColors.coldWater,
      width: 10,
    );
    if (waterFlow) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: retB,
        b: retA,
        progress: t,
        color: Colors.white,
      );
    }
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(retA.dx - 8, retA.dy - 18),
      'Return',
    );

    // PCB / control board on right inside
    final pcbRect = Rect.fromLTWH(
      casing.right - 70,
      casing.top + 30,
      54,
      80,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pcbRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFF2E6B3B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pcbRect, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // LEDs
    final ledOn = demandOn;
    canvas.drawCircle(
      Offset(pcbRect.left + 10, pcbRect.top + 10),
      3,
      Paint()..color = ledOn ? Colors.greenAccent : Colors.green.shade900,
    );
    canvas.drawCircle(
      Offset(pcbRect.left + 22, pcbRect.top + 10),
      3,
      Paint()..color = flameOn ? Colors.orangeAccent : Colors.orange.shade900,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pcbRect.left - 6, pcbRect.bottom + 6),
      'PCB',
    );

    // Title strip
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(size.width * 0.02, size.height * 0.02),
      'Condensing boiler — section view',
      background: AppColors.primary,
      textColor: Colors.white,
      fontSize: 12,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(size.width * 0.02, size.height * 0.95),
      demandOn ? 'Demand: ON' : 'Demand: OFF',
      background: demandOn ? AppColors.accent : AppColors.muted,
      textColor: Colors.white,
      fontSize: 11,
    );
  }

  void _drawFan(Canvas canvas, Offset c, bool spinning) {
    final ringPaint = Paint()
      ..color = AppColors.pipeMetal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(c, 28, ringPaint);
    canvas.drawCircle(
      c,
      28,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final angle = spinning ? t * math.pi * 6 : 0.0;
    final bladePaint = Paint()..color = Colors.black87;
    for (int i = 0; i < 4; i++) {
      final a = angle + i * math.pi / 2;
      final p1 = c;
      final p2 = Offset(c.dx + math.cos(a) * 22, c.dy + math.sin(a) * 22);
      final p3 = Offset(
        c.dx + math.cos(a + 0.3) * 16,
        c.dy + math.sin(a + 0.3) * 16,
      );
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();
      canvas.drawPath(path, bladePaint);
    }
    canvas.drawCircle(c, 5, Paint()..color = AppColors.accent);
  }

  void _drawGasValve(Canvas canvas, Offset c, bool open) {
    final body = Rect.fromCenter(center: c, width: 50, height: 30);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(4)),
      Paint()..color = AppColors.gas,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(4)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Solenoid coil on top
    final coil = Rect.fromCenter(
      center: Offset(c.dx, c.dy - 22),
      width: 22,
      height: 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(coil, const Radius.circular(3)),
      Paint()..color = open ? AppColors.accent : Colors.grey.shade500,
    );
    // Regulator adjuster
    canvas.drawCircle(
      Offset(c.dx + 18, c.dy),
      4,
      Paint()..color = Colors.black87,
    );
  }

  void _drawPrimaryCoil(Canvas canvas, Rect r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()..color = AppColors.pipeMetal.withValues(alpha: 0.6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Coil loops
    final coilPaint = Paint()
      ..color = waterFlow ? AppColors.hotWater : AppColors.coldWater
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final step = r.width / 6;
    for (int i = 0; i < 6; i++) {
      final x = r.left + i * step + step / 2;
      final topY = r.top + 8;
      final bottomY = r.bottom - 8;
      if (i.isEven) {
        path.moveTo(x - step / 2, topY);
        path.lineTo(x + step / 2, topY);
        path.lineTo(x + step / 2, bottomY);
      } else {
        path.lineTo(x + step / 2, bottomY);
        path.lineTo(x + step / 2, topY);
      }
    }
    canvas.drawPath(path, coilPaint);
  }

  void _drawSecondarySection(Canvas canvas, Rect r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()..color = condensateColor.withValues(alpha: 0.25),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Plates
    final stroke = Paint()
      ..color = AppColors.pipeMetal
      ..strokeWidth = 2;
    final n = (r.width / 10).floor();
    for (int i = 1; i < n; i++) {
      final x = r.left + i * 10.0;
      canvas.drawLine(
        Offset(x, r.top + 4),
        Offset(x, r.bottom - 4),
        stroke,
      );
    }
  }

  void _drawSmallFlame(Canvas canvas, Offset base, double time) {
    final flicker = 1 + math.sin(time * math.pi * 8) * 0.3;
    final h = 18 * flicker;
    final path = Path()
      ..moveTo(base.dx - 4, base.dy)
      ..quadraticBezierTo(base.dx - 6, base.dy - h * 0.6, base.dx, base.dy - h)
      ..quadraticBezierTo(base.dx + 6, base.dy - h * 0.6, base.dx + 4, base.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.gas.withValues(alpha: 0.9),
    );
    final inner = Path()
      ..moveTo(base.dx - 2, base.dy)
      ..quadraticBezierTo(
          base.dx - 3, base.dy - h * 0.5, base.dx, base.dy - h * 0.8)
      ..quadraticBezierTo(base.dx + 3, base.dy - h * 0.5, base.dx + 2, base.dy)
      ..close();
    canvas.drawPath(
      inner,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant _BoilerPainter old) =>
      old.t != t ||
      old.step != step ||
      old.demandOn != demandOn;
}
