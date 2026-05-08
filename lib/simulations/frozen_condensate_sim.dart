import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class FrozenCondensateSimScreen extends StatefulWidget {
  const FrozenCondensateSimScreen({super.key});
  @override
  State<FrozenCondensateSimScreen> createState() =>
      _FrozenCondensateSimScreenState();
}

class _FrozenCondensateSimScreenState extends State<FrozenCondensateSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _thaw = 0.0; // 0..1 — 1 means ice cleared
  bool _running = false;
  bool _insulated = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _steps = <SimStep>[
    SimStep(
        title: 'Symptom — winter lockout',
        narration:
            'In a cold snap the boiler trips out and shows code A02 or F19. Customer calls saying their heating died this morning and the temperature outside fell below freezing.'),
    SimStep(
        title: 'Why condensate freezes',
        narration:
            'Boiler condensate is mildly acidic water at around pH 4. It freezes at roughly 0°C and easily blocks small-bore external pipework, especially overnight.'),
    SimStep(
        title: 'Locate the freeze',
        narration:
            'Trace the 21.5 mm condensate route from the boiler trap, through the wall, and down the outside. Most freezes are in the external section or at the open termination.'),
    SimStep(
        title: 'Safe thawing methods',
        narration:
            'Use a warm cloth wrapped around the pipe or a jug of warm — not boiling — water. Boiling water can crack plastic pipe and scald you when it splashes back.'),
    SimStep(
        title: 'Pour warm water along the pipe',
        narration:
            'Work top to bottom. Pour repeatedly along the length and especially at the trap and any horizontal section. Keep going until you see water flowing freely.'),
    SimStep(
        title: 'Reset the boiler',
        narration:
            'Once the pipe is clear, press reset. The lockout clears, the fan runs, and the burner fires. Confirm condensate runs again at the termination.'),
    SimStep(
        title: 'Prevent recurrence',
        narration:
            'Lag the external pipe with weatherproof foam, increase to 32 mm minimum outside, and where possible route to an internal stack to avoid external runs entirely.'),
    SimStep(
        title: 'When to recall',
        narration:
            'If the freeze recurs after lagging, recommend rerouting internally or fitting a trace heating element. Document on the Benchmark log for the next service.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      title: 'Frozen condensate diagnoser',
      summary:
          'A condensing boiler in winter lockout. Use Pour warm water to thaw the ice plug, then Reset boiler to clear the lockout. Toggle Insulate pipe to reduce future risk.',
      diagramBuilder: (_, idx) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _FrozenCondensatePainter(
              step: idx,
              t: _ctrl.value,
              thaw: _thaw,
              running: _running,
              insulated: _insulated,
            ),
          ),
        );
      },
      steps: _steps,
      onStepChanged: (_) => setState(() {}),
      controls: [
        ElevatedButton.icon(
          icon: const Icon(Icons.water_drop, size: 18),
          label: const Text('Pour warm water'),
          onPressed: () {
            setState(() {
              _thaw = (_thaw + 0.25).clamp(0.0, 1.0);
            });
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.power_settings_new, size: 18),
          label: const Text('Reset boiler'),
          onPressed: _thaw >= 1.0
              ? () => setState(() => _running = true)
              : null,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Insulate pipe', style: TextStyle(fontSize: 12)),
            Switch.adaptive(
              value: _insulated,
              onChanged: (v) => setState(() => _insulated = v),
            ),
          ],
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Re-freeze'),
          onPressed: () => setState(() {
            _thaw = 0.0;
            _running = false;
          }),
        ),
      ],
    );
  }
}

