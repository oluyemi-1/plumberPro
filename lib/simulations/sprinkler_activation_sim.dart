import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/paint_helpers.dart';
import '../widgets/sim_scaffold.dart';

class SprinklerActivationSimScreen extends StatefulWidget {
  const SprinklerActivationSimScreen({super.key});

  @override
  State<SprinklerActivationSimScreen> createState() =>
      _SprinklerActivationSimScreenState();
}

class _SprinklerActivationSimScreenState
    extends State<SprinklerActivationSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Simulation state.
  bool _ignited = false;
  double _heatBuilt = 0; // 0 (cool) -> 1 (head bursts)
  double _fireIntensity = 0.6; // 0..1
  bool _activated = false; // sprinkler bulb burst, water flowing
  int _tempRating = 68; // 57 / 68 / 79 (°C)
  DateTime _lastTick = DateTime.now();

  static const _steps = <SimStep>[
    SimStep(
      title: 'How a sprinkler activates',
      narration:
          'Each sprinkler head is independently triggered by heat at the head itself. The head over the fire opens; the others stay shut. There is no central control deciding when to fire.',
    ),
    SimStep(
      title: 'The glass bulb and temperature rating',
      narration:
          'Inside the head a small glass bulb holds a coloured liquid that expands when heated. When the liquid expands enough, the bulb shatters, releasing the seal and letting water spray onto the deflector below.',
    ),
    SimStep(
      title: 'The alarm valve and flow switch',
      narration:
          'As soon as one head opens, water flows through the alarm valve. A motorised gong outside sounds, and an electric flow switch sends a signal to the panel. Both prove water is moving in the system.',
    ),
    SimStep(
      title: 'Monitoring and alarms',
      narration:
          'In a Cat 2 or Cat 3 system the flow switch, low tank level and pump-fail signals are routed to a constantly attended location, the building management system or an alarm receiving centre, with sounders inside the building.',
    ),
    SimStep(
      title: 'Pump set and tank with weekly test',
      narration:
          'The pump set with its dedicated tank delivers the design flow for the design duration. Weekly tests run the duty pump on bypass; quarterly checks include flow switch and gong tests; annual service tests the most remote head.',
    ),
    SimStep(
      title: 'Why only one head usually fires',
      narration:
          'In a Cat 1 domestic install only the head over the fire reaches activation temperature. Heat does not build up enough at neighbouring heads because the activated head cools the room rapidly with its spray.',
    ),
    SimStep(
      title: 'After the fire',
      narration:
          'Once the fire is out, isolate the system, drain down, replace the activated head with the same K factor and temperature rating, refill, recommission and update the log book. Keep a sealed spare head box on site.',
    ),
    SimStep(
      title: 'Common myths debunked',
      narration:
          'Smoke alone does not open a sprinkler — only direct heat does. All heads do not fire together. Modern heads are not prone to leaks. Water damage from one head is far less than from a fire brigade hose.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _ctrl.addListener(_simStep);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_simStep);
    _ctrl.dispose();
    super.dispose();
  }

  void _simStep() {
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;
    if (!_ignited) {
      // Cool down slowly.
      if (_heatBuilt > 0) {
        _heatBuilt = math.max(0, _heatBuilt - dt * 0.25);
        if (mounted) setState(() {});
      }
      return;
    }
    if (_activated) return;

    // Heat builds at a rate based on intensity, slowed for higher temp ratings.
    final rateBase = 0.18 + 0.55 * _fireIntensity;
    final tempScale = (_tempRating == 57)
        ? 1.0
        : _tempRating == 68
            ? 0.78
            : 0.58;
    _heatBuilt =
        (_heatBuilt + dt * rateBase * tempScale).clamp(0.0, 1.0);
    if (_heatBuilt >= 1.0 && !_activated) {
      _activated = true;
    }
    if (mounted) setState(() {});
  }

  void _ignite() {
    setState(() {
      _ignited = true;
      _lastTick = DateTime.now();
    });
  }

  void _reset() {
    setState(() {
      _ignited = false;
      _activated = false;
      _heatBuilt = 0;
      _lastTick = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Sprinkler activation',
      summary:
          'A side cross-section of a domestic two-storey house with a BS 9251 sprinkler system. Ignite a test fire and watch heat build at the nearest head until its bulb bursts and water sprays.',
      onStepChanged: (_) => setState(() {}),
      controls: [
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fire intensity ${(_fireIntensity * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12),
              ),
              Slider(
                value: _fireIntensity,
                min: 0,
                max: 1,
                activeColor: AppColors.gas,
                onChanged: (v) => setState(() => _fireIntensity = v),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
          ),
          onPressed: _ignited ? null : _ignite,
          icon: const Icon(Icons.local_fire_department),
          label: const Text('Ignite test fire'),
        ),
        OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
        Wrap(
          spacing: 6,
          children: [
            for (final t in const [57, 68, 79])
              ChoiceChip(
                label: Text('$t°C'),
                selected: _tempRating == t,
                selectedColor:
                    AppColors.coldWater.withValues(alpha: 0.2),
                onSelected: (_) => setState(() => _tempRating = t),
              ),
          ],
        ),
      ],
      diagramBuilder: (ctx, i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _SprinklerPainter(
            step: i,
            t: _ctrl.value,
            ignited: _ignited,
            heat: _heatBuilt,
            fireIntensity: _fireIntensity,
            activated: _activated,
            tempRating: _tempRating,
          ),
          size: Size.infinite,
        ),
      ),
      steps: _steps,
    );
  }
}

