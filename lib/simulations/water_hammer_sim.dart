import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sim_scaffold.dart';
import '../widgets/paint_helpers.dart';

class WaterHammerSimScreen extends StatefulWidget {
  const WaterHammerSimScreen({super.key});
  @override
  State<WaterHammerSimScreen> createState() => _WaterHammerSimScreenState();
}

class _WaterHammerSimScreenState extends State<WaterHammerSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _arrestor = true;
  bool _valveOpen = true;
  double _flow = 0.6; // 0..1
  // Hammer event timing: when the valve closes quickly we trigger an event.
  double _eventStart = -10; // animation seconds where event began
  double _now = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _ctrl.addListener(_tick);
  }

  void _tick() {
    setState(() {
      _now += 1 / 60.0;
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_tick);
    _ctrl.dispose();
    super.dispose();
  }

  void _slamValve() {
    setState(() {
      _valveOpen = false;
      _eventStart = _now;
    });
  }

  void _reopenValve() {
    setState(() {
      _valveOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final steps = const [
      SimStep(
        title: 'What is water hammer',
        narration:
            'Water hammer is a pressure surge caused by a sudden change in flow. When fast moving water is stopped abruptly, its kinetic energy converts into a shock wave that travels through the pipe.',
      ),
      SimStep(
        title: 'Equation',
        narration:
            'The Joukowsky equation gives the pressure rise as density times wave speed times the change in velocity. Even a one metre per second flow can produce pressure spikes of ten bar or more.',
      ),
      SimStep(
        title: 'Damage',
        narration:
            'Repeated surges loosen joints, crack fittings, fatigue cisterns and split flexible hoses. The characteristic banging in walls is a warning that damage is accumulating.',
      ),
      SimStep(
        title: 'Quick-closing devices',
        narration:
            'The usual culprits are solenoid valves on washing machines and dishwashers, lever taps and quarter-turn ball valves. Each can close in a fraction of a second.',
      ),
      SimStep(
        title: 'Mitigation',
        narration:
            'Use slow-closing valves where you can, secure pipework with clips at sensible spacings, and fit water hammer arrestors close to the offending appliance.',
      ),
      SimStep(
        title: 'Air arrestor types',
        narration:
            'A simple capped air pocket above a tee will absorb shocks until it waterlogs. A piston type arrestor with a sealed gas charge keeps working without maintenance.',
      ),
      SimStep(
        title: 'Charging a piston arrestor',
        narration:
            'Piston arrestors are pre-charged at the factory, typically to two or three bar. Some serviceable models allow a top-up via a Schrader valve.',
      ),
      SimStep(
        title: 'Diagnostic',
        narration:
            'If banging persists, walk the run, tighten loose clips and add or replace an arrestor close to the appliance. Soft closing taps are also worth fitting.',
      ),
    ];

    return SimScaffold(
      title: 'Water Hammer',
      summary:
          'Watch a sudden valve slam create a pressure pulse that travels back along the pipe. Toggle the arrestor and observe how the spike is absorbed.',
      steps: steps,
      diagramBuilder: (ctx, step) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _HammerPainter(
            step: step,
            t: _ctrl.value,
            now: _now,
            eventStart: _eventStart,
            arrestor: _arrestor,
            valveOpen: _valveOpen,
            flow: _flow,
          ),
          child: const SizedBox.expand(),
        ),
      ),
      controls: [
        ElevatedButton.icon(
          onPressed: _valveOpen ? _slamValve : _reopenValve,
          icon: Icon(_valveOpen ? Icons.flash_on : Icons.refresh),
          label: Text(_valveOpen ? 'Close valve quickly' : 'Reopen valve'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Arrestor fitted', style: TextStyle(fontSize: 12)),
            Switch.adaptive(
              value: _arrestor,
              onChanged: (v) => setState(() => _arrestor = v),
            ),
          ],
        ),
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Flow velocity: ${(_flow * 3).toStringAsFixed(1)} m/s',
                  style: const TextStyle(fontSize: 12)),
              Slider(
                min: 0,
                max: 1,
                value: _flow,
                onChanged: (v) => setState(() => _flow = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HammerPainter extends CustomPainter {
  final int step;
  final double t;
  final double now;
  final double eventStart;
  final bool arrestor;
  final bool valveOpen;
  final double flow;

  _HammerPainter({
    required this.step,
    required this.t,
    required this.now,
    required this.eventStart,
    required this.arrestor,
    required this.valveOpen,
    required this.flow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.cardBg);

    // Layout
    final yMain = h * 0.55;
    final cisternRect = Rect.fromLTWH(w * 0.04, h * 0.18, w * 0.14, h * 0.30);
    final pipeStart = Offset(cisternRect.right - 4, yMain);
    final stop = Offset(w * 0.27, yMain);
    final tBranch = Offset(w * 0.55, yMain);
    final solenoid = Offset(w * 0.78, yMain);
    final deadEnd = Offset(w * 0.93, yMain);
    final arrestorTop = Offset(tBranch.dx, tBranch.dy - h * 0.30);

    // Cistern
    PipePainterHelpers.drawTank(
      canvas,
      rect: cisternRect,
      level: 0.7,
      open: false,
      label: 'Cistern',
    );

    // Wobble offset for the pipe during hammer event without arrestor
    double wobble = 0;
    final since = now - eventStart;
    if (!valveOpen && !arrestor && since >= 0 && since < 1.6) {
      wobble = math.sin(since * 30) * 3 * (1 - since / 1.6);
    }

    // Main pipe
    PipePainterHelpers.drawPipe(
      canvas,
      a: pipeStart + Offset(0, wobble),
      b: deadEnd + Offset(0, wobble),
      color: AppColors.coldWater,
      width: 14,
    );
    // Arrestor branch
    PipePainterHelpers.drawPipe(
      canvas,
      a: tBranch,
      b: arrestorTop,
      color: AppColors.coldWater,
      width: 12,
    );

    // Stop tap (isolating)
    PipePainterHelpers.drawValve(canvas, stop, open: true);

    // T-branch joint
    PipePainterHelpers.drawJoint(canvas, tBranch);
    PipePainterHelpers.drawJoint(canvas, pipeStart);

    // Solenoid valve depiction
    _drawSolenoid(canvas, solenoid, open: valveOpen);

    // Dead-end cap
    _drawDeadEnd(canvas, deadEnd);

    // Arrestor body (piston type) at top of branch
    _drawArrestor(canvas, arrestorTop, arrestor: arrestor, since: since, valveOpen: valveOpen);

    // Particles flow when valve open and flow > 0
    if (valveOpen && flow > 0.05) {
      PipePainterHelpers.drawFlowParticles(
        canvas,
        a: pipeStart,
        b: solenoid,
        progress: t,
        color: AppColors.coldWater.withValues(alpha: 0.95),
        count: (4 + flow * 8).toInt(),
      );
    }

    // Pressure pulse: travels backwards from solenoid towards cistern when valve slams
    if (!valveOpen && since >= 0 && since < 1.4) {
      // Position based on time
      final waveSpeed = 1.0 / 1.0; // normalised
      final progress = (since * waveSpeed).clamp(0.0, 1.0);
      // From solenoid leftwards
      final pulseX = solenoid.dx - (solenoid.dx - pipeStart.dx) * progress;
      // Pulse intensity reduced if arrestor fitted and pulse passes T
      final passedT = pulseX < tBranch.dx;
      final attenuated = arrestor && passedT;
      final amp = (1 - progress) * (attenuated ? 0.25 : 1.0) * (0.5 + flow * 0.5);

      // Draw coloured pulse band
      final pulseColor = AppColors.hotWater.withValues(alpha: 0.4 + amp * 0.4);
      canvas.drawCircle(
        Offset(pulseX, yMain + wobble),
        16 + amp * 6,
        Paint()
          ..color = pulseColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Concentric noise rings at fittings if no arrestor
      if (!arrestor && progress < 0.6) {
        for (final f in [tBranch, pipeStart]) {
          final r = 8 + progress * 40;
          canvas.drawCircle(
            f,
            r,
            Paint()
              ..color = AppColors.accent.withValues(alpha: 0.6 * (1 - progress))
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }

    // Gauge near solenoid
    final gaugeC = Offset(solenoid.dx - 50, solenoid.dy - 60);
    _drawSpikeGauge(canvas, gaugeC, since: since, arrestor: arrestor, valveOpen: valveOpen, flow: flow);

    // Labels
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(stop.dx - 18, stop.dy + 18),
      'Isolating stop',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(pipeStart.dx + 10, pipeStart.dy - 24),
      'Pipe length',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(tBranch.dx - 18, tBranch.dy + 18),
      'T-branch',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(arrestorTop.dx - 30, arrestorTop.dy - 28),
      arrestor ? 'Air arrestor' : 'Arrestor (off)',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(solenoid.dx - 26, solenoid.dy + 26),
      'Solenoid valve',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(deadEnd.dx - 28, deadEnd.dy - 28),
      'Dead-end',
    );
    PipePainterHelpers.drawLabel(
      canvas,
      Offset(gaugeC.dx - 26, gaugeC.dy - 32),
      'Gauge',
    );

    // Step hint
    PipePainterHelpers.drawLabel(
      canvas,
      const Offset(12, 10),
      valveOpen
          ? 'Step ${step + 1}: Normal flow'
          : (arrestor
              ? 'Step ${step + 1}: Slam — arrestor absorbs pulse'
              : 'Step ${step + 1}: Slam — pulse travels back!'),
      background: AppColors.primary,
      textColor: Colors.white,
    );
  }

  void _drawSolenoid(Canvas canvas, Offset p, {required bool open}) {
    // Body
    final body = Rect.fromCenter(center: Offset(p.dx, p.dy - 20), width: 30, height: 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(4)),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Coil winding lines
    for (int i = 0; i < 4; i++) {
      final y = body.top + 6 + i * 7;
      canvas.drawLine(
        Offset(body.left + 2, y),
        Offset(body.right - 2, y),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.2,
      );
    }
    // Plunger / valve seat
    PipePainterHelpers.drawValve(canvas, p, open: open, size: 12);
    // Wires
    canvas.drawLine(
      Offset(body.right, body.top + 6),
      Offset(body.right + 14, body.top - 6),
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2,
    );
  }

  void _drawDeadEnd(Canvas canvas, Offset p) {
    canvas.drawRect(
      Rect.fromCenter(center: p, width: 12, height: 22),
      Paint()..color = AppColors.brass,
    );
    canvas.drawRect(
      Rect.fromCenter(center: p, width: 12, height: 22),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawArrestor(Canvas canvas, Offset top,
      {required bool arrestor, required double since, required bool valveOpen}) {
    // Cylinder body extends upwards
    final body = Rect.fromCenter(center: Offset(top.dx, top.dy - 30), width: 22, height: 60);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(4)),
      Paint()..color = arrestor ? AppColors.pipeMetal : Colors.grey.shade300,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(4)),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    if (arrestor) {
      // Piston compresses during hammer event
      double pistonOffset = 0;
      if (!valveOpen && since >= 0 && since < 1.0) {
        pistonOffset = math.sin(since * math.pi) * 8;
      }
      final pistonY = body.center.dy + 6 - pistonOffset;
      // Air pocket above piston (light)
      canvas.drawRect(
        Rect.fromLTRB(body.left + 2, body.top + 2, body.right - 2, pistonY - 2),
        Paint()..color = const Color(0xFFFFE9B3),
      );
      // Water below piston
      canvas.drawRect(
        Rect.fromLTRB(body.left + 2, pistonY + 2, body.right - 2, body.bottom - 2),
        Paint()..color = AppColors.coldWater.withValues(alpha: 0.7),
      );
      // Piston disk
      canvas.drawRect(
        Rect.fromLTWH(body.left + 1, pistonY, body.width - 2, 4),
        Paint()..color = Colors.black87,
      );
      // Schrader valve at top
      canvas.drawRect(
        Rect.fromLTWH(top.dx - 3, body.top - 6, 6, 6),
        Paint()..color = AppColors.brass,
      );
      PipePainterHelpers.drawLabel(
        canvas,
        Offset(top.dx + 12, body.top - 4),
        '2-3 bar',
        fontSize: 9,
      );
    } else {
      // Show capped stub (waterlogged)
      canvas.drawRect(
        Rect.fromLTRB(body.left + 2, body.top + 2, body.right - 2, body.bottom - 2),
        Paint()..color = AppColors.coldWater.withValues(alpha: 0.5),
      );
    }
  }

  void _drawSpikeGauge(Canvas canvas, Offset c,
      {required double since,
      required bool arrestor,
      required bool valveOpen,
      required double flow}) {
    final r = 26.0;
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    // Working pressure baseline = 0.4
    double normPressure = 0.35 + flow * 0.15;
    if (!valveOpen && since >= 0 && since < 1.4) {
      // spike
      final spikeAmp = arrestor ? 0.18 : 0.55;
      final spike = spikeAmp * math.exp(-since * 2.5) * (since < 0.6 ? 1 : math.cos(since * 6).abs());
      normPressure += spike;
    }
    normPressure = normPressure.clamp(0.0, 1.0);
    final ang = math.pi * 0.75 + normPressure * math.pi * 1.5;
    final tip = Offset(c.dx + math.cos(ang) * (r - 4), c.dy + math.sin(ang) * (r - 4));
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 3, Paint()..color = Colors.black87);
    // Tick marks
    for (int i = 0; i <= 4; i++) {
      final a = math.pi * 0.75 + (i / 4) * math.pi * 1.5;
      canvas.drawLine(
        Offset(c.dx + math.cos(a) * (r - 2), c.dy + math.sin(a) * (r - 2)),
        Offset(c.dx + math.cos(a) * (r - 7), c.dy + math.sin(a) * (r - 7)),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HammerPainter o) => true;
}
