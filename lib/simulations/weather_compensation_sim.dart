import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class WeatherCompensationSimScreen extends StatefulWidget {
  const WeatherCompensationSimScreen({super.key});
  @override
  State<WeatherCompensationSimScreen> createState() =>
      _WeatherCompensationSimScreenState();
}

class _WeatherCompensationSimScreenState
    extends State<WeatherCompensationSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Heat curve: flow = base - slope * outsideTemp
  // We'll let user pick low / med / high slope.
  int _curveIndex = 1;
  double? _override; // null = use animated outside temp

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _slope() {
    switch (_curveIndex) {
      case 0:
        return 0.6; // low
      case 2:
        return 1.6; // high
      default:
        return 1.0; // medium
    }
  }

  double _outsideTemp(double t) {
    if (_override != null) return _override!;
    // sin from -5 to +18
    final centre = 6.5;
    final amp = 11.5;
    return centre + amp * math.sin(t * math.pi * 2);
  }

  double _flowSetpoint(double outside) {
    final base = 70.0;
    final v = base - _slope() * (outside + 5);
    return v.clamp(25.0, 80.0);
  }

  @override
  Widget build(BuildContext context) {
    final steps = const [
      SimStep(
        title: 'Why weather compensation',
        narration:
            'Weather compensation matches the boiler flow temperature to the actual outside temperature. The result is a closer match between heat input and the building\'s heat loss, reducing overshoot and energy waste.',
      ),
      SimStep(
        title: 'Outside sensor',
        narration:
            'The outside sensor lives high up on a north-facing wall away from windows, vents and direct sun. This gives a stable reading of true ambient temperature, not a transient warm spike.',
      ),
      SimStep(
        title: 'Heat curve',
        narration:
            'The heat curve maps outside temperature to flow temperature. As outside temperature drops, flow temperature climbs along a sloped line so the radiators emit more heat exactly when needed.',
      ),
      SimStep(
        title: 'Curve slope and offset',
        narration:
            'A steeper slope suits older properties with high heat loss and large radiators. A shallower slope is set for well-insulated homes where lower flow temperatures are sufficient.',
      ),
      SimStep(
        title: 'Room influence',
        narration:
            'A room sensor can apply a small bias to the curve. If the lounge is overshooting its set point, the controller reduces flow temperature slightly to fine-tune comfort without abandoning the curve.',
      ),
      SimStep(
        title: 'Condensing efficiency',
        narration:
            'Lower flow temperatures keep the return below the dew point of about fifty-five degrees. The boiler then condenses water vapour out of the flue gases, recovering latent heat and lifting efficiency.',
      ),
      SimStep(
        title: 'Modulating boiler match',
        narration:
            'Modulating boilers continuously trim their burner output to maintain the calculated flow temperature. This smooth, low-output running cycles less and lasts longer than fixed on-off operation.',
      ),
      SimStep(
        title: 'Commissioning',
        narration:
            'Verify the curve on a genuinely cold day, ideally below freezing. Log flow temperatures at the boiler and adjust the slope if the home struggles to reach set-point or overshoots in mild weather.',
      ),
    ];

    return SimScaffold(
      title: 'Weather compensation',
      summary:
          'A weather-compensated boiler with an outside sensor that varies flow temperature against an adjustable heat curve. Drag the slider or pick a curve to see the boiler respond.',
      onStepChanged: (i) => setState(() {}),
      steps: steps,
      controls: [
        SizedBox(
          width: 240,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Outside temperature override',
                style: TextStyle(fontSize: 12),
              ),
              Slider(
                min: -10,
                max: 20,
                value: _override ?? 6.5,
                onChanged: (v) => setState(() => _override = v),
                divisions: 30,
                label: '${(_override ?? 6.5).toStringAsFixed(1)}°C',
              ),
              TextButton(
                onPressed: () => setState(() => _override = null),
                child: const Text('Use simulated'),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 6,
          children: [
            _CurveButton(
              label: 'Low',
              selected: _curveIndex == 0,
              onTap: () => setState(() => _curveIndex = 0),
            ),
            _CurveButton(
              label: 'Medium',
              selected: _curveIndex == 1,
              onTap: () => setState(() => _curveIndex = 1),
            ),
            _CurveButton(
              label: 'High',
              selected: _curveIndex == 2,
              onTap: () => setState(() => _curveIndex = 2),
            ),
          ],
        ),
      ],
      diagramBuilder: (ctx, stepIndex) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final outside = _outsideTemp(_ctrl.value);
            final flow = _flowSetpoint(outside);
            return CustomPaint(
              painter: _WCPainter(
                step: stepIndex,
                t: _ctrl.value,
                outside: outside,
                flowSetpoint: flow,
                slope: _slope(),
              ),
              size: Size.infinite,
            );
          },
        );
      },
    );
  }
}

