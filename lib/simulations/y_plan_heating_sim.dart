import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class YPlanHeatingSimScreen extends StatefulWidget {
  const YPlanHeatingSimScreen({super.key});
  @override
  State<YPlanHeatingSimScreen> createState() => _YPlanHeatingSimScreenState();
}

class _YPlanHeatingSimScreenState extends State<YPlanHeatingSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _heatDemand = true;
  bool _hwDemand = false;

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

  void _applyStepDefaults(int s) {
    switch (s) {
      case 2:
        _heatDemand = true;
        _hwDemand = false;
        break;
      case 1:
      case 3:
        _heatDemand = false;
        _hwDemand = true;
        break;
      case 4:
        _heatDemand = true;
        _hwDemand = true;
        break;
      case 6:
        _heatDemand = false;
        _hwDemand = false;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = const [
      SimStep(
        title: 'Y-plan overview',
        narration:
            'A Y-plan system uses a single three-port mid-position valve to route hot water from the boiler to either the heating circuit, the cylinder coil, or both. It does the work of two zone valves with one motorised body.',
      ),
      SimStep(
        title: 'Default rest position',
        narration:
            'When the motor is de-energised, an internal spring returns the valve to port B which feeds the cylinder. This is why hot water is the natural priority when the system has no demand.',
      ),
      SimStep(
        title: 'Heating only',
        narration:
            'When only the room thermostat calls, the white wire energises the motor fully and the valve drives over to port A. Flow is sent to the radiators and the cylinder coil is isolated.',
      ),
      SimStep(
        title: 'Hot water only',
        narration:
            'With only the cylinder thermostat calling, the motor stays de-energised and the spring rests the valve on port B. Hot primary feeds the cylinder coil while the heating circuit is shut off.',
      ),
      SimStep(
        title: 'Both demands',
        narration:
            'When both stats call, the motor receives a reduced voltage that holds the valve in the central mid-position. Both the heating circuit and the hot water coil receive flow simultaneously.',
      ),
      SimStep(
        title: 'Wiring colours',
        narration:
            'The valve has five wires: blue neutral, green-yellow earth, orange to the boiler and pump SP terminal, and white and grey for the motor. The grey is the limit switch return that confirms the valve has driven over.',
      ),
      SimStep(
        title: 'Boiler interlock',
        narration:
            'The boiler and pump must only run when at least one stat is calling. The interlock prevents short-cycling and is achieved through the orange wire from the valve combined with the cylinder stat satisfied contact.',
      ),
      SimStep(
        title: 'Common faults',
        narration:
            'Typical failures include a sticky synchronous motor, a seized paddle inside the valve body, and the valve failing to reach the mid-position because the motor is weak. Replacement of the powerhead is usually the fix.',
      ),
      SimStep(
        title: 'Pros and cons',
        narration:
            'Y-plan uses fewer valves and slightly less pipework than S-plan, but fault-finding is harder because one component handles both circuits. A failed Y-plan body removes both heating and hot water at once.',
      ),
    ];

    return SimScaffold(
      title: 'Y-Plan heating system',
      summary:
          'Animated walk-through of a Y-plan central heating system using a single three-port mid-position valve. Toggle the demands to see how the valve and flow respond.',
      autoPlay: false,
      onStepChanged: (i) => setState(() {
        _applyStepDefaults(i);
      }),
      controls: [
        _DemandSwitch(
          label: 'Heating demand',
          value: _heatDemand,
          onChanged: (v) => setState(() => _heatDemand = v),
        ),
        _DemandSwitch(
          label: 'Hot water demand',
          value: _hwDemand,
          onChanged: (v) => setState(() => _hwDemand = v),
        ),
      ],
      steps: steps,
      diagramBuilder: (ctx, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _YPlanPainter(
              step: stepIndex,
              t: _ctrl.value,
              heatDemand: _heatDemand,
              hwDemand: _hwDemand,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _DemandSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _DemandSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _YPlanPainter extends CustomPainter {
  final int step;
  final double t;
  final bool heatDemand;
  final bool hwDemand;
  _YPlanPainter({
    required this.step,
    required this.t,
    required this.heatDemand,
    required this.hwDemand,
  });

  @override
  void paint(Canvas c, Size s) {
    // Background
    final bg = Paint()..color = AppColors.cardBg;
    c.drawRect(Offset.zero & s, bg);

    // House outline
    final house = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final houseStroke = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final houseRect = Rect.fromLTWH(
      s.width * 0.04,
      s.height * 0.05,
      s.width * 0.92,
      s.height * 0.9,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(houseRect, const Radius.circular(10)),
      house,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(houseRect, const Radius.circular(10)),
      houseStroke,
    );

    // Boiler
    final boilerRect = Rect.fromLTWH(
      s.width * 0.10,
      s.height * 0.08,
      s.width * 0.16,
      s.height * 0.18,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(boilerRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFE9EEF5),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(boilerRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Burner glow when firing (any demand)
    final firing = heatDemand || hwDemand;
    if (firing) {
      final glow = Paint()
        ..color = AppColors.gas.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      c.drawCircle(boilerRect.center, 12, glow);
    }
    PipePainterHelpers.drawLabel(
      c,
      Offset(boilerRect.left + 4, boilerRect.top + 4),
      'Boiler',
    );

    // 3-port valve centre
    final valveCentre = Offset(boilerRect.center.dx, s.height * 0.40);
    // Boiler flow (down) to valve AB
    final boilerOut = Offset(boilerRect.center.dx, boilerRect.bottom);
    PipePainterHelpers.drawPipe(
      c,
      a: boilerOut,
      b: valveCentre,
      color: AppColors.hotWater,
      width: 10,
    );

    // Determine valve angle: A only = -45deg, B only = +45deg, mid = 0
    double angle;
    if (heatDemand && hwDemand) {
      angle = 0;
    } else if (heatDemand) {
      angle = -math.pi / 4;
    } else if (hwDemand) {
      angle = math.pi / 4;
    } else {
      angle = math.pi / 4; // rest position default to B
    }

    // Valve body
    _drawThreePortValve(c, valveCentre, angle);

    // Port A (heating) goes right
    final portA = Offset(valveCentre.dx + 36, valveCentre.dy);
    // Port B (hot water) goes left
    final portB = Offset(valveCentre.dx - 36, valveCentre.dy);

    PipePainterHelpers.drawLabel(
      c,
      Offset(valveCentre.dx + 40, valveCentre.dy - 30),
      'A heating',
      fontSize: 10,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(valveCentre.dx - 80, valveCentre.dy - 30),
      'B hot water',
      fontSize: 10,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(valveCentre.dx - 16, valveCentre.dy + 22),
      'AB common',
      fontSize: 10,
    );

    // ---- Heating circuit (right) ----
    // Flow path: portA -> right -> down -> across radiators
    final hFlowTop = Offset(s.width * 0.92, valveCentre.dy);
    final hFlowDown = Offset(s.width * 0.92, s.height * 0.62);
    PipePainterHelpers.drawPipe(
      c,
      a: portA,
      b: hFlowTop,
      color: AppColors.hotWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: hFlowTop,
      b: hFlowDown,
      color: AppColors.hotWater,
      width: 8,
    );
    // Three radiators along the bottom right
    final radY = s.height * 0.66;
    final radSize = Size(s.width * 0.12, s.height * 0.10);
    final radPositions = <Rect>[
      Rect.fromLTWH(s.width * 0.74, radY, radSize.width, radSize.height),
      Rect.fromLTWH(s.width * 0.55, radY, radSize.width, radSize.height),
      Rect.fromLTWH(s.width * 0.36, radY, radSize.width, radSize.height),
    ];
    final heatActive = heatDemand;
    final heatWarmth = heatActive ? (0.4 + 0.6 * (math.sin(t * math.pi * 2) * 0.2 + 0.8)).clamp(0.0, 1.0) : 0.0;
    for (final r in radPositions) {
      PipePainterHelpers.drawRadiator(c, rect: r, warmth: heatWarmth);
    }

    // Connect flow across the tops of radiators
    final flowEntry = Offset(radPositions.first.right, radPositions.first.top + 6);
    PipePainterHelpers.drawPipe(
      c,
      a: hFlowDown,
      b: Offset(hFlowDown.dx, flowEntry.dy),
      color: AppColors.hotWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(hFlowDown.dx, flowEntry.dy),
      b: flowEntry,
      color: AppColors.hotWater,
      width: 8,
    );
    // Return below radiators
    final returnY = radPositions.first.bottom + 14;
    final retStart = Offset(radPositions.last.left, returnY);
    final retCorner = Offset(s.width * 0.30, returnY);
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(radPositions.last.left, radPositions.last.bottom),
      b: retStart,
      color: AppColors.coldWater,
      width: 7,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: retStart,
      b: retCorner,
      color: AppColors.coldWater,
      width: 7,
    );

    // Radiator drops
    for (int i = 0; i < radPositions.length; i++) {
      final r = radPositions[i];
      // flow drop into top
      PipePainterHelpers.drawPipe(
        c,
        a: Offset(r.right, r.top + 6),
        b: Offset(r.left, r.top + 6),
        color: AppColors.hotWater,
        width: 5,
      );
      PipePainterHelpers.drawPipe(
        c,
        a: Offset(r.left, r.bottom),
        b: Offset(r.right, r.bottom),
        color: AppColors.coldWater,
        width: 5,
      );
    }

    // ---- Hot water circuit (left) ----
    final cylRect = Rect.fromLTWH(
      s.width * 0.10,
      s.height * 0.50,
      s.width * 0.14,
      s.height * 0.30,
    );
    _drawCylinder(c, cylRect, hwDemand);
    final cylInTop = Offset(cylRect.center.dx, cylRect.top);
    PipePainterHelpers.drawPipe(
      c,
      a: portB,
      b: Offset(portB.dx, cylInTop.dy - 30),
      color: AppColors.hotWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(portB.dx, cylInTop.dy - 30),
      b: Offset(cylInTop.dx, cylInTop.dy - 30),
      color: AppColors.hotWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(cylInTop.dx, cylInTop.dy - 30),
      b: cylInTop,
      color: AppColors.hotWater,
      width: 8,
    );

    // Cylinder coil return
    final coilOut = Offset(cylRect.right, cylRect.center.dy);
    PipePainterHelpers.drawPipe(
      c,
      a: coilOut,
      b: Offset(retCorner.dx, coilOut.dy),
      color: AppColors.coldWater,
      width: 7,
    );

    // Common return riser to AB and pump
    final pumpPos = Offset(retCorner.dx, s.height * 0.35);
    final abReturn = Offset(valveCentre.dx, valveCentre.dy + 28);
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(retCorner.dx, returnY),
      b: pumpPos,
      color: AppColors.coldWater,
      width: 7,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: pumpPos,
      b: abReturn,
      color: AppColors.coldWater,
      width: 7,
    );
    _drawPump(c, pumpPos, t);
    PipePainterHelpers.drawLabel(
      c,
      Offset(pumpPos.dx + 14, pumpPos.dy - 8),
      'Pump',
      fontSize: 10,
    );

    // Boiler return (back to boiler bottom-left)
    final boilerRet = Offset(boilerRect.left + 16, boilerRect.bottom);
    PipePainterHelpers.drawPipe(
      c,
      a: abReturn,
      b: Offset(abReturn.dx, abReturn.dy + 10),
      color: AppColors.coldWater,
      width: 7,
    );
    // small bend up to boiler return on left of boiler
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(boilerRet.dx, abReturn.dy + 30),
      b: Offset(abReturn.dx, abReturn.dy + 30),
      color: AppColors.coldWater,
      width: 7,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(boilerRet.dx, abReturn.dy + 30),
      b: boilerRet,
      color: AppColors.coldWater,
      width: 7,
    );

    // Joints
    PipePainterHelpers.drawJoint(c, boilerOut);
    PipePainterHelpers.drawJoint(c, retCorner);
    PipePainterHelpers.drawJoint(c, hFlowTop);
    PipePainterHelpers.drawJoint(c, hFlowDown);

    // Expansion vessel + pressure gauge + AAV
    final ev = Offset(boilerRect.right + 14, boilerRect.top + 20);
    _drawExpansionVessel(c, ev);
    PipePainterHelpers.drawLabel(
      c,
      Offset(ev.dx - 10, ev.dy + 26),
      'Exp vessel',
      fontSize: 9,
    );
    final gauge = Offset(boilerRect.right + 36, boilerRect.top + 50);
    _drawGauge(c, gauge, firing ? 1.4 : 1.0);
    PipePainterHelpers.drawLabel(
      c,
      Offset(gauge.dx - 16, gauge.dy + 18),
      'Gauge',
      fontSize: 9,
    );
    final aav = Offset(s.width * 0.92, s.height * 0.10);
    _drawAAV(c, aav);
    PipePainterHelpers.drawLabel(
      c,
      Offset(aav.dx - 12, aav.dy + 16),
      'AAV',
      fontSize: 9,
    );

    // Programmer / room stat / cylinder stat boxes
    _drawWallBox(c, Offset(s.width * 0.06, s.height * 0.30), 'Programmer');
    _drawWallBox(c, Offset(s.width * 0.84, s.height * 0.50), 'Room stat',
        active: heatDemand);
    _drawWallBox(c, Offset(s.width * 0.06, s.height * 0.45), 'Cyl stat',
        active: hwDemand);

    // Demand indicators on house diagram
    PipePainterHelpers.drawLabel(
      c,
      Offset(s.width * 0.30, s.height * 0.06),
      heatDemand ? 'Heat: CALL' : 'Heat: off',
      fontSize: 10,
      background: heatDemand ? const Color(0xFFFFE7E0) : Colors.white,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(s.width * 0.55, s.height * 0.06),
      hwDemand ? 'HW: CALL' : 'HW: off',
      fontSize: 10,
      background: hwDemand ? const Color(0xFFFFE7E0) : Colors.white,
    );

    // Animate flow particles only on active routes
    if (firing) {
      // boiler -> valve always when firing
      PipePainterHelpers.drawFlowParticles(
        c,
        a: boilerOut,
        b: valveCentre,
        progress: t,
        color: Colors.white,
        count: 5,
      );
      // common return to boiler
      PipePainterHelpers.drawFlowParticles(
        c,
        a: pumpPos,
        b: abReturn,
        progress: 1 - t,
        color: Colors.white,
        count: 4,
      );
    }
    if (heatDemand) {
      PipePainterHelpers.drawFlowParticles(
        c,
        a: portA,
        b: hFlowTop,
        progress: t,
        color: Colors.white,
        count: 4,
      );
      PipePainterHelpers.drawFlowParticles(
        c,
        a: hFlowTop,
        b: hFlowDown,
        progress: t,
        color: Colors.white,
        count: 4,
      );
      PipePainterHelpers.drawFlowParticles(
        c,
        a: Offset(radPositions.last.left, radPositions.last.bottom),
        b: retStart,
        progress: 1 - t,
        color: Colors.white,
        count: 3,
      );
    }
    if (hwDemand) {
      PipePainterHelpers.drawFlowParticles(
        c,
        a: portB,
        b: Offset(portB.dx, cylInTop.dy - 30),
        progress: t,
        color: Colors.white,
        count: 4,
      );
      PipePainterHelpers.drawFlowParticles(
        c,
        a: coilOut,
        b: Offset(retCorner.dx, coilOut.dy),
        progress: 1 - t,
        color: Colors.white,
        count: 3,
      );
    }

    // Step-specific overlays
    if (step == 5) {
      _drawWiringNote(c, s);
    }
    if (step == 6 && !firing) {
      PipePainterHelpers.drawLabel(
        c,
        Offset(s.width * 0.40, s.height * 0.20),
        'Boiler interlock satisfied: no demand, no fire',
        fontSize: 11,
        background: const Color(0xFFFFF8DC),
      );
    }
    if (step == 7) {
      PipePainterHelpers.drawLabel(
        c,
        Offset(valveCentre.dx + 60, valveCentre.dy - 60),
        'Fault: actuator stuck',
        fontSize: 10,
        background: const Color(0xFFFFE0E0),
      );
    }
  }

  void _drawThreePortValve(Canvas c, Offset centre, double angle) {
    final body = Paint()..color = AppColors.brass;
    final stroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    c.drawCircle(centre, 22, body);
    c.drawCircle(centre, 22, stroke);
    // motor head
    final head = Rect.fromCenter(
      center: Offset(centre.dx, centre.dy - 28),
      width: 28,
      height: 18,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(head, const Radius.circular(4)),
      Paint()..color = Colors.black87,
    );
    // arrow indicates rotor position
    final tip = PipePainterHelpers.rotate(
      Offset(centre.dx, centre.dy - 18),
      centre,
      angle,
    );
    final arrow = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    c.drawLine(centre, tip, arrow);
    c.drawCircle(tip, 3, Paint()..color = AppColors.accent);
  }

  void _drawCylinder(Canvas c, Rect rect, bool hot) {
    final body = Paint()..color = AppColors.copper.withValues(alpha: 0.85);
    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      body,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // coil swirls
    final coil = Paint()
      ..color = hot ? AppColors.hotWater : AppColors.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    for (int i = 0; i < 4; i++) {
      final y = rect.top + 30 + i * 16.0;
      final p = Path()
        ..moveTo(rect.left + 6, y)
        ..quadraticBezierTo(rect.center.dx, y - 6, rect.right - 6, y);
      c.drawPath(p, coil);
    }
    PipePainterHelpers.drawLabel(
      c,
      Offset(rect.left, rect.top - 16),
      'HW cylinder',
      fontSize: 10,
    );
  }

  void _drawPump(Canvas c, Offset p, double t) {
    c.drawCircle(p, 12, Paint()..color = AppColors.pipeMetal);
    c.drawCircle(
      p,
      12,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final angle = t * math.pi * 2;
    final blade = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      final a = angle + i * (math.pi * 2 / 3);
      c.drawLine(
        p,
        Offset(p.dx + math.cos(a) * 9, p.dy + math.sin(a) * 9),
        blade,
      );
    }
  }

  void _drawExpansionVessel(Canvas c, Offset p) {
    final r = Rect.fromCenter(center: p, width: 18, height: 26);
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()..color = const Color(0xFFB30000),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawGauge(Canvas c, Offset p, double pressureBar) {
    c.drawCircle(p, 9, Paint()..color = Colors.white);
    c.drawCircle(
      p,
      9,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    final ang = (pressureBar / 4.0) * math.pi - math.pi / 2;
    c.drawLine(
      p,
      Offset(p.dx + math.cos(ang) * 6, p.dy + math.sin(ang) * 6),
      Paint()
        ..color = AppColors.hotWater
        ..strokeWidth = 1.6,
    );
  }

  void _drawAAV(Canvas c, Offset p) {
    final r = Rect.fromCenter(center: p, width: 12, height: 16);
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(2)),
      Paint()..color = Colors.black87,
    );
    c.drawCircle(Offset(p.dx, p.dy - 12), 4, Paint()..color = Colors.white);
    c.drawCircle(
      Offset(p.dx, p.dy - 12),
      4,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawWallBox(Canvas c, Offset p, String label, {bool active = false}) {
    final r = Rect.fromCenter(center: p, width: 28, height: 20);
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()..color = active ? AppColors.accent : Colors.white,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(p.dx - 22, p.dy + 14),
      label,
      fontSize: 9,
    );
  }

  void _drawWiringNote(Canvas c, Size s) {
    final box = Rect.fromLTWH(s.width * 0.30, s.height * 0.85, s.width * 0.40, 28);
    c.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(6)),
      Paint()..color = const Color(0xFFFFF8DC),
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(box.left + 6, box.top + 6),
      'White=motor  Grey=limit  Orange=SP  Blue=N  G/Y=E',
      fontSize: 10,
      background: const Color(0xFFFFF8DC),
    );
  }

  @override
  bool shouldRepaint(_YPlanPainter o) => true;
}
