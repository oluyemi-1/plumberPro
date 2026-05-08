import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class UnderfloorHeatingSimScreen extends StatefulWidget {
  const UnderfloorHeatingSimScreen({super.key});
  @override
  State<UnderfloorHeatingSimScreen> createState() =>
      _UnderfloorHeatingSimScreenState();
}

class _UnderfloorHeatingSimScreenState extends State<UnderfloorHeatingSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<bool> _loops = [true, true, false, false];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = const [
      SimStep(
        title: 'UFH principle',
        narration:
            'Underfloor heating uses a large warm surface to deliver gentle, even heat across a room. Because output is spread over the whole floor area, low water temperatures still produce comfortable warmth.',
      ),
      SimStep(
        title: 'Manifold function',
        narration:
            'The manifold is a pair of brass rails that splits one supply pipe into multiple loops. Each loop feeds a zone or a room and returns to the same manifold body where flow can be balanced.',
      ),
      SimStep(
        title: 'Blending unit',
        narration:
            'A blending valve mixes hot primary at around sixty degrees with cooler return water to deliver flow at roughly forty degrees. The return temperature back to the boiler typically sits around thirty degrees.',
      ),
      SimStep(
        title: 'Loop length',
        narration:
            'Each loop is limited to about one hundred metres of sixteen millimetre pipe to keep pressure drop manageable. Larger rooms therefore use multiple loops rather than one long one.',
      ),
      SimStep(
        title: 'Pipe spacing',
        narration:
            'Pipe centres are typically one hundred and fifty millimetres in main living areas. Spacing tightens to one hundred millimetres around perimeters and in bathrooms to compensate for higher heat loss.',
      ),
      SimStep(
        title: 'Actuators',
        narration:
            'Thermal or motorised actuators sit on the flow ports of the manifold. They are normally closed and open when the room thermostat calls, with twenty-four or two hundred and thirty volt versions common.',
      ),
      SimStep(
        title: 'Flowmeters and balancing',
        narration:
            'The return rail carries flowmeter cups that read litres per minute. The lockshield is adjusted until each loop carries flow proportional to its length, balancing the system across the rooms.',
      ),
      SimStep(
        title: 'Screed type and depth',
        narration:
            'Sand-cement screed is typically seventy-five millimetres deep over the pipe, while liquid screed can be just thirty to fifty millimetres. Depth and conductivity affect both response time and output.',
      ),
      SimStep(
        title: 'Commissioning',
        narration:
            'After pressure testing the loops to six bar, commissioning follows a slow warm-up curve over about seven days. Flow temperature is raised gradually to drive moisture out without cracking the screed.',
      ),
      SimStep(
        title: 'Common faults',
        narration:
            'Typical issues include an air-locked loop that remains cold, a scaled or seized actuator stuck shut, and a faulty thermostat that fails to call. Bleeding and replacing the suspect part usually resolves it.',
      ),
    ];

    return SimScaffold(
      title: 'Underfloor heating manifold',
      summary:
          'A wet underfloor heating system with a four-port manifold, blending unit and four floor loops. Toggle each loop to see particles flow, the actuator open and the floor warm up.',
      onStepChanged: (i) => setState(() {}),
      steps: steps,
      controls: [
        for (int i = 0; i < _loops.length; i++)
          _LoopSwitch(
            label: 'Loop ${i + 1}',
            value: _loops[i],
            onChanged: (v) => setState(() => _loops[i] = v),
          ),
      ],
      diagramBuilder: (ctx, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _UfhPainter(
              step: stepIndex,
              t: _ctrl.value,
              loops: List<bool>.from(_loops),
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _LoopSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _LoopSwitch({
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

class _UfhPainter extends CustomPainter {
  final int step;
  final double t;
  final List<bool> loops;
  _UfhPainter({required this.step, required this.t, required this.loops});

  static const _loopColors = [
    Color(0xFFE63946),
    Color(0xFF2A9D8F),
    Color(0xFFE9C46A),
    Color(0xFF9D4EDD),
  ];

  @override
  void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = AppColors.cardBg);

    // Floor area on left
    final floorRect = Rect.fromLTWH(
      s.width * 0.04,
      s.height * 0.10,
      s.width * 0.55,
      s.height * 0.78,
    );
    final activeCount = loops.where((e) => e).length;
    final warmth = (activeCount / loops.length).clamp(0.0, 1.0);
    final floorBase = Color.lerp(
      const Color(0xFFE7E5DD),
      const Color(0xFFFCD3B0),
      warmth * (0.6 + 0.4 * math.sin(t * math.pi * 2) * 0.2 + 0.4),
    )!;
    c.drawRRect(
      RRect.fromRectAndRadius(floorRect, const Radius.circular(8)),
      Paint()..color = floorBase,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(floorRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(floorRect.left + 6, floorRect.top + 6),
      'Heated floor area',
      fontSize: 10,
    );

    // Boiler far left top
    final boiler = Rect.fromLTWH(
      s.width * 0.005,
      s.height * 0.04,
      s.width * 0.10,
      s.height * 0.10,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(boiler, const Radius.circular(6)),
      Paint()..color = const Color(0xFFE9EEF5),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(boiler, const Radius.circular(6)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(boiler.left + 4, boiler.top + 4),
      'Boiler 60°C',
      fontSize: 9,
    );

    // Manifold on right
    final manX = s.width * 0.66;
    final manTopY = s.height * 0.20;
    final manBotY = s.height * 0.70;
    final manRailLen = s.width * 0.28;
    // Top flow rail
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(manX, manTopY),
      b: Offset(manX + manRailLen, manTopY),
      color: AppColors.hotWater,
      width: 12,
    );
    // Bottom return rail
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(manX, manBotY),
      b: Offset(manX + manRailLen, manBotY),
      color: AppColors.coldWater,
      width: 12,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(manX, manTopY - 22),
      'Flow rail',
      fontSize: 10,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(manX, manBotY + 14),
      'Return rail',
      fontSize: 10,
    );

    // Blending unit + pump on inlet
    final blendCentre = Offset(manX - s.width * 0.04, manTopY);
    _drawBlendingValve(c, blendCentre, activeCount > 0);
    PipePainterHelpers.drawLabel(
      c,
      Offset(blendCentre.dx - 28, blendCentre.dy - 28),
      'Blending 40°C',
      fontSize: 9,
    );
    final pumpCentre = Offset(manX - s.width * 0.04, manBotY);
    _drawPump(c, pumpCentre, t, activeCount > 0);
    PipePainterHelpers.drawLabel(
      c,
      Offset(pumpCentre.dx - 14, pumpCentre.dy + 14),
      'Pump',
      fontSize: 9,
    );

    // Primary flow / return from boiler
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(boiler.right, boiler.center.dy),
      b: Offset(blendCentre.dx, boiler.center.dy),
      color: AppColors.hotWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(blendCentre.dx, boiler.center.dy),
      b: blendCentre,
      color: AppColors.hotWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: pumpCentre,
      b: Offset(pumpCentre.dx, boiler.center.dy + 16),
      color: AppColors.coldWater,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(pumpCentre.dx, boiler.center.dy + 16),
      b: Offset(boiler.right, boiler.center.dy + 16),
      color: AppColors.coldWater,
      width: 8,
    );

    // Loop tappings
    final n = loops.length;
    final spacing = manRailLen / (n + 1);
    for (int i = 0; i < n; i++) {
      final tapX = manX + spacing * (i + 1);
      final actuator = Offset(tapX, manTopY - 22);
      _drawActuator(c, actuator, loops[i]);
      PipePainterHelpers.drawLabel(
        c,
        Offset(tapX - 8, manTopY - 46),
        'A${i + 1}',
        fontSize: 9,
      );
      // flowmeter cup on bottom rail
      _drawFlowmeter(c, Offset(tapX, manBotY + 22), loops[i]);

      // Loop runs left into floor area
      final loopY = floorRect.top + 30 + i * ((floorRect.height - 60) / n);
      final color = _loopColors[i % _loopColors.length];
      // pipe out from manifold to floor
      PipePainterHelpers.drawPipe(
        c,
        a: Offset(tapX, manTopY),
        b: Offset(tapX, loopY),
        color: color,
        width: 5,
      );
      PipePainterHelpers.drawPipe(
        c,
        a: Offset(tapX, loopY),
        b: Offset(floorRect.right - 8, loopY),
        color: color,
        width: 5,
      );
      // Snake within floor
      _drawSnake(
        c,
        Rect.fromLTWH(
          floorRect.left + 20,
          loopY,
          floorRect.width - 40,
          (floorRect.height - 60) / n - 6,
        ),
        color,
        loops[i],
        t,
      );
      // return up to bottom rail
      final retY = loopY + (floorRect.height - 60) / n - 6;
      PipePainterHelpers.drawPipe(
        c,
        a: Offset(floorRect.right - 8, retY),
        b: Offset(tapX, retY),
        color: color.withValues(alpha: 0.6),
        width: 5,
      );
      PipePainterHelpers.drawPipe(
        c,
        a: Offset(tapX, retY),
        b: Offset(tapX, manBotY),
        color: color.withValues(alpha: 0.6),
        width: 5,
      );

      // Particles only when this loop is active
      if (loops[i]) {
        PipePainterHelpers.drawFlowParticles(
          c,
          a: Offset(tapX, manTopY),
          b: Offset(tapX, loopY),
          progress: t,
          color: Colors.white,
          count: 3,
        );
        PipePainterHelpers.drawFlowParticles(
          c,
          a: Offset(tapX, retY),
          b: Offset(tapX, manBotY),
          progress: 1 - t,
          color: Colors.white,
          count: 3,
        );
      }

      // Room thermostat icon on floor
      final stat = Offset(floorRect.left + 30 + (i % 2) * 20, loopY + 6);
      _drawRoomStat(c, stat, loops[i]);
    }

    // Joints
    PipePainterHelpers.drawJoint(c, Offset(manX, manTopY));
    PipePainterHelpers.drawJoint(c, Offset(manX + manRailLen, manTopY));
    PipePainterHelpers.drawJoint(c, Offset(manX, manBotY));
    PipePainterHelpers.drawJoint(c, Offset(manX + manRailLen, manBotY));

    // Step overlays
    if (step == 4) {
      PipePainterHelpers.drawLabel(
        c,
        Offset(floorRect.left + 12, floorRect.bottom - 24),
        '150 mm centres in main rooms, 100 mm at perimeter',
        fontSize: 10,
        background: const Color(0xFFFFF8DC),
      );
    }
    if (step == 8) {
      PipePainterHelpers.drawLabel(
        c,
        Offset(floorRect.left + 12, floorRect.top + 30),
        'Slow warm-up: +5°C per day for 7 days',
        fontSize: 10,
        background: const Color(0xFFFFF8DC),
      );
    }
    if (step == 9) {
      PipePainterHelpers.drawLabel(
        c,
        Offset(manX + 30, manTopY - 60),
        'Fault: scaled actuator',
        fontSize: 10,
        background: const Color(0xFFFFE0E0),
      );
    }

    // Temperature labels for blending step
    if (step == 2) {
      PipePainterHelpers.drawLabel(
        c,
        Offset(boiler.right + 4, boiler.bottom + 4),
        'Primary 60°C',
        fontSize: 9,
      );
      PipePainterHelpers.drawLabel(
        c,
        Offset(blendCentre.dx + 14, blendCentre.dy + 4),
        'Mixed 40°C',
        fontSize: 9,
      );
      PipePainterHelpers.drawLabel(
        c,
        Offset(pumpCentre.dx + 14, pumpCentre.dy - 8),
        'Return 30°C',
        fontSize: 9,
      );
    }
  }

  void _drawSnake(Canvas c, Rect rect, Color color, bool active, double tt) {
    final paint = Paint()
      ..color = color.withValues(alpha: active ? 0.9 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final rows = 3;
    final stepY = rect.height / rows;
    path.moveTo(rect.right, rect.top);
    for (int r = 0; r < rows; r++) {
      final y = rect.top + r * stepY;
      final yNext = y + stepY;
      if (r.isEven) {
        path.lineTo(rect.left, y);
        path.lineTo(rect.left, yNext);
      } else {
        path.lineTo(rect.right, y);
        path.lineTo(rect.right, yNext);
      }
    }
    c.drawPath(path, paint);

    if (active) {
      // Animated dashes by overlaying a moving stroke
      final glow = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      // Sample points along path for moving dashes
      final metrics = path.computeMetrics().toList();
      double total = 0;
      for (final m in metrics) {
        total += m.length;
      }
      final dashCount = 8;
      for (int i = 0; i < dashCount; i++) {
        final pos = ((tt + i / dashCount) % 1.0) * total;
        double remaining = pos;
        for (final m in metrics) {
          if (remaining <= m.length) {
            final tan = m.getTangentForOffset(remaining);
            if (tan != null) {
              c.drawCircle(tan.position, 2.5, glow);
            }
            break;
          }
          remaining -= m.length;
        }
      }
    }
  }

  void _drawActuator(Canvas c, Offset p, bool open) {
    final body = Rect.fromCenter(center: p, width: 14, height: 22);
    c.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(3)),
      Paint()..color = open ? AppColors.accent : Colors.grey.shade500,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    // status dot
    c.drawCircle(
      Offset(p.dx, p.dy - 8),
      2.5,
      Paint()..color = open ? Colors.white : Colors.black26,
    );
  }

  void _drawFlowmeter(Canvas c, Offset p, bool open) {
    final body = Rect.fromCenter(center: p, width: 14, height: 22);
    c.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(3)),
      Paint()..color = Colors.white,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(3)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    final level = open ? 0.6 + 0.2 * math.sin(t * math.pi * 2) : 0.0;
    final fill = Rect.fromLTRB(
      body.left + 2,
      body.bottom - body.height * level,
      body.right - 2,
      body.bottom - 2,
    );
    c.drawRect(fill, Paint()..color = AppColors.coldWater);
  }

  void _drawBlendingValve(Canvas c, Offset p, bool active) {
    c.drawCircle(p, 14, Paint()..color = AppColors.brass);
    c.drawCircle(
      p,
      14,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    final ang = active ? -math.pi / 4 : -math.pi / 2;
    final tip = Offset(p.dx + math.cos(ang) * 10, p.dy + math.sin(ang) * 10);
    final triangle = Path()
      ..moveTo(p.dx, p.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + 4, tip.dy + 4)
      ..close();
    c.drawPath(triangle, Paint()..color = AppColors.accent);
  }

  void _drawPump(Canvas c, Offset p, double tt, bool spinning) {
    c.drawCircle(p, 12, Paint()..color = AppColors.pipeMetal);
    c.drawCircle(
      p,
      12,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    final angle = spinning ? tt * math.pi * 2 : 0.0;
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

  void _drawRoomStat(Canvas c, Offset p, bool calling) {
    final r = Rect.fromCenter(center: p, width: 14, height: 10);
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(2)),
      Paint()..color = calling ? AppColors.accent : Colors.white,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(2)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_UfhPainter o) => true;
}