class _SprinklerPainter extends CustomPainter {
  final int step;
  final double t;
  final bool ignited;
  final double heat;
  final double fireIntensity;
  final bool activated;
  final int tempRating;

  _SprinklerPainter({
    required this.step,
    required this.t,
    required this.ignited,
    required this.heat,
    required this.fireIntensity,
    required this.activated,
    required this.tempRating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFEAF2FA),
    );

    // House outline (side cross-section).
    final houseLeft = w * 0.08;
    final houseRight = w * 0.92;
    final groundY = h * 0.94;
    final firstFloorTop = h * 0.55;
    final firstFloorCeil = h * 0.50;
    final secondFloorTop = h * 0.18;
    final roofPeakY = h * 0.05;

    // House body
    final bodyPaint = Paint()..color = Colors.white;
    final bodyStroke = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final bodyRect =
        Rect.fromLTRB(houseLeft, secondFloorTop, houseRight, groundY);
    canvas.drawRect(bodyRect, bodyPaint);
    canvas.drawRect(bodyRect, bodyStroke);

    // Roof
    final roof = Path()
      ..moveTo(houseLeft - 6, secondFloorTop)
      ..lineTo((houseLeft + houseRight) / 2, roofPeakY)
      ..lineTo(houseRight + 6, secondFloorTop)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF8C2F2F));
    canvas.drawPath(roof, bodyStroke);

    // Floor slab between storeys
    canvas.drawRect(
      Rect.fromLTRB(houseLeft, firstFloorCeil, houseRight, firstFloorTop),
      Paint()..color = const Color(0xFFD7D2C4),
    );
    canvas.drawLine(
      Offset(houseLeft, firstFloorCeil),
      Offset(houseRight, firstFloorCeil),
      bodyStroke,
    );
    canvas.drawLine(
      Offset(houseLeft, firstFloorTop),
      Offset(houseRight, firstFloorTop),
      bodyStroke,
    );

    // Ground line
    canvas.drawRect(
      Rect.fromLTRB(0, groundY, w, h),
      Paint()..color = const Color(0xFFB6B59A),
    );

    // ----- Pump set & tank in cupboard (loft area, left under roof) -----
    final tankRect = Rect.fromLTWH(
      houseLeft + 8,
      secondFloorTop - 2,
      w * 0.13,
      h * 0.14,
    );
    PipePainterHelpers.drawTank(
      canvas,
      rect: tankRect,
      level: 0.85,
      label: 'Tank',
    );

    // Pump beneath tank
    final pumpCentre =
        Offset(tankRect.center.dx, tankRect.bottom + 24);
    _drawPump(canvas, pumpCentre, running: activated);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pumpCentre.dx - 18, pumpCentre.dy + 14),
      'Pump set',
    );

    // ----- Alarm valve assembly (right of pump) -----
    final alarmCentre = Offset(
      tankRect.right + w * 0.08,
      pumpCentre.dy,
    );
    _drawAlarmValve(canvas, alarmCentre, open: activated, t: t);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(alarmCentre.dx - 22, alarmCentre.dy + 24),
      'Alarm valve',
    );

    // Motorised gong outside the wall on the right
    final gongCentre = Offset(houseRight + 14, secondFloorTop + 30);
    _drawGong(canvas, gongCentre, ringing: activated, t: t);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gongCentre.dx - 14, gongCentre.dy + 20),
      'Gong',
    );

    // Flow switch (small box on alarm valve outlet)
    final flowSwitch = Offset(alarmCentre.dx + 28, alarmCentre.dy);
    _drawFlowSwitch(canvas, flowSwitch, active: activated);
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(flowSwitch.dx + 6, flowSwitch.dy - 16),
      'Flow switch',
    );

    // Pipe from pump to alarm valve
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(pumpCentre.dx + 12, pumpCentre.dy),
      b: Offset(alarmCentre.dx - 10, alarmCentre.dy),
      color: AppColors.coldWater,
      width: 10,
    );

    // ----- Wet rising main -----
    final riserX = alarmCentre.dx + 60;
    final riserTopY = secondFloorTop + 8;
    final riserBotY = pumpCentre.dy;

    // Pipe from alarm valve outlet to riser
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(flowSwitch.dx + 12, alarmCentre.dy),
      b: Offset(riserX, alarmCentre.dy),
      color: AppColors.coldWater,
      width: 10,
    );
    // Vertical riser between floors
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(riserX, riserBotY),
      b: Offset(riserX, riserTopY),
      color: AppColors.coldWater,
      width: 10,
    );

    // Branches at first floor ceiling and second floor ceiling.
    final lowerCeilingY = firstFloorTop - 8; // ground floor ceiling level
    final upperCeilingY = secondFloorTop + 14; // first floor ceiling level

    // Lower branch (along ground floor ceiling)
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(riserX, lowerCeilingY),
      b: Offset(houseLeft + 26, lowerCeilingY),
      color: AppColors.coldWater,
      width: 9,
    );
    // Upper branch (first floor ceiling)
    PipePainterHelpers.drawPipe(
      canvas,
      a: Offset(riserX, upperCeilingY),
      b: Offset(houseLeft + 26, upperCeilingY),
      color: AppColors.coldWater,
      width: 9,
    );

    // Connect riser to two branches via tees.
    PipePainterHelpers.drawJoint(canvas, Offset(riserX, lowerCeilingY));
    PipePainterHelpers.drawJoint(canvas, Offset(riserX, upperCeilingY));

    // ----- Sprinkler heads -----
    // Lower floor heads (one nearest fire is the activator)
    final lowerHeads = <Offset>[
      Offset(houseLeft + w * 0.18, lowerCeilingY + 8),
      Offset(houseLeft + w * 0.40, lowerCeilingY + 8),
      Offset(houseLeft + w * 0.60, lowerCeilingY + 8),
    ];
    // Upper floor heads
    final upperHeads = <Offset>[
      Offset(houseLeft + w * 0.20, upperCeilingY + 8),
      Offset(houseLeft + w * 0.45, upperCeilingY + 8),
      Offset(houseLeft + w * 0.65, upperCeilingY + 8),
    ];

    // Fire location — under the middle lower head
    final fireHead = lowerHeads[1];

    for (final hp in upperHeads) {
      _drawHead(canvas, hp, orientation: 'pendent', heat: 0, activated: false);
    }
    // One upright head on the upper landing for variety
    final uprightHead = Offset(houseLeft + w * 0.78, upperCeilingY + 14);
    _drawHead(canvas, uprightHead, orientation: 'upright',
        heat: 0, activated: false);

    for (int i = 0; i < lowerHeads.length; i++) {
      final hp = lowerHeads[i];
      final isFire = (i == 1);
      _drawHead(
        canvas,
        hp,
        orientation: 'pendent',
        heat: isFire ? heat : 0.0,
        activated: isFire && activated,
      );
    }

    // ----- Fire & smoke -----
    final fireBaseY = groundY - 10;
    final fireX = fireHead.dx;
    if (ignited) {
      _drawFire(
        canvas,
        Offset(fireX, fireBaseY),
        intensity: fireIntensity,
        damped: activated, // fire becomes smaller once water is on it
        t: t,
      );
      _drawHeatPlume(
        canvas,
        from: Offset(fireX, fireBaseY - 6),
        to: fireHead,
        progress: t,
        heatLevel: heat,
        damped: activated,
      );
    }

    // ----- Water spray once activated -----
    if (activated) {
      _drawWaterCone(canvas, fireHead, fireBaseY, t);
    }

    // ----- Labels -----
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(riserX + 6, riserTopY + 4),
      'Wet riser',
      background: AppColors.coldWater,
      textColor: Colors.white,
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(houseLeft + 30, lowerCeilingY - 18),
      'Ground-floor branch (Cat 1/2)',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(houseLeft + 30, upperCeilingY - 18),
      'First-floor branch',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(houseLeft + 4, secondFloorTop + 4),
      'Loft / pump room',
      background: AppColors.primary,
      textColor: Colors.white,
    );

    // Status indicator (top-right card)
    final statusRect = Rect.fromLTWH(w - 170, 10, 160, 56);
    canvas.drawRRect(
      RRect.fromRectAndRadius(statusRect, const Radius.circular(8)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(statusRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final statusText = activated
        ? 'HEAD OPEN — water flowing'
        : ignited
            ? 'Heating bulb… ${(heat * 100).toStringAsFixed(0)}%'
            : 'Standby';
    final statusColor = activated
        ? AppColors.accent
        : ignited
            ? AppColors.gas
            : AppColors.muted;
    final tp = TextPainter(
      text: TextSpan(
        text: '$statusText\nRating: $tempRating°C',
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: statusRect.width - 12);
    tp.paint(canvas, Offset(statusRect.left + 6, statusRect.top + 6));

    // Step-aware highlight ring (e.g. ring head, alarm valve, pump etc.)
    _drawStepHighlight(
      canvas,
      step: step,
      t: t,
      fireHead: fireHead,
      pumpCentre: pumpCentre,
      alarmCentre: alarmCentre,
      gongCentre: gongCentre,
      tankRect: tankRect,
      flowSwitch: flowSwitch,
    );
  }

  // -------------------- helpers --------------------
  void _drawHead(
    Canvas canvas,
    Offset p, {
    required String orientation,
    required double heat,
    required bool activated,
  }) {
    // Connecting drop from pipe to head body
    final dropY = orientation == 'upright' ? p.dy - 14 : p.dy - 12;
    canvas.drawLine(
      Offset(p.dx, dropY),
      Offset(p.dx, p.dy + 4),
      Paint()
        ..color = AppColors.brass
        ..strokeWidth = 5,
    );
    // Body
    final body = Paint()..color = AppColors.brass;
    final bodyStroke = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(p, 7, body);
    canvas.drawCircle(p, 7, bodyStroke);

    // Deflector (small horizontal line under)
    canvas.drawLine(
      Offset(p.dx - 8, p.dy + 8),
      Offset(p.dx + 8, p.dy + 8),
      Paint()
        ..color = AppColors.pipeMetal
        ..strokeWidth = 2,
    );

    // Bulb (red liquid). Heats up to white-hot then bursts.
    final bulbY = p.dy + 4;
    if (!activated) {
      final color = Color.lerp(
        const Color(0xFFE3413A),
        const Color(0xFFFFE066),
        heat.clamp(0.0, 1.0),
      )!;
      canvas.drawCircle(
        Offset(p.dx, bulbY),
        2.6 + heat * 0.4,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(p.dx, bulbY),
        2.6 + heat * 0.4,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    } else {
      // Burst — small shards
      final sh = Paint()..color = const Color(0xFFE3413A);
      for (int i = 0; i < 5; i++) {
        final a = i * 1.25 + t * 6;
        final r = 4.0 + (i % 2);
        canvas.drawCircle(
          Offset(p.dx + math.cos(a) * r, bulbY + math.sin(a) * r * 0.5),
          1.2,
          sh,
        );
      }
    }
  }

  void _drawFire(
    Canvas canvas,
    Offset base, {
    required double intensity,
    required bool damped,
    required double t,
  }) {
    final amp = damped ? 0.25 : 1.0;
    final h = (16 + 60 * intensity) * amp;
    final w = (12 + 28 * intensity) * amp;
    final flickX = math.sin(t * math.pi * 4) * 2;
    final flickY = math.cos(t * math.pi * 6) * 1.6;
    final outer = Path()
      ..moveTo(base.dx - w, base.dy)
      ..quadraticBezierTo(base.dx - w * 0.4 + flickX,
          base.dy - h * 0.4 + flickY, base.dx + flickX, base.dy - h)
      ..quadraticBezierTo(base.dx + w * 0.5 + flickX,
          base.dy - h * 0.5 - flickY, base.dx + w, base.dy)
      ..close();
    canvas.drawPath(
      outer,
      Paint()..color = AppColors.gas.withValues(alpha: 0.85),
    );
    final inner = Path()
      ..moveTo(base.dx - w * 0.6, base.dy)
      ..quadraticBezierTo(base.dx - w * 0.2,
          base.dy - h * 0.5, base.dx, base.dy - h * 0.8)
      ..quadraticBezierTo(base.dx + w * 0.3,
          base.dy - h * 0.4, base.dx + w * 0.6, base.dy)
      ..close();
    canvas.drawPath(
      inner,
      Paint()..color = AppColors.accent.withValues(alpha: 0.9),
    );
    // Glow under fire
    canvas.drawCircle(
      base,
      w * 1.2,
      Paint()
        ..color = AppColors.gas.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  void _drawHeatPlume(
    Canvas canvas, {
    required Offset from,
    required Offset to,
    required double progress,
    required double heatLevel,
    required bool damped,
  }) {
    final amp = damped ? 0.3 : 1.0;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final segs = 12;
    for (int i = 0; i < segs; i++) {
      final s = i / segs;
      final off = math.sin((progress * 2 * math.pi) + s * 4) * 6;
      final cx = from.dx + dx * s + off;
      final cy = from.dy + dy * s;
      final r = (10 + 18 * (1 - s)) * (0.5 + 0.5 * heatLevel) * amp;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = Colors.grey
              .withValues(alpha: 0.10 + 0.18 * (1 - s) * amp)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    // Hot air shimmer right under the head
    if (!damped && dist > 0) {
      canvas.drawCircle(
        to,
        18 + 8 * heatLevel,
        Paint()
          ..color = AppColors.gas.withValues(alpha: 0.25 * heatLevel)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  void _drawWaterCone(
    Canvas canvas, Offset head, double floorY, double t) {
    final spread = 70.0;
    final cone = Path()
      ..moveTo(head.dx, head.dy + 8)
      ..lineTo(head.dx - spread, floorY - 2)
      ..lineTo(head.dx + spread, floorY - 2)
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..color = AppColors.coldWater.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Particles
    final droplet = Paint()..color = AppColors.coldWater;
    final rng = math.Random(7);
    for (int i = 0; i < 28; i++) {
      final base = rng.nextDouble();
      final phase = (t + base) % 1.0;
      final spread2 = (rng.nextDouble() * 2 - 1);
      final x = head.dx + spread2 * spread * phase;
      final y = head.dy + 8 + (floorY - head.dy - 10) * phase;
      canvas.drawCircle(Offset(x, y), 1.6, droplet);
    }
    // Splash ring at the floor
    final splashR = 14 + (math.sin(t * math.pi * 4).abs()) * 6;
    canvas.drawCircle(
      Offset(head.dx, floorY - 2),
      splashR,
      Paint()
        ..color = AppColors.coldWater.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _drawPump(Canvas canvas, Offset c, {required bool running}) {
    final r = 14.0;
    canvas.drawCircle(
      c,
      r,
      Paint()..color = const Color(0xFFE5E7EB),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Impeller
    final ang = running ? t * math.pi * 6 : 0.0;
    for (int i = 0; i < 4; i++) {
      final a = ang + i * math.pi / 2;
      canvas.drawLine(
        c,
        Offset(c.dx + math.cos(a) * (r - 3),
            c.dy + math.sin(a) * (r - 3)),
        Paint()
          ..color = AppColors.primary
          ..strokeWidth = 2,
      );
    }
    if (running) {
      canvas.drawCircle(
        c,
        r + 5,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  void _drawAlarmValve(Canvas canvas, Offset c, {required bool open, required double t}) {
    final body = Rect.fromCenter(center: c, width: 26, height: 26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(4)),
      Paint()..color = const Color(0xFFE5E7EB),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Clapper indicator: closed = horizontal line, open = tilted
    final ang = open ? -math.pi / 4 : 0.0;
    final clapperPaint = Paint()
      ..color = open ? AppColors.accent : AppColors.muted
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final cx = c.dx;
    final cy = c.dy;
    final r = 9.0;
    canvas.drawLine(
      Offset(cx - r * math.cos(ang), cy - r * math.sin(ang)),
      Offset(cx + r * math.cos(ang), cy + r * math.sin(ang)),
      clapperPaint,
    );
    if (open) {
      // Pulsing ring
      final pulse = (math.sin(t * math.pi * 4) + 1) / 2;
      canvas.drawCircle(
        c,
        18 + 4 * pulse,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.25 + 0.2 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  void _drawGong(Canvas canvas, Offset c, {required bool ringing, required double t}) {
    canvas.drawCircle(c, 12, Paint()..color = AppColors.brass);
    canvas.drawCircle(
      c,
      12,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(c, 4, Paint()..color = Colors.black54);
    if (ringing) {
      final pulse = (math.sin(t * math.pi * 8) + 1) / 2;
      for (int i = 1; i <= 3; i++) {
        canvas.drawCircle(
          c,
          12 + i * 6 + pulse * 3,
          Paint()
            ..color = AppColors.accent
                .withValues(alpha: (0.4 - i * 0.1).clamp(0.0, 1.0))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3,
        );
      }
    }
  }

  void _drawFlowSwitch(Canvas canvas, Offset c, {required bool active}) {
    final body = Rect.fromCenter(center: c, width: 18, height: 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(2)),
      Paint()..color = active ? AppColors.accent : const Color(0xFFE5E7EB),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(2)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Indicator LED
    canvas.drawCircle(
      Offset(c.dx, c.dy - 9),
      2.4,
      Paint()
        ..color = active ? AppColors.accent : AppColors.muted,
    );
  }

  void _drawStepHighlight(
    Canvas canvas, {
    required int step,
    required double t,
    required Offset fireHead,
    required Offset pumpCentre,
    required Offset alarmCentre,
    required Offset gongCentre,
    required Rect tankRect,
    required Offset flowSwitch,
  }) {
    Offset? target;
    double radius = 28;
    switch (step) {
      case 0:
      case 1:
      case 5:
        target = fireHead;
        radius = 22;
        break;
      case 2:
        target = alarmCentre;
        radius = 26;
        break;
      case 3:
        target = flowSwitch;
        radius = 22;
        break;
      case 4:
        target = Offset(tankRect.center.dx,
            (tankRect.bottom + pumpCentre.dy) / 2);
        radius = 50;
        break;
      case 6:
        target = fireHead;
        radius = 24;
        break;
      case 7:
        target = gongCentre;
        radius = 22;
        break;
    }
    if (target == null) return;
    final pulse = (math.sin(t * math.pi * 3) + 1) / 2;
    canvas.drawCircle(
      target,
      radius + pulse * 6,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.35 + 0.25 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SprinklerPainter o) => true;
}
