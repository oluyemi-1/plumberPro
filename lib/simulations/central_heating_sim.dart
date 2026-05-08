import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class CentralHeatingSimScreen extends StatefulWidget {
  const CentralHeatingSimScreen({super.key});
  @override
  State<CentralHeatingSimScreen> createState() =>
      _CentralHeatingSimScreenState();
}

class _CentralHeatingSimScreenState extends State<CentralHeatingSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _step = 0;
  bool _chDemand = true;
  bool _hwDemand = false;

  static const List<SimStep> _steps = [
    SimStep(
      title: 'System overview',
      narration:
          'This is a sealed S-plan layout. A single boiler serves both the '
          'radiator circuit and the hot water cylinder through two motorised '
          'zone valves that decide which load receives heat.',
    ),
    SimStep(
      title: 'Heating call',
      narration:
          'The programmer is in a heating time window and the room thermostat '
          'has dropped below its setpoint, so it closes its contacts and signals '
          'the CH zone valve to drive open.',
    ),
    SimStep(
      title: 'CH valve opens, boiler interlock',
      narration:
          'Once the CH valve reaches its end-switch, a permit signal is given '
          'to the boiler. Boiler interlock is essential so the burner never '
          'fires against closed valves.',
    ),
    SimStep(
      title: 'Pump and circulation',
      narration:
          'The circulator pump now starts, pushing hot primary water out of the '
          'boiler flow and back through the return. A steady loop forms around '
          'the radiator circuit.',
    ),
    SimStep(
      title: 'Radiators heating',
      narration:
          'Emitters warm from top to bottom. Lockshield valves balance flow so '
          'the first and last radiator receive a similar temperature drop, '
          'typically around eleven degrees across the system.',
    ),
    SimStep(
      title: 'Simultaneous hot water demand',
      narration:
          'The cylinder stat drops, so the HW valve also opens. Both valves now '
          'call together and the boiler modulates to meet the combined load '
          'through the common flow.',
    ),
    SimStep(
      title: 'Valves satisfied',
      narration:
          'Stats are happy, both zone valves close. The boiler performs a short '
          'pump overrun to dissipate residual heat from the heat exchanger '
          'before shutting down cleanly.',
    ),
    SimStep(
      title: 'Expansion and safety',
      narration:
          'Heating water expands as it warms. The expansion vessel absorbs this '
          'change, while the pressure relief valve and tundish provide a visible '
          'discharge route if pressure becomes excessive.',
    ),
    SimStep(
      title: 'Commissioning checks',
      narration:
          'Fill to around one bar cold, bleed all radiators from the lowest '
          'upwards, dose with inhibitor and record the commissioning pressures '
          'and flue gas readings in the benchmark log.',
    ),
  ];

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

  bool get _chActive {
    if (_step >= 6) return false;
    if (_step <= 1) return false;
    if (!_chDemand) return false;
    return true;
  }

  bool get _hwActive {
    if (_step >= 6) return false;
    if (_step == 5) return true;
    if (!_hwDemand) return false;
    return _step >= 2;
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Central heating (S-plan)',
      summary:
          'An animated sealed S-plan system showing how zone valves, pump and '
          'boiler interlock co-operate to serve radiators and a hot water '
          'cylinder from the same appliance.',
      steps: _steps,
      onStepChanged: (i) => setState(() => _step = i),
      controls: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('CH demand'),
          Switch(
            value: _chDemand,
            onChanged: (v) => setState(() => _chDemand = v),
          ),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('HW demand'),
          Switch(
            value: _hwDemand,
            onChanged: (v) => setState(() => _hwDemand = v),
          ),
        ]),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _CentralHeatingPainter(
            step: i,
            t: _ctrl.value,
            chActive: _chActive,
            hwActive: _hwActive,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _CentralHeatingPainter extends CustomPainter {
  final int step;
  final double t;
  final bool chActive;
  final bool hwActive;
  _CentralHeatingPainter({
    required this.step,
    required this.t,
    required this.chActive,
    required this.hwActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF9FBFD);
    canvas.drawRect(Offset.zero & size, bg);

    final w = size.width;
    final h = size.height;

    final boilerRect = Rect.fromLTWH(w * 0.05, h * 0.08, w * 0.18, h * 0.22);
    final pumpCenter = Offset(w * 0.28, h * 0.22);
    final chValveCenter = Offset(w * 0.45, h * 0.22);
    final hwValveCenter = Offset(w * 0.60, h * 0.22);
    final cylinderRect =
        Rect.fromLTWH(w * 0.78, h * 0.10, w * 0.16, h * 0.42);

    final radTop = h * 0.70;
    final radH = h * 0.14;
    final radW = w * 0.14;
    final radGap = w * 0.03;
    final radStartX = w * 0.08;
    final radRects = List.generate(4, (i) {
      return Rect.fromLTWH(
        radStartX + i * (radW + radGap),
        radTop,
        radW,
        radH,
      );
    });

    final boilerFlow = Offset(boilerRect.right, boilerRect.top + h * 0.05);
    final boilerReturn =
        Offset(boilerRect.right, boilerRect.bottom - h * 0.03);

    double warmth = 0.0;
    if (chActive) {
      if (step == 3) warmth = (t * 0.3).clamp(0.0, 0.3);
      if (step == 4) warmth = 0.9;
      if (step == 5) warmth = 1.0;
      if (step == 2) warmth = 0.1;
    }

    final pipeOff =
        chActive || hwActive ? AppColors.hotWater : AppColors.pipeMetal;
    PipePainterHelpers.drawPipe(
      canvas,
      a: boilerFlow,
      b: pumpCenter,
      color: pipeOff,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: pumpCenter,
      b: chValveCenter,
      color: pipeOff,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: chValveCenter,
      b: hwValveCenter,
      color: hwActive ? AppColors.hotWater : AppColors.pipeMetal,
      width: 10,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: hwValveCenter,
      b: Offset(cylinderRect.left, hwValveCenter.dy),
      color: hwActive ? AppColors.hotWater : AppColors.pipeMetal,
      width: 10,
    );

    final manifoldY = radTop - 20;
    final chDrop = Offset(chValveCenter.dx, manifoldY);
    PipePainterHelpers.drawPipe(
      canvas,
      a: chValveCenter,
      b: chDrop,
      color: chActive ? AppColors.hotWater : AppColors.pipeMetal,
      width: 10,
    );
    final manifoldLeft = Offset(radRects.first.left + 20, manifoldY);
    final manifoldRight = Offset(radRects.last.right - 20, manifoldY);
    PipePainterHelpers.drawPipe(
      canvas,
      a: manifoldLeft,
      b: chDrop,
      color: chActive ? AppColors.hotWater : AppColors.pipeMetal,
      width: 9,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: chDrop,
      b: manifoldRight,
      color: chActive ? AppColors.hotWater : AppColors.pipeMetal,
      width: 9,
    );

    for (final r in radRects) {
      final flowIn = Offset(r.left + 10, r.top);
      final returnOut = Offset(r.right - 10, r.top);
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(flowIn.dx, manifoldY),
        b: flowIn,
        color: chActive ? AppColors.hotWater : AppColors.pipeMetal,
        width: 7,
      );
      PipePainterHelpers.drawPipe(
        canvas,
        a: Offset(returnOut.dx, manifoldY + 18),
        b: returnOut,
        color: chActive ? AppColors.coldWater : AppColors.pipeMetal,
        width: 7,
      );
    }

    final retY = manifoldY + 18;
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(radRects.first.left + 10, retY),
      b: Offset(radRects.last.right - 10, retY),
      color: chActive ? AppColors.coldWater : AppColors.pipeMetal,
      width: 8,
    );
    final retRiser = Offset(w * 0.04, retY);
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(radRects.first.left + 10, retY),
      b: retRiser,
      color: chActive ? AppColors.coldWater : AppColors.pipeMetal,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: retRiser,
      b: Offset(retRiser.dx, boilerReturn.dy),
      color: chActive ? AppColors.coldWater : AppColors.pipeMetal,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(retRiser.dx, boilerReturn.dy),
      b: boilerReturn,
      color: chActive ? AppColors.coldWater : AppColors.pipeMetal,
      width: 8,
    );

    final coilIn = Offset(cylinderRect.left, cylinderRect.top + h * 0.10);
    final coilOut = Offset(cylinderRect.left, cylinderRect.top + h * 0.30);
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(cylinderRect.left - 8, hwValveCenter.dy),
      b: coilIn,
      color: hwActive ? AppColors.hotWater : AppColors.pipeMetal,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: coilOut,
      b: Offset(coilOut.dx - 20, coilOut.dy),
      color: hwActive ? AppColors.coldWater : AppColors.pipeMetal,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(coilOut.dx - 20, coilOut.dy),
      b: Offset(coilOut.dx - 20, retY - 30),
      color: hwActive ? AppColors.coldWater : AppColors.pipeMetal,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(coilOut.dx - 20, retY - 30),
      b: Offset(radRects.last.right, retY - 30),
      color: hwActive ? AppColors.coldWater : AppColors.pipeMetal,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(radRects.last.right, retY - 30),
      b: Offset(radRects.last.right, retY),
      color: hwActive ? AppColors.coldWater : AppColors.pipeMetal,
      width: 8,
    );

    final boilerPaint = Paint()..color = const Color(0xFFE8EEF4);
    final boilerStroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(boilerRect, const Radius.circular(8)),
      boilerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boilerRect, const Radius.circular(8)),
      boilerStroke,
    );
    final burnerOn = chActive || hwActive;
    final burnerRect = Rect.fromLTWH(
      boilerRect.left + 10,
      boilerRect.bottom - 20,
      boilerRect.width - 20,
      10,
    );
    canvas.drawRect(
      burnerRect,
      Paint()..color = burnerOn ? AppColors.gas : Colors.grey.shade400,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boilerRect.left + 8, boilerRect.top + 8),
      'Boiler',
    );
    canvas.drawRect(
      Rect.fromLTWH(boilerRect.left + 20, boilerRect.top - 16, 18, 16),
      Paint()..color = Colors.black54,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(boilerRect.left + 18, boilerRect.top - 34),
      'Flue',
    );

    _drawPump(canvas, pumpCenter, running: chActive || hwActive);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pumpCenter.dx - 12, pumpCenter.dy + 18),
      'Pump',
    );

    PipePainterHelpers.drawValve(canvas, chValveCenter, open: chActive);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(chValveCenter.dx - 12, chValveCenter.dy - 44),
      'CH valve',
    );
    PipePainterHelpers.drawValve(canvas, hwValveCenter, open: hwActive);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(hwValveCenter.dx - 12, hwValveCenter.dy - 44),
      'HW valve',
    );

    final cylPaint = Paint()..color = const Color(0xFFE8EEF4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cylinderRect, const Radius.circular(12)),
      cylPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cylinderRect, const Radius.circular(12)),
      boilerStroke,
    );
    final innerWater = cylinderRect.deflate(6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerWater, const Radius.circular(10)),
      Paint()
        ..color = (hwActive ? AppColors.hotWater : AppColors.coldWater)
            .withValues(alpha: 0.35),
    );
    final coilPaint = Paint()
      ..color = AppColors.copper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final coilPath = Path();
    double cy = coilIn.dy;
    coilPath.moveTo(coilIn.dx + 6, cy);
    while (cy < coilOut.dy) {
      coilPath.lineTo(cylinderRect.right - 6, cy + 8);
      cy += 16;
      coilPath.lineTo(coilIn.dx + 6, cy);
    }
    canvas.drawPath(coilPath, coilPaint);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cylinderRect.left, cylinderRect.top - 18),
      'HW cylinder',
    );
    canvas.drawCircle(
      Offset(cylinderRect.right - 4,
          cylinderRect.top + cylinderRect.height * 0.55),
      6,
      Paint()..color = AppColors.brass,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(cylinderRect.right + 6,
          cylinderRect.top + cylinderRect.height * 0.55 - 6),
      'Cyl stat',
      fontSize: 9,
    );

    for (int i = 0; i < radRects.length; i++) {
      PipePainterHelpers.drawRadiator(
          canvas, rect: radRects[i], warmth: warmth);
      PipePainterHelpers.drawJoint(
        canvas,
        Offset(radRects[i].right - 10, radRects[i].top),
        color: AppColors.brass,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(radRects[i].left, radRects[i].bottom + 4),
        'Rad ${i + 1}',
        fontSize: 9,
      );
    }

    final roomStatP = Offset(radRects.first.left, radRects.first.top - 60);
    _drawThermostat(canvas, roomStatP, on: chActive);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(roomStatP.dx - 14, roomStatP.dy + 20),
      'Room stat',
      fontSize: 9,
    );

    final expX = boilerRect.left + 4;
    final expY = boilerRect.bottom + 18;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(expX, expY, 28, 38), const Radius.circular(6)),
      Paint()..color = const Color(0xFFCED6DF),
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(expX, expY + 42),
      'Exp vessel',
      fontSize: 9,
    );
    final gaugeC = Offset(expX + 60, expY + 10);
    canvas.drawCircle(gaugeC, 10, Paint()..color = Colors.white);
    canvas.drawCircle(
      gaugeC,
      10,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final needleAngle = (chActive || hwActive) ? -0.4 : -1.1;
    canvas.drawLine(
      gaugeC,
      Offset(gaugeC.dx + 8 * math.cos(needleAngle),
          gaugeC.dy + 8 * math.sin(needleAngle)),
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 1.8,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gaugeC.dx - 16, gaugeC.dy + 14),
      'Gauge',
      fontSize: 9,
    );
    final flA = Offset(expX + 90, expY + 14);
    final flB = Offset(expX + 130, expY + 14);
    PipePainterHelpers.drawPipe(
      canvas,
      a: flA,
      b: flB,
      color: AppColors.coldWater,
      width: 6,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(flA.dx, flA.dy + 10),
      'Fill loop',
      fontSize: 9,
    );

    final aavP = Offset(w * 0.50, h * 0.06);
    PipePainterHelpers.drawPipe(
      canvas,
      a: aavP,
      b: Offset(aavP.dx, hwValveCenter.dy - 20),
      color: AppColors.pipeMetal,
      width: 6,
    );
    canvas.drawCircle(aavP, 6, Paint()..color = AppColors.brass);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(aavP.dx - 10, aavP.dy - 16),
      'AAV',
      fontSize: 9,
    );

    final prvP = Offset(boilerRect.right + 14, boilerRect.bottom - 6);
    canvas.drawCircle(prvP, 6, Paint()..color = AppColors.accent);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(prvP.dx - 6, prvP.dy + 10),
      'PRV',
      fontSize: 9,
    );
    final tundishRect = Rect.fromLTWH(prvP.dx - 6, prvP.dy + 26, 14, 10);
    canvas.drawPath(
      Path()
        ..moveTo(tundishRect.left, tundishRect.top)
        ..lineTo(tundishRect.right, tundishRect.top)
        ..lineTo(tundishRect.center.dx + 2, tundishRect.bottom)
        ..lineTo(tundishRect.center.dx - 2, tundishRect.bottom)
        ..close(),
      Paint()..color = Colors.white,
    );
    canvas.drawPath(
      Path()
        ..moveTo(tundishRect.left, tundishRect.top)
        ..lineTo(tundishRect.right, tundishRect.top)
        ..lineTo(tundishRect.center.dx + 2, tundishRect.bottom)
        ..lineTo(tundishRect.center.dx - 2, tundishRect.bottom)
        ..close(),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    if (chActive || hwActive) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: boilerFlow,
        b: pumpCenter,
        progress: t,
        color: Colors.white,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: pumpCenter,
        b: chValveCenter,
        progress: t,
        color: Colors.white,
        count: 5,
      );
    }
    if (chActive) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: chValveCenter,
        b: chDrop,
        progress: t,
        color: Colors.white,
        count: 3,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: chDrop,
        b: manifoldRight,
        progress: t,
        color: Colors.white,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: manifoldLeft,
        b: chDrop,
        progress: 1 - t,
        color: Colors.white,
        count: 4,
      );
    }
    if (hwActive) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: chValveCenter,
        b: hwValveCenter,
        progress: t,
        color: Colors.white,
        count: 4,
      );
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: hwValveCenter,
        b: Offset(cylinderRect.left, hwValveCenter.dy),
        progress: t,
        color: Colors.white,
        count: 4,
      );
    }
  }

  void _drawPump(Canvas canvas, Offset c, {required bool running}) {
    canvas.drawCircle(c, 14, Paint()..color = AppColors.primary);
    canvas.drawCircle(
      c,
      14,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    final ang = running ? t * 6.28 : 0.0;
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final a = ang + i * 1.57;
      canvas.drawLine(
        c,
        Offset(c.dx + 10 * math.cos(a), c.dy + 10 * math.sin(a)),
        p,
      );
    }
  }

  void _drawThermostat(Canvas canvas, Offset c, {required bool on}) {
    final rect = Rect.fromCenter(center: c, width: 26, height: 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      c,
      4,
      Paint()..color = on ? AppColors.hotWater : Colors.grey.shade400,
    );
  }

  @override
  bool shouldRepaint(_CentralHeatingPainter o) =>
      o.step != step ||
      o.t != t ||
      o.chActive != chActive ||
      o.hwActive != hwActive;
}