class _FrozenCondensatePainter extends CustomPainter {
  final int step;
  final double t;
  final double thaw;
  final bool running;
  final bool insulated;
  _FrozenCondensatePainter(
      {required this.step,
      required this.t,
      required this.thaw,
      required this.running,
      required this.insulated});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky / outside background (right portion)
    final wallX = w * 0.55;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, wallX, h),
        Paint()..color = const Color(0xFFFAF3E2)); // kitchen warm
    canvas.drawRect(
        Rect.fromLTWH(wallX, 0, w - wallX, h),
        Paint()..color = const Color(0xFFD9EAF5)); // outside cold

    // Wall divider
    canvas.drawRect(Rect.fromLTWH(wallX - 12, 0, 24, h),
        Paint()..color = const Color(0xFFB6A47A));
    PipePainterHelpers.drawLabel(canvas, Offset(wallX - 22, 6), 'External wall');
    PipePainterHelpers.drawLabel(
        canvas, Offset(8, 6), 'Kitchen interior');
    PipePainterHelpers.drawLabel(
        canvas, Offset(wallX + 24, 6), 'Outside (~ -3°C)');

    // Boiler on inside wall
    final boilerRect = Rect.fromLTWH(40, 60, 200, 200);
    canvas.drawRRect(
        RRect.fromRectAndRadius(boilerRect, const Radius.circular(10)),
        Paint()..color = const Color(0xFFEAF0F4));
    canvas.drawRRect(
        RRect.fromRectAndRadius(boilerRect, const Radius.circular(10)),
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    // boiler display
    final dispRect = Rect.fromLTWH(boilerRect.left + 50,
        boilerRect.top + 20, 100, 40);
    canvas.drawRRect(
        RRect.fromRectAndRadius(dispRect, const Radius.circular(4)),
        Paint()..color = const Color(0xFF0B1F33));
    final code = running ? 'OK' : (thaw >= 1.0 ? 'RDY' : 'A02');
    final codeColor = running
        ? Colors.greenAccent
        : (thaw >= 1.0 ? Colors.amberAccent : Colors.redAccent);
    final tp = TextPainter(
      text: TextSpan(
          text: code,
          style: TextStyle(
              color: codeColor,
              fontSize: 22,
              fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas,
        Offset(dispRect.center.dx - tp.width / 2,
            dispRect.center.dy - tp.height / 2));
    PipePainterHelpers.drawLabel(canvas, Offset(dispRect.left - 4, dispRect.top - 16),
        'Boiler display');

    if (!running) {
      PipePainterHelpers.drawLabel(canvas,
          Offset(dispRect.left, dispRect.bottom + 6),
          'Condensate blocked',
          background: Colors.redAccent, textColor: Colors.white);
    }

    PipePainterHelpers.drawLabel(canvas,
        Offset(boilerRect.left + 8, boilerRect.bottom - 22),
        'Wall-mounted condensing boiler');

    // Internal trap under boiler
    final trapTop = Offset(boilerRect.center.dx - 30, boilerRect.bottom);
    final trapBot = Offset(boilerRect.center.dx - 30, boilerRect.bottom + 40);
    PipePainterHelpers.drawPipe(canvas,
        a: trapTop,
        b: trapBot,
        color: AppColors.waste,
        width: 10);
    final trapU1 = Offset(trapBot.dx, trapBot.dy);
    final trapU2 = Offset(trapBot.dx + 30, trapBot.dy + 14);
    final trapU3 = Offset(trapBot.dx + 60, trapBot.dy);
    canvas.drawPath(
      Path()
        ..moveTo(trapU1.dx, trapU1.dy)
        ..quadraticBezierTo(trapU2.dx, trapU2.dy, trapU3.dx, trapU3.dy),
      Paint()
        ..color = AppColors.waste
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    PipePainterHelpers.drawLabel(
        canvas, Offset(trapU2.dx - 30, trapU2.dy + 16), 'Internal trap');

    // Run from trap to wall
    final beforeWall = Offset(trapU3.dx, trapU3.dy);
    final wallEntry = Offset(wallX - 14, h * 0.55);
    PipePainterHelpers.drawPipe(canvas,
        a: beforeWall, b: Offset(beforeWall.dx, wallEntry.dy), color: AppColors.waste, width: 10);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(beforeWall.dx, wallEntry.dy), b: wallEntry, color: AppColors.waste, width: 10);
    PipePainterHelpers.drawJoint(canvas, Offset(beforeWall.dx, wallEntry.dy));

    // Outside section: through wall then drops vertically to drain
    final wallExit = Offset(wallX + 12, wallEntry.dy);
    PipePainterHelpers.drawPipe(canvas,
        a: wallExit,
        b: Offset(w - 80, wallEntry.dy),
        color: AppColors.waste,
        width: 10);
    PipePainterHelpers.drawJoint(canvas, Offset(w - 80, wallEntry.dy));
    final outBottom = Offset(w - 80, h - 60);
    PipePainterHelpers.drawPipe(canvas,
        a: Offset(w - 80, wallEntry.dy),
        b: outBottom,
        color: AppColors.waste,
        width: 10);

    // Frost on outside pipe (if not insulated and not fully thawed)
    if (!insulated) {
      final frost = Paint()
        ..color = Colors.lightBlue.shade100.withValues(alpha: 0.8 - 0.6 * thaw);
      // around horizontal external bit
      canvas.drawRect(
          Rect.fromLTWH(wallX + 14, wallEntry.dy - 8,
              (w - 80) - (wallX + 14), 16),
          frost);
      // around vertical drop
      canvas.drawRect(
          Rect.fromLTWH(w - 88, wallEntry.dy + 8, 16,
              (outBottom.dy - wallEntry.dy) - 16),
          frost);
    } else {
      // foam lagging wrapper
      final lag = Paint()..color = const Color(0xFF6E6F73).withValues(alpha: 0.6);
      canvas.drawRect(
          Rect.fromLTWH(wallX + 14, wallEntry.dy - 12,
              (w - 80) - (wallX + 14), 24),
          lag);
      canvas.drawRect(
          Rect.fromLTWH(w - 92, wallEntry.dy + 8, 24,
              (outBottom.dy - wallEntry.dy) - 16),
          lag);
      PipePainterHelpers.drawLabel(canvas,
          Offset(wallX + 30, wallEntry.dy - 28), 'Lagged 32 mm');
    }

    // Ice plug inside the pipe — visible until thaw == 1
    if (thaw < 1.0 && !insulated) {
      // plug at trap on inside (reading) and outside vertical
      final plugY = wallEntry.dy + 60;
      final plugRect = Rect.fromLTWH(w - 86, plugY, 12, 36 * (1 - thaw) + 12);
      canvas.drawRRect(
          RRect.fromRectAndRadius(plugRect, const Radius.circular(2)),
          Paint()..color = const Color(0xFFB7E6F4));
      canvas.drawRRect(
          RRect.fromRectAndRadius(plugRect, const Radius.circular(2)),
          Paint()
            ..color = Colors.lightBlue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
      // pulsing red ring
      final pulse = 24 + 6 * math.sin(t * math.pi * 2);
      canvas.drawCircle(
          plugRect.center,
          pulse,
          Paint()
            ..color = Colors.redAccent
                .withValues(alpha: 0.5 - 0.3 * math.sin(t * math.pi * 2))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      PipePainterHelpers.drawLabel(canvas,
          Offset(plugRect.center.dx - 14, plugRect.top - 18), 'ICE PLUG',
          background: Colors.lightBlue, textColor: Colors.white);
    }

    // Termination: drain / gully
    final gullyRect =
        Rect.fromLTWH(outBottom.dx - 24, outBottom.dy - 6, 48, 18);
    canvas.drawRRect(
        RRect.fromRectAndRadius(gullyRect, const Radius.circular(4)),
        Paint()..color = const Color(0xFF555E66));
    canvas.drawRRect(
        RRect.fromRectAndRadius(gullyRect, const Radius.circular(4)),
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    PipePainterHelpers.drawLabel(
        canvas, Offset(gullyRect.left - 6, gullyRect.bottom + 4),
        'Outside drain / gully');

    // Drips from pipe end if running
    if (running) {
      for (int i = 0; i < 4; i++) {
        final dt = ((t + i / 4) % 1.0);
        final y = outBottom.dy - 12 + dt * 14;
        canvas.drawCircle(Offset(outBottom.dx, y), 3,
            Paint()..color = AppColors.coldWater);
      }
      // Flow particles inside the inside trap pipe
      PipePainterHelpers.drawFlowParticles(canvas,
          a: trapTop,
          b: trapBot,
          progress: t,
          color: AppColors.coldWater,
          count: 4,
          radius: 2.6);
    }

    // Pourer animation — show jug pouring above iced section while user clicks button
    if (thaw > 0 && thaw < 1.0) {
      final jugX = w - 80;
      final jugY = wallEntry.dy + 30;
      // jug
      final jr = Rect.fromLTWH(jugX - 24, jugY - 24, 28, 22);
      canvas.drawRRect(
          RRect.fromRectAndRadius(jr, const Radius.circular(3)),
          Paint()..color = Colors.brown.shade300);
      canvas.drawLine(
          Offset(jr.right, jr.top + 4),
          Offset(jr.right + 6, jr.top - 2),
          Paint()
            ..color = Colors.brown.shade400
            ..strokeWidth = 4);
      // water stream
      for (int i = 0; i < 6; i++) {
        final dt = ((t + i / 6) % 1.0);
        final p = Offset(jugX - 4, jr.bottom + dt * 36);
        canvas.drawCircle(p, 2.4, Paint()..color = AppColors.hotWater.withValues(alpha: 0.7));
      }
      PipePainterHelpers.drawLabel(canvas,
          Offset(jr.left - 24, jr.top - 16), 'Warm water (NOT boiling)',
          background: Colors.amber.shade300);
    }

    // Inside flow (running) particles to confirm condensate moves
    if (running) {
      PipePainterHelpers.drawFlowParticles(canvas,
          a: wallExit,
          b: Offset(w - 80, wallEntry.dy),
          progress: t,
          color: AppColors.coldWater,
          count: 5,
          radius: 2.4);
      PipePainterHelpers.drawFlowParticles(canvas,
          a: Offset(w - 80, wallEntry.dy),
          b: outBottom,
          progress: t,
          color: AppColors.coldWater,
          count: 6,
          radius: 2.4);
    }

    // Thaw progress meter
    final meterRect = Rect.fromLTWH(20, h - 36, 220, 14);
    canvas.drawRRect(
        RRect.fromRectAndRadius(meterRect, const Radius.circular(7)),
        Paint()..color = Colors.black12);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(meterRect.left, meterRect.top,
                meterRect.width * thaw, meterRect.height),
            const Radius.circular(7)),
        Paint()..color = Colors.green);
    PipePainterHelpers.drawLabel(canvas, Offset(meterRect.left, meterRect.top - 16),
        'Thaw progress: ${(thaw * 100).round()}%');

    // Snowflakes outside if not running and not insulated
    if (!insulated) {
      for (int i = 0; i < 12; i++) {
        final px = wallX + 20 + ((i * 53.0 + t * 60) % (w - wallX - 40));
        final py = ((i * 41.0 + t * 80) % (h - 80));
        canvas.drawCircle(Offset(px, py), 2,
            Paint()..color = Colors.white.withValues(alpha: 0.85));
      }
    }

    // Title labels
    PipePainterHelpers.drawLabel(canvas, Offset(8, h - 14),
        '21.5 mm condensate (or 32 mm external)');
  }

  @override
  bool shouldRepaint(_FrozenCondensatePainter o) => true;
}