class _CurveButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CurveButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _WCPainter extends CustomPainter {
  final int step;
  final double t;
  final double outside;
  final double flowSetpoint;
  final double slope;
  _WCPainter({
    required this.step,
    required this.t,
    required this.outside,
    required this.flowSetpoint,
    required this.slope,
  });

  @override
  void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = AppColors.cardBg);

    // Sky / outside on the left third
    final skyTone = Color.lerp(
      const Color(0xFFB3E0FF),
      const Color(0xFF20323F),
      ((10 - outside) / 25).clamp(0.0, 1.0),
    )!;
    final skyRect = Rect.fromLTWH(0, 0, s.width * 0.30, s.height);
    c.drawRect(skyRect, Paint()..color = skyTone);

    // Sun / cloud
    if (outside > 5) {
      c.drawCircle(
        Offset(s.width * 0.22, s.height * 0.10),
        16,
        Paint()..color = const Color(0xFFFFE066),
      );
    } else {
      // snowflakes
      for (int i = 0; i < 12; i++) {
        final x = (i / 12) * skyRect.width;
        final y = ((t * 80 + i * 23) % skyRect.height);
        c.drawCircle(
          Offset(x, y),
          1.6,
          Paint()..color = Colors.white.withValues(alpha: 0.8),
        );
      }
    }
    PipePainterHelpers.drawLabel(
      c,
      Offset(skyRect.left + 6, skyRect.top + 6),
      'Outside',
      fontSize: 10,
    );

    // House outline (right of sky)
    final houseRect = Rect.fromLTWH(
      s.width * 0.30,
      s.height * 0.04,
      s.width * 0.66,
      s.height * 0.92,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(houseRect, const Radius.circular(8)),
      Paint()..color = Colors.white,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(houseRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Outside thermometer mounted on house wall
    final thermoBase = Offset(s.width * 0.30 + 6, s.height * 0.20);
    _drawThermometer(c, thermoBase, outside);
    PipePainterHelpers.drawLabel(
      c,
      Offset(thermoBase.dx - 30, thermoBase.dy - 24),
      'Outside sensor',
      fontSize: 9,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(thermoBase.dx - 18, thermoBase.dy + 64),
      '${outside.toStringAsFixed(1)}°C',
      fontSize: 10,
    );

    // Boiler with controller
    final boiler = Rect.fromLTWH(
      s.width * 0.36,
      s.height * 0.16,
      s.width * 0.16,
      s.height * 0.22,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(boiler, const Radius.circular(8)),
      Paint()..color = const Color(0xFFE9EEF5),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(boiler, const Radius.circular(8)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(boiler.left + 4, boiler.top + 4),
      'Boiler',
      fontSize: 10,
    );

    // Controller display
    final disp = Rect.fromLTWH(
      boiler.left + 8,
      boiler.top + 24,
      boiler.width - 16,
      40,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(disp, const Radius.circular(4)),
      Paint()..color = const Color(0xFF0A2A3A),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: 'Flow set\n${flowSetpoint.toStringAsFixed(0)}°C',
        style: const TextStyle(
          color: Color(0xFF7CFFB2),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: disp.width);
    tp.paint(c, Offset(disp.left + 4, disp.top + 4));

    // Burner glow proportional to flow setpoint
    final fireT = ((flowSetpoint - 25) / 55).clamp(0.0, 1.0);
    if (fireT > 0.05) {
      final glow = Paint()
        ..color = AppColors.gas.withValues(alpha: 0.6 * fireT)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      c.drawCircle(
        Offset(boiler.center.dx, boiler.bottom - 14),
        14,
        glow,
      );
    }

    // Flow pipe colour intensity scales with flow setpoint
    final flowColor = Color.lerp(
      const Color(0xFFFFC4B5),
      AppColors.hotWater,
      fireT,
    )!;

    // Heating circuit out and back
    final flowOut = Offset(boiler.right, boiler.bottom - 28);
    final flowDown = Offset(boiler.right + 14, boiler.bottom - 28);
    final flowBus = Offset(boiler.right + 14, s.height * 0.62);
    final flowEnd = Offset(s.width * 0.92, s.height * 0.62);

    PipePainterHelpers.drawPipe(
      c,
      a: flowOut,
      b: flowDown,
      color: flowColor,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: flowDown,
      b: flowBus,
      color: flowColor,
      width: 8,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: flowBus,
      b: flowEnd,
      color: flowColor,
      width: 8,
    );

    // Three radiators
    final radWarmth = fireT;
    final radPositions = <Rect>[
      Rect.fromLTWH(s.width * 0.40, s.height * 0.70, s.width * 0.13, s.height * 0.10),
      Rect.fromLTWH(s.width * 0.58, s.height * 0.70, s.width * 0.13, s.height * 0.10),
      Rect.fromLTWH(s.width * 0.76, s.height * 0.70, s.width * 0.13, s.height * 0.10),
    ];
    for (final r in radPositions) {
      PipePainterHelpers.drawRadiator(c, rect: r, warmth: radWarmth);
      PipePainterHelpers.drawPipe(
        c,
        a: Offset(r.left + r.width * 0.5, r.top),
        b: Offset(r.left + r.width * 0.5, s.height * 0.62),
        color: flowColor,
        width: 5,
      );
    }

    // Return pipe
    final returnY = s.height * 0.85;
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(s.width * 0.92, returnY),
      b: Offset(s.width * 0.40, returnY),
      color: AppColors.coldWater,
      width: 6,
    );
    for (final r in radPositions) {
      PipePainterHelpers.drawPipe(
        c,
        a: Offset(r.left + r.width * 0.5, r.bottom),
        b: Offset(r.left + r.width * 0.5, returnY),
        color: AppColors.coldWater,
        width: 5,
      );
    }
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(s.width * 0.40, returnY),
      b: Offset(boiler.center.dx, returnY),
      color: AppColors.coldWater,
      width: 6,
    );
    PipePainterHelpers.drawPipe(
      c,
      a: Offset(boiler.center.dx, returnY),
      b: Offset(boiler.center.dx, boiler.bottom),
      color: AppColors.coldWater,
      width: 6,
    );

    // Particles flow when boiler firing
    if (fireT > 0.1) {
      PipePainterHelpers.drawFlowParticles(
        c,
        a: flowBus,
        b: flowEnd,
        progress: t,
        color: Colors.white,
        count: 5,
      );
      PipePainterHelpers.drawFlowParticles(
        c,
        a: Offset(s.width * 0.92, returnY),
        b: Offset(s.width * 0.40, returnY),
        progress: t,
        color: Colors.white,
        count: 4,
      );
    }

    // Joints
    PipePainterHelpers.drawJoint(c, flowDown);
    PipePainterHelpers.drawJoint(c, flowBus);
    PipePainterHelpers.drawJoint(c, Offset(s.width * 0.40, returnY));
    PipePainterHelpers.drawJoint(c, Offset(boiler.center.dx, returnY));

    // Outside sensor wire from thermometer to boiler
    final wirePaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final wirePath = Path()
      ..moveTo(thermoBase.dx + 6, thermoBase.dy + 22)
      ..quadraticBezierTo(
        thermoBase.dx + 30,
        thermoBase.dy + 60,
        boiler.left,
        boiler.top + 10,
      );
    c.drawPath(wirePath, wirePaint);
    PipePainterHelpers.drawLabel(
      c,
      Offset(thermoBase.dx + 26, thermoBase.dy + 30),
      'Sensor wire',
      fontSize: 9,
    );

    // Heat curve chart (top-right corner)
    final chart = Rect.fromLTWH(
      s.width * 0.62,
      s.height * 0.06,
      s.width * 0.32,
      s.height * 0.30,
    );
    _drawHeatCurve(c, chart);

    // Step overlays
    if (step == 4) {
      PipePainterHelpers.drawLabel(
        c,
        Offset(s.width * 0.58, s.height * 0.42),
        'Room sensor bias: -2°C on flow',
        fontSize: 10,
        background: const Color(0xFFFFF8DC),
      );
    }
    if (step == 5) {
      PipePainterHelpers.drawLabel(
        c,
        Offset(boiler.right + 4, boiler.bottom + 8),
        'Return < 55°C: condensing on',
        fontSize: 10,
        background: const Color(0xFFE8FBE8),
      );
    }
    if (step == 6) {
      PipePainterHelpers.drawLabel(
        c,
        Offset(boiler.left + 4, boiler.bottom - 8),
        'Burner modulating',
        fontSize: 10,
        background: const Color(0xFFFFF8DC),
      );
    }
  }

  void _drawThermometer(Canvas c, Offset base, double tempC) {
    // tube
    final tube = Rect.fromCenter(
      center: Offset(base.dx + 6, base.dy + 20),
      width: 8,
      height: 50,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(tube, const Radius.circular(4)),
      Paint()..color = Colors.white,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(tube, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    // mercury
    final lvl = ((tempC + 10) / 30).clamp(0.0, 1.0);
    final fill = Rect.fromLTRB(
      tube.left + 1.5,
      tube.bottom - tube.height * lvl,
      tube.right - 1.5,
      tube.bottom - 2,
    );
    c.drawRect(fill, Paint()..color = AppColors.hotWater);
    // bulb
    c.drawCircle(
      Offset(tube.center.dx, tube.bottom + 4),
      6,
      Paint()..color = AppColors.hotWater,
    );
    c.drawCircle(
      Offset(tube.center.dx, tube.bottom + 4),
      6,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawHeatCurve(Canvas c, Rect rect) {
    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = Colors.white,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.stroke,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(rect.left + 6, rect.top + 4),
      'Heat curve',
      fontSize: 10,
    );
    // axes
    final axisPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1.2;
    final ox = rect.left + 26;
    final oy = rect.bottom - 22;
    c.drawLine(Offset(ox, oy), Offset(rect.right - 8, oy), axisPaint);
    c.drawLine(Offset(ox, oy), Offset(ox, rect.top + 22), axisPaint);
    PipePainterHelpers.drawLabel(
      c,
      Offset(rect.right - 50, oy + 2),
      'Outside °C',
      fontSize: 9,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(ox - 18, rect.top + 22),
      'Flow °C',
      fontSize: 9,
    );

    // Map outside (-10..20) to x, flow (20..80) to y
    Offset toCanvas(double oTemp, double flow) {
      final fx = ((oTemp + 10) / 30).clamp(0.0, 1.0);
      final fy = ((flow - 20) / 60).clamp(0.0, 1.0);
      return Offset(
        ox + fx * (rect.right - 8 - ox),
        oy - fy * (oy - (rect.top + 22)),
      );
    }

    // curve line: flow = 70 - slope*(o+5)
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2;
    final p1 = toCanvas(-10, (70 - slope * (-10 + 5)).clamp(20.0, 80.0));
    final p2 = toCanvas(20, (70 - slope * (20 + 5)).clamp(20.0, 80.0));
    c.drawLine(p1, p2, linePaint);

    // dot at current outside / flow
    final dot = toCanvas(outside, flowSetpoint);
    c.drawCircle(dot, 5, Paint()..color = AppColors.accent);
    c.drawCircle(
      dot,
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    PipePainterHelpers.drawLabel(
      c,
      Offset(dot.dx + 8, dot.dy - 8),
      '${flowSetpoint.toStringAsFixed(0)}°C',
      fontSize: 9,
    );
  }

  @override
  bool shouldRepaint(_WCPainter o) => true;
}
